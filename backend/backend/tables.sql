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
    email VARCHAR(256) ,
    cr BOOLEAN DEFAULT FALSE
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
    user_id BIGINT NOT NULL, -- user_id is the id of the user who updated the slot
    updated_slot VARCHAR(8),
    custom_timings JSON,
    PRIMARY KEY(course_code, acad_period, user_id),
    FOREIGN KEY (course_code, acad_period) REFERENCES courses(course_code, acad_period) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE 
);CASCADE


CREATE TABLE IF NOT EXISTS register
(
    user_id BIGINT NOT NULL,
    course_code VARCHAR(16) NOT NULL,
    acad_period VARCHAR(32) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (course_code, acad_period) REFERENCES courses(course_code, acad_period) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY(user_id, course_code, acad_period)
);

