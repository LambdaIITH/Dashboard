from Routes.Auth.cookie import get_user_id
from utils import queries
from fastapi import APIRouter, HTTPException, Response, Depends
from models import User
from pydantic import BaseModel
from Routes.User.user import get_user, update_phone

router = APIRouter(
    prefix="/user",
    tags=["user"]
)

class UserUpdate(BaseModel):
    phone_number: str

@router.get("/", response_model=User)
async def user(user_id: int = Depends(get_user_id)):
    """
    Get user details by user_id.
    """
    user_details = get_user(user_id=user_id)
    if not user_details:
        raise HTTPException(status_code=404, detail="User not found")
    return user_details

@router.patch("/update", response_model=User)
async def update_user(user_update: UserUpdate, user_id: int = Depends(get_user_id)):
    """
    Update user's phone number by user_id.
    """
    existing_user = get_user(user_id=user_id)
    if not existing_user:
        raise HTTPException(status_code=404, detail="User not found")

    updated_user = update_phone(user_id=user_id, phone=user_update.phone_number)
    if not updated_user:
        raise HTTPException(status_code=500, detail="Error updating user")
    return updated_user