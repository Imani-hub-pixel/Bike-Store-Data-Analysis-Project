SELECT *
FROM customers;

SELECT *
FROM order_items;

SELECT *
FROM orders;

SELECT *
FROM products;

SELECT *
FROM staffs;

SELECT *
FROM stocks;

SELECT *
FROM stores;
-- Creating a copy of the raw data
-- Handle duplicate data
-- Standardization(Trim fields)
-- Verify data types
-- Looking for inconsistent categories
-- Handle null values
-- Remove unecessary rows and columns
-- Create derived columns
-- EDA

-- 1.Creating a copy of the raw data to work in

CREATE TABLE customers_clean AS
SELECT *
FROM customers;

CREATE TABLE orders_clean AS
SELECT *
FROM orders;

CREATE TABLE order_items_clean AS
SELECT *
FROM order_items;

CREATE TABLE products_clean AS
SELECT *
FROM products;

CREATE TABLE categories_clean AS
SELECT *
FROM categories;

CREATE TABLE staffs_clean AS
SELECT *
FROM staffs;

CREATE TABLE stocks_clean AS
SELECT *
FROM stocks;

CREATE TABLE stores_clean AS
SELECT *
FROM stores;

CREATE TABLE brands_clean AS
SELECT *
FROM brands;

-- Identifyig and Handling duplicates
WITH top_row_num AS
(
	SELECT customer_id,
	ROW_NUMBER()OVER(PARTITION BY customer_id) AS row_num
	FROM customers_clean
	ORDER BY row_num
)
SELECT *
FROM top_row_num
WHERE row_num >1;

SELECT brand_id,COUNT(*) AS num
FROM brands_clean
GROUP BY brand_id
HAVING num > 1;

SELECT category_id,COUNT(*) AS num_cat
FROM categories_clean
GROUP BY category_id
HAVING num_cat>1;

WITH  order_row AS
(
	SELECT order_id,item_id,product_id,
	ROW_NUMBER()OVER(PARTITION BY order_id,item_id ORDER BY product_id) AS row_num_order
	FROM order_items_clean
)
SELECT *
FROM order_row
WHERE row_num_order > 1;

SELECT order_id,COUNT(*) AS order_count
FROM orders_clean
GROUP BY order_id
HAVING order_count >1;


SELECT product_id,COUNT(*) AS product_count
FROM products_clean
GROUP BY product_id
HAVING product_count >1;


SELECT staff_id,COUNT(*) AS staff_count
FROM staffs_clean
GROUP BY staff_id
HAVING staff_count >1
;

SELECT store_id, product_id, COUNT(*)
FROM stocks_clean
GROUP BY store_id, product_id
HAVING COUNT(*) > 1;

SELECT store_id,COUNT(*)
FROM stores_clean
GROUP BY store_id
HAVING COUNT(*) >1;

-- No duplicates were found.

-- Standardizatiom
SELECT customer_id,phone
FROM customers_clean;

