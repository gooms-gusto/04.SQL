SELECT  doh.orderNo as trans_no
FROM DOC_ORDER_HEADER doh 
WHERE doh.organizationId='OJV_CML'
AND doh.warehouseId='CBT02'
AND doh.customerId ='TUMI'
AND doh.orderType IN (
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
AND DATE_FORMAT(doh.addTime,'%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH),'%Y-%m-%d')
 AND doh.orderNo NOT IN (
 SELECT DISTINCT(bs.docNo) FROM BIL_SUMMARY bs
 WHERE bs.organizationId='OJV_CML'
 AND bs.customerId='TUMI'
 AND bs.warehouseId='CBT02' AND bs.chargeCategory='OB' 
 AND  DATE_FORMAT(bs.addTime,'%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH),'%Y-%m-%d')) order BY doh.lastShipmentTime ASC