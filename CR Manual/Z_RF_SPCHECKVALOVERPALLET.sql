USE WMS_FTEST;

DROP PROCEDURE IF EXISTS Z_RF_SPCHECKVALOVERPALLET;

DELIMITER $$

CREATE
DEFINER = 'sa'@'localhost'
PROCEDURE Z_RF_SPCHECKVALOVERPALLET (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_UserId varchar(30),
IN IN_languageId varchar(20),
IN IN_locId varchar(30),
OUT r_returnVal varchar(40),
INOUT OUT_returnCode varchar(1000))
ENDPROC:
  BEGIN
    DECLARE countTrace int(100);
    DECLARE countPLcount int(100);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      GET DIAGNOSTICS CONDITION 1
      @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT, @p3 = MYSQL_ERRNO, @p4 = TABLE_NAME, @p5 = COLUMN_NAME;
      ROLLBACK;
      SET OUT_returnCode = CONCAT('999#Z_RF_SPCHECKVALOVERPALLET', IFNULL(@p1, ''), IFNULL(@p2, ''), IFNULL(@p3, ''), IFNULL(@p4, ''), IFNULL(@p5, ''));
    END;


    SET countPLcount := 0;
    SET countTrace := 0;

    SELECT
      COUNT(illi.traceId),
      IFNULL(bl.plCount, 0) INTO countTrace, countPLcount
    FROM INV_LOT_LOC_ID illi
      INNER JOIN BAS_LOCATION bl
        ON illi.organizationId = bl.organizationId
        AND illi.warehouseId = bl.warehouseId
        AND illi.locationId = bl.locationId
        AND bl.mix_lotFlag = 'N'
        AND bl.mix_flag = 'N'
    WHERE illi.organizationId = 'OJV_CML'
    AND illi.warehouseId = IN_warehouseId
    AND bl.locationId = IN_locId
    AND illi.qty > 0
    AND bl.locationCategory IN ('SD');


    IF countTrace >= countPLcount AND countPLcount <> 0 THEN
      SET r_returnVal = 'N';
      SET OUT_returnCode = '000';
    ELSE
      SET r_returnVal = 'Y';
      SET OUT_returnCode = '000';
    END IF;


SET OUT_returnCode = '000';

  END
$$

DELIMITER ;