from fastapi import FastAPI, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from models import *
from utils import conn
from queries import course as course_queries

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



@app.get("/courses")
def get_course(course_code : str, acad_period : str, res: Response) -> Course:
    try:
        query = course_queries.get_course(course_code, acad_period)
        result = []
        
        with conn.cursor() as cur: 
            cur.execute(query)
            conn.commit()
            
            if cur.rowcount == 0:
                return HTTPException(status_code=404, detail="Course not Found")

            if cur.rowcount > 1:
                raise Exception()

            row = cur.fetchone()
            res.status_code = 200  
            return Course(course_code=row[0], acad_period=row[1], course_name=row[2], segment=row[3], credits=row[4])
            
            
            
    except Exception as e:
        return HTTPException(status_code=500, detail= f'Internal Server Error: {e}')



@app.get("/timetable/{user_id}")
async def get_timetable(user_id: int, acad_period: str, res: Response) -> Timetable:
    try:
        query = course_queries.get_timeTable(user_id, acad_period)
        
        
        with conn.cursor() as cur: 
            cur.execute(query)
            conn.commit()

            rows = cur.fetchall()
            res.status_code = 200  
            
            timetable = Timetable(id=user_id, acad_period=acad_period, course_codes=[])
            for row in rows:
                timetable.course_codes.append(row[0])
            
            return timetable
    except Exception as e:
        return HTTPException(status_code=500, detail=f"Internal Server Error : {e}")


# TODO: to be done
@app.post("/timetable")
async def post_timetable(timetable: Timetable, res: Response):
    
    try:
        pass
    except Exception as e:
        return HTTPException(status_code=500, detail="Internal Server Error")
    
    
    
    

@app.get("/")
async def root(response: Response):
    response.status_code = 200
    return {"message" : "hello dashboard"}
