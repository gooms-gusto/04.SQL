USE wms_cml;

DROP PROCEDURE IF EXISTS Z_CHECK_LDLEXISTAPPDOC;

DELIMITER $$

CREATE
DEFINER = 'sa'@'localhost'
PROCEDURE Z_CHECK_LDLEXISTAPPDOC (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_UserId varchar(30),
IN IN_languageId varchar(20),
IN IN_LDLNO varchar(30),
OUT r_returnVal varchar(40),
INOUT OUT_returnCode varchar(1000))
ENDPROC:
  BEGIN
    DECLARE countldl int(100);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      GET DIAGNOSTICS CONDITION 1
      @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT, @p3 = MYSQL_ERRNO, @p4 = TABLE_NAME, @p5 = COLUMN_NAME;
      ROLLBACK;
      SET OUT_returnCode = CONCAT('999#Z_CHECK_LDLEXISTAPPDOC', IFNULL(@p1, ''), IFNULL(@p2, ''), IFNULL(@p3, ''), IFNULL(@p4, ''), IFNULL(@p5, ''));
    END;


    SET countldl := 0;


    SELECT COUNT(1) INTO countldl
FROM DOC_APPOINTMENT_DETAILS
WHERE organizationId=IN_organizationId AND warehouseId=IN_warehouseId AND docType='LOAD' AND docNo=IN_LDLNO;

    IF countldl > 0 THEN
      SET r_returnVal = 'N';
     SET OUT_returnCode = 'Loading List Number already created on appointment!';
    ELSE
      SET r_returnVal = 'Y';
      SET OUT_returnCode = '000';
    END IF;

  END
$$

DELIMITER ;