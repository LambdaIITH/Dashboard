import json
import os
import gspread
import numpy
import string
import datetime
from oauth2client.service_account import ServiceAccountCredentials

# -------------------------------------------------------------------------------
# What week is now? (1/2/3/4) (for deciding which menu to use)
d = datetime.date.today()
current_week = (
    d.isocalendar()[1] - datetime.date(d.year, d.month, 1).isocalendar()[1] + 1
)

# -------------------------------------------------------------------------------
# Get sheets
scope = [
    "https://www.googleapis.com/auth/spreadsheets",
    "https://www.googleapis.com/auth/drive",
    "https://www.googleapis.com/auth/feeds"
]
filename = os.path.join(os.path.dirname(__file__), "credentials.json")
creds = ServiceAccountCredentials.from_json_keyfile_name(filename, scope)
print(creds.access_token)
gc = gspread.authorize(creds)

# gc = gspread.oauth()

sheet_link = 'https://docs.google.com/spreadsheets/d/1XVqmsPvTO1ssypLAlAE2M7qLII-8zLPA/'
sh = gc.open_by_url(sheet_link)

print(sh)