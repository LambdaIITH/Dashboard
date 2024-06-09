import os
import requests
from google.oauth2 import id_token
from google.auth.transport import requests
from dotenv import load_dotenv
from google.auth.exceptions import GoogleAuthError
from Routes.Auth.tokens import generate_access_token, generate_refresh_token

load_dotenv()

client_id = os.getenv("GOOGLE_CLIENT_ID")

def verify_id_token(token):
    request = requests.Request()
    
    try:
        id_info = id_token.verify_oauth2_token(
            token, request, client_id)
        
        return True, id_info

    except GoogleAuthError as e:
        return False, f"Token verification failed: {e}"

#TODO implement for exsiting user also
def handle_login(id_token):
    ok, data = verify_id_token(id_token)

    if ok is False :
        return False, {"error": "Invalid Id token", "status": 401}
    
    if data["hd"] != "iith.ac.in" :
        return False, {"error": "Please Try IITH email", "status": 401}
    
    # generating rt
    refresh_token = generate_refresh_token(data["email"])

    # TODO: add user to the database, and get the id
    user_id = 1 # TODO change it

    # generating at
    access_token = generate_access_token(user_id)

    return True, {"id": user_id, "access_token": access_token, "refresh_token": refresh_token}

