from Routes.Auth.cookie import set_cookie
from fastapi import APIRouter, HTTPException, Response
from pydantic import BaseModel
from Routes.Auth.auth import handle_login
from fastapi.responses import JSONResponse

router = APIRouter(
    prefix="/auth",
    tags=["auth"]
)

class LoginRequest(BaseModel):
    id_token: str

class AccessTokenRequest(BaseModel):
    refresh_token: str
    user_id: int

@router.post("/login")
def login(login_request: LoginRequest, response: Response):
    id_token = login_request.id_token
    status, token,  msg = handle_login(id_token)

    if status:
        response = JSONResponse(content=msg)
        set_cookie(response, key="session", value=token)
        return response
    else:
        raise HTTPException(status_code=401, detail=msg)
