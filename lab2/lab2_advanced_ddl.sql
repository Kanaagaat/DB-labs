-- Part 1: Multiple Database Management
-- Task 1.1: Database Creation with Parameters
CREATE DATABASE university_main
    WITH
       OWNER  = postgres
       TEMPLATE = template0
       ENCODING = 'UTF8';
CREATE DATABASE university_archive WITH
       CONNECTION LIMIT = 50
       TEMPLATE = template0;
CREATE DATABASE university_test WITH
       IS_TEMPLATE = true
       CONNECTION LIMIT = 10;
-- Task 1.2: Tablespace Operations
CREATE TABLESPACE student_data
        LOCATION 'C:\Program Files\PostgreSQL\17\data/students';
CREATE TABLESPACE course_data
        LOCATION 'C:\Program Files\PostgreSQL\17\data/courses';
CREATE DATABASE university_distributed WITH
       TABLESPACE = student_data
       ENCODING = 'UTF8';

-- Part 2: Complex Table Creation
-- Task 2.1: University Management System
\c university_main;
CREATE TABLE IF NOT EXISTS  students(
    student_id  serial primary key,
    first_name varchar(50),
    last_name varchar(50),
    email varchar(100),
    phone char(15),
    date_of_birth date,
    enrollment_date date,
    gpa numeric(3,2),
    is_active boolean,
    graduation_year date
);
CREATE TABLE professors(
    professor_id serial primary key,
    first_name varchar(50),
    last_name varchar(50),
    email varchar(100),
    office_number varchar(20),
    hire_date date,
    salary numeric(12, 2),
    is_tenured boolean,
    year_experience int
);
CREATE TABLE courses(
    course_id serial primary key,
    course_code char(8),
    course_title varchar(100),
    description text,
    credits smallint,
    max_enrollments int,
    course_fee numeric(10,2),
    is_online boolean,
    created_at  timestamp without time zone
);
-- Task 2.2: Time-based and Specialized Tables
CREATE TABLE class_schedule(
    schedule_id serial primary key,
    course_id int,
    professor_id int,
    classroom varchar(20),
    class_date date,
    start_time time without time zone,
    end_time time without time zone,
    duration interval
);
CREATE TABLE student_records(
    record_id serial primary key,
    student_id int,
    course_id int,
    semester varchar(20),
    year int,
    grade char(2),
    attendance_percentage numeric(3, 2),
    submission_timestamp timestamp with time zone,
    last_update timestamp with time zone
);

-- Part 3: Advanced ALTER TABLE Operations
-- Task 3.1: Modifying Existing Tables
ALTER TABLE students
    ADD COLUMN middle_name varchar(30),
    ADD COLUMN student_status varchar(20) DEFAULT 'ACTIVE',
    ALTER COLUMN phone TYPE varchar(20),
    ALTER COLUMN gpa SET DEFAULT 0.00;
ALTER TABLE professors
    ADD COLUMN department_code char(5),
    ADD COLUMN research_are text,
    ALTER COLUMN year_experience TYPE smallint,
    ALTER COLUMN is_tenured SET DEFAULT false,
    ADD COLUMN last_promotion_date date;
ALTER TABLE courses
    ADD COLUMN prerequisite_course_id int,
    ADD COLUMN difficulty_leve smallint,
    ADD COLUMN lab_required boolean default false,
    ALTER COLUMN course_id TYPE varchar(10),
    ALTER COLUMN credits SET DEFAULT 3;
-- Task 3.2: Column Management Operations
ALTER TABLE class_schedule
    ADD COLUMN  room_capacity int,
    DROP COLUMN duration,
    ADD COLUMN session_type varchar(15),
    ALTER COLUMN classroom TYPE varchar(30),
    ADD COLUMN equipment_needed text;
ALTER TABLE student_records
    ADD COLUMN extra_credit_points numeric(3,1) DEFAULT 0.0,
    ALTER COLUMN grade TYPE varchar(5),
    ADD COLUMN final_exam_date date,
    DROP COLUMN last_update;

-- Part 4: Table Relationships and Management
-- Task 4.1: Additional Supporting Tables
CREATE TABLE departments(
    department_id serial primary key,
    department_name varchar(100),
    department_code char(5),
    building varchar(50),
    phone varchar(15),
    budget numeric(12,2),
    established_year int
);
CREATE TABLE library_books(
    book_id serial primary key,
    isbn char(13),
    title varchar(200),
    author varchar(100),
    publisher varchar(100),
    publication_date date,
    price numeric(3,2),
    is_available boolean,
    acquisition_timestamp timestamp without time zone
);
CREATE TABLE student_book_loans(
    loan_id serial primary key,
    student_id int,
    book_id int,
    loan_date date,
    due_date date,
    return_date date,
    fine_amount numeric(3,2),
    loan_status varchar(20)
);
-- Task 4.2: Table Modifications for Integration
ALTER TABLE professors
    ADD COLUMN department_id int;
ALTER TABLE students
    ADD COLUMN advisor_id int;
ALTER TABLE courses
    ADD COLUMN department_id int;

CREATE TABLE grade_scale(
    grade_id serial primary key,
    letter_grade char(2),
    min_percentage numeric(3,1),
    max_percentage numeric(3,1),
    gpa_points numeric(3,2)
);
CREATE TABLE semester_calendar(
    semester_id serial primary key,
    semester_name varchar(20),
    academic_year int,
    started_date date,
    end_date date,
    registration_deadline timestamp with time zone,
    is_current boolean
);

-- Part 5: Table Deletion and Cleanup
-- Task 5.1: Conditional Table Operations
DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

CREATE TABLE grade_scale(
    grade_id serial primary key,
    letter_grade char(2),
    min_percentage numeric(3,1),
    max_percentage numeric(3,1),
    gpa_points numeric(3,2),
    description text
);
DROP TABLE IF EXISTS semester_calendar CASCADE;
CREATE TABLE semester_calendar(
    semester_id serial primary key,
    semester_name varchar(20),
    academic_year int,
    started_date date,
    end_date date,
    registration_deadline timestamp with time zone,
    is_current boolean
);
-- Task 5.2: Database Cleanup

UPDATE pg_database
   SET datistemplate = false
 WHERE datname = 'university_test';


DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed;

CREATE DATABASE university_backup TEMPLATE university_main;
