USE WMS_FTEST;

SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT01';
SET @IN_USERID = 'EDI';
SET @IN_Language = 'en';
SET @IN_CustomerId = 'HPK';
SET @IN_orderNo = 'HPK_ORDERNO000000034';
SET @IN_tariffMaster = 'BIL00036';
CALL CML_BILLHOSTD(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_orderNo, @IN_tariffMaster);