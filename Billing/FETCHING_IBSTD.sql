SELECT  dah.asnNo as trans_no
FROM DOC_ASN_HEADER dah 
WHERE dah.warehouseId='CBT01'
AND dah.customerId ='HPK'
AND dah.asnType NOT IN ('FREE')
AND dah.asnStatus IN ('99')
AND date(dah.addTime) > DATE_ADD(NOW(),INTERVAL -30 DAY)
AND dah.asnNo NOT IN (
SELECT docNo FROM BIL_SUMMARY 
WHERE customerId='HPK'
AND warehouseId='CBT01' AND chargeCategory='IB' AND  addTime > dah.addTime )
