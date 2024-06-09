# import os
# import requests
# from dotenv import load_dotenv
# from fastapi import APIRouter, Header, HTTPException

# load_dotenv("cred.env")
# CLIENT_ID = os.getenv("CLIENT_ID")
# CLIENT_SECRET = os.getenv("CLIENT_SECRET")

# router = APIRouter(
#     prefix="/auth",
#     tags=["auth"]
# )


# @router.post("/get_new_access_token")
# def generate_access_token_from_refresh_token(refresh_token: str = Header(None , alias="refresh_token")):
#     token_url = "https://oauth2.googleapis.com/token"

#     params = {
#         "client_id": CLIENT_ID,
#         "client_secret": CLIENT_SECRET,
#         "access_type": "offline",
#         "grant_type": "refresh_token",
#         "refresh_token": refresh_token
#     }

#     try:
#         response = requests.post(token_url, data=params)
#         response_data = response.json()

#         if response.status_code == 200:
#             return response_data.get("access_token")
#         else:
#             return response_data

#     except Exception as e:
#         print("Error refreshing access token:", str(e))
#         return {"error": e}


# @router.get("/verify_access_token")
# def verify_access_token(access_token: str = Header(None, alias="access_token")):
#     if access_token is None: 
#         raise HTTPException(status_code=401, detail="Access token is required")

#     token_info_endpoint_url = f"https://oauth2.googleapis.com/tokeninfo?access_token={access_token}"
#     try:
#         response = requests.get(token_info_endpoint_url)
#         if response.status_code != 200:
#             raise HTTPException(status_code=401, detail="Invalid Access Token")

#         return True
#     except:
#         raise HTTPException(status_code=401, detail="Invalid Access Token")
