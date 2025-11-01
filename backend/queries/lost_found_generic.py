"""
Generic query builder for Lost and Found items.
This module provides reusable query functions that work for both 'lost' and 'found' tables.
"""

from pypika import Query, Table, Order
from typing import Dict, Any

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
        ValueError: If table name is not in allowed list
    """
    if table_name not in allowed_tables:
        raise ValueError(f"Invalid table name: {table_name}")


def insert_in_table(table_name: str, form_data: Dict[str, Any], user_id: int) -> str:
    """
    Generic insert query for lost/found items.
    
    Args:
        table_name: Name of the table ('lost' or 'found')
        form_data: Dictionary containing item_name and item_description
        user_id: ID of the user creating the item
    
    Returns:
        SQL query string with RETURNING clause
    """
    _validate_table_name(table_name, ALLOWED_TABLES)
    table = Table(table_name)
    query = Query.into(table).columns('item_name', 'item_description', 'user_id').insert(
        form_data['item_name'], form_data['item_description'], user_id
    )
    
    sql_query = query.get_sql()
    sql_query += " RETURNING *"
    
    return sql_query


def insert_images(table_name: str, image_paths: list, post_id: int) -> str:
    """
    Generic insert query for item images.
    
    Args:
        table_name: Name of the images table ('lost_images' or 'found_images')
        image_paths: List of image URLs to insert
        post_id: ID of the item
    
    Returns:
        SQL query string
    """
    _validate_table_name(table_name, ALLOWED_IMAGES_TABLES)
    images_table = Table(table_name)
    query = Query.into(images_table).columns('image_url', 'item_id')

    for image_path in image_paths:
        query = query.insert(image_path, post_id)
    
    return query.get_sql()


def get_all_items(table_name: str, images_table_name: str) -> str:
    """
    _validate_table_name(table_name, ALLOWED_TABLES)
    _validate_table_name(images_table_name, ALLOWED_IMAGES_TABLES)
        Generic query to get all items with their images.
    
    Args:
        table_name: Name of the main table ('lost' or 'found')
        images_table_name: Name of the images table ('lost_images' or 'found_images')
    
    Returns:
        SQL query string
    """
    query = f"""
            SELECT
                f.id,
                f.item_name,
                f.item_description,
                f.user_id,
                COALESCE(json_agg(fi.image_url) FILTER (WHERE fi.image_url IS NOT NULL), '[]') AS images,
                f.created_at
            FROM
                {table_name} f
            LEFT JOIN
                {images_table_name} fi ON f.id = fi.item_id
            GROUP BY
                f.id, f.item_name, f.item_description, f.user_id
            ORDER BY
                f.created_at DESC;
            """
            
    return query


def update_in_table(table_name: str, item_id: int, form_data: Dict[str, Any]) -> str:
    """
    _validate_table_name(table_name, ALLOWED_TABLES)
        Generic update query for lost/found items.
    
    Args:
        table_name: Name of the table ('lost' or 'found')
        item_id: ID of the item to update
        form_data: Dictionary containing fields to update
    
    Returns:
        SQL query string with RETURNING clause
    """
    table = Table(table_name)
    query = Query.update(table)

    for key, value in form_data.items():
        if key == 'item_name' or key == 'item_description':
            query = query.set(table[key], value)

    query = query.where(table['id'] == item_id).get_sql()
    query += " RETURNING *"
    return query


def get_particular_item(table_name: str, item_id: int) -> str:
    """
    _validate_table_name(table_name, ALLOWED_TABLES)
        Generic query to get a specific item with user details.
    
    Args:
        table_name: Name of the table ('lost' or 'found')
        item_id: ID of the item
    
    Returns:
        SQL query string
    """
    table = Table(table_name)
    users = Table("users")
    query = (Query.from_(table)
             .join(users)
             .on(users['id'] == table['user_id'])
             .select('*')
             .where(table['id'] == item_id))
    return str(query)


def delete_an_item_images(images_table_name: str, item_id: int) -> str:
    """
    _validate_table_name(images_table_name, ALLOWED_IMAGES_TABLES)
        Generic query to delete all images for an item.
    
    Args:
        images_table_name: Name of the images table ('lost_images' or 'found_images')
        item_id: ID of the item
    
    Returns:
        SQL query string
    """
    images_table = Table(images_table_name)
    query = Query.from_(images_table).delete().where(images_table['item_id'] == item_id)
    return str(query)


def get_all_image_uris(images_table_name: str, item_id: int) -> str:
    """
    _validate_table_name(images_table_name, ALLOWED_IMAGES_TABLES)
        Generic query to get all image URLs for an item.
    
    Args:
        images_table_name: Name of the images table ('lost_images' or 'found_images')
        item_id: ID of the item
    
    Returns:
        SQL query string
    """
    images_table = Table(images_table_name)
    query = Query.from_(images_table).select('image_url').where(images_table['item_id'] == item_id)
    return str(query)


def search_items(table_name: str, search_query: str, max_results: int = 10) -> str:
    """
    _validate_table_name(table_name, ALLOWED_TABLES)
        Generic search query for lost/found items.
    
    Args:
        table_name: Name of the table ('lost' or 'found')
        search_query: Search string to match against item_name and item_description
        max_results: Maximum number of results to return
    
    Returns:
        SQL query string
    """
    table = Table(table_name)
    query = (Query.from_(table)
    .select('*')
    .where(table['item_name'].ilike(f'%{search_query}%') | table['item_description'].ilike(f'%{search_query}%'))
    .orderby(table['created_at'], order=Order.desc)
    .limit(max_results)
    )
    return str(query)


def get_some_image_uris(images_table_name: str, item_ids: list) -> str:
    """
    _validate_table_name(images_table_name, ALLOWED_IMAGES_TABLES)
        Generic query to get image URLs for multiple items.
    
    Args:
        images_table_name: Name of the images table ('lost_images' or 'found_images')
        item_ids: List of item IDs
    
    Returns:
        SQL query string
    """
    images_table = Table(images_table_name)
    query = Query.from_(images_table).select(
        images_table['item_id'], 
        images_table['image_url']
    ).where(images_table['item_id'].isin(item_ids))
    return str(query)
