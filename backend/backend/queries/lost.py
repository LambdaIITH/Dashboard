
from pypika import Query, Table, functions as fn
from typing import Dict, Any

lost_table, lost_images_table = Table('lost'), Table('lost_images')

def insert_in_lost_table( form_data: Dict[str, Any], user_id: int ): 
    query = Query.into(lost_table).columns('item_name', 'item_description', 'user_id').insert(
        form_data['item_name'], form_data['item_description'], user_id
    )
    
    sql_query = query.get_sql()
    sql_query += " RETURNING *"
    
    return sql_query


def insert_lost_images( image_paths: list, post_id: int): 

    query = Query.into(lost_images_table).columns('image_url', 'item_id')

    for image_path in image_paths:
        query = query.insert(image_path, post_id)
    
    return query.get_sql()


def get_all_lost_items():
    query = """
            SELECT
                f.id,
                f.item_name,
                f.item_description,
                f.user_id,
                COALESCE(json_agg(fi.image_url) FILTER (WHERE fi.image_url IS NOT NULL), '[]') AS images,
                f.created_at
            FROM
                lost f
            LEFT JOIN
                lost_images fi ON f.id = fi.item_id
            GROUP BY
                f.id, f.item_name, f.item_description, f.user_id
            ORDER BY
                f.created_at DESC;
            """
            
    return query


def update_in_lost_table( item_id: int, form_data: Dict[str, Any]):
    query = Query.update(lost_table)

    for key, value in form_data.items():
        if key == 'item_name' or key == 'item_description':
            query = query.set(lost_table[key], value)

    query = query.where(lost_table['id'] == item_id).get_sql()
    query  += " RETURNING *"
    return query

def get_particular_lost_item(item_id: int):
    query = Query.from_(lost_table).select('*').where(lost_table['id'] == item_id)
    return str(query)

def delete_an_item_images(item_id:int):
    query = Query.from_(lost_images_table).delete().where(lost_images_table['item_id'] == item_id)
    return str(query)

def get_all_image_uris(item_id: int):
    query = Query.from_(lost_images_table).select('image_url').where(lost_images_table['item_id'] == item_id)
    return str(query)