from pypika import Table, Query, Field, Column
from models import Slot_Change
from typing import List

custom_courses = Table("custom_courses")


def post_course(slot: Slot_Change):
    query = Query.into(custom_courses).insert(
        slot.course_code, slot.acad_period, slot.user_id, slot.slot, slot.custom_slot
    )
    return query.get_sql()


def get_all_custom_courses(user_id: str, acad_period: str):
    query = (
        Query.from_(custom_courses)
        .select("*")
        .where(
            (custom_courses.acad_period == acad_period)
            & (custom_courses.user_id == user_id)
        )
    )

    return query.get_sql()


def delete_course(course_code: str, acad_period: str, user_id: str):
    query = Query.from_(custom_courses).where(
        (custom_courses.course_code == course_code)
        & (custom_courses.acad_period == acad_period)
        & (custom_courses.user_id == user_id)
    )

    query = query.delete()

    return query.get_sql()


def update_course(slot: Slot_Change):
    query = (
        Query.update(custom_courses)
        .set(custom_courses.slot, slot.slot)
        .set(custom_courses.custom_timings, slot.custom_slot)
        .where(
            (custom_courses.course_code == slot.course_code)
            & (custom_courses.acad_period == slot.acad_period)
            & (custom_courses.user_id == slot.user_id)
        )
    )

    return query.get_sql()
