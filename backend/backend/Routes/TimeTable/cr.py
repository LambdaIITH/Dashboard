from fastapi import APIRouter, HTTPException
from utils import conn
from models import Course, User, Slot_Change
from queries import timetable as timetable_queries
from psycopg2.errors import ForeignKeyViolation
# from psycopg2.errors import UniqueViolation
from queries import custom as custom_queries
from queries import cr as cr_queries
from queries import user as user_queries
from queries import course as course_queries
from typing import List, Dict
from constants import slots
router = APIRouter(prefix="/cr", tags=["cr-changes"])

# def get_course(course_code: str, acad_period: str) -> Course:
#     try:
#         query = course_queries.get_course(course_code, acad_period)

#         with conn.cursor() as cur:
#             cur.execute(query)

#             if cur.rowcount == 0:
#                 raise HTTPException(status_code=404, detail="Foreign Key Violdated")

#             if cur.rowcount > 1:
#                 raise HTTPException(
#                     status_code=500, detail="Multiple courses found")

#             row = cur.fetchone()
#             # true since rowcount > 0 (adding because of linter warning)
#             assert row is not None

#             return Course.from_row(row)

#     except Exception as e:
#         raise HTTPException(
#             status_code=500, detail=f'Internal Server Error: {e}')


def check_user_is_cr(user_id: int):

    query = user_queries.get_user(user_id=user_id)
    with conn.cursor() as cur:
        cur.execute(query)
        if cur.rowcount == 0:
            raise HTTPException(status_code=404, detail='User doesn\'t exist')
        row = cur.fetchone()

        user = User.from_row(row)
        if user.cr == False:
            raise HTTPException(
                status_code=400, detail='Unauthorized Action, User is not CR')
        return user


@router.post("/")
def post_change_as_cr(slot: Slot_Change):
    try:
        cr = check_user_is_cr(slot.user_id)
        if slot.custom_slot == {}:
            slot.custom_slot = None

        if slot.slot is not None and slot.slot not in slots:  # checking if this is a valid slot
            raise HTTPException(status_code=400, detail="Invalid Slot")

        if slot.custom_slot is not None and slot.slot is not None:
            raise HTTPException(
                status_code=400, detail="Both slot and custom_slot provided")

        with conn.cursor() as cur:
            query = cr_queries.post_change(slot)
            cur.execute(query)
            conn.commit()

        return {"message": "Change successfully posted"}

    except HTTPException as e:
        conn.rollback()
        raise e
    except ForeignKeyViolation as e:
        conn.rollback()
        raise HTTPException(
            status_code=404, detail=f'Foreign Key Violdated: {e}')
    except Exception as e:
        conn.rollback()
        raise HTTPException(
            status_code=500, detail=f'Internal Server Error: {e}')


# route for changing the slot of a course from frontend
@router.patch('/')
def post_change_slot(slot: Slot_Change):
    try:
        cr = check_user_is_cr(slot.user_id)

        if slot.custom_slot == {}:
            slot.custom_slot = None

        if slot.custom_slot is None and slot.slot is None:
            raise HTTPException(status_code=400, detail="No slot provided")

        if slot.slot is not None and slot.slot not in slots:  # checking if this is a valid slot
            raise HTTPException(status_code=400, detail="Invalid Slot")

        with conn.cursor() as cur:
            query = cr_queries.update_CR_change(slot)
            cur.execute(query)
            conn.commit()

        return {"message": "Change successfully posted"}

    except HTTPException as e:
        conn.rollback()
        raise e
    except ForeignKeyViolation as e:
        conn.rollback()
        raise HTTPException(
            status_code=404, detail=f'Foreign Key Violdated: {e}')
    except Exception as e:
        conn.rollback()
        raise HTTPException(
            status_code=500, detail=f'Internal Server Error: {type(e)} {e}')


@router.delete('/')
def delete_change_slot(course_code: str, acad_period: str, cr_id: int):
    try:
        cr = check_user_is_cr(cr_id)

        with conn.cursor() as cur:
            query = cr_queries.delete_CR_change(
                course_code, acad_period, cr_id)
            cur.execute(query)
            affected_rows = cur.rowcount
            if affected_rows == 0:
                raise HTTPException(status_code=404, detail="No Changes Made")

        conn.commit()
        return {"message": "Change successfully deleted"}

    except HTTPException as e:
        conn.rollback()
        raise e
    except Exception as e:
        conn.rollback()
        raise HTTPException(
            status_code=500, detail=f'Internal Server Error: {type(e)} {e}')


# TODO change cr id's with cr names
@router.get('/{user_id}')
def get_cr_changes_for_user(user_id: int, acad_period: str) -> List[Slot_Change]:
    try:

        with conn.cursor() as cur:
            # fetch all custom queries
            query1 = custom_queries.get_all_custom_courses(
                user_id, acad_period)
            cur.execute(query1)
            rows = cur.fetchall()
            courses = [row[0] for row in rows]

            query2 = timetable_queries.get_allRegisteredCourses(
                user_id, acad_period)
            cur.execute(query2)
            rows = cur.fetchall()
            courses.extend([row[0] for row in rows])

            courses = list(set(courses))  # for getting the unique courses

            # fetch all cr changes in any of custom or registered courses
            query3 = cr_queries.get_CR_changes(courses, acad_period)
            cur.execute(query3)
            rows = cur.fetchall()
            changes = [Slot_Change.from_row(row) for row in rows]

            return changes

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f'Internal Server Error: {e}')
