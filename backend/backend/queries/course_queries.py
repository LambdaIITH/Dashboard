from pypika import Table, Query, Field, Column
from models import *

users, courses, register = Table('users'), Table('courses'), Table('register')


def get_course(register_details: Register):
    query = (Query.from_(register)
             .select('*')
             .where(register.course_code == register_details.course_code)
             .where(register.acad_period == register_details.acad_period)
             .where(register.user_id == register_details.user_id)
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