import time
import firebase_admin
from firebase_admin import credentials, messaging
from utils import conn
from concurrent.futures import ThreadPoolExecutor, as_completed

# Initialize Firebase Admin SDK only once
if not firebase_admin._apps:
    cred = credentials.Certificate("serviceAccount.json")
    firebase_admin.initialize_app(cred)

def send_personalized_fcm_notification(token, title, body, image_url=None, redirect_url=None, notification_type=None, extra_data=None):
    """Sends an FCM notification to a specific device with data payload support."""
    data_payload = {
        "data":{
            "redirectURL": redirect_url or "",  
            "open": notification_type or "home",
            "timestamp": str(int(time.time()))
        }
    }

    if extra_data:
        data_payload.update(extra_data)

    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
            image=image_url
        ),
        data=data_payload,
        token=token,
    )

    try:
        response = messaging.send(message)
        print(f"Successfully sent message: {title}")
        return response
    except Exception as e:
        print(f"Error sending FCM notification: {e}, {title}")
        return None

def get_all_fcm_tokens(test = True):
    """Fetches all FCM tokens from the database."""
    tokens = []
    if test:
        query = "SELECT fcm.token, u.name FROM fcm_tokens fcm JOIN users u ON fcm.user_id = u.id where u.id in (1, 41)"
    else: 
        query = "SELECT fcm.token, u.name FROM fcm_tokens fcm JOIN users u ON fcm.user_id = u.id"

    try:
        with conn.cursor() as cursor:
            cursor.execute(query)
            tokens = cursor.fetchall()
        return tokens
    except Exception as e:
        print(f"Database error: {e}")
        return []

def send_notifications_to_all_users(title, body, image_url=None, test=True, redirect_url=None, notification_type=None, extra_data=None):
    """Sends an FCM notification to all users."""
    tokens = get_all_fcm_tokens(test=test)

    max_workers = 30

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = []
        for token, name in tokens:
            personalized_title = title.replace("%name%", name.split()[0])
            personalized_body = body.replace("%name%", name.split()[0])
            futures.append(executor.submit(send_personalized_fcm_notification, token, personalized_title, personalized_body, image_url,redirect_url, notification_type, extra_data ))

        for future in as_completed(futures):
            try:
                future.result()
            except Exception as e:
                print(f"Error in sending notification: {e}")


def send_fcm_cab_notifications(token: str, title: str, description: str):
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=description,
        ),
        token=token,
        data = {
            "redirectUrl": "",  
            "open": "cabsharing",
            "timestamp": str(int(time.time()))
        }
    )
    try:
        response = messaging.send(message)
        print(f"Successfully sent message: {title}")
        return response
    except Exception as e:
        print(f"Error sending FCM notification: {e}, {title}")
        return None