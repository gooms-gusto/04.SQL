SELECT 
warehouseid,salesarea,
CASE WHEN MAX(divcode) IS NULL THEN '62' ELSE MAX(divcode) END  AS divcode,
sapcustomerid,
sum(billingamount) AS billingamount,YEAR(NOW()) AS YearPeriod, MONTH(NOW()) AS MonthPeriod
FROM ZV_BILLING_DATA
WHERE (DATE_FORMAT(DATE(billingfromdate),'%Y-%m-%d') >= '2024-08-26'
 AND DATE_FORMAT(DATE(billingfromdate),'%Y-%m-%d') <=  '2024-09-25') AND chargecategory <> 'IV'
  AND sapcustomerid NOT IN('3000000733','3000000735','3000016576','3000005193') AND (sapcustomerid NOT IN('8000000010') AND warehouseid NOT IN ('SBYMM'))
GROUP BY 
warehouseid,salesarea,sapcustomerid;


SELECT
SUM(bs.billingAmount) AS total,
bc.udf02,bs.chargeCategory,bs.chargeType,bs.warehouseId
FROM BIL_SUMMARY bs
INNER JOIN BAS_CUSTOMER bc 
ON bs.organizationId = bc.organizationId 
AND bs.customerId = bc.customerId
WHERE bc.organizationId='OJV_CML' AND bc.udf02='3000008984' AND bs.chargeCategory <> 'IV'
AND (DATE_FORMAT(DATE(billingfromdate),'%Y-%m-%d') >= '2024-08-26'
 AND DATE_FORMAT(DATE(billingfromdate),'%Y-%m-%d') <=  '2024-09-25')
GROUP BY bc.udf02,bs.chargeCategory,bs.chargeType,bs.warehouseId ;