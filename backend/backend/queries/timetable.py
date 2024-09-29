from pypika import Table, Query, Field, Column
from models import Timetable
from typing import List
from datetime import datetime as DateTime
import json
users, shared_timetable = Table('users'), Table('shared_timetable')

def get_timetable(user_id: int) -> str:
    """Get the timetable of the user with the given user_id"""
    query = Query.from_(users).select('timetable').where(users.id == user_id)
    return str(query)

def post_timetable(user_id: int, timetable: Timetable) -> str:
    """Update the timetable of the user with the given user_id"""
    timetable = json.dumps(timetable.model_dump())
    print(timetable)
    
    query = Query.update(users).set('timetable', timetable).where(users.id == user_id)
    return str(query)

def get_shared_timetable(code: str) -> str:
    """Get the timetable with the given code"""
    query = Query.from_(shared_timetable).select('*').where(shared_timetable.code == code)
    return str(query)

def post_shared_timetable(code: str, user_id: int, timetable, expiry: DateTime) -> str:
    """Post the timetable to the shared_timetable table"""
    query = Query.into(shared_timetable).columns('code', 'user_id', 'timetable', 'expiry').insert(code, user_id, json.dumps(timetable), expiry)
    return str(query)

def delete_shared_timetable(code: str) -> str:
    """Delete the timetable with the given code"""
    query = Query.from_(shared_timetable).delete().where(shared_timetable.code == code)
    return str(query)