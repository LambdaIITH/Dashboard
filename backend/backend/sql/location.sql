-- name: get_loc_id$
SELECT id 
FROM locations
WHERE locations.place = :place; 
