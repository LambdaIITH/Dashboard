
from pypika import Query, Table, functions as fn
from typing import Dict, Any

found_table, found_images_table = Table('found'), Table('found_images')

def insert_in_found_table( form_data: Dict[str, Any], user_id: str ): 
    query = Query.into(found_table).columns('item_name', 'item_description', 'user_id').insert(
        form_data['item_name'], form_data['item_description'], user_id
    )
    
    sql_query = query.get_sql()
    sql_query += " RETURNING id"
    
    return sql_query


def insert_found_images( image_paths: list, post_id: int): 

    query = Query.into(found_images_table).columns('image_url', 'item_id')

    for image_path in image_paths:
        query = query.insert(image_path, post_id)
    
    return query.get_sql()


def get_all_found_items():
    query = """
            SELECT
                f.id,
                f.item_name,
                f.item_description,
                f.user_id,
                COALESCE(json_agg(fi.image_url) FILTER (WHERE fi.image_url IS NOT NULL), '[]') AS images,
                f.created_at
            FROM
                found f
            LEFT JOIN
                found_images fi ON f.id = fi.item_id
            GROUP BY
                f.id, f.item_name, f.item_description, f.user_id
            ORDER BY
                f.created_at DESC;
            """
            
    return query