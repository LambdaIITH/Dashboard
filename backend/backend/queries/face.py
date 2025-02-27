from pypika import Query, Table, functions as fn, Order
from typing import Dict, Any

face_table = Table('face')
users = Table("users")
def insert_in_face_table( user_name: str, image_paths: list, user_id: int ): 
    query = Query.into(face_table).columns('user_name', 'face_url', 'user_id').insert(
        user_name, image_paths[0], user_id
    )
    
    sql_query = query.get_sql()
    sql_query += " RETURNING *"
    
    return sql_query