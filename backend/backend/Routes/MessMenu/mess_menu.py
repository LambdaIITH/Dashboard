from fastapi import APIRouter, HTTPException
import json
import os
router = APIRouter(prefix="/mess_menu", tags=["mess_menu"])

@router.get("/")
async def get_mess_menu():
    try:    
        dir = os.path.dirname(os.path.realpath(__file__))
        file = open(dir + "/mess.json")
        menu = json.load(file)
        file.close()
        return menu
    except FileNotFoundError:
        raise HTTPException(
            status_code=500, detail="Mess menu file does not exist. Please make one."
        )
