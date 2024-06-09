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
from pypika import  Query
from queries.user import users

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


def handle_login(id_token):
    ok, data = verify_id_token(id_token)

    if ok is False :
        return False, {"error": "Invalid Id token", "status": 401}
    
    if not is_valid_iith_email(data["email"]):
        return False, {"error": "Please Try IITH email", "status": 401}
    
    exists, user_id, stored_refresh_token = is_user_exists(data["email"])
    
    if exists:
        # User already exists, use the existing refresh token
        refresh_token = stored_refresh_token
    else:
        # Insert new user into the database
        refresh_token = generate_refresh_token(data["email"])
        new_user = User(email=data["email"], refresh_token=refresh_token)
        user_id = insert_user(new_user)
    
    # generating at
    access_token = generate_access_token(user_id)

    return True, {"id": user_id, "access_token": access_token, "refresh_token": refresh_token, "email": data["email"]}


def is_valid_iith_email(email):
    pattern = r'^[a-zA-Z0-9._%+-]+@(?:[a-zA-Z0-9-]+\.)?iith\.ac\.in$'
    return re.match(pattern, email) is not None

def insert_user(user: User):
    cursor = conn.cursor()
    try:
        insert_query = user_queries.post_user(user)
        cursor.execute(insert_query)
        conn.commit()
    except Exception as e:
        conn.rollback()
        raise
    try:
        # Retrieve the user ID of the newly inserted user
        select_query = Query.from_(users).select(users.id).where(users.email == user.email)
        cursor.execute(select_query.get_sql())
        user_id = cursor.fetchone()[0]
        return user_id
    except Exception as e:
        raise
    finally:
        cursor.close()
        
def is_user_exists(email: str):
    cursor = conn.cursor()
    try:
        query = Query.from_(users).select(users.id, users.refresh_token).where(users.email == email)
        cursor.execute(query.get_sql())
        result = cursor.fetchone()
        if result:
            return True, result[0], result[1]
        else:
            return False, None, None
    except Exception as e:
        raise
    finally:
        cursor.close()
