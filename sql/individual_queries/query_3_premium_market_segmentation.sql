-- ============================================================
-- QUERY 3: Premium Market Segmentation
-- ============================================================
-- Purpose: Identify sellers in East/West US regions who sold 
--          premium German or French cars (2015–2016)
-- Business Value: Segments premium market opportunities
-- ============================================================

-- Identify sellers whose sale prices exceeded the regional average
SELECT 
  s.first_name,                   -- Seller's first name
  s.last_name,                    -- Seller's last name
  s.car,                          -- Car ID or model
  c.category,                     -- Car category (German or French)
  r.region,                       -- Region of sale
  s.selling_date,                 -- Date of sale
  s.price,                        -- Sale price
  CASE 
    -- Label cars as 'premium' if price is 120000 or more
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
