from fastapi import APIRouter, HTTPException
from utils import conn
from models import  Course, User, Slot_Change
from queries import timetable as timetable_queries
from psycopg2.errors import ForeignKeyViolation, InFailedSqlTransaction
# from psycopg2.errors import UniqueViolation
from queries import timetable as timetable_queries
from queries import course as course_queries
from queries import user as user_queries
from typing import List, Dict

router = APIRouter(prefix="/cr", tags=["courses"])
# TODO

def get_course(course_code: str, acad_period: str) -> Course:
    try:
        query = course_queries.get_course(course_code, acad_period)

        with conn.cursor() as cur:
            cur.execute(query)

            if cur.rowcount == 0:
                raise HTTPException(status_code=404, detail="Course not Found")

            if cur.rowcount > 1:
                raise HTTPException(
                    status_code=500, detail="Multiple courses found")

            row = cur.fetchone()
            # true since rowcount > 0 (adding because of linter warning)
            assert row is not None

            return Course.from_row(row)

    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f'Internal Server Error: {e}')


@router.patch("/slot/cr")
def post_change_as_cr(new_slot: Slot_Change):
    try:
        cr = check_user_is_cr(new_slot.user_id)
        
        course = get_course(new_slot.course_code, new_slot.acad_period)
        
        with conn.cursor() as cur:
            query = course_queries.post_change(new_slot)
            cur.execute(query)
            
        return {"message" : "Change successfully posted"}     
            

    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Internal Server Error: {e}')

def check_user_is_cr(user_id: int):
    query = user_queries.get_user(user_id=user_id)
    with conn.cursor() as cur:
        cur.execute(query)
        
        if cur.rowcount == 0:
            raise HTTPException(status_code= 404, detail= 'User doesn\'t exist')
        
        user = User.from_row(cur.fetchone())
        
        if user.cr == False:
            raise HTTPException(status_code= 400, detail= 'Unauthorized Action, User is not CR')

        return user
    
# route for changing the slot of a course from frontend
@router.patch('/slot')
def post_change_slot(slot: Slot_Change):
    try:
        course = get_course(slot.course_code, slot.acad_period)
        
        with conn.cursor() as cur:
            query = course_queries.post_change(slot)
            cur.execute(query)
            
        return {"message" : "Change successfully posted"}     
            

    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Internal Server Error: {e}')