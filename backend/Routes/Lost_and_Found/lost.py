from fastapi import APIRouter, Request, UploadFile, File, Form
from typing import Dict, Any, List
from queries.lost import *
from models import LfResponse
from .generic_handlers import (
    add_item_handler,
    get_all_items_handler,
    get_item_by_id_handler,
    delete_item_handler,
    edit_item_handler,
    search_items_handler
)

router = APIRouter(prefix="/lost", tags=["lost"])


# add lost item
@router.post("/add_item")
async def add_item(
    request: Request,
    form_data: str = Form(...),
    images: List[UploadFile] = File(default=None),
) -> Dict[str, Any]:
    return await add_item_handler(
        request, 
        form_data, 
        images, 
        "lost", 
        insert_in_lost_table, 
        insert_lost_images
    )



# show all lost item names sorted by created_at
@router.get("/all")
async def get_all_lost_item_names() -> List[Dict[str, Any]]:
    return await get_all_items_handler("lost", "lost_images")


# show some lost items with images
@router.get("/item/{id}")
def show_lost_items(id: int) -> LfResponse:
    return get_item_by_id_handler(id, get_particular_lost_item, get_all_image_uris)


# delete a lost item
@router.delete("/delete_item")
def delete_lost_item(request: Request, item_id: int = Form(...)) -> Dict[str, str]:
    return delete_item_handler(request, item_id, "lost")


# Update a lost item
@router.put("/edit_item")
def edit_selected_item(
    request: Request, 
    item_id: int = Form(...), 
    form_data: str = Form(...)
) -> Dict[str, str]:
    return edit_item_handler(request, item_id, form_data, "lost", update_in_lost_table)


# search lost items
@router.get("/search")
def search(query: str, max_results: int = 100) -> List[Dict[str, Any]]:
    return search_items_handler(query, max_results, search_lost_items, get_some_image_uris)
