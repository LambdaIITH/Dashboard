import logging
import os
import smtplib
import threading
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from typing import Literal

import html2text
from dotenv import load_dotenv
from fastapi import  HTTPException
from pytz import timezone
from uvicorn.workers import UvicornWorker

from utils import conn


class MyUvicornWorker(UvicornWorker):
    CONFIG_KWARGS = {"log_config": "logging.yml"}


class CustomFormatter(logging.Formatter):

    yellow = "\x1b[33;20m"  # warning
    red = "\x1b[31;20m"  # error
    reset = "\x1b[0m"
    format = (
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s (%(filename)s:%(lineno)d)"
    )

    FORMATS = {
        logging.ERROR: red + format + reset,
    }

    def format(self, record):
        log_fmt = self.FORMATS.get(record.levelno)
        formatter = logging.Formatter(log_fmt)
        return formatter.format(record)


load_dotenv()

# DATABASE = os.getenv("DATABASE")
# POSTGRES_USER = os.getenv("POSTGRES_USER")
# POSTGRES_PASS = os.getenv("POSTGRES_PASS")
# POSTGRES_HOST = os.getenv("POSTGRES_HOST")
# POSTGRES_PORT = os.getenv("POSTGRES_PORT")

GMAIL_USER = os.getenv("GMAIL") or ""
GMAIL_PASSWORD = os.getenv("GMAIL_PASSWORD") or ""

# conn = psycopg2.connect(
#     database=DATABASE,
#     user=POSTGRES_USER,
#     password=POSTGRES_PASS,
#     host=POSTGRES_HOST,
#     port=POSTGRES_PORT,
# )



# ------------------ AUTH ----------------------


# def try_details(Authorization: str):
#     try:
#         details = authn_user(Authorization)
#         if details is None:
#             raise HTTPException(
#                 status_code=498, detail="You are not logged in, please login again."
#             )

#         GSUITE_DOMAIN_NAME = "iith.ac.in"
#         domain = details[0].split("@")[-1]
#         # allow domain or subdomains
#         if domain != GSUITE_DOMAIN_NAME and not domain.endswith(
#             "." + GSUITE_DOMAIN_NAME
#         ):
#             raise HTTPException(
#                 status_code=498, detail="Please use your IITH email address to login."
#             )
#     except exceptions.InvalidValue:
#         raise HTTPException(
#             status_code=498, detail="Token invalid or expired, please login again."
#         )
#     return details


# def verify_auth_token(Authorization: str = Header()):
#     email, name = try_details(Authorization)
#     return email


# def verify_auth_token_with_name(Authorization: str = Header()):
#     email, name = try_details(Authorization)
#     return email, name


# ------------------ AUTH END ------------------


def verify_exists(email):
    phone_number = queries.get_phone_number(conn, email=email)
    if phone_number is None:
        # return 401
        raise HTTPException(status_code=403, detail="Please provide a phone number")


def get_bookings(res, owner_email=None):

    bookings = []
    for tup in res:
        travellers = queries.get_travellers(conn, cab_id=tup[0])
        travellers_list = []

        owner_email = tup[6]

        for traveller in travellers:
            traveller_dict = {
                "email": traveller[0],
                "comments": traveller[1],
                "name": traveller[2],
                "phone_number": traveller[3],
            }
            if owner_email == traveller_dict["email"]:
                travellers_list.insert(0, traveller_dict)
            else:
                travellers_list.append(traveller_dict)

        # convert from utc to ist
        start_time = tup[1].astimezone(timezone("Asia/Kolkata"))
        end_time = tup[2].astimezone(timezone("Asia/Kolkata"))

        booking = {
            "id": tup[0],
            "start_time": start_time.strftime("%Y-%m-%d %H:%M:%S"),
            "end_time": end_time.strftime("%Y-%m-%d %H:%M:%S"),
            "capacity": tup[3],
            "from_": tup[4],
            "to": tup[5],
            "owner_email": owner_email,
            "travellers": travellers_list,
        }

        if owner_email == tup[6]:
            requests = queries.show_requests(conn, cab_id=tup[0])
            requests_list = []
            for request in requests:
                requests_list.append(
                    {
                        "email": request[0],
                        "comments": request[1],
                        "name": request[2],
                        "phone_number": request[3],
                    }
                )
            booking["requests"] = requests_list

        bookings.append(booking)
    return bookings


def send_email(
    receiver: str,
    mail_type: Literal[
        "create",
        "request",
        "accept",
        "accept_notif",
        "reject",
        "exit",
        "exit_notif",
        "delete_notif",
    ],
    booking_id: int,
    **kwargs,
):
    """
    Send an email to the receiver with the given mail_type.

    kwargs are used for mail_type specific substitutions.
    all kwargs must start with "x_", for example x_requester_name, x_exiter_email, etc.
    this is to prevent conflicts, and to make it clear that these are not part of the booking info.
    """

    booking_info = queries.get_booking_details(conn, cab_id=booking_id)
    (
        _,
        start_time,
        end_time,
        capacity,
        from_loc,
        to_loc,
        owner_email,
        owner_name,
        owner_phone,
    ) = booking_info

    def fmt(s: str) -> str:
        return s.format(
            booking_id=booking_id,
            start_time=start_time.strftime("%Y-%m-%d %H:%M"),
            end_time=end_time.strftime("%Y-%m-%d %H:%M"),
            date=start_time.strftime("%d %b %Y"),  # 13 Sep 2023
            capacity=capacity,
            from_loc=from_loc,
            to_loc=to_loc,
            owner_email=owner_email,
            owner_name=owner_name,
            owner_phone=owner_phone,
            **kwargs,  # see docstring
        )

    with open(f"templates/{mail_type}/subject.txt", "r") as f:
        subject = f.read()
    with open(f"templates/{mail_type}/body.html", "r") as f:
        html = f.read()
    subject = fmt(subject)
    # convert html to text before substituting user data
    text = html2text.html2text(html)
    text = fmt(text)
    html = fmt(html)

    message = MIMEMultipart("alternative")
    message["From"] = GMAIL_USER
    message["To"] = receiver
    message["Subject"] = subject
    # need to compose a proper email with accept and reject options
    part1 = MIMEText(text, "plain")
    part2 = MIMEText(html, "html")
    message.attach(part1)
    message.attach(part2)

    def _send(msg):
        try:
            with smtplib.SMTP("smtp.gmail.com", 587) as smtp_server:
                smtp_server.starttls()
                smtp_server.login(GMAIL_USER, GMAIL_PASSWORD)
                smtp_server.send_message(msg)
        except Exception as ex:
            print("Error sending mail:", ex)

    # send email in a separate thread so that the user doesn't have to wait
    threading.Thread(target=_send, args=(message,)).start()
