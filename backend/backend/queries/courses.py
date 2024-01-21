from Pypika import Table, Query, Field, Column
from models import *

users, courses, register = Table('users'), Table('courses'), Table('register')


def get_course(courseId: str, acad_period: str):
    query = (Query.from_(courses)
             .select('*')
             .where(courses.courseId == courseId)
             .where(courses.acad_period == acad_period)
             )
    return query.get_sql()


def get_timeTable(email: str, acad_period: str):
    query = (Query.from_(register)
             .select('*')
             .where(register.email == email)
             .where(register.acad_period == acad_period)
             )
    return query.get_sql()


def post_timeTable(email: str, course_codes: [str], acad_period: str):
    query = (
        Query.into(register)
        .columns(register.email, register.course_code, register.acad_period)
    )
    
    for course_code in course_codes:
        query = query.insert(email, course_code, acad_period)
    
    return query.get_sql()


def edit_timeTable(email : str, course_code : str, acad_period : str):
    query = (
        Query.update(register)
        .set(register.course_code, course_code)
        .where(register.email == email)
        .where(register.acad_period == acad_period)
    )
    return query.get_sql()