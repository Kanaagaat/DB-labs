    -- Part A
    -- 1
    CREATE DATABASE advanced_lab;
    \c   advanced_lab;
    CREATE TABLE employees(
        empl_id serial primary key,
        first_name varchar(50),
        last_name varchar(50),
        department varchar(100),
        salary int,
        hire_date date,
        status varchar(50) DEFAULT 'Active'
    );
    CREATE TABLE departments (
        dept_id serial primary key,
        dept_name varchar(100),
        budget int,
        manager_id int
    );
    CREATE TABLE projects (
        project_id serial primary key,
        project_name varchar(100),
        dept_id int,
        start_date date,
        end_date date,
        budget int
    );
    -- Part B
    -- 2
    INSERT INTO employees (first_name, last_name, department)
    VALUES ('Sauranbay', 'Kanagat', 'Developer');
    -- 3
    INSERT INTO employees (first_name, last_name, department,  hire_date)
    VALUES  ('Erasyl', 'Nuradillov', 'Marketing', CURRENT_DATE);

    INSERT INTO employees (first_name, last_name, department,  hire_date)
    VALUES  ('Islam', 'Primkul', 'IT', CURRENT_DATE);
    -- 4
    INSERT INTO departments (dept_name, budget, manager_id)
    VALUES ('developer', 500000, 1),
           ('Marketing', 450000, 2),
           ('HR', 250000, 3);
    -- 5
    INSERT INTO employees(first_name, last_name, department, salary, hire_date)
    VALUES ('Darkhan', 'Aitkabyl', 'Management', 5000*1.1, CURRENT_DATE);
    -- 6
    CREATE TEMP TABLE temp_employees AS
        SELECT * FROM employees WHERE department = 'IT';
    -- Part C
    -- 7
    UPDATE employees
        SET  salary = salary * 1.10;
    -- 8
    UPDATE employees
        SET status = 'Senior'
        WHERE salary > 60000
        AND hire_date < '2020-01-01';
    -- 9
    UPDATE employees
        SET department =
            CASE
                WHEN salary > 80000 THEN 'Management'
                WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
                ELSE 'Junior'
            END;
    -- 10
    UPDATE employees
        SET department = DEFAULT
        WHERE  status = 'Inactive';
    -- 11
    UPDATE departments d
        SET budget = (
                SELECT AVG(salary) * 1.2 FROM employees e
                WHERE e.department = d.dept_name
            );
    -- 12
    UPDATE employees
        SET salary = salary * 1.15,
            status = 'Promoted'
        WHERE  department = 'Sales';


-- Part D
-- 13
    DELETE FROM employees WHERE status = 'Terminated';
-- 14
    DELETE FROM employees
        WHERE salary < 40000
          AND hire_date > '2023-01-01'
          AND department IS NULL;
-- 15
    DELETE FROM departments
    WHERE dept_name NOT IN (
        SELECT  DISTINCT department FROM employees
                WHERE   department IS NOT NULL
        );
-- 16
    DELETE FROM projects
        WHERE  end_date < '2023-01-01'
        RETURNING *;
-- PART E
-- 17
    INSERT INTO employees(FIRST_NAME, LAST_NAME, DEPARTMENT, SALARY, HIRE_DATE)
        VALUES ('Joshua', 'Kreig', Null, Null, current_date);
-- 18
    UPDATE employees
        SET department = 'Unassigned'
        WHERE department IS NULL;
-- 19
    DELETE FROM employees
    WHERE salary IS NULL
       OR department IS NULL;
-- PART F
-- 20
    INSERT INTO employees(FIRST_NAME, LAST_NAME, DEPARTMENT, SALARY, HIRE_DATE)
    VALUES ('Valentin', 'Strykalo', 'HR',65000,current_date )
    returning empl_id , first_name || ' ' || last_name as full_name;
-- 21
    UPDATE employees
    SET salary = salary + 5000
    WHERE department = 'IT'
    RETURNING  empl_id, salary - 5000 AS old_salary, salary AS new_salary;
-- 22
    delete from employees
    where hire_date < '2020-01-01'
    returning *;
-- part g
-- 23
    INSERT INTO employees(first_name, last_name, department)
    SELECT 'Kukuruza', 'Vanil', 'IT'
    WHERE NOT EXISTS(SELECT 1 FROM employees
                              WHERE first_name = 'Kukuruza' and last_name = 'Vanil');
-- 24
    UPDATE employees e
        SET salary = salary * CASE
            WHEN (SELECT budget FROM departments d
                        WHERE d.dept_name = e.department) > 100000
                        THEN 1.10
            ELSE 1.05
        END;
-- 25
    INSERT INTO employees(FIRST_NAME, LAST_NAME, DEPARTMENT, salary)
    VALUES ('Miras', 'Ibraev', 'IT', 600000),
           ('Dulat', 'Amangeldiev', 'HR', 75000),
           ('Yerassyl', 'Amangeldi', 'Sales',55000),
           ('Daniyal', 'Amangeldiev', 'Marketing', 70000),
           ('Kenzhebek', 'Talgatov', 'IT', 95000);
    UPDATE employees
        SET salary = salary * 1.10
        WHERE department = 'IT';
-- 26
    CREATE TABLE employee_archive (LIKE employees INCLUDING ALL);
    INSERT INTO employee_archive
    SELECT * FROM employees;
    DELETE FROM employees
    WHERE status = 'Inactive';
-- 27
    UPDATE projects p
    SET end_date = end_date + interval '30 days'
    where budget > 5000 and
          (SELECT COUNT(*) FROM employees e
                           JOIN departments d ON e.department = d.dept_name
                           WHERE d.dept_id = p.dept_id) > 3;





