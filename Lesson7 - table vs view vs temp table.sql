--  Lesson # 7 Table vs View vs Temp Table
-- Homework Part 1 - Answers to 24 questions - classicmodels database
select * from classicmodels.customers; 
select * from classicmodels.employees;
select * from classicmodels.offices;
select * from classicmodels.payments;
select * from classicmodels.orderdetails;
select * from classicmodels.orders;
select * from classicmodels.productlines;
select * from classicmodels.products;

select count(*) from classicmodels.customers;-- 122
select count(*) from classicmodels.employees; -- 23
select count(*) from classicmodels.offices; -- 7
select count(*) from classicmodels.payments; -- 273
select count(*) from classicmodels.orderdetails; -- 2996
select count(*) from classicmodels.orders; -- 326
select count(*) from classicmodels.productlines; -- 7
select count(*) from classicmodels.products; -- 110


-- 1.how many vendors, product lines, and products exist in the database?
SELECT
	COUNT(distinct ProductVendor) as Vendors_count,
	COUNT(distinct ProductLine) as Product_lines_count,
	COUNT(distinct productCode) as Products_count
FROM classicmodels.products;

-- 2.what is the average price (buy price, MSRP) per vendor?
SELECT
	productVendor,
    AVG (buyPrice) as AvgPrice,
    AVG (MSRP) as AvgMSRP
FROM classicmodels.products
GROUP BY productVendor;    

-- 3.what is the average price (buy price, MSRP) per customer?
SELECT
orders.customerNumber, AVG(det.priceEach) as AvgPrice, AVG(prod.buyPrice) as AvgBuyPrice, AVG(prod.MSRP) as AvgMSRP 
FROM classicmodels.orders orders 
JOIN classicmodels.orderdetails det on det.orderNumber = orders.orderNumber
JOIN classicmodels.products prod on prod.productCode = det.productCode
GROUP BY orders.customerNumber
ORDER BY orders.customerNumber;

-- 4.Pay Attention!!! which fields: productCode or quatityOrdered?
-- what product was sold the most?
SELECT prod.productName,
COUNT(prod.productCode) as prod_cnt, 
SUM(det.quantityOrdered) as quantity_ordered_sum,
MAX(det.quantityOrdered) as order_cnt
FROM classicmodels.orderdetails det
JOIN classicmodels.products prod ON det.productCode = prod.productCode
GROUP BY prod.productCode
ORDER BY prod_cnt DESC -- order_cnt DESC 
LIMIT 1;


-- 5.how much money was made between buyPrice and MSRP?
-- wrong!
SELECT 
-- msrp, buyPrice, (msrp - buyPrice)difference
SUM(msrp - buyPrice) as moneyMade, SUM(msrp)- SUM(buyPrice) as difference
-- select * 
FROM classicmodels.products;

-- correct
SELECT SUM(prod.msrp * det.quantityOrdered) as msrp_sales, 
SUM(prod.buyPrice * det.quantityOrdered) as buyPrice_sales,
SUM(prod.msrp * det.quantityOrdered) - SUM(prod.buyPrice * det.quantityOrdered) as difference_in_sales
FROM classicmodels.products prod
JOIN classicmodels.orderdetails det on prod.productCode = det.productCode


-- 6.which vendor sells 1966 Shelby Cobra?
SELECT prod.productVendor, prod.productName
FROM classicmodels.products prod
WHERE prod.productName LIKE '1966 Shelby Cobra%';

-- 7.which vendor sells more products?
SELECT prod.productVendor, SUM(det.quantityOrdered) as quantity, count(det.productcode) as quantity2
FROM classicmodels.products prod
JOIN classicmodels.orderdetails det on prod.productCode = det.productCode
GROUP BY prod.productVendor
ORDER BY quantity desc
LIMIT 1;


-- 8.which product is the most and least expensive?
(SELECT msrp as mostexp, productName 
FROM classicmodels.products
ORDER BY msrp desc
LIMIT 1)
UNION
(SELECT msrp as leastexp, productName 
FROM classicmodels.products
ORDER BY msrp 
LIMIT 1);

-- 9.which product has the most quantityInStock?
SELECT productName, quantityInStock  -- select *
FROM classicmodels.products
ORDER BY quantityInStock desc
LIMIT 1;

-- 10.list all products that have quantity in stock less than 20
SELECT productName, quantityInStock
FROM classicmodels.products
WHERE quantityInStock < 20;

-- 11.which customer has the highest and lowest credit limit?
(SELECT customerNumber, creditLimit as highestLimit
FROM classicmodels.customers
ORDER BY creditlimit desc
LIMIT 1)
UNION
(SELECT customerNumber, creditLimit as lowestLimit
FROM classicmodels.customers
ORDER BY creditlimit
LIMIT 1);

-- 12.rank customers by credit limit
select customerNumber, creditLimit,
RANK() OVER (ORDER BY creditLimit DESC) as credlimit
from classicmodels.customers;

-- 13
-- #1 list the most sold product by city
WITH a as (
SELECT c.City, od.productCode, sum(quantityOrdered) as quantitySold,
(ROW_NUMBER() OVER (PARTITION BY c.City ORDER BY sum(quantityOrdered) DESC)) as rowNum
FROM classicmodels.orderDetails od
JOIN classicmodels.orders o on o.orderNumber = od.orderNumber
JOIN classicmodels.customers c on c.customerNumber = o.customerNumber
GROUP BY c.City, od.productCode
) 
SELECT a.City, a.productCode, a.quantitySold
FROM a
WHERE rowNum = 1;

-- #2 list the most sold product by city
select * from (
select  oc.city, p.productname, SUM(od.quantityOrdered), COUNT(p.productcode)
,RANK() OVER (PARTITION BY oc.city ORDER BY sum(od.quantityOrdered) DESC)  as myrank
from classicmodels.offices oc 
join classicmodels.employees e on oc.officecode=e.officecode
join classicmodels.customers c on c.salesrepemployeenumber=e.employeenumber
join classicmodels.orders o on o.customernumber=c.customernumber
join classicmodels.orderdetails od on o.ordernumber=od.ordernumber
join classicmodels.products p on p.productcode=od.productcode
group by  oc.city, p.productname) a
where myrank = 1 ;

-- 14
-- #1 customers in what city are the most profitable to the company?
SELECT c.city, p.amount as payedAmount
FROM classicmodels.customers c
JOIN classicmodels.payments p ON c.customerNumber = p.customerNumber 
ORDER BY p.amount desc
LIMIT 1;

-- #2
select  c.city, sum(quantityordered*priceeach) as revenue 
from classicmodels.customers c 
join classicmodels.orders o on c.customernumber=o.customernumber
join classicmodels.orderdetails od on o.ordernumber=od.ordernumber
group by c.city 
order by revenue desc 
limit 1;

-- 15
-- #1 what is the average number of orders per customer?
SELECT (COUNT(orderNumber)/COUNT(distinct customerNumber)) as avgPerCust
FROM classicmodels.orders;
-- #2
select -- c.customername, 
AVG(quantityordered) 
from classicmodels.customers c 
join classicmodels.orders o on c.customernumber=o.customernumber
join classicmodels.orderdetails od on o.ordernumber=od.ordernumber
-- group by c.customername
-- order by avg(quantityordered) desc;

-- 16
-- #1 who is the best customer?
SELECT c.customerName as BestCustomer, p.amount as amountPayed
FROM classicmodels.payments p
JOIN classicmodels.customers c ON p.customerNumber = c.customerNumber
ORDER BY amount desc
LIMIT 1;
-- #2
select  c.customername, sum(quantityordered*priceeach) as revenue 
from classicmodels.customers c join classicmodels.orders o on c.customernumber=o.customernumber
join classicmodels.orderdetails od on o.ordernumber=od.ordernumber
group by c.customername 
order by revenue desc 
limit 1;

-- 17
-- customers without payment
SELECT c.customerNumber, c.customerName, p.amount
FROM classicmodels.customers c
LEFT JOIN classicmodels.payments p ON c.customerNumber = p.customerNumber
WHERE p.amount is Null;

-- 18
-- #1  what is the average number of days between the order date and ship date?
SELECT SUM(datediff(shippedDate,orderDate))/count(*) as averageDays -- 3.5951
FROM classicmodels.orders;
-- #2
SELECT AVG(datediff(shippedDate,orderDate)) as averageDays -- 3.7564
FROM classicmodels.orders;

-- 19
-- sales by year
SELECT
YEAR(paymentDate) as years, sum(amount) as sales 
FROM classicmodels.payments
GROUP BY years
ORDER BY years;

-- 20
-- how many orders are not shipped?
SELECT COUNT(*) -- select *
FROM classicmodels.orders 
where shippeddate is null;
-- where status <> 'Shipped'; -- wrong because there customers that are in 'Disputed' status

-- 21
-- list all employees by their (full name: first + last) in alpabetical order
SELECT
CONCAT(lastName,' ', firstName) as fullName
FROM classicmodels.employees
ORDER BY fullName;

-- 22
-- list of employees  by how much they sold in 2003?
SELECT CONCAT(e.lastName, ' ',e.firstName) as fullName, YEAR(p.paymentDate) as Year_sold, YEAR(o.orderdate) as Year_ordered, sum(p.amount) as sold
FROM classicmodels.employees e
JOIN classicmodels.customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN classicmodels.payments p ON c.customerNumber = p.customerNumber
-- for payments
-- where YEAR(p.paymentDate) = 2003
-- for orders: 
JOIN classicmodels.orders o on o.customernumber=c.customernumber
where o.orderdate between'2003-01-01' and '2003-12-31'
GROUP BY fullName
ORDER BY fullName, p.amount;

-- 23
-- which city has the most number of employees?
SELECT o.city, COUNT(employeeNumber) as empNumber 
FROM classicmodels.employees e
JOIN classicmodels.offices o ON e.officeCode = o.officeCode
GROUP BY o.city
ORDER BY empNumber desc
LIMIT 1;

-- 24
-- which office has the biggest sales?
SELECT o.city, SUM(p.amount) as salesAmount
FROM classicmodels.offices o
JOIN classicmodels.employees e ON o.officeCode = e.officeCode
JOIN classicmodels.customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN classicmodels.payments p ON c.customerNumber = p.customerNumber
GROUP BY o.city
ORDER BY salesAmount desc
LIMIT 1;

-- Advanched Homework
-- join all tables together
SELECT count(1)-- 2,996
FROM classicmodels.customers c
JOIN classicmodels.employees e ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN classicmodels.offices o ON e.officeCode = o.officeCode
JOIN (select customerNumber, max(paymentDate) as paymentDate, sum(amount) as amount 
from classicmodels.payments group by customerNumber) p ON c.customerNumber = p.customerNumber
JOIN classicmodels.orders orders ON c.customerNumber = orders.customerNumber
JOIN classicmodels.orderdetails det ON orders.orderNumber = det.orderNumber
JOIN classicmodels.products pr ON det.productCode = pr.productCode
JOIN classicmodels.productlines pl ON pr.productLine = pl.productLine;

-- join all tables together [12,015 ROWS]
SELECT * FROM classicmodels.orders o 
JOIN classicmodels.orderdetails od ON o.orderNumber=od.orderNumber
JOIN classicmodels.customers c ON o.customerNumber=c.customerNumber
JOIN classicmodels.products p ON od.productCode=p.productCode
JOIN classicmodels.productlines pl ON p.productLine=pl.productLine
JOIN classicmodels.employees e ON c.salesRepEmployeeNumber=e.employeeNumber
JOIN classicmodels.payments py ON c.customerNumber=py.customerNumber
JOIN classicmodels.offices off ON e.officeCode=off.officeCode;
-- ---------------------------------------------------

-- Homework - Part #2
-- count distinct movies
select count(distinct title) from film.film_locations_in_san_francisco; -- 325

-- count of all films by release year
select `release year`, count(distinct title) as movie_cnt 
from film.film_locations_in_san_francisco
group by `release year`; 

-- count of all films by 'production company'
select `production company`, count(distinct title) movie_cnt
from film.film_locations_in_san_francisco
group by `production company`; 

-- count of all films directed by Woody Allen
select director, count(distinct title) movie_cnt
from film.film_locations_in_san_francisco
where director like '%Woody Allen%'
group by director; 

-- how many movies have/don't have fun facts?
select case when `fun facts` = '' then 'no' else 'yes' end fun_fact, 
count(distinct title) movie_cnt
from film.film_locations_in_san_francisco
group by case when `fun facts` = '' then 'no' else 'yes' end; 

-- in how many movies were Keanu Reeves and Robin Williams?
select count(distinct title) movie_cnt
from film.film_locations_in_san_francisco
where `actor 1` in ('Keanu Reeves', 'Robin Williams')
or `actor 2` in ('Keanu Reeves', 'Robin Williams')
or `actor 3` in ('Keanu Reeves', 'Robin Williams');




-- ----------------- Lesson #7 Table / View / Temp Table -----------------------
-- TABLE                      -- stored set of data, exist until droped
-- drop table mywork.payments_10000;
create table mywork.payments_10000 as
select customerNumber, checkNumber, paymentDate, amount
from classicmodels.payments
where amount <=10000
order by amount desc;
-- ---------------------------------------------------
-- VIEW						  -- like "saved query", virtual table, exist until droped
-- drop view mywork.v_payments_10000;
create view mywork.v_payments_10000 as
select customerNumber, checkNumber, paymentDate, amount
from classicmodels.payments
where amount <=10000
order by amount desc;
-- ---------------------------------------------------
-- TMP TABLE					-- stored set of data until session is closed; exists only in current session
-- drop table mywork.tmp_payments_10000;
create temporary table mywork.tmp_payments_10000 as
select customerNumber, checkNumber, paymentDate, amount
from classicmodels.payments
where amount <=10000
order by amount desc; 

select * from mywork.payments_10000;
desc mywork.payments_10000;
select * from mywork.v_payments_10000;
desc mywork.v_payments_10000;
select * from mywork.tmp_payments_10000;
desc mywork.tmp_payments_10000;

-- -------------------------- SQL vs. NoSQL Database ----------------------------------
-- https://www.ml4devs.com/articles/datastore-choices-sql-vs-nosql-database/
Databases have 5 components: interface, query processor, metadata, indexes, and storage:

1.Interface Language or API: Each database defines a language or API to interact with it. 
It covers definition, manipulation, query, and control of data and transactions.
2.Query Processor: The “CPU” of the database. Its job is to process incoming requests, perform needed actions, and return results.
The Query Processor performs the following steps for each incoming request:
Parses the request and validates it against the metadata.
Creates an efficient execution plan that exploits the indexes.
Reads or updates the storage.
Updates metadata and indexes.
Computes and returns results.
3.Storage: The disk or memory where the data is stored.
4.Indexes: Data structures to quickly locate the queried data in the storage.
5.Metadata: Meta-information of data, storage. and indexes (e.g., catalog, schema, size).
-- --------------------------------------------------------------------
SQL
Tabular datastores are suitable for storing structured data. 
Each record (row) has the same number of attributes (columns) of the same type.
There are two kinds of applications:
Online Transaction Processing (OLTP): Capture, store, and process data from transactions in real-time.
Online Analytical Processing (OLAP): analyze aggregated historical data from OLTP applications.
Relation Database Management Systems (RDBMS) are one of the earliest datastores. The data is organized in tables. 
Tables are normalized for reduced data redundancy and better data integrity.
Tables may have primary and foreign keys:
Query and transactions are coded using Structured Query Language (SQL).
Relational databases are optimized for transaction operations. Transactions often update multiple records in multiple tables. 
Indexes are optimized for frequent low-latency writes of 
-- ACID Transactions:
Atomicity: Any transaction that updates multiple rows is treated as a single unit. A successful transaction performs all updates. 
A failed transaction performs none of the updates, i.e., the database is left unchanged.
Consistency: Every transaction brings the database from one valid state to another. It guarantees to maintain all database invariants and constraints.
Isolation: Concurrent execution of multiple transactions leaves the database in the same state as if the transactions were executed sequentially.
Durability: Committed transactions are permanent, and survive even a system crash.

Cloud Agnostic: Oracle, Microsoft SQL Server, IBM DB2, PostgreSQL, and MySQL
AWS: Hosted PostgreSQL and MySQL in Relational Database Service (RDS)
Microsoft Azure: Hosted SQL Server as Azure SQL Database
Google Cloud: Hosted PostgreSQL and MySQL in Cloud SQL, and also horizontally scaling Cloud Spanner

Big Data Modern Data Warehouses are built on Columnar databases. Data is stored by columns instead of by rows. 
Available choices are:
AWS: RedShift
Azure: Synapse
Google Cloud: BigQuery
Apache: Druid, Kudu, Pinot
Others: ClickHouse, Snowflake

-- ----------------------------------------------------------------------------
NoSQL for Semi-structured Data
NoSQL datastores cater to semi-structured data 4 types: key-value, wide column, document (tree), and graph.

1.Key-Value Datastore
A key-value store is a dictionary or hash table database. 
It is designed for CRUD operations with a unique key for each record:
-- CRUD operations
Create(key, value): Add a key-value pair to the datastore
Read(key): Lookup the value associated with the key
Update(key, value): Change the existing value for the key
Delete(key): Delete the (key, value) record from the datastore
The values do not have a fixed schema and can be anything from primitive values to compound structures. 
Key-value stores are highly partitionable (thus scale horizontally). 
DB: Redis

2.Wide-column Datastore
A wide-column store has tables, rows, and columns. 
But the names of the columns and their types may be different for each row in the same table. 
Logically, It is a versioned sparse matrix with multi-dimensional mapping (row-value, column-value, timestamp). 
It is like a two-dimensional key-value store, with each cell value versioned with a timestamp.
Wide-column datastores are highly partitionable.
DB: Cassandra

3.Document Datastore
Document stores are for storing and retrieving a document consisting of nested objects. a tree structure such as XML, JSON, and YAML.
DB: MongoDB

4.Graph Datastore
Graph databases are like document stores but are designed for graphs instead of document trees. 
For example, a graph database will suit to store and query a social connection network.
DB: Neo4J, JanusGraph 

-- --------------------------------------------------------------------
SQL vs. NoSQL Database Comparison
Non-relational NoSQL datastores gained popularity for two reasons:
1.RDBMS did not scale horizontally for Big Data
2.Not all data fits into strict RDBMS schema

NoSQL datastores offer horizontal scale at various CAP Theorem tradeoffs. 
-- CAP Theorem
As per CAP Theorem, a distributed datastore can give at most 2 of the following 3 guarantees:
Consistency: Every read receives the most recent write or an error. (latest verion)
Availability: Every request gets a (non-error) response, regardless of the individual states of the nodes. (data returned event if one of the servers/nodes is down)
Partition tolerance: The cluster does not fail despite an arbitrary number of messages being dropped (or delayed) by the network between nodes. (cluster is still up even if some nodes are down)
   Note that the consistency definitions in CAP Theorem and ACID Transactions are different. 
   ACID consistency is about data integrity (data is consistent w.r.t. relations and constraints after every transaction). 
   CAP is about the state of all nodes being consistent with each other at any given time.

Only a few NoSQL datastores are ACID-complaint. Most NoSQL datastore support BASE model:
-- BASE model
Basically Available: Data is replicated on many storage systems and is available most of the time.
Soft-state: Replicas are not consistent all the time; so the state may only be partially correct as it may not yet have converged.
Eventually consistent: Data will become consistent at some point in the future, but no guarantee when.

-- --------------------------------------------------------------------
Difference between SQL and NoSQL
Differences between RDBMS and NoSQL databases stem from their choices for:
Data Model: RDBMS databases are used for normalized structured (tabular) data strictly adhering to a relational schema. 
NoSQL datastores are used for non-relational data, e.g. key-value, document tree, graph.
Transaction Guarantees: All RDBMS databases support ACID transactions, but most NoSQL datastores offer BASE transactions.
CAP Tradeoffs: RDBMS databases prioritize strong consistency over everything else. 
But NoSQL datastores typically prioritize availability and partition tolerance (horizontal scale) and offer only eventual consistency.

SQL vs. NoSQL Performance
NoSQL datastores are designed for efficiently handling a lot more data than RDBMS. 
There are no relational constraints on the data, and it does not need to be even tabular. 
NoSQL offers performance at a higher scale by typically giving up strong consistency. 
Data access is mostly through REST APIs. 
NoSQL query languages (such as GraphQL) are not yet as mature as SQL in design and optimizations. 
RDBMS scale vertically. You need to upgrade hardware (more powerful CPU, higher storage capacity) to handle the increasing load.
NoSQL datastores scale horizontally. NoSQL is better at handling partitioned data, so you can scale by adding more machines.
-- ---------------------------------------------------
-- Homework #7 
-- Data Cleaning Project - English Dicionary
-- Import two files english_dictionary_master.csv and english_dictionary_most_common_words.csv
-- (Source: http://www.rupert.id.au/resources/1000-words.php)
-- 1.Edit - Preferences - SQL Editor - change RDBMS timout connection to 600
-- 2.Create database Dictionary;
-- 3.Right click on database dictinary - Table Data Import Wizard - dictionary.english_dictionary_master - Next
-- Right click on database dictinary - Table Data Import Wizard - dictionary.english_dictionary_most_common_words - Next
-- Get to know the data: n - noun, a - adjective, v - verb, adverb, preposition
-- 4.Show counts of both tables
-- 5.Create copies of both tables just in case you accidentally delete the originals
-- 6.Rename column type to word_type and definition to word_def
-- 7.Update column word_type and word_def to remove " and .
-- 8.Add column is_common to master table and update this column with 'yes' for common words 
-- 9.Using trim functon get rid off extra spaces in all columns in dictionary.english_dictionary_master
-- 10.
-- Query: how many distinct common/uncommon words are in the table?
-- Query: how many distinct word_types are in the table?
-- Query: find all english words for different colors (e.g. bronze, ruby, white, pink, red, azure, blue, etc.)
-- Query: randomly select 4 nouns and ajectives (order by rand())
-- Query: create separtate columns for each letter in the word -- use substr function







