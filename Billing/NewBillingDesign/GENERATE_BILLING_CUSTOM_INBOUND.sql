USE WMS_FTEST;

DROP TRIGGER IF EXISTS GENERATE_BILLING_CUSTOM_INBOUND;

DELIMITER $$

CREATE
DEFINER = 'sa'@'localhost'
TRIGGER GENERATE_BILLING_CUSTOM_INBOUND
AFTER UPDATE
ON DOC_ASN_HEADER
FOR EACH ROW
BEGIN
  DECLARE errorMessage varchar(255);
  IF NEW.asnStatus = '99' THEN

    SET @IN_organizationId = 'OJV_CML';
    SET @IN_warehouseId = NEW.warehouseId;
    SET @IN_USERID = 'EDI';
    SET @IN_Language = 'EN';
    SET @IN_CustomerId = NEW.customerId;
    SET @IN_asnNo = NEW.asnNo;
    SET @OUT_returnCode = '';
    CALL CML_ASNCLOSEBILLAKB(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_asnNo, @OUT_returnCode);

    SET errorMessage = CONCAT('SP Error Billing custom');
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = errorMessage;

  END IF;
END
$$

DELIMITER ;