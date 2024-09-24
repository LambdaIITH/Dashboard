
# CabShare
This documentation outlines the various API routes for the **CabShare** module, describing the required inputs and expected responses for each route.

## Requirements:
- Send emails on various events on success, like booking creation, request acceptance, etc. Following routes require email notifications:
1. **POST** `/bookings`
2. **POST** `/bookings/{booking_id}/request`
3. **POST** `/bookings/{booking_id}/accept`
4. **POST** `/bookings/{booking_id}/reject`
5. **DELETE** `/bookings/{booking_id}/self`
6. **DELETE** `/bookings/{booking_id}`

## 1. `GET /cabshare/`
- **Description**: Root endpoint to verify the API is operational.
- **Request**: None
- **Response**:
  - `200 OK`
  ```json
  {
    "Hello": "World"
  }```

## 2. `GET /cabshare/me`
- **Description**: Test endpoint to validate user identity by retrieving the authenticated user's phone number.
- **Request Headers**:
  - `Authorization: Bearer <JWT_TOKEN>`
- **Response**:
  - `200 OK`
  ```json
  {
    "phone_number": "1234567890"
  }```

## 3. `POST /cabshare/bookings`
- **Description**: Creates a new booking for a cab share.
- **Request Body**:
  ```json
  {
    "from_loc": "IITH Main Gate",
    "to_loc": "Gachibowli",
    "start_time": "2024-09-22T10:30:00",
    "end_time": "2024-09-22T11:30:00",
    "capacity": 4,
    "comments": "Heading to office"
  }```

## 4. `PATCH /cabshare/bookings/{booking_id}`
- **Description**: Updates the time of an existing booking.
- **Request Parameters**:
  - `booking_id`: ID of the booking to be updated.
- **Request Body**:
  ```json
  {
    "start_time": "2024-09-22T11:00:00",
    "end_time": "2024-09-22T12:00:00"
  }```

## 5. `GET /cabshare/me/bookings`
- **Description**: Retrieves bookings where the authenticated user is a traveler.
- **Response**:
  - `200 OK`
  ```json
  {
    "past_bookings": [/* past booking objects */],
    "future_bookings": [/* future booking objects */]
  }```

## 6. `GET /cabshare/me/requests`
- **Description**: Retrieves pending requests sent by the authenticated user.
- **Response**:
  - `200 OK`: List of pending requests.

## 7. `GET /cabshare/bookings`
- **Description**: Searches for available bookings based on locations and time.
- **Request Parameters (optional)**:
  - `from_loc`: Starting location
  - `to_loc`: Destination location
  - `start_time`: Start time (ISO format)
  - `end_time`: End time (ISO format)
- **Response**:
  - `200 OK`: List of matching bookings.
  - `400 Bad Request`: If only one location is provided.



## 8. `POST /cabshare/bookings/{booking_id}/request`
- **Description**: Requests to join an existing booking.
- **Request Parameters**:
  - `booking_id`: ID of the booking.
- **Request Body**:
  ```json
  {
    "comments": "Looking for a ride to work."
  }```

- **Response**:
    - `200 OK`: Request sent successfully.
    - `400 Bad Request`: Request already sent or booking is full.

## 9. `DELETE /cabshare/bookings/{booking_id}/request`
- **Description**: Deletes a user's request to join a booking.
- **Request Parameters**:
  - `booking_id`: ID of the booking.
- **Response**:
  - `200 OK`: Request deleted successfully.
  - `400 Bad Request`: No pending request found.

## 10. `POST /cabshare/bookings/{booking_id}/accept`
- **Description**: Accepts a request for a traveler to join a booking.
- **Request Parameters**:
  - `booking_id`: ID of the booking.
- **Request Body**:
  ```json
  {
    "requester_email": "traveller@example.com"
  }
  ```
- **Response**:
  - `200 OK` : Traveler added successfully.
  - `400 Bad Request` : No pending request or ride is full.
  - `403 Forbidden` : Unauthorized to accept the request.


## 11. `POST /cabshare/bookings/{booking_id}/reject`
- **Description**: Rejects a traveler's request to join a booking.
- **Request Parameters**:
  - `booking_id`: ID of the booking.
- **Request Body**:
  ```json
  {
    "requester_email": "traveller@example.com"
  }```

- **Response**:
    - `200 OK`: Request rejected successfully.
    
## 12. `DELETE /cabshare/bookings/{booking_id}`
- **Description**: Deletes an existing booking.
- **Request Parameters**:
  - `booking_id`: ID of the booking.
- **Response**:
  - `200 OK`: Booking deleted successfully.
  - `403 Forbidden`: Unauthorized to delete the booking.

## 13. `DELETE /cabshare/bookings/{booking_id}/self`
- **Description**: Allows a user (not the owner) to exit from a booking.
- **Request Parameters**:
  - `booking_id`: ID of the booking.
- **Response**:
  - `200 OK`: Successfully exited from the booking.
  - `400 Bad Request`: Owner cannot exit, only delete the ride.
