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
-- Create procedure `CML_ASSIGN_STG_LOCATIONS`
--
CREATE
DEFINER = 'wms_cml'@'%'
PROCEDURE CML_ASSIGN_STG_LOCATIONS (IN IN_organizationId varchar(20),
IN IN_warehouseId varchar(20),
IN IN_userId varchar(40),
IN IN_waveNo varchar(20),
IN IN_orderNo varchar(20),
OUT OUT_assortingStation varchar(1000),
OUT OUT_stageAlloc_Code varchar(1000),
OUT OUT_returnCode varchar(1000))
BEGIN
  DECLARE v_customerId,
          v_orderType,
          v_orderno varchar(20);
  DECLARE OUT_stageAlloc_Code varchar(20);
  DECLARE finished integer DEFAULT 0;
  DECLARE cur_orders CURSOR FOR
  SELECT
    o.orderNo,
    o.orderType,
    o.customerId
  FROM DOC_WAVE_DETAILS w
    INNER JOIN DOC_ORDER_HEADER o
      ON w.orderNo = o.OrderNo
      AND w.WAVENO = o.WAVENO
      AND w.organizationId = o.organizationId
      AND w.warehouseId = o.warehouseId
  WHERE (w.waveno = IFNULL(IN_waveNo, '')
  OR o.orderNo = IFNULL(IN_orderNo, ''))
  AND w.organizationId = IN_organizationId
  AND w.warehouseId = IN_warehouseId;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
  IF (IFNULL(IN_waveNo, '') <> ''
    OR IFNULL(IN_orderNo, '') <> '') THEN
    OPEN cur_orders;
  getordRec:
    LOOP
      FETCH cur_orders INTO v_orderno, v_orderType, v_customerId;
      IF finished = 1 THEN
        LEAVE getordRec;
      ELSE
      BEGIN
        IF v_orderType IN ('Inter-warehouse transfer', 'RT') THEN
          SET OUT_assortingStation = '000';
          CALL CML_ASSIGN_DOCKDOOR_STG_LOC(IN_organizationId, IN_warehouseId, IN_waveNo, IN_orderNo, OUT_stageAlloc_Code, OUT_returnCode);
        ELSE
          IF v_customerId IN ('ZAP') THEN
            SET OUT_stageAlloc_Code = '000';
            CALL CML_GET_SORTING_STATION(IN_organizationId, IN_warehouseId, IN_waveNo, IN_orderNo, IN_userId, OUT_assortingStation, OUT_returnCode);
          ELSEIF v_customerId IN ('BCA') THEN
            SET OUT_assortingStation = '000';
            SET OUT_stageAlloc_Code = '000';
            CALL CML_ASSIGN_CUSTSORT_STG_LOC(IN_organizationId, IN_warehouseId, IN_waveNo, IN_orderNo, OUT_returnCode);
          ELSE
            SET OUT_assortingStation = '000';
            CALL CML_ASSIGN_DOCKDOOR_STG_LOC(IN_organizationId, IN_warehouseId, IN_waveNo, IN_orderNo, OUT_stageAlloc_Code, OUT_returnCode);
          END IF;
        END IF;
      END;
      END IF;
    END LOOP getordRec;
    CLOSE cur_orders;
    SET OUT_returnCode = '000';
  END IF;
END
$$

DELIMITER ;