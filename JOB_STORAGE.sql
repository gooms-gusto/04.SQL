use wms_cml;

SELECT zbcc.organizationId,zbcc.warehouseId,zbcc.customerId,zbcc.udf01 AS cronday,zbccd.spName,zbccd.lottable03 AS period
  FROM Z_BAS_CUSTOMER_CUSTBILLING zbcc
  INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
  ON zbcc.organizationId = zbccd.organizationId
  AND zbcc.lotatt01=zbccd.idGroupSp
  WHERE zbcc.organizationId='OJV_CML'
  AND IFNULL(zbcc.udf01,'') <> '' AND zbccd.lottable02 = 'no.sql' ; 



SELECT * FROM Z_BAS_CUSTOMER_CUSTBILLING zbcc;


SELECT * FROM Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd;


-- Ensure the MySQL Event Scheduler is ON (one-time setup)
SET GLOBAL event_scheduler = ON;

-- Akbar IT-WH 2025
DELIMITER $$ 
CREATE EVENT `CML_Event_ProcessBillingCML_STORAGE`
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
  BEGIN
    CALL CML_BIL_STORAGE_JOB_NW();
  END$$ 
DELIMITER ;


SELECT * FROM Z_JOB_EXECUTION_STORAGE_LOG;