create database lab5
\c lab5
-- part 1
create table employees(
    employee_id serial primary key, 
    first_name varchar(50),
    last_name varchar(50),
    age int,
    salary numeric,
    check (age between 18 and 65),
    check (salary > 0)
);

create table products_catalog(
    product_id serial primary key,
    product_name varchar(50),
    regular_price numeric,
    discount_price numeric,
    CONSTRAINT valid_discount check(
        regular_price > 0 and
        discount_price > 0 and
        discount_price < regular_price
    )
);

create table bookings(
    booking_id serial primary key,
    check_in_date date,
    check_out_date date,
    num_guests int,
    CHECK (num_guests > 1 and num_guests < 10),
    check( check_out_date < check_in_date)
);
--valid
INSERT INTO employees VALUES (1, 'John', 'Smith', 25, 2000);
INSERT INTO employees VALUES (2, 'Mary', 'Lee', 40, 3500);

--Нарушает CHECK (age)
INSERT INTO employees VALUES (3, 'Tom', 'Young', 70, 2500);
-- Ошибка: age нарушает CHECK (age BETWEEN 18 AND 65)

--Нарушает CHECK (salary)
INSERT INTO employees VALUES (4, 'Anna', 'Brown', 30, -500);
-- Ошибка: salary нарушает CHECK (salary > 0)
-- DROP TABLE IF EXISTS employees CASCADE;
-- DROP TABLE IF EXISTS products_catalog CASCADE;
-- DROP TABLE IF EXISTS bookings CASCADE;

create  table customers(
    customer_id serial primary key NOT NULL,
    email varchar(50) not null,
    phone varchar(50),
    registration date not null
);

create table inventory(
    item_id serial primary key not null,
    item_name varchar(50) not null,
    quantity int not null check(quantity > 0),
    unit_price numeric not null check(unit_price > 0),
    last_update timestamp not null
);

--Верные данные
INSERT INTO customers VALUES (1, 'john@gmail.com', '12345', '2025-10-07');

--Нарушает NOT NULL (email)
INSERT INTO customers VALUES (2, NULL, '12345', '2025-10-07');
-- Ошибка: column "email" violates NOT NULL constraint

-- phone может быть NULL
INSERT INTO customers VALUES (3, 'maria@mail.com', NULL, '2025-10-07');
-- part 3
create table users(
    user_id serial primary key,
    username varchar(50) unique ,
    email varchar(50) unique,
    created_at timestamp
);

create table course_enrollments(
    enrollment_id serial primary key,
    student_id int,
    course_code text,
    semester text,
    constraint unique_enrollment unique(student_id, course_code, semester)
);

alter table users
add constraint unique_username unique(username),
add constraint unique_email unique(email);
-- part 4

create table departments(
    dept_id serial primary key,
    dept_name text not null,
    location text
);

INSERT INTO departments VALUES (1, 'HR', 'Almaty');
INSERT INTO departments VALUES (2, 'Finance', 'Astana');
INSERT INTO departments VALUES (3, 'IT', 'Shymkent');

--Дубликат ключа
INSERT INTO departments VALUES (1, 'Marketing', 'Aktau');
-- Ошибка: duplicate key value violates unique constraint "departments_pkey"

--NULL ключ
INSERT INTO departments VALUES (NULL, 'Support', 'Atyrau');
-- Ошибка: null value in column "dept_id" violates not-null constraint

create table student_course(
    student_id int,
    course_id int,
    enrollment_date date,
    grade text,
    primary key (student_id, course_id)
);
-- 4.3
-- 1 uniquely identify data - praimary key, may not have null value , may be only one in table
--   unique - gurantee uniqueness may have null value, may be many in onne table
-- 2 we use single column when primary  is single and can bee identified by 1 column
--   we use composite when we have multiple primary key value to identify table
-- 3 when column in unique and it has to identify relation we use unique value, because it can be only one in one relation, while unique may be all column
-- part 5

create table  employees_dept(
    emp_id serial primary key,
    emp_name text not null,
    dept_id int,
    foreign key  (dept_id) references departments(dept_id)
);

-- drop table employees_dept cascade ;
-- TRUNCATE TABLE departments RESTART IDENTITY CASCADE;

INSERT INTO departments (dept_name, location) VALUES
('HR','Almaty'),
('Finance','Astana'),
('IT','Shymkent');
INSERT INTO employees_dept (emp_name, dept_id) VALUES
('Alice', 1),
('Bob', 2);

SELECT * FROM departments;
SELECT * FROM employees_dept;

create table authors(
    author_id serial primary key,
    author_name text not null,
    country text
);
create table publishers(
    publisher_id serial primary key,
    publisher_name text not null,
    city text
);
create table books(
    book_id serial primary key,
    title text not null,
    author_id int references authors(author_id),
    publisher_id int references  publishers(publisher_id),
    publication_year int,
    isbn text unique
);
INSERT INTO authors (author_name, country) VALUES
('Leo Tolstoy','Russia'),
('Jane Austen','UK'),
('Gabriel Garcia Marquez','Colombia'),
('Fyodor Dostoevsky','Russia'),
('Haruki Murakami','Japan');
INSERT INTO publishers (publisher_name, city) VALUES
('Penguin','London'),
('Vintage','New York'),
('HarperCollins','New York'),
('Reilly','Sebastopol'),
('LitRes','Moscow');
INSERT INTO books (title, author_id, publisher_id, publication_year, isbn) VALUES
('War and Peace', 1, 5, 1869, '978-1-111111-1'),
('Pride and Prejudice', 2, 1, 1813, '978-2-222222-2'),
('One Hundred Years of Solitude', 3, 2, 1967, '978-3-333333-3'),
('Crime and Punishment', 4, 5, 1866, '978-4-444444-4'),
('Norwegian Wood', 5, 2, 1987, '978-5-555555-5');


-- DROP TABLE IF EXISTS books CASCADE;
-- DROP TABLE IF EXISTS authors CASCADE;
-- DROP TABLE IF EXISTS publishers CASCADE;
--

create table categories(
    category_id serial primary key,
    category_name text not null
);
create table products_fk(
    product_id serial primary key,
    product_name text not null,
    category_id int references categories(category_id) on delete restrict
);

create table orders(
    order_id serial primary key,
    order_date date not null
);
create table order_item(
    item_id serial primary key,
    order_id int references orders(order_id) on delete cascade,
    product_id int references products_fk(product_id),
    quantity int check(quantity > 0)
);

-- Create an order and related items
INSERT INTO orders (order_date) VALUES ('2025-10-01'); -- order_id = 1
INSERT INTO order_items (order_id, product_id, quantity)
VALUES (1, 1, 2), (1, 3, 1);

-- 1) Attempt to delete a category that has products (should FAIL due to RESTRICT)
-- DELETE FROM categories WHERE category_id = 1;
-- -> ERROR: update or delete on table "categories" violates foreign key constraint "products_fk_category_id_fkey"

-- 2) Delete an order and verify that its items are automatically deleted (CASCADE)
SELECT * FROM order_items WHERE order_id = 1; -- before deletion: 2 rows

DELETE FROM orders WHERE order_id = 1; -- deletes the order itself

SELECT * FROM order_items WHERE order_id = 1; -- after deletion: 0 rows (CASCADE worked)

-- Documentation:
-- (1) Deleting a category that has existing products returns a FK RESTRICT error (deletion not allowed).
-- (2) Deleting an order automat

create table customers2(
    customer_id serial primary key,
    name text not null,
    email text unique,
    phone text not null,
    registration_date date not null);

create table products (
    product_id serial primary key,
    name text not null,
    description text,
    price numeric check (price >= 0),
    stock_quantity int check (stock_quantity >= 0)
);
create table orders2 (
    order_id serial primary key,
    customer_id int references customers2(customer_id) on delete cascade,
    order_date date not null,
    total_amount numeric check (total_amount >= 0),
    status text check (status in ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);
create table order_details (
    order_detail_id serial primary key,
    order_id int references orders2(order_id) on delete cascade,
    product_id int references products(product_id) on delete restrict,
    quantity int check (quantity > 0),
    unit_price numeric check (unit_price >= 0)
);

-- drop table customers2;
-- drop table products;
-- drop table orders2;
-- drop table order_details;


insert into customers2(name, email, phone, registration_date) values
('john smith', 'john@example.com', '123456789', '2024-01-10'),
('mary lee', 'mary@example.com', '987654321', '2024-02-15'),
('alex kim', 'alex@example.com', '555111222', '2024-03-01'),
('sofia garcia', 'sofia@example.com', '777888999', '2024-04-12'),
('daniel choi', 'daniel@example.com', '666555444', '2024-05-05');

insert into products(name, description, price, stock_quantity) values
('laptop', '15-inch display, 16gb ram', 1200, 10),
('smartphone', 'android 13, 128gb storage', 800, 20),
('headphones', 'wireless noise-cancelling', 150, 50),
('keyboard', 'mechanical rgb', 90, 30),
('mouse', 'ergonomic wireless', 60, 40);

insert into orders2(customer_id, order_date, total_amount, status) values
(1, '2024-06-01', 1950, 'shipped'),
(2, '2024-06-10', 890, 'processing'),
(3, '2024-06-15', 150, 'pending'),
(4, '2024-06-20', 1350, 'delivered'),
(5, '2024-06-25', 60, 'cancelled');

insert into order_details(order_id, product_id, quantity, unit_price) values
(1, 1, 1, 1200),
(1, 3, 5, 150),
(2, 2, 1, 800),
(3, 3, 1, 150),
(4, 4, 10, 90);

delete from customers2 where customer_id = 1;




