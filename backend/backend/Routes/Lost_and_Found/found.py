import os, shutil
import json
from fastapi import APIRouter, HTTPException, Request, status, UploadFile, File, Form
from typing import Dict, Any, List, Tuple
from Routes.Auth.cookie import get_user_id
from utils import *
from queries.lost_and_found import *
from models import LfItem, LfResponse
from utils import S3Client
from .funcs import get_image_dict, authorize_edit_delete

router = APIRouter(prefix="/found", tags=["found"])



# add found item 
@router.post("/add_item")
async def add_item( request: Request,
                    form_data: str = Form(...),
                    images: List[UploadFile]  = File(default = None)
                    )  -> Dict[str, Any]:
    
    try:
        form_data_dict = json.loads(form_data)
        user_id = get_user_id(request)
        with conn.cursor() as cur:
            cur.execute( insert_in_table(TableType.FOUND, form_data_dict, user_id ) )
            item = LfItem.from_row(cur.fetchone())
        
        # update in elasticsearch
        
        if images is not None:
            image_paths = S3Client.uploadToCloud(images, item.id, "found")

            with conn.cursor() as cur:
                cur.execute(insert_images(TableImagesType.FOUND, image_paths, item.id))
        conn.commit()
                
        return {"message": "Data inserted successfully"}


    except Exception as e: 
        conn.rollback()
        error_message = f"An error occurred: {e}"
        print(error_message)
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=error_message)


# show all found item names 
@router.get("/all")
async def get_all_found_item_names() -> List[Dict[str, Any]]:
    try:   
        with conn.cursor() as cur: 
            cur.execute("SELECT id,item_name FROM found ORDER BY created_at DESC")
            rows = cur.fetchall()
            
            cur.execute("SELECT item_id, image_url from found_images")
            images = cur.fetchall()
            image_dict = get_image_dict(images)
                
            rows = list(map(lambda x: {"id": x[0], "name": x[1], "images": image_dict.get(x[0], [])}, rows))
            return rows        
       
    except Exception as e: 
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="failed to fetch items")
         

# show found item with images 
@router.get("/item/{id}")
def show_found_items(id: int) -> LfResponse:
    try:   
        with conn.cursor() as cur: 
            print('hello')
            cur.execute(get_particular_item(TableType.FOUND, id))
            found_item = cur.fetchall()
            
            if found_item == []:
                raise HTTPException(status_code=404, detail="Item not found")
            found_item = found_item[0]
            cur.execute(get_all_image_uris(TableType.FOUND, id))
            found_images = cur.fetchall()
            image_urls = list(map(lambda x: x[0], found_images))
            res = LfResponse.from_row(found_item, image_urls)
            return res
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch items: {e}")


# delete a found item 
@router.delete( "/delete_item" )
def delete_found_item( request: Request, item_id: int = Form(...)) -> Dict[str, str]: 
    user_id = get_user_id(request)
    try: 
        authorize_edit_delete("found", item_id, user_id, conn)
    except Exception as e: 
        raise HTTPException( status_code=500, detail= f"Error: {e}" )
    
    try: 
        with conn.cursor() as cur: 
            query = f"DELETE from found WHERE found.id = {item_id}"
            cur.execute( query )        
        S3Client.deleteFromCloud( item_id, "found" )
        conn.commit()
        return {"message": "Item deleted successfully!"}
               
    except Exception as e: 
        conn.rollback()
        raise HTTPException(status_code=500, detail="Failed to fetch items")


# Update a found item    
@router.put( "/edit_item" )
def edit_selected_item( request: Request, item_id: int = Form(...),  form_data:str = Form(...) ) -> Dict[str, str]:
    # checking authorization
    user_id = get_user_id(request)
    try: 
        authorize_edit_delete("found", item_id, user_id, conn)
    except Exception as e: 
        raise HTTPException( status_code=500, detail= f"Error: {e}" )
    
    
    # updating 
    try: 
        form_data_dict = json.loads(form_data)

        with conn.cursor() as cur:
            cur.execute( update_in_table(TableType.FOUND, item_id, form_data_dict ) )
            row = cur.fetchone()
            item = LfItem.from_row(row)
        conn.commit()
            
        return {"message": "item updated"}
    except Exception as e: 
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Error: {e}")          

@router.get("/search") 
def search(query : str, max_results: int = 100) -> List[Dict[str, Any]]:
    try: 
        with conn.cursor() as cur: 
            cur.execute( search_items(TableType.FOUND, query, max_results ) )
            res = cur.fetchall()
            if len(res) == 0:
                return []
            cur.execute(get_some_image_uris(TableImagesType.FOUND, [x[0] for x in res]))
            images = cur.fetchall()
            
            image_dict = get_image_dict(images)
            res = list( map( lambda x: {"id": x[0], "name": x[1], "images": image_dict.get(x[0], [])}, res ) )
    
            
        return res
    except Exception as e: 
        raise HTTPException(status_code=500, detail=f"Error: {e}")
