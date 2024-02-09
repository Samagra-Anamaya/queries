CREATE MATERIALIZED VIEW pds_hs_availing
  AS
SELECT COUNT(DISTINCT bd."rationCardNumber") AS distinct_rationcard_count
FROM external_beneficiary_detail bd
WHERE bd."rationCardNumber" IN (
  SELECT n."rationcard_number"
  FROM undefinednfsamemberdatashare n
  UNION -- Removes duplicates between the two scheme tables
  SELECT s."rationcard_number"
  FROM undefinedsfssmemberdatashare s
);
