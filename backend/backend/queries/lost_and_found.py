from pypika import Query, Table, functions as fn, Order
from typing import Dict, Any
from models import TableType, TableImagesType

lost_table, lost_images_table = Table('lost'), Table('lost_images')
found_table, found_images_table = Table('found'), Table('found_images')
users = Table("users")

def insert_in_table(table_type: TableType, form_data: Dict[str, Any], user_id: int ): 

    query = Query.into(table_type.value).columns('item_name', 'item_description', 'user_id').insert(
        form_data['item_name'], form_data['item_description'], user_id
    )
    
    sql_query = query.get_sql()
    sql_query += " RETURNING *"
    
    return sql_query


def insert_images(table_type: TableType, image_paths: list, post_id: int): 

    query = Query.into(table_type.value).columns('image_url', 'item_id')

    for image_path in image_paths:
        query = query.insert(image_path, post_id)
    
    return query.get_sql()

def get_all_items(table_type: TableType):
	if table_type.value == lost_table:
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

def update_in_table(table_type: TableType, item_id: int, form_data: Dict[str, Any]):
    query = Query.update(table_type.value)

    for key, value in form_data.items():
        if key == 'item_name' or key == 'item_description':
            query = query.set(table_type.value[key], value)

    query = query.where(table_type.value['id'] == item_id).get_sql()
    query  += " RETURNING *"
    return query

def get_particular_item(table_type: TableType, item_id: int):
    query = (Query.from_(table_type.value)
             .join(users)
             .on(users['id'] == table_type.value['user_id'])
             .select('*')
             .where(table_type.value['id'] == item_id))
    return str(query)

def delete_an_item_images(table_images_type: TableImagesType, item_id:int):
    query = Query.from_(table_images_type.value).delete().where(table_images_type.value['item_id'] == item_id)
    return str(query)

def get_all_image_uris(table_images_type: TableImagesType, item_id: int):
    query = Query.from_(table_images_type.value).select('image_url').where(table_images_type.value['item_id'] == item_id)
    return str(query)

def search_items(table_type: TableType, search_query: str, max_results: int= 10):
    query = (Query.from_(table_type.value)
    .select('*')
    .where(table_type.value['item_name'].ilike(f'%{search_query}%') | table_type.value['item_description'].ilike(f'%{search_query}%'))
    .orderby(table_type.value['created_at'], order=Order.desc)
    .limit(max_results)
    )
    return str(query)

def get_some_image_uris(table_images_type: TableImagesType, item_ids : list):
    query = Query.from_().select(table_images_type.value['item_id'], table_images_type.value['image_url']).where(table_images_type.value['item_id'].isin(item_ids))
    return str(query)