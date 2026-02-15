"""
Lost items query module.
This module provides query functions for the 'lost' table by wrapping the generic functions.
"""

from typing import Dict, Any
from .lost_found_generic import (
    insert_in_table as generic_insert_in_table,
    insert_images as generic_insert_images,
    get_all_items as generic_get_all_items,
    update_in_table as generic_update_in_table,
    get_particular_item as generic_get_particular_item,
    delete_an_item_images as generic_delete_an_item_images,
    get_all_image_uris as generic_get_all_image_uris,
    search_items as generic_search_items,
    get_some_image_uris as generic_get_some_image_uris
)


def insert_in_lost_table(form_data: Dict[str, Any], user_id: int) -> str:
    """Insert a new lost item."""
    return generic_insert_in_table('lost', form_data, user_id)


def insert_lost_images(image_paths: list, post_id: int) -> str:
    """Insert images for a lost item."""
    return generic_insert_images('lost_images', image_paths, post_id)


def get_all_lost_items() -> str:
    """Get all lost items with their images."""
    return generic_get_all_items('lost', 'lost_images')


def update_in_lost_table(item_id: int, form_data: Dict[str, Any]) -> str:
    """Update a lost item."""
    return generic_update_in_table('lost', item_id, form_data)


def get_particular_lost_item(item_id: int) -> str:
    """Get a specific lost item with user details."""
    return generic_get_particular_item('lost', item_id)


def delete_an_item_images(item_id: int) -> str:
    """Delete all images for a lost item."""
    return generic_delete_an_item_images('lost_images', item_id)


def get_all_image_uris(item_id: int) -> str:
    """Get all image URLs for a lost item."""
    return generic_get_all_image_uris('lost_images', item_id)


def search_lost_items(search_query: str, max_results: int = 10) -> str:
    """Search for lost items."""
    return generic_search_items('lost', search_query, max_results)


def get_some_image_uris(item_ids: list) -> str:
    """Get image URLs for multiple lost items."""
    return generic_get_some_image_uris('lost_images', item_ids)