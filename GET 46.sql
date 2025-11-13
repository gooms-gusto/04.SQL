USE wms_cml;
SELECT  doh.orderNo as trans_no
FROM DOC_ORDER_HEADER doh 
WHERE doh.warehouseId='CBT02'
AND doh.customerId ='ADS'
AND doh.orderType NOT IN ('FREE')
AND doh.soStatus IN ('99')
AND DATE_FORMAT(doh.addTime,'%Y-%m-%d') >= DATE_FORMAT('2024-02-26','%Y-%m-%d')
AND doh.organizationId='OJV_CML'
AND doh.orderNo NOT IN (
SELECT bs.docNo FROM BIL_SUMMARY bs
WHERE bs.customerId='ADS' AND bs.organizationId='OJV_CML'
AND bs.warehouseId='CBT02' AND bs.chargeCategory='OB' AND  DATE_FORMAT(bs.addTime,'%Y-%m-%d') >= DATE_FORMAT('2024-02-26','%Y-%m-%d'));


-- SELECT DATE_FORMAT('2024-02-26','%Y-%m-%d');