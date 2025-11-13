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
-- Create trigger `CML_CHECK_VOLUMELOC_RCV`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER CML_CHECK_VOLUMELOC_RCV
BEFORE INSERT
ON INV_LOT_LOC_ID
FOR EACH ROW
BEGIN
  DECLARE r_returnVal decimal(23, 8);
  DECLARE OUT_returnCode varchar(1000);

  IF (NEW.oprseqflag LIKE '%WRF_H5INB01006%')
    OR (NEW.oprseqflag LIKE '%A2002%')
    OR (NEW.oprseqflag LIKE '%STDRCVPLAKB%')
    OR (NEW.oprseqflag LIKE '%WRF_H5INB010006%') THEN


    SET @IN_organizationId = NEW.organizationId;
    SET @IN_warehouseId = NEW.warehouseId;
    SET @IN_locId = NEW.locationId;
    SET @IN_SKU = NEW.sku;
    SET @IN_QtyEAIn = NEW.qty;
    SET @returncode = '';
    CALL Z_CHECKOVERPALLETINLOC(@IN_organizationId, @IN_warehouseId, @IN_locId, @IN_SKU, @IN_QtyEAIn, @returncode);




  END IF;
END
$$

--
-- Create trigger `CML_CHECK_VOLUMELOC_PUTAWAY`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER CML_CHECK_VOLUMELOC_PUTAWAY
AFTER UPDATE
ON TSK_TASKLISTS
FOR EACH ROW
BEGIN
  DECLARE errorMessage varchar(255);

  IF (NEW.oprSeqFlag LIKE '%WRF_H5INB01006%')
    OR (NEW.oprSeqFlag LIKE '%A2002%')
    OR (NEW.oprSeqFlag LIKE '%STDRCVPLAKB%')
    OR (NEW.oprSeqFlag LIKE '%WRF_H5INB010006%') THEN

    IF NEW.taskProcess = '99'
      AND OLD.taskProcess <> '99'
      AND OLD.taskType = 'PA' THEN
      SET @IN_organizationId = OLD.organizationId;
      SET @IN_warehouseId = OLD.warehouseId;
      SET @IN_UserId = 'UDFTIMER';
      SET @IN_languageId = 'en';
      SET @IN_locId = NEW.planToLocation;
      SET @IN_SKU = NEW.SKU;
      SET @IN_QtyEAIn = NEW.fmQty_Each;
      CALL Z_CHECKOVERPALLETINLOC(@IN_organizationId, @IN_warehouseId, @IN_UserId, @IN_languageId, @IN_locId, @IN_SKU, @IN_QtyEAIn);

    END IF;

  END IF;

END
$$

DELIMITER ;