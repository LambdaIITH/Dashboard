from fastapi import FastAPI, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from models import *
from utils import conn
from queries import course_queries

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



@app.get("/courses/{user_id}")
def get_course(course_code : str, acad_period : str, user_id : int, response: Response):
    try:
        query =course_queries.get_course(Register(user_id=user_id, course_code=course_code, acad_period=acad_period))
        result = []
        with conn.cursor() as cur:
            cur.execute(query)
            conn.commit()
            
            if cur.rowcount == 0:
                return HTTPException(status_code=404, detail="Course not Registered")

            if cur.rowcount > 1:
                raise Exception()
            
            response.status_code = 200
            
            
            
            
            
            
            
    except Exception as e:
        return HTTPException(status_code=500, detail= f'Internal Server Error: {e}')



@app.get("/timetable/")
async def get_timetable(id: int, acad_period: str):
    try:
        return get_course(course_code, acad_period)
    except Exception as e:
        return HTTPException(status_code=500, detail="Internal Server Error")


@app.post("/timetable/")
async def edit_timetable(timetable: Timetable, response: Response):
    try:
        return get_course(course_code, acad_period)
    except Exception as e:
        return HTTPException(status_code=500, detail="Internal Server Error")
    
    response.status_code = 200
    return query
    
    

@app.get("/")
async def root(response: Response):
    response.status_code = 200
    return {"message" : "hello dashboard"}
