-- STATION
-- --------------
-- Id      Number
-- City    Varchar2(21)
-- State   Varchar2(2)
-- Lat_N   Number
-- Long_W  Number

-- Query a list of CITY names from STATION for cities that have an even ID number. 
-- Print the results in any order, but exclude duplicates from the 

> select distinct City from Station where Id%2=0 order by City asc;


-- Find the difference between the total number of CITY entries in the table and the 
-- number of distinct CITY entries in the table. 

> select count(City)-count(distinct City) from Station;


-- Query the two cities in STATION with the shortest and longest CITY names, as well 
-- as their respective lengths (i.e.: number of characters in the name). If there is 
-- more than one smallest or largest city, choose the one that comes first when ordered 
-- alphabetically. 

> select city, length(city) from station
order by length(city),city asc
limit 1;
select city, length(city) from station
order by length(city) desc
limit 1;


-- Query the list of CITY names from STATION that either do not start with vowels or 
-- do not end with vowels. Your result cannot contain duplicates.

> select distinct City from station where 
substring(City,1,1) not in ('a','e','i','o','u') or 
substring(City,length(City),1) not in ('a','e','i','o','u');


-- STUDENTS
-- -----------------
-- Id         Integer
-- Name       String   
-- Marks      Integer

-- The Name column only contains uppercase (A-Z) and lowercase (a-z) letters.

-- Query the Name of any student in STUDENTS who scored higher than 75 Marks. 
-- Order your output by the last three characters of each name. If two or more students 
-- both have names ending in the same last three characters 
-- (i.e.: Bobby, Robby, etc.), secondary sort them by ascending ID.

> select Name from Students where Marks>75 
order by substring(Name,length(Name)-2,3),Id asc;


-- TRIANGLES
-- -----------------
-- A          Integer
-- B          Integer
-- C          Integer


-- Write a query identifying the type of each record in the TRIANGLES table using its 
-- three side lengths. Output one of the following statements for each record in the table:

--     Equilateral: It''s a triangle with 

-- sides of equal length.
-- Isosceles: It's a triangle with
-- sides of equal length.
-- Scalene: It's a triangle with
-- sides of differing lengths.
-- Not A Triangle: The given values of A, B, and C don''t form a triangle.

> select case             
            when A + B > C and B + C > A and A + C > B then
                case 
                    when A = B and B = C then 'Equilateral'
                    when A = B or B = C or A = C then 'Isosceles'
                    else 'Scalene'
                end
            else 'Not A Triangle'
        end
from Triangles;



-- CITY 
-- -------------------------
-- Id            Number
-- Name          Varchar2(17)
-- CountryCode   Varchar2(3)
-- District      Varchar2(20)
-- Population    Number


-- Query the average population for all cities in CITY, rounded down to 
-- the nearest integer.

> select round(avg(Population),0) from City;

-- EMPLOYEES 
-- -----------------
-- Id         Integer
-- Name       String   
-- Salary     Integer

-- Samantha was tasked with calculating the average monthly salaries for all employees 
-- in the EMPLOYEES table, but did not realize her keyboard''s

-- key was broken until after completing the calculation. She wants your help finding 
-- the difference between her miscalculation (using salaries with any zeros removed), 
-- and the actual average salary.

-- Write a query calculating the amount of error actual - miscalculated  (i.e.:
-- average monthly salaries), and round it up to the next integer.

> select ceil(avg(Salary)-avg(replace(Salary,'0',''))) from Employees;


-- EMPLOYEES
-- --------------------------
-- Employee_Id    Integer
-- Name           String   
-- Months         Integer
-- Salary         Integer

-- We define an employee''s total earnings to be their monthly Salary*Months worked, 
-- and the maximum total earnings to be the maximum total earnings for any employee 
-- in the Employee table. Write a query to find the maximum total earnings for all 
-- employees as well as the total number of employees who have maximum total earnings. 
-- Then print these values as space-separated integers.

> select (Salary*Months)as Earnings,count(*) from Employee 
group by 1 order by Earnings desc limit 1;

-- STUDENTS
-- -----------------
-- Id         Integer
-- Name       String   
-- Marks      Integer

-- The Name column only contains uppercase (A-Z) and lowercase (a-z) letters.

-- Query the Name of any student in STUDENTS who scored higher than 75 Marks. 
-- Order your output by the last three characters of each name. 
-- If two or more students both have names ending in the same last three characters 
-- (i.e.: Bobby, Robby, etc.), secondary sort them by ascending ID.

-- SUBSTRING(string, start, length)

> select Name from Students where Marks>75 
order by substring(Name,length(Name)-2,3),Id asc;


-- CITY
-- -------------------------
-- Id            Number
-- Name          Varchar2(17)
-- CountryCode   Varchar2(3)
-- District      Varchar2(20)
-- Population    Number


-- Query the average population for all cities in CITY, rounded down to the 
-- nearest integer.

> select round(avg(Population),0) from City;

-- EMPLOYEES
-- -----------------
-- Id         Integer
-- Name       String   
-- Salary     Integer

-- Samantha was tasked with calculating the average monthly salaries for all employees 
-- in the EMPLOYEES table, but did not realize her keyboard''s 0 key was broken 
-- until after completing the calculation. She wants your help finding 
-- the difference between her miscalculation (using salaries with any zeros removed), 
-- and the actual average salary.

-- Write a query calculating the amount of error actual - miscalculated  (i.e.:
-- average monthly salaries), and round it up to the next integer.

> select ceil(avg(Salary)-avg(replace(Salary,'0',''))) from Employees;


-- EMPLOYEES
-- --------------------------
-- Employee_Id    Integer
-- Name           String   
-- Months         Integer
-- Salary         Integer

-- We define an employee''s total earnings to be their monthly Salary*Months worked, 
-- and the maximum total earnings to be the maximum total earnings for any employee 
-- in the Employee table. Write a query to find the maximum total earnings for all 
-- employees as well as the total number of employees who have maximum total earnings. 
-- Then print these values as space-separated integers.


> select (Salary*Months)as Earnings,count(*) from Employee 
group by 1 order by Earnings desc limit 1;

> select (Salary*Months) as Earning,count(*) as Frequency from Employee
group by Earning order by Frequency desc limit 1;

-- group by 1 groups by Earning & order by orders  

-- 108064 7 --> we need only this , limit 1 gets only the largest

-- 101154 1 

-- 91241 1 

-- 90816 1 

-- 89936 1 


-- select (Salary*Months) as Earning from Employee
-- group by Earning order by Earning desc ;


-- 108064 

-- 101154 

-- 91241 

-- 90816 

-- 89936 
=======================
| Weather Observation |
=======================
-- STATION
-- ---------------
-- Id    |  Number
-- City  |  Varchar2(21)
-- State |  Varchar2(2)
-- Lat_N |  Number
-- Long_W|  Number

-- Query the following two values from the STATION table:
-- 1)The sum of all values in LAT_N rounded to a scale of 2 decimal places.
-- 2)The sum of all values in LONG_W rounded to a scale of 2 decimal places.


> select round(sum(Lat_N),2),round(sum(Long_W),2) from Station;

-- Query a list of CITY names from STATION for cities that have an even ID number. 
-- Print the results in any order, but exclude duplicates from the 

> select distinct City from Station where Id%2=0 ;


-- Find the difference between the total number of CITY entries in the table 
-- and the number of distinct CITY entries in the table. 

> select count(City)-count(distinct City) from Station;



-- Query the two cities in STATION with the shortest and longest CITY names, as well 
-- as their respective lengths (i.e.: number of characters in the name). If there is 
-- more than one smallest or largest city, choose the one that comes first when ordered 
-- alphabetically. 

> Select City,length(City) from Station 
order by length(City),City asc limit 1;

> Select City,length(City) from Station 
order by length(City) desc limit 1;;


-- Query the list of CITY names from STATION that either do not start with 
-- vowels or do not end with vowels. Your result cannot contain duplicates.

> select distinct City from station where 
substring(City,1,1) not in ('a','e','i','o','u') or 
substring(City,length(City),1) not in ('a','e','i','o','u');

-- Query the sum of Northern Latitudes (LAT_N) from STATION having values 
-- greater than 38.7880 and less than 137.2345. Truncate your answer 
-- to 4 decimal places.

>select truncate(sum(Lat_N),4) from Station 
where Lat_N between 38.7880 and 137.2345;

 -- using subquery
>select round(sum(lat_n),4) from station where lat_n in 
(select lat_n from station where lat_n > 38.7880 and lat_n < 137.2345);


-- Query the Western Longitude (LONG_W) for the largest Northern Latitude (LAT_N) 
-- in STATION that is less than 137.2345. Round your answer to 4 decimal places.

>select round(Long_W,4) from Station 
where Lat_N < 137.2345 order by Lat_N desc limit 1;


-- Query the Western Longitude (LONG_W)where the smallest Northern Latitude 
-- (LAT_N) in STATION is greater than 38.7780. Round your answer to 4 decimal places.

>select round(Long_W,4) from Station where
Lat_N in (select min(Lat_N) from Station where Lat_N > 38.7780);



-- Generate the following two result sets:

-- Query an alphabetically ordered list of all names in OCCUPATIONS, 
-- immediately followed by the first letter of each profession as a 
-- parenthetical (i.e.: enclosed in parentheses). 
-- For example: AnActorName(A), ADoctorName(D), AProfessorName(P), and ASingerName(S).

--     Query the number of ocurrences of each occupation in OCCUPATIONS. 
--     Sort the occurrences in ascending order, and output them in the 
--     following format:

--     There are a total of [occupation_count] [occupation]s.

--     where [occupation_count] is the number of occurrences of an 
--     occupation in OCCUPATIONS and [occupation] is the lowercase occupation 
--     name. If more than one Occupation has the same [occupation_count], 
--     they should be ordered alphabetically.

-- Note: There will be at least two entries in the table for each type of occupation.


-- OCCUPATIONS
-- =============
-- Field          Type
-- --------------------------
-- Occupation     String
-- Name           String   



-- Given the CITY and COUNTRY tables, query the sum of the populations of all 
-- cities where the CONTINENT is 'Asia'.

-- Note: CITY.CountryCode and COUNTRY.Code are matching key columns.

-- CITY
-- ===========
-- Field         Type
-- -------------------------
-- Id            Number
-- Name          Varchar2(17)
-- CountryCode   Varchar2(3)
-- District      Varchar2(20)
-- Population    Number

-- COUNTRY
-- ===========
-- Field         Type
-- -------------------------
-- Code            Varchar2(3)
-- Name            Varchar2(44)
-- Coutinent       Varchar2(13)
-- Region          Varchar2(25)
-- SurfaceArea     Number
-- IndepYear       Varchar2(5)
-- Population      Number
-- LifeExpectancy  Varchar2(4)
-- Gnp             Number
-- GnPold           Varchar2(9)
-- LocalName       Varchar2(44)
-- GovernmentForm  Varchar2(44)
-- HeadOfState     Varchar2(32)
-- Capital         Varchar2(4)
-- Code2           Varchar2(2)


> select sum(City.Population) from City 
inner join Country on City.CountryCode=Country.Code
where Country.Continent like "Asia";


-- Given the CITY and COUNTRY tables, query the names of all the continents 
-- (COUNTRY.Continent) and their respective average city 
-- populations (CITY.Population) rounded down to the nearest integer.

-- round() will provide error , need to use floor() only

> select Country.Continent,floor(avg(City.Population))
from Country inner join City on 
City.CountryCode=Country.Code group by Country.Continent;
