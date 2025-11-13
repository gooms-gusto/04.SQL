-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE WMS_FTEST;

DELIMITER $$

--
-- Create procedure `CML_REOPENLDL`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_REOPENLDL (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_userId varchar(20),
IN IN_languageId varchar(20),
IN IN_ldlNo varchar(30),
INOUT OUT_returnCode varchar(1000))
ENDPROC:
  BEGIN
    DECLARE OUT_ReturnNo varchar(40);
    DECLARE R_CurrentTime timestamp;
    DECLARE r_Count int;
    DECLARE r_CountExist int;
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
    IF IFNULL(IN_ldlNo, '') != '' THEN
      SET OUT_returnCode = '000';


      -- check order cancel or close
      SELECT
        COUNT(1)
      FROM DOC_LOADING_HEADER doh
      WHERE doh.ldlNo = IN_ldlNo
      AND organizationId = IN_organizationId
      AND warehouseId = IN_warehouseId
      AND doh.ldlStatus NOT IN ('99') INTO r_Count;


      IF r_Count > 0 THEN
        SET OUT_returnCode = 'Loading list cannot change!';
        LEAVE ENDPROC;
      END IF;



      START TRANSACTION;
        SET OUT_Return_Code = '*_*';
        SET R_CurrentTime = NOW();

        -- update SO
        UPDATE DOC_LOADING_HEADER
        SET ldlStatus = '00',
            editTime = NOW()
        WHERE organizationId = 'OJV_CML'
        AND warehouseId = IN_warehouseId
        AND ldlNo = IN_ldlNo;



        -- insert to log

        INSERT INTO Z_LogUdfTran (docType
        , docNo
        , userId
        , lottable01
        , lottable02
        , addDate
        , addWho
        , editDate
        , editWho)
          VALUES ('LDL' -- docType - VARCHAR(255)
          , IN_ldlNo -- docNo - VARCHAR(255)
          , IN_userId -- userId - VARCHAR(255)
          , CONCAT('Reopen loading list '), 'CML_REOPENLDL', NOW() -- addDate - DATETIME
          , 'EDI' -- addWho - VARCHAR(255)
          , NOW() -- editDate - DATETIME
          , 'EDI' -- editWho - VARCHAR(255)
          );



      COMMIT;
    END IF;
  END
  $$

DELIMITER ;