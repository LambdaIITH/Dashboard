from Pypika import Table, Query, Field, Column
from models import *

users,courses, register = Table('users'), Table('courses'), Table('register')

def get_course(courseId : str, acad_period: str):
    query = Query.from_(courses)
    .select('*')
    .where(courses.courseId == courseId)
    .where(courses.acad_period == acad_period)
    
    return query.get_sql()

def get_timeTable(id: int, acad_period: str):
    query = Query.from_(register)
    .select('*')
    .where(register.user_id == id)
    .where(register.acad_period == acad_period)

    return query.get_sql()

def 