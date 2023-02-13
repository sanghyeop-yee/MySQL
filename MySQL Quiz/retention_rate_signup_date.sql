-- Analytics Framework: Retention Rate by Users' Signup Date

-- Quesion:
-- Please write a query to get D1 and D2 retention rate of each signup date
-- Expected to see signup_date, signup_users, d1_retention, d2_retention

-- Approach:
-- 1. Start with a query that gives us each users' activity
-- 2. JOIN any data we need.
-- 3. Group and sum using Case When
-- 4. Answer

-- Steps:
-- Get users activity table
with user_activity as (
  select 
    e.user_id,
    u.signup_date,
    date(e.created_at) as activity_date,
    count(*) as daily_activity
  from mobile_analytics.events e
  join users u
    on e.user_id = u.id
  group by 1, 2, 3
  order by 2, 1
)
select 
  signup_date,
  count(distinct user_id) as signup_users,
  round(100.0 *
    sum(case when activity_date = date_add(signup_date, interval 1 day) then 1 else 0 end) /
    count(distinct user_id)
  , 2) as d1_retention,
  round(100.0 *
    sum(case when activity_date = date_add(signup_date, interval 2 day) then 1 else 0 end) /
    count(distinct user_id)
  , 2) as d2_retention
from user_activity
group by 1
order by 1;
