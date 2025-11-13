SELECT bth.warehouseId AS WarehouseId,
 bw.udf02 AS salesarea,
 CASE WHEN btd.udf06 is NULL THEN '62' ELSE btd.udf06 END  AS divcode,
  bc.udf02 AS sapcustomerid , CASE WHEN DAY(NOW()) =26 THEN ROUND(btd.minAmount / 1 ,2)  ELSE
   ROUND((btd.minAmount/DAY(LAST_DAY(NOW())))*DATEDIFF(NOW(), wms_cml.getBillFMDate(26)),2) END AS BillingAmount,
  -- btd.minAmount AS BillingAmount,
  YEAR(NOW()) AS YearPeriod, MONTH(NOW()) AS MonthPeriod
-- btm.customerId,
-- bth.tariffMasterId,
-- btd.chargeCategory,
-- btd.descrC,btd.ratebase,
FROM BIL_TARIFF_HEADER bth INNER JOIN BIL_TARIFF_DETAILS btd
ON bth.organizationId = btd.organizationId AND bth.warehouseId = btd.warehouseId AND bth.tariffId = btd.tariffId
INNER JOIN BIL_TARIFF_MASTER btm ON bth.organizationId = btm.organizationId AND bth.tariffMasterId = btm.tariffMasterId
INNER JOIN BAS_CUSTOMER bc ON btm.organizationId = bc.organizationId AND btm.Customerid = bc.customerId
INNER JOIN BSM_WAREHOUSE bw ON bw.organizationId = bth.organizationId AND bw.warehouseId=bth.warehouseId
WHERE btd.organizationId='OJV_CML'   AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bc.customerType='OW'
      AND bc.activeFlag='Y'
      AND btd.chargeCategory='FX';