--
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

DELIMITER $$

--
-- Create event `CML_Event_ProcessBillingCML_BILLHISTD_TYPE2()`
--
CREATE 
	DEFINER = 'mysql.sys'@'%'
EVENT `CML_Event_ProcessBillingCML_BILLHISTD_TYPE2()`
	ON SCHEDULE EVERY '30' MINUTE
	STARTS '2025-08-28 13:09:11'
	DO 
BEGIN
   CALL Z_SP_ProcessBillingCML_BILLHISTD_TYPE2();
END
$$

ALTER 
	DEFINER = 'mysql.sys'@'%'
EVENT `CML_Event_ProcessBillingCML_BILLHISTD_TYPE2()`
	ENABLE
$$

DELIMITER ;