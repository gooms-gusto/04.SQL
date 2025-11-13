SELECT bs.warehouseId, bw.udf02 AS salesarea,'61' AS divcode,bc.udf02 AS sapcustomerid
,SUM(bs.cost) AS billingamount,YEAR(NOW()) AS YearPeriod, MONTH(NOW()) AS MonthPeriod
FROM 
BIL_SUMMARY bs INNER JOIN BAS_CUSTOMER bc
ON bs.organizationId = bc.organizationId AND bs.customerId = bc.customerId
INNER JOIN BSM_WAREHOUSE bw ON bs.organizationId = bw.organizationId AND bs.warehouseId = bw.warehouseId
WHERE bs.organizationId='OJV_CML'
AND bs.warehouseId='CBT03'
AND bc.customerType='OW'
AND (DATE_FORMAT(DATE(bs.billingFromDate),'%Y-%m-%d') >= DATE_ADD(DATE(getBillFMDate(1)), INTERVAL -1 DAY )
 AND DATE_FORMAT(DATE(bs.billingFromDate),'%Y-%m-%d') <= DATE(getBillTODate(DAY(LAST_DAY(NOW()))))) AND chargecategory <> 'IV'
 GROUP BY bs.warehouseid,bw.udf02,bc.udf02;