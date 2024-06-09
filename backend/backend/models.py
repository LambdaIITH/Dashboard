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
    def from_row(cls,row: tuple):
        return Course(course_code=row[0], acad_period=row[1], course_name=row[2], segment=row[3],
                          credits=row[5], slot=row[4])


class User(BaseModel):
    id: int = None
    email: str
    cr: bool = False
    refresh_token: str
    
    @classmethod
    def from_row(cls, row: tuple):
        return User(id = row[0], email = row[1], cr = row[2], refresh_token=row[3])


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
    user_id: int
    slot: str |None = None
    custom_slot : Dict | None = None
    
    @classmethod
    def from_row(cls, row: tuple):
        return Slot_Change(course_code = row[0], acad_period = row[1], user_id = row[2],  slot = row[3], custom_slot = row[4])
 
class cr_Slot_Change(BaseModel):
    course_code: str
    acad_period:str
    user_id: int | None = None
    cr_name: str | None = None
    slot: str |None = None
    custom_slot : Dict | None = None
    
    @classmethod
    def from_row(cls, row: tuple, cr_name :str = None):
        return cr_Slot_Change(course_code = row[0], acad_period = row[1], user_id = row[2], cr_name = cr_name, slot = row[3], custom_slot = row[4])
    
    def from_row_with_name(cls, row:tuple, cr_name: str):
        return cr_Slot_Change(course_code = row[0], acad_period = row[1], user_id = None, cr_name = cr_name, slot = row[3], custom_slot = row[4])
    
        

class Timetable(BaseModel):
    user_id: int
    acad_period: str
    course_codes: List[str]
    
class Changes_Accepted(BaseModel):
    user_id: int
    course_code: str
    acad_period: str
    cr_id: int

    @classmethod
    def from_row(cls, row: tuple):
        return Changes_Accepted(user_id=row[0], course_code=row[1], acad_period=row[2], cr_id=row[3])

class Takes(BaseModel):
    course_code: str
    course_name: str
    acad_period: str
    segment: str
    slot: str | None = None
    timings: Dict | None = None

    @classmethod
    def from_row_type1(cls, row: tuple):
        return Takes(course_code=row[0],acad_period= row[1] ,course_name= "", segment="", slot=row[3], timings=row[4])


class LfItem(BaseModel):
    id: int
    item_name: str
    item_description: str 
    created_at: datetime
    image_urls: List[str] | None = None 
    
    @classmethod
    def from_row(cls, row: tuple):
        return LfItem(id=row[0], item_name=row[1], item_description=row[2], created_at=row[3])

class LfResponse(BaseModel):
    item_name: str
    item_description: str 
    created_at: datetime
    image_urls: List[str]
    @classmethod
    def from_im_items(cls, item: LfItem):
        return LfResponse(item_name = item.item_name, item_description= item.item_description, created_at= item.created_at, image_urls= item.image_urls)
    
    
class image_info(BaseModel):
    id: int
    image_url: str
    item_id: int  
    
    @classmethod
    def from_row(cls, row:tuple):
        return image_info(id = row[0], image_url= row[1],  item_id = row[3])

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