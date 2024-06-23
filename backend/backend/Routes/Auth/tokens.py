import os
import jwt
from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv
from queries import user as user_queries
from utils import conn

load_dotenv()
secret = os.getenv("TOKEN_SECRET")

def generate_token(user_id):
    duration = timedelta(days=15) # Expire in 15 days
    
    exp_time = datetime.now(tz=timezone.utc) + duration
    
    token = jwt.encode(
        {"sub": user_id, "exp": exp_time}, 
        secret, 
        algorithm="HS256"
    )
    return token

def verify_token(token):
    try:
        decoded_token = jwt.decode(
            token, 
            secret, 
            algorithms=["HS256"]
        )
        return True, decoded_token
    except jwt.ExpiredSignatureError:
        return False, "Token has expired"
    except jwt.InvalidTokenError:
        return False, "Invalid token"
