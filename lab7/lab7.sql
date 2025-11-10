create database lab7;
\c lab7;
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
-- 2.1
create view part2_view as
    select e.emp_name, e.salary, d.dept_name, d.location
    from employees e join departments d on e.dept_id = d.dept_id
    where e.dept_id is not null;
select * from part2_view;
-- 2.2
create or replace view dept_statistics as
    select
        d.dept_name,
        count(e.emp_id) as employee_count,
        avg(e.salary) as avg_salary,
        max(e.salary) as max_salary,
        min(e.salary) as min_salary
    from employees e join departments d on true
    group by d.dept_name;
select * from dept_statistics
order by employee_count desc;
-- 2.3
create view project_overview as
    select
        p.project_name,
        p.budget,
        d.dept_name,
        d.location,
        count(e.emp_name)
    from projects p
    join departments d on p.dept_id = d.dept_id
    join employees e on p.dept_id = e.dept_id
    group by d.dept_name, p.budget, p.project_name, d.location;
select * from project_overview;
-- 2.4
create view high_earners as
    select e.emp_name, e.salary, d.dept_name
    from employees e join departments d on e.dept_id = d.dept_id
    where e.salary > 55000;
select * from high_earners;

-- part 3
create or replace view part2_view as
    select
        e.emp_name, e.salary,
        d.dept_name, d.location,
        case
            when e.salary > 60000 then 'High'
            when e.salary > 50000 then 'Medium'
            else 'Standard'
        end as salary_grade
    from employees e join departments d on e.dept_id = d.dept_id
        where e.dept_id is not null;
select * from part2_view;
-- 3.2
alter view high_earners rename to top_performers;
select * from top_performers;
-- 3.3
create view temp_view as
select *
from employees e
where salary < 50000;
drop view temp_view;
-- part 4
create view employee_salaries as
    select * from employees;
-- 4.2
update employee_salaries
set salary = 520000
where emp_name = 'John Smith';
SELECT * FROM employees WHERE emp_name = 'John Smith';
-- 4.3
insert into employee_salaries(emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);
select * from employee_salaries;
-- 4.4
create view it_employees as
    select e.emp_id ,e.emp_name, e.dept_id, e.salary
    from employees e
    where e.dept_id = 101
    with local check option;
-- This should fail
INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000);
-- error message: [44000] ERROR: new row violates check option for view "it_employees"
--   Подробности: Failing row contains (7, Bob Wilson, 103, 60000.00).
-- because we are inserting different from IT dept_id;
-- part 5
create materialized view dept_summary_mv as
    select
        d.dept_id, d.dept_name,
        count(e.emp_id) as total_employee,
        sum(e.salary) as total_salary,
        count(p.project_id) as total_projects,
        sum(p.budget) as total_budget
    from departments d
        join employees e on e.dept_id = d.dept_id
        join projects p on d.dept_id = p.dept_id
        group by d.dept_id, d.dept_name
    with data;
select * from dept_summary_mv order by total_employee;
-- 5.2
INSERT INTO employees(emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);

-- 2) Query materialized view BEFORE refresh
SELECT * FROM dept_summary_mv WHERE dept_id = 101;

-- 3) Refresh
REFRESH MATERIALIZED VIEW dept_summary_mv;

-- 4) Query materialized view AFTER refresh
SELECT * FROM dept_summary_mv WHERE dept_id = 101;
-- 5.3


