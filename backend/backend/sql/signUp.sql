-- name: insert_user!
INSERT INTO users (email, name, phone_number) VALUES (:email, :name, :phone_number)
  ON CONFLICT (email) DO UPDATE SET phone_number = :phone_number;

-- name: get_name$
SELECT name FROM users WHERE email = :email;
