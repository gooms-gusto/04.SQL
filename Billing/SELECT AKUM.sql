USE wms_cml;

SELECT
*
FROM Z_BIL_AKUM_DAYS_STORAGE WHERE organizationId='OJV_CML' AND warehouseId='CBT02-B2C' AND customerId='ECMAMA' 
AND chargeType='STRG' AND addWho='CUSTOMBILL';

SELECT
*
FROM Z_BIL_AKUM_DAYS_STORAGE WHERE organizationId='OJV_CML' AND warehouseId='CBT02-B2C' AND customerId='ECMAMA' 
AND chargeType='STRG' AND addWho='CUSTOMBILL';


 DELETE FROM Z_BIL_AKUM_DAYS_STORAGE WHERE  organizationId='OJV_CML' AND warehouseId='CBT02-B2C' AND customerId='ECMAMA' 
 AND chargeType='STRG' AND addWho='CUSTOMBILL' ;


SELECT COUNT(1) FROM Z_InventoryBalance zib WHERE zib.organizationId='OJV_CML' AND 
 zib.StockDate='2025-05-20' AND zib.customerId = 'ECMAMA';


CALL CML_BILLSTORAGE_SAVEDAILY_STORAGEPCS('OJV_CML','CBT02-B2C','CUSTOMBILL', 'en', 'ECMAMAB2C');