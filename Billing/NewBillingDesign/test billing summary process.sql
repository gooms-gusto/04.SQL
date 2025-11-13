USE WMS_FTEST;

SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'MRD01';
SET @IN_USERID = 'EDI';
SET @IN_Language = 'EN';
SET @IN_BillingSummaryID = '0065*01,SP000563,0005*01';
CALL CML_BILLSUMMARYPROCESS(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_BillingSummaryID);
SELECT
  @OUT_returnCode;


SELECT arNo,bs.warehouseId FROM BIL_SUMMARY bs WHERE bs.billingSummaryId='0016*01'


SELECT * FROM CML_TEMP_LOG ctl;


SELECT * FROM BIL_BILLING_HEADER bbh WHERE bbh.billingNo IN('0000000003','AR2309250018') AND bbh.warehouseId='MRD01';
SELECT * FROM BIL_BILLING_DETAILS  bbh WHERE bbh.billingNo IN('0000000003','AR2309250018') AND bbh.warehouseId='MRD01';
SELECT bs.arNo FROM  BIL_SUMMARY bs WHERE bs.billingSummaryId='0040*01'


USE WMS_FTEST;

INSERT INTO BIL_BILLING_HEADER (organizationId, warehouseId, billingNo, status, BillTo, customerId, billingDate, billDateFM, billDateTO, totalAmount, discountStart, discountRate, totalBillingAmount, actualAmount, noteText, udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag, addWho, addTime, editWho, editTime, billingType, minAmount, maxAmount) VALUES
('OJV_CML', 'MRD01', '0000000003', '00', 'YARAJKT', 'YARAJKT', NULL, '2023-09-25 00:00:00', '2023-09-25 00:00:00', 1393340.00000000, 0.00000000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N', 100, '20230925105523000711RA172031009087[A3702]', 'WM_AARDIANSAH', '2023-09-25 10:55:24', 'WM_AARDIANSAH', '2023-09-25 10:55:24', 'AR', NULL, NULL);


USE WMS_FTEST;

INSERT INTO BIL_BILLING_DETAILS (organizationId, warehouseId, billingNo, billingLineNo, chargeCategory, chargeType, billingAmount, noteText, udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag, addWho, addTime, editWho, editTime) VALUES
('OJV_CML', 'MRD01', '0000000003', 1, 'IB', 'IB01', 1393340.00000000, NULL, NULL, NULL, NULL, NULL, NULL, 100, '20230925105523000711RA172031009087[A3702]', 'WM_AARDIANSAH', '2023-09-25 10:55:24', 'WM_AARDIANSAH', '2023-09-25 10:55:24');
