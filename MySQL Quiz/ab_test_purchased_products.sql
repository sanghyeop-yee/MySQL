-- Purchased products of AB-test variation

-- Purpose:
-- “Which products were purchased more often?”
-- “Do users just want to try our product (they purchase a monthly subscription) 
-- or they’re fully committed and purchase the yearly subscription?”

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
    SUM(CASE WHEN p.refunded = FALSE THEN p.amount END) AS total_revenue,
    COUNT(DISTINCT(CASE WHEN p.refunded = FALSE AND r.name = 'Yearly subscription' THEN p.user_id END)) AS yearly_customers,
    COUNT(DISTINCT(CASE WHEN p.refunded = FALSE AND r.name = 'Monthly subscription' THEN p.user_id END)) AS monthly_customers
  FROM ab_test_categorization c
  LEFT JOIN books_users b
    ON c.user_id = b.user_id
  LEFT JOIN purchases p
    ON c.user_id = p.user_id
  LEFT JOIN products r
    ON r.id = p.product_id
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
  monthly_customers,
  ROUND(100.0 * monthly_customers / cohort_size, 2) AS monthly_purchase_rate
FROM ab_test_stats