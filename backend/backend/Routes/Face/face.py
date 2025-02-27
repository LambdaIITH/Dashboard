import os, shutil
import json
from fastapi import APIRouter, HTTPException, Request, status, UploadFile, File, Form
from typing import Dict, Any, List, Tuple
from Routes.Auth.cookie import get_user_id
from utils import *
from queries.face import *
from queries.user import *
from utils import S3Client

router = APIRouter(prefix="/face", tags=["face"])

# add face item 
@router.post("/add_face")
async def add_item( request: Request,
                    images: List[UploadFile]  = File(default = None)
                    )  -> Dict[str, Any]:
    
    try:
        if images is not None:
            print(f"Number of images received: {len(images)}")
            for image in images:
                print(f"Image filename: {image.filename}, Content Type: {image.content_type}")

        user_id = get_user_id(request)

        if images is not None:
            image_paths = S3Client.uploadToCloud(images, user_id, "face")
        with conn.cursor() as cur:
            cur.execute(get_user(user_id))
            user = cur.fetchone()
            cur.execute( insert_in_face_table( user[2], image_paths, user_id ) )
        
        # update in elasticsearch
        conn.commit()
                
        return {"message": "Data inserted successfully"}


    except Exception as e: 
        conn.rollback()
        error_message = f"An error occurred: {e}"
        print(error_message)
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=error_message)