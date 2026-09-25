from fastapi import APIRouter, HTTPException, Depends, Request, BackgroundTasks
import json
import os
import datetime
import subprocess
from pydantic import BaseModel
from Routes.Auth.cookie import get_user_id
from Routes.User.user import get_user
from Routes.Auth.tokens import verify_token

router = APIRouter(prefix="/mess_menu", tags=["mess_menu"])
password = os.getenv("ADMIN_PASS")
allowed_numbers = [0,1,2,3]

admins = ["ms22btech11010@iith.ac.in", "lambda@iith.ac.in", "ma22btech11003@iith.ac.in", "cs22btech11017@iith.ac.in", "cs22btech11028@iith.ac.in"]

SHEETS_WEBHOOK_TOKEN = os.getenv("SHEETS_WEBHOOK_TOKEN")

DAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

class MenuWeekChangeRequest(BaseModel):
    password: str
    number: int

def get_today_name() -> str:
    """Get today's day name matching our DAYS array (Sunday=0)."""
    py_wd = datetime.date.today().weekday()  # Mon=0...Sun=6
    return DAYS[0 if py_wd == 6 else py_wd + 1]

@router.get("/")
async def get_mess_menu():
    try:    
        dir = os.path.dirname(os.path.realpath(__file__))
        with open(dir + "/config.json") as file:
            week = json.load(file)["week"]
        
        with open(dir + f"/{week}.json") as file:
            menu = json.load(file)
        
        # Check for special dinner override for today
        special_file = os.path.join(dir, "special_dinners.json")
        if os.path.exists(special_file):
            with open(special_file) as f:
                specials = json.load(f)
            today_str = datetime.date.today().strftime("%d-%m-%Y")
            if today_str in specials:
                today_name = get_today_name()
                special_items = specials[today_str]
                # Override dinner for both messes
                if today_name in menu.get("LDH", {}):
                    menu["LDH"][today_name]["Dinner"] = special_items
                if today_name in menu.get("UDH", {}):
                    menu["UDH"][today_name]["Dinner"] = special_items
        
        return menu
    except FileNotFoundError:
        raise HTTPException(
            status_code=500, detail="Mess menu file does not exist. Please make one."
        )
        

@router.post("/")
async def post_mess_menu(admin: MenuWeekChangeRequest, request: Request):
    isAdmin = False
    user_id = None
        
    try:
        token = request.cookies.get("session")
        if token:
            status, data = verify_token(token)
            if status:
                user_id = data["sub"] 
        
        if user_id:
            user_details = get_user(user_id=user_id)
        if user_details['email'] in admins:
            isAdmin = True
    except HTTPException:
        isAdmin = False 
            
    if not isAdmin and admin.password != password:
        raise HTTPException(status_code=401, detail="Incorrect password")
    
    if admin.number not in allowed_numbers:
        raise HTTPException(status_code=400, detail="Invalid week number")
    
    
    dir = os.path.dirname(os.path.realpath(__file__))
    with open(dir + "/config.json", "w") as file:
        json.dump({"week": admin.number}, file, indent=1)

    return {"message": "Week number updated successfully"}


@router.get("/week")
async def get_current_week_number(request: Request):
    isAdmin = False
    user_id = None
    
    try:
        user_id = get_user_id(request)
        user_details = get_user(user_id=user_id)
        if user_details['email'] in admins:
            isAdmin = True
    except HTTPException:
        isAdmin = False 
    
    if not isAdmin :
        return {"message" :"unauthorized"} 
    try:    
        dir = os.path.dirname(os.path.realpath(__file__))
        with open(dir + "/config.json") as file:
            week = json.load(file)["week"]
            
        return {"week": week}
    except FileNotFoundError:
        raise HTTPException(
            status_code=500, detail="Mess menu file does not exist. Please make one."
        )


@router.post("/webhook/sheets")
async def sheets_webhook(request: Request, background_tasks: BackgroundTasks):
    token = request.headers.get("X-Webhook-Token")
    if SHEETS_WEBHOOK_TOKEN and token != SHEETS_WEBHOOK_TOKEN:
        raise HTTPException(status_code=401, detail="Invalid webhook token")
    
    background_tasks.add_task(run_menu_scraper)
    return {"status": "scraper triggered"}


def run_menu_scraper():
    try:
        base_dir = os.path.dirname(os.path.realpath(__file__))
        scraper_path = os.path.join(base_dir, "..", "..", "job_scripts", "menu_scraper.py")
        result = subprocess.run(
            ["python", scraper_path],
            capture_output=True,
            text=True,
            timeout=120,
            cwd=os.path.join(base_dir, "..", "..")
        )
        if result.returncode != 0:
            print(f"Scraper failed: {result.stderr}")
        else:
            print(f"Scraper completed: {result.stdout}")
    except subprocess.TimeoutExpired:
        print("Scraper timed out after 120 seconds")
    except Exception as e:
        print(f"Scraper error: {e}")
        
