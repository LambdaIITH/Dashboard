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

# -------------------------------------------------------------------------------
# Timezone: IST (Asia/Kolkata)
try:
    IST = datetime.timezone(datetime.timedelta(hours=5, minutes=30))
except AttributeError:
    IST = datetime.timezone(datetime.timedelta(hours=5, minutes=30))

def now_ist() -> datetime.datetime:
    return datetime.datetime.now(IST)

def today_ist() -> datetime.date:
    return now_ist().date()

DAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

def get_today_name() -> str:
    """Get today's day name matching our DAYS array (Sunday=0) in IST."""
    py_wd = today_ist().weekday()  # Mon=0...Sun=6
    return DAYS[0 if py_wd == 6 else py_wd + 1]

def log_api(msg: str):
    """Log API events to menu_scraper.log for unified observability."""
    try:
        log_path = os.path.join(os.path.dirname(__file__), "..", "..", "job_scripts", "menu_scraper.log")
        with open(log_path, "a") as f:
            f.write(f"{now_ist().isoformat()} [API] {msg}\n")
    except Exception:
        pass

class MenuWeekChangeRequest(BaseModel):
    password: str
    number: int

@router.get("/")
async def get_mess_menu():
    try:    
        dir = os.path.dirname(os.path.realpath(__file__))
        with open(dir + "/config.json") as file:
            week = json.load(file)["week"]
        
        with open(dir + f"/{week}.json") as file:
            menu = json.load(file)
        
        # Check for special dinner override for today (IST)
        special_file = os.path.join(dir, "special_dinners.json")
        if os.path.exists(special_file):
            with open(special_file) as f:
                specials = json.load(f)
            today_str = today_ist().strftime("%d-%m-%Y")
            if today_str in specials:
                today_name = get_today_name()
                special_items = specials[today_str]
                # Override dinner for both messes
                if today_name in menu.get("LDH", {}):
                    menu["LDH"][today_name]["Dinner"] = special_items
                if today_name in menu.get("UDH", {}):
                    menu["UDH"][today_name]["Dinner"] = special_items
                log_api(f"Special dinner applied for {today_str} ({today_name}): {len(special_items)} items")
        
        log_api(f"Menu served for week={week}, date={today_ist()}")
        return menu
    except FileNotFoundError as e:
        log_api(f"Menu file not found: {e}")
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
    
    log_api(f"Admin week override: week={admin.number} by user={user_id}")
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
        log_api(f"Webhook rejected: invalid token from {request.client.host if request.client else 'unknown'}")
        raise HTTPException(status_code=401, detail="Invalid webhook token")
    
    log_api(f"Webhook received from {request.client.host if request.client else 'unknown'}, triggering scraper")
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
            log_api(f"Scraper FAILED: {result.stderr[:500]}")
        else:
            log_api(f"Scraper SUCCESS: {result.stdout[:200]}")
    except subprocess.TimeoutExpired:
        log_api("Scraper TIMEOUT after 120 seconds")
    except Exception as e:
        log_api(f"Scraper ERROR: {e}")