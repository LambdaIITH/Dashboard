import os, shutil
import json
from fastapi import APIRouter, HTTPException, status, UploadFile, File, Form
from typing import Dict, Any, List
from utils import *
from models import LfResponse
from queries.found import *

router = APIRouter(prefix="/found", tags=["found"])

# add found item 
@router.post("/add_item")
async def add_item( form_data: str = Form(...),
                    user_id: str =Form(...),
                    images: List[UploadFile] = File(default = None)
                    ):
    
    try:
        form_data_dict = json.loads(form_data)
       
        with conn.cursor() as cur:
            cur.execute( insert_in_found_table( form_data_dict, user_id ) )
            item_id = cur.fetchone()[0]
            conn.commit()
        
        if images is not None:
            image_paths = S3Client.uploadToCloud(images, item_id, "found")

            with conn.cursor() as cur:
                cur.execute(insert_found_images(image_paths, item_id))
                conn.commit()
                
        print("Data inserted successfully")
        return {"message": "Data inserted successfully"}


    except Exception as e: 
        conn.rollback()
        error_message = f"An error occurred: {e}"
        print(error_message)
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=error_message)


# show all found item names 
@router.get("/all")
async def get_all_found_item_names():
    try:   
        with conn.cursor() as cur: 
            cur.execute("SELECT id,item_name FROM found ORDER BY created_at DESC")
            rows = cur.fetchall()
            rows =list( map(lambda x: {"id" : x[0], "name" : x[1]},rows))
            
            print(rows) 
            
            return rows        
       
    except Exception as e: 
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="failed to fetch items")
         

# show found item with images 
@router.get("/item/{id}")
def show_found_items(id: int):
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
        print(e)
        raise HTTPException(status_code=500, detail="Failed to fetch items")


# delete a found item 
@router.delete( "/delete_item" )
def delete_found_item( item_id: str = Form(...) ): 
        
    try: 
        with conn.cursor() as cur: 
            query = f"DELETE from found WHERE found.id = {item_id}"
            cur.execute( query )
            conn.commit() 
        
            S3Client.deleteFromCloud( item_id, "found" )
            
        return {"message": "Item deleted successfully!"}
               
    except Exception as e: 
        raise HTTPException(status_code=500, detail="Failed to fetch items")


# Update a found item    
@router.put( "/edit_item" )
def edit_selected_item( item_id: str = Form(...), user_id: str = Form(...), form_data:str = Form(...),images: List[UploadFile] = File(default = None) ):
    # checking authorization
    try: 
        with conn.cursor() as cur: 
            cur.execute( f"SELECT found.user_id FROM found WHERE found.id = {item_id}" )
            authorized_id = cur.fetchone()[0] 
            conn.commit()
        
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
            S3Client.deleteFromCloud( item_id, "found" )
            cur.execute(delete_an_item_images(item_id))
            if images is not None:
                image_paths = S3Client.uploadToCloud(images, item_id, "found")
                cur.execute(insert_found_images(image_paths, item_id))
                
            conn.commit()
    
            
        return {"message": "item updated"}
    except Exception as e: 
        raise HTTPException(status_code=500, detail=f"Error: {e}")          

