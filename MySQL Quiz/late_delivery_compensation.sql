/*

[Question]
Please create a query that calculates the appropriate compensation amount 
for each customer who either received their product late or who have not yet received it.

* Compensation
For 10 days or more : 1000 won (each product)
For 15 days or more : 3000 won (each product)
*/

select * from orders;
select * from orderdetails;
select * from products;

/*
[Table schema]
orders
{   
    'order_date' date,
    'order_id' integer,
    'customer_id' integer,
    'product_id' integer,
    'shipped_date' date
}

orderdetails
{
	'orderNumber' integer,
    'productCode' string,
    'quantityOrdered' integer,
    'priceEach' integer
}

products
{   
    'productCode' integer,
    'productName' string,
    'productLine' string,
    'register_date' date
}

customer
{   
    'customer_id' integer,
    'customer_name' string,
    'join_date' date    
}

Delivery
{   
    'id' integer,
    'delivery_id' integer,
    'delivery_status' integer, (**60 : delivery_completed / 70 : delivery_not_completed)
    'delivery_status_time' timestamp
}
*/


-- [Answer]
-- | customer_id | compensation_amount |

-- 1. Join orders and orderdetails to add a column (product counts per order) and a delivery lapsed time column
with 
product_ordered_count as (
select
	o1.order_id,
    o1.order_date,
    o1.shippedDate,
    o1.customer_id,
    o2.product_cnt,
    datediff(o1.shippedDate, o1.order_date) as 'delivery_lapsed_days' -- add a delivery lapsed days column
from orders o1 left join 
	(
	select orderNumber, count(productCode) as 'product_cnt'
	from orderdetails
	group by orderNumber
    ) o2
	on o1.order_id = o2.orderNumber
)
,
-- 2. Calculate compensation amount for each order
compensation_order as (
select 
	*,
    case
		when delivery_lapsed_days >= 6 then product_cnt*1000
        when delivery_lapsed_days >= 8 then product_cnt*3000
	end as 'compensation_amount'
from product_ordered_count
)
-- 3. Calculate compensation amount for each customer
select customer_id, coalesce(sum(compensation_amount), 0) as 'total_compensation'
from compensation_order
group by customer_id;

