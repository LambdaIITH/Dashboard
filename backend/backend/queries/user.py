from pypika import Table, Query, Field, Column
from models import Timetable
from typing import List

users, courses, register = Table("users"), Table("courses"), Table("register")

def get_user(user_id: int):
    query = (Query.from_(users)
             .where(users.id == user_id))
    return query.get_sql()