import os
import re
import requests
from dotenv import load_dotenv
from google.oauth2 import id_token
from google.auth.exceptions import GoogleAuthError
from Routes.Auth.tokens import generate_token
from models import User
from utils import conn
from queries import user as user_queries
from pypika import Query
from queries.user import users

load_dotenv()

client_id = os.getenv("GOOGLE_CLIENT_ID")

def verify_id_token(token):
    # return True, {"email": "ms22btech11010@iith.ac.in", "name": "Bhaskar"}
    request = requests.Request()
    
    try:
        id_info = id_token.verify_oauth2_token(token, request, client_id)
        return True, id_info
    except GoogleAuthError as e:
        return False, f"Token verification failed: {e}"

def handle_login(id_token):
    ok, data = verify_id_token(id_token)
    if not ok:
        return False, "", {"error": "Invalid ID token", "status": 401}

    if not is_valid_iith_email(data["email"]):
        return False, "", {"error": "Please use an IITH email", "status": 401}

    exists, user_id = is_user_exists(data["email"])
    if not exists:
        user_id = insert_user(email=data["email"], name=data["name"])

    token = generate_token(user_id)
    return True, token, {"id": user_id, "email": data["email"]}

def is_valid_iith_email(email):
    pattern = r'^[a-zA-Z0-9._%+-]+@(?:[a-zA-Z0-9-]+\.)?iith\.ac\.in$'
    return re.match(pattern, email) is not None

def insert_user(email: str, name: str):
    with conn.cursor() as cursor:
        try:
            insert_query = user_queries.post_user(email, name)
            cursor.execute(insert_query)
            conn.commit()
            select_query = Query.from_(users).select(users.id).where(users.email == email)
            cursor.execute(select_query.get_sql())
            user_id = cursor.fetchone()[0]
            return user_id
        except Exception as e:
            conn.rollback()
            raise

def is_user_exists(email: str):
    with conn.cursor() as cursor:
        try:
            query = Query.from_(users).select(users.id).where(users.email == email)
            cursor.execute(query.get_sql())
            result = cursor.fetchone()
            return (True, result[0]) if result else (False, None)
        except Exception as e:
            raise

