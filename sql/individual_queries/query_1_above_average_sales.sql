-- ============================================================
-- QUERY 1: Above-Average Sales Analysis
-- ============================================================
-- Purpose: Count how many German, American, and Japanese cars 
--          sold above average price in 2016
-- Business Value: Identifies high-performing vehicle categories
-- ============================================================

-- Step 1: Calculate the average price for each car category sold in 2016
WITH avg_prices AS (
  SELECT 
    c.category,                      -- Car category (e.g., German, American, Japanese)
    AVG(s.price) AS avg_price       -- Average selling price per category
  FROM sellers s
    JOIN cars c ON s.car = c.car  -- Link each sale to its car using car ID
  WHERE YEAR(s.selling_date) = 2016 -- Filter sales from year 2016
  GROUP BY c.category               -- Group by category for average price
),

-- Step 2: Identify sales above the category average
filtered_sales AS (
  SELECT 
    c.category                      -- Extract only the category for final count
  FROM sellers s
  JOIN cars c ON s.car = c.car
  JOIN avg_prices a ON c.category = a.category
  WHERE YEAR(s.selling_date) = 2016
    AND s.price > a.avg_price       -- Keep only cars sold above average price
)

-- Step 3: Count how many cars were sold above average in each category
SELECT
  SUM(CASE WHEN category = 'German' THEN 1 ELSE 0 END) AS German,
  SUM(CASE WHEN category = 'American' THEN 1 ELSE 0 END) AS American,
  SUM(CASE WHEN category = 'Japanese' THEN 1 ELSE 0 END) AS Japanese
FROM filtered_sales;
