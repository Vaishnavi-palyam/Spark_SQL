-- 1. Aggregations

SELECT * FROM catalog_sql.sales.order;

-- Find the number of orders placed for each product category by each month
SELECT month(order_date) as Month, product_category, count(*) as Number_of_orders
FROM catalog_sql.sales.order
GROUP BY Month, product_category
order by Month asc, Number_of_orders desc;

-- 2. Subquery

-- Fetch month wise orders for home decor
SELECT * FROM
(
    SELECT month(order_date) as Month, product_category, count(*) as Number_of_orders
    FROM catalog_sql.sales.order
    GROUP BY Month, product_category
    order by Month asc, Number_of_orders desc
) tbl1
  WHERE product_category = 'Home Decor';

  -- Correlated subquery
  -- Depends on the outer query. Runs after each row in the outer query
  -- Find the product_name which sells more than average in the same category
  SELECT * FROM catalog_sql.sales.order;

SELECT o1.product_name, o1.product_category, o1.Number_of_orders
FROM
(
      SELECT product_category,
            product_name,
            count(*) as Number_of_orders
            FROM catalog_sql.sales.order
            GROUP BY product_category, product_name
            order by product_category
      ) o1
WHERE o1.Number_of_orders >

(
  SELECT avg(Number_of_orders) as avg_orders
  FROM (
      SELECT product_category,
            product_name,
            count(*) as Number_of_orders
            FROM catalog_sql.sales.order
            GROUP BY product_category, product_name
            order by product_category
      ) o2
  WHERE o1.product_category = o2.product_category
)
  
-- 3. Conditionals

SELECT DISTINCT(payment_method)
FROM
catalog_sql.sales.order;

SELECT *,
        CASE
          WHEN ((payment_method LIKE '%Card%') and (order_status in ('Cancelled','Returned'))) THEN 'CARD'
          WHEN ((payment_method IN ('UPI','PayPal')) and (order_status in ('Cancelled','Returned'))) THEN 'Bank transfer'
          ELSE payment_method
        END AS payment_type
FROM
    catalog_sql.sales.order;

-- 4 . CTEs

SELECT * FROM catalog_sql.sales.order;

-- Delete those orders which are Cancelled or returned

WITH cancelled_orders AS (
  SELECT order_id
  FROM catalog_sql.sales.`order`
  WHERE order_status IN ('Cancelled','Returned')
)

DELETE FROM catalog_sql.sales.`order`
WHERE order_id IN (SELECT * FROM cancelled_orders);

SELECT * FROM catalog_sql.sales.duplicate;

delete from catalog_sql.sales.duplicate
where ID IN 
  (SELECT ID FROM (SELECT ID, 
                             Name, 
                             Age, 
                             Department,
                              row_number() Over(partition by ID order by ID) as rn
                              FROM
                              catalog_sql.sales.duplicate) 
        where rn>1)

-- 5. Window functions

SELECT price_per_unit,
      row_number() OVER (ORDER BY price_per_unit DESC) as row_number,
      rank() over(order by price_per_unit desc ) as rank,
      dense_rank() over(order by price_per_unit desc) as dense_rank
FROM catalog_sql.sales.order;

Select *,
       sum(price_per_unit) over(partition by user_id order by order_date ROWS BETWEEN UNBOUNDED PRECEDING and current row) as running_sum
from catalog_sql.sales.order
order by user_id, order_date;
