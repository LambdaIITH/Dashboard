from pydantic import BaseModel, Field
from datetime import datetime

class Courses(BaseModel):
    course_code: str
    acad_period: str
    course_name: str

class Users(BaseModel):
    id: int
    email: str

class Register(BaseModel):
    user_id: int
    course_code: str
    acad_period: str
    