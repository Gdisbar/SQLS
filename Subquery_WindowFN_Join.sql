-- department
-- -------------------------------------------------
-- dept_id		int ,
-- dept_name	varchar(50) PRIMARY KEY,
-- location	varchar(100)


-- EMPLOYEE
-- ------------------------------------------------------
-- EMP_ID      INT PRIMARY KEY,
-- EMP_NAME    VARCHAR(50) NOT NULL,
-- DEPT_NAME   VARCHAR(50) NOT NULL,
-- SALARY      INT,
-- constraint fk_emp foreign key(dept_name) references department(dept_name)



-- employee_history
-- ----------------------------------------
-- emp_id      INT PRIMARY KEY,
-- emp_name    VARCHAR(50) NOT NULL,
-- dept_name   VARCHAR(50),
-- salary      INT,
-- location    VARCHAR(100),
-- constraint fk_emp_hist_01 foreign key(dept_name) references department(dept_name),
-- constraint fk_emp_hist_02 foreign key(emp_id) references employee(emp_id)


-- sales
-- ------------------------------
-- 	store_id  		int,
-- 	store_name  	varchar(50),
-- 	product_name	varchar(50),
-- 	quantity		int,
-- 	price	     	int



-- INTRO
--------------------------------------------------------------------------------
/* < WHAT IS SUBQUERIES? Sample subquery. How SQL processes this statement containing subquery? > */

/* QUESTION: Find the employees who's salary is more than the average salary earned by all employees. */
-- 1) find the avg salary
-- 2) filter employees based on the above avg salary
select *
from employee e
where salary > (select avg(salary) from employee)
order by e.salary;



-- TYPES OF SUBQUERY
--------------------------------------------------------------------------------
/* < SCALAR SUBQUERY > */
/* QUESTION: Find the employees who earn more than the average salary earned by all employees. */
-- it return exactly 1 row and 1 column

select *
from employee e
where salary > (select avg(salary) from employee)
order by e.salary;

select e.*, round(avg_sal.sal,2) as avg_salary
from employee e
join (select avg(salary) sal from employee) avg_sal
	on e.salary > avg_sal.sal;



--------------------------------------------------------------------------------
/* < MULTIPLE ROW SUBQUERY > */
-- Multiple column, multiple row subquery
/* QUESTION: Find the employees who earn the highest salary in each department. */
1) find the highest salary in each department.
2) filter the employees based on above result.
select *
from employee e
where (dept_name,salary) in (select dept_name, max(salary) from employee group by dept_name)
order by dept_name, salary;

-- Single column, multiple row subquery
/* QUESTION: Find department who do not have any employees */
1) find the departments where employees are present.
2) from the department table filter out the above results.
select *
from department
where dept_name not in (select distinct dept_name from employee);


--------------------------------------------------------------------------------
/* < CORRELATED SUBQUERY >
-- A subquery which is related to the Outer query
/* QUESTION: Find the employees in each department who earn more than the average salary in that department. */
1) find the avg salary per department
2) filter data from employee tables based on avg salary from above result.

select *
from employee e
where salary > (select avg(salary) from employee e2 where e2.dept_name=e.dept_name)
order by dept_name, salary;

/* QUESTION: Find department who do not have any employees */
-- Using correlated subquery
select *
from department d
where not exists (select 1 from employee e where e.dept_name = d.dept_name)



--------------------------------------------------------------------------------
/* < SUBQUERY inside SUBQUERY (NESTED Query/Subquery)> */

/* QUESTION: Find stores who's sales where better than the average sales accross all stores */
1) find the sales for each store
2) average sales for all stores
3) compare 2 with 1
-- Using multiple subquery
select *
from (select store_name, sum(price) as total_sales
	 from sales
	 group by store_name) sales
join (select avg(total_sales) as avg_sales
	 from (select store_name, sum(price) as total_sales
		  from sales
		  group by store_name) x
	 ) avg_sales
on sales.total_sales > avg_sales.avg_sales;

-- Using WITH clause
with sales as
	(select store_name, sum(price) as total_sales
	 from sales
	 group by store_name)
select *
from sales
join (select avg(total_sales) as avg_sales from sales) avg_sales
	on sales.total_sales > avg_sales.avg_sales;



-- CLAUSES WHERE SUBQUERY CAN BE USED
--------------------------------------------------------------------------------
/* < Using Subquery in WHERE clause > */
/* QUESTION:  Find the employees who earn more than the average salary earned by all employees. */
select *
from employee e
where salary > (select avg(salary) from employee)
order by e.salary;


--------------------------------------------------------------------------------
/* < Using Subquery in FROM clause > */
/* QUESTION: Find stores who's sales where better than the average sales accross all stores */
-- Using WITH clause
with sales as
	(select store_name, sum(price) as total_sales
	 from sales
	 group by store_name)
select *
from sales
join (select avg(total_sales) as avg_sales from sales) avg_sales
	on sales.total_sales > avg_sales.avg_sales;


--------------------------------------------------------------------------------
/* < USING SUBQUERY IN SELECT CLAUSE > */
-- Only subqueries which return 1 row and 1 column is allowed (scalar or correlated)
/* QUESTION: Fetch all employee details and add remarks to those employees who earn more than the average pay. */
select e.*
, case when e.salary > (select avg(salary) from employee)
			then 'Above average Salary'
	   else null
  end remarks
from employee e;

-- Alternative approach
select e.*
, case when e.salary > avg_sal.sal
			then 'Above average Salary'
	   else null
  end remarks
from employee e
cross join (select avg(salary) sal from employee) avg_sal;



--------------------------------------------------------------------------------
/* < Using Subquery in HAVING clause > */
/* QUESTION: Find the stores who have sold more units than the average units sold by all stores. */
select store_name, sum(quantity) Items_sold
from sales
group by store_name
having sum(quantity) > (select avg(quantity) from sales);




-- SQL COMMANDS WHICH ALLOW A SUBQUERY
--------------------------------------------------------------------------------
/* < Using Subquery with INSERT statement > */
/* QUESTION: Insert data to employee history table. Make sure not insert duplicate records. */
insert into employee_history
select e.emp_id, e.emp_name, d.dept_name, e.salary, d.location
from employee e
join department d on d.dept_name = e.dept_name
where not exists (select 1
				  from employee_history eh
				  where eh.emp_id = e.emp_id);


--------------------------------------------------------------------------------
/* < Using Subquery with UPDATE statement > */
/* QUESTION: Give 10% increment to all employees in Bangalore location based on the maximum
salary earned by an emp in each dept. Only consider employees in employee_history table. */
update employee e
set salary = (select max(salary) + (max(salary) * 0.1)
			  from employee_history eh
			  where eh.dept_name = e.dept_name)
where dept_name in (select dept_name
				   from department
				   where location = 'Bangalore')
and e.emp_id in (select emp_id from employee_history);


--------------------------------------------------------------------------------
/* < Using Subquery with DELETE statement > */
/* QUESTION: Delete all departments who do not have any employees. */
delete from department d1
where dept_name in (select dept_name from department d2
				    where not exists (select 1 from employee e
									  where e.dept_name = d2.dept_name));


==========================================================================================
==========================================================================================

/* **************
   Window Function
 ************** */
==========================================================================================

-- employee
-- -------------------
-- emp_ID int
-- emp_NAME varchar(50)
-- DEPT_NAME varchar(50)
-- SALARY int



-- Using Aggregate function as Window Function
-- Without window function, SQL will reduce the no of records.
select dept_name, max(salary) from employee
group by dept_name;

-- By using MAX as an window function, SQL will not reduce records but the result will be shown corresponding to each record.
select e.*,
max(salary) over(partition by dept_name) as max_salary
from employee e;


-- row_number(), rank() and dense_rank()
select e.*,
row_number() over(partition by dept_name) as rn
from employee e;


-- Fetch the first 2 employees from each department to join the company.
select * from (
	select e.*,
	row_number() over(partition by dept_name order by emp_id) as rn
	from employee e) x
where x.rn < 3;


-- Fetch the top 3 employees in each department earning the max salary.
select * from (
	select e.*,
	rank() over(partition by dept_name order by salary desc) as rnk
	from employee e) x
where x.rnk < 4;


-- Checking the different between rank, dense_rnk and row_number window functions:
select e.*,
rank() over(partition by dept_name order by salary desc) as rnk,
dense_rank() over(partition by dept_name order by salary desc) as dense_rnk,
row_number() over(partition by dept_name order by salary desc) as rn
from employee e;



-- lead and lag

-- fetch a query to display if the salary of an employee is higher, lower or equal to the previous employee.
select e.*,
lag(salary) over(partition by dept_name order by emp_id) as prev_empl_sal,
case when e.salary > lag(salary) over(partition by dept_name order by emp_id) then 'Higher than previous employee'
     when e.salary < lag(salary) over(partition by dept_name order by emp_id) then 'Lower than previous employee'
	 when e.salary = lag(salary) over(partition by dept_name order by emp_id) then 'Same than previous employee' end as sal_range
from employee e;

-- Similarly using lead function to see how it is different from lag.
select e.*,
lag(salary) over(partition by dept_name order by emp_id) as prev_empl_sal,
lead(salary) over(partition by dept_name order by emp_id) as next_empl_sal
from employee e;

=====================================================================================
=====================================================================================
/********************
 * Joins
 * *****************/
 ====================================================================================

-- employee
-- ----------------------------------
-- 	emp_id			varchar(20),
-- 	emp_name		varchar(50),
-- 	salary			int,
-- 	dept_id			varchar(20),
-- 	manager_id		varchar(20)


-- department
-- --------------------------
-- 	dept_id			varchar(20)
-- 	dept_name		varchar(50)

-- manager
-- ---------------------------------
-- manager_id			varchar(20)
-- manager_name		varchar(50)
-- dept_id				varchar(20)


-- projects
-- --------------------------------------
-- project_id			varchar(20)
-- project_name		varchar(100)
-- team_member_id		varchar(20)


-- Inner Join
select e.emp_name, d.dept_name
from employee e
join department d on e.dept_id = d.dept_id;

-- Left Join
select e.emp_name, d.dept_name
from employee e
left join department d on e.dept_id = d.dept_id;

-- Right Join
select e.emp_name, d.dept_name
from employee e
right join department d on e.dept_id = d.dept_id;

-- Multiple joins 1
select e.emp_name, d.dept_name, m.manager_name
from employee e
right join department d on e.dept_id = d.dept_id -- returns on Manoj, Rahul, Michael and James
join manager m on m.manager_id = e.manager_id; -- Hence returns on the managers of above 4 employees

-- Multiple joins 2
select e.emp_name, d.dept_name, m.manager_name
from employee e
right join department d on e.dept_id = d.dept_id -- returns on Manoj, Rahul, Michael and James
left join manager m on m.manager_id = e.manager_id;

-- Multiple joins 3
select e.emp_name, d.dept_name, m.manager_name
from employee e
right join department d on e.dept_id = d.dept_id -- returns on Manoj, Rahul, Michael and James
right join manager m on m.manager_id = e.manager_id;

-- Multiple joins 4
select e.emp_name, d.dept_name, m.manager_name, p.project_name
from employee e
right join department d on e.dept_id = d.dept_id -- returns on Manoj, Rahul, Michael and James
right join manager m on m.manager_id = e.manager_id
inner join projects p on p.team_member_id = m.manager_id;




--------------------------------------------------------------------

-- Inner join / JOIN
select e.emp_name, d.dept_name
from employee e join department d on e.dept_id = d.dept_id;

-- left join
select e.emp_name, d.dept_name
from employee e left join department d on e.dept_id = d.dept_id;

-- left join = inner join + all records from left table (returns null value for any columns fetched from right table)

-- right join
select e.emp_name, d.dept_name
from employee e right join department d on e.dept_id = d.dept_id;

-- right join = inner join + all records from right table (returns null value for any columns fetched from left table)



-- fetch emp name, their manager who are not working on any project.
select e.emp_name, m.manager_name
from employee e
join manager m on m.manager_id = e.manager_id
where not exists (select 1 from projects p where p.team_member_id = e.emp_id);

-- Fetch details of ALL emp, their manager, their department and the projects they work on.
select e.emp_name, d.dept_name, m.manager_name, p.project_name
from employee e
left join department d on d.dept_id = e.dept_id
join manager m on m.manager_id = e.manager_id
left JOIN projects p on p.team_member_id = e.emp_id;

-- Fetch details of ALL emp and ALL manager, their department and the projects they work on.
select e.emp_name, d.dept_name, m.manager_name, p.project_name
from employee e
left join department d on d.dept_id = e.dept_id
right join manager m on m.manager_id = e.manager_id
left join projects p on p.team_member_id = e.emp_id;



-- employee
-- --------------------------
-- emp_id			varchar(20),
-- emp_name		varchar(50),
-- salary			int,
-- dept_id			varchar(20),
-- manager_id		varchar(20)



-- department
-- --------------------------------
-- dept_id			varchar(20),
-- dept_name		varchar(50)

-- company
-- --------------------------------
-- company_id		varchar(10),
-- company_name	varchar(50),
-- location		varchar(20)

-- family
-- -------------------------------------
-- member_id     VARCHAR(10),
-- name          VARCHAR(50),
-- age           INT,
-- parent_id     VARCHAR(10)




select * from employee; -- D1, D2, D10
select * from department; -- D1, D2, D3, D4
select * from company;

-- INNER JOIN can also be represented as "JOIN"
-- INNER Join = Fetches only matching records in both tables based on the JOIN condition.
-- Write a query to fetch the employee name and their corresponding department name.
SELECT e.emp_name, d.dept_name
FROM employee e
INNER JOIN department d ON e.dept_id = d.dept_id;

-- LEFT JOIN can also be represented as "LEFT OUTER JOIN"
-- LEFT Join = INNER Join + all remaining records from Left Table (returns null value for any columns fetched from right table)
-- Write a query to fetch ALL the employee name and their corresponding department name.
SELECT e.emp_name, d.dept_name
FROM employee e
LEFT JOIN department d ON e.dept_id = d.dept_id;

-- RIGHT JOIN can also be represented as "RIGHT OUTER JOIN"
-- RIGHT Join = INNER Join + all remaining records from Right Table (returns null value for any columns fetched from left table)
-- Write a query to fetch ALL the department and the employees under these departments.
SELECT e.emp_name, d.dept_name
FROM employee e
RIGHT JOIN department d ON e.dept_id = d.dept_id;


-- FULL JOIN can also be represented as "FULL OUTER JOIN"
-- FULL Join = INNER Join
--              + all remaining records from Left Table (returns null value for any columns fetched from right table)
--              + all remaining records from Right Table (returns null value for any columns fetched from left table)
-- Write a query to fetch the employee name and their corresponding department name.
-- Make sure to include all the employees and the departments.
SELECT e.emp_name, d.dept_name
FROM employee e
FULL JOIN department d ON e.dept_id = d.dept_id;


-- CROSS JOIN
-- CROSS JOIN returns cartesian product.
-- Meaning it will match every record from the left table with every record from the right table hence it will return records from both table.
-- No join condition is required to be specified.
SELECT e.emp_name, d.dept_name
FROM employee e
CROSS JOIN department d;

-- Write a query to fetch the employee name and their corresponding department name.
-- Also make sure to display the company name and the company location correspodning to each employee.


-- NATURAL JOIN - SQL will naturally choose the column on which join should happen based on the column name.
-- Natural join will perform inner join operation if there are columns with same name in both table. If there are more than 1 column with same name then join will happen based on all these columns.
-- If there are no columns with same name in both table then it performs cross join
-- If you specify * in select list then it displays the join columns in the beginning and does not repeat it.
-- No join condition is required to be specified.
SELECT *
FROM employee e
NATURAL JOIN department d;

-- Altering the dept_id column name to see how Natural Join acts when there are no common column names in both tables.
--alter table department rename column dept_id to department_id
--alter table department rename column department_id to dept_id;



-- SELF JOIN - When you join a table to itself, this is called as SELF Join.
-- There is no keyword like SELF JOIN but we just use the regular JOIN keyword to make the self join.
-- Write a query to fetch the child name and their age correspodning to their parent name and parent age.
select child.name as child_name
, child.age as child_age
, parent.name as parent_name
, parent.age as parent_age
from family as child
join family as parent on parent.member_id = child.parent_id;


select child.name as child_name
, child.age as child_age
, parent.name as parent_name
, parent.age as parent_age
from family as child
left join family as parent on parent.member_id = child.parent_id;



-- ANSI JOIN - Uses the JOIN clause and mentions join condition under the ON clause and filter conditions in the WHERE clause.
SELECT e.emp_name, d.dept_name
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
WHERE e.salary > 15000;

SELECT e.emp_name, d.dept_name
FROM employee e
LEFT JOIN department d ON e.dept_id = d.dept_id
WHERE e.salary > 15000;


-- Non ANSI JOIN - Uses comma to seperate multiple tables and then use WHERE clause to mention both the join and filter conditions.
SELECT e.emp_name, d.dept_name
FROM employee e
,    department d
WHERE e.salary > 15000
AND   e.dept_id = d.dept_id;

SELECT e.emp_name, d.dept_name
FROM employee e
,    department d
WHERE e.salary > 15000
AND   e.dept_id = d.dept_id (+); -- This is unsupported in PostgreSQL but works in Oracle. Other RDBMS may have alternative symbols to performs same thing.

