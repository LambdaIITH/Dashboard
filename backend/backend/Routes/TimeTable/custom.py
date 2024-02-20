from fastapi import APIRouter, HTTPException
from utils import conn
from models import  Course, User, Slot_Change
from queries import timetable as timetable_queries
from psycopg2.errors import ForeignKeyViolation, InFailedSqlTransaction
# from psycopg2.errors import UniqueViolation
from queries import timetable as timetable_queries
from queries import course as course_queries
from queries import user as user_queries
from typing import List, Dict

router = APIRouter(prefix="/custom", tags=["courses"])