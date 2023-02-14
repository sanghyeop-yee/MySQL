-- Most Frequently Used Dates Function

-- 1. Extract year from timestamp
-- extract(year from orderdate)
select
  extract(year from orderdate) as sales_year
  ,count(orderdate) as orders_cnt
  ,sum(salesamount) as total_sales
from onlinesales
group by sales_year
order by sales_year;


-- 2. Extract year and month (or day) as a group
-- date_format(orderdate, '%Y-%m') as year_and_month
select
  date_format(date, '%Y-%m') as year_and_month
from dates;

select
  date_format(date, '%Y-%m-%d') as year_and_month_day
from dates;


-- 3. Get difference between two dates
-- datediff(today, previous_date)
-- timestampdiff(month, prev_order_date, order_date)

-- days
select
  datediff(order_date, prev_order_date) -- today - past
from onlinesales;

-- months
select
	timestampdiff(month, prev_order_date, order_date)  -- past - today
from onlinesales;

-- 4. Add a time
-- date_add(signup_date, interval 1 day)
select date_add(curdate(), interval 1 month);

select 
	round(100.0 *
		sum(case when activity_date = date_add(signup_date, interval 1 day) then 1 else 0 end) 
        / count(distinct user_id)
  , 2) as d1_retention;



