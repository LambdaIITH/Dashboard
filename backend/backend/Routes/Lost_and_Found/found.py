import os, shutil
import json
from fastapi import APIRouter, HTTPException, Request, status, UploadFile, File, Form
from typing import Dict, Any, List
from Routes.Auth.cookie import get_user_id
from utils import *
from models import LfItem, LfResponse
from queries.found import *
from utils import S3Client, ESClient


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
            cur.execute( insert_in_found_table( form_data_dict, user_id ) )
            item = LfItem.from_row(cur.fetchone())
        
        # update in elasticsearch
        ESClient.add_item(item.id, item.item_name, item.item_description, "found", item.created_at)
        
        if images is not None:
            image_paths = S3Client.uploadToCloud(images, item.id, "found")

            with conn.cursor() as cur:
                cur.execute(insert_found_images(image_paths, item.id))
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
            rows =list( map(lambda x: {"id" : x[0], "name" : x[1]},rows))
            return rows        
       
    except Exception as e: 
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="failed to fetch items")
         

# show found item with images 
@router.get("/item/{id}")
def show_found_items(id: int) -> LfResponse:
    try:   
        with conn.cursor() as cur: 
            cur.execute(get_particular_found_item(id))
            found_item = cur.fetchall()[0]
            cur.execute(get_all_image_uris(id))
            found_images = cur.fetchall()
            image_urls = list(map(lambda x: x[0], found_images))
            res = LfResponse.from_row(found_item, image_urls)
            return res
        
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch items")


# delete a found item 
@router.delete( "/delete_item" )
def delete_found_item( request: Request, item_id: int = Form(...)) -> Dict[str, str]: 
    user_id = get_user_id(request)
    try: 
        with conn.cursor() as cur: 
            cur.execute( f"SELECT found.user_id FROM found WHERE found.id = {item_id}" )
            authorized_id = cur.fetchone()[0] 
        
        authorized_id = str(authorized_id) 
        if authorized_id != user_id: 
            raise HTTPException( status_code=status.HTTP_401_UNAUTHORIZED , detail="User not Authorized" )
    except Exception as e: 
        raise HTTPException( status_code=500, detail= f"Error: {e}" )
    
    try: 
        with conn.cursor() as cur: 
            query = f"DELETE from found WHERE found.id = {item_id}"
            cur.execute( query )        
        S3Client.deleteFromCloud( item_id, "found" )
        ESClient.delete_item( item_id, "found" )
        conn.commit()
        return {"message": "Item deleted successfully!"}
               
    except Exception as e: 
        conn.rollback()
        raise HTTPException(status_code=500, detail="Failed to fetch items")


# Update a found item    
@router.put( "/edit_item" )
def edit_selected_item( request: Request, item_id: int = Form(...),  form_data:str = Form(...),images: List[UploadFile]  = File(default = None) ) -> Dict[str, str]:
    # checking authorization
    user_id = get_user_id(request)
    try: 
        with conn.cursor() as cur: 
            cur.execute( f"SELECT found.user_id FROM found WHERE found.id = {item_id}" )
            authorized_id = cur.fetchone()[0] 
        
        authorized_id = str(authorized_id) 
        if authorized_id != user_id: 
            raise HTTPException( status_code=status.HTTP_401_UNAUTHORIZED , detail="User not Authorized" )
    except Exception as e: 
        raise HTTPException( status_code=500, detail= f"Error: {e}" )
    
    
    # updating 
    try: 
        form_data_dict = json.loads(form_data)

        with conn.cursor() as cur:
            cur.execute( update_in_found_table( item_id, form_data_dict ) )
            row = cur.fetchone()
            item = LfItem.from_row(row)
            
        
            ESClient.delete_item(item_id, "found")
            ESClient.add_item(item_id, item.item_name, item.item_description, "found", item.created_at)
            
            S3Client.deleteFromCloud( item_id, "found")
            cur.execute(delete_an_item_images(item_id))
            if images is not None:
                image_paths = S3Client.uploadToCloud(images, item_id, "found")
                cur.execute(insert_found_images(image_paths, item_id))
                
            conn.commit()
    
            
        return {"message": "item updated"}
    except Exception as e: 
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Error: {e}")          

@router.get("/search") 
def search(query : str, max_results: int = 10) -> List[Dict[str, Any]]:
    try: 
        response = ESClient.search_items(query, max_results, "found")
        res = list(map(lambda x: {"id": x["_source"]["id"], "name": x["_source"]["name"]}, response))
        return res
    except Exception as e: 
        raise HTTPException(status_code=500, detail=f"Error: {e}")
