import json
import os
import sys
import fcntl
import gspread
import datetime
from oauth2client.service_account import ServiceAccountCredentials

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

# -------------------------------------------------------------------------------
# Timezone: IST (Asia/Kolkata)
try:
    IST = datetime.timezone(datetime.timedelta(hours=5, minutes=30))
except AttributeError:
    # Python < 3.9 fallback
    import time
    IST = datetime.timezone(datetime.timedelta(hours=5, minutes=30))

def now_ist() -> datetime.datetime:
    return datetime.datetime.now(IST)

def today_ist() -> datetime.date:
    return now_ist().date()

# -------------------------------------------------------------------------------
# Lock file to prevent concurrent scraper runs
LOCK_FILE = "/tmp/menu_scraper.lock"
lock_fp = open(LOCK_FILE, "w")
try:
    fcntl.flock(lock_fp, fcntl.LOCK_EX | fcntl.LOCK_NB)
except BlockingIOError:
    print("Another scraper instance is running, exiting")
    sys.exit(0)

# -------------------------------------------------------------------------------
log_file_path = os.path.join(os.path.dirname(__file__), "menu_scraper.log")

def log(msg: str):
    try:
        with open(log_file_path, "a") as f:
            f.write(f"{now_ist().isoformat()}: {msg}\n")
    except Exception:
        pass

# -------------------------------------------------------------------------------
log("Script started")

# Environment variables
SHEET_URL = os.environ.get("GOOGLE_SHEET_URL")
if not SHEET_URL:
    log("ERROR: GOOGLE_SHEET_URL not set in environment")
    raise ValueError("GOOGLE_SHEET_URL environment variable is required")

WEBHOOK_TOKEN = os.environ.get("SHEETS_WEBHOOK_TOKEN", "")  # For potential future use

# Current week (1-4) based on Mondays in month so far (IST)
d = today_ist()
start_date = datetime.date(d.year, d.month, 1)
num_mondays = sum(1 for i in range((d - start_date).days + 1) 
                  if (start_date + datetime.timedelta(days=i)).weekday() == 0)
current_week = (num_mondays % 4) or 4
current_date_str = d.strftime("%d-%m-%Y")

log(f"Current week: {current_week}, Date: {current_date_str}")

# -------------------------------------------------------------------------------
# Google Sheets auth
scope = [
    "https://www.googleapis.com/auth/spreadsheets",
    "https://www.googleapis.com/auth/drive",
]
creds_path = os.path.join(os.path.dirname(__file__), "credentials.json")
if not os.path.exists(creds_path):
    log(f"ERROR: credentials.json not found at {creds_path}")
    raise FileNotFoundError(f"credentials.json not found at {creds_path}")

creds = ServiceAccountCredentials.from_json_keyfile_name(creds_path, scope)
gc = gspread.authorize(creds)

sh = gc.open_by_url(SHEET_URL)

# -------------------------------------------------------------------------------
# Load sheets (no ID column in any sheet)
weekly_menu_data = sh.worksheet("Weekly_Menu").get_all_values()
daily_base_data = sh.worksheet("Daily_Base").get_all_values()
extras_menu_data = sh.worksheet("Extras_Menu").get_all_values()
special_dinner_data = sh.worksheet("Special_Dinner").get_all_values()

# Optional: Public sheet fallback (for testing without credentials.json):
# import re, urllib.request, csv, io
# sheet_match = re.search(r"/spreadsheets/d/([a-zA-Z0-9-_]+)", SHEET_URL)
# if sheet_match:
#     sheet_id = sheet_match.group(1)
#     def fetch_public_tab(tab_name: str) -> list:
#         url = f"https://docs.google.com/spreadsheets/d/{sheet_id}/gviz/tq?tqx=out:csv&sheet={tab_name}"
#         req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
#         with urllib.request.urlopen(req) as resp:
#             return list(csv.reader(io.StringIO(resp.read().decode("utf-8"))))
#     weekly_menu_data = fetch_public_tab("Weekly_Menu")
#     daily_base_data = fetch_public_tab("Daily_Base")
#     extras_menu_data = fetch_public_tab("Extras_Menu")
#     special_dinner_data = fetch_public_tab("Special_Dinner")

DAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
MEALS = ["Breakfast", "Lunch", "Snacks", "Dinner"]

def clean(text: str) -> str:
    return text.strip() if text else ""

def parse_week_pattern(pattern: str, week: int) -> bool:
    pattern = pattern.strip()
    if pattern == "All Weeks":
        return True
    elif pattern == "Week 1 & 3":
        return week in (1, 3)
    elif pattern == "Week 2 & 4":
        return week in (2, 4)
    return False

def parse_items(text: str) -> list:
    """
    Parse items split by comma, semicolon, plus, or newline.
    Does NOT split on delimiters inside parentheses.
    Example: "Sambar (Carrot, Drumstick), Rice" -> ["Sambar (Carrot, Drumstick)", "Rice"]
    """
    text = text.strip()
    if not text:
        return []
    
    items = []
    current = []
    paren_depth = 0
    
    for char in text:
        if char == '(':
            paren_depth += 1
            current.append(char)
        elif char == ')':
            paren_depth = max(0, paren_depth - 1)
            current.append(char)
        elif paren_depth == 0 and char in ',;+\n':
            # Delimiter outside parentheses
            item = ''.join(current).strip()
            if item:
                items.append(item)
            current = []
        else:
            current.append(char)
    
    # Last token
    item = ''.join(current).strip()
    if item:
        items.append(item)
    
    return items

# -------------------------------------------------------------------------------
# 1. Daily_Base: standing items per meal (every day)
# Columns: Meal, Item
daily_base = {meal: [] for meal in MEALS}
for row in daily_base_data[1:]:  # Skip header
    if len(row) >= 2:
        meal = clean(row[0])
        item = clean(row[1])
        if meal in MEALS and item:
            daily_base[meal].extend(parse_items(item))

log(f"Daily_Base parsed: { {m: len(v) for m, v in daily_base.items()} }")

# -------------------------------------------------------------------------------
# 2 & 3. Build Regular Items per week (Daily_Base ∪ Weekly_Menu, deduplicated)
def build_regular_items_for_week(target_week: int) -> dict:
    weekly_menu = {day: {meal: [] for meal in MEALS} for day in DAYS}
    for row in weekly_menu_data[1:]:
        if len(row) < 4:
            continue
        day, meal, week_pattern, item = map(clean, row[:4])
        if day not in DAYS or meal not in MEALS or not item:
            continue
        if not parse_week_pattern(week_pattern, target_week):
            continue
        weekly_menu[day][meal].extend(parse_items(item))

    regular_items = {day: {meal: [] for meal in MEALS} for day in DAYS}
    for day in DAYS:
        for meal in MEALS:
            seen = set()
            for item in daily_base[meal] + weekly_menu[day][meal]:
                if item not in seen:
                    regular_items[day][meal].append(item)
                    seen.add(item)
    return regular_items

log(f"Weekly_Menu parser initialized for week {current_week}")

# -------------------------------------------------------------------------------
# 4. Extras_Menu: paid add-ons per day AND meal
# Columns: Day, Meal, Item, Price (Rs)
extra_items = {day: {meal: [] for meal in MEALS} for day in DAYS}
for row in extras_menu_data[1:]:
    if len(row) < 4:
        continue
    day, meal, item, price = map(clean, row[:4])
    if day not in DAYS or meal not in MEALS or not item:
        continue
    # Format: "Item (Rs. Price)" if price is valid
    if price and not price.lower().startswith("price"):
        formatted = f"{item} (Rs. {price})"
    else:
        formatted = item
    extra_items[day][meal].append(formatted)

log(f"Extras_Menu parsed: { {d: {m: len(v) for m, v in meals.items()} for d, meals in extra_items.items()} }")

# -------------------------------------------------------------------------------
# 5. Special_Dinner: date-specific dinner overrides
# Columns: Date (DD-MM-YYYY), Items
# Parse ALL special dinners, store in special_dinners.json for API to apply at request time
# FILTER OUT PAST DATES
special_dinners = {}
today = today_ist()
for row in special_dinner_data[1:]:
    if len(row) < 2:
        continue
    date_str, items_str = map(clean, row[:2])
    if not date_str or not items_str:
        continue
    # Validate date format (DD-MM-YYYY)
    try:
        parsed_date = datetime.datetime.strptime(date_str, "%d-%m-%Y").date()
    except ValueError:
        log(f"Invalid date format in Special_Dinner: {date_str}")
        continue
    # Only keep today and future dates
    if parsed_date < today:
        log(f"Skipping past special dinner: {date_str}")
        continue
    special_dinners[date_str] = parse_items(items_str)

log(f"Special_Dinner parsed: {len(special_dinners)} entries (past dates filtered)")

# -------------------------------------------------------------------------------
# Build and write outputs
mess_menu_dir = os.path.join(os.path.dirname(__file__), "..", "Routes", "MessMenu")
os.makedirs(mess_menu_dir, exist_ok=True)

# Write all 4 week files (0.json, 1.json, 2.json, 3.json)
for w in range(1, 5):
    api_w = (w - 1) % 4
    week_regular = build_regular_items_for_week(w)
    week_data = {
        "LDH": week_regular,
        "UDH": week_regular,
        "LDH Additional": extra_items,
        "UDH Additional": extra_items,
    }
    with open(os.path.join(mess_menu_dir, f"{api_w}.json"), "w") as f:
        json.dump(week_data, f, indent=4)

# Write mess.json for current week reference
api_week = (current_week - 1) % 4
current_regular = build_regular_items_for_week(current_week)
current_json_data = {
    "LDH": current_regular,
    "UDH": current_regular,
    "LDH Additional": extra_items,
    "UDH Additional": extra_items,
}
with open(os.path.join(mess_menu_dir, "mess.json"), "w") as f:
    json.dump(current_json_data, f, indent=4)

# Write config.json with current calculated week (auto-sync)
config_file = os.path.join(mess_menu_dir, "config.json")
with open(config_file, "w") as f:
    json.dump({"week": api_week}, f, indent=4)
log(f"Updated config.json with calculated week={api_week}")

# Write special_dinners.json for API to check at request time
special_file = os.path.join(mess_menu_dir, "special_dinners.json")
with open(special_file, "w") as f:
    json.dump(special_dinners, f, indent=4)

log(f"Done. Week={current_week} (API={api_week}), Date={current_date_str}, Special dinners={len(special_dinners)}")
print(f"Scraper completed. Week: {current_week}, API week: {api_week}, Date: {current_date_str}")