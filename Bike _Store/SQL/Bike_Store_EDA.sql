SELECT *
FROM brands_clean;

SELECT *
FROM categories_clean;

SELECT *
FROM customers_clean;

SELECT *
FROM order_items_clean;

SELECT *
FROM orders_clean;

SELECT *
FROM products_clean;

SELECT *
FROM staffs_clean;

SELECT *
FROM stocks_clean;

SELECT *
FROM stores_clean;
-- Who are the top customers by spending?
CREATE VIEW customer_order AS
SELECT 
    cc.customer_id,
    cc.first_name,
    cc.last_name,
    cc.email,
    cc.city,
    cc.state,
    oc.order_id,
    oic.item_id,
    oic.product_id,
    oic.quantity,
    oic.discount,
    pc.product_name,
    pc.brand_id,
    pc.category_id,
    pc.list_price,
    pc.model_year,
    bc.brand_name,
    cac.category_name,
    oic.quantity * pc.list_price * (1 - oic.discount) AS revenue
FROM customers_clean AS cc
JOIN orders_clean AS oc
    ON cc.customer_id = oc.customer_id
JOIN order_items_clean AS oic
    ON oc.order_id = oic.order_id
JOIN products_clean AS pc
    ON oic.product_id = pc.product_id
JOIN brands_clean AS bc
	ON pc.brand_id=bc.brand_id
JOIN categories_clean AS cac
	ON pc.category_id=cac.category_id
    ;

-- How many orders were placed?
SELECT COUNT(order_id)
FROM customer_order;

-- 4722 orders were placed.

-- Which customers generate the most revenue?
SELECT
    customer_id,
    first_name,
    last_name,
    SUM(revenue) AS total_revenue
FROM customer_order
GROUP BY customer_id, first_name, last_name
ORDER BY total_revenue DESC;

-- Sharlyn Hopkins is the top customer, generating total revenue of $34,807.92.
-- This indicates that she is a high value customer,and makes a big contribution to the company's sales.


-- Which cities generate the most revenue?
SELECT
	city,
    state,
    SUM(revenue) AS total_revenue
FROM customer_order
GROUP BY city,state
ORDER BY total_revenue DESC;

-- Customers from Mount Vernon generated the highest revenue at $ 105563.3335.,indicating that the city is one of the biggest maret for the business.
-- This suggests that the company should prioritize marketing campaigns and enough inventory in this region.

-- Which products generate the most revenue?
SELECT 
	product_id,
    product_name,
    SUM(revenue) AS total_revenue
FROM customer_order
GROUP BY product_id,product_name
ORDER BY total_revenue DESC;

-- Trek Slash 8 27.5-2016 is the top revenue-generating product, generating a revenue of 555558.61
-- Its strong revenue contribution indicates that the product is an important contributor to overall sales.
-- The business should consider maintaining sufficient inventory to meet demand for this product.

-- Which brand generates the most revenue?

SELECT 
	brand_id,
	brand_name,
	SUM(revenue) AS total_revenue
FROM customer_order
GROUP BY brand_id,brand_name
ORDER BY total_revenue DESC;

-- Trek is the top-revenue generating brand ,generating total revenue of $ 4602754.
-- This suggests that Trek  is  major contributor to the the store's sales.
-- The business should continue monitoring demand for Trek products and ensure that high-performing Trek products remain adequately stocked.

-- Which category generated the most revenue?

SELECT 
	category_id,
    category_name,
    SUM(revenue) AS total_revenue
FROM customer_order
GROUP BY category_id,category_name
ORDER BY total_revenue;

-- Children Bicycles generated the highest revenue among all product categories, indicating that this category is a significant contributor to the store's overall sales performance.
-- he business should continue monitoring demand for Children Bicycles and ensure sufficient inventory availability to meet customer demand.

SELECT *
FROM customer_order;

-- Which product sell the most unit?

SELECT 
	product_id,
    product_name,
    COUNT(*) AS units_sold
FROM customer_order
GROUP BY product_id,product_name
ORDER BY units_sold DESC;

-- Surly Ice Cream Truck Frameset -2016 is the top_seller,selling a total of 110 units.
-- This indicates that Surly Ice Cream Truck Frameset -2016 has a strong customer demand in the store.
-- This suggests that the store should ensure sufficient inventory to meet the demand of this product.

-- Does a product's price affect the number of units sold?

SELECT
	product_id,
    product_name,
    COUNT(*) AS units_sold,
    list_price
FROM customer_order
GROUP BY product_id,product_name,list_price,discount
ORDER BY units_sold DESC;

-- Sales volume varies across products at different price points
-- While lower-priced products tend to achieve higher sales volumes, some premium-priced products also show strong demand.
-- For example, Surly Ice Cream Truck Frameset - 2016, priced at $469, recorded the highest sales volume of 110 units
-- However, some premium products such as Trek Slash 8 27.5 - 2016 ($3,999) also achieved strong sales
-- that factors beyond price, such as brand reputation and product demand, may also influence purchasing decisions.
-- Extremely high-priced products, such as Trek Domane SLR 9 Disc - 2018 ($11,999.90), recorded significantly lower sales volume,indicating that premium pricing may limit demand for some products.
-- This indicates Product demand appears to be influenced by multiple factors, not price alone.

-- How does revenue change over time?


SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
   SUM(quantity * list_price * (1 - discount)) AS revenue
FROM orders_clean oc
JOIN order_items_clean oic
ON oc.order_id = oic.order_id
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;

-- Revenue shows how sales performance changes over time. The trend helps identify periods of growth, decline, and seasonal fluctuations.
-- Peaks may indicate high-demand periods, while drops may suggest lower customer activity or operational issues. 

-- Which years had the highest sales?
SELECT 
    YEAR(order_date) AS year,
	COUNT(oc.order_id) AS sales_count
FROM orders_clean oc
JOIN order_items_clean oic
ON oc.order_id = oic.order_id
GROUP BY YEAR(order_date)
ORDER BY sales_count DESC ;

-- 2017 has the highest sales volume. 
-- 2018 has the lowest sales volume. 

-- How long does it take to ship orders?

SELECT 
	order_id,
    (DATEDIFF(shipped_date, order_date)) AS shipping_days
FROM orders_clean
ORDER BY shipping_days DESC;

-- What percentage of orders were delayed?

SELECT 
    COUNT(*) AS delayed_orders,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders_clean),
        2
    ) AS delayed_percentage
FROM orders_clean
WHERE shipped_date > required_date;

-- 28.36% of orders were delayed.