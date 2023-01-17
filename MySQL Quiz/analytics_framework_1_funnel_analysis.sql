-- Analytics Framework 1: Funnel Analysis
-- 퍼넬분석이란 목표까지의 고객 여정을 단계별로 나눠 단계별로 나눠 전환과 이탈을 측정하는 방식을 말합니다.


-- Purpose:
-- 1. 어느 단계에 집중해서 개선해야할까?
-- 2. 고객을 목표지점까지 잘 데려오고, 꾸준히 상품을 쓰고 있을까?


-- Steps:
-- 1. 최종 목표, 비즈니스에서 가장 중요한 메트릭 정의하기
	-- e.g. Uber
    -- 목표: Call Uber
    -- 단계: Decision to use -> Set up account -> Request a ride -> Arrival

-- 2. 목표까지의 단계, 시나리오 만들어보기
-- 3. 전환율 기준 정하기
-- 4. 전환율 데이터 산출하기 (가설에 따라 세그먼트로 나눠서 비교하기)
-- 5. A/B 테스트로 지표 개선해가기


-- 1) Measuring traffic per device
-- Let’s calculate how many pageviews from mobile devices Bindle website had in Feb, 2018.
show tables;
select * from activity_log;

select 
    date_format(stamp, '%Y-%m') as 'month',
    count(*)
from activity_log
group by 1
order by 1;


-- 2) Web Funnels Part 1: Measuring traffic on a page
-- step 1. pageviews on homepage
SELECT
  COUNT(*) AS homepage_pvs
FROM web_analytics.pageviews
WHERE
  url = 'https://www.bindle.com/'
  OR url LIKE 'https://www.bindle.com/?%';
  
-- unique visitors
SELECT
  COUNT(DISTINCT(visitor_id)) AS homepage_unique_visits
FROM web_analytics.pageviews
WHERE
  url = 'https://www.bindle.com/'
  OR url LIKE 'https://www.bindle.com/?%';

-- Step 2: book page pageviews
SELECT
  COUNT(*) AS books_pvs
FROM web_analytics.pageviews
WHERE
  url LIKE '%/books/%'
  AND (
    referer_url = 'https://www.bindle.com/'
    OR referer_url LIKE 'https://www.bindle.com/?%';
  )
  
-- Count how many unique visitors Bindle had on all book pages in Feb, 2018? (with or without referral)
SELECT 
  to_char(created_at, 'yyyy-mm') as year_and_month,
  count(distinct(visitor_id)) as visitors_cnt
FROM web_analytics.pageviews
where 
  url like '%/books/%'
group by 1
order by 1;


-- 3) Web Funnels Part 2: Funnel based on referral URL
-- Which percentage of homepage visits is followed up by a visit to a book page?
-- Left Join to join homepage pageviews to book pageviews
SELECT
  COUNT(h.visitor_id) AS homepage_pvs,
  COUNT(b.visitor_id) AS book_page_pvs
FROM web_analytics.pageviews h
LEFT JOIN web_analytics.pageviews b
  ON h.visitor_id = b.visitor_id
    AND b.url LIKE '%/books/%'
    AND (
      b.referer_url = 'https://www.bindle.com/'
      OR b.referer_url LIKE 'https://www.bindle.com/?%'
    )  
    AND b.created_at BETWEEN h.created_at AND date_add(h.created_at, interval 30 minute)
WHERE
  h.url = 'https://www.bindle.com/'
  OR h.url LIKE 'https://www.bindle.com/?%';


-- Calculating funnel step churn rate
-- A two step funnel - users visit the homepage and then go to a book page
-- Let's calculate churn rate of this step.
-- Calculate percentage of visitors who did not go from the homepage to a book page.
SELECT
  cast(100 - 100 * COUNT(DISTINCT(b.visitor_id)) / COUNT(DISTINCT(h.visitor_id)) as float) AS 'churn_rate'
FROM web_analytics.pageviews h
LEFT JOIN web_analytics.pageviews b
  ON h.visitor_id = b.visitor_id
    AND b.url LIKE '%/books/%'
    AND (
      b.referer_url = 'https://www.bindle.com/'
      OR b.referer_url LIKE 'https://www.bindle.com/?%'
    )  
     AND b.created_at BETWEEN h.created_at AND date_add(h.created_at, interval 30 minute)
WHERE
  h.url = 'https://www.bindle.com/'
  OR h.url LIKE 'https://www.bindle.com/?%';
  


-- 132. Listing traffice sources based on referer URL
-- a query that lists all referer URL-s visitors come from
-- 모든 리퍼럴 페이지별 방문자 수 구하기
SELECT
  referer_url,
  COUNT(*)
FROM web_analytics.pageviews
WHERE
  referer_url NOT LIKE 'https://www.bindle.com%'
GROUP BY 1
ORDER BY 2 DESC;

-- 133. Identifying TOP traffic source for a landing page
SELECT
  referer_url,
  COUNT(*)
FROM web_analytics.pageviews
WHERE
  (url = 'https://www.bindle.com/'
  OR url LIKE 'https://www.bindle.com/?%')
  AND referer_url NOT LIKE 'https://www.bindle.com%'
GROUP BY 1
ORDER BY 2 DESC;


-- 135. Building web funnels based on events
-- First funnel with events
SELECT
  COUNT(DISTINCT(p.visitor_id)) AS unique_visitors,
  COUNT(DISTINCT(e.pageview_id)) AS unique_clicks
FROM web_analytics.pageviews p
-- We’re joining only specific click events. 
-- If we add this filter in the WHERE clause it’d filter out all pageviews without events.
LEFT JOIN web_analytics.events e
  ON p.pageview_id = e.pageview_id
    AND e.category = 'Signup Button'
    AND e.action = 'Click'
WHERE
  url LIKE '%/books/%';

-- 136. Multistep funnels with pageviews and events
-- add one more step - an actual signup event
SELECT
  COUNT(DISTINCT(p.visitor_id)) AS unique_visitors,
  COUNT(DISTINCT(c.pageview_id)) AS clicks,
  COUNT(DISTINCT(s.pageview_id)) AS signups
FROM web_analytics.pageviews p
LEFT JOIN web_analytics.events c
  ON p.pageview_id = c.pageview_id
    AND c.category = 'Signup Button'
    AND c.action = 'Click'
-- Naming for signup event might be a bit confusing. 
-- Category parameter is reserved for an element we interact with. 
-- We could specify Category as “Signup from” and Action as “Submit”. 
-- For simplicity we’ll just use “Signup” for both category and action.
LEFT JOIN web_analytics.events s
  ON p.pageview_id = s.pageview_id
    AND s.category = 'Signup'
    AND s.action = 'Signup'    
WHERE
  url LIKE '%/books/%';


-- 137. CTR of a "Signup" button
-- Which device type has the highest CTR of a signup button on book pages?
-- Consider unique visitors when calculating CTR
select 
  p.device_type,
  count(distinct(p.visitor_id)) as unique_visitors,
  count(distinct(e.pageview_id)) as unique_clicks,
  100*(count(distinct(e.pageview_id)) / count(distinct(p.visitor_id))::float) as ctr_signup_button,
  count(distinct(s.pageview_id)) as signups
from web_analytics.pageviews p
left join web_analytics.events e
  on p.pageview_id = e.pageview_id
  and e.category = 'Signup Button'
  and e.action = 'Click'
left join web_analytics.events s
  on p.pageview_id = s.pageview_id
  and s.category = 'Signup'
  and s.action = 'Signup'
where url like '%/books/%'
group by 1
order by 4 desc;

  
-- 143. Percentage of mobile traffic on the page
SELECT device_type, count(DISTINCT(visitor_id)), 
  count(DISTINCT(visitor_id))::float /
  (select count(distinct(visitor_id))
  from web_analytics.pageviews
  where url like '%/books/%') * 100
FROM web_analytics.pageviews
where url like '%/books/%'
group by 1;

SELECT
  100 * COUNT(DISTINCT(
    CASE WHEN device_type = 'mobile' THEN visitor_id END
  )) / COUNT(DISTINCT(visitor_id))::float
FROM web_analytics.pageviews
WHERE
  url LIKE '%/books/%';
  

-- 146. Onboarding funnel analysis on the web
/*
onboarding pages
/welcome
/select-genres
/library
/reader/:slug
*/

/*
Our query should reflect all of the following assumptions.
- users visit onboarding pages exactly in this order
- timestamp of each pageview will be greater than the previous pageview
- referer URL of each pageview is the URL of a previous page
*/

