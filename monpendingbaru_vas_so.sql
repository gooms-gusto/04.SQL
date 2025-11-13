SELECT
  dov.organizationId,
  dov.warehouseId,
  doh.customerId,
  dov.orderNo,dov.vasType
FROM DOC_ORDER_VAS dov
  INNER JOIN DOC_ORDER_HEADER doh
    ON dov.organizationId = doh.organizationId
    AND dov.warehouseId = doh.warehouseId
    AND dov.orderNo = doh.orderNo
  INNER JOIN DOC_ORDER_HEADER_UDF dahu
    ON dov.organizationId = dahu.organizationId
    AND dov.warehouseId = dahu.warehouseId
    AND dov.orderNo = dahu.orderNo
  INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
    ON (dov.organizationId = zbcc.organizationId
    AND dov.warehouseId = zbcc.warehouseId
    AND doh.customerId = zbcc.customerId)
  INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
    ON (zbcc.organizationId = zbccd.organizationId
    AND zbcc.lotatt01 = zbccd.idGroupSp)
WHERE dov.organizationId = 'OJV_CML'
AND DATE(dahu.closeTime) >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
AND zbcc.lotatt01 <> ''
      AND zbcc.active='Y'
      AND zbccd.active='Y'
      AND doh.soStatus IN ('99')
      AND doh.orderType NOT IN ('FREE')
  AND zbccd.spName='CML_BILLSOVASSTD'
  AND NOT EXISTS(
  SELECT  1 FROM BIL_SUMMARY
  where organizationId=doh.organizationId
  AND warehouseId=doh.warehouseId and customerId=doh.customerId AND chargeCategory='VA' AND docNo=dov.orderNo
 AND addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
