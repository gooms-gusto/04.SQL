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
-- Create trigger `TRG_VAL_DOUBLE_WAVE`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER TRG_VAL_DOUBLE_WAVE
BEFORE INSERT
ON DOC_LOADING_HEADER
FOR EACH ROW
BEGIN

  DECLARE errorMessage varchar(255);
  DECLARE status_asn varchar(2);


  IF EXISTS (SELECT
        1
      FROM DOC_LOADING_HEADER dlh
        INNER JOIN DOC_WAVE_HEADER dwh
          ON (dlh.organizationId = dwh.organizationId
          AND dlh.warehouseId = dwh.warehouseId
          AND dlh.waveNo = dwh.waveNo)
      WHERE dwh.waveStatus NOT IN ('99')
      AND dlh.waveNo = new.waveNo) THEN
    SET errorMessage = CONCAT('Cannot create loading list ', new.waveNo, ' still not close!');
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = errorMessage;
  END IF;

END
$$

DELIMITER ;
-- No objects to export