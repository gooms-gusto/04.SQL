SELECT * FROM SYS_IDSEQUENCE WHERE idName='BILL INGAR';

SELECT DISTINCT(bs.arLineNo) FROM BIL_SUMMARY bs

SELECT * FROM BIL_SUMMARY bs WHERE bs.customerId='YARAJKT' AND bs.arNo LIKE 'AR2312290003' ;



SELECT * from BIL_BILLING_HEADER bbh WHERE bbh.billingNo LIKE 'AR%';

SELECT * FROM BIL_INV_LOG L WHERE L.billingNo='AR2312290003';

SELECT * FROM BIL_BILLING_DETAILS B WHERE B.billingNo='AR2312290003';

SELECT * FROM BAS_CUSTOMER_MULTIWAREHOUSE WHERE customerId='YARAJKT'

USE wms_cml;

USE wms_cml;

INSERT INTO BIL_BILLING_HEADER (organizationId, warehouseId, billingNo, status, BillTo, customerId, billingDate, billDateFM, billDateTO, totalAmount, discountStart, discountRate, totalBillingAmount, actualAmount, noteText, udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag, addWho, addTime, editWho, editTime, billingType, minAmount, maxAmount) VALUES
('OJV_CML', 'MRD01', 'AR2312290001', '00', 'YARAJKT', 'YARAJKT', '2023-12-29 20:00:18', '2023-12-29 20:00:18', '2023-12-29 20:00:18', 266000000, 0.00000000, 0.00000000, NULL, NULL, NULL, 'MRD0000000084', NULL, NULL, NULL, 'N', 100, '20230925105523000711RA172031009087[A3702]', 'IT_RBUDIMAN', '2023-12-29 20:00:18', 'FN_SUPARNO', '2023-12-29 20:00:18', 'AR', NULL, NULL);

INSERT INTO BIL_BILLING_HEADER (organizationId, warehouseId, billingNo, status, BillTo, customerId, billingDate, billDateFM, billDateTO, totalAmount, discountStart, discountRate, totalBillingAmount, actualAmount, noteText, udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag, addWho, addTime, editWho, editTime, billingType, minAmount, maxAmount) VALUES
('OJV_CML', 'MRD01', 'AR2312290002', '00', 'YARAJKT', 'YARAJKT', '2023-12-29 20:00:18', '2023-12-29 20:00:18', '2023-12-29 20:00:18', 41700000, 0.00000000, 0.00000000, NULL, NULL, NULL, 'MRD0000000085', NULL, NULL, NULL, 'N', 100, '20230925105523000711RA172031009087[A3702]', 'IT_RBUDIMAN', '2023-12-29 20:00:18', 'FN_SUPARNO', '2023-12-29 20:00:18', 'AR', NULL, NULL);

INSERT INTO BIL_BILLING_HEADER (organizationId, warehouseId, billingNo, status, BillTo, customerId, billingDate, billDateFM, billDateTO, totalAmount, discountStart, discountRate, totalBillingAmount, actualAmount, noteText, udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag, addWho, addTime, editWho, editTime, billingType, minAmount, maxAmount) VALUES
('OJV_CML', 'MRD01', 'AR2312290003', '00', 'YARAJKT', 'YARAJKT', '2023-12-29 20:00:18', '2023-12-29 20:00:18', '2023-12-29 20:00:18', 122940684.23, 0.00000000, 0.00000000, NULL, NULL, NULL, 'MRD0000000086', NULL, NULL, NULL, 'N', 100, '20230925105523000711RA172031009087[A3702]', 'IT_RBUDIMAN', '2023-12-29 20:00:18', 'FN_SUPARNO', '2023-12-29 20:00:18', 'AR', NULL, NULL);


USE wms_cml;

UPDATE BIL_BILLING_HEADER set billingDate=NULL, editTime=NOW()
WHERE organizationId = 'OJV_CML' AND warehouseId = 'MRD01' AND billingNo IN ( 'AR2312290001','AR2312290002','AR2312290003');


USE wms_cml;

USE wms_cml;

UPDATE BIL_BILLING_DETAILS
 SET billingLineNo = null, editTime=NOW()
 WHERE   organizationId = 'OJV_CML' AND warehouseId = 'MRD01' AND billingNo = 'AR2312290001';

USE wms_cml;

UPDATE BIL_SUMMARY SET arLineNo = '0' AND editTime=NOW()
 WHERE organizationId = 'OJV_CML' AND warehouseId = 'MRD01'
 AND billingSummaryId = 'SP00003554' AND customerId='YARAJKT';



USE wms_cml;

UPDATE BIL_SUMMARY SET arLineNo = '1' 
WHERE organizationId = 'OJV_CML' AND 
warehouseId = 'MRD01' 
AND customerId='YARAJKT' AND chargeCategory='IB'
AND arNo = 'AR2312290003';

UPDATE BIL_SUMMARY SET arLineNo = '2' 
WHERE organizationId = 'OJV_CML' AND 
warehouseId = 'MRD01' 
AND customerId='YARAJKT' AND chargeCategory='VA'
AND arNo = 'AR2312290003';

