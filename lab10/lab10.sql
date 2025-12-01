create database lab10;
\c lab10;

CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0.00
);
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    shop VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);
-- Insert test data
INSERT INTO accounts (name, balance) VALUES
    ('Alice', 1000.00),
    ('Bob', 500.00),
    ('Wally', 750.00);
INSERT INTO products (shop, product, price) VALUES
('Joe''s Shop', 'Coke', 2.50),
    ('Joe''s Shop', 'Pepsi', 3.00);


-- part 3.2
-- task 1

BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';
COMMIT;

select  * from accounts;
-- a) Alice: 900, Bob: 600.
-- b) To keep it atomic: either both updates happen or none.
-- c) Money could be taken from Alice but not added to Bob → inconsistent state.
-- task 3.3
BEGIN;
UPDATE accounts SET balance = balance - 500.00 -- 900 - 500
WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice'; -- Oops! Wrong amount, let's undo 400
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';
--а) 400
--b) 900
--c) The user cancels an operation mid-way

--3.4
BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';
-- Oops, should transfer to Wally instead
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Wally';
COMMIT;

select * from accounts;
-- a) Alice: 900, Bob: 500, Wally: 850.
-- b) Bob was credited but that step was rolled back to the savepoint.
-- c) You can undo only part of a transaction instead of restarting everything.


--3.5
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to make changes and COMMIT
-- Then re-run:
SELECT * FROM products WHERE shop = 'Joe''s Shop'; COMMIT;

--terminal 2
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
    VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;


BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

--
-- a) READ COMMITTED: first query – old rows, second – new rows after T2 commits.
-- b) SERIALIZABLE: sees one consistent snapshot (or gets serialization error).
-- c) READ COMMITTED allows seeing others’ commits during the transaction;
--    SERIALIZABLE does not.

-- 3.6

-- Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products
    WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2
SELECT MAX(price), MIN(price) FROM products
    WHERE shop = 'Joe''s Shop';
COMMIT;
-- Terminal 2:
BEGIN;
INSERT INTO products (shop, product, price)
    VALUES ('Joe''s Shop', 'Sprite', 4.00);
COMMIT;

-- a) With standard REPEATABLE READ, it can miss the new row (phantom possible).
-- b) Phantom read: same query returns a different set of rows
-- because new rows were inserted/deleted.
-- c) Only SERIALIZABLE fully prevents phantoms.

-- task 3.7
-- Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to UPDATE but NOT commit
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to ROLLBACK
SELECT * FROM products WHERE shop = 'Joe''s Shop'; COMMIT;
-- Terminal 2:
BEGIN;
UPDATE products SET price = 99.99
WHERE product = 'Fanta';
-- Wait here (don't commit yet) -- Then:
ROLLBACK;

-- a) Yes, it can see 99.99; problem: that value never really existed
-- after ROLLBACK
-- b) Dirty read: reading uncommitted changes from another transaction
-- c) It breaks data integrity; usually should not be used


-- part 4
-- 1
BEGIN;

SELECT balance FROM accounts
WHERE name = 'Bob'
FOR UPDATE;
UPDATE accounts SET balance = balance - 200 WHERE name='Bob';
UPDATE accounts SET balance = balance + 200 WHERE name='Wally';

COMMIT;


-- ex2
BEGIN;
INSERT INTO products (shop, product, price)
VALUES ('My Shop', 'Apple', 1.00);
SAVEPOINT sp1;
UPDATE products SET price = 2.00 WHERE product = 'Apple';
SAVEPOINT sp2;
DELETE FROM products WHERE product = 'Apple';
ROLLBACK TO sp1;
COMMIT;


-- Terminal 1
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT balance FROM accounts WHERE id = 1 FOR UPDATE; -- locks row
-- balance = 100, proceed with withdrawal
UPDATE accounts SET balance = balance - 80 WHERE id = 1;
COMMIT;

-- tr2
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- 1. Проверяем баланс (все еще видим 1000, т.к. Т1 не закоммитил)
SELECT balance FROM accounts WHERE name = 'Alice';
-- 2. Тоже снимаем 800 (1000 - 800 = 200)
UPDATE accounts SET balance = balance - 800.00 WHERE name = 'Alice';
COMMIT;
-- Alice's balance will become 200.00 (or -600,
-- if the UPDATE was balance = balance - 800).
-- If the logic was "read -> mentally calculate -> write down the new number,
-- " then both would write 200. Lost update!