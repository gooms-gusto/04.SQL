USE WMS_FTEST;

SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT01';
SET @IN_USERID = 'CUSTOMBILL';
SET @IN_Language = 'en';
SET @IN_CustomerId = 'LTL';
SET @IN_trans_no = 'P000000953';
SET @IN_tariffMaster = '';
CALL CML_BILLHISTD(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @IN_tariffMaster);

SELECT dah.asnNo ,bs.customerId,bs.warehouseId
FROM DOC_ASN_HEADER dah INNER JOIN BIL_SUMMARY bs
ON dah.organizationId = bs.organizationId AND dah.warehouseId = bs.warehouseId AND dah.customerId = bs.customerId
AND dah.asnNo=bs.docNo
WHERE dah.organizationId='OJV_CML'
AND dah.asnStatus='99'
AND bs.addWho ='EDI'
ORDER BY dah.editTime DESC LIMIT 1;


SELECT dah.orderNo ,bs.customerId,bs.warehouseId
FROM DOC_ORDER_HEADER dah INNER JOIN BIL_SUMMARY bs
ON dah.organizationId = bs.organizationId AND dah.warehouseId = bs.warehouseId AND dah.customerId = bs.customerId
AND dah.orderNo=bs.docNo
WHERE dah.organizationId='OJV_CML'
AND dah.soStatus='99'
AND bs.addWho ='EDI'
ORDER BY dah.editTime DESC LIMIT 1;

SELECT * FROM BIL_SUMMARY bs WHERE bs.docNo='MAP_ORDERNO000000168' and bs.organizationId='OJV_CML';
  
DELETE FROM BIL_SUMMARY WHERE organizationId='OJV_CML' AND docNo='P000000953' AND warehouseId='CBT01' AND customerId='LTL';