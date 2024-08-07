from pypika import Query, Table, functions as fn, Order
from typing import Dict, Any
from enum import Enum

lost_table, lost_images_table = Table('lost'), Table('lost_images')
found_table, found_images_table = Table('found'), Table('found_images')
users = Table("users")

class TableType(Enum):
    LOST = lost_table
    FOUND = found_table
class TableImagesType(Enum):
    LOST = lost_images_table
    FOUND = found_images_table


def insert_in_table(TableType, form_data: Dict[str, Any], user_id: int ): 

    query = Query.into(TableType.value).columns('item_name', 'item_description', 'user_id').insert(
        form_data['item_name'], form_data['item_description'], user_id
    )
    
    sql_query = query.get_sql()
    sql_query += " RETURNING *"
    
    return sql_query


def insert_images(TableType, image_paths: list, post_id: int): 

    query = Query.into(TableType.value).columns('image_url', 'item_id')

    for image_path in image_paths:
        query = query.insert(image_path, post_id)
    
    return query.get_sql()

def get_all_items(TableType):
	if TableType.value == lost_table:
		tableQuery = """
			FROM
				lost f
			LEFT JOIN
				lost_images fi ON f.id = fi.item_id
            """
	else: tableQuery = """
			FROM
				found f
			LEFT JOIN
				found_images fi ON f.id = fi.item_id
            """
    	
	query = """
			SELECT
				f.id,
				f.item_name,
				f.item_description,
				f.user_id,
				COALESCE(json_agg(fi.image_url) FILTER (WHERE fi.image_url IS NOT NULL), '[]') AS images,
				f.created_at
            """
	+ tableQuery
	+ """
			GROUP BY
				f.id, f.item_name, f.item_description, f.user_id
			ORDER BY
				f.created_at DESC;
            """
            
	return query

def update_in_table(TableType, item_id: int, form_data: Dict[str, Any]):
    query = Query.update(TableType.value)

    for key, value in form_data.items():
        if key == 'item_name' or key == 'item_description':
            query = query.set(TableType.value[key], value)

    query = query.where(TableType.value['id'] == item_id).get_sql()
    query  += " RETURNING *"
    return query

def get_particular_item(TableType, item_id: int):
    query = (Query.from_(TableType.value)
             .join(users)
             .on(users['id'] == TableType.value['user_id'])
             .select('*')
             .where(TableType.value['id'] == item_id))
    return str(query)

def delete_an_item_images(TableImagesType, item_id:int):
    query = Query.from_(TableImagesType.value).delete().where(TableImagesType.value['item_id'] == item_id)
    return str(query)

def get_all_image_uris(TableImagesType, item_id: int):
    query = Query.from_(TableImagesType.value).select('image_url').where(TableImagesType.value['item_id'] == item_id)
    return str(query)

def search_items(TableType, search_query: str, max_results: int= 10):
    query = (Query.from_(TableType.value)
    .select('*')
    .where(TableType.value['item_name'].ilike(f'%{search_query}%') | TableType.value['item_description'].ilike(f'%{search_query}%'))
    .orderby(TableType.value['created_at'], order=Order.desc)
    .limit(max_results)
    )
    return str(query)

def get_some_image_uris(TableImagesType, item_ids : list):
    query = Query.from_().select(TableImagesType.value['item_id'], TableImagesType.value['image_url']).where(TableImagesType.value['item_id'].isin(item_ids))
    return str(query)