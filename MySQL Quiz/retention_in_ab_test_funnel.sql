-- Analytics Framework: Retention in AB Test Funnel

-- Purpose:
-- A lot of AB-tests done in the product ideally should convert to better retention.
-- Let’s add a D7 retention rate to the AB-test funnel.

-- Approach:
-- 1. Start with a query that gives us a cohort of the user.
-- 2. LEFT JOIN any data we need.
-- 3. Use subqueries to break down calculation logic.
-- 4. Group and count or sum.
-- 5. Answer

-- Steps:
-- 1. Calculating retention rate per user
-- 2. Adding D7 retention rate to AB-test funnel


-- AB Test cohorts with categorization
WITH ab_test_categorization AS (
  SELECT
    user_id,
    custom_parameters ->> 'ab_test_name' AS ab_test_name,
    custom_parameters ->> 'ab_test_variation' AS ab_test_variation,
    created_at AS categorized_at
  FROM mobile_analytics.events
  WHERE
    custom_parameters ->> 'ab_test_name' IS NOT NULL
    AND action = 'signup'
), 
-- Calculating retention rate per user
user_activity AS (
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
), user_retention_days AS (
  SELECT
    user_id,
    -- Get days after signup when a user was active
    datediff(activity_date, signup_date) as retention_day
  FROM user_activity
), ab_test_stats AS (
  SELECT
    ab_test_variation AS variation,
    COUNT(DISTINCT(c.user_id)) AS cohort_size,
    COUNT(DISTINCT(b.user_id)) AS users_with_books,
    COUNT(DISTINCT(CASE WHEN last_page > 0 THEN b.user_id END)) AS users_with_started_books,
    COUNT(DISTINCT(CASE WHEN p.refunded = FALSE THEN p.user_id END)) AS customers,
    COUNT(DISTINCT(CASE WHEN p.refunded = TRUE THEN p.user_id END)) AS refunds,
    SUM(CASE WHEN p.refunded = FALSE THEN p.amount END) AS total_revenue,
    COUNT(DISTINCT(CASE WHEN p.refunded = FALSE AND r.name = 'Yearly subscription' THEN p.user_id END)) AS yearly_customers,
    COUNT(DISTINCT(CASE WHEN a.retention_day = 7 THEN a.user_id END)) AS d7_active_users
  FROM ab_test_categorization c
  LEFT JOIN books_users b
    ON c.user_id = b.user_id
  LEFT JOIN purchases p
    ON c.user_id = p.user_id
  LEFT JOIN products r
    ON r.id = p.product_id
  LEFT JOIN user_retention_days AS a
    ON c.user_id = a.user_id
  WHERE
    ab_test_name = 'longer_onboarding_201803'
  GROUP BY 1
)

SELECT
  variation,
  cohort_size,
  users_with_books,
  ROUND(100.0 * users_with_books / cohort_size, 2) AS soft_activation_rate,
  users_with_started_books,
  ROUND(100.0 * users_with_started_books / cohort_size, 2) AS activation_rate,
  customers,
  ROUND(100.0 * customers / cohort_size, 2) AS purchase_rate,
  refunds,
  ROUND(total_revenue, 2) AS total_revenue,
  ROUND(total_revenue / cohort_size, 2) AS ARPU,
  yearly_customers,
  ROUND(100.0 * yearly_customers / cohort_size, 2) AS yearly_purchase_rate,
  ROUND(100.0 * d7_active_users / cohort_size, 2) AS d7_retention_rate
FROM ab_test_stats
