use wms_cml;


SELECT DISTINCT(bbh.customerId) FROM BIL_BILLING_HEADER bbh
WHERE DATE(bbh.addTime) >= '2025-05-26'
AND DATE(bbh.addTime) <= '2025-06-04';


SELECT DISTINCT(bs.customerId)
FROM BIL_SUMMARY bs
WHERE DATE(bs.billingFromDate) > '2025-05-21'
AND DATE(bs.billingFromDate) < '2025-06-02';





SELECT DISTINCT bbd.warehouseId,bbh.customerId,bbd.chargeCategory ,bbd.chargeType,bcm.codeDescr
FROM BIL_BILLING_DETAILS bbd
INNER JOIN BIL_BILLING_HEADER bbh ON bbd.organizationId = bbh.organizationId
INNER JOIN BSM_CODE_ML bcm ON bbd.organizationId = bcm.organizationId
AND bbd.chargeCategory=bbd.chargeCategory AND bbd.chargeType=bcm.codeid
AND bbd.warehouseId = bbh.warehouseId AND bbd.billingNo = bbh.billingNo
WHERE DATE(bbd.addTime) >= '2025-05-26'
AND DATE(bbd.addTime) <= '2025-06-04' AND bbd.chargeCategory='IV'
AND bcm.languageId='en' AND bcm.codeType='CHARGE_TYPE'
GROUP BY bbd.warehouseId,bbh.customerId,bbd.chargeType,bbd.chargeCategory ,bcm.codeDescr
ORDER BY bbd.warehouseId,bbh.customerId ;


-- SELECT * FROM BSM_CODE_ML bcm WHERE bcm.codeDescr='Staging Location' ;







          