
CREATE DATABASE lab4;
\c lab
CREATE TABLE employees (
     employee_id SERIAL PRIMARY KEY,
     first_name VARCHAR(50),
     last_name VARCHAR(50),
     department VARCHAR(50),
     salary NUMERIC(10,2),
     hire_date DATE,
     manager_id INTEGER,
     email VARCHAR(100)
);
CREATE TABLE projects (
     project_id SERIAL PRIMARY KEY,
     project_name VARCHAR(100),
     budget NUMERIC(12,2),
     start_date DATE,
     end_date DATE,
     status VARCHAR(20)
);
CREATE TABLE assignments (
 assignment_id SERIAL PRIMARY KEY,
 employee_id INTEGER REFERENCES employees(employee_id),
 project_id INTEGER REFERENCES projects(project_id),
 hours_worked NUMERIC(5,1),
 assignment_date DATE
);
INSERT INTO employees (first_name, last_name, department, salary, hire_date, manager_id, email) VALUES
    ('John', 'Smith', 'IT', 75000, '2020-01-15', NULL,
    'john.smith@company.com'),
    ('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1,
    'sarah.j@company.com'),
    ('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL,
    'mbrown@company.com'),
    ('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL,
    'emily.davis@company.com'),
    ('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
    ('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3,
    'lisa.a@company.com');
INSERT INTO projects (project_name, budget, start_date, end_date, status) VALUES
    ('Website Redesign', 150000, '2024-01-01', '2024-06-30',
    'Active'),
    ('CRM Implementation', 200000, '2024-02-15', '2024-12-31',
    'Active'),
    ('Marketing Campaign', 80000, '2024-03-01', '2024-05-31',
    'Completed'),
    ('Database Migration', 120000, '2024-01-10', NULL, 'Active');
INSERT INTO assignments (employee_id, project_id, hours_worked, assignment_date) VALUES
    (1, 1, 120.5, '2024-01-15'),
    (2, 1, 95.0, '2024-01-20'),
    (1, 4, 80.0, '2024-02-01'),
    (3, 3, 60.0, '2024-03-05'),
    (5, 2, 110.0, '2024-02-20'),
    (6, 3, 75.5, '2024-03-10');



-- part1
select concat(first_name , ' ' , last_name) as full_name, department, salary from employees;
select distinct department from employees;
select project_name, budget,
       case
            when budget > 150000 then 'Large'
            when budget between 100000 and 150000 then 'Medium'
            else 'small'
       end as budget_category
from projects;
select concat(employees.first_name, ' ', employees.last_name) as full_name,
       coalesce(email, 'no email provided') as email
from employees;

-- part 2
select * from employees
where hire_date > '2020-01-1';
select * from employees
where salary between 60000 and 70000;
select * from employees
where last_name like 'S%' or last_name like 'j%';
select * from employees
where manager_id is not null and department='IT';

-- part 3
select upper(employees.first_name || ' ' || last_name) as ful_name,
       length(employees.last_name) as Lengtth_of_Last_Name,
       substring(email, 1,3) as email
from employees;
select  first_name, last_name,
        salary * 12 as anual_salary,
        round(salary/12, 2) as monthly_salary,
        salary* 0.10 as raise_mount
from employees;
select format('Projects:%s - Budget:$%s - Status:%s',
       projects.project_name, projects.budget, projects.status) as project from projects;
select concat(employees.first_name, ' ', employees.last_name) as full_name,
    date_part('year', age(current_date, employees.hire_date)) as in_company
from employees;
-- part 4
select department, round(avg(salary), 2) as avg_salary
from employees
group by department;
select projects.project_name, sum(a.hours_worked) as total_hours
from projects
join assignments a on projects.project_id = a.project_id
group by projects.project_name;
select employees.department, count(*) as number_employees from employees
group by department
having count(*) > 1;
select max(employees.salary) as max,
        min(employees.salary) as min,
        sum(employees.salary) as total
from employees;
-- part 5
(select employee_id, concat(first_name, ' ', last_name) as full_name, salary from employees
    where salary > 65000)
union
(select employee_id, concat(first_name, ' ', last_name) as full_name, salary from employees
    where hire_date < '2020-01-01');
SELECT employee_id, CONCAT(first_name, ' ', last_name) AS full_name, salary
FROM employees
WHERE department = 'IT'
INTERSECT
SELECT employee_id, CONCAT(first_name, ' ', last_name), salary
FROM employees
WHERE salary > 65000;

select employees.employee_id, concat(employees.first_name, ' ', employees.last_name) as full_name
from employees
except
select employees.employee_id, concat(employees.first_name, ' ', employees.last_name)
from employees
join assignments a on employees.employee_id = a.employee_id;

-- part 6
select employees.employee_id, concat(employees.first_name, ' ', employees.last_name) as full_name
from employees
where exists(
    select 1 from assignments
             where employees.employee_id =  assignments.employee_id
);
SELECT e.employee_id, CONCAT(e.first_name, ' ', e.last_name) AS full_name
FROM employees e
WHERE e.employee_id IN (
    SELECT a.employee_id
    FROM assignments a
    JOIN projects p ON a.project_id = p.project_id
    WHERE p.status = 'Active'
);
SELECT employee_id, CONCAT(first_name, ' ', last_name) AS full_name, salary
FROM employees
WHERE salary > ANY (
    SELECT salary FROM employees WHERE department = 'Sales'
);

-- part 7
SELECT e.first_name || ' ' || e.last_name AS employee_name,
       e.department,
       ROUND(AVG(a.hours_worked), 2) AS avg_hours_worked,
       RANK() OVER (PARTITION BY e.department ORDER BY e.salary DESC) AS salary_rank
FROM employees e
LEFT JOIN assignments a ON e.employee_id = a.employee_id
GROUP BY e.employee_id, e.department, e.salary, e.first_name, e.last_name;
SELECT p.project_name,
       SUM(a.hours_worked) AS total_hours,
       COUNT(DISTINCT a.employee_id) AS num_employees
FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_name
HAVING SUM(a.hours_worked) > 150;
SELECT department,
       COUNT(*) AS total_employees,
       ROUND(AVG(salary), 2) AS avg_salary,
       (SELECT first_name || ' ' || last_name
        FROM employees e2
        WHERE e2.department = e1.department
        ORDER BY e2.salary DESC
        LIMIT 1) AS highest_paid_employee,
       GREATEST(MAX(salary), AVG(salary)) AS highest_metric,
       LEAST(MIN(salary), AVG(salary)) AS lowest_metric
FROM employees e1
GROUP BY department;




