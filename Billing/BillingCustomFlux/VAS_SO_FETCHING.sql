SELECT  dov.orderNo AS trans_no
FROM DOC_ORDER_HEADER doh INNER JOIN DOC_ORDER_VAS dov ON doh.organizationId = dov.organizationId AND doh.warehouseId = dov.warehouseId
AND doh.orderNo = dov.orderNo 
WHERE dov.warehouseId='CBT01'
AND doh.customerId ='HPK'
AND doh.soStatus IN ('99')
AND date(doh.addTime) > DATE_ADD(NOW(),INTERVAL -1 MONTH)
AND doh.orderNo NOT IN (
SELECT ds.docNo FROM BIL_SUMMARY ds
WHERE ds.customerId='HPK'
AND ds.warehouseId='CBT01' AND ds.chargeCategory='VA' AND  ds.addTime > doh.addTime );


SELECT * FROM BIL_TARIFF_DETAILS btd WHERE btd.tariffId='BIL00418'