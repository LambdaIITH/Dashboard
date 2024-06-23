from fastapi import APIRouter, HTTPException
from utils import conn
from models import Course, User, Slot_Change, Changes_Accepted
from queries import timetable as timetable_queries
from psycopg2.errors import ForeignKeyViolation, InFailedSqlTransaction
# from psycopg2.errors import UniqueViolation
from queries import cr as cr_queries
from queries import course as course_queries
from queries import user as user_queries
from queries import changes as changes_accepted_queries
from typing import List, Dict
from Routes.Auth.cookie import get_user_id
from fastapi import Request

router = APIRouter(prefix="/changes", tags=["user-changes"])


def get_required_details_from_course(row: tuple):
    return (row[0], row[2], row[3], row[5])


@router.get('/')
async def get_all_changes_to_be_accepted(request: Request, acad_period: str) -> List[Slot_Change]:
    user_id = get_user_id(request)
    try:
        query = timetable_queries.get_registered_course_details(
            user_id, acad_period)
        with conn.cursor() as cur:

            cur.execute(query)

            # registered_courses contains all the registered courses of given user
            registered_courses = list(
                map(get_required_details_from_course, cur.fetchall()))
            course_codes = [course[2] for course in registered_courses]
            
            
            # accepted courses
            query = changes_accepted_queries.get_all_accepted_courses(user_id, acad_period)
            cur.execute(query)
            accepted_courses = cur.fetchall()
            accepted_courses = [ (course[1], course[3]) for course in accepted_courses ]
            
            # available changes
            query = cr_queries.get_CR_changes(course_codes=course_codes, acad_period=acad_period)
            cur.execute(query)
            slot_updates = cur.fetchall()
            slot_updates = [update for update in slot_updates if (update[0], update[2]) not in accepted_courses]
            
            
            slot_changes = [Slot_Change.from_row(row) for row in slot_updates]
            return slot_changes


    except (ForeignKeyViolation, InFailedSqlTransaction) as e:  # if some course doesn't exist
        conn.rollback()
        raise HTTPException(
            status_code=404, detail=f"Foreign Key Violdated : {e}")
    except HTTPException as e:
        conn.rollback()
        raise e
    except Exception as e:
        conn.rollback()
        raise HTTPException(
            status_code=500, detail=f"Internal Server Error : {e}")


@router.delete('/')
async def delete_change(request: Request, change: Changes_Accepted)  -> Dict[str, str]:
    user_id = get_user_id(request)
    change.user_id = user_id
    try:
        query = changes_accepted_queries.exists(change)

        with conn.cursor() as cur:

            cur.execute(query)
            row_count=cur.rowcount
            if row_count==0:
                raise HTTPException(status_code=404, detail=f"The user is not seeing changes from this cr")
            
            query = changes_accepted_queries.delete_change(change)
            cur.execute(query)
            
            conn.commit()
        
        return {'message':'change successfully deleted'}
    
    except (HTTPException) as e:
        conn.rollback()
        raise e

    except (ForeignKeyViolation, InFailedSqlTransaction) as e:  # if some course doesn't exist
        conn.rollback()
        raise HTTPException(
            status_code=404, detail=f"Accepted Change not Found : {e}")

    except Exception as e:
        conn.rollback()
        raise HTTPException(
            status_code=500, detail=f"Internal Server Error : {type(e)}")


@router.post('/')
async def accept_change(request: Request, change: Changes_Accepted) -> Dict[str, str]:
    user_id = get_user_id(request)
    try:
        query = changes_accepted_queries.exists(change)

        with conn.cursor() as cur:
            cur.execute(query)
            
            row_count=cur.rowcount
            if row_count!=0:
                query = changes_accepted_queries.update_change(change)
                cur.execute(query)
                conn.commit()
                return {'message':'Change successfully updated'}
            
            query = changes_accepted_queries.accept_change(change)
            cur.execute(query)
            conn.commit()
        
        return {'message':'Change successfully accepted'}

    except (ForeignKeyViolation, InFailedSqlTransaction) as e:  # if some course doesn't exist
        conn.rollback()
        raise HTTPException(status_code=404, detail=f"User not Found : {e}")

    except Exception as e:
        conn.rollback()
        raise HTTPException(
            status_code=500, detail=f"Internal Server Error : {type(e)} {e}")
