from pypika import Table, Query, Field, Column
from models import Slot_Change, Takes, Changes_Accepted
from typing import List

users, courses, register, custom_courses, changes_accepted, slot_updates = Table("users"), Table(
    "courses"), Table("register"), Table("custom_courses"), Table("changes_accepted"), Table("slot_updates")

# Returns the changes to be accepted by the user
def get_changes_to_be_accepted(user_id: int,acad_period: str):

    # In progress
    

    return query.get_sql()

# Returns all the changes which the user has already accepted
def get_all_accepted_changes(user_id: int,acad_period: str):
    query = (
        Query.from_(changes_accepted)
        .join(courses)
        .on(
            (courses.course_code==changes_accepted.course_code) &
            (courses.acad_period==changes_accepted.acad_period)
        )
        .join(slot_updates)
        .on(
            (slot_updates.course_code==courses.course_code) &
            (slot_updates.acad_period==courses.course_code)
        )
        .select(
            courses.course_code,
            courses.course_name,
            courses.segment,
            slot_updates.updated_slot,
            slot_updates.custom_timings
        )
        .where((changes_accepted.user_id==user_id)&(changes_accepted.acad_period==acad_period))
    )

    return query.get_sql()

# Deletes a change from changes accepted table
def delete_change(user_id: int, course_code: str, acad_period: str, cr_id: int):
    query = (
        Query.from_(changes_accepted)
        .where(
            (changes_accepted.user_id==user_id) &
            (changes_accepted.course_code==course_code) &
            (changes_accepted.acad_period==acad_period) &
            (changes_accepted.cr_id==cr_id)
        )
    )
    query = query.delete()

    return query.get_sql()

# Inserts a row into changes_accepted table
def accept_change(row: Changes_Accepted):
    query = (
        Query.into(changes_accepted)
        .columns(
            changes_accepted.user_id,
            changes_accepted.course_code,
            changes_accepted.acad_period,
            changes_accepted.cr_id
        )
    )

    query = query.insert(row[0],row[1],row[2],row[3])

    return query.get_sql()