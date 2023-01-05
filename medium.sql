--The PADS

-- Ashely(P)
-- Christeen(P)
-- Jane(A)
-- Jenny(D)
-- Julia(A)
-- There are a total of [occupation_count] [occupation]s.

select concat(Name,'(',substring(Occupation,1,1),')') from Occupations 
order by Name asc; 

select concat('There are a total of ',count(Occupation),' ',
	lower(Occupation),'s.') 
from Occupations group by Occupation 
order by count(Occupation),Occupation;
============================================================================
--Occupations

-- Pivot the Occupation column in OCCUPATIONS so that each Name is 
-- sorted alphabetically and displayed underneath its corresponding 
-- Occupation. The output column headers should be Doctor, Professor, Singer, 
-- and Actor, respectively.

-- Jenny    Ashley     Meera  Jane
-- Samantha Christeen  Priya  Julia
-- NULL     Ketty      NULL   Maria


-- prints groups corresponding to same rn
select max(rn) from(select Name,Occupation,Row_number() 
over(partition by Occupation order by Name asc) as rn
from Occupations) as ord group by rn;

select min(if(Occupation='Doctor',Name,NULL)),
min(if(Occupation='Professor',Name,NULL)),
min(if(Occupation='Singer',Name,NULL)),
min(if(Occupation='Actor',Name,NULL)) 
from
(select Name,Occupation,Row_number() 
over(partition by Occupation order by Name asc) as rn
from Occupations) as ord group by rn;

============================================================================
--Binary Tree Nodes


--     Root: If node is root node.
--     Leaf: If node is leaf node.
--     Inner: If node is neither root nor leaf node.


-- 1 Leaf
-- 2 Inner
-- 3 Leaf
-- 5 Root
-- 6 Leaf
-- 8 Inner
-- 9 Leaf


select N,
    case
        when P is NULL then 'Root'
        when N in (select P from BST) then 'Inner' -- N is a child of some P
        else 'Leaf'
    end
from BST order by N;

============================================================================
-- New Company

-- join data from multiple table
-- as we've used count() we need to use group by 
-- select has C.company_code, C.founder -> so group by must have these 2
-- (whatever is on select group by will have exact same thing)

select C.company_code, C.founder, 
    count(distinct L.lead_manager_code), count(distinct S.senior_manager_code), 
    count(distinct M.manager_code),count(distinct E.employee_code) 
from Company C, Lead_Manager L, Senior_Manager S, Manager M, Employee E
where C.company_code = L.company_code 
    and L.lead_manager_code=S.lead_manager_code 
    and S.senior_manager_code=M.senior_manager_code 
    and M.manager_code=E.manager_code 
group by C.company_code ,C.founder order by C.company_code;

====================================================================================
-- Placements

-- Students
-- ------------
-- id int
-- name string

-- Friends
-- ---------------
-- id int  
-- friend_id int

-- Packages
-- ----------------
-- id int
-- salary float

-- utput the names of those students whose best friends got offered 
-- a higher salary than them. Names must be ordered by the salary amount offered 
-- to the best friends. It is guaranteed that no two students got same salary offer.


select name from Students s
inner join Friends as f on s.id = f.id
inner join Packages as p on s.id = p.id
where p.salary < (select salary from Packages where id = f.friend_id)
order by (select salary from Packages where id = f.friend_id)

=====================================================================================
-- Project Planning

-- Projects
-- ---------------------
-- task_id int
-- start_date date
-- end_date date

-- output the start and end dates of projects listed by the number 
-- of days it took to complete the project in ascending order. If there 
-- is more than one project that have the same number of completion days, 
-- then order by the start date of the project.

with p_start as(
    select start_date, row_number() over(order by start_date) as rn 
    from projects 
    where start_date not in (select end_date from projects)
    ),
p_end as(
    select end_date, row_number() over(order by end_date) as rn 
    from projects 
    where end_date not in (select start_date from projects)
    )
select start_date, end_date from p_start,p_end where p_start.rn = p_end.rn
order by datediff(end_date, start_date), start_date;
=====================================================================================

-- Consider P1(a,b) and P2(c,d) to be two points on a 2D plane.

-- a = minimum value in Northern Latitude (LAT_N in STATION).
-- b = minimum value in Western Longitude (LONG_W in STATION).
-- c = maximum value in Northern Latitude (LAT_N in STATION).
-- d = maximum value in Western Longitude (LONG_W in STATION).

-- Query the Manhattan Distance between points P1 and P2 and round it to a scale 
-- of 4 decimal places.


> select round(abs(min(Lat_N)-max(Lat_N))
        + abs(min(Long_W)-max(Long_w)),4)
from Station;

-- Euclidean Distance

> select round(sqrt(
                power((min(Lat_N)-max(Lat_N)),2)
                +power((min(Long_W)-max(Long_w)),2)),4)
from Station;


-- A median is defined as a number separating the higher half of a data set 
-- from the lower half. Query the median of the Northern Latitudes (LAT_N) 
-- from STATION and round your answer to 4 decimal places.


> set @rowindex := -1;
 
select round(avg(x.Lat_N),4) as Median 
from
   (select @rowindex:=@rowindex + 1 as rowindex,Station.Lat_N as Lat_N
    from Station order by Station.Lat_N) as x
where
x.rowindex in (floor(@rowindex / 2), ceil(@rowindex / 2));


-- Explanation :

-- 1. Beginning with the internal subquery – the select assigns 
-- @rowindex as an incremental index for each Lat_N that is selected 
-- and sorts the Lat_N.
-- 2. Once we have the sorted list of Lat_N, the outer query will 
-- fetch the middle items in the array. If the array contains an odd 
-- number of items, both values will be the single middle value.
-- 3. Then, the SELECT clause of the outer query returns the average of 
-- those two values as the median value.

> select ROUND(ranks.lat_n, 4)
from 
(select lat_n, rank() over(order by lat_n) as lat_rank
from station) as ranks
where ranks.lat_rank = (select round(count(*)/2,0) from station);

======================================================================================
-- generate a report containing three columns: Name, Grade and Mark. grade < 8 use 
-- "NULL" in the name & list them by grade descending & then marks ascending if 
-- grade 8-10 order by grade descending & name ascending

-- STUDENTS
-- ==========
-- Field   Type
-- --------------
-- Id     Integer
-- Name   String
-- Marks  Integer

-- GRADES
-- =========
-- Field    Type
-- --------------
-- Grade     Integer
-- Min_mark  Integer
-- Max_mark  Integer


> select ( case when Grade < 8 then NULL else Name end), Grade, Marks from Students 
inner join Grades on Marks between Min_mark and Max_mark 
order by Grade desc, Name asc;


-- subquery

SELECT IF(TBL.Grade < 8, NULL, Students.Name),
    TBL.Grade,
    TBL.Marks
FROM(SELECT Students.Name,Grades.Grade,Students.Marks
        FROM Students,Grades
        WHERE Students.Marks BETWEEN Grades.Min_Mark AND Grades.Max_Mark
    ) AS TBL
    JOIN Students ON TBL.Name = Students.Name
ORDER BY TBL.Grade DESC,
    Students.Name ASC;


-- Write a query to print the id, age, coins_needed, and power of the wands 
-- that Ron's interested in, sorted in order of descending power. If 
-- more than one wand has same power, sort the result in order of descending age.

-- WANDS
-- ======
-- Field         Type
-- ----------------------
-- Id            Integer
-- Code          Integer
-- Coins_needed  Integer
-- Power         Integer

-- WANDS_PROPERTY
-- ================
-- Field         Type
------------------------
-- Code          Integer
-- Age           Integer
-- Is_evil       Integer

> select 
    ww.id, 
    temp.age,
    temp.coins_needed,
    temp.power
from(select w.code,
    min(w.coins_needed) coins_needed,
    w.power,
    wp.age
from wands w, wands_property wp where w.code = wp.code and wp.is_evil = 0
group by w.code, w.power, wp.age) temp left join wands ww on temp.code=ww.code 
and temp.power=ww.power and temp.coins_needed = ww.coins_needed
order by temp.power desc, temp.age desc;

> select w.id, w.power, w.coins_needed, ww.age from wands w
join wands_property ww on w.code = ww.code where ww.is_evil=0
and w.coins_needed in 
(select min(coins_needed) over (partition by code,power order by coins_needed)
from wands w) order by w.power desc, w.age desc ;

======================================================================================

-- Write a query to print the respective hacker_id and name of hackers who 
-- achieved full scores for more than one challenge. Order your output in 
-- descending order by the total number of challenges in which the hacker 
-- earned a full score. If more than one hacker received full scores in same 
-- number of challenges, then sort them by ascending hacker_id.

-- Hackers
-- =========
-- Field         Type
------------------------
-- Hacker_Id   Integer
-- Name         String

-- Difficulty
-- ===========
-- Field                Type
--------------------------------
-- Difficulty_level   Integer
-- Score              Integer


-- Challenges
-- ============
-- Field                Type
--------------------------------
-- Challange_Id       Integer
-- Hacker_Id          Integer
-- Difficulty_level   Integer


> SELECT R.HACKER_ID, R.NAME FROM SUBMISSIONS S 
INNER JOIN HACKERS R ON R.HACKER_ID = S.HACKER_ID
INNER JOIN CHALLENGES C ON C.CHALLENGE_ID = S.CHALLENGE_ID
INNER JOIN DIFFICULTY D ON D.DIFFICULTY_LEVEL = C.DIFFICULTY_LEVEL
GROUP BY R.HACKER_ID, R.NAME
HAVING SUM(IF(S.SCORE= D.SCORE, 1,0))> 1
ORDER BY SUM(IF(S.SCORE = D.SCORE, 1,0)) DESC, R.HACKER_ID

======================================================================================

-- P(R) represents a pattern drawn by Julia in R rows. The following 
-- pattern represents P(5):

-- * * * * * 
-- * * * * 
-- * * * 
-- * * 
-- *

-- Write a query to print the pattern P(20).


> WITH RECURSIVE cte (n) AS
(
  SELECT 20
  UNION ALL
  SELECT n - 1 FROM cte WHERE n >1
)

SELECT repeat('* ', n) FROM cte;

> DELIMITER $$
CREATE PROCEDURE P(R int) 
BEGIN
   WHILE R > 0 DO
       SELECT REPEAT("* ", R);
       set R = R - 1;
   END WHILE;
END$$
DELIMITER ;

CALL P(20);

-- P(R) represents a pattern drawn by Julia in R rows. The following pattern 
-- represents P(5):

-- * 
-- * * 
-- * * * 
-- * * * * 
-- * * * * *

-- Write a query to print the pattern P(20).

DELIMITER $$
CREATE PROCEDURE P(R int) 
BEGIN
   WHILE R < 21 DO
       SELECT REPEAT("* ", R);
       set R = R + 1;
   END WHILE;
END$$
DELIMITER ;

CALL P(1);

======================================================================================

-- Julia asked her students to create some coding challenges. 
-- Write a query to print the hacker_id, name, and the total number of 
-- challenges created by each student. Sort your results by the total number 
-- of challenges in descending order. If more than one student created the same 
-- number of challenges, then sort the result by hacker_id. If more than one student 
-- created the same number of challenges and the count is less than the maximum 
-- number of challenges created, then exclude those students from the result.

-- Input Format

-- The following tables contain challenge data:

--     Hackers: The hacker_id is the id of the hacker, and name is the name of 
--     the hacker.

--         Field          Type
--     --------------------------
--         Hacker_Id    Integer
--         Name           String   
  

--     Challenges: The challenge_id is the id of the challenge, and hacker_id is 
--     the id of the student who created the challenge. 

--       Field           Type
--     --------------------------
--         Challenge_Id  Integer
--         Hacker_Id     Integer


SELECT H.HACKER_ID, 
       H.NAME, 
       COUNT(C.CHALLENGE_ID) AS C_COUNT
FROM HACKERS H
JOIN CHALLENGES C ON C.HACKER_ID = H.HACKER_ID
GROUP BY H.HACKER_ID, H.NAME
HAVING C_COUNT = 
    (SELECT COUNT(C2.CHALLENGE_ID) AS C_MAX
     FROM CHALLENGES AS C2
     GROUP BY C2.HACKER_ID 
     ORDER BY C_MAX DESC LIMIT 1)
OR C_COUNT IN 
    (SELECT DISTINCT C_COMPARE AS C_UNIQUE
     FROM (SELECT H2.HACKER_ID, 
                  H2.NAME, 
                  COUNT(CHALLENGE_ID) AS C_COMPARE
           FROM HACKERS H2
           JOIN CHALLENGES C ON C.HACKER_ID = H2.HACKER_ID
           GROUP BY H2.HACKER_ID, H2.NAME) COUNTS
     GROUP BY C_COMPARE
     HAVING COUNT(C_COMPARE) = 1)
ORDER BY C_COUNT DESC, H.HACKER_ID;

======================================================================================

-- The total score of a hacker is the sum of their maximum scores for all 
-- of the challenges. Write a query to print the hacker_id, name, and total score 
-- of the hackers ordered by the descending score. If more than one hacker achieved 
-- the same total score, then sort the result by ascending hacker_id. Exclude all 
-- hackers with a total score of

-- from your result.

-- Input Format

-- The following tables contain contest data:

--     Hackers: The hacker_id is the id of the hacker, and name is the name of 
--     the hacker.

--     Submissions: The submission_id is the id of the submission, hacker_id is 
--     the id of the hacker who made the submission, challenge_id is the id of 
--     the challenge for which the submission belongs to, and score is the score

--             Field          Type
--     --------------------------
--         Submission_Id    Integer
--         Hacker_Id        Integer 
--         Challenge_Id     Integer
--         Score            Integer

SELECT X.hacker_id, 
(SELECT H.NAME FROM HACKERS H
                      WHERE H.HACKER_ID = X.HACKER_ID) NAME, 
SUM(X.SCORE) TOTAL_SCORE FROM 
  (SELECT HACKER_ID, MAX(SCORE) SCORE FROM SUBMISSIONS S
   GROUP BY 1, S.CHALLENGE_ID) X 
GROUP BY 1
HAVING TOTAL_SCORE > 0
ORDER BY TOTAL_SCORE DESC, HACKER_ID;

======================================================================================

-- Write a query to print all prime numbers less than or equal to 1000. 
-- Print your result on a single line, and use the ampersand (&) character as 
-- your separator (instead of a space).

-- For example, the output for all prime numbers

-- would be:

-- 2&3&5&7

declare @result1 nvarchar(4000) = '2'

declare @n int = 1000

declare @i decimal(10,5) = 3

declare @boundary int
declare @isPrime int
declare @loop int

while @i < @n
begin
    select @boundary = cast(Sqrt(@i) as int)
    set @loop = 3
    set @isprime = 1

    if @i = 1 begin set @isprime = 0 end
    if @i = 2 begin set @isprime = 1 end
    if @i % 2 = 0 begin set @isprime = 0 end

    while @loop <= @boundary and @isprime = 1
    begin
        if @i % @loop = 0 begin set @isprime = 0 end
        set @loop = @loop + 2
    end

    if @isprime = 1
    begin
        set @result1 = @result1 + '&' + cast(cast(@i as int) as nvarchar(10))
    end

    set @i = @i + 1
end

select @result1

-- Oracle

-- WITH THOUSAND AS
--   (SELECT *
--    FROM
--      (SELECT LEVEL LVL
--       FROM DUAL CONNECT BY LEVEL <= 1000)
--    WHERE LVL > 1)
-- SELECT LISTAGG(T1.LVL, '&') WITHIN GROUP(ORDER BY T1.LVL)
-- FROM THOUSAND T1
-- WHERE T1.LVL <=
--     (SELECT COUNT(DISTINCT T2.LVL) + 2
--      FROM THOUSAND T2
--      WHERE T2.LVL < T1.LVL
--        AND MOD(T1.LVL, T2.LVL) > 0);


======================================================================================
-- Symmetric Pairs

-- Functions
-- ----------------
-- x int 
-- y int

-- Two pairs (X1, Y1) and (X2, Y2) are said to be symmetric pairs if 
-- X1 = Y2 and X2 = Y1.

-- Write a query to output all such symmetric pairs in ascending order by the value 
-- of X. List the rows such that X1 ≤ Y1. 

WITH Numbering AS (

SELECT
    X,
    Y,
    ROW_NUMBER() OVER(ORDER BY X, Y) AS RN
FROM Functions
)

SELECT DISTINCT
    N1.X,
    N1.Y
FROM
    Numbering N1 
        JOIN
    Numbering N2 ON N1.X = N2.Y AND N2.X = N1.Y AND N1.RN <> N2.RN
WHERE N1.X <= N1.Y
ORDER BY X,Y
======================================================================================
=====================================================================================
/************
 *  Hard
 * ************/
======================================================================================
======================================================================================
#Interviews

SELECT A.CONTEST_ID, A.HACKER_ID, A.NAME, 
        SUM(TOTAL_SUBMISSIONS) AS TOTAL_SUBMISSIONS, 
        SUM(TOTAL_ACCEPTED_SUBMISSIONS) AS TOTAL_ACCEPTED_SUBMISSIONS,
        SUM(TOTAL_VIEWS) AS TOTAL_VIEWS,
        SUM(TOTAL_UNIQUE_VIEWS) AS TOTAL_UNIQUE_VIEWS
FROM CONTESTS AS A
LEFT JOIN COLLEGES AS B
    ON A.CONTEST_ID = B.CONTEST_ID
LEFT JOIN CHALLENGES AS C
    ON B.COLLEGE_ID = C.COLLEGE_ID 
LEFT JOIN (SELECT CHALLENGE_ID, SUM(TOTAL_VIEWS) AS TOTAL_VIEWS, 
                  SUM(TOTAL_UNIQUE_VIEWS) AS TOTAL_UNIQUE_VIEWS
           FROM VIEW_STATS
           GROUP BY CHALLENGE_ID) AS D 
    ON C.CHALLENGE_ID = D.CHALLENGE_ID 
LEFT JOIN (SELECT CHALLENGE_ID, SUM(TOTAL_SUBMISSIONS) AS TOTAL_SUBMISSIONS, 
                  SUM(TOTAL_ACCEPTED_SUBMISSIONS) AS TOTAL_ACCEPTED_SUBMISSIONS
           FROM SUBMISSION_STATS
           GROUP BY CHALLENGE_ID) AS E
    ON C.CHALLENGE_ID = E.CHALLENGE_ID
GROUP BY A.CONTEST_ID, A.HACKER_ID, A.NAME
HAVING (TOTAL_SUBMISSIONS + TOTAL_ACCEPTED_SUBMISSIONS + TOTAL_VIEWS + TOTAL_UNIQUE_VIEWS) > 0 
ORDER BY A.CONTEST_ID;

=======================================================================================
#15 Days of Learning SQL

SELECT
    submission_date,
    COUNT(DISTINCT hacker_id),
    (SELECT hacker_id
    FROM Submissions
    WHERE submission_date = o.submission_date
    GROUP BY hacker_id
    ORDER BY COUNT(DISTINCT submission_id) DESC, hacker_id ASC
    LIMIT 1) AS most_active,
    (SELECT name
    FROM Hackers
    WHERE hacker_id = most_active)
FROM Submissions o
WHERE hacker_id IN 
               (SELECT i.hacker_id
               FROM Submissions i
               -- FOR each query this WHERE clause is restricting the input set up to date queried in the upmost row
               WHERE i.submission_date <=
                    (SELECT MIN(submission_date) FROM Submissions)
                    + INTERVAL DATEDIFF(o.submission_date, (SELECT MIN(submission_date) FROM Submissions)) DAY
                    -- A way to tell hacker have been consistently posting
                GROUP BY i.hacker_id
                HAVING COUNT(DISTINCT submission_date) = DATEDIFF(o.submission_date, (SELECT MIN(submission_date) FROM Submissions)) + 1
                )
GROUP BY submission_date
ORDER BY submission_date