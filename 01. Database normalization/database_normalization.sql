----- CREATE DB
CREATE DATABASE sales;

----- CREATE TABLE AND IMPORT DATA
CREATE TABLE transactions (
    transactionid varchar,
    timestampsec timestamp,
    customerid varchar,
    firstname varchar,
    surname varchar,
    shipping_state varchar,
    item varchar,
    description varchar,
    retail_price float(2),
    loyalty_discount float(2)
);

----- IMPORT DATA FROM CSV
COPY transactions FROM '/Users/sergeysuslov/Desktop/OLTP.csv' DELIMITER ',' HEADER CSV;

----- FIRST SNAPSHOT
SELECT *
FROM transactions;

----- CHECK 1NF: NO DUPLICATES + 1 VALUE IN 1 CELL
SELECT COUNT(*)
FROM transactions;
-- 3455 rows

SELECT COUNT(*)
FROM
	(
		SELECT DISTINCT *
	    FROM transactions
	 ) AS tmp;
-- 3455 rows
--1NF CONFIRMED 

----- CHECK 2NF: NON-PRIMARY ATTRIBUTES DEPEND ON EVERY PRIMARY
SELECT *
FROM transactions;
-- PRIMARY ATT: {transactionid} / {timestampsec, customerid}
-- As we can see, attributes like firstname, surname, shipping_state, loyalty_discount 
-- can be defined by customerid without timestampsec. Let's correct that

CREATE TABLE customers AS
SELECT DISTINCT *
FROM 
	(
		SELECT customerid,
			   firstname,
			   surname,
			   shipping_state,
			   loyalty_discount
		FROM transactions
	) AS tmp;

SELECT *
FROM customers
-- 942 rows

ALTER TABLE transactions
DROP COLUMN firstname,
DROP COLUMN surname,
DROP COLUMN shipping_state,
DROP COLUMN loyalty_discount

SELECT *
FROM transactions;
-- 2NF CONFIRMED

----- CHECK 3NF: NO INDIRECT DEPENDENCE BETWEEN NON-PRIMARY AND PRIMARY ATTRIBUTES
-- AS WE CAN SEE item can be defined by transactionid, meanwhile description and retail_price by item
CREATE TABLE items AS (
SELECT DISTINCT *
FROM
	(
		SELECT item,
			   description,
			   retail_price
		FROM transactions
	) AS tmp;
)

SELECT *
FROM items
--126 rows

ALTER TABLE transactions
DROP COLUMN description,
DROP COLUMN retail_price

SELECT *
FROM transactions;
--3NF CONFIRMED

----- DATA FOR DOWNLOAD
SELECT t.transactionid, t.timestampsec, c.*, i.*
FROM transactions t
LEFT JOIN customers c ON t.customerid = c.customerid
LEFT JOIN items i ON t.item = i.item