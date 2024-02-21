from fastapi import APIRouter, HTTPException
from utils import conn
from models import  Course, User, Slot_Change, Changes_Accepted, Changes_tobe_Accepted
from queries import timetable as timetable_queries
from psycopg2.errors import ForeignKeyViolation, InFailedSqlTransaction
# from psycopg2.errors import UniqueViolation
from queries import cr as slot_update_queries
from queries import course as course_queries
from queries import user as user_queries
from queries import changes as changes_accepted_queries
from typing import List, Dict

router = APIRouter(prefix="/changes", tags=["courses"])

def get_required_details_from_course(row: tuple):
    return (row[0], row[2], row[3], row[4])

@router.get('/{user_id}')
async def get_all_changes_to_be_accepted(user_id: int, acad_period: str) -> List[Changes_tobe_Accepted]:
    try:
        query = timetable_queries.get_registered_course_details(user_id,acad_period)

        with conn.cursor() as cur:

            cur.execute(query)

            # registered_courses contains all the registered courses of given user
            registered_courses = list(map(get_required_details_from_course ,cur.fetchall()))


            query = slot_update_queries.get_all_slot_updates(acad_period)
            cur.execute(query)

            # slot_updates contains all the slot updates for a specific acad period
            slot_updates = cur.fetchall()

            answer = []

            for i in slot_updates:
                for j in registered_courses:
                    if i[0]==j[0]:
                        answer.append(Changes_tobe_Accepted.from_row(i,j))
                        break

            return answer

    except (ForeignKeyViolation, InFailedSqlTransaction) as e:  # if some course doesn't exist

        raise HTTPException(status_code=404, detail=f"Course not Found : {e}")
    
    except Exception as e:

        raise HTTPException(status_code=500, detail=f"Internal Server Error : {type(e)}")
    

@router.delete('/{user_id}')
async def delete_change(user_id: int, acad_peiod: str, course_code: str, cr_id: int):
    try:
        query = changes_accepted_queries.delete_change(user_id, course_code, acad_peiod, cr_id)

        with conn.cursor() as cur:

            cur.execute(query)

    except (ForeignKeyViolation, InFailedSqlTransaction) as e:  # if some course doesn't exist

        raise HTTPException(status_code=404, detail=f"Accepted Change not Found : {e}")
    
    except Exception as e:

        raise HTTPException(status_code=500, detail=f"Internal Server Error : {type(e)}")

    
@router.post('/{user_id}')
async def accept_change(row: Changes_Accepted):
    try:
        query = changes_accepted_queries.accept_change(Changes_Accepted)

        with conn.cursor() as cur:

            cur.execute(query)

    except (ForeignKeyViolation, InFailedSqlTransaction) as e:  # if some course doesn't exist

        raise HTTPException(status_code=404, detail=f"User not Found : {e}")
    
    except Exception as e:

        raise HTTPException(status_code=500, detail=f"Internal Server Error : {type(e)}")