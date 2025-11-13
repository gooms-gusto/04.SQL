SELECT
  dah.ASNNO
FROM DOC_ASN_HEADER dah
WHERE dah.organizationId = 'OJV_CML'
AND dah.warehouseId = 'CBT01'
AND dah.customerId = 'PPG'
AND (dah.ediSendFlag2 = 'N'
OR dah.ediSendFlag2 = NULL)
AND dah.asnStatus = '99'
AND dah.addTime > DATE_ADD(NOW(), INTERVAL -1 MONTH);


SELECT
  DATE_ADD(NOW(), INTERVAL 1 MONTH);

query show global variables like 'basedir'
SELECT
  dah.ASNNO,
  dah.ediSendTime,
  dah.ediSendFlag2,
  dah.udf08
FROM DOC_ASN_HEADER dah
WHERE dah.organizationId = 'OJV_CML'
AND dah.warehouseId = 'CBT01'
AND dah.ASNNO = 'ASNPPG2405130018';


SELECT * FROM DOC_ASN_HEADER dahu WHERE dahu.asnNo='ASNECC240612004';

SELECT * FROM DOC_ORDER_HEADER doh LIMIT 1

SELECT * FROM ACT_TRANSACTION_LOG atl WHERE atl.organizationId='OJV_CML' AND atl.transactionId='0158980'