-- Analytics Framework 2: Retention Rate

-- Purpose:
-- 1. How many users came back to the app after X days?

-- Steps:
-- Step 1) User activity data based on analytics events
WITH users_daily_events AS (
  SELECT
    u.user_id,
    date(u.created_at) AS signup_date,
    date(e.created_at) AS activity_date,
    COUNT(*) AS events_counts
  FROM mobile_analytics.events u
  LEFT JOIN mobile_analytics.events e
    ON e.user_id = u.user_id  
  WHERE
    u.action = 'signup'  
  GROUP BY 1, 2, 3
  ORDER BY signup_date ASC, user_id ASC
)
SELECT
  user_id,
  signup_date,
  activity_date
FROM users_daily_events;

-- Step 2) D7 Retention Rate
WITH user_activity AS (
  SELECT
    u.user_id,
    date(u.created_at) AS signup_date,
    date(e.created_at) AS activity_date,
    COUNT(*) AS events_counts
  FROM mobile_analytics.events u
  LEFT JOIN mobile_analytics.events e
    ON e.user_id = u.user_id  
  WHERE
    u.action = 'signup'  
  GROUP BY 1, 2, 3
  ORDER BY signup_date ASC, user_id ASC
)

SELECT 
  100.0 * COUNT(DISTINCT(CASE WHEN activity_date = '2018-02-08' THEN user_id END)) / COUNT(DISTINCT(user_id)) AS D7_retention_rate
FROM user_activity
WHERE 
  signup_date = '2018-02-01';
  

-- Step 3) D1-D30 Retention Curve: active users per day
WITH user_activity AS (
  SELECT
    u.user_id,
    date(u.created_at) AS signup_date,
    date(e.created_at) AS activity_date,
    COUNT(*) AS events_counts
  FROM mobile_analytics.events u
  LEFT JOIN mobile_analytics.events e
    ON e.user_id = u.user_id  
  WHERE
    u.action = 'signup'  
  GROUP BY 1, 2, 3
  ORDER BY signup_date ASC, user_id ASC
)

SELECT
  activity_date, 
  COUNT(DISTINCT(user_id)) AS active_users
FROM user_activity
WHERE
  signup_date = '2018-02-01'
GROUP BY 1
ORDER BY 1 ASC;


-- Step 4) D1-D30 Retention Curve: retention rate for each day
WITH user_activity AS (
  SELECT
    u.user_id,
    date(u.created_at) AS signup_date,
    date(e.created_at) AS activity_date,
    COUNT(*) AS events_counts
  FROM mobile_analytics.events u
  LEFT JOIN mobile_analytics.events e
    ON e.user_id = u.user_id  
  WHERE
    u.action = 'signup'  
  GROUP BY 1, 2, 3
  ORDER BY signup_date ASC, user_id ASC
)
SELECT
  activity_date, 
  COUNT(DISTINCT(user_id)) AS active_users,
  FIRST_VALUE(COUNT(DISTINCT(user_id))) OVER() AS cohort_size,
  100.0 * COUNT(DISTINCT(user_id)) / FIRST_VALUE(COUNT(DISTINCT(user_id))) OVER() AS retention_rate,
  -- D0
  ROW_NUMBER() OVER() - 1 AS retention_day
FROM user_activity
WHERE
  signup_date = '2018-02-01'    
GROUP BY 1
ORDER BY 1 ASC;


