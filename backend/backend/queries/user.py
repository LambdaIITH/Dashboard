from pypika import Table, Query, Field, Column
from models import Timetable
from typing import Dict, List, Optional
from models import User

users, courses, register = Table("users"), Table("courses"), Table("register")

def get_user(user_id: int):
    query = (Query.from_(users)
             .select('*')
             .where(users.id == user_id))
    return query.get_sql()

def post_user(user: User):
    query = (Query.into(users)
             .columns(users.email, users.cr)
             .insert(user.email, user.cr))
    return query.get_sql()

def get_user_details(conn, user_id: int) -> Optional[Dict[str, str]]:
    query = """
    SELECT email, name, phone
    FROM users
    WHERE id = %s
    """
    with conn.cursor() as cursor:
        cursor.execute(query, (user_id,))
        user = cursor.fetchone()
    if user:
        return {
            "email": user[0],
            "name": user[1],
            "phone": user[2]
        }
    return None
