from fastapi import APIRouter, HTTPException
from utils import conn
from models import  Course, User, Slot_Change
from queries import timetable as timetable_queries
from psycopg2.errors import ForeignKeyViolation
# from psycopg2.errors import UniqueViolation
from queries import timetable as timetable_queries
from queries import course as course_queries
from queries import cr as cr_queries
from queries import user as user_queries
from typing import List, Dict

router = APIRouter(prefix="/cr", tags=["courses"])

# def get_course(course_code: str, acad_period: str) -> Course:
#     try:
#         query = course_queries.get_course(course_code, acad_period)

#         with conn.cursor() as cur:
#             cur.execute(query)

#             if cur.rowcount == 0:
#                 raise HTTPException(status_code=404, detail="Course not Found")

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
    try:
        query = user_queries.get_user(user_id=user_id)
        with conn.cursor() as cur:
            cur.execute(query)

            if cur.rowcount == 0:
                raise HTTPException(status_code= 404, detail= 'User doesn\'t exist')

            user = User.from_row(cur.fetchone())

            if user.cr == False:
                raise HTTPException(status_code= 400, detail= 'Unauthorized Action, User is not CR')

            return user
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Internal Server Error: {e}')
    

@router.patch("/")
def post_change_as_cr(slot: Slot_Change):
    try:
        cr = check_user_is_cr(slot.user_id)
        
        if slot.custom_slot is None and slot.slot is None:
            raise HTTPException(status_code=400, detail="No slot provided")

        if slot.custom_slot is not None and slot.slot is not None:
            raise HTTPException(status_code=400, detail="Both slot and custom_slot provided")
        
        
        with conn.cursor() as cur:
            query = cr_queries.post_change(slot)
            cur.execute(query)
            
        return {"message" : "Change successfully posted"}     
            
    except ForeignKeyViolation as e:
        raise HTTPException(status_code=404, detail=f'Course not found: {e}')
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Internal Server Error: {e}')


    
# route for changing the slot of a course from frontend
@router.patch('/')
def post_change_slot(slot: Slot_Change):
    try:
        cr = check_user_is_cr(slot.user_id)
        
        if slot.custom_slot is None and slot.slot is None:
            raise HTTPException(status_code=400, detail="No slot provided")

        if slot.custom_slot is not None and slot.slot is not None:
            raise HTTPException(status_code=400, detail="Both slot and custom_slot provided")
        
        with conn.cursor() as cur:
            query = cr_queries.update_CR_change(slot)
            affected_rows = cur.rowcount
            if affected_rows == 0:
                raise HTTPException(status_code=404, detail="No Changes Made")

            cur.execute(query)
            
        return {"message" : "Change successfully posted"}     
            
    except ForeignKeyViolation as e:
        raise HTTPException(status_code=404, detail=f'Course not found: {e}')
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Internal Server Error: {e}')
    
    
@router.delete('/')
def delete_change_slot(course_code :str, acad_period: str, cr_id: int):
    try:
        cr = check_user_is_cr(cr_id)
        
        with conn.cursor() as cur:
            query = cr_queries.delete_CR_change(course_code, acad_period, cr_id)
            cur.execute(query)
            affected_rows = cur.rowcount
            if affected_rows == 0:
                raise HTTPException(status_code=404, detail="No Changes Made")
        return {"message" : "Change successfully deleted"}     
               
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Internal Server Error: {e}')

# TODO
@router.get('/{user_id}')
def get_cr_changes() -> List[Slot_Change]:
    try:
        registered_courses = []
        custom_courses = []
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Internal Server Error: {e}')