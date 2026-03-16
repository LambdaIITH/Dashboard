-- Drop tables and types in the correct order with CASCADE to handle dependencies
DROP TABLE IF EXISTS changes_accepted CASCADE;
DROP TABLE IF EXISTS slot_updates CASCADE;
DROP TABLE IF EXISTS custom_courses CASCADE;
DROP TABLE IF EXISTS register CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS request CASCADE;
DROP TABLE IF EXISTS traveller CASCADE;
DROP TABLE IF EXISTS cab_booking CASCADE;
DROP TABLE IF EXISTS locations CASCADE;
DROP TYPE IF EXISTS request_status CASCADE;
DROP TYPE IF EXISTS fcm_tokens CASCADE;
DROP TABLE IF EXISTS shared_timetable CASCADE;
DROP TABLE IF EXISTS lost CASCADE;
DROP TABLE IF EXISTS found CASCADE;
DROP TABLE IF EXISTS lost_images CASCADE;
DROP TABLE IF EXISTS found_images CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS face CASCADE;
DROP TABLE IF EXISTS hostel_complaints CASCADE;
DROP TABLE IF EXISTS hostel_complaint_images CASCADE;
DROP TABLE IF EXISTS selling CASCADE;
DROP TABLE IF EXISTS selling_images CASCADE;


-- Re-create the tables and types
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
    name VARCHAR NOT NULL,
    cr BOOLEAN DEFAULT FALSE,
    phone_number VARCHAR(15) UNIQUE,
    timetable JSON DEFAULT '{"courses": {}, "slots": {}}'
);

-- Store FCM token of user
CREATE TABLE IF NOT EXISTS fcm_tokens (
    user_id       BIGINT NOT NULL,
    token         TEXT   NOT NULL,
    device_type   VARCHAR(50) NOT NULL,
    PRIMARY KEY (user_id, token),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS shared_timetable
(
    code VARCHAR(8) NOT NULL,
    user_id BIGINT NOT NULL,
    timetable JSON,
    expiry TIMESTAMP,
    PRIMARY KEY(code),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
) ;

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

CREATE TABLE IF NOT EXISTS lost
(
    id BIGSERIAL PRIMARY KEY,
    item_name VARCHAR(256) NOT NULL,
    item_description VARCHAR(512) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS found
(
    id BIGSERIAL PRIMARY KEY,
    item_name VARCHAR(256) NOT NULL,
    item_description VARCHAR(512) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS lost_images
(
    id BIGSERIAL PRIMARY KEY,
    image_url VARCHAR(256) NOT NULL,
    item_id BIGINT NOT NULL,

    FOREIGN KEY(item_id) REFERENCES lost(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS found_images
(
    id BIGSERIAL PRIMARY KEY,
    image_url VARCHAR(256) NOT NULL,
    item_id BIGINT NOT NULL,

    FOREIGN KEY(item_id) REFERENCES found(id) ON DELETE CASCADE ON UPDATE CASCADE
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


-- using nanoid function for creating a key for transactions
-- so later it can be used for generating QR code
CREATE TABLE IF NOT EXISTS transactions (
    id TEXT PRIMARY KEY,
    transaction_id TEXT UNIQUE,
    payment_time TIMESTAMP NOT NULL,
    user_id BIGINT NOT NULL,
    travel_date DATE NOT NULL,
    bus_timing TIME NOT NULL,
    isUsed BOOLEAN DEFAULT FALSE,
    amount NUMERIC(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS face
(
    id BIGSERIAL PRIMARY KEY,
    user_name VARCHAR(256) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    face_url VARCHAR(256) NOT NULL,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS announcements
(
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    createdat bigint NOT NULL,
    createdby TEXT NOT NULL,
    tags TEXT[],
    category TEXT[],
    imageURI TEXT
);

CREATE TABLE IF NOT EXISTS hostel_complaints
(
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    complaint_description VARCHAR(1000) NOT NULL,
    complaint_data JSONB DEFAULT '{}',
    complaint_status VARCHAR(50) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    is_sheet_synced BOOLEAN DEFAULT FALSE,
    sheet_sync_attempts INT DEFAULT 0,
    hostel VARCHAR(100),
    room_number VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS hostel_complaint_images
(
    id BIGSERIAL PRIMARY KEY,
    complaint_id BIGINT NOT NULL REFERENCES hostel_complaints(id) ON DELETE CASCADE,
    image_url VARCHAR(256) NOT NULL
);

CREATE TABLE IF NOT EXISTS hostels
(
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(256) UNIQUE NOT NULL REFERENCES users(email) ON DELETE CASCADE ON UPDATE CASCADE,
    hostel_block VARCHAR(50) NOT NULL,
    room_number VARCHAR(50) NOT NULL,
    gender VARCHAR(20)
);

-- Marketplace/Buy-Sell tables
CREATE TABLE IF NOT EXISTS selling
(
    id BIGSERIAL PRIMARY KEY,
    item_name VARCHAR(256) NOT NULL,
    item_description VARCHAR(1000) NOT NULL,
    selling_price NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS selling_images
(
    id BIGSERIAL PRIMARY KEY,
    image_url VARCHAR(512) NOT NULL,
    item_id BIGINT NOT NULL REFERENCES selling(id) ON DELETE CASCADE ON UPDATE CASCADE
);
