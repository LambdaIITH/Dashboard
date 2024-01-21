from pydantic import BaseModel, Field
from datetime import datetime

class Courses(BaseModel):
    course_code: str
    acad_period: str
    course_name: str

class Users(BaseModel):
    email: str

class Register(BaseModel):
    user_email: str
    course_code: str
    acad_period: str

class Timetable(BaseModel):
    email: str
    acad_period: str
    course_codes: [str]