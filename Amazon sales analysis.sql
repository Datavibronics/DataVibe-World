SELECT*
FROM `amazon sales dataset`;

-- Business Question:
-- Which product category contribute the most to total revenue, and what percentage do they represent?

SELECT 
    product_category,
    SUM(total_revenue) AS revenue,
    ROUND(SUM(total_revenue) / (SELECT SUM(total_revenue) FROM `amazon sales dataset`) * 100, 2) AS revenue_pct
FROM `amazon sales dataset`
GROUP BY product_category
ORDER BY revenue DESC;

-- Business Question:
-- How is revenue accumulating over time, and what is the overall growth trajectory?

SELECT 
    order_date,
    SUM(total_revenue) AS daily_revenue,
    SUM(SUM(total_revenue)) OVER (ORDER BY order_date) AS cumulative_revenue
FROM `amazon sales dataset`
GROUP BY order_date
ORDER BY order_date;

-- Business Question:
-- Are there any unusually high transactions that deviate significantly from normal sales patterns?

SELECT *
FROM `amazon sales dataset`
WHERE total_revenue > (
    SELECT AVG(total_revenue) + 2 * STDDEV(total_revenue)
    FROM `amazon sales dataset`
);

-- Business Question:
-- How does customer rating relate to transaction volume and revenue?

SELECT 
    ROUND(rating) AS rating_group,
    COUNT(*) AS transactions,
    SUM(total_revenue) AS revenue
FROM `amazon sales dataset`
GROUP BY rating_group
ORDER BY rating_group;

-- Business Question:
-- Which payment methods are most commonly used and generate the highest revenue?

SELECT 
    payment_method,
    COUNT(*) AS usage_count,
    SUM(total_revenue) AS revenue
FROM `amazon sales dataset`
GROUP BY payment_method
ORDER BY revenue DESC;

-- Business Question:
-- Which product category performs best in each city, and where are the top opportunities?

SELECT 
    customer_region,
    product_category,
    SUM(total_revenue) AS revenue,
    RANK() OVER (PARTITION BY customer_region ORDER BY SUM(total_revenue) DESC) AS rank_in_city
FROM `amazon sales dataset`;

