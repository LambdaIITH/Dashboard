import os
import requests
from google.oauth2 import id_token
from google.auth.transport import requests
from dotenv import load_dotenv
from google.auth.exceptions import GoogleAuthError
from Routes.Auth.tokens import generate_access_token, generate_refresh_token
import re
from models import User
from utils import conn
from queries import user as user_queries

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
    
    if not is_valid_iith_email(data["email"]):
        return False, {"error": "Please Try IITH email", "status": 401}
    
    # if data["hd"] != "iith.ac.in" :
    #     return False, {"error": "Please Try IITH email", "status": 401}
    
    # generating rt
    refresh_token = generate_refresh_token(data["email"])
    
    #insert user into db
    new_user = User(email=data["email"], refresh_token=refresh_token)
    user_id = insert_user(new_user)
    
    # generating at
    access_token = generate_access_token(user_id)

    return True, {"id": user_id, "access_token": access_token, "refresh_token": refresh_token, "email": new_user.email}


def is_valid_iith_email(email):
    pattern = r'^[a-zA-Z0-9._%+-]+@(?:[a-zA-Z0-9-]+\.)?iith\.ac\.in$'
    return re.match(pattern, email) is not None

def insert_user(user: User):
    cursor = conn.cursor()
    insert_query = user_queries.post_user(user)
    cursor.execute(insert_query)
    user_id = cursor.fetchone()[0] 
    conn.commit()
    return user_id