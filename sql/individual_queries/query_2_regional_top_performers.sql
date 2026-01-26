-- ============================================================
-- QUERY 2: Regional Top Performers
-- ============================================================
-- Purpose: Find the seller with the highest priced sale in each region
-- Business Value: Recognizes top sales performers by region
-- ============================================================

-- Step 1: Identify the highest price per region
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

-- Step 2: Get seller details for each region's top sale
SELECT 
  s.first_name,                    -- Seller's first name
  s.last_name,                     -- Seller's last name
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
