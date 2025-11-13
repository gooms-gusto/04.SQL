USE wms_cml;

SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT02';
SET @IN_USERID = 'CUSTOMBIL';
SET @IN_Language = 'en';
SET @IN_CustomerId = 'LTL';
SET @IN_trans_no = 'P000013411';
SET @IN_tariffMaster = '';
CALL CML_BILLASNVASSTD(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @IN_tariffMaster);



CALL CML_BILLHOSTD('OJV_CML','CBT02','CUSTOMBIL','en','ADS','SOADS240517003','00');

SELECT * FROM BIL_TARIFF_DETAILS btd WHERE btd.tariffId='BIL00612';

SELECT bs.docNo, bs.addWho FROM BIL_SUMMARY bs WHERE bs.docNo IN 
('P000013499') GROUP BY bs.addWho,bs.docNo ORDER BY bs.docNo DESC;


DELETE FROM BIL_SUMMARY WHERE docNo IN
('P000013499') AND addWho='EDI' AND organizationId='OJV_CML' AND warehouseId='CBT02' AND customerId='LTL';


SELECT MAX(bs.billingSummaryId) from BIL_SUMMARY bs WHERE date(bs.addTime) = date(NOW()) AND bs.addWho='CUSTOMBIL';

SELECT * FROM SYS_IDSEQUENCE si WHERE si.idName='BILLINGSUMMARYID' AND si.warehouseId='CBT01';
 




SELECT  dah.asnNo,dah.addTime  as trans_no
FROM DOC_ASN_HEADER dah 
WHERE dah.organizationId='OJV_CML'
AND dah.warehouseId='CBT02'
AND dah.customerId ='ADS'
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
 WHERE customerId='ADS' AND organizationId='OJV_CML'
 AND warehouseId='CBT02' AND chargeCategory='IB' AND  
 DATE_FORMAT(addTime,'%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH),'%Y-%m-%d'));
 