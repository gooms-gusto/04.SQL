SELECT * FROM BAS_CUSTOMER bc WHERE bc.udf02 IN('3000000733','3000000735','3000016576','3000005193');


SELECT bth.tariffMasterId FROM BIL_TARIFF_HEADER bth ORDER BY bth.tariffMasterId DESC;


DELETE FROM BIL_SUMMARY WHERE organizationId='OJV_CML' 
AND warehouseId='CBT03' AND customerId='MAP' 
and chargecategory='IB' and billingFromDate BETWEEN '2024-09-26' and '2024-10-23' and docno='000008'

USE wms_cml;

SELECT buwas.udf01 AS WAREHOUSE_ID_OR_DEPARTMENT,bw.warehouseDescr AS WAREHOUSE_NAME_OR_DEPARTMENTNAME,COUNT(buwas.userId) AS TOTAL_USER
  FROM wms_cml.BSM_USER buwas LEFT OUTER  JOIN  
      wms_cml.BSM_WAREHOUSE bw ON
   bw.organizationId = buwas.organizationId AND buwas.udf01 = bw.warehouseId
  WHERE bw.activeFlag='Y' 
 -- AND buwas.udf01 <> '' AND buwas.udf01<> '1' AND buwas.udf01<> 'H'
  GROUP BY buwas.udf01,bw.warehouseDescr 
   union ALL
  SELECT CASE bur.udf01 WHEN 'EXCLUDE' THEN 'HONEYWELL' ELSE bur.udf01 END AS WAREHOUSE_ID_OR_DEPARTMENT,
  CASE bur.udf01 WHEN 'EXCLUDE' THEN 'HONEYWELL'
   WHEN 'EXCLUDE' THEN 'HONEYWELL ACCOUT'
  WHEN 'BILLING' THEN 'DEPT BILLING'
  WHEN 'BOD' THEN 'DEPT  BOD'
  WHEN 'IT' THEN 'DEPT IT'
  WHEN 'ODC' THEN 'DEPT ODC'
  WHEN 'SALESHO' THEN 'DEPT SALES HO' END AS WAREHOUSE_NAME_OR_DEPARTMENTNAME,COUNT(bur.userId) AS TOTAL_USER
  FROM  BSM_USER bur WHERE bur.activeFlag='Y' AND bur.udf01 NOT IN (SELECT bw.warehouseId FROM BSM_WAREHOUSE bw)
  GROUP BY bur.udf01
 union all
  SELECT "*IDDLE USER*" AS WAREHOUSE_ID_OR_DEPARTMENT, "*IDDLE USER*" AS WAREHOUSE_NAME_OR_DEPARTMENTNAME,(243 - COUNT(bu.userId)) AS TOTAL_USER
  FROM  BSM_USER bu WHERE bu.activeFlag='Y';


SELECT * FROM BSM_USER WHERE activeFlag='Y';


SELECT * FROM BSM_USER WHERE udf01='EXCLUDE';



-- SELECT bw.warehouseId AS WAREHOUSE_ID,bw.warehouseDescr AS WAREHOUSE_NAME,COUNT(buwas.userId) AS TOTAL_USER
--   FROM linc-bi.wms_cml.BSM_USER buwas INNER JOIN  
--       linc-bi.wms_cml.BSM_WAREHOUSE bw ON
--    bw.organizationId = buwas.organizationId AND buwas.groupname = bw.warehouseId
--   WHERE bw.activeFlag='Y' 
--  -- AND buwas.udf01 <> '' AND buwas.udf01<> '1' AND buwas.udf01<> 'H'
--   GROUP BY bw.warehouseId,bw.warehouseDescr 
--  union all
--   SELECT "*IDDLE USER*" AS WAREHOUSE_ID, "*IDDLE USER*" AS WAREHOUSE_NAME,16 AS TOTAL_USER;