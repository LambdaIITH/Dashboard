from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from models import Course
from utils import conn
from queries import timetable as course_queries
from Routes.timetable import router as timetable_router

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

# include routers
app.include_router(timetable_router)


@app.get("/")
async def root():
    return {"message": "hello dashboard"}


@app.get("/courses")
def get_course(course_code: str, acad_period: str) -> Course:
    try:
        query = course_queries.get_course(course_code, acad_period)

        with conn.cursor() as cur:
            cur.execute(query)

            if cur.rowcount == 0:
                raise HTTPException(status_code=404, detail="Course not Found")

            if cur.rowcount > 1:
                raise HTTPException(status_code=500, detail="Multiple courses found")

            row = cur.fetchone()
            assert row is not None  # true since rowcount > 0 (adding because of linter warning)

            return Course(course_code=row[0], acad_period=row[1], course_name=row[2], segment=row[3],
                          credits=row[5], slot=row[4])

    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Internal Server Error: {e}')
