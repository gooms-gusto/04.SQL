SELECT  dah.asnNo as trans_no
FROM DOC_ASN_HEADER dah 
WHERE dah.organizationId='OJV_CML'
AND dah.warehouseId='CBT01'
AND dah.customerId ='LTL'
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
AND DATE_FORMAT(dah.addTime,'%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH),'%Y-%m-%d')
 AND dah.asnNo NOT IN (
 SELECT DISTINCT(docNo) FROM BIL_SUMMARY 
 WHERE customerId='LTL' AND organizationId='OJV_CML'
 AND warehouseId='CBT01' AND chargeCategory='IB' AND  
 DATE_FORMAT(addTime,'%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH),'%Y-%m-%d'));


SELECT * FROM DOC_ASN_HEADER dah WHERE dah.asnNo='P000013780' AND dah.warehouseId='CBT01' AND dah.organizationId='OJV_CML';