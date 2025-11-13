USE WMS_FTEST;

SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT01';
SET @IN_UserId = 'UDFTIMER';
SET @IN_languageId ='en';
SET @IN_locId = 'PFA-01-02';
SET @IN_SKU = '000000000000153221';
SET @IN_QtyEAIn = '30';
SET @r_returnVal = '';
SET @OUT_returnCode ='';
CALL Z_CHECKOVERPALLETINLOC(@IN_organizationId, @IN_warehouseId, @IN_UserId, @IN_languageId, @IN_locId, @IN_SKU, @IN_QtyEAIn, @r_returnVal, @OUT_returnCode);
SELECT
  @r_returnVal,
  @OUT_returnCode;