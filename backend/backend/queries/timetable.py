from pypika import Table, Query, Field, Column
from models import Timetable
from typing import List, Dict

users, courses, register = Table("users"), Table("courses"), Table("register")


def get_registered_courses(user_id: int) -> str:
    query = (Query.from_(users)
             .select(users['timetable'])
             .where(id == user_id))
    return query.get_sql()

def register_courses_and_slots(user_id: int, slots: [Dict[str, Dict[str, str]], courses: List[str]]) -> str:
    query = (Query.into(register)
             .columns('user_id', 'course_code', 'slot')
             .insert(user_id, courses, slots))
    return query.get_sql()