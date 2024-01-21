from fastapi import FastAPI, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from models import *
import utils

load_dotenv()

app = FastAPI()

# TODO: change for prod
origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/courses/")
async def get_course(course_code: str, acad_period: str):
    return utils.get_course(course_code, acad_period)


@app.get("/timetable/")
async def get_timetable(id: int, acad_period: str):
    return utils.get_timetable(id,acad_period)


@app.post("/timetable/")
async def edit_timetable(timetable: Timetable):
    utils.post_timetable(timetable.email,timetable.course_codes,timetable.acad_period)
    return JSONResponse(status_code=200)

@app.get("/")
async def root():
    return {"message": "Hello World"}
