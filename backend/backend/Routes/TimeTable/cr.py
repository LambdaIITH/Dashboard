from fastapi import APIRouter, HTTPException, Request
from utils import conn
from models import Course, User, Slot_Change
from queries import timetable as timetable_queries
from psycopg2.errors import ForeignKeyViolation, UniqueViolation
# from psycopg2.errors import UniqueViolation
from queries import custom as custom_queries
from queries import cr as cr_queries
from queries import user as user_queries
from queries import course as course_queries
from typing import List, Dict
from constants import slots
from Routes.Auth.cookie import get_user_id
router = APIRouter(prefix="/cr", tags=["cr-changes"])


def check_user_is_cr(user_id: int) -> User:
    """
        Check if the user is CR and return the user object
    """
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
def post_change_as_cr(request: Request, slot: Slot_Change) -> Dict[str, str]:
    user_id = get_user_id(request)
    slot.user_id = user_id
    try:
        cr = check_user_is_cr(slot.user_id)
        if slot.custom_slot == {}:
            slot.custom_slot = None

        if slot.slot is not None and slot.slot not in slots:  # checking if this is a valid slot
            raise HTTPException(status_code=400, detail="Invalid Slot")

        with conn.cursor() as cur:
            query = cr_queries.post_change(slot)
            cur.execute(query)
        conn.commit()

        return {"message": "Change successfully posted"}

    
    except ForeignKeyViolation as e:
        raise HTTPException(
            status_code=404, detail=f'Foreign Key Violated')
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f'Internal Server Error: {e}')


# route for changing the slot of a course from frontend
@router.patch('/')
def patch_change_slot( request : Request, slot: Slot_Change) -> Dict[str, str]:
    user_id = get_user_id(request)
    slot.user_id = user_id
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
            if cur.rowcount == 0:
                raise HTTPException(status_code=404, detail="No Changes Made: No such CR change exists")
            conn.commit()
        
        return {"message": "Change successfully posted"}

    except ForeignKeyViolation as e:
        raise HTTPException(
            status_code=404, detail=f'Foreign Key Violdated: {e}')
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f'Internal Server Error: {e}')


@router.delete('/')
def delete_change_slot(request: Request, course_code: str, acad_period: str) -> Dict[str, str]:
    cr_id = get_user_id(request)
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
        raise e
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f'Internal Server Error: {type(e)} {e}')

