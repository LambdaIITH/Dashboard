
This documentation outlines the various API routes for both the **Lost** and **Found** modules, describing the required inputs and expected responses for each route.

## Requirements:
- Uses Amazon S3 for storing images.

---

## Lost and Found Items Common Error Responses

- **400 Bad Request**: Invalid input or request.
- **403 Forbidden**: Unauthorized access.
- **500 Internal Server Error**: An error occurred on the server.

---

# **Lost API**

## 1. `POST /lost/add_item`

- **Description**: Add a new lost item along with optional images.
- **Request**:
  - Form Data: 
    - `form_data` (string): JSON string containing the details of the lost item.
    - `images` (list of UploadFile, optional): Images related to the lost item.
- **Response**:
  - `200 OK`: Item added successfully.
    ```json
    {
      "message": "Data inserted successfully"
    }
    ```
  - `500 Internal Server Error`: Error message.
    ```json
    {
      "detail": "An error occurred: <error_message>"
    }
    ```

---

## 2. `GET /lost/all`

- **Description**: Retrieve a list of all lost item names along with their image URLs, sorted by creation date.
- **Response**:
  - `200 OK`: List of lost items with associated images.
    ```json
    [
      {
        "id": 1,
        "name": "Laptop",
        "images": ["https://s3.amazonaws.com/lost-images/1.jpg"]
      },
      {
        "id": 2,
        "name": "Backpack",
        "images": []
      }
    ]
    ```
  - `500 Internal Server Error`: Error message.
    ```json
    {
      "detail": "failed to fetch items"
    }
    ```

---

## 3. `GET /lost/item/{id}`

- **Description**: Retrieve details of a specific lost item along with its associated images.
- **Request Parameters**:
  - `id` (int): The ID of the lost item.
- **Response**:
  - `200 OK`: Details of the lost item.
    ```json
    {
      "id": 1,
      "name": "Laptop",
      "description": "Black Dell Laptop",
      "images": ["https://s3.amazonaws.com/lost-images/1.jpg"]
    }
    ```
  - `404 Not Found`: If the item is not found.
    ```json
    {
      "detail": "Item not found"
    }
    ```
  - `500 Internal Server Error`: Error message.
    ```json
    {
      "detail": "Failed to fetch items: <error_message>"
    }
    ```

---

## 4. `DELETE /lost/delete_item`

- **Description**: Delete a lost item by its ID.
- **Request**:
  - Form Data:
    - `item_id` (int): The ID of the item to be deleted.
- **Response**:
  - `200 OK`: Item deleted successfully.
    ```json
    {
      "message": "Item deleted successfully!"
    }
    ```
  - `500 Internal Server Error`: Error message.
    ```json
    {
      "detail": "Failed to delete item: <error_message>"
    }
    ```

---

## 5. `PUT /lost/edit_item`

- **Description**: Edit an existing lost item.
- **Request**:
  - Form Data:
    - `item_id` (int): The ID of the item to be updated.
    - `form_data` (string): JSON string with updated details of the item.
- **Response**:
  - `200 OK`: Item updated successfully.
    ```json
    {
      "message": "Item updated"
    }
    ```
  - `500 Internal Server Error`: Error message.
    ```json
    {
      "detail": "Error: <error_message>"
    }
    ```

---

## 6. `GET /lost/search`

- **Description**: Search for lost items by a query.
- **Request Parameters**:
  - `query` (string): The search query.
  - `max_results` (int, optional, default=100): The maximum number of results to return.
- **Response**:
  - `200 OK`: List of lost items that match the search query.
    ```json
    [
      {
        "id": 1,
        "name": "Laptop",
        "images": ["https://s3.amazonaws.com/lost-images/1.jpg"]
      },
      {
        "id": 2,
        "name": "Backpack",
        "images": []
      }
    ]
    ```
  - `500 Internal Server Error`: Error message.
    ```json
    {
      "detail": "Error: <error_message>"
    }
    ```

---

# **Found API**

## 1. `POST /found/add_item`

- **Description**: Add a new found item along with optional images.
- **Request**:
  - Form Data: 
    - `form_data` (string): JSON string containing the details of the found item.
    - `images` (list of UploadFile, optional): Images related to the found item.
- **Response**:
  - `200 OK`: Item added successfully.
    ```json
    {
      "message": "Data inserted successfully"
    }
    ```
  - `500 Internal Server Error`: Error message.
    ```json
    {
      "detail": "An error occurred: <error_message>"
    }
    ```

---

## 2. `GET /found/all`

- **Description**: Retrieve a list of all found item names along with their image URLs.
- **Response**:
  - `200 OK`: List of found items with associated images.
    ```json
    [
      {
        "id": 1,
        "name": "Laptop",
        "images": ["https://s3.amazonaws.com/found-images/1.jpg"]
      },
      {
        "id": 2,
        "name": "Backpack",
        "images": []
      }
    ]
    ```
  - `500 Internal Server Error`: Error message.
    ```json
    {
      "detail": "failed to fetch items"
    }
    ```

---

## 3. `GET /found/item/{id}`

- **Description**: Retrieve details of a specific found item along with its associated images.
- **Request Parameters**:
  - `id` (int): The ID of the found item.
- **Response**:
  - `200 OK`: Details of the found item.
    ```json
    {
      "id": 1,
      "name": "Laptop",
      "description": "Black Dell Laptop",
      "images": ["https://s3.amazonaws.com/found-images/1.jpg"]
    }
    ```
  - `404 Not Found`: If the item is not found.
    ```json
    {
      "detail": "Item not found"
    }
    ```
  - `500 Internal Server Error`: Error message.
    ```json
    {
      "detail": "Failed to fetch items: <error_message>"
    }
    ```

---

## 4. `DELETE /found/delete_item`

- **Description**: Delete a found item by its ID.
- **Request**:
  - Form Data:
    - `item_id` (int): The ID of the item to be deleted.
- **Response**:
  - `200 OK`: Item deleted successfully.
    ```json
    {
      "message": "Item deleted successfully!"
    }
    ```
  - `500 Internal Server Error`: Error message.
    ```json
    {
      "detail": "Failed to delete item: <error_message>"
    }
    ```

---

## 5. `PUT /found/edit_item`

- **Description**: Edit an existing found item.
- **Request**:
  - Form Data:
    - `item_id` (int): The ID of the item to be updated.
    - `form_data` (string): JSON string with updated details of the item.
- **Response**:
  - `200 OK`: Item updated successfully.
    ```json
    {
      "message": "Item updated"
    }
    ```
  - `500 Internal Server Error`: Error message.
    ```json
    {
      "detail": "Error: <error_message>"
    }
    ```

---

## 6. `GET /found/search`

- **Description**: Search for found items by a query.
- **Request Parameters**:
  - `query` (string): The search query.
  - `max_results` (int, optional, default=100): The maximum number of results to return.
- **Response**:
  - `200 OK`: List of found items that match the search query.
    ```json
    [
      {
        "id": 1,
        "name": "Laptop",
        "images": ["https://s3.amazonaws.com/found-images/1.jpg"]
      },
      {
        "id": 2,
        "name": "Backpack",
        "images": []
      }
    ]
    ```
  - `500 Internal Server Error`: Error message.
    ```json
    {
      "detail": "Error: <error_message>"
    }
    ```
