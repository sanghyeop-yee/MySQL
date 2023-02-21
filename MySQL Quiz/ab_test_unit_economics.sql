-- Unit economics for AB-test variations

-- Purpose:
-- Let’s think money. How could we measure the success of the AB-test from this perspective? 
-- Some questions to start from:

-- 1. How much money did we earn per variation?. That’s the most generic question. 
-- 2. ARPU per variation. The more precise way to look at the previous question.
-- 3. How many refunds did we have per variation?. Our safety net question. 
	-- When AB-testing something price sensitive we need to make sure customers don’t churn early.
-- 4. Purchase rate. Did our AB-test cause more users to purchase 
    -- or fewer users started purchasing more expensive products?

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
), ab_test_stats AS (
  SELECT
    ab_test_variation AS variation,
    COUNT(DISTINCT(c.user_id)) AS cohort_size,
    COUNT(DISTINCT(b.user_id)) AS users_with_books,
    COUNT(DISTINCT(CASE WHEN last_page > 0 THEN b.user_id END)) AS users_with_started_books,
    COUNT(DISTINCT(CASE WHEN p.refunded = FALSE THEN p.user_id END)) AS customers,
    COUNT(DISTINCT(CASE WHEN p.refunded = TRUE THEN p.user_id END)) AS refunds,
    SUM(CASE WHEN p.refunded = FALSE THEN p.amount END) AS total_revenue
  FROM ab_test_categorization c
  LEFT JOIN books_users b
    ON c.user_id = b.user_id
  LEFT JOIN purchases p
    ON c.user_id = p.user_id
  WHERE
    ab_test_name = 'longer_onboarding_202302'
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
  ROUND(total_revenue / cohort_size, 2) AS ARPU
FROM ab_test_stats