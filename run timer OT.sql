USE WMS_FTEST;

SET @IN_warehouseId = 'CBT01';
SET @IN_userId = 'UDFTIMER';
SET @OUT_returnCode = '';
CALL OJV_CML_SPUDF_Process1(@IN_warehouseId, @IN_userId, @OUT_returnCode);
SELECT
  @OUT_returnCode;


SELECT bth.udf01 FROM BIL_TARIFF_HEADER bth;

UPDATE BIL_TARIFF_HEADER
set udf01='1600', editTime=NOW();
