import os
import jwt
from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv


load_dotenv()
at_secret = os.getenv("ACCESS_TOKEN_SECRET")
rt_secret = os.getenv("REFRESH_TOKEN_SECRET")


def generate_access_token(user_id):
    duration = timedelta(hours=24*7) # Expire in 7 days
    
    exp_time = datetime.now(tz=timezone.utc) + duration
    
    access_Token = jwt.encode(
        {"sub": user_id, "exp": exp_time}, 
        at_secret, 
        algorithm="HS256"
    )
    return access_Token

def verify_access_token(access_token):
    try:
        decoded_token = jwt.decode(
            access_token, 
            at_secret, 
            algorithms=["HS256"]
        )
        return True, decoded_token
    except jwt.ExpiredSignatureError:
        return False, "Token has expired"
    except jwt.InvalidTokenError:
        return False, "Invalid token"
    
def generate_refresh_token(email):
    return jwt.encode(
        {"sub": email}, 
        rt_secret, 
        algorithm="HS256"
    )

def verify_refresh_token(refresh_token, user_id):
    try:
        decoded_token = jwt.decode(
            refresh_token, 
            rt_secret, 
            algorithms=["HS256"]
        )

        #TODO: `SELECT refresh_token FROM Users WHERE id = {user_id}` 
        # and if both are same then return TRUE, otherwise 401

        return True , "" # TODO: change it

    except jwt.ExpiredSignatureError:
        return False, "Token has expired"
    except jwt.InvalidTokenError:
        return False, "Invalid token"

