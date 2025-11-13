SELECT  dah.asnNo as trans_no
FROM DOC_ASN_HEADER dah 
WHERE dah.warehouseId='CBT02'
AND dah.customerId ='ADS'
AND dah.asnType NOT IN ('FREE')
AND dah.asnStatus IN ('99')
AND DATE_FORMAT(dah.addTime,'%Y-%m-%d') >= DATE_FORMAT('2024-02-26','%Y-%m-%d')
AND dah.organizationId='OJV_CML'
AND dah.asnNo NOT IN (
SELECT docNo FROM BIL_SUMMARY 
WHERE customerId='ADS' AND organizationId='OJV_CML'
AND warehouseId='CBT02' AND chargeCategory='IB' AND  DATE_FORMAT(addTime,'%Y-%m-%d') >= DATE_FORMAT('2024-02-26','%Y-%m-%d'))

