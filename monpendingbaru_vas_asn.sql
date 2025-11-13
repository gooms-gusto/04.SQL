SELECT
  dav.organizationId,
  dav.warehouseId,
  dah.customerId,
  dav.asnNo,dav.vasType
FROM DOC_ASN_VAS dav
  INNER JOIN DOC_ASN_HEADER dah
    ON dav.organizationId = dah.organizationId
    AND dav.warehouseId = dah.warehouseId
    AND dav.asnNo = dah.asnNo
  INNER JOIN DOC_ASN_HEADER_UDF  dahu
    ON dav.organizationId = dahu.organizationId
    AND dav.warehouseId = dahu.warehouseId
    AND dav.asnNo = dahu.asnNo
  INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
    ON (dav.organizationId = zbcc.organizationId
    AND dav.warehouseId = zbcc.warehouseId
    AND dah.customerId = zbcc.customerId)
  INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
    ON (zbcc.organizationId = zbccd.organizationId
    AND zbcc.lotatt01 = zbccd.idGroupSp)
WHERE dav.organizationId = 'OJV_CML'
AND DATE(dahu.closeTime) >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
AND zbcc.lotatt01 <> ''
      AND zbcc.active='Y'
      AND zbccd.active='Y'
      AND dah.asnStatus IN ('99')
      AND dah.asnType NOT IN ('FREE')
  AND zbccd.spName='CML_BILLASNVASSTD'
  AND NOT EXISTS(
  SELECT  1 FROM BIL_SUMMARY
  where organizationId=dah.organizationId
  AND warehouseId=dah.warehouseId and customerId=dah.customerId AND chargeCategory='VA' AND docNo=dav.asnNo AND docType='SO'
 AND addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))