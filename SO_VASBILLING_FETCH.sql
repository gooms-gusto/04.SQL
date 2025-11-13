SELECT doh.organizationId,
  doh.warehouseId,
  doh.customerId,
  doh.orderNo AS trans_no,
  zbccd.spName,
  doh.editTime AS trans_time
FROM DOC_ORDER_HEADER doh 
   INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
      ON (doh.organizationId = zbcc.organizationId
      AND doh.warehouseId = zbcc.warehouseId
      AND doh.customerId = zbcc.customerId)
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
      ON (zbcc.organizationId = zbccd.organizationId
      AND zbcc.lotatt01 =zbccd.idGroupSp)
WHERE doh.organizationId='OJV_CML'
    AND zbcc.lotatt01 <> ''
      AND zbcc.active='Y'
      AND zbccd.active='Y'
  AND zbccd.spName='CML_BILLSOVASSTD'
 -- AND doh.warehouseId='@warehouse'
-- AND  doh.customerId=''
 AND EXISTS
(SELECT 1 FROM DOC_ORDER_VAS dov WHERE doh.organizationId = dov.organizationId AND doh.warehouseId = dov.warehouseId
AND doh.orderNo = dov.orderNo
  AND date(dov.editTime) >=DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
AND doh.soStatus IN ('99') AND doh.orderType NOT IN ('FREE')
AND date(doh.editTime) >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
AND NOT EXISTS(
SELECT 1 FROM BIL_SUMMARY bs
WHERE bs.organizationId=doh.organizationId AND bs.customerId=doh.customerId
AND bs.warehouseId=doh.warehouseId AND bs.chargeCategory='VA' AND bs.docType='SO'
  AND  bs.addTime >=  DATE_SUB(CURDATE(), INTERVAL 2 MONTH) 
 );
