from pypika import Table, Query, Field, Column
from models import Slot_Change
from typing import List

users, courses, register, custom_courses = Table("users"), Table(
    "courses"), Table("register"), Table("custom_courses")


def get_course(course_code: str, acad_period: str):
    query = (
        Query.from_(courses)
        .select("*")
        .where((courses.course_code == course_code) & (courses.acad_period == acad_period))
    )
    return query.get_sql()


def get_all_courses(course_list: List[str], acad_period: str):
    query = Query.from_(courses).select("*").where(
        (courses.course_code.isin(course_list)) & (
            courses.acad_period == acad_period)
    )

    return query.get_sql()


def post_CR_change(new_slot: Slot_Change):
    query = (
        Query.into(custom_courses)
        .insert(
            new_slot.course_code, new_slot.acad_period, new_slot.user_id, new_slot.slot, new_slot.custom_slot,
        )
    )
    
    return query.get_sql()

def post_user_change(slot: Slot_Change):
    query = (
        Query.into(register)
        .insert(
            slot.course_code, slot.acad_period, slot.user_id, slot.slot, slot.custom_slot
        )
    )
    return query.get_sql()
