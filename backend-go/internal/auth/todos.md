# backend-go/internal/auth

muqeeth26832 - 3-10-2024

This package is responsible for handling authentication-related functionality in the Go backend. It was developed using Go and follows patterns similar to those in Python's FastAPI.

### **Note:**
- **Testing**: The code has not been tested yet as I do not have the required environment variables configured.
- **Environment Variables**: The code assumes the existence of certain environment variables (e.g., Google client ID, secret keys), but I don't know how to configure them currently.
- **Error Handling**: The error handling can be improved and more detailed.

---

## TODOs

1. **Database Functions in `auth.go`**:
   - Write database functions in `auth.go` (e.g., check user existence, insert new user).
   - **Issue**: I'm not familiar with `sqlx` yet. 😓

2. **Environment Variables Handling**:
   - Instead of calling `os.Getenv()` each time, load all environment variables in `main.go` and import them wherever needed.

3. **Error Handling**:
   - Improve error handling across the package.
   - Ensure that the error messages are more descriptive and consistent.

---

## Notes on Code Structure

1. **Exported Functions**:
   - All functions are written in **upper case** (exported functions in Go).
   - If you prefer, you can rename them to use camel case (lowercase first letter) to match Go convention for internal functions.

2. **Package Importing**:
   - This is a standalone `auth` package. You can build and import it into other parts of the backend and begin testing.

3. **Branch Information**:
   - All of the work has been done on the `goauth` branch and is being pushed to the `go-backend` branch.

---