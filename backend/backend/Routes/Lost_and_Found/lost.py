import os, shutil
import json
from fastapi import APIRouter, HTTPException, status, UploadFile, File, Form
from typing import Dict, Any, List
from utils import conn
from queries.lost import insert_in_lost_table, insert_lost_images, get_all_lost_items, update_in_lost_table

router = APIRouter(prefix="/lost", tags=["lost"])

# add lost item 
@router.post("/add_item")
async def add_item( form_data: str = Form(...),
                    user_id: str =Form(...),
                    images: List[UploadFile] = File(default = None)
                    ):
    
    try:
        form_data_dict = json.loads(form_data)
       
        with conn.cursor() as cur:
            cur.execute( insert_in_lost_table( form_data_dict, user_id ) )
            item_id = cur.fetchone()[0]
            conn.commit()
        
        print( images ) 
        if images is not None:
            image_paths = []
            for image in images:
                file_location = f"uploads/lost/{item_id}/{image.filename}"
                os.makedirs(os.path.dirname(file_location), exist_ok=True)
                with open(file_location, "wb") as f:
                    f.write(image.file.read())
                image_paths.append(file_location)

            with conn.cursor() as cur:
                cur.execute(insert_lost_images(image_paths, item_id))
                conn.commit()
                
        print("Data inserted successfully")
        return {"message": "Data inserted successfully"}


    except Exception as e: 
        conn.rollback()
        error_message = f"An error occurred: {e}"
        print(error_message)
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=error_message)


# show all lost item names 
@router.get("/show_all_item_names")
async def get_all_lost_item_names():
    try:   
        with conn.cursor() as cur: 
            cur.execute("SELECT * FROM lost ORDER BY created_at DESC")
            rows = cur.fetchall() 
            
        return rows        
       
    except Exception as e: 
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="failed to fetch items")
         

# show all lost items with images 
@router.get("/show_all_items")
def show_lost_items():
    try:   
        with conn.cursor() as cur: 
            cur.execute(get_all_lost_items())
            lost_items = cur.fetchall() 

        return lost_items
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to fetch items")


# delete a lost item 
@router.delete( "/delete_item" )
def delete_lost_item( item_id: str = Form(...) ): 
        
    try: 
        with conn.cursor() as cur: 
            query = f"DELETE from lost WHERE lost.id = {item_id}"
            cur.execute( query )
            conn.commit() 
        
        dir_path = f"uploads/lost/{item_id}"      
        if os.path.exists(dir_path):
            shutil.rmtree(dir_path) 
            
        return {"message": "Item deleted successfully!"}
               
    except Exception as e: 
        raise HTTPException(status_code=500, detail="Failed to fetch items")


# Update a lost item    
@router.put( "/edit_item" )
def edit_selected_item( item_id: str = Form(...), user_id: str = Form(...), form_data:str = Form(...),images: List[UploadFile] = File(default = None) ):
    # checking authorization
    try: 
        with conn.cursor() as cur: 
            cur.execute( f"SELECT lost.user_id FROM lost WHERE lost.id = {item_id}" )
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
            cur.execute( update_in_lost_table( item_id, form_data_dict ) )
            conn.commit()
        
        
        dir_path = f"uploads/lost/{item_id}"      
        if os.path.exists(dir_path):
            with conn.cursor() as cur: 
                cur.execute( f"DELETE FROM lost_images WHERE lost_images.item_id = {item_id}" )
                conn.commit()
            shutil.rmtree(dir_path) 
            
        if images is not None:
            image_paths = []
            for image in images:
                file_location = f"uploads/lost/{item_id}/{image.filename}"
                os.makedirs(os.path.dirname(file_location), exist_ok=True)
                with open(file_location, "wb") as f:
                    f.write(image.file.read())
                image_paths.append(file_location)

            with conn.cursor() as cur:
                cur.execute(insert_lost_images(image_paths, item_id))
                conn.commit()
            
        return {"message": "item updated"}
    except Exception as e: 
        raise HTTPException(status_code=500, detail=f"Error: {e}")          



