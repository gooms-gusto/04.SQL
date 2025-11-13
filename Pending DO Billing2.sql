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
 AND  DATE_FORMAT(bs.addTime,'%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH),'%Y-%m-%d')) order BY doh.lastShipmentTime ASC;


SELECT CONNECTION_ID();

SELECT * FROM Z_SP_BILLING_LOG zsbl WHERE zsbl.lottable02='CUSTOMBILL'   ORDER BY zsbl.addTime DESC LIMIT 10;


SELECT * FROM Z_SP_BILLING_LOG zsbl 
  ORDER BY zsbl.addTime DESC LIMIT 300

CBT02/TUMI/TUMISO2508130014

SELECT aad.organizationId,aad.warehouseId,aad.allocationDetailsId,
  aad.orderNo FROM ACT_ALLOCATION_DETAILS aad 
  WHERE aad.organizationId='OJV_CML' AND 
  aad.warehouseId='CBT02' AND aad.customerId='MAP'AND aad.orderNo='SAMSO000035724';

SELECT organizationId,warehouseId,customerId,lotatt01 from Z_BAS_CUSTOMER_CUSTBILLING where active='Y'  order by seqNo;


SELECT * FROM ACT_ALLOCATION_DETAILS aad WHERE aad.organizationId='OJV_CML'
  AND aad.warehouseId='SBYKK' AND aad.customerId='ADASBY'
  AND aad.orderNo='SOADA250811001';


SELECT bbh.tariffLineNo, bbh.chargeCategory,bbh.descrC,bbh.ratebase,bbh.udf01 FROM BIL_TARIFF_DETAILS bbh WHERE bbh.organizationId='OJV_CML' AND 
bbh.chargeCategory='VA' AND bbh.tariffLineNo <=100;





SELECT * FROM Z_BAS_CUSTOMER_CUSTBILLING zbcc;

SELECT * FROM Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd;

SELECT  dah.asnNo as trans_no
FROM DOC_ASN_HEADER dah 
WHERE dah.organizationId='OJV_CML'
AND dah.warehouseId='SMG-SO'
AND dah.customerId ='PPT_SMG'
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
AND DATE_FORMAT(dah.addTime,'%Y-%m-%d') >= DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL -1 MONTH),'%Y-%m-%d')
 AND dah.asnNo NOT IN (
 SELECT DISTINCT(docNo) FROM BIL_SUMMARY 
 WHERE customerId='PPT_SMG' AND organizationId='OJV_CML'
 AND warehouseId='SMG-SO' AND chargeCategory='IB' AND  
 DATE_FORMAT(addTime,'%Y-%m-%d') >= DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL -1 MONTH),'%Y-%m-%d')) order by dah.editTime ASC;
 