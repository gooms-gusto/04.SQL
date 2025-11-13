SELECT  dav.asnNo AS trans_no
FROM DOC_ASN_HEADER dah  INNER JOIN DOC_ASN_VAS dav ON dah.organizationId = dav.organizationId AND dah.warehouseId = dav.warehouseId
AND dah.asnNo = dav.asnNo 
WHERE dav.warehouseId='CBT01'
AND dah.customerId ='HPK'
AND dah.asnStatus IN ('99') AND dah.asnType NOT IN ('FREE')
AND date(dah.addTime) > DATE_ADD(NOW(),INTERVAL -1 MONTH)
AND dah.asnNo NOT IN (
SELECT ds.docNo FROM BIL_SUMMARY ds
WHERE ds.customerId='HPK'
AND ds.warehouseId='CBT01' AND ds.chargeCategory='VA' AND  ds.addTime > dah.addTime );


SELECT * FROM BIL_TARIFF_DETAILS btd WHERE btd.tariffId='BIL00418'