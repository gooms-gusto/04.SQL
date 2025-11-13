USE WMS_FTEST;

DROP PROCEDURE IF EXISTS CML_UPD_SO_PLT_CDN;

DELIMITER $$

CREATE 
	DEFINER = 'root'@'localhost'
PROCEDURE CML_UPD_SO_PLT_CDN(IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_ContainerID varchar(30),
IN IN_LDLNo varchar(30),
IN IN_PLTCDN varchar(30),
IN IN_CUSTOMERID varchar(50),
IN IN_ORDERNO varchar(50),
INOUT OUT_returnCode varchar(1000))
ENDPROC:
  BEGIN
    DECLARE od_allocationId varchar(10);
    DECLARE od_orderNo varchar(10);
    DECLARE OUT_Return_Code varchar(1000);
    DECLARE OD_CURSORDONE int DEFAULT 0;

    UPDATE ACT_ALLOCATION_DETAILS
    SET udf05 = IN_PLTCDN,
        editTime = NOW()
    WHERE organizationId = IN_organizationId
    AND warehouseId = IN_warehouseId AND customerId=IN_CUSTOMERID
    AND customerId=IN_CUSTOMERID AND orderNo=IN_ORDERNO
    AND pickToTraceId=IN_ContainerID;

    SET OUT_returnCode = '000';
  END
$$

DELIMITER ;