USE WMS_FTEST;

DROP PROCEDURE IF EXISTS CML_VAL_ALERT_ARRIVAL;

DELIMITER $$

CREATE
DEFINER = 'sa'@'%'
PROCEDURE CML_VAL_ALERT_ARRIVAL (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_userId varchar(20),
IN IN_languageId varchar(20),
IN IN_Input1 varchar(20),
IN IN_Input2 varchar(20),
IN IN_Input3 varchar(20),
IN IN_Input4 varchar(20),
IN IN_Input5 varchar(20),
INOUT OUT_returnCode varchar(1000))
ENDPROC:
  BEGIN
    DECLARE v_Dock varchar(10);
    DECLARE v_loc varchar(20);
    DECLARE v_row_pass int;
    DECLARE v_row_data int;
    DECLARE v_vehicleNo varchar(30);
    DECLARE v_driver varchar(30);
    DECLARE errorMessage varchar(255);
    DECLARE OUT_Return_Code varchar(1000);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      GET DIAGNOSTICS CONDITION 1
      @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT, @p3 = MYSQL_ERRNO, @p4 = TABLE_NAME, @p5 = COLUMN_NAME;
      ROLLBACK;
      SET OUT_returnCode = CONCAT('999#CML_REOPENLDL', IFNULL(@p1, ''), IFNULL(@p2, ''), IFNULL(@p3, ''), IFNULL(@p4, ''), IFNULL(@p5, ''));
      SELECT
        OUT_returnCode,
        IN_ldlNo;
    END;


    IF IN_warehouseId='CBT01' AND  IN_Input1 NOT IN ('CDE','CDD','CON-20',
'CON-40','DUMPTRUCK','FORKLIFT','FUSO','TRONTON','WINGBOX','VAN','PICKUP','MOTOR','PRIVATECAR') THEN
    BEGIN

      SET errorMessage = CONCAT('ALERT: This Vehicle not allowed in this warehouse!');
--       SIGNAL SQLSTATE '45000'
--       SET MESSAGE_TEXT = errorMessage;
        SET OUT_returnCode = errorMessage;
        LEAVE ENDPROC;
    END;
    ELSE
       SET OUT_returnCode = '000';
    END IF;

  END
$$

DELIMITER ;