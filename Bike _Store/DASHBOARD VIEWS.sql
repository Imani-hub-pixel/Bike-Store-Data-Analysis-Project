-- Views to be used in power bi to create a dashboard.alter
-- Problem:The bike store wants to understand its sales performance, customer purchasing behavior, product demand, 
-- and store performance so that management can make better decisions about inventory, sales strategy, and resource allocation.

-- Sales performance 

CREATE VIEW sales_performance AS
SELECT 
cc.customer_id,
cc.city,
cc.state,
oc.order_id,
oc.order_date,
oc.store_id,
oic.quantity,
oic.list_price,
oic.discount,
pc.product_name,
cac.category_name,
sc.store_name,
bc.brand_name,
(oic.list_price *oic.quantity)*(1-oic.discount) AS revenue
FROM customers_clean AS cc
JOIN orders_clean AS oc
	ON cc.customer_id=oc.customer_id
JOIN order_items_clean AS oic
	ON oc.order_id=oic.order_id
JOIN products_clean AS pc
	ON oic.product_id=pc.product_id
JOIN categories_clean AS cac
	ON pc.category_id=cac.category_id
JOIN stores_clean AS sc
	ON  oc.store_id=sc.store_id
JOIN brands_clean AS bc
	ON pc.brand_id=bc.brand_id;
    
SELECT *
FROM sales_performance;

-- How much revenue are we generating.
CREATE VIEW Total_revenue AS
SELECT 
	SUM(revenue) AS Total_revenue
FROM sales_performance;

-- Total Revenue generated is 7689116.5576

-- What is the total monthly revenue?
CREATE VIEW Monthly_revenue AS
SELECT  
	YEAR(order_date),
	MONTH(order_date),
    SUM(revenue) AS Total_revenue
FROM sales_performance
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY Total_revenue DESC;

-- April,2018 generated the highest revenue.

--  How is revenue changing over time?
CREATE VIEW Revenue_over_time AS 
SELECT 
	YEAR(order_date),
    MONTH(order_date),
    SUM(revenue) AS total_revenue
FROM sales_performance
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY YEAR(order_date);

-- -- How many orders are being placed?

CREATE VIEW Total_orders AS
SELECT 
	COUNT( DISTINCT order_id) AS total_orders
FROM sales_performance;

-- What is the average order value?
-- Average order value (AOV) tracks the average money spent per transaction, calculated by dividing total revenue by the total number of orders

CREATE VIEW AOV AS
SELECT 
	SUM(revenue)/COUNT(DISTINCT order_id) AS AOV
FROM sales_performance;

-- Which stores have the highest average order value
CREATE VIEW  AOV_store AS
SELECT 
	store_name,
    SUM(revenue)/COUNT(DISTINCT order_id) AS AOV
    FROM sales_performance
    GROUP BY store_name
    ORDER BY AOV DESC;
    
-- Which store generated the highest revenue?
CREATE VIEW store_revenue AS 
SELECT
	store_name,
    SUM(revenue) AS total_revenue
FROM sales_performance
GROUP BY store_name
ORDER BY total_revenue DESC;

-- Which brand generated the highest revenue?
CREATE VIEW brand_revenue AS
SELECT
	brand_name,
    SUM(revenue) AS total_revenue
FROM sales_performance
GROUP BY brand_name
ORDER BY total_revenue DESC;

-- Which category generates the most revenue?
CREATE VIEW category_revenue AS
SELECT
	category_name,
    SUM(revenue) AS total_revenue
FROM sales_performance
GROUP BY category_name
ORDER BY total_revenue DESC;

--Inventory Analysis

-- CREATE VIEW customer_purchase AS
SELECT 
cc.customer_id,
cc.first_name,
cc.last_name,
cc.city,
cc.state,
oc.order_id,
oc.order_date,
oc.store_id,
oic.quantity,
oic.list_price,
oic.discount,
pc.product_name,
cac.category_name,
sc.store_name,
bc.brand_name,
(oic.list_price *oic.quantity)*(1-oic.discount) AS revenue
FROM customers_clean AS cc
JOIN orders_clean AS oc
	ON cc.customer_id=oc.customer_id
JOIN order_items_clean AS oic
	ON oc.order_id=oic.order_id
JOIN products_clean AS pc
	ON oic.product_id=pc.product_id
JOIN categories_clean AS cac
	ON pc.category_id=cac.category_id
JOIN stores_clean AS sc
	ON  oc.store_id=sc.store_id
JOIN brands_clean AS bc
	ON pc.brand_id=bc.brand_id;







