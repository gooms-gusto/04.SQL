SELECT bth.warehouseId AS WAREHOUSE_ID,
 bw.udf02 AS SALES_AREA,
 CASE WHEN btd.udf06 is NULL THEN '62' ELSE btd.udf06 END  AS DIVISION_CODE,
  bc.udf02 AS SAP_CUSTOMER_ID , 
  CASE WHEN DAY(NOW()) =26 THEN ROUND(btd.minAmount / 1 ,2)  ELSE
   ROUND((btd.minAmount/DAY(LAST_DAY(NOW())))*DATEDIFF(NOW(), wms_cml.getBillFMDate(26)),2) END AS BILLING_AMOUNT,
DATE_FORMAT( DATE_ADD(CURDATE(),INTERVAL - 1 DAY),'%m')  AS  MONTH_PERIOD,
DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL - 1 DAY),'%Y') AS  YEAR_PERIOD
FROM BIL_TARIFF_HEADER bth INNER JOIN BIL_TARIFF_DETAILS btd
ON bth.organizationId = btd.organizationId AND bth.warehouseId = btd.warehouseId AND bth.tariffId = btd.tariffId
INNER JOIN BIL_TARIFF_MASTER btm ON bth.organizationId = btm.organizationId AND bth.tariffMasterId = btm.tariffMasterId
INNER JOIN BAS_CUSTOMER bc ON btm.organizationId = bc.organizationId AND btm.Customerid = bc.customerId
INNER JOIN BSM_WAREHOUSE bw ON bw.organizationId = bth.organizationId AND bw.warehouseId=bth.warehouseId
WHERE btd.organizationId='OJV_CML'   AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bth.effectiveTo >=  DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY), '%Y-%m-%d')
      AND btm.udf02='01'
      AND bc.customerType='OW'
      AND bc.activeFlag='Y'
      AND btd.chargeCategory='FX';