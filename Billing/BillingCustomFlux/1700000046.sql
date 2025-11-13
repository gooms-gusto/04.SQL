SELECT  doh.orderNo as trans_no
FROM DOC_ORDER_HEADER doh 
WHERE doh.warehouseId='CBT01'
AND doh.customerId ='HPK'
AND doh.orderType NOT IN ('FREE')
AND doh.soStatus IN ('99')
AND date(doh.addTime) > DATE_ADD(NOW(),INTERVAL -30 DAY)
AND doh.orderNo NOT IN (
SELECT bs.docNo FROM BIL_SUMMARY bs
WHERE bs.customerId='HPK'
AND bs.warehouseId='CBT01' AND bs.chargeCategory='OB' AND  bs.addTime > doh.addTime)
