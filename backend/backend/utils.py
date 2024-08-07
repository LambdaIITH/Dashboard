import os

# from fastapi import UploadFile
import aiosql
import psycopg2
from dotenv import load_dotenv
from typing import List
import boto3
from typing import Dict,List
from external_services import ElasticsearchManager, S3Manager

load_dotenv()

DATABASE = os.getenv("DATABASE")
POSTGRES_USER = os.getenv("POSTGRES_USER")
POSTGRES_PASS = os.getenv("POSTGRES_PASS")
POSTGRES_HOST = os.getenv("POSTGRES_HOST")
POSTGRES_PORT = os.getenv("POSTGRES_PORT")

try: 
    conn = psycopg2.connect(
        database=DATABASE,
        user=POSTGRES_USER,
        password=POSTGRES_PASS,
        host=POSTGRES_HOST,
        port=POSTGRES_PORT,
    )
    print( "\nConnected Successfully!\n")
except:
    print("Connection Failed")

print("Opened database successfully!")
queries = aiosql.from_path("sql", "psycopg2")

conn.autocommit = False
# For more clarity, you can define nested types:
Courses = Dict[str, str]
SlotDetails = Dict[str, str]
Slots = Dict[str, SlotDetails]

TimeTable = Dict[Courses, Slots]
