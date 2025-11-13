SELECT dah.organizationId,
  dah.warehouseId,
  dah.customerId,
  dah.asnNo AS trans_no,
  zbccd.spName,
  dah.editTime AS trans_time
FROM DOC_ASN_HEADER dah
  INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
      ON (dah.organizationId = zbcc.organizationId
      AND dah.warehouseId = zbcc.warehouseId
      AND dah.customerId = zbcc.customerId)
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
      ON (zbcc.organizationId = zbccd.organizationId
      AND zbcc.lotatt01 =zbccd.idGroupSp)
WHERE dah.organizationId='OJV_CML' 
AND dah.asnStatus IN ('99') AND dah.asnType NOT IN ('FREE')
    AND zbcc.lotatt01 <> ''
      AND zbcc.active='Y'
      AND zbccd.active='Y'
  AND zbccd.spName='CML_BILLASNVASSTD'
-- AND dah.warehouseId='@warehouse' 
-- AND dah.customerId ='@customer'
AND EXISTS (
SELECT 1 FROM  DOC_ASN_VAS dav WHERE dah.organizationId = dav.organizationId AND dah.warehouseId = dav.warehouseId
AND dah.asnNo = dav.asnNo AND  date(dav.editTime) >=DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
)
AND date(dah.editTime) > DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
AND  NOT EXISTS (SELECT 1 FROM BIL_SUMMARY bs
WHERE  bs.organizationId='OJV_CML' AND bs.docNo=dah.asnNo AND bs.customerId=dah.customerId AND
 bs.chargeCategory='VA' AND  bs.docType='ASN' AND date(bs.addTime) >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
ORDER BY dah.editTime DESC;