from fastapi import APIRouter, HTTPException, Request
from utils import conn
from models import Timetable, Course, Takes
from queries import timetable as timetable_queries
from queries import course as course_queries
from queries import custom as custom_queries
from queries import changes as changes_queries
from psycopg2.errors import ForeignKeyViolation, InFailedSqlTransaction
from typing import List
from Routes.Auth.cookie import get_user_id
router = APIRouter(prefix="/timetable", tags=["timetable"])


def get_required_details_from_course(row: tuple):
    return (row[1], row[2], 0 , row[7], None) # course_code, acad_period, cr_id(none), slot, Custom(none here)


@router.get("/")
async def get_timetable(request: Request, acad_period: str) -> List[Takes]:
    user_id = get_user_id(request)
    try:
        query = timetable_queries.get_registered_course_details(user_id, acad_period)

        with conn.cursor() as cur:

            # getting registered courses
            cur.execute(query)
            registeredCourses = list(map(get_required_details_from_course ,cur.fetchall()))
            registeredCourseCodes = [course[0] for course in registeredCourses]
            
            # getting custom courses
            query = custom_queries.get_all_custom_courses(user_id, acad_period)
            cur.execute(query)
            customCourses = cur.fetchall()
            customCourseCodes = [course[0] for course in customCourses]
            
            # getting accepted courses
            query = changes_queries.get_all_accepted_changes(user_id, acad_period)
            cur.execute(query)
            acceptedCourses = cur.fetchall()
            acceptedCodes = [course[0] for course in acceptedCourses]
            
            courses = [Takes.from_row_type1(row) for row in registeredCourses]
            
            for course in courses:
                if course.course_code in acceptedCodes:
                    course.slot = acceptedCourses[acceptedCodes.index(course.course_code)][3]
                    course.timings = acceptedCourses[acceptedCodes.index(course.course_code)][4]

                if course.course_code in customCourseCodes:
                    course.slot = customCourses[customCourseCodes.index(course.course_code)][3]
                    course.timings = customCourses[customCourseCodes.index(course.course_code)][4]
            
            courses.extend([Takes.from_row_type1(row) for row in customCourses if row[0] not in registeredCourseCodes])
            print(courses)
            # TODO TO ADD COURSE NAMES AND SEGMENTS
            return courses

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal Server Error : {e}")


@router.post("/")  # the route also works to update the timetable
async def update_timetable(request: Request, timetable: Timetable):

    try:
        user_id = get_user_id(request)
        timetable.user_id = user_id
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
        raise e

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal Server Error : {type(e)} : {e}")
