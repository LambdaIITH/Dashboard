from pypika import Table, Query, Field, Column
from models import Timetable
from typing import List
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