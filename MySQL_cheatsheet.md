# MySQL Cheatsheet

# **MySQL**

## **Date Functions**

1. timestamp 형 날짜에서 year 뽑아내기

```sql
select
  extract(year from orderdate) as sales_year
  ,count(orderdate) as orders_cnt
  ,sum(salesamount) as total_sales
from onlinesales
group by sales_year
order by sales_year;
```

1. Date (2022-09-14) 형에서 month (2022-09) 뽑아내기

```sql
select
  date_format(date, '%Y-%m') as year_and_month
from dates;

select
  date_format(date, '%Y-%m-%d') as year_and_month_day
from dates;
```

1. String (2022-09) 형에서 month, date 로 뽑아내기

1. 두 날짜의 차이 구하기

```sql
select
  datediff(last_order_date, first_order_date)
from onlinesales;
```

1. Cohort Analysis: 고객의 Life Time Month 구하기

> 코호트 분석이란 시간에 따라 비슷한 그룹을 비교하는 것입니다.

((Order Date - First Order Date) / 30) +1 as life_time_month
> 
> 
> +1 하는 이유는 첫구매가 1월 1일이고 주문 날짜가 1월 11일이면 
> 1번째 Life Time Month (10일의 차이) 이기 때문에
> 

1. 년도 뽑아내기

```sql
select extract(year from "2022-09-14");

select year(curdate());
```

1. A quick summary of Sales Orders and Sales Amount over the years

```sql
select
  extract(year from orderdate) as SalesYear,
  count(orderdate) as Orders,
  count(distinct(customerkey)) as Customers,
  sum(SalesAmount) as TotalSales
from onlinesales
group by SalesYear
order by SalesYear;
```

1. 이전 달과 비교하기

```sql
select
  year_key,
  month_key,
  count(distinct(customerkey)) as cohort_cust_cnt,
  lag(count(distinct(customerkey)), 1, 0) over (order by year_key, month_key) as PrevCohortCustCount,
  count(distinct(customerkey)) - lag(count(distinct(customerkey)), 1, 0) over (order by year_key, month_key) as ChangeToPrevCohort
from first_purchase
group by
  year_key,
  month_key
order by
  year_key,
  month_key;
```

1. 내 생일 30일 전, 일별 활동 유저 수 보기

```sql
select activity_date as 'day', count(distinct user_id) as 'active_users'
from Activity
where activity_date between date_sub('2023-09-14', interval 30 day) and '2023-09-14'
group by activity_date
order by activity_date;
```

1. 오늘 주문한 고객 수 찾기

```sql
select count(customer_id)
from orders
where date(order_date) = curdate(); -- when order_date is in datetime format
-- where order_date = curdate(); -- when order_date is in date format
```

1. 해당년도에 구매기록이 없는 고객은 0으로 나타내기 (null 값을 0 으로 채워넣기)

`ifnull(orders_in_2019, 0) as 'orders_in_2019'`

`coalesce(orders_in_2019, 0) as 'orders_in_2019'`

```sql
-- 1. 해당년도의 구매자별 주문 수를 구하고
with cte as(
	select buyer_id, count(order_id) as 'orders_in_2019'
	from orders
	where year(order_date) = '2019'
	group by buyer_id
)

-- 2. 유저 테이블에 조인 (단, 구매기록이 없으면 0으로 표시)
select 
	user_id as 'buyer_id'
	,join_date
	,ifnull(orders_in_2019, 0) as 'orders_in_2019'
from users u
left join cte c on c.buyer_id = u.user_id;
```