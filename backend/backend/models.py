from pydantic import BaseModel, Field
from datetime import datetime
from typing import List, Dict, Optional, Tuple
from queries.lost_and_found import lost_table, found_table, lost_images_table, found_images_table
from enum import Enum


class Course(BaseModel):
    course_code: str
    acad_period: str
    course_name: str
    segment: str
    slot: str
    credits: int
    custom_slot:  Optional[Dict] = None
    
    @classmethod
    def from_row(cls,row: tuple):
        return Course(course_code=row[0], acad_period=row[1], course_name=row[2], segment=row[3],
                          credits=row[5], slot=row[4])


class User(BaseModel):
    id: int = None
    email: str
    name: str
    cr: bool = False
    phone_number: Optional[str] = None

    @classmethod
    def from_row(cls, row: tuple):
        return cls(id=row[0], email=row[1], name = row[2],  cr=row[3], phone=row[4])


class Register(BaseModel):
    user_id: int
    course_code: str
    acad_period: str
    
    @classmethod
    def from_row(cls, row: tuple):
        return Register(user_id = row[0], course_code = row[1], acad_period=row[2])

class Slot_Change(BaseModel):
    course_code: str
    acad_period:str
    user_id: Optional[int] = None
    slot: Optional[str] = None
    custom_slot : Optional[Dict] = None
    
    @classmethod
    def from_row(cls, row: tuple):
        return Slot_Change(course_code = row[0], acad_period = row[1], user_id = row[2],  slot = row[3], custom_slot = row[4])
 
class cr_Slot_Change(BaseModel):
    course_code: str
    acad_period:str
    user_id: Optional[int] = None
    cr_name: Optional[str] = None
    slot: Optional[str] = None
    custom_slot : Optional[Dict] = None
    
    @classmethod
    def from_row(cls, row: tuple):
        return cr_Slot_Change(course_code = row[0], acad_period = row[1], user_id = row[2], cr_name = None, slot = row[3], custom_slot = row[4])
    
    def from_row_with_name(cls, row:tuple, cr_name: str):
        """
            will be used for responses
        """
        return cr_Slot_Change(course_code = row[0], acad_period = row[1], user_id = None, cr_name = cr_name, slot = row[3], custom_slot = row[4])
    
        

class Timetable(BaseModel):
    user_id: Optional[int] = None
    acad_period: str
    course_codes: List[str]
    
class Changes_Accepted(BaseModel):
    user_id: Optional[int] = None
    course_code: str
    acad_period: str
    cr_id: int

    @classmethod
    def from_row(cls, row: Tuple[int, str, str, int]):
        return Changes_Accepted(user_id=row[0], course_code=row[1], acad_period=row[2], cr_id=row[3])

class Takes(BaseModel):
    course_code: str
    course_name: str
    acad_period: str
    segment: str
    slot: Optional[str] = None
    timings: Optional[Dict] = None

    @classmethod
    def from_row_type1(cls, row: tuple):
        return Takes(course_code=row[0],acad_period= row[1] ,course_name= "", segment="", slot=row[3], timings=row[4])


class LfItem(BaseModel):
    id: int 
    item_name: str
    item_description: str 
    created_at: datetime
    image_urls: Optional[List[str]] = None 
    user_id: int 
    
    @classmethod
    def from_row(cls, row: tuple):
        return LfItem(id=row[0], item_name=row[1], item_description=row[2], created_at=row[3], user_id=row[4])

class LfResponse(BaseModel):
    id: int
    item_name: str
    item_description: str 
    created_at: datetime
    image_urls: List[str] 
    user_email: str
    username: str
    
    @classmethod
    def from_row(cls, row: tuple, image_urls: List[str] ):
        return LfResponse(id = row[0], item_name=row[1], item_description=row[2], created_at=row[3], image_urls=image_urls,user_email=row[6], username=row[7])
    
class image_info(BaseModel):
    id: int
    image_url: str
    item_id: int  
    
    @classmethod
    def from_row(cls, row:tuple):
        return image_info(id = row[0], image_url= row[1],  item_id = row[3])


class Slot_Key(BaseModel):
    course_code: str
    acad_period: str
    user_id: Optional[int] = None


class TableType(Enum):
    LOST = lost_table
    FOUND = found_table
class TableImagesType(Enum):
    LOST = lost_images_table
    FOUND = found_images_table
    
# class Changes_tobe_Accepted(BaseModel):
#     course_code: str
#     course_name: str
#     cr_id: int
#     old_slot: str | None = None
#     new_slot: str | None = None
#     old_timings: Dict | None = None
#     new_timings: Dict | None = None

#     @classmethod
#     def from_row(cls, a: tuple,b: tuple):
#         return Changes_tobe_Accepted(
#             course_code=b[0],
#             course_name=b[1],
#             cr_id=a[2],
#             old_slot=b[3],
#             new_slot=a[3],
#             old_timings=None,
#             new_timings=a[4]
#         )