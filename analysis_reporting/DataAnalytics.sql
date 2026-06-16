/* ========================= 7 - Change-Over-Time (Trends) ========================= */

-- Check the trend of sales and other aspects
-- First form: int (ok)
SELECT 
	YEAR(order_date) AS order_year,
	MONTH(order_date) AS order_month,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date) ASC

-- Other form: date (ok)
SELECT 
	DATETRUNC(month,order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month,order_date)
ORDER BY DATETRUNC(month,order_date) ASC

-- Other form: string (problem!)
SELECT 
	FORMAT(order_date, 'yyyy-MMM') AS order_date,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM') ASC



/* ========================= 8 - Cumulative Analysis ========================= */

-- Calculate the total sales per month and the running total of sales over time
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_date ASC) AS running_total_sales
FROM (
	SELECT 
		DATETRUNC(month, order_date) AS order_date,
		SUM(sales_amount) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(month,order_date))t

-- Calculate the total sales per month partitioned by year and the running total of sales over time
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date ASC) AS running_total_sales
FROM (
	SELECT 
		DATETRUNC(month, order_date) AS order_date,
		SUM(sales_amount) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(month,order_date))t


-- Calculate the moving average of price 
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date ASC) AS running_total_sales,
	AVG(avg_price) OVER(ORDER BY order_date ASC) AS moving_average
FROM (
	SELECT 
		DATETRUNC(year, order_date) AS order_date,
		SUM(sales_amount) AS total_sales,
		AVG(price) AS avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(year,order_date))t



/* ========================= 9 - Performance Analysis ========================= */

-- Analyze the yearly performance of products by comparing each product's sales to 
-- both its average sales performance and the previous year's sales

WITH yearly_product_sales AS (
	SELECT 
		YEAR(f.order_date) AS year_orders,
		p.product_name,
		SUM(f.sales_amount) AS current_sales
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
	ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
	GROUP BY 
		YEAR(f.order_date),
		p.product_name
)
SELECT 
	year_orders,
	product_name,
	current_sales,
	AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
	CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
		 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
		 ELSE 'Avg'
	END AS avg_change,
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY year_orders ASC) AS py_sales,
	current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY year_orders ASC) AS diff_py,
	CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY year_orders ASC) > 0 THEN 'Increasing'
		 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY year_orders ASC) < 0 THEN 'Decreasing'
		 ELSE 'No Change'
	END AS py_change
FROM yearly_product_sales
ORDER BY 
	product_name,
	year_orders;



/* ========================= 10 - Part-to_Whole Analysis (proportional) ========================= */

-- Which categories contribute the most to overall sales?
WITH category_sales AS (
	SELECT
		p.category,
		SUM(f.sales_amount) AS total_cat_sales
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
	ON f.product_key = p.product_key
	GROUP BY p.category
)
SELECT 
	category,
	total_cat_sales,
	SUM(total_cat_sales) OVER () AS total_sales,
	CAST(ROUND((CAST(total_cat_sales AS FLOAT) / SUM(total_cat_sales) OVER ())*100, 2) AS NVARCHAR) + '%' AS percetage
FROM category_sales
ORDER BY total_cat_sales DESC;


/* ========================= 11 - Data Segmentation ========================= */

-- Segment products into cost ranges and count how many products fall into each segment
WITH products_segments AS (
SELECT
	product_key,
	product_name,
	cost,
	CASE WHEN cost < 100 THEN 'Below 100'
		 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		 ELSE 'Above 1000'
	END AS cost_range
FROM gold.dim_products
)
SELECT 
	cost_range,
	COUNT(product_key) AS total_products
FROM products_segments
GROUP BY cost_range
ORDER BY total_products DESC;

/* Group customers into three segments based on their spending behavior:

	* VIP: at least 12 months of history and spending more than 5000

	* Regular: at least 12 months of history and but spending 5000 or less

	* New: lifespan less than 12 months

-- Last, find the total number of customers by each group

*/
WITH customer_spending AS (
	SELECT
		c.customer_key,
		SUM(f.sales_amount) AS total_spending,
		MIN(f.order_date) AS first_order,
		MAX(f.order_date) AS last_order,
		DATEDIFF(month, MIN(f.order_date), MAX(f.order_date)) AS lifespan
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_customers AS c
	ON f.customer_key = c.customer_key
	GROUP BY c.customer_key
)
SELECT 
	customer_segment,
	COUNT(customer_key) AS total_customers
FROM (
	SELECT 
		customer_key,
		CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
			 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
			 ELSE 'New'
		END AS customer_segment
	FROM customer_spending)t
GROUP BY customer_segment
ORDER BY total_customers DESC;

