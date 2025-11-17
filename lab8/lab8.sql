create database lab8;
\c lab8;

CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(100),
 dept_id INT,
 salary DECIMAL(10,2),
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
CREATE TABLE projects (
 proj_id INT PRIMARY KEY,
 proj_name VARCHAR(100),
 budget DECIMAL(12,2),
 dept_id INT,
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
-- Insert sample data
INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');
INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);
INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102);

-- part 2
create index emp_salary_idx on employees(salary);
-- List all indexes on employees table
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'employees';
-- 2 indexes

-- 2.2
create index dept_id_idx on employees(dept_id);
SELECT * FROM employees WHERE dept_id = 101;
-- to speed up joins and integrity cheks

-- 2.3
select tablename, indexname, indexdef from pg_indexes where schemaname = 'public'
order by tablename, indexname;

-- part 3
create index dept_salary_idx on employees(dept_id, salary);

-- This query can use the multicolumn index
SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;
-- only if salary is first column, otherwise no

-- 3.2
create index emp_salary_deptid_idx on employees(dept_id, salary);

SELECT * FROM employees WHERE dept_id = 102 AND salary = 50000;
SELECT * FROM employees WHERE salary = 50000 AND dept_id = 102;
-- Yes, the index is most effective if the query filters on the leftmost index column.

-- part 4
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;
create unique index emp_email_idx on employees(email);
INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');
-- Unique constraint violation error.
-- 4.2
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'employees' AND indexname LIKE '%phone%';
-- Yes, it automatically created a UNIQUE B-tree index.

-- part 5
create index emp_salary_desc on employees(salary desc );
select emp_name, salary from employees
order by salary desc;
-- fast sorting

-- 5.2
create index proj_budget_null_first_idx on projects(budget nulls first);

SELECT proj_name, budget FROM projects ORDER BY budget NULLS FIRST;
-- part 6

create index emp_name_lower_idx on employees(lower(emp_name));

SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';
-- postgres scan all rows and applies lower to each

-- 6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

create index emp_hire_year_idx on employees(extract(year from hire_date));

SELECT emp_name, hire_date FROM employees WHERE EXTRACT(YEAR FROM hire_date) = 2020;

-- part 7
alter index emp_salary_idx rename to employees_salary_index;
select indexname from pg_indexes where tablename = 'employees';

-- 7.2
drop index emp_salary_deptid_idx;
-- reduce disk space if it rarely used
-- 7.3
reindex index employees_salary_index;
-- after massive insertion
-- part 8
SELECT e.emp_name, e.salary, d.dept_name FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

create index emp_filter_salary_idx on employees(salary) where salary > 50000;

create index proj_high_budget on projects(budget) where budget > 80000;
SELECT proj_name, budget
FROM projects
WHERE budget > 80000;
-- Faster queries for subset, smaller and more efficient than full index.
explain select * from employees where salary > 52000;
-- Index Scan means index used; Seq Scan means not used. Use EXPLAIN to check.
-- part 9
create index dept_name_idx on departments using hash(dept_name);
SELECT * FROM departments WHERE dept_name = 'IT';
-- 9.2
create index proj_name_btree_idx on projects(proj_name);
create index proj_name_hash_idx on projects(proj_name);

-- Equality search (both can be used)
SELECT * FROM projects WHERE proj_name = 'Website Redesign';
-- Range search (only B-tree can be used)
SELECT * FROM projects WHERE proj_name > 'Database';

-- part 10
select schemaname,tablename, indexname, pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
from pg_indexes where schemaname = 'public' order by tablename, indexname;


drop index if exists proj_name_hash_idx

create view index_documentation as
    select
        tablename,
        indexname,
        indexdef,
        'improves  salary-based-queries' as purpose
    from pg_indexes
    where schemaname = 'public'
    and indexname like '%salary%';

select * from index_documentation;