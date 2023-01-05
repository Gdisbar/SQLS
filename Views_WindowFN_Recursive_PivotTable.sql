======================================================================================
======================================================================================
/******************
 * VIEW
 * ****************/

======================================================================================

-- create table if not exists tb_customer_data
-- (
--     cust_id         varchar(10) primary key,
--     cust_name       varchar(50) not null,
--     phone           bigint,
--     email           varchar(50),
--     address         varchar(250)
-- );

-- create table if not exists tb_product_info
-- (
--     prod_id         varchar(10) primary key,
--     prod_name       varchar(50) not null,
--     brand           varchar(50) not null,
--     price           int
-- );

-- create table if not exists tb_order_details
-- (
--     ord_id          bigint primary key,
--     prod_id         varchar(10) references tb_product_info(prod_id),
--     quantity        int,
--     cust_id         varchar(10) references tb_customer_data(cust_id),
--     disc_percent    int,
--     date            date
-- );

-- Fetch the order summary (to be given to client/vendor)
create view order_summary
as
select o.ord_id, o.date, c.cust_name, p.prod_name
, (p.price * o.quantity) - (p.price * o.quantity) * (o.disc_percent::float/100) as cost
from tb_customer_data c
join tb_order_details o on o.cust_id = c.cust_id
join tb_product_info p on p.prod_id = o.prod_id
order by o.ord_id,c.cust_name;


select * from order_summary;


-- Using CREATE or REPLACE
create or replace view order_summary
as
select o.ord_id, o.date, c.cust_name, p.prod_name
, (p.price * o.quantity) - (p.price * o.quantity) * (o.disc_percent::float/100) as cost
from tb_customer_data c
join tb_order_details o on o.cust_id = c.cust_id
join tb_product_info p on p.prod_id = o.prod_id
order by o.ord_id,c.cust_name;


-- Rules for using CREATE OR REPLACE is:
    -- The column list along with its name and data type should be same as used when creation of the view.
    -- New columns can be added only to end of the column list
    -- JOINS, table list, Order by clause can be changed.

    -- FAIL :: Adding NEW Column in between
    create or replace view order_summary
    as
    select o.ord_id, o.date, c.cust_name, p.prod_name, c.cust_id
    , (p.price * o.quantity) - (p.price * o.quantity) * (o.disc_percent::float/100) as cost
    from tb_customer_data c
    join tb_order_details o on o.cust_id = c.cust_id
    join tb_product_info p on p.prod_id = o.prod_id
    order by o.ord_id,c.cust_name;

    -- SUCCESS :: Adding NEW Column at the end works.
    create or replace view order_summary
    as
    select o.ord_id, o.date, c.cust_name, p.prod_name, c.cust_id
    , (p.price * o.quantity) - (p.price * o.quantity) * (o.disc_percent::float/100) as cost
    , c.cust_id
    from tb_customer_data c
    join tb_order_details o on o.cust_id = c.cust_id
    join tb_product_info p on p.prod_id = o.prod_id
    order by o.ord_id,c.cust_name;

    -- FAIL :: Changing DATA TYPE of exisitng column
    create or replace view order_summary
    as
    select o.ord_id::NUMERIC , o.date, c.cust_name, p.prod_name
    , (p.price * o.quantity) - (p.price * o.quantity) * (o.disc_percent::float/100) as cost
    from tb_customer_data c
    join tb_order_details o on o.cust_id = c.cust_id
    join tb_product_info p on p.prod_id = o.prod_id
    order by o.ord_id,c.cust_name;

    -- FAIL :: Changing column name of existing column.
    create or replace view order_summary
    as
    select o.ord_id, o.date, c.cust_name, p.prod_name as PRD_NAME
    , (p.price * o.quantity) - (p.price * o.quantity) * (o.disc_percent::float/100) as cost
    from tb_customer_data c
    join tb_order_details o on o.cust_id = c.cust_id
    join tb_product_info p on p.prod_id = o.prod_id
    order by o.ord_id,c.cust_name;

    -- SUCCESS :: Changing JOIN and tables and changing Order by clause is fine.
    create or replace view order_summary
    as
    select o.ord_id, o.date, 'thoufiq'::varchar(50) as cust_name, p.prod_name
    , (p.price * o.quantity) - (p.price * o.quantity) * (o.disc_percent::float/100) as cost
    , 'C99'::varchar(10) as cust_id
    from /*tb_customer_data c
    join */tb_order_details o --on o.cust_id = c.cust_id
    join tb_product_info p on p.prod_id = o.prod_id
    order by o.ord_id;--,c.cust_name;


-- If you want to change the structure of a view then use ALTER VIEW command:
alter view order_summary rename to customer_order_summary;
alter view customer_order_summary rename to order_summary;
alter view order_summary rename column ord_id to order_id;


-- Drop a view using:
drop view order_summary;



-- Advantages of using a view:
1) Security:
2) Simplify complex SQL Queries:

There can be other advantages as well but these I think are the most important ones.

To showcase Security,
lets create a role for our vendor and then give only select access to our view in this role.

CREATE ROLE vendor
LOGIN
PASSWORD 'vendor';

SELECT rolname FROM pg_roles;

GRANT SELECT
ON order_summary
TO vendor;



-- Changing underlying table structure does not automatically change view structure.
create or replace view exp_products
as
select * from tb_product_info where price > 1000;

select * from exp_products;

alter table tb_product_info add column configuration varchar(100);

select * from tb_product_info;



-- Updatable Views:
Only view created over simple SQL Queries.

SQL Query should satisfy following rules:
 - Should contain just one table or view.
 - Should not contains distinct clause, or group by clause
 - SHould not contains window functions and WITH clause.

 -- Views containing more than 1 TABLE/VIEW cannot be updated.
 update order_summary
 set cust_name = 'Raj'
 where ord_id = 1;

-- Views containing DISTINCT cannot be updated.
 create or replace view exp_products
 as
 select distinct * from tb_product_info where price > 1000;

 update exp_products
 set price = 5400
 where prod_id = 'P6';

 -- Views containing GROUP BY cannot be updated.
 create view orders_per_day
 as
 select date, count(1) as no_of_order
 from tb_order_details
 group by date;

 select * from orders_per_day;

 update orders_per_day
 set  no_of_order = 3
 where date = current_date;


 -- Views containing WITH clause cannot be updated.
 create or replace view exp_products
 as
 with temp as (select avg(price) pr from tb_product_info)
 select * from tb_product_info  a
 where price >= (select pr from temp);

 update exp_products
 set price = 5600
 where prod_id = 'P6';


 -- Views containing Window functions cannot be updated.
 create or replace view exp_products
 as
 select a.* , rank() over() as rnk
 from tb_product_info  a
 where price > 1000;

 update exp_products
 set price = 5600
 where prod_id = 'P6';

=====================================================================================
=====================================================================================
/*****************
 * Window Function
 * ****************/
=====================================================================================




-- CREATE TABLE product
-- ( 
--     product_category varchar(255),
--     brand varchar(255),
--     product_name varchar(255),
--     price int
-- );


-- FIRST_VALUE 
-- Write query to display the most expensive product under each category (corresponding to each record)
select *,
first_value(product_name) over(partition by product_category order by price desc) as most_exp_product
from product;



-- LAST_VALUE 
-- Write query to display the least expensive product under each category (corresponding to each record)
select *,
first_value(product_name) 
    over(partition by product_category order by price desc) 
    as most_exp_product,
last_value(product_name) 
    over(partition by product_category order by price desc
        range between unbounded preceding and unbounded following) 
    as least_exp_product    
from product
WHERE product_category ='Phone';



-- Alternate way to write SQL query using Window functions
select *,
first_value(product_name) over w as most_exp_product,
last_value(product_name) over w as least_exp_product    
from product
WHERE product_category ='Phone'
window w as (partition by product_category order by price desc
            range between unbounded preceding and unbounded following);
            

            
-- NTH_VALUE 
-- Write query to display the Second most expensive product under each category.
select *,
first_value(product_name) over w as most_exp_product,
last_value(product_name) over w as least_exp_product,
nth_value(product_name, 5) over w as second_most_exp_product
from product
window w as (partition by product_category order by price desc
            range between unbounded preceding and unbounded following);



-- NTILE
-- Write a query to segregate all the expensive phones, mid range phones and the cheaper phones.
select x.product_name, 
case when x.buckets = 1 then 'Expensive Phones'
     when x.buckets = 2 then 'Mid Range Phones'
     when x.buckets = 3 then 'Cheaper Phones' END as Phone_Category
from (
    select *,
    ntile(3) over (order by price desc) as buckets
    from product
    where product_category = 'Phone') x;




-- CUME_DIST (cumulative distribution) ; 
/*  Formula = Current Row no (or Row No with value same as current row) / Total no of rows */

-- Query to fetch all products which are constituting the first 30% 
-- of the data in products table based on price.
select product_name, cume_dist_percetage
from (
    select *,
    cume_dist() over (order by price desc) as cume_distribution,
    round(cume_dist() over (order by price desc)::numeric * 100,2)||'%' as cume_dist_percetage
    from product) x
where x.cume_distribution <= 0.3;




-- PERCENT_RANK (relative rank of the current row / Percentage Ranking)
/* Formula = Current Row No - 1 / Total no of rows - 1 */

-- Query to identify how much percentage more expensive is "Galaxy Z Fold 3" when compared to all products.
select product_name, per
from (
    select *,
    percent_rank() over(order by price) ,
    round(percent_rank() over(order by price)::numeric * 100, 2) as per
    from product) x
where x.product_name='Galaxy Z Fold 3';


-- QUERY 1 :

-- create table emp
-- ( emp_ID int
-- , emp_NAME varchar(50)
-- , SALARY int);

with avg_sal(avg_salary) as
        (select cast(avg(salary) as int) from emp)
select *
from emp e
join avg_sal av on e.salary > av.avg_salary





-- QUERY 2 :

-- create table sales
-- (
--  store_id        int,
--  store_name      varchar(50),
--  product         varchar(50),
--  quantity        int,
--  cost            int
-- );


-- Find total sales per each store
select s.store_id, sum(s.cost) as total_sales_per_store
from sales s
group by s.store_id;


-- Find average sales with respect to all stores
select cast(avg(total_sales_per_store) as int) avg_sale_for_all_store
from (select s.store_id, sum(s.cost) as total_sales_per_store
    from sales s
    group by s.store_id) x;



-- Find stores who's sales where better than the average sales accross all stores
select *
from   (select s.store_id, sum(s.cost) as total_sales_per_store
                from sales s
                group by s.store_id
       ) total_sales
join   (select cast(avg(total_sales_per_store) as int) avg_sale_for_all_store
                from (select s.store_id, sum(s.cost) as total_sales_per_store
                    from sales s
                        group by s.store_id) x
       ) avg_sales
on total_sales.total_sales_per_store > avg_sales.avg_sale_for_all_store;



-- Using WITH clause
WITH total_sales as
        (select s.store_id, sum(s.cost) as total_sales_per_store
        from sales s
        group by s.store_id),
    avg_sales as
        (select cast(avg(total_sales_per_store) as int) avg_sale_for_all_store
        from total_sales)
select *
from   total_sales
join   avg_sales
on total_sales.total_sales_per_store > avg_sales.avg_sale_for_all_store;

=====================================================================================
=====================================================================================
/*****************
 * Recursive SQL
 * ****************/
=====================================================================================

-- RECURSIVE SQL QUERIES in PostgreSQL, Oracle, MSSQL & MySQL
/* Recursive Query Structure/Syntax
WITH [RECURSIVE] CTE_name AS
    (
     SELECT query (Non Recursive query or the Base query)
        UNION [ALL]
     SELECT query (Recursive query using CTE_name [with a termination condition])
    )
SELECT * FROM CTE_name;
*/

/* Difference in Recursive Query syntax for PostgreSQL, Oracle, MySQL, MSSQL.
- Syntax for PostgreSQL and MySQL is the same.
- In MSSQL, RECURSIVE keyword is not required and we should use UNION ALL instead of UNION.
- In Oracle, RECURSIVE keyword is not required and we should use UNION ALL instead of UNION. Additionally, we need to provide column alias in WITH clause itself
*/

-- Queries:
-- Q1: Display number from 1 to 10 without using any in built functions.
-- Q2: Find the hierarchy of employees under a given manager "Asha".
-- Q3: Find the hierarchy of managers for a given employee "David".


-- emp_details
-- ------------------------------------------
-- id           int PRIMARY KEY,
-- name         varchar(100),
-- manager_id   int,
-- salary       int,
-- designation  varchar(100)


/* Q1: Display number from 1 to 10 without using any in built functions. */

with recursive num as
    (select 1 as n
    union
    select n+1 as n
    from num where n < 10
    )
select * from num;

/* Q2: Find the hierarchy of employees under a given manager */


with recursive managers as
    (select id as emp_id, name as emp_name, manager_id
     , designation as emp_role, 1 as level
     from demo.emp_details e where id=7
     union
     select e.id as emp_id, e.name as emp_name, e.manager_id
     , e.designation as emp_role, level+1 as level
     from demo.emp_details e
     join managers m on m.emp_id = e.manager_id)
select *
from managers;



/* Q2-A: Find the hierarchy of employees under a given employee. Also displaying the manager name. */

with recursive managers as
    (select id as emp_id, name as emp_name, manager_id
     , designation as emp_role, 1 as level
     from demo.emp_details e where id=7
     union
     select e.id as emp_id, e.name as emp_name, e.manager_id
     , e.designation as emp_role, level+1 as level
     from demo.emp_details e
     join managers m on m.manager_id = e.id)
select *
from managers;

=====================================================================================
=====================================================================================
/*************************
* Pivot Table
**************************/
=====================================================================================
/*
QUESTION: Derive the output.
write a query to fetch the results into a desired format.

Solve the problem using CASE statement, PIVOT table and CROSSTAB function.
*/

-- sales_data
-- ----------------------------------
-- sales_date      date,
-- customer_id     varchar(30),
-- amount          varchar(30)


-- Different parts of the query:
-- 1) Aggregate the sales amount for each customer per month:
--     - Build the base SQL query:
--         - Remove $ symbol
--         - Transform sales_date to fetch only the month and year.
-- 2) Aggregate the sales amount per month irrespective of the customer.
-- 3) Aggregate the sales amount per each customer irrespective of the month.
-- 4) Transform final output:
--     - Replace negative sign with parenthesis.
--     - Suffix amount with $ symbol.


with sales as
        (select customer_id as Customer
        , date_format(sales_date, '%b-%y') as sales_date
        , replace(amount, '$', '') as amount
        from sales_data),
    sales_per_cust as
        (select Customer
        , sum(case when sales_date = 'Jan-21' then amount else 0 end) as Jan_21
        , sum(case when sales_date = 'Feb-21' then amount else 0 end) as Feb_21
        , sum(case when sales_date = 'Mar-21' then amount else 0 end) as Mar_21
        , sum(case when sales_date = 'Apr-21' then amount else 0 end) as Apr_21
        , sum(case when sales_date = 'May-21' then amount else 0 end) as May_21
        , sum(case when sales_date = 'Jun-21' then amount else 0 end) as Jun_21
        , sum(case when sales_date = 'Jul-21' then amount else 0 end) as Jul_21
        , sum(case when sales_date = 'Aug-21' then amount else 0 end) as Aug_21
        , sum(case when sales_date = 'Sep-21' then amount else 0 end) as Sep_21
        , sum(case when sales_date = 'Oct-21' then amount else 0 end) as Oct_21
        , sum(case when sales_date = 'Nov-21' then amount else 0 end) as Nov_21
        , sum(case when sales_date = 'Dec-21' then amount else 0 end) as Dec_21
        , sum(amount) as Total
        from sales s
        group by Customer),
    sales_per_month as
        (select 'Total' as Customer
        , sum(case when sales_date = 'Jan-21' then amount else 0 end) as Jan_21
        , sum(case when sales_date = 'Feb-21' then amount else 0 end) as Feb_21
        , sum(case when sales_date = 'Mar-21' then amount else 0 end) as Mar_21
        , sum(case when sales_date = 'Apr-21' then amount else 0 end) as Apr_21
        , sum(case when sales_date = 'May-21' then amount else 0 end) as May_21
        , sum(case when sales_date = 'Jun-21' then amount else 0 end) as Jun_21
        , sum(case when sales_date = 'Jul-21' then amount else 0 end) as Jul_21
        , sum(case when sales_date = 'Aug-21' then amount else 0 end) as Aug_21
        , sum(case when sales_date = 'Sep-21' then amount else 0 end) as Sep_21
        , sum(case when sales_date = 'Oct-21' then amount else 0 end) as Oct_21
        , sum(case when sales_date = 'Nov-21' then amount else 0 end) as Nov_21
        , sum(case when sales_date = 'Dec-21' then amount else 0 end) as Dec_21
        , '' as Total
        from sales s),
    final_data as
        (select * from sales_per_cust
        UNION
        select * from sales_per_month)
select Customer
, case when Jan_21 < 0 then concat('(', Jan_21 * -1 , ')$') else concat(Jan_21, '$') end as "Jan-21"
, case when Feb_21 < 0 then concat('(', Feb_21 * -1 , ')$') else concat(Feb_21, '$') end as "Feb-21"
, case when Mar_21 < 0 then concat('(', Mar_21 * -1 , ')$') else concat(Mar_21, '$') end as "Mar-21"
, case when Apr_21 < 0 then concat('(', Apr_21 * -1 , ')$') else concat(Apr_21, '$') end as "Apr-21"
, case when May_21 < 0 then concat('(', May_21 * -1 , ')$') else concat(May_21, '$') end as "May-21"
, case when Jun_21 < 0 then concat('(', Jun_21 * -1 , ')$') else concat(Jun_21, '$') end as "Jun-21"
, case when Jul_21 < 0 then concat('(', Jul_21 * -1 , ')$') else concat(Jul_21, '$') end as "Jul-21"
, case when Aug_21 < 0 then concat('(', Aug_21 * -1 , ')$') else concat(Aug_21, '$') end as "Aug-21"
, case when Sep_21 < 0 then concat('(', Sep_21 * -1 , ')$') else concat(Sep_21, '$') end as "Sep-21"
, case when Oct_21 < 0 then concat('(', Oct_21 * -1 , ')$') else concat(Oct_21, '$') end as "Oct-21"
, case when Nov_21 < 0 then concat('(', Nov_21 * -1 , ')$') else concat(Nov_21, '$') end as "Nov-21"
, case when Dec_21 < 0 then concat('(', Dec_21 * -1 , ')$') else concat(Dec_21, '$') end as "Dec-21"
, case when Total = '' then ''
       when Total < 0 then concat('(', Total * -1 , ')$')
       else concat(Total, '$') end as "Total"
from final_data;
