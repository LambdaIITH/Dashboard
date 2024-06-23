-- name: create_request!
INSERT INTO request (status, booking_id, request_email, comments) 
  VALUES ('pending', :booking_id, :email, :comments)
  ON CONFLICT DO NOTHING;

-- name: get_request_status$
SELECT status
  FROM request
  WHERE booking_id = :booking_id AND request_email = :email;

-- name: delete_request!
UPDATE request
  SET status = 'cancelled'
  WHERE booking_id = :cab_id AND request_email = :email AND status = 'pending';

-- name: show_requests
SELECT r.request_email, r.comments, u.name, u.phone_number
  FROM request r
    INNER JOIN users u ON u.email = r.request_email
  WHERE r.status = 'pending' AND r.booking_id = :cab_id;

-- name: get_user_pending_requests
SELECT c.id, c.start_time, c.end_time, c.capacity, fl.place, tl.place, c.owner_email, u.name, u.phone_number
  FROM cab_booking c
    INNER JOIN locations fl ON fl.id = c.from_loc
    INNER JOIN locations tl ON tl.id = c.to_loc
    INNER JOIN users u ON u.email = c.owner_email
    INNER JOIN request r ON r.booking_id = c.id
  WHERE r.request_email = :email
    AND r.status = 'pending'
    AND c.end_time > (SELECT CURRENT_TIMESTAMP);

-- name: update_request<!
UPDATE request
  SET status = :val
  WHERE booking_id = :booking_id AND request_email = :request_email AND status = 'pending'
  RETURNING comments;
