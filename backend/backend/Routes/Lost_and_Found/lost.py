import os, shutil
import json
from fastapi import APIRouter, HTTPException, Request, status, UploadFile, File, Form
from typing import Dict, Any, List
from Routes.Auth.cookie import get_user_id
from utils import *
from queries.lost import *
from models import LfItem, LfResponse
from utils import S3Client
router = APIRouter(prefix="/lost", tags=["lost"])

# add lost item 
@router.post("/add_item")
async def add_item( request: Request,
                   form_data: str = Form(...), 
                    images: List[UploadFile] = File(default = None),
                    
                    ) -> Dict[str, Any]:
    
    try:
        form_data_dict = json.loads(form_data)
        user_id = get_user_id(request)
        with conn.cursor() as cur:
            cur.execute( insert_in_lost_table( form_data_dict, user_id ) )
            item = LfItem.from_row(cur.fetchone())
        
        # update in elasticsearch
        
        if images is not None:
            image_paths = S3Client.uploadToCloud(images, item.id, "lost")

            with conn.cursor() as cur:
                cur.execute(insert_lost_images(image_paths, item.id))
        conn.commit()
        return {"message": "Data inserted successfully"}


    except Exception as e: 
        conn.rollback()
        error_message = f"An error occurred: {e}"
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=error_message)


# show all lost item names  sorted by created_at
@router.get("/all")
async def get_all_lost_item_names() -> List[Dict[str, Any]]:
    try:   
        with conn.cursor() as cur: 
            cur.execute("SELECT id, item_name FROM lost ORDER BY created_at DESC")
            rows = cur.fetchall()
            cur.execute("SELECT image_url, item_id from lost_images")
            images = cur.fetchall()
            
            image_dict = {}
            for image in images:
                if image[1] not in image_dict:
                    image_dict[image[1]] = []
                image_dict[image[1]].append(image[0])
            
            rows = list(map(lambda x: {"id": x[0], "name": x[1], "images": image_dict.get(x[0], [])}, rows))
                
            return rows        
       
    except Exception as e: 
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="failed to fetch items")
         

# show some lost items with images 
@router.get("/item/{id}")
def show_lost_items(id: str) -> LfResponse:
    try:   
        with conn.cursor() as cur: 
            cur.execute(get_particular_lost_item(id))
            lost_item = cur.fetchall()[0]
            cur.execute(get_all_image_uris(id))
            lost_images = cur.fetchall()
            image_urls = list(map(lambda x: x[0], lost_images))
            res = LfResponse.from_row(lost_item, image_urls)
            return res

        
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch items")


# delete a lost item 
@router.delete( "/delete_item" ) 
def delete_lost_item(request: Request, item_id: int = Form(...) ) -> Dict[str, str]:   
    user_id = get_user_id(request)
    try: 
        
        with conn.cursor() as cur: 
            cur.execute( f"SELECT lost.user_id FROM lost WHERE lost.id = {item_id}" )
            authorized_id = cur.fetchone()[0] 
        
        if authorized_id != user_id: 
            raise HTTPException( status_code=status.HTTP_401_UNAUTHORIZED , detail="User not Authorized" )
    except Exception as e: 
        raise HTTPException( status_code=500, detail= f"Error: {e}" )
        
    try: 
        with conn.cursor() as cur: 
            query = f"DELETE from lost WHERE lost.id = {item_id}"
            cur.execute( query )
        
        S3Client.deleteFromCloud( item_id, "lost" )
        conn.commit() 
        
        return {"message": "Item deleted successfully!"}
               
    except Exception as e: 
        raise HTTPException(status_code=500, detail="Failed to fetch items")


# Update a lost item    
@router.put( "/edit_item" )
def edit_selected_item(request: Request, item_id: int = Form(...),  form_data:str = Form(...),images: List[UploadFile]  = File(default = None) ) -> Dict[str, str]:
    # checking authorization
    user_id = get_user_id(request)
    try: 
        with conn.cursor() as cur: 
            cur.execute( f"SELECT lost.user_id FROM lost WHERE lost.id = {item_id}" )
            authorized_id = cur.fetchone()[0] 
        
        if authorized_id != user_id: 
            raise HTTPException( status_code=status.HTTP_401_UNAUTHORIZED , detail="User not Authorized" )
    except Exception as e: 
        raise HTTPException( status_code=500, detail= f"Error: {e}" )
    
    
    # updating 
    try: 
        form_data_dict = json.loads(form_data)

        with conn.cursor() as cur:
            cur.execute( update_in_lost_table( item_id, form_data_dict ) )
            row = cur.fetchone()
            item = LfItem.from_row(row)
            
        
            S3Client.deleteFromCloud( item_id, "lost" )
            cur.execute(delete_an_item_images(item_id))
            if images is not None:
                image_paths = S3Client.uploadToCloud(images, item_id, "lost")
                cur.execute(insert_lost_images(image_paths, item_id))
            conn.commit()
        
            
        return {"message": "item updated"}
    except Exception as e: 
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Error: {e}")          


# search lost items
@router.get("/search")
def search(query : str, max_results: int = 100) -> List[Dict[str, Any]] :
    try: 
        with conn.cursor() as cur: 
            cur.execute( search_lost_items( query, max_results ) )
            res = cur.fetchall()
            res = list( map( lambda x: {"id": x[0], "name": x[1]}, res ) )
        return res
    except Exception as e: 
        raise HTTPException(status_code=500, detail=f"Error: {e}")
