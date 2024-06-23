from datetime import datetime

from pydantic import BaseModel, Field


class Email(BaseModel):
    email: str


class UserDetails(BaseModel):
    phone_number: str


MAX_CAPACITY = 25


class Booking(BaseModel):
    start_time: datetime
    end_time: datetime
    capacity: int = Field(le=MAX_CAPACITY)
    from_loc: str
    to_loc: str
    comments: str


class BookingUpdate(BaseModel):
    start_time: datetime
    end_time: datetime


class JoinBooking(BaseModel):
    comments: str


class RequestResponse(BaseModel):
    requester_email: str
