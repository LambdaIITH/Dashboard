from fastapi import APIRouter, Request, UploadFile, File, Form
from typing import Dict, Any, List
from queries.found import *
from models import LfResponse
from .generic_handlers import (
    add_item_handler,
    get_all_items_handler,
    get_item_by_id_handler,
    delete_item_handler,
    edit_item_handler,
    search_items_handler
)

router = APIRouter(prefix="/found", tags=["found"])


# add found item
@router.post("/add_item")
async def add_item(
    request: Request,
    form_data: str = Form(...),
    images: List[UploadFile] = File(default=None)
) -> Dict[str, Any]:
    return await add_item_handler(
        request, 
        form_data, 
        images, 
        "found", 
        insert_in_found_table, 
        insert_found_images
    )


# show all found item names
@router.get("/all")
async def get_all_found_item_names() -> List[Dict[str, Any]]:
    return await get_all_items_handler("found", "found_images")


# show found item with images
@router.get("/item/{id}")
def show_found_items(id: int) -> LfResponse:
    return get_item_by_id_handler(id, get_particular_found_item, get_all_image_uris)


# delete a found item
@router.delete("/delete_item")
def delete_found_item(request: Request, item_id: int = Form(...)) -> Dict[str, str]:
    return delete_item_handler(request, item_id, "found")


# Update a found item
@router.put("/edit_item")
def edit_selected_item(
    request: Request, 
    item_id: int = Form(...), 
    form_data: str = Form(...)
) -> Dict[str, str]:
    return edit_item_handler(request, item_id, form_data, "found", update_in_found_table)


@router.get("/search")
def search(query: str, max_results: int = 100) -> List[Dict[str, Any]]:
    return search_items_handler(query, max_results, search_found_items, get_some_image_uris)
