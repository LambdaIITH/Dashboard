# queries/user.py

from typing import Optional, Dict
from pypika import Table, Query
from utils import conn 

users = Table("users")

def get_user(user_id: int) -> Optional[Dict[str, str]]:
    query = (Query.from_(users)
             .select('*')
             .where(users.id == user_id))

    with conn.cursor() as cursor:
        cursor.execute(query.get_sql(), (user_id,))
        user = cursor.fetchone()
    print(user)
    if user:
        return {
            "id": user[0],
            "email": user[1],
            "name": user[2],
            "cr": user[3],
            "phone_number": user[4]
        }
    return None

def update_phone(user_id: int, phone: str) -> Optional[Dict[str, str]]:
    query = """
    UPDATE users
    SET phone_number = %s
    WHERE id = %s
    RETURNING id, email, name, cr, phone_number
    """
    with conn.cursor() as cursor:
        cursor.execute(query, (phone, user_id))
        user = cursor.fetchone()
        conn.commit()
    if user:
        return {
            "id": user[0],
            "email": user[1],
            "name": user[2],
            "cr": user[3],
            "phone_number": user[4]
        }
    return None
