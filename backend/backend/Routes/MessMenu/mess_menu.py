from fastapi import APIRouter, HTTPException
import json

router = APIRouter(prefix="/mess_menu", tags=["mess_menu"])


@router.get("/")
async def get_mess_menu():
    try:
        file = open("mess.json")
        menu = json.load(file)
        file.close()
        return menu
    except FileNotFoundError:
        return HTTPException(
            status_code=500, detail="Mess menu file does not exist. Please make one."
        )
