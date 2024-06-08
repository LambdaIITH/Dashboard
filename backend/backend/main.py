from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from Routes.TimeTable.timetable import router as timetable_router
from Routes.auth import router as auth_router, verify_access_token
from Routes.TimeTable.cr import router as cr_router
from Routes.TimeTable.custom import router as custom_router
from Routes.TimeTable.changes import router as changes_router
from Routes.MessMenu.mess_menu import router as mess_menu_router

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
app.include_router(cr_router)
app.include_router(custom_router)
app.include_router(changes_router)
app.include_router(mess_menu_router)


@app.get("/")
async def root():
    return {"message": "hello dashboard"}


# example of how to use auth in each path operation that leads to protected-data
@app.get("/protected-data", dependencies=[Depends(verify_access_token)])
def get_protected_data():
    return {"user": "verified"}
