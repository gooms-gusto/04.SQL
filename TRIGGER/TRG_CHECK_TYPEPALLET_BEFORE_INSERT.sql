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
-- Create trigger `TRG_CHECK_TYPEPALLET_BEFORE_INSERT`
--
CREATE
DEFINER = 'mysql.sys'@'%'
TRIGGER TRG_CHECK_TYPEPALLET_BEFORE_INSERT
BEFORE INSERT
ON INV_LOT_LOC_ID
FOR EACH ROW
FOLLOWS TRG_CHECK_OVERPALLET_BEFORE_INSERT
BEGIN
  DECLARE v_return_code varchar(3);
  DECLARE v_error_message varchar(255);

  -- Hanya lakukan validasi jika qty > 0
  IF NEW.qty > 0
    AND NEW.customerId IN ('PT.ABC') THEN
    -- Panggil stored procedure untuk validasi
    CALL CML_SP_CHECK_OVER_TYPEPALLET(NEW.organizationId,
    NEW.warehouseId,
    NEW.locationId,
    NEW.qty,
    NEW.sku,
    NEW.customerId,
    NEW.lotNum,
    v_return_code);

    -- Jika return code bukan 000, lempar error
    IF v_return_code = '444' THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error LOC:Over Type Pallet';
    END IF;
  END IF;
END
$$

DELIMITER ;