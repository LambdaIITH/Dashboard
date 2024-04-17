from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from Routes.Auth.auth import handle_login
from Routes.Auth.tokens import generate_access_token, verify_refresh_token

router = APIRouter(
    prefix="/auth1",
    tags=["auth1"]
)

class LoginRequest(BaseModel):
    id_token: str

class AccessTokenRequest(BaseModel):
    refresh_token: str
    user_id: int

@router.post("/login")
def login(login_request: LoginRequest):
    id_token = login_request.id_token
    status, msg = handle_login(id_token)

    if status:
        return msg
    else:
        raise HTTPException(status_code=401, detail=msg)
    
@router.post("/access_token") # for new access token
def refresh_access_token(at_req: AccessTokenRequest):
    rt = at_req.refresh_token
    id = at_req.user_id

    ok, msg = verify_refresh_token(rt, id)

    if ok :
        new_at = generate_access_token(id)
        return {"access_token": new_at, "refresh_token": rt}
    else:
        return HTTPException(status_code=401, detail=msg)
