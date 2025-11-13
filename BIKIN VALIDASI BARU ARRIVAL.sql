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
-- Create trigger `BEFORE_UPDATE_ARRIVAL_CLOSE`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER BEFORE_UPDATE_ARRIVAL_CLOSE
BEFORE UPDATE
ON DOC_ARRIVAL_HEADER
FOR EACH ROW
BEGIN
  DECLARE errorMessage varchar(255);
  DECLARE status_asn varchar(2);
  SET errorMessage = CONCAT('Cannot change arrival status to Leave, ASN still not close status!');



  IF new.arrivalstatus = '99' THEN

    SELECT
      A.ASNSTATUS INTO status_asn
    FROM DOC_ASN_HEADER A
      INNER JOIN DOC_APPOINTMENT_DETAILS B
        ON (A.ASNNO = B.PONO)
      INNER JOIN DOC_ARRIVAL_DETAILS C
        ON (B.APPOINTMENTNO = C.APPOINTMENTNO)
    WHERE A.warehouseId = C.warehouseId
    AND C.ARRIVALNO = old.ARRIVALNO
    AND A.warehouseId = old.warehouseId;

    IF status_asn <> '99' THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = errorMessage;
    END IF;
  END IF;
END
$$

DELIMITER ;
-- No objects to export