import json
import os
import gspread
import datetime
import re
from oauth2client.service_account import ServiceAccountCredentials

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

log_file_path = os.path.join(os.path.dirname(__file__), "menu_scraper.log")

def log(msg: str):
    try:
        with open(log_file_path, "a") as f:
            f.write(f"{datetime.datetime.now()}: {msg}\n")
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

# Current week (1-4) based on Mondays in month so far
d = datetime.date.today()
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
# 2. Weekly_Menu: recurring items per day/meal/week
# Columns: Day, Meal, WeekPattern, Item
weekly_menu = {day: {meal: [] for meal in MEALS} for day in DAYS}
for row in weekly_menu_data[1:]:
    if len(row) < 4:
        continue
    day, meal, week_pattern, item = map(clean, row[:4])
    if day not in DAYS or meal not in MEALS or not item:
        continue
    if not parse_week_pattern(week_pattern, current_week):
        continue
    weekly_menu[day][meal].extend(parse_items(item))

log(f"Weekly_Menu parsed for week {current_week}")

# -------------------------------------------------------------------------------
# 3. Combine: Daily_Base ∪ Weekly_Menu (deduplicated)
regular_items = {day: {meal: [] for meal in MEALS} for day in DAYS}
for day in DAYS:
    for meal in MEALS:
        seen = set()
        for item in daily_base[meal] + weekly_menu[day][meal]:
            if item not in seen:
                regular_items[day][meal].append(item)
                seen.add(item)

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
special_dinners = {}
for row in special_dinner_data[1:]:
    if len(row) < 2:
        continue
    date_str, items_str = map(clean, row[:2])
    if not date_str or not items_str:
        continue
    # Validate date format (DD-MM-YYYY)
    try:
        datetime.datetime.strptime(date_str, "%d-%m-%Y")
    except ValueError:
        log(f"Invalid date format in Special_Dinner: {date_str}")
        continue
    special_dinners[date_str] = parse_items(items_str)

log(f"Special_Dinner parsed: {len(special_dinners)} entries")

# -------------------------------------------------------------------------------
# Build output (WITHOUT applying special dinner - API will do that at request time)
json_data = {
    "LDH": regular_items,
    "UDH": regular_items,
    "LDH Additional": extra_items,
    "UDH Additional": extra_items,
}

mess_menu_dir = os.path.join(os.path.dirname(__file__), "..", "Routes", "MessMenu")
os.makedirs(mess_menu_dir, exist_ok=True)

# Write only mess.json (reference) and current week file (what API reads)
api_week = (current_week - 1) % 4
for fname in ["mess.json", f"{api_week}.json"]:
    with open(os.path.join(mess_menu_dir, fname), "w") as f:
        json.dump(json_data, f, indent=4)

with open(os.path.join(mess_menu_dir, "config.json"), "w") as f:
    json.dump({"week": api_week}, f, indent=4)

# Write special_dinners.json for API to check at request time
special_file = os.path.join(mess_menu_dir, "special_dinners.json")
with open(special_file, "w") as f:
    json.dump(special_dinners, f, indent=4)

log(f"Done. Week={current_week} (API={api_week}), Date={current_date_str}, Special dinners={len(special_dinners)}")
print(f"Scraper completed. Week: {current_week}, API week: {api_week}, Date: {current_date_str}")