CREATE TABLE IF NOT EXISTS "courses"
(
    course_code VARCHAR(16) NOT NULL,
    acad_period VARCHAR(32) NOT NULL,
    course_name VARCHAR(256) NOT NULL,
    segment VARCHAR(3) NOT NULL,
    credits INT NOT NULL,
    PRIMARY KEY(course_code, acad_period)
);
CREATE TABLE IF NOT EXISTS "users"( email VARCHAR(256));
CREATE TABLE IF NOT EXISTS "register"(
    user_id INT NOT NULL,
    course_code VARCHAR(16) NOT NULL,
    acad_period VARCHAR(32) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (course_code, acad_period) REFERENCES courses(course_code, acad_period) ON DELETE CASCADE ON UPDATE CASCADE
);