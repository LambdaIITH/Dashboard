from pypika import Table, Query, Field, Column
from models import *

users, courses, register = Table('users'), Table('courses'), Table('register')


def get_course(course_code : str, acad_period : str):
    query = (
        
    Query.from_(courses)
    .select('*')
    .where(
        courses.course_code == course_code &
        courses.acad_period == acad_period
        )
    )
    return query.get_sql()


def get_timeTable(user_id: int, acad_period: str):
    query = (
        
    Query.from_(register)
    .join(courses)
    .on(
        (register.course_code == courses.course_code) &
        (register.acad_period == courses.acad_period)
    )
    .select(
        courses.course_code, courses.acad_period, courses.course_name, courses.segment, courses.credits
    )
    .where(
        (register.user_id == user_id) &
        (register.acad_period == acad_period)
        )
    )

    return query.get_sql()

def get_allRegisteredCourses(user_id: int, acad_period:str):
    query = (
        
    Query.from_(register)
    .select(
        register.course_code
    )
    .where(
        (register.user_id == user_id)
        )
    )

    return query.get_sql()


def post_timeTable(timetable: Timetable):
    query = (
        Query.into(register)
        .columns(register.user_id, register.course_code, register.acad_period)
    )
    
    for course_code in timetable.course_codes:
        query = query.insert(timetable.user_id, course_code, timetable.acad_period)
    
    return query.get_sql()

def delete_timeTable(timetable: Timetable): # deletes some courses which are in this timeTable Object
    query = (
        Query.from_(register)
        .where(
            (register.user_id == timetable.user_id) &
            (register.acad_period == timetable.acad_period)
        )
        
    )
    
    for course_code in timetable.course_codes:
        query = query.where(register.course_code == course_code)
    
    query = query.delete()
    
    return query.get_sql()