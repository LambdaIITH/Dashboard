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


def create_timeTableQuery(timetable: Timetable):
    query = (
        Query.into(register)
        .columns(register.id, register.course_code, register.acad_period)
    )
    
    for course_code in timetable.course_codes:
        query = query.insert(timetable.id, course_code, timetable.acad_period)
    
    return query.get_sql()


def edit_timeTable(email : str, course_code : str, acad_period : str):
    query = (
        Query.update(register)
        .set(register.course_code, course_code)
        .where(register.email == email)
        .where(register.acad_period == acad_period)
    )
    return query.get_sql()