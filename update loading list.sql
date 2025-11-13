USE wms_cml;

UPDATE DOC_LOADING_HEADER 
  SET ldlStatus='00',editTime=NOW()
  WHERE ldlNo='LDLB2C23030040' AND warehouseId='CBT02-B2C';

SELECT * FROM DOC_LOADING


  SELECT * FROM wms_cml.DOC_ASN_DETAILS WHERE asnNo='ASNAPI211228006 ' AND warehouseId='CBT02';

    SELECT * FROM wms_cml.TMP_DOC_ASN_DETAILS   WHERE asnNo='ASNAPI211228006 ' AND warehouseId='CBT02';

    SELECT * FROM ACT_TRANSACTION_LOG WHERE docNo='ASNAPI211228006';


    USE wms_cml;
UPDATE ACT_TRANSACTION_LOG SET totalGrossWeight = 800.00000000,editTime=NOW() WHERE organizationId = 'OJV_CML' AND warehouseId = 'CBT02' AND transactionId = '0030813' AND fmCustomerId='API';
UPDATE ACT_TRANSACTION_LOG SET totalGrossWeight = 800.00000000,editTime=NOW() WHERE organizationId = 'OJV_CML' AND warehouseId = 'CBT02' AND transactionId = '0030817' AND fmCustomerId='API';
UPDATE DOC_ASN_DETAILS SET totalGrossWeight = 800.00000000,editTime=NOW() WHERE organizationId = 'OJV_CML' AND warehouseId = 'CBT02' AND asnNo = 'ASNAPI211228006' AND asnLineNo = 1;


