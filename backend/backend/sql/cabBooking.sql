-- name:create_booking<!
insert into cab_booking (start_time, end_time, capacity, from_loc, to_loc, owner_email, comments)
values (:start_time, :end_time, :capacity, :from_loc, :to_loc, :owner_email, :comments)
returning id;

-- name:update_booking!
update cab_booking
  set start_time=:start_time, end_time=:end_time
  where id=:cab_id;

-- name:add_traveller!
insert into traveller (email, cab_id, comments)
  values  (:email, :cab_id, :comments); 

-- name:get_owner_email$
select owner_email from cab_booking where id=:cab_id;
