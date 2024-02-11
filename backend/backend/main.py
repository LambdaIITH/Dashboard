from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from Routes.timetable import router as timetable_router
from Routes.auth import router as auth_router, verify_access_token 
from Routes.courses import router as courses_router

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
app.include_router(auth_router)
app.include_router(courses_router)
@app.get("/")
async def root():
    return {"message": "hello dashboard"}


# example of how to use auth in each path operation that leads to protected-data
@app.get("/protected-data" , dependencies=[ Depends(verify_access_token)])
def get_protected_data(): 
    return {"user" : "verified"}