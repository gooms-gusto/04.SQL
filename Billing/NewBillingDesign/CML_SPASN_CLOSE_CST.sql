USE WMS_FTEST;

DROP PROCEDURE IF EXISTS CML_SPASN_CLOSE_CST;

DELIMITER $$

CREATE
DEFINER = 'wms_ftest'@'%'
PROCEDURE CML_SPASN_CLOSE_CST (IN IN_organizationId varchar(20),
IN IN_Warehouse varchar(20),
IN IN_SONO varchar(100),
IN IN_ASNSplit varchar(120),
IN IN_Userid varchar(100),
OUT OUT_returnCode varchar(1000))
END_PROC:
  BEGIN
    DECLARE l_customerId varchar(30);
    DECLARE done int DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      GET DIAGNOSTICS CONDITION 1 @p1 = RETURNED_SQLSTATE,
      @p2 = MESSAGE_TEXT,
      @p3 = MYSQL_ERRNO,
      @p4 = TABLE_NAME,
      @p5 = COLUMN_NAME;
      ROLLBACK;
      SET OUT_ReturnCode = CONCAT(
      '999#CML_SPASN_CLOSE_CST,',
      IFNULL(@p1, ''),
      ',',
      IFNULL(@p2, ''),
      ',',
      IFNULL(@p3, ''),
      ',',
      IFNULL(@p4, ''),
      ',',
      IFNULL(@p5, '')
      );
      SELECT
        OUT_ReturnCode AS error;
    END;

    BEGIN
     -- Validate 3PL_CUST

SELECT doh.customerId INTO l_customerId
        FROM DOC_ASN_HEADER doh INNER JOIN
        BSM_CONFIG_RULES bcr
         ON (doh.customerID=bcr.customerId)
        WHERE
         bcr.configId = '3PL_CUST'
        AND bcr.configValue = 'Y'
        AND bcr.activeFlag = 'Y'
        AND doh.warehouseId=IN_Warehouse
        AND doh.asnNo=IN_SONO;

     IF (LENGTH( l_customerId> 0)) THEN
        

      INSERT INTO CML_MIDDLEWARE_CST(organizationId,warehouseId,customerId,transactionType,docNo,status,addWho,addTime,udf01)
      VALUES('OJV_CML',IN_Warehouse,l_customerId,'ASN',IN_SONO,'99','EDI',NOW(),'N');
      SET OUT_returnCode = '000';
      COMMIT;
      END IF;
    END;



  END
$$

DELIMITER ;