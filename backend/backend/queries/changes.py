from pypika import Table, Query, Field, Column
from models import Slot_Change, Takes, Changes_Accepted
from typing import List

users, courses, register, custom_courses, changes_accepted, slot_updates = Table("users"), Table(
    "courses"), Table("register"), Table("custom_courses"), Table("changes_accepted"), Table("slot_updates")

# Returns the changes to be accepted by the user
def get_changes_to_be_accepted(user_id: int,acad_period: str):
    pass
    # In progress
    

    # return query.get_sql()

# Returns all the changes which the user has already accepted
def get_all_accepted_changes(user_id: int,acad_period: str):
    query = (
        Query.from_(changes_accepted)
        .join(slot_updates)
        .on(
            (slot_updates.course_code== changes_accepted.course_code) &
            (slot_updates.acad_period== changes_accepted.acad_period) & 
            (slot_updates.cr_id==changes_accepted.cr_id)
        )
        .select(
            changes_accepted.course_code,
            changes_accepted.acad_period,
            changes_accepted.cr_id,
            slot_updates.updated_slot,
            slot_updates.custom_timings
        )
        .where((changes_accepted.user_id==user_id)&(changes_accepted.acad_period==acad_period))
    )

    return query.get_sql()

# Deletes a change from changes accepted table
def delete_change(change: Changes_Accepted):
    query = (
        Query.from_(changes_accepted)
        .where(
            (changes_accepted.user_id==change.user_id) &
            (changes_accepted.course_code==change.course_code) &
            (changes_accepted.acad_period==change.acad_period) &
            (changes_accepted.cr_id==change.cr_id)
        )
    )
    query = query.delete()

    return query.get_sql()

# Inserts a change into changes_accepted table
def accept_change(change: Changes_Accepted):
    query = (
        Query.into(changes_accepted)
        .columns(
            changes_accepted.user_id,
            changes_accepted.course_code,
            changes_accepted.acad_period,
            changes_accepted.cr_id
        )
    )

    query = query.insert(change.user_id,change.course_code,change.acad_period,change.cr_id)

    return query.get_sql()

# Checks if a user has already accepted a change for a course_id
def exists(change: Changes_Accepted):
    query = (
        Query.from_(changes_accepted)
        .select('*')
        .where(
            (changes_accepted.user_id==change.user_id) &
            (changes_accepted.course_code==change.course_code) &
            (changes_accepted.acad_period==change.acad_period)
        )
    )

    return query.get_sql()

# Updates an accepted change of a user with a course_id
def update_change(change: Changes_Accepted):
    query = (
        Query.update(changes_accepted)
        .set(changes_accepted.cr_id,change.cr_id)
        .where(
            (changes_accepted.user_id==change.user_id) &
            (changes_accepted.course_code==change.course_code) &
            (changes_accepted.acad_period==change.acad_period)
        )
    )

    return query.get_sql()

def get_all_accepted_courses(user_id: int, acad_period: str):
    query = (
        Query.from_(changes_accepted)
        .select('*')
        .where((changes_accepted.user_id==user_id)&(changes_accepted.acad_period==acad_period))
    )

    return query.get_sql()