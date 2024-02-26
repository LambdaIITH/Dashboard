from fastapi import APIRouter, HTTPException
from utils import conn
from models import Timetable, Course, Takes
from queries import timetable as timetable_queries
from queries import course as course_queries
from queries import custom as custom_queries
from queries import changes as changes_queries
from psycopg2.errors import ForeignKeyViolation, InFailedSqlTransaction
from typing import List

router = APIRouter(prefix="/timetable", tags=["timetable"])


def get_required_details_from_course(row: tuple):
    return (row[0], row[2], row[3], row[4])


@router.get("/{user_id}")
async def get_timetable(user_id: int, acad_period: str) -> List[Takes]:
    try:
        query = timetable_queries.get_registered_course_details(user_id, acad_period)

        with conn.cursor() as cur:

            # getting registered courses
            cur.execute(query)
            registeredCourses = list(map(get_required_details_from_course ,cur.fetchall()))

            # getting custom courses
            query = custom_queries.get_all_custom_courses(user_id, acad_period)
            cur.execute(query)
            customCourses = cur.fetchall()

            # getting accepted courses
            query = changes_queries.get_all_accepted_changes(user_id, acad_period)
            cur.execute(query)
            acceptedCourses = cur.fetchall()

            answer = []

            for row in acceptedCourses:
                for i, registered_course in enumerate(registeredCourses):
                    if registered_course[0] == row[0]:
                        a=registered_course
                        a[4]=row[4]
                        answer.append(Takes.from_row(a))
                        del registeredCourses[i]
                        break
            
            for row in customCourses:
                for i, registered_course in enumerate(registeredCourses):
                    if registered_course[0] == row[0]:
                        a=registered_course
                        a[4]=row[4]
                        answer.append(Takes.from_row(a))
                        del registeredCourses[i]
                        break
            
            for i in registeredCourses:
                answer.append(i)
            
            return answer
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal Server Error : {e}")


@router.post("/")  # the route also works to update the timetable
async def update_timetable(timetable: Timetable):

    try:
        user_id = timetable.user_id
        acad_period = timetable.acad_period
        query = timetable_queries.get_allRegisteredCourses(user_id, acad_period)
        timetable.course_codes = list(set(timetable.course_codes))  # having unique courses
        with conn.cursor() as cur:  # for transaction
            cur.execute(query)
            rows = cur.fetchall()
            courses = [row[0] for row in rows]
            removal = [course for course in timetable.course_codes if course  in courses]
            
            removal = list(set(removal))
            for course in removal:
                courses.remove(course)
                timetable.course_codes.remove(course)
           
            
            if len(timetable.course_codes) == 0 and len(courses) == 0:  # if no courses are to be added or deleted
                raise HTTPException(status_code=400, detail="No Changes Made")

            if len(courses) != 0:  # if some courses are to be deleted
                query = timetable_queries.delete_timeTable(
                    Timetable(user_id=user_id, acad_period=acad_period, course_codes=courses))
                cur.execute(query)
            

            if len(timetable.course_codes) != 0:  # if some courses are to be added
                query = timetable_queries.post_timeTable(timetable)
                cur.execute(query)
            conn.commit()
        return {"message": "Courses Updated Successfully"}
    except HTTPException as e:
        conn.rollback()
        raise e

    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Internal Server Error : {type(e)} : {e}")
