USE wms_cml;

SELECT * FROM RUL_MOVE_ARCHIVE WHERE activeFlag='Y' ;

SELECT * FROM RUL_MOVE_ARCHIVE_LOG ORDER BY addTime DESC;

DELETE  FROM RUL_MOVE_ARCHIVE_LOG;


SELECT * FROM RUL_ARCHIVE_TABLE_INFO WHERE 
-- tableName='DOC_ORDER_SUBSERIALNO' AND archiveCatagery = 'OTHER' AND
 activeFlag = 'Y';



 UPDATE RUL_MOVE_ARCHIVE SET organizationId = 'OJV_CML',
 ruleId = 'ARCHIVECML', activeflag = 'Y',batchQty=1,additionalCondition=2020,
 warehouseId = '*', 
 customerId = '*', toDb = 'wms_cml_arv', 
 editTime = NOW()
 WHERE ruleId='ARCHIVECML';



UPDATE RUL_ARCHIVE_TABLE_INFO SET activeFlag = 'N' WHERE organizationId = 'OJV_CML' AND tableName  IN('Z_InventoryBalance');


-- EXECUTE CML_SPCOM_Archive_Process('OJV_CML', 'EN', 'EDI', @OUT); 

USE wms_cml;

SET @IN_organizationId = 'OJV_CML';
SET @IN_language = 'EN';
SET @IN_userId = 'EDI';
SET @OUT_returnCode = '';
CALL CML_SPCOM_Archive_Process(@IN_organizationId, @IN_language, @IN_userId, @OUT_returnCode);
SELECT
  @OUT_returnCode;