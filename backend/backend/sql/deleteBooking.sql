-- name: delete_booking!
DELETE FROM cab_booking WHERE id=:cab_id;

-- name: delete_particular_traveller!
DELETE FROM traveller WHERE cab_id=:cab_id and email=:email
 AND :owner_email IN (SELECT owner_email FROM cab_booking WHERE id=:cab_id);
