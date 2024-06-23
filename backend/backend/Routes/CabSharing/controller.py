import logging
from datetime import datetime
from typing import Dict, List, Union

from Routes.Auth.cookie import get_user_id
from fastapi import Depends, FastAPI, HTTPException, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from pytz import timezone
from utils import conn, queries
from queries.user import get_user_email
import Routes.CabSharing.schemas as schemas

from Routes.CabSharing.cab import (
    CustomFormatter,
    get_bookings,
    send_email,
    verify_exists,
)

app = APIRouter(
    prefix="/cabshare",
    tags=["cabshare"]
)

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

console_handler = logging.FileHandler("logs/error.log")
console_handler.setLevel(logging.ERROR)
console_handler.setFormatter(CustomFormatter())

logger.addHandler(console_handler)


# app = FastAPI()

# origins = [
#     "https://iith.dev",
#     "https://iithdashboard.com",
#     "http://localhost",
#     "http://localhost:3000",
# ]

# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=origins,
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )


@app.get("/")
async def read_root():
    return {"Hello": "World"}


@app.get("/me")
async def check_auth(user_id: str = Depends(get_user_id)):
    """
    Test Endpoint to validate user identity
    """
    #get email
    email = get_user_email(conn, user_id)
    
    phone_number = queries.get_phone_number(conn, email=email)
    return {"phone_number": phone_number}


# @app.post("/me")
# async def create_user(
#     details: schemas.UserDetails, emailname=Depends(verify_auth_token_with_name)
# ):
#     """
#     Create a new User.
#     """
#     email, name = emailname
#     try:
#         queries.insert_user(
#             conn, email=email, name=name, phone_number=details.phone_number
#         )
#         conn.commit()
#     except Exception as e:
#         logger.error(e, exc_info=True)
#         conn.rollback()
#         raise HTTPException(status_code=500, detail="Internal Server Error")


@app.post("/bookings")
async def create_booking(
    booking: schemas.Booking, user_id: str = Depends(get_user_id)
):
    """
    Create a new Booking.
    """
    #get email
    email = get_user_email(conn, user_id)
    # get respected ids for locations
    from_id = queries.get_loc_id(conn, place=booking.from_loc)
    to_id = queries.get_loc_id(conn, place=booking.to_loc)
    if from_id is None or to_id is None:
        raise HTTPException(status_code=400, detail="Invalid Location")

    verify_exists(email)

    try:
        booking_id = queries.create_booking(
            conn,
            start_time=booking.start_time.astimezone(timezone("Asia/Kolkata")),
            end_time=booking.end_time.astimezone(timezone("Asia/Kolkata")),
            capacity=booking.capacity,
            from_loc=from_id,
            to_loc=to_id,
            owner_email=email,
            comments=booking.comments,
        )

        queries.add_traveller(
            conn, cab_id=booking_id, email=email, comments=booking.comments
        )
        conn.commit()
        send_email(email, "create", booking_id)
    except Exception as e:
        logger.error(e, exc_info=True)

        conn.rollback()
        raise HTTPException(status_code=500, detail="Internal Server Error")


@app.patch("/bookings/{booking_id}")
async def update_booking(
    booking_id: int,
    patch: schemas.BookingUpdate,
    user_id: str = Depends(get_user_id),
):
    """
    Update a Booking Time. (currently unused in frontend, so doesn't send emails)
    """
    #get email
    email = get_user_email(conn, user_id)

    verify_exists(email)

    owner_email = queries.get_owner_email(conn, cab_id=booking_id)
    if owner_email is None:
        raise HTTPException(status_code=400, detail="Invalid Booking ID")
    elif owner_email != email:
        raise HTTPException(status_code=403, detail="Unauthorized")

    try:

        queries.update_booking(
            conn,
            start_time=patch.start_time.astimezone(timezone("Asia/Kolkata")),
            end_time=patch.end_time.astimezone(timezone("Asia/Kolkata")),
            cab_id=booking_id,
        )
        conn.commit()
    except HTTPException as e:
        raise e
    except Exception as e:
        logger.error(e, exc_info=True)
        conn.rollback()
        raise HTTPException(status_code=500, detail="Internal Server Error")

    # TODO: Send Email to Travellers


@app.get("/me/bookings")
async def user_bookings(user_id: str = Depends(get_user_id)):
    """
    Get Bookings where the authenticated user is a traveller
    """
    #get email
    email = get_user_email(conn, user_id)
    
    res1 = queries.get_user_past_bookings(conn, email=email)
    res2 = queries.get_user_future_bookings(conn, email=email)
    user_bookings_dict = {}
    user_bookings_dict["past_bookings"] = get_bookings(res1, email)
    user_bookings_dict["future_bookings"] = get_bookings(res2, email)

    return user_bookings_dict


@app.get("/me/requests")
async def user_requests(user_id: str = Depends(get_user_id)):
    """
    Get Pending requests sent by the authenticated user
    """
    #get email
    email = get_user_email(conn, user_id)
    
    res = queries.get_user_pending_requests(conn, email=email)
    requested_bookings = get_bookings(res)

    return requested_bookings


@app.get("/bookings")
async def search_bookings(
    from_loc: Union[str, None] = None,
    to_loc: Union[str, None] = None,
    start_time: Union[datetime, None] = None,
    end_time: Union[datetime, None] = None,
    user_id: str = Depends(get_user_id),
) -> List[Dict]:
    """
    Search Bookings by locations and time
    """

    start_time = start_time or datetime.fromisoformat("1970-01-01T00:00:00+05:30")
    end_time = end_time or datetime.fromisoformat("2100-01-01T00:00:00+05:30")

    if (from_loc is None) ^ (to_loc is None):
        raise HTTPException(
            status_code=400, detail="Cannot search with only one location"
        )
    elif from_loc is None and to_loc is None:
        res = queries.filter_times(conn, start_time=start_time, end_time=end_time)
    else:
        from_id = queries.get_loc_id(conn, place=from_loc)
        to_id = queries.get_loc_id(conn, place=to_loc)

        if from_id is None or to_id is None:
            raise HTTPException(status_code=400, detail="Invalid Filter Location")

        res = queries.filter_all(
            conn,
            from_loc=from_id,
            to_loc=to_id,
            start_time=start_time,
            end_time=end_time,
        )

    bookings = get_bookings(res)

    return bookings


@app.post("/bookings/{booking_id}/request")
async def request_to_join_booking(
    booking_id: int,
    join_booking: schemas.JoinBooking,
    user_id: str = Depends(get_user_id),
):
    """
    A function for a new person to place a request to join an existing booking
    """
    #get email
    email = get_user_email(conn, user_id)

    owner_email = queries.get_owner_email(conn, cab_id=booking_id)
    if owner_email is None:
        # booking doesn't exist
        raise HTTPException(status_code=400, detail="Invalid Ride ID")
    elif owner_email == email:
        # user is owner
        raise HTTPException(status_code=400, detail="You cannot join your own ride")

    verify_exists(email)

    if queries.is_cab_full(conn, cab_id=booking_id):
        raise HTTPException(status_code=400, detail="Ride is full")

    # check if request already sent
    request_status = queries.get_request_status(
        conn, booking_id=booking_id, email=email
    )
    if request_status is not None:
        if request_status == "pending":
            detail = "Request already sent"
        elif request_status == "accepted":
            detail = "You are already a traveller"
        elif request_status == "cancelled":
            detail = "Request already cancelled"
        else:
            # request_status == "rejected"
            detail = "Request already rejected"
        raise HTTPException(status_code=400, detail=detail)

    try:
        queries.create_request(
            conn,
            booking_id=booking_id,
            email=email,
            comments=join_booking.comments,
        )
        owner_email = queries.get_owner_email(conn, cab_id=booking_id)
        phone = queries.get_phone_number(conn, email=email)
        name = queries.get_name(conn, email=email)
        send_email(
            owner_email,
            "request",
            booking_id,
            x_requester_name=name,
            x_requester_phone=phone,
            x_requester_email=email,
        )
        conn.commit()
    except Exception as e:
        logger.error(e, exc_info=True)
        conn.rollback()
        raise HTTPException(status_code=500, detail="Internal Server Error")


@app.delete("/bookings/{booking_id}/request")
async def delete_request(booking_id: int, user_id: str = Depends(get_user_id)):
    """
    To delete a person's request to join booking
    """
    #get email
    email = get_user_email(conn, user_id)
    
    request_status = queries.get_request_status(
        conn, booking_id=booking_id, email=email
    )
    if request_status != "pending":
        raise HTTPException(status_code=400, detail="No pending request found")

    try:
        queries.delete_request(conn, cab_id=booking_id, email=email)
        conn.commit()
    except Exception as e:
        logger.error(e, exc_info=True)
        conn.rollback()
        raise HTTPException(status_code=500, detail="Internal Server Error")


@app.post("/bookings/{booking_id}/accept")
async def accept_request(
    booking_id: int,
    response: schemas.RequestResponse,
    user_id: str = Depends(get_user_id),
):
    """
    To accept a person's request to join booking
    """
    #get email
    email = get_user_email(conn, user_id)
    
    owner_email = queries.get_owner_email(conn, cab_id=booking_id)
    if owner_email is None:
        raise HTTPException(status_code=400, detail="Booking does not exist")
    elif owner_email != email:
        raise HTTPException(
            status_code=403, detail="You are not the owner of this booking"
        )

    if queries.is_cab_full(conn, cab_id=booking_id):
        raise HTTPException(status_code=400, detail="Cab is already full")

    status = queries.get_request_status(
        conn, booking_id=booking_id, email=response.requester_email
    )
    if status != "pending":
        raise HTTPException(status_code=400, detail="No pending request found")

    try:
        comments = queries.update_request(
            conn,
            booking_id=booking_id,
            request_email=response.requester_email,
            val="accepted",
        )
        if comments is None:
            raise HTTPException(
                status_code=400, detail="There is no pending request to accept"
            )

        queries.add_traveller(
            conn,
            cab_id=booking_id,
            email=response.requester_email,
            comments=comments,
        )

        conn.commit()
    except HTTPException as e:
        raise e
    except Exception as e:
        logger.error(e, exc_info=True)
        conn.rollback()
        raise HTTPException(status_code=500, detail="Internal Server Error")

    send_email(response.requester_email, "accept", booking_id)

    name = queries.get_name(conn, email=response.requester_email)
    phone = queries.get_phone_number(conn, email=response.requester_email)

    travellers = queries.get_travellers(conn, cab_id=booking_id)
    for traveller in travellers:
        traveller_email = traveller[0]
        if traveller_email == response.requester_email:
            continue
        send_email(
            traveller_email,
            "accept_notif",
            booking_id,
            x_accepted_email=response.requester_email,
            x_accepted_name=name,
            x_accepted_phone=phone,
        )


@app.post("/bookings/{booking_id}/reject")
async def reject_request(
    booking_id: int,
    response: schemas.RequestResponse,
    user_id: str = Depends(get_user_id),
):
    """
    To reject a person's request to join booking
    """
    #get email
    email = get_user_email(conn, user_id)
    
    owner_email = queries.get_owner_email(conn, cab_id=booking_id)
    if owner_email is None:
        raise HTTPException(status_code=400, detail="Ride does not exist")
    elif owner_email != email:
        raise HTTPException(
            status_code=403, detail="You are not the owner of this booking"
        )

    try:
        res = queries.update_request(
            conn,
            booking_id=booking_id,
            request_email=response.requester_email,
            val="rejected",
        )
        if res is None:
            raise HTTPException(status_code=400, detail="No pending request found")

        conn.commit()
    except HTTPException as e:
        raise e
    except Exception as e:
        logger.error(e, exc_info=True)
        conn.rollback()
        raise HTTPException(status_code=500, detail="Internal Server Error")

    send_email(response.requester_email, "reject", booking_id)


@app.delete("/bookings/{booking_id}")
async def delete_existing_booking(
    booking_id: int, user_id: str = Depends(get_user_id)
):
    """
    Delete a Particular booking
    """
    #get email
    email = get_user_email(conn, user_id)
    
    owner_email = queries.get_owner_email(conn, cab_id=booking_id)
    if owner_email is None:
        raise HTTPException(status_code=400, detail="Booking does not exist")
    elif owner_email != email:
        raise HTTPException(
            status_code=403, detail="You are not the owner of this booking"
        )

    try:
        travellers = queries.get_travellers(conn, cab_id=booking_id)
        for traveller in travellers:
            traveller_email = traveller[0]
            send_email(traveller_email, "delete_notif", booking_id)
        queries.delete_booking(conn, cab_id=booking_id)
        conn.commit()
    except Exception as e:
        logger.error(e, exc_info=True)
        conn.rollback()
        raise HTTPException(status_code=500, detail="Internal Server Error")


@app.delete("/bookings/{booking_id}/self")
async def exit_booking(booking_id: int, user_id: str = Depends(get_user_id),):
    """
    For a user to exit from a booking (owner cannot exit)
    """
    #get email
    email = get_user_email(conn, user_id)
    
    owner_email = queries.get_owner_email(conn, cab_id=booking_id)
    if owner_email is None:
        raise HTTPException(status_code=400, detail="Ride does not exist")
    elif owner_email == email:
        raise HTTPException(
            status_code=400, detail="Owner cannot exit a ride, but you can delete it"
        )

    try:
        queries.delete_particular_traveller(
            conn, cab_id=booking_id, email=email, owner_email=owner_email
        )
        conn.commit()
    except Exception as e:
        logger.error(e, exc_info=True)
        conn.rollback()
        raise HTTPException(status_code=500, detail="Internal Server Error")

    # confimation email to exiting user
    send_email(email, "exit", booking_id)

    name = queries.get_name(conn, email=email)

    travellers = queries.get_travellers(conn, cab_id=booking_id)
    for traveller in travellers:
        traveller_email = traveller[0]
        send_email(
            traveller_email,
            "exit_notif",
            booking_id,
            x_exited_email=email,
            x_exited_name=name,
        )


# if __name__ == "__main__":
#     import uvicorn

#     uvicorn.run(app, host="0.0.0.0", port=8000)
