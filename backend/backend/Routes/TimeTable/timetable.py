from fastapi import APIRouter, HTTPException, Request
from utils import conn
from models import Timetable
from queries import timetable as timetable_queries
from psycopg2.errors import ForeignKeyViolation, InFailedSqlTransaction
from typing import List , Dict
from constants import default_slots
from Routes.Auth.cookie import get_user_id
import regex as re
import uuid 
router = APIRouter(prefix="/timetable", tags=["timetable"])

def slot_sanity_check(slot : Dict[str, str]):
    try:
        keys = slot.keys()
        slot_val = slot.values()
        # check if all slots are valid
        # basically keys must be in one of the weekdays
        weekdays = ['M', 'T', 'W', 'Th', 'F', 'S', 'Su']
        for key in keys:
            if key not in weekdays:
                return False

        # check if all values are in the format of HH:MM-HH:MM

        for val in slot_val:
            if not re.match(r"^\d{2}:\d{2}-\d{2}:\d{2}$", val):
                return False
        # all HH must be in 00 to 23 and MM must be in 00 to 59
        for val in slot_val:
            start, end = val.split("-")
            start_hh, start_mm = start.split(":")
            end_hh, end_mm = end.split(":")
            if not (0 <= int(start_hh) <= 23 and 0 <= int(start_mm) <= 59 and 0 <= int(end_hh) <= 23 and 0 <= int(end_mm) <= 59):
                return False

        return True
    except Exception as e:
        return False
    
    
@router.get("/courses")
def get_timetable(request: Request) -> Timetable:
    user_id = get_user_id(request)
    try: 
        query = timetable_queries.get_timetable(user_id)
        with conn.cursor() as cur:
            cur.execute(query)
            courses = cur.fetchone()
            return Timetable.from_row(courses[0])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal Server Error : {e}")

@router.post("/")
def post_edit_timetable(request: Request, timetable: Timetable):
    user_id = get_user_id(request)
    # sanity check
    course_codes = list(timetable.courses.keys())
    custom_slot_codes = list(timetable.custom_slots.keys())
    ## check if custom_slot_codes are not same as default slots
    
    
    for slot in custom_slot_codes:
        if slot in default_slots or custom_slot_codes.count(slot) > 1:
            raise HTTPException(status_code=400, detail = "Slot already exists") 
    
    ## doing sanity check on slots
    for slot in custom_slot_codes:
        if not slot_sanity_check(timetable.custom_slots[slot]):
            raise HTTPException(status_code=400, detail=f"Slot {slot} is not in correct format")
    slots = list(set(default_slots).union(set(custom_slot_codes)))
    
    ## check if all courses occur in valid slots only
    for course_code, slot in timetable.courses.items():
        if slot not in slots:
            raise HTTPException(status_code=400, detail=f"No slot {slot} exists for course {course_code}")
    try:
        query = timetable_queries.post_timetable(user_id, timetable)
        with conn.cursor() as cur:
            cur.execute(query)
            conn.commit()
        return {"message": "Timetable Updated Successfully"}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Internal Server Error : {e}")

@router.get('/share/{code}')
def get_shared_timetable(code: str):
    try:
        query = timetable_queries.get_shared_timetable(code)
        with conn.cursor() as cur:
            cur.execute(query)
            timetable =cur.fetchone()
            if timetable is None:
                raise HTTPException(status_code=404, detail="Code Not Found")

            
            ## convert a sql returned time string to DateTime Object\
            expiry = timetable[3]
            if expiry < DateTime.now():
                conn.commit()
                delete_query = timetable_queries.delete_shared_timetable(code)
                cur.execute(delete_query)
                conn.commit()
                raise HTTPException(status_code=404, detail="Timetable has expired")

            return timetable[2]
            
    except HTTPException as e:
        raise e
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Internal Server Error : {e}")

from datetime import datetime as DateTime
import datetime
@router.post('/share')
def post_share_timetable(request: Request):
    """
    Generate a unique code for the timetable, store it in db and return it
    """

    user_id = get_user_id(request)
    code = 'FIXED FOR NOW'
    try:
        query = timetable_queries.get_timetable(user_id)
        with conn.cursor() as cur:
            cur.execute(query)
            timetable = cur.fetchone()[0]
            
            cur_date = DateTime.now()
            expiry_days = 120
            expiry = cur_date + datetime.timedelta(days = expiry_days)
            code = 'FIXED__' # will make this random
            query = timetable_queries.post_shared_timetable(code, user_id, timetable, expiry)
            cur.execute(query)
            conn.commit()
            return {"code": code}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Internal Server Error : {e}")
    
@router.delete('/share/{code}')
def delete_shared_timetable(request: Request, code: str):
    user_id = get_user_id(request)
    ## Check if user is the owner of this code
    try:
        query = timetable_queries.get_shared_timetable(code)
        with conn.cursor() as cur:
            cur.execute(query)
            timetable = cur.fetchone()
            if timetable is None:
                raise HTTPException(status_code=404, detail="Timetable not found")
            
            if timetable[1] != user_id:
                raise HTTPException(status_code=403, detail="You are not the owner of this timetable")
            
            query = timetable_queries.delete_shared_timetable(code)
            cur.execute(query)
            conn.commit()
            return {"message": "Timetable Deleted Successfully"}
    except HTTPException as e:
        raise e
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Internal Server Error : {e}")