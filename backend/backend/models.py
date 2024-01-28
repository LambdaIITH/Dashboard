from pydantic import BaseModel, Field
from datetime import datetime
from typing import List
class Course(BaseModel):
    course_code: str
    acad_period: str
    course_name: str
    segment: str
    credits: int

class User(BaseModel):
    email: str
    cr : bool

class Register(BaseModel):
    user_id: int
    course_code: str
    acad_period: str

class Timetable(BaseModel):
    id: int
    acad_period: str
    course_codes: List[str]