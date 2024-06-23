DROP TABLE IF EXISTS register;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS custom_courses;
DROP TABLE IF EXISTS slot_updates;
DROP TABLE IF EXISTS changes_accepted;
DROP TABLE IF EXISTS request;
DROP TABLE IF EXISTS traveller;
DROP TABLE IF EXISTS cab_booking;
DROP TABLE IF EXISTS locations;
DROP TYPE IF EXISTS request_status;

CREATE TABLE IF NOT EXISTS courses
(
    course_code VARCHAR(16) NOT NULL,
    acad_period VARCHAR(32) NOT NULL,
    course_name VARCHAR(256) NOT NULL,
    segment VARCHAR(3) NOT NULL,
    slot VARCHAR(8) NOT NULL,
    credits INT NOT NULL,
    PRIMARY KEY(course_code, acad_period)
);

CREATE TABLE IF NOT EXISTS users
(
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(256) UNIQUE NOT NULL,
    cr BOOLEAN DEFAULT FALSE,
    phone_number VARCHAR(15) UNIQUE,
);

CREATE TABLE IF NOT EXISTS custom_courses
(
    course_code VARCHAR(16) NOT NULL,
    acad_period VARCHAR(32) NOT NULL,
    user_id BIGINT NOT NULL,
    slot VARCHAR(8),
    custom_timings JSON,
    PRIMARY KEY(course_code, acad_period, user_id),
    FOREIGN KEY (course_code, acad_period) REFERENCES courses(course_code, acad_period) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS slot_updates
(
    course_code VARCHAR(16) NOT NULL,
    acad_period VARCHAR(32) NOT NULL,
    cr_id BIGINT NOT NULL, -- cr_id is the id of the user who updated the slot
    updated_slot VARCHAR(8),
    custom_timings JSON,
    PRIMARY KEY(course_code, acad_period, cr_id),
    FOREIGN KEY (course_code, acad_period) REFERENCES courses(course_code, acad_period) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (cr_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS register
(
    user_id BIGINT NOT NULL,
    course_code VARCHAR(16) NOT NULL,
    acad_period VARCHAR(32) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (course_code, acad_period) REFERENCES courses(course_code, acad_period) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY(user_id, course_code, acad_period)
);

CREATE TABLE IF NOT EXISTS changes_accepted
(
    user_id BIGINT NOT NULL,
    course_code VARCHAR(16) NOT NULL,
    acad_period VARCHAR(32) NOT NULL,
    cr_id BIGINT NOT NULL,
    PRIMARY KEY(user_id, course_code, acad_period, cr_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (course_code, acad_period, cr_id) REFERENCES slot_updates(course_code, acad_period,cr_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id, course_code, acad_period) REFERENCES register(user_id,course_code,acad_period) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE locations
(
  place VARCHAR NOT NULL,
  id BIGSERIAL NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (place)
);

INSERT INTO locations (place) VALUES ('IITH');
INSERT INTO locations (place) VALUES ('RGIA');
INSERT INTO locations (place) VALUES ('Secun. Railway Stn.');
INSERT INTO locations (place) VALUES ('Lingampally Stn.');
INSERT INTO locations (place) VALUES ('Kacheguda Stn.');
INSERT INTO locations (place) VALUES ('Hyd. Deccan Stn.');


CREATE TABLE cab_booking
(
  id BIGSERIAL NOT NULL,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP NOT NULL,
  capacity INT NOT NULL,
  from_loc INT,
  to_loc INT,
  owner_email VARCHAR NOT NULL,
  comments VARCHAR NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (from_loc) REFERENCES locations(id),
  FOREIGN KEY (to_loc) REFERENCES locations(id),
  FOREIGN KEY (owner_email) REFERENCES users(email)
);

CREATE TABLE traveller
(
  email VARCHAR NOT NULL,
  cab_id INT NOT NULL,
  comments VARCHAR NOT NULL,
  PRIMARY KEY (email, cab_id),
  FOREIGN KEY (email) REFERENCES users(email),
  FOREIGN KEY (cab_id) REFERENCES cab_booking(id) ON DELETE CASCADE
);

CREATE TYPE request_status AS ENUM ('pending', 'accepted', 'rejected', 'cancelled');

CREATE TABLE request
(
  status request_status NOT NULL,
  booking_id INT NOT NULL,
  request_email VARCHAR NOT NULL, 
  comments VARCHAR,
  PRIMARY KEY (booking_id, request_email),
  FOREIGN KEY (booking_id) REFERENCES cab_booking(id) ON DELETE CASCADE,
  FOREIGN KEY (request_email) REFERENCES users(email)
);
