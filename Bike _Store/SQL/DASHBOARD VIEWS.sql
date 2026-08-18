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

-- Management and Inventory Analysis

CREATE VIEW inventory_analysis AS
SELECT
    stc.store_id,
    sc.store_name,
    stc.product_id,
    pc.product_name,
    cc.category_name,
    bc.brand_name,
    stc.quantity AS stock_quantity
FROM stocks_clean AS stc
JOIN products_clean AS pc
    ON stc.product_id = pc.product_id
JOIN stores_clean AS sc
    ON stc.store_id = sc.store_id
JOIN categories_clean AS cc
    ON pc.category_id = cc.category_id
JOIN brands_clean AS bc
    ON pc.brand_id = bc.brand_id;
    
    
-- Which products have the highest stock at each store?
CREATE VIEW highest_stock_products AS
SELECT
    store_name,
    product_name,
    total_stock
FROM (
    SELECT
        store_name,
        product_name,
        SUM(stock_quantity) AS total_stock,
        RANK() OVER (
            PARTITION BY store_name
            ORDER BY SUM(stock_quantity) DESC
        ) AS stock_rank
    FROM inventory_analysis
    GROUP BY store_name, product_name
) ranked
WHERE stock_rank = 1;

-- Which products are low in stock at each store?

CREATE VIEW lowest_stock_products AS
SELECT
    store_name,
    product_name,
    total_stock
FROM (
    SELECT
        store_name,
        product_name,
        SUM(stock_quantity) AS total_stock,
        RANK() OVER (
            PARTITION BY store_name
            ORDER BY SUM(stock_quantity)
        ) AS stock_rank
    FROM inventory_analysis
    GROUP BY store_name, product_name
) ranked
WHERE stock_rank = 1;

-- Are products adequately stocked,out of stock or potentially understocked?
CREATE VIEW inventory_status AS
SELECT
    stc.store_id,
    sc.store_name,
    stc.product_id,
    pc.product_name,
    stc.quantity AS current_stock,
    COALESCE(SUM(oic.quantity), 0) AS total_units_sold,

    CASE
        WHEN stc.quantity = 0 THEN 'Out of Stock'
        WHEN stc.quantity < COALESCE(SUM(oic.quantity), 0)
            THEN 'Potentially Understocked'
        ELSE 'Adequately Stocked'
    END AS stock_status

FROM stocks_clean AS stc

JOIN stores_clean AS sc
    ON stc.store_id = sc.store_id

JOIN products_clean AS pc
    ON stc.product_id = pc.product_id

LEFT JOIN orders_clean AS oc
    ON stc.store_id = oc.store_id

LEFT JOIN order_items_clean AS oic
    ON oc.order_id = oic.order_id
    AND stc.product_id = oic.product_id

GROUP BY
    stc.store_id,
    sc.store_name,
    stc.product_id,
    pc.product_name,
    stc.quantity;
    
    -- Customer Analysis
    

    CREATE VIEW customer_analysis AS
    SELECT 
		cc.customer_id,
        cc.first_name,
        cc.last_name,
        oc.order_id,
        oic.quantity,
        oic.list_price,
        oic.discount,
        (oic.list_price*oic.quantity)*(1-oic.discount) AS revenue
	FROM customers_clean AS cc
    JOIN orders_clean AS oc
		ON cc.customer_id=oc.customer_id
	JOIN order_items_clean AS oic
		ON oc.order_id=oic.order_id;
        
	  -- Who are the 10 top customers by spending?
      CREATE VIEW  top_10_customers AS
      SELECT 
		customer_id,
		first_name,
        last_name,
        SUM(revenue) AS total_revenue
	FROM customer_analysis
    GROUP BY customer_id,first_name,last_name
    ORDER BY total_revenue DESC;
    
    -- How many orders does each customer place?
    
CREATE VIEW customer_purchase_behavior AS
SELECT
    cc.customer_id,
    CONCAT(cc.first_name, ' ', cc.last_name) AS customer_name,
    COUNT(DISTINCT oc.order_id) AS total_orders,
    SUM(oic.quantity) AS total_units_purchased,
    SUM((oic.quantity * oic.list_price)*(1 - oic.discount)) AS total_spent
FROM customers_clean AS cc
JOIN orders_clean AS oc
    ON cc.customer_id = oc.customer_id
JOIN order_items_clean AS oic
    ON oc.order_id = oic.order_id
GROUP BY
    cc.customer_id,
    cc.first_name,
    cc.last_name;
    
    -- Average order value per customer
CREATE VIEW customer_order_value AS
SELECT
    cc.customer_id,
    CONCAT(cc.first_name, ' ', cc.last_name) AS customer_name,
    COUNT(DISTINCT oc.order_id) AS total_orders,
    SUM((oic.quantity * oic.list_price)*(1 - oic.discount))AS total_spent,
    ROUND(
        SUM((oic.quantity * oic.list_price)*(1 - oic.discount)) /
        COUNT(DISTINCT oc.order_id),
        2
    ) AS average_order_value
FROM customers_clean AS cc
JOIN orders_clean AS oc
    ON cc.customer_id = oc.customer_id
JOIN order_items_clean AS oic
    ON oc.order_id = oic.order_id
GROUP BY
    cc.customer_id,
    cc.first_name,
    cc.last_name;
    
-- What products do customers prefer?
CREATE VIEW customer_product_preferences AS
SELECT
    pc.product_id,
    pc.product_name,
    SUM(oic.quantity) AS units_purchased,
    COUNT(DISTINCT oc.customer_id) AS unique_customers
FROM order_items_clean AS oic
JOIN orders_clean AS oc
    ON oic.order_id = oc.order_id
JOIN products_clean AS pc
    ON oic.product_id = pc.product_id
GROUP BY
    pc.product_id,
    pc.product_name
ORDER BY units_purchased DESC;

-- Customer purchasing behavior by location
CREATE VIEW customer_location_behavior AS
SELECT
    cc.city,
    cc.state,
    COUNT(DISTINCT cc.customer_id) AS total_customers,
    COUNT(DISTINCT oc.order_id) AS total_orders,
    SUM(oic.quantity) AS total_units_purchased,
    SUM((oic.quantity * oic.list_price)*(1 - oic.discount)) AS total_revenue
FROM customers_clean AS cc
JOIN orders_clean AS oc
    ON cc.customer_id = oc.customer_id
JOIN order_items_clean AS oic
    ON oc.order_id = oic.order_id
GROUP BY
    cc.city,
    cc.state;

-- Store Performance

-- WHat is the revenue generated by each store?
CREATE VIEW store_revenue_analysis AS 
SELECT 
	sc.store_name,
    SUM((oic.quantity*oic.list_price)*(1 - oic.discount)) AS total_revenue
FROM stores_clean AS sc
JOIN orders_clean AS oc
	ON sc.store_id=oc.store_id
JOIN order_items_clean AS oic
	ON oc.order_id=oic.order_id
GROUP BY store_name
;
-- How many orders did each store have?
CREATE VIEW store_orders AS
SELECT
    sc.store_id,
    sc.store_name,
    COUNT(DISTINCT oc.order_id) AS total_orders
FROM stores_clean AS sc
JOIN orders_clean AS oc
    ON sc.store_id = oc.store_id
GROUP BY
    sc.store_id,
    sc.store_name
ORDER BY total_orders DESC;

-- Units sold by store
CREATE VIEW store_units_sold AS
SELECT
    sc.store_id,
    sc.store_name,
    SUM(oic.quantity) AS total_units_sold
FROM stores_clean AS sc
JOIN orders_clean AS oc
    ON sc.store_id = oc.store_id
JOIN order_items_clean AS oic
    ON oc.order_id = oic.order_id
GROUP BY
    sc.store_id,
    sc.store_name
ORDER BY total_units_sold DESC;

-- AOV by store
CREATE VIEW store_average_order_value AS
SELECT
    sc.store_id,
    sc.store_name,
    COUNT(DISTINCT oc.order_id) AS total_orders,
    SUM((oic.quantity * oic.list_price)*(1-oic.discount)) AS total_revenue,
    ROUND(
        SUM((oic.quantity * oic.list_price)*(1-oic.discount)) /
        COUNT(DISTINCT oc.order_id),
        2
    ) AS average_order_value
FROM stores_clean AS sc
JOIN orders_clean AS oc
    ON sc.store_id = oc.store_id
JOIN order_items_clean AS oic
    ON oc.order_id = oic.order_id
GROUP BY
    sc.store_id,
    sc.store_name
ORDER BY average_order_value DESC;

-- -- Store inventory
CREATE VIEW store_inventory AS
SELECT
    store_id,
    store_name,
    SUM(stock_quantity) AS total_inventory
FROM inventory_analysis
GROUP BY
    store_id,
    store_name
ORDER BY total_inventory DESC;

-- Store-level stock issues 
-- CREATE VIEW store_stock_issues AS
SELECT
    store_id,
    store_name,
    stock_status,
    COUNT(*) AS product_count
FROM inventory_status
WHERE stock_status IN ('Out of Stock', 'Potentially Understocked')
GROUP BY
    store_id,
    store_name,
    stock_status
ORDER BY
    store_name,
    stock_status;





