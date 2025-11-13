USE WMS_FTEST;

SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT01';
SET @IN_USERID ='EDI';
SET @IN_Language = 'EN';
SET @IN_CustomerId = 'MAP';
set @IN_asnNo='MAP_ORDERNO000000107';
SET @OUT_returnCode = '';
CALL BILL_MOD229(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId,@IN_asnNo);
SELECT
  @OUT_returnCode;

SET @OUT_returnCode = '';
      CALL SPCOM_GetIDSequence('OJV_CML', 'CBT01', 'EN', 'BILLINGSUMMARYID', '', @OUT_returnCode);
SELECT
  @OUT_returnCode;



USE WMS_FTEST;

SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT01';
SET @IN_USERID ='EDI';
SET @IN_Language = 'EN';
SET @IN_CustomerId = 'MAP';
set @IN_orderNo='MAP_ORDERNO000000107';
SET @OUT_returnCode = '';
CALL BILL_MOD339(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId,@IN_orderNo, @OUT_returnCode);
SELECT
  @OUT_returnCode;



CREATE PROCEDURE debug_msg(enabled INTEGER, msg VARCHAR(255))
BEGIN
  IF enabled THEN
    select concat('** ', msg) AS '** DEBUG:';
  END IF;
END 

SELECT * FROM TMP_BIL_SUMMARY_INFO2

SELECT * FROM BIL_SUMMARY bs WHERE bs.docNo='MAPASN0609230001';

SELECT * FROM BIL_SUMMARY_LOG bsl WHERE bsl.billingSummaryId='INV033370*01';
SELECT * FROM BIL_SUMMARY_INFORMATION WHERE billingSummaryId='INV033370*01';

SELECT * FROM BIL_TARIFF_HEADER bth WHERE bth.tariffId='BIL00300';
SELECT * FROM BIL_TARIFF_DETAILS btd  WHERE btd.tariffId='BIL00300';