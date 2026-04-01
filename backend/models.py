from pydantic import BaseModel, Field
from datetime import datetime
from typing import List, Dict, Optional, Tuple
from enum import Enum
from datetime import date


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

    # this User BaseClass does not contain TimeTable Field, but original table does(so does the tuple here)
    @classmethod
    def from_row(cls, row: tuple):
        return cls(id=row[0], email=row[1], name = row[2],  cr=row[3], phone=row[4])




class Timetable(BaseModel):
    """TimeTable Model:
        courses: Mapping of course_code to slots
        slots: List of slots
        custom_slot is a mapping of slot to a mapping of day to timings
    """
    
    courses: Dict[str, Dict[str, str]] = Field(
        default_factory=dict,
        example={"CS101": {"title": "Introduction to Computer Science"}}
    )
    slots: List[Dict[str, str]] = Field(
        default_factory=list,
        example=[
            {
                "course_code": "CS101",
                "day": "Monday",
                "start_time": "9:00 AM",
                "end_time": "10:30 AM"
            }
        ]
    )

    @classmethod
    def from_row(cls, timetable):
        return cls(courses=timetable['courses'], slots=timetable['slots'])


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
    
class SellingItem(BaseModel):
    id: int
    item_name: str
    item_description: str
    selling_price: float
    created_at: datetime
    image_urls: Optional[List[str]] = None
    user_id: int

    @classmethod
    def from_row(cls, row: tuple):
        return SellingItem(id=row[0], item_name=row[1], item_description=row[2],
                           selling_price=float(row[3]), user_id=row[4], created_at=row[5])

class SellingResponse(BaseModel):
    id: int
    item_name: str
    description: str
    selling_price: float
    created_at: str
    images: List[str]
    user_email: str
    username: str
    user_phone_number: Optional[str] = None

    @classmethod
    def from_row(cls, row: tuple, image_urls: List[str]):
        ist_time = row[5].astimezone().isoformat() if row[5] else ""
        # selling table: id[0], item_name[1], item_description[2], selling_price[3], user_id[4], created_at[5]
        # users table (via JOIN): users.id[6], email[7], name[8], cr[9], phone_number[10], timetable[11]
        return SellingResponse(id=row[0], item_name=row[1], description=row[2],
                               selling_price=float(row[3]), created_at=ist_time,
                               images=image_urls, user_email=row[7],
                               username=row[8],
                               user_phone_number=row[10] if len(row) > 10 else None)

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