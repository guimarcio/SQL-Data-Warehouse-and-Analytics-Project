/* ========================= 12 - Reporting ========================= */

/*
==============================================================================
Product Report
==============================================================================
Purpose: 
	- This report consolidates key product metrics and behaviors

Highlights:
	1. Gathers essentials fields such as product name, category, subcategory and cost.
	2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
	3. Aggregates product-level metrics:
		- total orders
		- total sales
		- total quantity sold
		- total unique customers 
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last sale)
		- average order revenue (AOR)
		- average monthly revenue
==============================================================================
*/

CREATE VIEW gold.report_products AS
-- Retrieving basic information
WITH base_query AS (
SELECT
	f.order_number,
	f.order_date,
	f.customer_key,
	f.sales_amount,
	f.quantity,
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
WHERE order_date IS NOT NULL)

-- Aggregations
, product_aggregations AS(
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	COUNT(DISTINCT customer_key) AS total_customers,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
	SUM(quantity) AS total_quantity,
	MAX(order_date) AS last_sale_date
FROM base_query
GROUP BY
	product_key,
	product_name,
	category,
	subcategory,
	cost)

-- Final query
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	total_orders,
	total_sales,
	CASE WHEN total_sales > 50000 THEN 'High-Performer'
		 WHEN total_sales BETWEEN 10000 AND 50000 THEN 'Mid-Performer'
		 ELSE 'Low-Performer'
	END AS product_segment,
	total_quantity,
	DATEDIFF(month, last_sale_date, GETDATE()) AS recency,
	CASE WHEN total_orders = 0 THEN 0
		 ELSE ROUND(CAST(total_sales AS FLOAT) / total_orders, 2)
	END AS avg_order_revenue,
	CASE WHEN lifespan = 0 THEN total_sales
		 ELSE ROUND(CAST(total_sales AS FLOAT) / lifespan, 2)
	END AS avg_monthly_revenue,
	total_customers,
	lifespan
FROM product_aggregations


SELECT * FROM gold.report_products
SELECT * FROM gold.report_customers