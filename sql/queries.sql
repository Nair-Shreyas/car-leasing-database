------------------------------------------------------------------------------------------------------------------------

--------------------
-- QUERY 1 START --
--------------------

-- Purpose: Count how many German, American, and Japanese cars sold above average price in 2016
-- Step 0: Declare Common Table Expressions (CTEs) to organize logic
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

--------------------
-- QUERY 1 END --
--------------------

------------------------------------------------------------------------------------------------------------------------

--------------------
-- QUERY 2 START –
--------------------

-- Purpose: Find the seller with the highest priced sale in each region
-- Step 0: Use a CTE (Common Table Expression) to find the maximum sale price in each region for easier reference
-- Step 1: Identify the highest price per region and category

WITH max_prices AS (
  SELECT 
    s.region_id,                    -- Region where the sale occurred
    MAX(s.price) AS max_price       -- Maximum price sold in that region
  FROM sellers s
  JOIN cars c ON s.car = c.car
  WHERE YEAR(s.selling_date) = 2016
    AND c.category IN ('German', 'American', 'Japanese')
  GROUP BY s.region_id
)

-- Step 2: Get seller details for each region’s top sale

SELECT 
  s.first_name,                    -- Seller’s first name
  s.last_name,                     -- Seller’s last name
  s.car,                           -- Car sold
  c.category,                      -- Car category
  r.region,                        -- Region name
  s.selling_date,                  -- Date of sale
  s.price                          -- Price of sale
FROM sellers s
JOIN cars c ON s.car = c.car
  JOIN regions r ON s.region_id = r.region_id  -- Match seller to their region
JOIN max_prices mp ON s.region_id = mp.region_id AND s.price = mp.max_price
WHERE YEAR(s.selling_date) = 2016
  AND c.category IN ('German', 'American', 'Japanese');

--------------------
-- QUERY 2 END --
--------------------

------------------------------------------------------------------------------------------------------------------------

--------------------
-- QUERY 3 START –
--------------------

-- Purpose: Identify sellers in East/West US regions who sold premium German or French cars (2015–2016)
-- Step 0: Apply filters and conditions for region, category, and price
-- Step 1: Identify sellers whose sale prices exceeded the regional average

SELECT 
  s.first_name,                   -- Seller’s first name
  s.last_name,                    -- Seller’s last name
  s.car,                          -- Car ID or model
  c.category,                     -- Car category (German or French)
  r.region,                       -- Region of sale
  s.selling_date,                 -- Date of sale
  s.price,                        -- Sale price
  CASE 

    -- Step 2: Use CASE to label cars as 'premium' if price is 120000 or more (used similarly in Query 1 and 4 too)

    WHEN s.price >= 120000 THEN 'Yes' 
    ELSE 'No' 
  END AS premium_sedan            -- Label if car is premium
FROM sellers s
JOIN cars c ON s.car = c.car
JOIN regions r ON s.region_id = r.region_id
WHERE c.category IN ('German', 'French')                                   -- Only include German and French cars
  AND r.region IN ('Eastern United States', 'Western United States')      -- Limit to East/West regions
  AND YEAR(s.selling_date) IN (2015, 2016)                                 -- Years filter
  AND s.price > (
      SELECT AVG(s2.price)
      FROM sellers s2
      WHERE s2.region_id = s.region_id
        AND YEAR(s2.selling_date) IN (2015, 2016)
  );

--------------------
-- QUERY 3 END --
--------------------

------------------------------------------------------------------------------------------------------------------------

--------------------
-- QUERY 4 START –
--------------------

-- Purpose: Count how many cars were premium vs regular based on price
-- Step 0: Use a subquery to filter based on region, category, and date
-- This subquery selects only cars that were sold in 2015 or 2016 in East/West regions,
-- of German or French make, and priced above their region's average.
-- Step 1: Begin the main SELECT to count cars based on their price category

SELECT
    SUM(CASE WHEN price >= 120000 THEN 1 ELSE 0 END) AS premium_sedan_count,  -- Count cars priced at or above 120000
    SUM(CASE WHEN price < 120000 THEN 1 ELSE 0 END) AS regular_sedan_count     -- Count cars priced below 120000
FROM (

  -- Step 2: Filter cars using the same logic as in Query 3

    SELECT s.price  -- Only retrieve the price field for further aggregation
  FROM sellers s
  JOIN cars c ON s.car = c.car
  JOIN regions r ON s.region_id = r.region_id
  WHERE c.category IN ('German', 'French')
    AND r.region IN ('Eastern United States', 'Western United States')
    AND YEAR(s.selling_date) IN (2015, 2016)
    AND s.price > (
      SELECT AVG(s2.price)
      FROM sellers s2
      WHERE s2.region_id = s.region_id
        AND YEAR(s2.selling_date) IN (2015, 2016)
    )
) AS filtered_data;

--------------------
-- QUERY 4 END --
--------------------

------------------------------------------------------------------------------------------------------------------------