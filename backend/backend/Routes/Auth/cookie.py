
import jwt
from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv
import os
from fastapi import Response

load_dotenv()
secret = os.getenv("TOKEN_SECRET")

def set_cookie(response: Response, key: str, value: str, days_expire=15):
    expires = datetime.now(timezone.utc) + timedelta(days=days_expire)
    response.set_cookie(
        key=key,
        value=value,
        expires=expires,
        httponly=True,
        secure=False,
        # samesite='Lax',
        domain='localhost',
        # path='/',
        max_age=days_expire * 24 * 60 * 60 
    )
