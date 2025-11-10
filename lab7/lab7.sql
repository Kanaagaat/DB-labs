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
-- we before rrefresh we see old data withoutcharlie, after we can see differnece in valuee
-- 5.3
create unique index on dept_summary_mv(dept_id);
refresh materialized view concurrently dept_summary_mv;

select * from dept_summary_mv;
-- we can read data while it is updating
-- 5.4
create materialized view project_stats_mv as
    select p.project_name, p.budget,d.dept_name, count(e.emp_id) as assigned_emp
    from projects p
    left join departments d on p.dept_id = d.dept_id
    left join employees e on p.dept_id = e.dept_id
    group by p.project_name, p.budget, d.dept_name
    with no data;

select * from project_stats_mv;
-- it gives errrror because we didnt write refresh and added data into ito it
-- part 6
create role analyst;
create role data_viewer login password 'viewer123';
create role report_use login password 'report456';
SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';
-- 6.2
create role db_creator login password 'creator789' createdb ;
create role user_manager login password 'manager101' createrole ;
create role admin_user login password 'admin99' superuser;
-- 6.3
grant select on employees, departments,projects to analyst;
grant all privileges  on part2_view to data_viewer;
grant select,insert on employees to report_use;
-- 6.4
create role hr_team;
create role finance_team;
create role it_team;

create role hr_user1 login password 'hr001';
create role hr_user2 login password 'hr002';
create role finance_user1 login password 'fin001';

grant hr_team to hr_user1;
grant hr_team to hr_user2;
grant finance_team to finance_user1;

grant select, update on employees to hr_team;
grant select on part2_view to finance_team;
-- 6.5
revoke update on employees from hr_team;
revoke hr_team from hr_user2;
revoke all privileges on part2_view from data_viewer;
-- 6.6
alter role analyst login password 'analyst123';
alter role user_manager superuser;
alter role analyst password  null;
alter role data_viewer connection limit 5;

-- part 7
create role read_only;
grant select on all tables in schema public to read_only;
alter default privileges in schema public
grant select on tables to read_only;

create role junior_analyst login password 'junior123';
create role senior_analyst login password 'senior123';

grant read_only to junior_analyst;
grant read_only to senior_analyst;

grant insert, update on employees to senior_analyst;

-- 7.2
create role project_manager login password 'pm123';
alter view dept_statistics owner to project_manager;
alter table projects owner to project_manager;


SELECT tablename, tableowner FROM pg_tables
WHERE schemaname = 'public';
-- 7.3
create role temp_owner login;

create table temp_table(id int);
alter table temp_table owner to temp_owner;

reassign owned by temp_owner to postgres;
drop owned by temp_owner;
drop role temp_owner;

-- 7.4
create or replace view hr_employee_view as
    select * from employees where dept_id = 102;
grant select on hr_employee_view to hr_team;

create or replace view finance_employee_view as
    select emp_id, emp_name, salary from employees;
grant select on finance_employee_view to finance_team;

-- part 8
create or replace view dept_dashboard as
    select
        d.dept_name, d.location,
        count(distinct e.emp_id) as employee_count,
        round(avg(e.salary), 2) as avg_salary,
        count(distinct p.project_id) as active_projects,
        sum(distinct  p.budget) as total_budget,
        ROUND(
            COALESCE(SUM(p.budget), 0) /
            NULLIF(COUNT(DISTINCT e.emp_id), 0), 2
        ) AS budget_per_employee
    from departments d
    left join projects p on d.dept_id = p.dept_id
    left join employees e on d.dept_id = e.dept_id
    group by d.dept_name, d.location
    order by d.dept_name;

select * from dept_dashboard;
-- 8.2
alter table projects
add column create_date timestamp default current_timestamp;

create or replace view high_budget_projects as
    select
        p.project_name,
        p.budget,
        d.dept_name,
        p.create_date,
        case
            when p.budget > 150000 then 'critical review required'
            when p.budget > 100000 then 'Management approval needed'
            else 'Standard Process'
        end as approval_satatus
        from projects p
        left join departments d on d.dept_id = p.dept_id
        where budget > 75000
        order by p.budget desc;

select * from high_budget_projects;

-- 8.3
create role viewer_role;
grant select on all tables in schema public to viewer_role;
grant select on all sequences in schema public to viewer_role;

create role entry_role;
grant viewer_role to entry_role;
grant insert on employees to entry_role;
grant insert on projects to entry_role;

CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;

-- Разрешаем обновление данных
GRANT UPDATE ON employees, projects TO analyst_role;

CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;

-- Разрешаем удаление данных
GRANT DELETE ON employees, projects TO manager_role;

-- Создаем пользователей
CREATE USER alice PASSWORD 'alice123';
CREATE USER bob PASSWORD 'bob123';
CREATE USER charlie PASSWORD 'charlie123';

-- Назначаем им роли
GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;


