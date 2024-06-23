import os, shutil
import json
from fastapi import APIRouter, HTTPException, status, UploadFile, File, Form
from typing import Dict, Any, List
from utils import *
from queries.lost import *
from models import LfItem, LfResponse

router = APIRouter(prefix="/lost", tags=["lost"])

# add lost item 
@router.post("/add_item")
async def add_item( form_data: str = Form(...),
                    user_id: int =Form(...),
                    images: List[UploadFile] | None = File(default = None)
                    ):
    
    try:
        form_data_dict = json.loads(form_data)
       
        with conn.cursor() as cur:
            cur.execute( insert_in_lost_table( form_data_dict, user_id ) )
            item = LfItem.from_row(cur.fetchone())
            conn.commit()
        
        # update in elasticsearch
        ESClient.add_item(item.id, item.item_name, item.item_description, "lost", item.created_at)
        
        print( images ) 
        if images is not None:
            image_paths = S3Client.uploadToCloud(images, item.id, "lost")

            with conn.cursor() as cur:
                cur.execute(insert_lost_images(image_paths, item.id))
                conn.commit()
                
        print("Data inserted successfully")
        return {"message": "Data inserted successfully"}


    except Exception as e: 
        conn.rollback()
        error_message = f"An error occurred: {e}"
        print(error_message)
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=error_message)


# show all lost item names  sorted by created_at
@router.get("/all")
async def get_all_lost_item_names():
    try:   
        with conn.cursor() as cur: 
            cur.execute("SELECT id, item_name FROM lost ORDER BY created_at DESC")
            rows = cur.fetchall()
            rows =list( map(lambda x: {"id" : x[0], "name" : x[1]},rows))
            print(rows) 
            
            return rows        
       
    except Exception as e: 
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="failed to fetch items")
         

# show some lost items with images 
@router.get("/item/{id}")
def show_lost_items(id: str):
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
        print(e)
        raise HTTPException(status_code=500, detail="Failed to fetch items")


# delete a lost item 
@router.delete( "/delete_item" )
def delete_lost_item( item_id: int = Form(...) , user_id: int = Form(...)):   
    try: 
        with conn.cursor() as cur: 
            cur.execute( f"SELECT lost.user_id FROM lost WHERE lost.id = {item_id}" )
            authorized_id = cur.fetchone()[0] 
            conn.commit()
        
        if authorized_id != user_id: 
            raise HTTPException( status_code=status.HTTP_401_UNAUTHORIZED , detail="User not Authorized" )
    except Exception as e: 
        raise HTTPException( status_code=500, detail= f"Error: {e}" )
        
    try: 
        with conn.cursor() as cur: 
            query = f"DELETE from lost WHERE lost.id = {item_id}"
            cur.execute( query )
            conn.commit() 
        
        S3Client.deleteFromCloud( item_id, "lost" )
        ESClient.delete_item( item_id, "lost" ) 
        return {"message": "Item deleted successfully!"}
               
    except Exception as e: 
        raise HTTPException(status_code=500, detail="Failed to fetch items")


# Update a lost item    
@router.put( "/edit_item" )
def edit_selected_item( item_id: int = Form(...), user_id: int = Form(...), form_data:str = Form(...),images: List[UploadFile] | None = File(default = None) ):
    # checking authorization
    try: 
        with conn.cursor() as cur: 
            cur.execute( f"SELECT lost.user_id FROM lost WHERE lost.id = {item_id}" )
            authorized_id = cur.fetchone()[0] 
            conn.commit()
        
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
            
        
            ESClient.delete_item(item_id, "lost")
            ESClient.add_item(item_id, item.item_name, item.item_description, "lost", item.created_at)
            
            S3Client.deleteFromCloud( item_id, "lost" )
            cur.execute(delete_an_item_images(item_id))
            if images is not None:
                image_paths = S3Client.uploadToCloud(images, item_id, "lost")
                cur.execute(insert_lost_images(image_paths, item_id))
            conn.commit()
        
            
        return {"message": "item updated"}
    except Exception as e: 
        raise HTTPException(status_code=500, detail=f"Error: {e}")          


# search lost items
@router.get("/search")
def search(query : str, max_results: int = 10):
    try: 
        response = ESClient.search_items(query, max_results, "lost")
        res = list(map(lambda x: {"id": x["_source"]["id"], "name": x["_source"]["name"]}, response))
        return res
    except Exception as e: 
        raise HTTPException(status_code=500, detail=f"Error: {e}")