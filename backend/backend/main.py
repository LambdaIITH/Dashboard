import os
from Routes.Auth.cookie import get_user_id, set_cookie
from Routes.User.user import get_user
from fastapi import Depends, FastAPI, HTTPException, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from dotenv import load_dotenv
from Routes.TimeTable.timetable import router as timetable_router
from Routes.MessMenu.mess_menu import router as mess_menu_router
from Routes.Auth.controller import router as auth_router
from Routes.Lost_and_Found.found import router as found_router
from Routes.Lost_and_Found.lost import router as lost_router
from Routes.Auth.controller import router as auth_router
from Routes.CabSharing.controller import app as cab_router
from Routes.User.controller import router as user_router
from Routes.Auth.tokens import verify_token
from fastapi.responses import JSONResponse
from Routes.Transport.transport_schedule import router as transport_router

load_dotenv()

app = FastAPI()

domains = os.getenv("ALLOWED_DOMAINS", "").split(",")

# TODO: change for prod
origins = [
    "http://localhost:5500",
    "http://localhost:8080",
] + domains

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
app.include_router(mess_menu_router)
app.include_router(found_router)
app.include_router(lost_router)
app.include_router(cab_router)
app.include_router(user_router)
app.include_router(transport_router)

async def cookie_verification_middleware(request: Request, call_next):
    if request.method == "OPTIONS":
        return await call_next(request)
    token = request.cookies.get("session")
    if token:
        status, data = verify_token(token)
        if not status:
            resp = JSONResponse(status_code=401, content={"detail": data})
            set_cookie(value="", days_expire=0, key="session", response=resp)
            return resp
        request.state.user_id = data["sub"]  # Store user_id in request state
    else:
        return JSONResponse(status_code=401, content={"detail": "Session cookie is missing"})
    response = await call_next(request)
    
    #updating the cookie
    set_cookie(response=response, key="session", value=token, days_expire=15)
    return response

@app.middleware("http")
async def apply_middleware(request: Request, call_next):
    excluded_routes = ["/auth/login", "/auth/logout", "/docs", "/openapi.json", "/transport/", "/mess_menu/"]  # Add routes to exclude guard here

    if request.url.path not in excluded_routes:
        return await cookie_verification_middleware(request, call_next)
    else:
        response = await call_next(request)
        return response

@app.get("/")
async def root():
    return {"message": f"hello dashboard"}

@app.options("/{path:path}")
def options_handler(request: Request, path: str):
    return JSONResponse(status_code=200, headers={
        "Access-Control-Allow-Origin": "*", 
        "Access-Control-Allow-Methods": "*", 
        "Access-Control-Allow-Headers": "*", 
    })


@app.get("/protected-data")
def get_protected_data():
    return {"user": "verified"}

@app.get("/session-exists")
def get_session_info(response: Response):
    response = JSONResponse(content={"message": "Session Exists"}, status_code=200)
    return response

@app.get("/main-gate/status")
async def get_main_gate_status(user_id: int = Depends(get_user_id)):
    user_details = get_user(user_id=user_id)
    if not user_details:
        raise HTTPException(status_code=404, detail="User not found")
    
    roll = user_details['email'].split("@")[0].capitalize()
    
    auth_token = os.getenv("AUTH_PASSWORD")
    
    if not auth_token:
        raise HTTPException(status_code=500, detail="Auth token not found")
    
    async with httpx.AsyncClient() as client:
        main_gate_api = os.getenv("MAIN_GATE_API")
    
        if not main_gate_api:
            raise HTTPException(status_code=500, detail="Main Gate API not found")
        
        response = await client.get(f"{main_gate_api}?roll={roll}", headers={"Auth": auth_token})
        
        if response.status_code != 200:
            raise HTTPException(status_code=500, detail="Error fetching status from Main Gate API")

        response_data = response.json()
        
        if response_data.get("message") is not None:
            return response_data, 201
        else:
            return response_data, 200

