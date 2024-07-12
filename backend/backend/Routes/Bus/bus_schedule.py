from fastapi import APIRouter, HTTPException
import json
import os
router = APIRouter(prefix="/bus_schdule", tags=["bus_schedule"])

@router.get("/")
async def get_bus_schedule():
    try:    
        dir = os.path.dirname(os.path.realpath(__file__))
        file = open(dir + "/bus.json")
        menu = json.load(file)
        file.close()
        return menu
    except FileNotFoundError:
        raise HTTPException(
            status_code=500, detail="Bus Schdule file does not exist. Please make one."
        )
