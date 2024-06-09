from pypika import Table, Query, Field, Column
from models import User
from typing import List

users, courses, register = Table("users"), Table("courses"), Table("register")

def get_user(user_id: int):
    query = (Query.from_(users)
             .select('*')
             .where(users.id == user_id))
    return query.get_sql()

def get_refresh_token(user_id: int):
    query = (Query.from_(users)
             .select(users.refresh_token)
             .where(users.id == user_id))
    return query.get_sql()

def post_user(user: User):
    query = (Query.into(users)
             .columns(users.email, users.cr, users.refresh_token)
             .insert(user.email, user.cr, user.refresh_token)
             .returning(users.id))
    return query.get_sql()