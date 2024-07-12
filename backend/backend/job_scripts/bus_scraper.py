import json
import os
import gspread
import numpy
import string
import datetime
from oauth2client.service_account import ServiceAccountCredentials
from functools import reduce

# -------------------------------------------------------------------------------
# What week is now? (1/2/3/4) (for deciding which menu to use)
d = datetime.date.today()
current_week = (
    d.isocalendar()[1] - datetime.date(d.year, d.month, 1).isocalendar()[1] + 1
)

# -------------------------------------------------------------------------------
# Get sheets
scope = ["https://spreadsheets.google.com/feeds",
         'https://www.googleapis.com/auth/spreadsheets',
         "https://www.googleapis.com/auth/drive.file",
         "https://www.googleapis.com/auth/drive"
]

filename = os.path.join(os.path.dirname(__file__), "credentials.json")
creds = ServiceAccountCredentials.from_json_keyfile_name(filename, scope)
gc = gspread.authorize(creds)

# gc = gspread.oauth()

sheet_link = 'https://docs.google.com/spreadsheets/d/1mLrLAf6Z0Z4G2AsAzrK7TXJ_DZAPXb_3n6V_jKTx1wc/'
sh = gc.open_by_url(sheet_link)

sheet = sh.worksheet('Transport Schedule')

# fetching bus data
bus_directions = sheet.col_values(1)[2:]
bus_unique_directions = reduce(lambda x, y: x if y in x else x + [y], [[], ] + bus_directions)

# initializing bus_data
bus_data = {
    bus_unique_directions[i]: [] for i in range(len(bus_unique_directions))}

unusable_data_points = ['', ' ', '-', 'Break']

time_values = []
# fetching bus data from columns

from datetime import datetime
for bus_num in range(1, 4):
    bus = sheet.col_values(bus_num + 1)[2:]
    for i, time in enumerate(bus):
        if time not in unusable_data_points:
            try:
                time_mod = datetime.strptime(time, "%H:%M:%S").time()
                bus_data[bus_directions[i]].append(time_mod)
            except:
                pass
            
bus_data = {key: sorted(value) for key, value in bus_data.items()}
bus_data = {key: [str(value) for value in values] for key, values in bus_data.items()}


# writing into a json file
outname = os.path.dirname(__file__) + "/../Routes/Bus/bus.json"

import json
with open(outname, 'w') as f:
    json.dump(bus_data, f, indent = 2)

