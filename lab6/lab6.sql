create database lab6_again;
\c lab6_again
-- Create table: employees
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(50),
 dept_id INT,
 salary DECIMAL(10, 2)
);
-- Create table: departments
CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);
-- Create table: projects
CREATE TABLE projects (
 project_id INT PRIMARY KEY,
 project_name VARCHAR(50),
 dept_id INT,
 budget DECIMAL(10, 2)
);
-- Insert data into employees
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);
-- Insert data into departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');
-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id,
budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

-- part 2
SELECT e.emp_name, d.dept_name
FROM employees e CROSS JOIN departments d;
-- total 20 row because cross join is cartesian product of 2 table. All possibe combinations
-- 2.2
-- a
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;
-- b
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON TRUE;
-- 2.3
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON TRUE;
-- part3
-- 3.1
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
-- 4 rows total and Tom dept_id is NULL.
-- 3.2
SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);
-- output looks cleaner, but the data is the same no duplicates in using
-- 3.3
SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;
-- 3.4
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;
-- part 4
-- Your query here
-- 4.1
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS
dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- Tom Brown appears with null values in department columns because dept_id is null
-- 4.2
SELECT
    emp_name,
    dept_id,
    dept_name,
    location
FROM employees
LEFT JOIN departments USING (dept_id);
-- 4.3
SELECT
    e.emp_name,
    e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;
-- 4.4
SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;
-- part 5
-- 5.1
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;
-- 5.2
SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id;
-- 5.3
SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;
-- part6
select e.emp_name, e.dept_id as emp_dapt, d.dept_id as dept_dept, d.dept_id
from employees e full join departments d on e.dept_id = d.dept_id;
-- null on eft side is emp_name is null, means departments has no employee
-- null on right side is dept_name is name, means employees has no department
-- 6.2
select d.dept_name, p.project_name from
departments d full join projects p on d.dept_id=p.dept_id;
-- 6.3
select e.emp_name, d.dept_name from employees e
full join departments d on e.dept_id=d.dept_id
where e.emp_name is NULL or d.dept_id is NULL;
-- part 7
-- Query 1: Filter in ON clause
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND
d.location = 'Building A';
-- 7.2
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id where
d.location = 'Building A';
-- on keeps unmatched rows while where remove them
-- 7.3
select e.emp_name,d.dept_name, e.salary
from employees e inner join departments d on e.dept_id = d.dept_id
and d.location = 'Building A';
select e.emp_name,d.dept_name, e.salary
from employees e inner join departments d on e.dept_id = d.dept_id
where d.location = 'Building A';
-- part 8
select
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
from departments d
left join employees e on d.dept_id=e.dept_id
left join projects p on d.dept_id = p.dept_id
order by d.dept_name, e.emp_name;
-- 8.2
-- Add manager_id column
ALTER TABLE employees ADD COLUMN manager_id INT;
-- Update with sample data
UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

SELECT
 e.emp_name AS employee,
 m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- 8.3
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;