USE WMS_FTEST;

SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT01';
SET @IN_USERID = 'EDI';
SET @IN_Language = 'en';
SET @IN_CustomerId = 'HPK';
SET @IN_asnNo ='HPK_ASNNO00000000009';
SET @IN_tariffMaster = 'BIL00036';
CALL CML_BILLHISTD(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_asnNo, @IN_tariffMaster);