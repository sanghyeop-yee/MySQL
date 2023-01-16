
/*
[Question]

Please write a query to calculate 
(a) The number of top 30% of products with the highest sales in 2020 for each category
(b) the number of new products within (a). New products are defined as products registered after 2020.

*/

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
*/

-- [Answer here]
-- (a) The number of top 30% of products with the highest sales in 2020 for each category

-- 0. Join orderdetails and orders table to get sales table and get total sales of each product in 2020
with 
sales as (
select 
	o1.order_date,
    o2.productCode as 'product_id',
    o2.priceEach as 'price',
    o2.quantityOrdered 'quantity',
    round(o2.priceEach * o2.quantityOrdered, 2) as 'sales_amount'
from orders o1 left join orderdetails o2
	on o1.order_id = o2.orderNumber
where year(o1.order_date) = 2020 -- in 2020
),
-- 1. join with products to add product_category column
category_sales as (
select 
	order_date,
    product_id,
    price,
    quantity,
    sales_amount,
    -- register_date,
    productLine as 'product_category'
from sales s join products p
	on s.product_id = p.productCode
),
-- 2. get top percentile rank of each category
category_sales_rank as (
select
	product_category,
    product_id,
    sales_amount,
    -- register_date,
    dense_rank() over (partition by product_category order by sales_amount desc) as 'rank',
    round(percent_rank() over (partition by product_category order by sales_amount desc) * 100, 2) as 'percentile_rank'
from category_sales
)
-- 3. count top 30% of each category
select product_category, count(*) 'number_of_top_30_percent'
from category_sales_rank
where percentile_rank <= 30
-- (b) the number of new products within (a). 
-- and year(register_date) >= 2020
group by product_category;












