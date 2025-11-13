-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE WMS_FTEST;

DELIMITER $$

--
-- Create trigger `GENERATE_BILLING_CUSTOM_OUTBOUND`
--
CREATE
DEFINER = 'sa'@'localhost'
TRIGGER GENERATE_BILLING_CUSTOM_OUTBOUND
AFTER UPDATE
ON DOC_ORDER_HEADER
FOR EACH ROW
BEGIN
  DECLARE errorMessage varchar(255);
  IF NEW.soStatus = '99' THEN

    SET @IN_organizationId = 'OJV_CML';
    SET @IN_warehouseId = NEW.warehouseId;
    SET @IN_USERID = 'EDI';
    SET @IN_Language = 'EN';
    SET @IN_CustomerId = NEW.customerId;
    SET @IN_orderNo = NEW.orderNo;
    SET @OUT_returnCode = '';
    CALL CML_SOCLOSEBILLAKB(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_orderNo, @OUT_returnCode);

    SET errorMessage = CONCAT('SP Error Billing custom');
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = errorMessage;

  END IF;
END
$$

DELIMITER ;