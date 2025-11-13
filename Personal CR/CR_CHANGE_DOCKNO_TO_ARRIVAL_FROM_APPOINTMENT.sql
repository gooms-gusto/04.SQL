USE wms_cml;

DROP PROCEDURE IF EXISTS CML_ARRIVAL_UPDATE_DOCNO;

DELIMITER $$

CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_ARRIVAL_UPDATE_DOCNO (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_userId varchar(20),
IN IN_languageId varchar(20),
IN IN_appdocno varchar(30),
IN IN_dockno varchar(10),
IN IN_type varchar(10),
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
      SET OUT_returnCode = CONCAT('999#CML_ARRIVAL_UPDATE_DOCKNO', IFNULL(@p1, ''), IFNULL(@p2, ''), IFNULL(@p3, ''), IFNULL(@p4, ''), IFNULL(@p5, ''));
      SELECT
        OUT_returnCode,
        IN_soNo;
    END;

set r_Count=0;
    IF IFNULL(IN_appdocno, '') != '' THEN
      SET OUT_returnCode = '000';


      -- check order cancel or close
      SELECT
        COUNT(1)
      FROM DOC_APPOINTMENT_HEADER  doh
      WHERE doh.appointmentNo = IN_dockno
      AND organizationId = IN_organizationId
      AND warehouseId = IN_warehouseId
      AND doh.appStatus IN ( '99') INTO r_Count;


      IF r_Count > 0 THEN
        SET OUT_returnCode = 'Appointment doc  cannot change when status closed!';
        LEAVE ENDPROC;
      END IF;


    


      START TRANSACTION;
        SET OUT_Return_Code = '*_*';
        SET R_CurrentTime = NOW();

        -- update SO
    IF EXISTS (SELECT
          1
        FROM DOC_ARRIVAL_HEADER AH
        WHERE AH.arrivalNo in  (SELECT DISTINCT arrivalNo FROM DOC_ARRIVAL_DETAILS WHERE appointmentNo=IN_appdocno AND warehouseId=IN_warehouseId)) THEN

		UPDATE DOC_ARRIVAL_HEADER dh LEFT JOIN
    DOC_ARRIVAL_DETAILS dad ON dh.organizationId = dad.organizationId AND   dh.warehouseId = dad.warehouseId AND dh.arrivalNo = dad.arrivalno
    LEFT JOIN DOC_APPOINTMENT_HEADER dah ON  dad.organizationId = dah.organizationId AND  dad.warehouseId = dah.warehouseId AND dad.appointmentno = dah.appointmentNo
		SET dh.dockNo=dah.dockNo, dh.editTime=NOW()
		WHERE dah.appointmentNo=IN_appdocno AND dah.warehouseId=IN_warehouseId;



    
    END IF;



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
          VALUES ('SO' -- docType - VARCHAR(255)
          , IN_appdocno -- docNo - VARCHAR(255)
          , IN_userId -- userId - VARCHAR(255)
          , CONCAT('Update  Dockno Arrival ', IN_type), 'CML_SO_UPDATE_TYPE', NOW() -- addDate - DATETIME
          , 'EDI' -- addWho - VARCHAR(255)
          , NOW() -- editDate - DATETIME
          , 'EDI' -- editWho - VARCHAR(255)
          );



      COMMIT;
    END IF;
  END
$$

DELIMITER ;