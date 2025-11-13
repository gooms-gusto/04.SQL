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
-- Create trigger `TRG_CHECK_OVERPALLET_BEFORE_INSERT`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER TRG_CHECK_OVERPALLET_BEFORE_INSERT
BEFORE INSERT
ON INV_LOT_LOC_ID
FOR EACH ROW
BEGIN
  DECLARE v_returnCode varchar(3);
  DECLARE v_message varchar(500);
  DECLARE v_currentPalletUsage decimal(18, 8);
  DECLARE v_incomingPallet decimal(18, 8);
  DECLARE v_totalPalletAfter decimal(18, 8);
  DECLARE v_maxPalletCapacity decimal(18, 8);
  DECLARE v_percentageAfter decimal(18, 8);
  DECLARE v_errorMessage varchar(1000);

  -- Hanya cek jika qty > 0 dan bukan lokasi receiving
  IF NEW.qty > 0
    AND NEW.locationId NOT LIKE '%RCV%'
    AND NEW.customerId NOT IN ('SMART_SBY') THEN
    -- Panggil stored procedure untuk cek over pallet
    CALL CML_SP_CHECK_OVER_PALLET(NEW.organizationId,
    NEW.warehouseId,
    NEW.locationId,
    NEW.qty,
    NEW.sku,
    NEW.customerId,
    v_returnCode,
    v_message,
    v_currentPalletUsage,
    v_incomingPallet,
    v_totalPalletAfter,
    v_maxPalletCapacity,
    v_percentageAfter);

    -- Jika return code 111 (over pallet), block insert
    IF v_returnCode = '111' THEN
      SET v_errorMessage = CONCAT('OVER PALLET LOC:', NEW.locationId, ' ', v_message);
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_errorMessage;
    END IF;

  END IF;
END
$$

DELIMITER ;