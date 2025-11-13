USE WMS_FTEST;

DROP PROCEDURE IF EXISTS CML_ALERT_EDT_ARRIVAL;

DELIMITER $$

CREATE
DEFINER = 'wms_ftest'@'%'
PROCEDURE CML_ALERT_EDT_ARRIVAL (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_userId varchar(20),
IN IN_languageId varchar(20),
IN IN_arrivalNo varchar(30),
IN IN_vehicleNo varchar(30),
IN IN_driver varchar(30))
ENDPROC:
  BEGIN
    DECLARE v_Dock varchar(10);
    DECLARE v_loc varchar(20);
    DECLARE v_row_pass int;
    DECLARE v_row_data int;
     DECLARE v_vehicleNo varchar(30);
      DECLARE v_driver varchar(30);
    DECLARE errorMessage varchar(255);

    SELECT
      COUNT(1) INTO v_row_pass
    FROM DOC_ARRIVAL_PASSID dap
    WHERE dap.organizationId = IN_organizationId
    AND dap.warehouseId = IN_warehouseId
    AND dap.arrivalNo = IN_arrivalNo;
    IF (v_row_pass > 0) THEN

      SELECT dap.vehicleNo,dap.driver  INTO v_vehicleNo,v_driver FROM DOC_ARRIVAL_HEADER   dap WHERE dap.organizationId=IN_organizationId
      AND dap.warehouseId=IN_warehouseId AND dap.arrivalNo=IN_arrivalNo;

      
      SELECT COUNT(1)   INTO v_row_data  FROM DOC_ARRIVAL_HEADER dap WHERE dap.organizationId=IN_organizationId
      AND dap.warehouseId=IN_warehouseId AND dap.arrivalNo=IN_arrivalNo AND (LTRIM(RTRIM(UPPER(dap.vehicleNo))) =LTRIM(RTRIM(UPPER(IN_vehicleNo)))  
      AND LTRIM(RTRIM(UPPER(dap.driver)))=LTRIM(RTRIM(UPPER(IN_driver))));

      IF (v_row_data = 0) THEN
       SET errorMessage = CONCAT('Cannot edit vehicle and driver name after print ticket ');
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = errorMessage;
       END IF;

     
    END IF;





  END
$$

DELIMITER ;