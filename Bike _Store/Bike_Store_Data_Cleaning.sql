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
UPDATE customers_clean
SET
	first_name=TRIM(first_name),
    last_name=TRIM(last_name),
    street=TRIM(street),
    city=TRIM(city),
    state=TRIM(state),
    zip_code=TRIM(zip_code)
;

UPDATE customers_clean
SET email = LOWER(email);

UPDATE customers_clean
SET phone=REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(phone,'_',''),'(',''),')',''),'-',''),' ','');

SELECT *
FROM customers_clean;

SELECT *
FROM products_clean;

SELECT product_name
FROM products
WHERE product_name LIKE '%  %';

SELECT *
FROM staffs_clean;

UPDATE staffs_clean
SET
	first_name=TRIM(first_name),
    last_name=TRIM(last_name),
    email=TRIM(email)
    ;

UPDATE staffs_clean
SET phone=REPLACE(REPLACE(REPLACE(REPLACE(phone,'(',''),')',''),'-',''),' ','');
    
    -- Verify data types
SELECT *
FROM orders_clean;

DESCRIBE orders_clean;

ALTER TABLE orders_clean
MODIFY order_date DATE,
MODIFY required_date DATE,
MODIFY shipped_date DATE;


-- Looking for inconsistent categories
SELECT DISTINCT state
FROM customers_clean
ORDER BY state;

SELECT DISTINCT product_name,COUNT(*)
FROM products_clean
GROUP BY product_name
ORDER BY COUNT(*) DESC;

-- No inconsistnet categories were found

-- Handle null values

SELECT *
FROM customers_clean;

SELECT
	SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(first_name IS NULL) AS first_name_nulls,
    SUM(last_name IS NULL) AS last_name_nulls,
    SUM(phone IS NULL OR phone = '') AS phone_nulls,
    SUM(email IS NULL) AS email_nulls,
    SUM(street IS NULL) AS street_nulls,
    SUM(city IS NULL) AS city_nulls,
    SUM(state IS NULL) AS state_nulls,
    SUM(zip_code IS NULL) AS zip_code_nulls
FROM customers_clean;

UPDATE customers_clean
SET phone='Unknown'
WHERE phone IS NULL;

-- 1297 null values on phone column.Left as unknown since phone numbers are optional.

SELECT 
	SUM(order_id IS NULL ) AS order_id_nulls,
    SUM(item_id IS NULL) AS item_id_nulls,
    SUM(product_id IS NULL) AS product_id_nulls,
    SUM(quantity IS NULL)AS quantity_nulls,
    SUM(list_price IS NULL) AS list_price_nulls,
    SUM(discount IS NULL) AS discount_nulls
FROM order_items_clean
;

SELECT*
FROM orders_clean;

SELECT
	SUM(order_id IS NULL) AS order_id_nulls,
	SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(order_status IS NULL) AS order_status_nulls,
    SUM(order_date IS NULL) AS order_date_nulls,
    SUM(required_date IS NULL) AS required_date_nulls,
    SUM(shipped_date IS NULL) AS shipped_date_nulls,
    SUM(store_id IS NULL) AS store_id_nulls,
    SUM(staff_id IS NULL) AS staff_id_nulls
FROM orders_clean;

-- Shipped date has 170 null values meaning 170 orders have not yet been shipped.

SELECT *
FROM products_clean;
    
SELECT 
	SUM(product_id IS NULL) AS product_id_nulls,
	SUM(product_name IS NULL) AS product_name_nulls,
	SUM(brand_id IS NULL) AS brand_id_nulls,
 	SUM(category_id IS NULL) AS category_id_nulls,
    SUM(model_year IS NULL) AS model_year_nulls,
    SUM(list_price IS NULL) AS list_price_nulls
FROM products_clean;

-- No null values were found in the products tables 
SELECT 
	SUM(staff_id IS NULL) AS staff_id_nulls,
    SUM(first_name IS NULL) AS first_name_nulls,
    SUM(last_name IS NULL) AS last_name_nulls,
    SUM(phone IS NULL OR phone = '') AS phone_nulls,
    SUM(email IS NULL) AS email_nulls,
    SUM(active IS NULL) AS active_nulls,
    SUM(store_id IS NULL) AS store_id_nulls,
    SUM(manager_id IS NULL) AS manager_id_nulls
FROM staffs_clean;

-- One NULL manager_id was retained because the correct manager
-- could not be determined from the available data.
    
SELECT 
	SUM(store_id IS NULL) AS store_id_nulls,
    SUM(product_id IS NULL) AS product_id_nulls,
    SUM(quantity IS NULL) AS quantity_nulls
FROM stocks_clean;

-- No null values in the stocks table.


-- Removing unecessary rows and columns

-- Removed phone column because it was not relevant to the sales analysis
-- and contained a high proportion of NULL values.

ALTER TABLE customers_clean
DROP COLUMN phone;

-- Removed  street, and zip_code columns because they were
-- not required for the planned sales analysis.    

ALTER TABLE customers_clean
DROP COLUMN street;

ALTER TABLE customers_clean
DROP COLUMN zip_code;

SELECT *
FROM staffs_clean;






