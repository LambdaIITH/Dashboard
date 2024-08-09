import json
import os
import gspread
import numpy
import string
import datetime
from oauth2client.service_account import ServiceAccountCredentials
from functools import reduce
from datetime import datetime

log_file_path = os.path.join(os.path.dirname(__file__), "transport_scraper.log")

# -------------------------------------------------------------------------------
# Adding Logs with file open
try:
    with open(log_file_path, "a") as log_file:
        log_file.write(f"Script executed at: {datetime.now()}\n")
except Exception as e:
    with open(log_file_path, "a") as log_file:
        log_file.write(f"Error opening log file: {str(e)}\n")


# -------------------------------------------------------------------------------

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

#! fetching bus data-----------------------------------------------------
bus_directions = sheet.col_values(1)[2:]
bus_unique_directions = reduce(lambda x, y: x if y in x else x + [y], [[], ] + bus_directions)

# initializing bus_data
bus_data = {
    bus_unique_directions[i]: [] for i in range(len(bus_unique_directions))}

unusable_data_points = ['', ' ', '-', 'Break']

# fetching bus data from columns

for bus_num in range(1, 4):
    bus = sheet.col_values(bus_num + 1)[2:]
    for i, time in enumerate(bus):
        if time not in unusable_data_points:
            try:
                time_mod = datetime.strptime(time, "%H:%M:%S").time()
                bus_data[bus_directions[i]].append(time_mod)
            except:
                print("Error on:", time)
                pass
            
bus_data = {key: sorted(value) for key, value in bus_data.items()}
bus_data = {key: [str(value) for value in values] for key, values in bus_data.items()}

#! fetching EV data----------------------------------------------------------
EV_directions = sheet.col_values(6)[2:]
EV_unique_directions = reduce(lambda x, y: x if y in x else x + [y], [[], ] + EV_directions)
EV_times = sheet.col_values(7)[2:]

EV_data = {EV_unique_directions[i]: [] for i in range(len(EV_unique_directions))}


# fetch ev data from columns
for i, time in enumerate(EV_times):
    if time not in unusable_data_points:
        try:
            time_mod = datetime.strptime(time, "%H:%M:%S").time()
            EV_data[EV_directions[i]].append(time_mod)
        except:
            print("Error on:", time)
            pass
        
EV_data = {key: sorted(value) for key, value in EV_data.items()}
EV_data = {key: [str(value) for value in values] for key, values in EV_data.items()}



# writing into a json file
outname = os.path.dirname(__file__) + "/../Routes/Transport/transport.json"
out_json = {
    "bus": bus_data,
    "EV": EV_data
}
import json
with open(outname, 'w') as f:
    json.dump(out_json, f, indent = 2)

