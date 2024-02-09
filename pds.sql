CREATE MATERIALIZED VIEW IF NOT EXISTS pds_hs_availing
  AS
SELECT COUNT(DISTINCT bd."rationCardNumber") AS distinct_rationcard_count
FROM external_beneficiary_detail bd
WHERE bd."rationCardNumber" IN (
  SELECT n."rationcard_number"
  FROM undefinednfsamemberdatashare n
  UNION -- Removes duplicates between the two scheme tables
  SELECT s."rationcard_number"
  FROM undefinedsfssmemberdatashare s);

CREATE MATERIALIZED VIEW IF NOT EXISTS pds_district_progress
  AS
select "districtName",
"Number of Eligible Households",
"No. of Households who have availed scheme(s)" * 1000,
ROUND(CAST("Saturation %"AS decimal),1) as "Saturation %",
  ROW_NUMBER () OVER(ORDER BY "Saturation %" DESC) AS "Rank"
from
(SELECT
  bd."districtName",
  COUNT(DISTINCT bd."rationCardNumber") AS "Number of Eligible Households",
  COUNT(DISTINCT nd."rationcard_number") AS "No. of Households who have availed scheme(s)",
  FORMAT(
    (COUNT(DISTINCT CASE WHEN nd."rationcard_number" IS NOT NULL THEN nd."rationcard_number" END) * 100.00) / 
    NULLIF(COUNT(DISTINCT bd."rationCardNumber"), 0), 2
  ) AS "Saturation %"
FROM
  external_beneficiary_detail bd
LEFT JOIN
  undefinednfsamemberdatashare nd ON bd."rationCardNumber" = nd."rationcard_number"
GROUP BY
  bd."districtName") as X
  order by "Rank" ASC;
