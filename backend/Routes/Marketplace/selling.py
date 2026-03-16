import os, shutil
import json
from fastapi import APIRouter, HTTPException, Request, status, UploadFile, File, Form
from typing import Dict, Any, List
from Routes.Auth.cookie import get_user_id
from utils import *
from queries.selling import *
from models import SellingItem, SellingResponse
from utils import S3Client
from .funcs import get_image_dict, authorize_edit_delete

router = APIRouter(prefix="/marketplace", tags=["marketplace"])


# add selling item
@router.post("/add_item")
async def add_item(request: Request,
                   form_data: str = Form(...),
                   images: List[UploadFile] = File(default=None),
                   ) -> Dict[str, Any]:

    try:
        form_data_dict = json.loads(form_data)
        user_id = get_user_id(request)
        with conn.cursor() as cur:
            cur.execute(insert_in_selling_table(form_data_dict, user_id))
            item = SellingItem.from_row(cur.fetchone())

        if images is not None:
            image_paths = S3Client.uploadToCloud(images, item.id, "selling")

            with conn.cursor() as cur:
                cur.execute(insert_selling_images(image_paths, item.id))
        conn.commit()
        return {"message": "Data inserted successfully"}

    except Exception as e:
        conn.rollback()
        error_message = f"An error occurred: {e}"
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=error_message)


# show all selling items sorted by created_at
# Go response shape: [{id, user_id, name, selling_price, description, created_at, images}, ...]
@router.get("/all")
async def get_all_selling_item_names() -> List[Dict[str, Any]]:
    try:
        with conn.cursor() as cur:
            cur.execute(get_all_selling_items())
            rows = cur.fetchall()

            # get_all_selling_items() returns:
            # s.id[0], s.item_name[1], s.item_description[2], s.user_id[3], images[4], s.created_at[5], s.selling_price[6]
            # json_agg may return a Python list or a JSON string depending on psycopg2 version
            def parse_images(img_val):
                if img_val is None:
                    return []
                if isinstance(img_val, str):
                    return json.loads(img_val)
                return img_val

            result = list(map(lambda x: {
                "id": x[0],
                "user_id": x[3],
                "name": x[1],
                "selling_price": float(x[6]),
                "description": x[2],
                "created_at": str(x[5]),
                "images": parse_images(x[4]),
            }, rows))

            return result

    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="failed to fetch items")


# show a particular selling item with images
# Go response shape: {id, item_name, description, username, user_email, user_phone_number, images, selling_price, created_at}
@router.get("/get_item/{id}")
def show_selling_item(id: int) -> SellingResponse:
    try:
        with conn.cursor() as cur:
            cur.execute(get_particular_selling_item(id))

            selling_item = cur.fetchall()
            if selling_item == []:
                raise HTTPException(status_code=404, detail="Item not found")
            selling_item = selling_item[0]
            cur.execute(get_all_image_uris(id))
            selling_images = cur.fetchall()
            image_urls = list(map(lambda x: x[0], selling_images))
            res = SellingResponse.from_row(selling_item, image_urls)
            return res

    except HTTPException:
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to fetch items: {e}")


# delete a selling item
# Frontend sends: DELETE /marketplace/delete_item/$id (path param, no body)
@router.delete("/delete_item/{id}")
def delete_selling_item(request: Request, id: int) -> Dict[str, str]:
    user_id = get_user_id(request)
    try:
        authorize_edit_delete("selling", id, user_id, conn)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {e}")

    try:
        with conn.cursor() as cur:
            query = f"DELETE from selling WHERE selling.id = {id}"
            cur.execute(query)

        S3Client.deleteFromCloud(id, "selling")
        conn.commit()

        return {"message": "Item deleted successfully!"}

    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail="Failed to delete item")


# update a selling item
# Frontend sends: PUT /marketplace/edit_item with JSON body {item_id, item_name, item_description, selling_price}
@router.put("/edit_item")
async def edit_selected_item(request: Request) -> Dict[str, str]:
    # checking authorization
    user_id = get_user_id(request)

    try:
        request_data = await request.json()
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid request data")

    item_id = request_data.get("item_id")
    if item_id is None:
        raise HTTPException(status_code=400, detail="Missing or invalid item_id")
    item_id = int(item_id)

    try:
        authorize_edit_delete("selling", item_id, user_id, conn)
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Error: {e}")

    # updating - remove item_id from data before updating
    try:
        update_data = {k: v for k, v in request_data.items() if k != "item_id"}

        with conn.cursor() as cur:
            cur.execute(update_in_selling_table(item_id, update_data))
            row = cur.fetchone()
            item = SellingItem.from_row(row)

            conn.commit()

        return {"message": "Item updated successfully"}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Error: {e}")


# search selling items
# Go response shape: [{id, item_name, item_description, user_id, created_at, images}, ...]
@router.get("/search")
def search(query: str, max_results: int = 100) -> List[Dict[str, Any]]:
    try:
        with conn.cursor() as cur:
            cur.execute(search_selling_items(query, max_results))
            res = cur.fetchall()

            if len(res) == 0:
                return []
            cur.execute(get_some_image_uris([x[0] for x in res]))
            images = cur.fetchall()

            image_dict = get_image_dict(images)
            # Go search response shape: {id, item_name, item_description, user_id, created_at, images}
            res = list(map(lambda x: {
                "id": x[0],
                "item_name": x[1],
                "item_description": x[2],
                "user_id": x[4],
                "created_at": str(x[5]),
                "images": image_dict.get(x[0], [])
            }, res))

        return res
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Error: {e}")


# get user's own selling items
# Go response shape: [{id, user_id, name, selling_price, description, created_at, images}, ...]
@router.get("/my_items")
def get_my_items(request: Request) -> List[Dict[str, Any]]:
    user_id = get_user_id(request)
    try:
        with conn.cursor() as cur:
            cur.execute(get_selling_items_by_user(user_id))
            rows = cur.fetchall()

            if len(rows) == 0:
                return []

            item_ids = [row[0] for row in rows]
            cur.execute(get_some_image_uris(item_ids))
            images = cur.fetchall()

            image_dict = get_image_dict(images)
            # get_selling_items_by_user SELECT *: id[0], item_name[1], item_description[2], selling_price[3], user_id[4], created_at[5]
            result = list(map(lambda x: {
                "id": x[0],
                "user_id": x[4],
                "name": x[1],
                "selling_price": float(x[3]),
                "description": x[2],
                "created_at": str(x[5]),
                "images": image_dict.get(x[0], [])
            }, rows))

        return result
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Error: {e}")
