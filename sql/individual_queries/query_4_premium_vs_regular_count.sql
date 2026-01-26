-- ============================================================
-- QUERY 4: Premium vs Regular Count
-- ============================================================
-- Purpose: Count how many cars were premium vs regular based on price
-- Business Value: Market composition analysis
-- ============================================================

-- Count cars based on their price category
SELECT
    SUM(CASE WHEN price >= 120000 THEN 1 ELSE 0 END) AS premium_sedan_count,  -- Count cars priced at or above 120000
    SUM(CASE WHEN price < 120000 THEN 1 ELSE 0 END) AS regular_sedan_count     -- Count cars priced below 120000
FROM (
  -- Filter cars using the same logic as in Query 3
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
