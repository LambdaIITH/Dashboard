from fastapi import APIRouter, HTTPException
from utils import conn
from models import Course, User, Slot_Change
from constants import slots

from psycopg2.errors import ForeignKeyViolation
from queries import custom as custom_queries
from typing import List, Dict

router = APIRouter(prefix="/custom", tags=["custom-changes"])


@router.post("/")
def post_custom_slot(slot: Slot_Change):
    try:
        if slot.custom_slot == {}:
            slot.custom_slot = None
            
        if slot.slot is not None and slot.slot not in slots:  # checking if this is a valid slot
            raise HTTPException(status_code=400, detail="Invalid Slot")

        if slot.custom_slot is not None and slot.slot is not None:
            raise HTTPException(
                status_code=400, detail="Both slot and custom_slot provided")
            
        with conn.cursor() as cur:
            query = custom_queries.post_course(slot)
            cur.execute(query)
        conn.commit()
        return {"message": "Change successfully posted"}

    except ForeignKeyViolation as e:
        conn.rollback()
        raise HTTPException(status_code=404, detail= f"Foreign Key Violdation: {e}")
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {e}")


@router.get("/")
def get_custom_slots(user_id: str, acad_period: str) -> List[Slot_Change]:
    try:
        out_list = []
        with conn.cursor() as cur:
            query = custom_queries.get_all_custom_courses(user_id, acad_period)
            cur.execute(query)
            rows = cur.fetchall()
            for row in rows:
                out_list.append(
                    Slot_Change(
                        course_code=row[0],
                        acad_period=row[1],
                        user_id=row[2],
                        slot=row[3],
                        custom_slot=row[4],
                    )
                )
        return out_list
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {e}")


@router.delete("/")
def delete_custom_slot(slot: Slot_Change):
    try:
        # course = get_course(slot.course_code, slot.acad_period)

        with conn.cursor() as cur:
            query = custom_queries.delete_course(slot)
            cur.execute(query)
        conn.commit()
        return {"message": "Course successfully deleted"}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {e}")


@router.patch("/")
def patch_custom_slot(slot: Slot_Change):
    try:
        if slot.custom_slot == {}:
            slot.custom_slot = None
            
        if slot.slot is not None and slot.slot not in slots:  # checking if this is a valid slot
            raise HTTPException(status_code=400, detail="Invalid Slot")


        if slot.custom_slot is not None and slot.slot is not None:
            raise HTTPException(
                status_code=400, detail="Both slot and custom_slot provided")
            
        with conn.cursor() as cur:
            query = custom_queries.update_course(slot)
            cur.execute(query)
        conn.commit()
            
        return {"message": "Course successfully Updated"}
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {e}")
