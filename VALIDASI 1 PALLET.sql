-- 
-- Set character set the client will use to send SQL statements to the server
--

DROP PROCEDURE IF EXISTS Z_CHECKOVERPALLETINLOC;

SET NAMES 'utf8';

--
-- Set default database
--
USE WMS_FTEST;

DELIMITER $$

--
-- Create procedure `Z_CHECKOVERPALLETINLOC`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE Z_CHECKOVERPALLETINLOC (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_UserId varchar(30),
IN IN_languageId varchar(20),
IN IN_locId varchar(30),
IN IN_SKU varchar(30),
IN IN_QtyEAIn decimal(23, 8),
OUT r_returnVal decimal(23, 8),
INOUT OUT_returnCode varchar(1000))
BEGIN
  -- Declare variables to store data from each row
  DECLARE done int DEFAULT FALSE;
  DECLARE v_locationId varchar(255);  -- Adjust lengths as needed
  DECLARE v_traceId varchar(255);
  DECLARE v_customerId varchar(255);
  DECLARE v_sku varchar(255);
  DECLARE v_qtyStock int;
  DECLARE v_muid varchar(255);
  DECLARE v_qtyPallet int;
  DECLARE v_qtyPercentage decimal(10, 2); -- Decimal for percentage
  DECLARE v_qtyPercentageQtyIn decimal(10, 2); -- Decimal for percentage qty In
  DECLARE v_totalperseninstock decimal(10, 2); -- Decimal for percentage qty In
  DECLARE v_packId varchar(255);
  DECLARE v_sum_percentage int;
  -- Declare the cursor
  DECLARE cur_inventory CURSOR FOR
  SELECT
    INVID.locationId,
    INVID.TRACEID,
    INVID.customerId,
    INVID.SKU,
    INVID.qty AS qtystock,
    INVID.muid,
    bpd.qty AS qtypallet,
    ((INVID.qty / bpd.qty) * 100) AS qtypercentage,
    bp.PACKID
  FROM INV_LOT_LOC_ID INVID
    INNER JOIN BAS_SKU bs
      ON (INVID.organizationId = bs.organizationId
      AND INVID.customerId = bs.customerId
      AND INVID.SKU = bs.SKU)
    INNER JOIN BAS_SKU_MULTIWAREHOUSE bsm
      ON (bs.organizationId = bsm.organizationId
      AND bs.customerId = bsm.customerId
      AND bs.SKU = bsm.SKU
      AND INVID.warehouseId = bsm.warehouseId)
    INNER JOIN BAS_PACKAGE bp
      ON bsm.organizationId = bp.organizationId
      AND bsm.PACKID = bp.PACKID
      AND bsm.customerId = bp.customerId
    INNER JOIN BAS_PACKAGE_DETAILS bpd
      ON bp.organizationId = bpd.organizationId
      AND bp.PACKID = bpd.PACKID
      AND bp.customerId = bpd.customerId
  WHERE INVID.organizationId = IN_organizationId
  AND INVID.warehouseId = IN_warehouseId
  AND bpd.packUom = 'PL'
  AND INVID.locationId = IN_locId
  AND INVID.qty > 0;

  -- Declare continue handler to exit the loop when no more rows
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  -- Open the cursor
  OPEN cur_inventory;


  SET v_sum_percentage = 0;


-- Loop through the results
read_loop:

  LOOP
    -- Fetch data into variables
    FETCH cur_inventory INTO
    v_locationId,
    v_traceId,
    v_customerId,
    v_sku,
    v_qtyStock,
    v_muid,
    v_qtyPallet,
    v_qtyPercentage,
    v_packId;

    -- Check if we're done
    IF done THEN
      LEAVE read_loop;
    END IF;

    SET v_sum_percentage = v_sum_percentage + v_qtyPercentage;



  END LOOP;


  SELECT
    (IN_QtyEAIn / bpd.qty) * 100 INTO v_qtyPercentageQtyIn
  FROM BAS_PACKAGE bp
    INNER JOIN BAS_PACKAGE_DETAILS bpd
      ON bp.organizationId = bpd.organizationId
      AND bp.PACKID = bpd.PACKID
      AND bp.customerId = bpd.customerId
    INNER JOIN BAS_SKU_MULTIWAREHOUSE bsm
      ON bp.organizationId = bsm.organizationId
      AND bpd.organizationId = bsm.organizationId
      AND bpd.customerId = bsm.customerId
      AND bpd.PACKID = bsm.PACKID
      AND bsm.organizationId = IN_organizationId
      AND bsm.warehouseId = IN_warehouseId
      AND bpd.packUom = 'PL'
      AND bsm.SKU = IN_SKU;


  SET v_totalperseninstock = v_qtyPercentageQtyIn + v_sum_percentage;

  IF EXISTS (SELECT
        1
      FROM BAS_SKU_MULTIWAREHOUSE 
      WHERE organizationId = @IN_organizationId
      AND SKU = IN_SKU) THEN

    IF (v_totalperseninstock > 100) THEN
      SET r_returnVal = v_totalperseninstock;
      SET OUT_returnCode = '999';
        ELSE
      SET r_returnVal = v_totalperseninstock;
      SET OUT_returnCode = '000';
    END IF;
  ELSE
    SET OUT_returnCode = '888';
  END IF;
  -- Close the cursor
  CLOSE cur_inventory;
END
$$

DELIMITER ;