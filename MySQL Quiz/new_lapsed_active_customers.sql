/*
Below table has customer's order history. 

Find the number of each customer types who ordered today with the following condition.
(a) New or Reactive or Active customers 

* New customers : Customer who purchased for the first time ever
* Reactive customers : Customer who purchased for the first time within six months and they have purchase history before six months
* Active customers : Customer who have repeat purchase history and not Reactive

(b) the average order amount, monthly basis in 2023
*/

/*
[Table schema]
orders
{   
    'order_date' date,
    'order_id' integer,
    'customer_id' integer,
    'product_id' integer
}

orderdetails
{ 
	'orderNumber' integer,
    'productCode' string,
    'quantityOrdered' integer,
    'priceEach' decimal
}
*/
-- ----------------------------------------------------
-- (a) New or Reactive or Active customers 

select * from orderdetails;
select * from orders;

-- 1. Find order sequence by each customer and previous order date for each order
with 
order_sequence as (
select
	customer_id,
	order_date,
    row_number() over (partition by customer_id order by order_date) as 'customer_order_sequence',
    lag(order_date, 1, order_date) over (partition by customer_id order by order_date) as 'prev_order_date'
from orders
group by customer_id, order_date
),
-- 2. Find the lapsed days between orders
time_between_orders as (
select 
	*,
    timestampdiff(month, prev_order_date, order_date) as 'months_between_orders'
from order_sequence
),
-- 3. Label using case when
customer_life_cycle as (
select
	*,
    case
		when customer_order_sequence = 1 then 'New'
        when months_between_orders >= 0 and months_between_orders < 6 then 'Active'
        when months_between_orders >= 6 then 'Reactive'
	end as 'customer_type'
from time_between_orders
)
-- 4. Count each customer type
select 
	customer_type,
	count(distinct customer_id) as 'total_order_customers'
from customer_life_cycle
where order_date = curdate() -- as of today, today's total 
group by customer_type;


-- ----------------------------------------------------
-- (b) the average order amount (monthly basis in 2023)
-- 1. Left join orders and orderdetails to get order_amount for each order
with
total_order_amount as (
select 
	o1.order_id,
    o1.order_date,
    date_format(order_date, '%Y-%m') as 'year_and_month', -- date keys to group
    o1.customer_id,
    sum(o2.quantityOrdered*priceEach) as 'order_amount'
from orders o1 left join orderdetails o2
	on o1.order_id = o2.orderNumber
group by 
	o1.order_id,
    o1.order_date,
    o1.customer_id
)
-- 2. group by year and month get avg order amount
select
	year_and_month,
    sum(order_amount) as 'monthly_total_order_amount',
	round(avg(order_amount), 2) as 'monthly_avg_order_amount'
from total_order_amount
where extract(year from order_date) = 2023
group by year_and_month;