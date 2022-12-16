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
