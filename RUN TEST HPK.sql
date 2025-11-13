-- C3309
-- B2703
-- HPK_ASNNO00000000014

USE WMS_FTEST;

SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT01';
SET @IN_USERID ='EDI';
SET @IN_Language = 'en';
SET @IN_CustomerId = 'HPK';
SET @IN_trans_no = 'HPK_ASNNO00000000014';
SET @IN_tariffMaster = '000';
CALL CML_BILLHISTD(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @IN_tariffMaster);

DELETE FROM BIL_SUMMARY WHERE docNo='HPK_ASNNO00000000014' AND organizationId='OJV_CML';

SELECT * FROM BIL_SUMMARY WHERE docNo='HPK_ASNNO00000000014' AND organizationId='OJV_CML';