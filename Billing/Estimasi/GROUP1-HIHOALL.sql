SELECT bs.warehouseId AS WAREHOUSE_ID,
bw.udf02 AS SALES_AREA,
btm.udf01 AS DIVISION_CODE,
bc.udf02 AS SAP_CUSTOMER_ID,
SUM(bs.billingAmount) AS BILLING_AMOUNT,
 CASE
        WHEN DAY(CURDATE()) > 25 THEN 
        DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL (25 - DAY(CURDATE()) + DAY(LAST_DAY(CURDATE()))) DAY),'%m')
        ELSE  DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL (25 - DAY(CURDATE())) DAY),'%m') END AS MONTH_PERIOD,
        DATE_FORMAT(CURRENT_DATE(),'%Y') AS  YEAR_PERIOD
FROM BIL_SUMMARY bs INNER JOIN BAS_CUSTOMER bc
ON bs.organizationId = bc.organizationId
AND bs.customerId = bc.customerId
LEFT JOIN BIL_TARIFF_HEADER bth ON bs.organizationId = bth.organizationId
AND bs.tariffId = bth.tariffId
LEFT JOIN BIL_TARIFF_MASTER btm ON bs.organizationId = btm.organizationId
AND bth.tariffMasterId=btm.tariffMasterId
LEFT JOIN BSM_WAREHOUSE bw ON bs.organizationId = bw.organizationId AND bs.warehouseId = bw.warehouseId
 WHERE bs.organizationId='OJV_CML' AND 
 CASE WHEN btm.udf02='25' THEN 
 (DATE_FORMAT(date(bs.billingfromdate),'%Y-%m-%d') >'2024-12-25'
 AND DATE_FORMAT(date(bs.billingfromdate),'%Y-%m-%d') < '2025-01-26')
 ELSE
 (DATE_FORMAT(date(bs.billingfromdate),'%Y-%m-%d') >'2025-01-01'
 AND DATE_FORMAT(date(bs.billingfromdate),'%Y-%m-%d') < '2025-01-31')
 END
 AND bs.chargecategory <> 'IV'
 AND bc.customerType='OW'
 AND bc.activeFlag='Y'
--  AND bc.udf02='3000007550'
--  AND bs.warehouseid  IN ('SMG-TA')
  AND bc.udf02 NOT IN ('8000000010')
  AND btm.udf02='25'
  AND bs.warehouseid NOT IN ('SBYMM','BASF02','BASF01')
 AND bs.customerId NOT LIKE 'IDC%'
 AND bs.customerId NOT LIKE 'PKT%'
 GROUP BY bs.warehouseid,bw.udf02,btm.udf01,bc.udf02;