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
    oic.quantity * pc.list_price * (1 - oic.discount) AS revenue
FROM customers_clean AS cc
JOIN orders_clean AS oc
    ON cc.customer_id = oc.customer_id
JOIN order_items_clean AS oic
    ON oc.order_id = oic.order_id
JOIN products_clean AS pc
    ON oic.product_id = pc.product_id;
    
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

-- Which brand generates the most revenue.