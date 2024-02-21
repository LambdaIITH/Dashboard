from pydantic import BaseModel, Field
from datetime import datetime
from typing import List, Dict


class Course(BaseModel):
    course_code: str
    acad_period: str
    course_name: str
    segment: str
    slot: str
    credits: int
    custom_slot:  Dict | None = None
    
    @classmethod
    def from_row(row: tuple):
        return Course(course_code=row[0], acad_period=row[1], course_name=row[2], segment=row[3],
                          credits=row[5], slot=row[4])


class User(BaseModel):
    id: int
    email: str
    cr: bool = False
    
    @classmethod
    def from_row(row: tuple):
        return User(id = row[0], email = row[1], cr = row[2])


class Register(BaseModel):
    user_id: int
    course_code: str
    acad_period: str
    
    @classmethod
    def from_row(row: tuple):
        return Register(user_id = row[0], course_code = row[1], acad_period=row[2])

class Slot_Change(BaseModel):
    course_code: str
    acad_period:str
    user_id: int | None = None
    cr_name: str | None = None
    slot: str |None = None
    custom_slot : Dict | None = None
    
    @classmethod
    def from_row(row: tuple, cr_name :str = None):
        return Slot_Change(course_code = row[0], acad_period = row[1], user_id = row[2], cr_name = cr_name, slot = row[3], custom_slot = row[4])
    
    def from_row_with_name(row:tuple, cr_name: str):
        return Slot_Change(course_code = row[0], acad_period = row[1], user_id = None, cr_name = cr_name, slot = row[3], custom_slot = row[4])
    
    

class Timetable(BaseModel):
    user_id: int
    acad_period: str
    course_codes: List[str]
    
    
