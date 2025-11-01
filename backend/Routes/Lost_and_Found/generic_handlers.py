"""
Generic route handlers for Lost and Found items.
This module provides reusable handler functions that work for both 'lost' and 'found' endpoints.
"""

import json
from fastapi import HTTPException, Request, status, UploadFile, File, Form
from typing import Dict, Any, List, Callable
from Routes.Auth.cookie import get_user_id
from utils import conn, S3Client
from models import LfItem, LfResponse
from .funcs import get_image_dict, authorize_edit_delete

# Whitelist of allowed table names to prevent SQL injection
ALLOWED_TABLES = {'lost', 'found'}
ALLOWED_IMAGES_TABLES = {'lost_images', 'found_images'}


def _validate_table_name(table_name: str, allowed_tables: set) -> None:
    """
    Validate that a table name is in the allowed list.
    
    Args:
        table_name: Name of the table to validate
        allowed_tables: Set of allowed table names
        
    Raises:
        HTTPException: If table name is not in allowed list
    """
    if table_name not in allowed_tables:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid table name: {table_name}"
        )


async def add_item_handler(
    request: Request,
    form_data: str,
    images: List[UploadFile],
    table_name: str,
    insert_fn: Callable,
    insert_images_fn: Callable
) -> Dict[str, Any]:
    """
    Generic handler for adding a lost or found item.
    
    Args:
        request: FastAPI request object
        form_data: JSON string containing item data
        images: List of uploaded images
        table_name: Name of the table ('lost' or 'found')
        insert_fn: Function to insert item into table
        insert_images_fn: Function to insert images
    
    Returns:
        Success message dictionary
    """
    _validate_table_name(table_name, ALLOWED_TABLES)
    try:
        form_data_dict = json.loads(form_data)
        user_id = get_user_id(request)
        with conn.cursor() as cur:
            cur.execute(insert_fn(form_data_dict, user_id))
            item = LfItem.from_row(cur.fetchone())
        
        if images is not None:
            image_paths = S3Client.uploadToCloud(images, item.id, table_name)
            with conn.cursor() as cur:
                cur.execute(insert_images_fn(image_paths, item.id))
        
        conn.commit()
        return {"message": "Data inserted successfully"}
    
    except Exception as e:
        conn.rollback()
        error_message = f"An error occurred: {e}"
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail=error_message
        )


async def get_all_items_handler(
    table_name: str,
    images_table_name: str
) -> List[Dict[str, Any]]:
    """
    Generic handler for getting all lost or found items.
    
    Args:
        table_name: Name of the main table ('lost' or 'found')
        images_table_name: Name of the images table ('lost_images' or 'found_images')
    
    Returns:
        List of items with their images
    """
    _validate_table_name(table_name, ALLOWED_TABLES)
    _validate_table_name(images_table_name, ALLOWED_IMAGES_TABLES)
    try:
        with conn.cursor() as cur:
            cur.execute(
                f"SELECT id, item_name FROM {table_name} ORDER BY created_at DESC"
            )
            rows = cur.fetchall()
            
            cur.execute(f"SELECT item_id, image_url from {images_table_name}")
            images = cur.fetchall()
            
            image_dict = get_image_dict(images)
            rows = list(map(
                lambda x: {
                    "id": x[0], 
                    "name": x[1], 
                    "images": image_dict.get(x[0], [])
                }, 
                rows
            ))
            return rows
    
    except Exception as e:
        conn.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
            detail="failed to fetch items"
        )


def get_item_by_id_handler(
    item_id: int,
    get_item_fn: Callable,
    get_images_fn: Callable
) -> LfResponse:
    """
    Generic handler for getting a specific lost or found item.
    
    Args:
        item_id: ID of the item to retrieve
        get_item_fn: Function to get the item details
        get_images_fn: Function to get image URLs
    
    Returns:
        Item details with images
    """
    try:
        with conn.cursor() as cur:
            cur.execute(get_item_fn(item_id))
            item = cur.fetchall()
            
            if item == []:
                raise HTTPException(status_code=404, detail="Item not found")
            
            item = item[0]
            cur.execute(get_images_fn(item_id))
            images = cur.fetchall()
            image_urls = list(map(lambda x: x[0], images))
            res = LfResponse.from_row(item, image_urls)
            return res
    
    except Exception as e:
        conn.rollback()
        raise HTTPException(
            status_code=500, 
            detail=f"Failed to fetch items: {e}"
        )


def delete_item_handler(
    request: Request,
    item_id: int,
    table_name: str
) -> Dict[str, str]:
    """
    Generic handler for deleting a lost or found item.
    
    Args:
        request: FastAPI request object
        item_id: ID of the item to delete
        table_name: Name of the table ('lost' or 'found')
    
    Returns:
        Success message dictionary
    """
    _validate_table_name(table_name, ALLOWED_TABLES)
    user_id = get_user_id(request)
    
    try:
        authorize_edit_delete(table_name, item_id, user_id, conn)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {e}")
    
    try:
        with conn.cursor() as cur:
            query = f"DELETE from {table_name} WHERE {table_name}.id = {item_id}"
            cur.execute(query)
        
        S3Client.deleteFromCloud(item_id, table_name)
        conn.commit()
        
        return {"message": "Item deleted successfully!"}
    
    except Exception as e:
        conn.rollback()
        raise HTTPException(
            status_code=500, 
            detail="Failed to fetch items"
        )


def edit_item_handler(
    request: Request,
    item_id: int,
    form_data: str,
    table_name: str,
    update_fn: Callable
) -> Dict[str, str]:
    """
    Generic handler for editing a lost or found item.
    
    Args:
        request: FastAPI request object
        item_id: ID of the item to edit
        form_data: JSON string containing updated data
        table_name: Name of the table ('lost' or 'found')
        update_fn: Function to update the item
    
    Returns:
        Success message dictionary
    """
    _validate_table_name(table_name, ALLOWED_TABLES)
    user_id = get_user_id(request)
    
    try:
        authorize_edit_delete(table_name, item_id, user_id, conn)
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Error: {e}")
    
    try:
        form_data_dict = json.loads(form_data)
        
        with conn.cursor() as cur:
            cur.execute(update_fn(item_id, form_data_dict))
            row = cur.fetchone()
            item = LfItem.from_row(row)
            
        conn.commit()
        return {"message": "item updated"}
    
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Error: {e}")


def search_items_handler(
    query: str,
    max_results: int,
    search_fn: Callable,
    get_images_fn: Callable
) -> List[Dict[str, Any]]:
    """
    Generic handler for searching lost or found items.
    
    Args:
        query: Search query string
        max_results: Maximum number of results to return
        search_fn: Function to search items
        get_images_fn: Function to get images for multiple items
    
    Returns:
        List of matching items with their images
    """
    try:
        with conn.cursor() as cur:
            cur.execute(search_fn(query, max_results))
            res = cur.fetchall()
            
            if len(res) == 0:
                return []
            
            cur.execute(get_images_fn([x[0] for x in res]))
            images = cur.fetchall()
            
            image_dict = get_image_dict(images)
            res = list(map(
                lambda x: {
                    "id": x[0], 
                    "name": x[1], 
                    "images": image_dict.get(x[0], [])
                }, 
                res
            ))
        
        return res
    
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Error: {e}")
