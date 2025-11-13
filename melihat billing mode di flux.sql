SELECT table_name, table_rows FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms_cml' ORDER BY table_rows DESC LIMIT 0,20;



SELECT * FROM wms_cml.Z_InventoryBalance zib LIMIT 1;


SELECT bth.tariffDescr, btd.* FROM BIL_TARIFF_HEADER bth
INNER JOIN BIL_TARIFF_DETAILS btd ON (bth.organizationId = btd.organizationId AND bth.warehouseId = btd.warehouseId AND bth.tariffId = btd.tariffId)
 WHERE DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 7 HOUR)- interval 1 DAY,"%Y-%m-%d") between DATE_FORMAT(DATE(bth.effectiveFrom),"%Y-%m-%d") and DATE_FORMAT(DATE(bth.effectiveTo),"%Y-%m-%d")
 AND btd.chargeCategory='IV';

SELECT DISTINCT(btd.udf04) FROM BIL_TARIFF_HEADER bth
INNER JOIN BIL_TARIFF_DETAILS btd ON (bth.organizationId = btd.organizationId AND bth.warehouseId = btd.warehouseId AND bth.tariffId = btd.tariffId)
 WHERE DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 7 HOUR)- interval 1 DAY,"%Y-%m-%d") between DATE_FORMAT(DATE(bth.effectiveFrom),"%Y-%m-%d") and DATE_FORMAT(DATE(bth.effectiveTo),"%Y-%m-%d")
 AND btd.chargeCategory='IV';


SELECT * FROM BSM_CODE bc WHERE bc.codeType='PLT_TYP'