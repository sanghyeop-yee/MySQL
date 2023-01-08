-- Leetcode
-- Q601. Human Traffice of Stadium

-- Write an SQL query to display the records with three or more rows with consecutive id's, 
-- and the number of people is greater than or equal to 100 for each.
-- Return the result table ordered by visit_date in ascending order.

-- Approach: Using WHERE clause
-- 3 consecutive rows can be formed in the following scenarios
-- if the current row has value greater than or equal to 100,
-- check if row+1 and row+2 has value greater than or equal to 100.
-- check if row+1 and row-1 has value greater than or equal to 100.
-- check if row-1 and row-2 has value greater than or equal to 100.

select id, visit_date, people
from stadium
where people >= 100 and
(
id+1 in (select id from stadium where people >=100) and id+2 in (select id from stadium where people >=100) or
id+1 in (select id from stadium where people >=100) and id-1 in (select id from stadium where people >=100) or
id-1 in (select id from stadium where people >=100) and id-2 in (select id from stadium where people >=100)
)
order by id;


-- Leetcode
-- Q180. Consecutive Numbers

-- Write an SQL query to find all numbers that appear at least three times consecutively.

-- Approach: Using distinct and where clause
-- l1, l2, l3 크로스 테이블을 만들어서 붙이기
select distinct l1.num as ConsecutiveNums
from logs l1
join logs l2 on l1.id = l2.id-1 and l1.num = l2.num
join logs l3 on l1.id = l3.id-2 and l1.num = l3.num;

SELECT DISTINCT
    l1.Num AS ConsecutiveNums
FROM
    Logs l1,
    Logs l2,
    Logs l3
WHERE
    l1.Id = l2.Id - 1
    AND l2.Id = l3.Id - 1
    AND l1.Num = l2.Num
    AND l2.Num = l3.Num
;


-- Leetode
-- Q165. Department Top Three Salaries

-- A company's executives are interested in seeing who earns the most money 
-- in each of the company's departments. 
-- A high earner in a department is an employee who has a salary 
-- in the top three unique salaries for that department.

-- Write an SQL query to find the employees who are high earners in each of the departments.
-- Return the result table in any order.

-- Approach: Using DENSE_RANK
select 
	d.name as 'Department', e.name as 'Employee', e.salary as 'Salary'
from 
	(select 
		*,
		dense_rank() over (partition by departmentId order by salary desc) as 'rank'
	from employee) e 
    join department d
    on e.departmentId = d.id
where e.rank <= 3
order by Department, Salary desc;


-- Leetcode
-- Q262. Trips and Users

-- The cancellation rate is computed by dividing the number of canceled (by client or driver) 
-- requests with unbanned users by the total number of requests with unbanned users on that day.

-- Write a SQL query to find the cancellation rate of requests with unbanned users 
-- (both client and driver must not be banned) each day between "2013-10-01" and "2013-10-03". 
-- Round Cancellation Rate to two decimal points.
-- Return the result table in any order.

-- Approach:
-- count(cancelled)
-- count(case when status != 'completed' then 1 else null end)
-- sum(case when status != 'completed' then 1 else 0 end)

select
	request_at as 'Day',
    round(sum(case when status != 'completed' then 1 else 0 end) / count(*), 2) as 'Cancellation Rate'
from Trips
	join Users client on client.users_id = trips.client_id
    join Users driver on driver.users_id = trips.driver_id
where
	client.banned = 'No' and driver.banned = 'No'
    and request_at between '2013-10-01' and '2013-10-03'
group by request_at;



-- Interview Test
-- Most frequently bought pairs of item category

-- Approach:
-- 1. pair all product_id within the same purchase_id
-- 2. except for the product_id of themselves and without repeating

select 
	p1.product_id as first_product,
    p2.product_id as second_product,
    count(*) as pairs_count

from 
	purchase_detail_log p1
    join
    purchase_detail_log p2
    on p1.purchase_id = p2.purchase_id -- pair all product_id within the same purchase_id
    and p1.product_id < p2.product_id -- except for the product_id of themselves and without repeating
group by
	first_product, second_product
order by
	pairs_count desc
limit 5;




-- Leetcode
-- Q1393. Capital Gain/Loss
-- Write an SQL query to report the Capital gain/loss for each stock.

-- The Capital gain/loss of a stock is the total gain or loss after buying and selling the stock one or many times.
-- Return the result table in any order.

-- Approach: using culumulative sum and case when to update 'Buy' price to negative
select 
    stock_name
    ,sum(case when operation = 'Buy' then -price else price end) as 'capital_gain_loss'
from stocks
group by stock_name;

















