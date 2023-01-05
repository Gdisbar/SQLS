/*create a schema*/
create schema 'schema_name';
/*select a table under a schema*/
select * from schema_name.table_name;
/* check EER in data modeling of sql workbench*/

/*Connecting to MySQL using Python connector & API*/

#!/usr/bin/python

import MySQL.connector
from MySQL.connector import errorcode


try:
  db = MySQL.connector.connect(user='root', password='datasoft123',
                                host='127.0.0.1', database='sakila')
except MySQL.connector.Error as err:
  if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
    print("Acess denied/wrong  user name or password")
  elif err.errno == errorcode.ER_BAD_DB_ERROR:
    print("Database does not exists")
  else:
    print(err)
else:
  db.close()


table: employees
+-------------+-------------+-------------+----------+--------------------+------------+------------+----------+----------------+------------+---------------+
| EMPLOYEE_ID | FIRST_NAME  | LAST_NAME   | EMAIL    | PHONE_NUMBER       | HIRE_DATE  | JOB_ID     | SALARY   | COMMISSION_PCT | MANAGER_ID | DEPARTMENT_ID |
+-------------+-------------+-------------+----------+--------------------+------------+------------+----------+----------------+------------+---------------+

get the names (first_name, last_name), salary of the employees whose salary 
greater than the average salary of all department.

/*SQL code*/
SELECT b.first_name,b.last_name 
FROM employees b 
WHERE NOT EXISTS (SELECT 'X' FROM employees a WHERE a.manager_id = b.employee_id);

/*python code*/
#!/usr/bin/python
import MySQL.connector

db =  MySQL.connector.connect(host="localhost", # Host, usually localhost
                     user="root", # your username
                     password="**********", # your password
                     db="hr") # name of the data base
#create a Cursor object.
cur = db.cursor() 

# Write SQL statement here
cur.execute("SELECT b.first_name,b.last_name FROM employees b WHERE NOT EXISTS (SELECT 'X' FROM employees a WHERE a.manager_id = b.employee_id);")

# print all the first and second cells of all the rows
for row in cur.fetchall() :
    print (row[0],row[1])

/*create database */
CREATE DATABASE bookinfo;
show databases; /*list all database with show privilege*/
select database(); /*which database currently selected*/
use database_name; + show tables;
/*database size*/
SELECT table_schema "Database", 
SUM(data_length + index_length)/1024/1024 "Size in MB" 
FROM information_schema.TABLES GROUP BY table_schema;
/*all the tables in 'hr' database with columns 'name' or 'department_id'*/
SELECT DISTINCT TABLE_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE COLUMN_NAME IN ('department_id', 'name')
AND TABLE_SCHEMA='hr';

/* drop database */
DROP DATABASE tempdatabase;
DROP TABLE table2,table4,table5;
ALTER TABLE  table_name DROP column_name;
ALTER TABLE table1 drop col1, drop col11, drop col12;


INSERT INTO table_name (column1, column2, column3, ...)
VALUES (value1, value2, value3, ...); 

INSERT INTO table_name VALUES 
(value1, value2, value3, ...); 

-- sales_data
-- ----------------------------------
-- sales_date      date,
-- customer_id     varchar(30),
-- amount          varchar(30)
    
insert into sales_data values 
  (str_to_date('01-Jan-2021','%d-%b-%Y'), 'Cust-1', '50$');

-- copy elements of other table

INSERT INTO table2
SELECT * FROM table1
WHERE condition; 

INSERT INTO table2 (column1, column2, column3, ...)
SELECT column1, column2, column3, ...
FROM table1
WHERE condition; 
---------------------------------------------------------------------
SELECT column_names
FROM table_name
WHERE column_name IS NOT NULL; 

-- SELECT ProductName, UnitPrice * (UnitsInStock + IFNULL(UnitsOnOrder, 0))
-- FROM Products; 

SELECT column_name(s)
FROM table_name
WHERE column_name BETWEEN value1 AND value2; 
---------------------------------------------------------------------
UPDATE table_name
SET column1 = value1, column2 = value2, ...
WHERE condition; 

SELECT column_name(s)
FROM table_name
WHERE condition
LIMIT number; 
---------------------------------------------------------------------
SELECT MAX(column_name)  
FROM table_name
WHERE condition; 

COUNT(),AVG(),SUM()

SELECT column_name(s)
FROM table_name
WHERE column_name operator ANY
  (SELECT column_name
  FROM table_name
  WHERE condition); 

SELECT ALL column_name(s)
FROM table_name
WHERE condition;

SELECT column_name(s)
FROM table_name
WHERE column_name operator ALL
  (SELECT column_name
  FROM table_name
  WHERE condition); 

-- SELECT ProductName
-- FROM Products
-- WHERE ProductID = ANY
--   (SELECT ProductID
--   FROM OrderDetails
--   WHERE Quantity = 10);   
---------------------------------------------------------------------
SELECT column1, column2, ...
FROM table_name
WHERE columnN LIKE pattern; 

pattern : 'a__%' -> starts with a ,atleast 3 char long
pattern : '%or%' -> any value with or at any position
---------------------------------------------------------------------
SELECT column_name(s)
FROM table_name
WHERE column_name IN (value1, value2, ...); 

SELECT column_name(s)
FROM table_name
WHERE column_name IN (SELECT STATEMENT); 

SELECT column_name(s)
FROM table_name
WHERE EXISTS
(SELECT column_name FROM table_name WHERE condition); 
---------------------------------------------------------------------
SELECT column_name AS alias_name
FROM table_name;

SELECT column_name(s)
FROM table_name AS alias_name;
---------------------------------------------------------------------
SELECT column1, column2, ...
FROM table_name
ORDER BY column1, column2, ... ASC|DESC; 
------------------------------------------------------------------
SELECT column_name(s)
FROM table_name
WHERE condition
GROUP BY column_name(s)
ORDER BY column_name(s); 

SELECT column_name(s)
FROM table_name
WHERE condition
GROUP BY column_name(s)
HAVING condition
ORDER BY column_name(s);
---------------------------------------------------------------------
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    WHEN conditionN THEN resultN
    ELSE result
END; 
---------------------------------------------------------------------
ALTER TABLE table_name
ADD column_name datatype; 

ALTER TABLE table_name DROP COLUMN column_name; 
DROP TABLE IF EXISTS table_name;

CREATE TABLE IF NOT EXISTS table_name (
    column1 datatype constraint,
    column2 datatype constraint,
    column3 datatype constraint,
    ....
);

CREATE UNIQUE INDEX index_name
ON table_name (column1, column2, ...);

CREATE VIEW view_name AS
SELECT column1, column2, ...
FROM table_name
WHERE condition; 

-- CREATE VIEW [Brazil Customers] AS
-- SELECT CustomerName, ContactName
-- FROM Customers
-- WHERE Country = 'Brazil'; 

-- In SQL, a view is a virtual table based on the result-set of an SQL statement.

-- A view contains rows and columns, just like a real table. The fields in a 
-- view are fields from one or more real tables in the database.

-- You can add SQL statements and functions to a view and present the data as 
-- if the data were coming from one single table.



-- NOT NULL - Ensures that a column cannot have a NULL value
-- UNIQUE - Ensures that all values in a column are different
-- PRIMARY KEY - A combination of a NOT NULL and UNIQUE. 
--               Uniquely identifies each row in a table
-- FOREIGN KEY - Prevents actions that would destroy links between tables
-- CHECK - Ensures that the values in a column satisfies a specific condition
-- DEFAULT - Sets a default value for a column if no value is specified
-- CREATE INDEX - Used to create and retrieve data from the database very quickly


    -- DATE - format YYYY-MM-DD
    -- DATETIME - format: YYYY-MM-DD HH:MI:SS
    -- TIMESTAMP - format: YYYY-MM-DD HH:MI:SS
    -- YEAR - format YYYY or YY

-- SELECT * FROM Orders WHERE OrderDate='2008-11-11'

-- CREATE TABLE Persons (
--     ID int NOT NULL,
--     LastName varchar(255) NOT NULL,
--     FirstName varchar(255),
--     Age int,
--     UNIQUE (ID)
-- ); 

-- CREATE TABLE Persons (
--     ID int NOT NULL,
--     LastName varchar(255) NOT NULL,
--     FirstName varchar(255) NOT NULL,
--     Age int
-- ); 

-- ALTER TABLE Persons
-- MODIFY Age int NOT NULL; 

-- CREATE TABLE Orders (
--     OrderID int NOT NULL,
--     OrderNumber int NOT NULL,
--     PersonID int,
--     PRIMARY KEY (OrderID),
--     CONSTRAINT FK_PersonOrder FOREIGN KEY (PersonID)
--     REFERENCES Persons(PersonID)
-- ); 

-- ALTER TABLE Persons
-- ADD CONSTRAINT PK_Person PRIMARY KEY (ID,LastName); 

-- CREATE TABLE Orders (
--     ID int NOT NULL,
--     OrderNumber int NOT NULL,
--     OrderDate date DEFAULT CURRENT_DATE()
-- ); 

-- CREATE TABLE Persons (
--     Personid int NOT NULL AUTO_INCREMENT,
--     LastName varchar(255) NOT NULL,
--     FirstName varchar(255),
--     Age int,
--     PRIMARY KEY (Personid)
-- ); 
----------------------------------------------------------------------------
String Functions -> 
SUBSTRING(string, start, length)
FORMAT(number, decimal_places)
REPLACE(string, substring, new_string)
REVERSE(string)
SUBSTRING_INDEX(string, delimiter, number)
--SELECT SUBSTRING_INDEX("www.w3schools.com", ".", 1); www
UPPER(text)
STRCMP(string1, string2) -- 0,-1,1 based on string1
POSITION(substring IN string)
--SELECT POSITION("COM" IN "W3Schools.com") AS MatchPosition; 11

Numeric Functions -> ABS(number) ,FLOOR(number) , CEIL(number)

Date Functions -> 

Advanced Functions ->

-- SELECT OrderID, Quantity, IF(Quantity>10, "MORE", "LESS")
-- FROM OrderDetails; 
----------------------------------------------------------------------------

