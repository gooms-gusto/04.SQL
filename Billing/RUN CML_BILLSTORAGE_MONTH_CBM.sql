USE wms_cml;

SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT02-B2C';
SET @IN_userId = 'CUSTOMBILL';
SET @IN_language = 'en';
SET @IN_customerId = 'ECMAMAB2C';
CALL CML_BILLSTORAGE_MONTH_CBM('OJV_CML', 'CBT02-B2C', 'CUSTOMBILL', 'en', 'ECMAMAB2C');