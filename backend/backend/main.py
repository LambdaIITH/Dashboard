from fastapi import Depends, FastAPI, HTTPException, Request
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
app.include_router(auth_router1)
app.include_router(cr_router)
app.include_router(custom_router)
app.include_router(changes_router)
app.include_router(mess_menu_router)


user_id = -1

async def token_verification_middleware(request: Request, call_next):
    global user_id
    authorization = request.headers.get("Authorization")
    if authorization:
        scheme, token = authorization.split()
        if scheme.lower() != "bearer":
            return JSONResponse(status_code=401, content={"detail": "Invalid authorization scheme"})
        status, data = verify_access_token(token)
        if status is False:
            return JSONResponse(status_code=401, content={"detail": data})
        user_id = data["sub"] # Updating user_id 
    else:
        return JSONResponse(status_code=401, content={"detail": "Authorization header is missing"})

    response = await call_next(request)
    return response


@app.middleware("http")
async def apply_middleware(request: Request, call_next):
    excluded_routes = ["/auth1/login", "/auth1/access_token"]  # Add routes to exclude guard here

    if request.url.path not in excluded_routes:
        return await token_verification_middleware(request, call_next)
    else:
        response = await call_next(request)
        return response

@app.get("/")
async def root():
    return {"message": "hello dashboard"}


# example of how to use auth in each path operation that leads to protected-data
@app.get("/protected-data", dependencies=[Depends(verify_access_token)])
def get_protected_data():
    return {"user": "verified"}
