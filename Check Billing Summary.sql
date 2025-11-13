USE wms_cml;

SELECT DISTINCT(bs.docNo) FROM BIL_SUMMARY bs WHERE bs.customerId='BMM_JKT' AND 
bs.organizationId='OJV_CML' AND bs.warehouseId='MRD02'  AND 
 DATE_FORMAT(bs.billingFromDate,'%Y-%m-%d') BETWEEN '2024-03-26' AND '2024-04-22';


DELETE FROM BIL_SUMMARY
WHERE customerId='BMM_JKT' AND organizationId='OJV_CML' AND warehouseId='MRD02'  AND 
DATE_FORMAT(billingFromDate,'%Y-%m-%d') BETWEEN '2024-03-26' AND '2024-04-23';


SELECT * FROM BAS_MANPOWER bm ORDER BY bm.AddTime desc;



SELECT  dah.asnNo as trans_no
FROM DOC_ASN_HEADER dah 
WHERE dah.warehouseId='MRD02'
AND dah.customerId ='BMM_JKT'
AND dah.asnType  IN (
SELECT DISTINCT btd.docType
  FROM BAS_SKU_MULTIWAREHOUSE bsm
        INNER JOIN BAS_CUSTOMER bc
          ON bc.customerId = bsm.customerId
          AND bc.organizationId = bsm.organizationId
          AND bc.CustomerType = 'OW'
        INNER JOIN BIL_TARIFF_HEADER bth
          ON bth.organizationId = bsm.organizationId
          AND bth.tariffMasterId = bsm.tariffMasterId
        INNER JOIN BIL_TARIFF_DETAILS btd
          ON btd.organizationId = bth.organizationId
          AND btd.tariffId = bth.tariffId
          WHERE bsm.organizationId=dah.organizationId AND bc.customerId=dah.customerId AND bsm.warehouseId=dah.warehouseId
  AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND btd.chargeCategory = 'IB'
)
AND dah.asnStatus IN ('99')
AND DATE_FORMAT(dah.addTime,'%Y-%m-%d') >= DATE_FORMAT('2024-02-26','%Y-%m-%d')
AND dah.organizationId='OJV_CML'
 AND dah.asnNo NOT IN (
 SELECT docNo FROM BIL_SUMMARY 
 WHERE customerId='BMM_JKT' AND organizationId='OJV_CML'
 AND warehouseId='MRD02' AND chargeCategory='IB' AND  
 DATE_FORMAT(addTime,'%Y-%m-%d') >= DATE_FORMAT('2024-02-26','%Y-%m-%d'));







SELECT  doh.orderNo as trans_no
FROM DOC_ORDER_HEADER doh 
WHERE doh.warehouseId='MRD02'
AND doh.customerId ='BMM_JKT'
AND doh.orderType NOT IN (
SELECT DISTINCT btd.docType
  FROM BAS_SKU_MULTIWAREHOUSE bsm
        INNER JOIN BAS_CUSTOMER bc
          ON bc.customerId = bsm.customerId
          AND bc.organizationId = bsm.organizationId
          AND bc.CustomerType = 'OW'
        INNER JOIN BIL_TARIFF_HEADER bth
          ON bth.organizationId = bsm.organizationId
          AND bth.tariffMasterId = bsm.tariffMasterId
        INNER JOIN BIL_TARIFF_DETAILS btd
          ON btd.organizationId = bth.organizationId
          AND btd.tariffId = bth.tariffId
          WHERE bsm.organizationId=doh.organizationId AND bc.customerId=doh.customerId AND bsm.warehouseId=doh.warehouseId
  AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND btd.chargeCategory = 'OB'
)
AND doh.soStatus IN ('99')
AND DATE_FORMAT(doh.addTime,'%Y-%m-%d') >= DATE_FORMAT('2024-02-26','%Y-%m-%d')
 AND doh.orderNo NOT IN (
 SELECT bs.docNo FROM BIL_SUMMARY bs
 WHERE bs.customerId='BMM_JKT'
 AND bs.warehouseId='MRD02' AND bs.chargeCategory='OB' 
 AND  DATE_FORMAT(bs.addTime,'%Y-%m-%d') >= DATE_FORMAT('2024-02-26','%Y-%m-%d'))



