USE WMS_FTEST;

DROP PROCEDURE IF EXISTS CML_APPT_GET_TICKET;

DELIMITER $$

CREATE
DEFINER = 'wms_ftest'@'%'
PROCEDURE CML_APPT_GET_TICKET (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_userId varchar(20),
IN IN_languageId varchar(20),
IN IN_arrivalNo varchar(30),
INOUT OUT_ticketNo varchar(1000),
INOUT OUT_returnCode varchar(1000))
ENDPROC:
  BEGIN
    DECLARE OUT_ReturnNo varchar(40);
    DECLARE R_CurrentTime timestamp;
    DECLARE r_Count int;
    DECLARE r_Count_Status int; -- add for validation ignored entrance 17.05.2024
    DECLARE OUT_Return_Code varchar(1000);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      GET DIAGNOSTICS CONDITION 1
      @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT, @p3 = MYSQL_ERRNO, @p4 = TABLE_NAME, @p5 = COLUMN_NAME;
      ROLLBACK;
      SET OUT_returnCode = CONCAT('999#CML_APPT_GET_TICKET', IFNULL(@p1, ''), IFNULL(@p2, ''), IFNULL(@p3, ''), IFNULL(@p4, ''), IFNULL(@p5, ''));
      SELECT
        OUT_returnCode,
        IN_arrivalNo;
    END;
    IF IFNULL(IN_arrivalNo, '') != '' THEN
      SET OUT_returnCode = '000';
      SET OUT_ticketNo = '000';

     -- add for validation ignored entrance 17.05.2024

      SELECT COUNT(1) FROM DOC_ARRIVAL_HEADER dah WHERE dah.organizationId = IN_organizationId
      AND dah.warehouseId = IN_warehouseId
      AND dah.arrivalNo = IN_arrivalNo 
      AND dah.arrivalStatus='00' INTO r_Count_Status;
          IF r_Count_Status > 0 THEN
        SET OUT_returnCode = 'Please set status to Entrance!';
        LEAVE ENDPROC;
      END IF;

      SELECT
        COUNT(1)
      FROM DOC_ARRIVAL_PASSID
      WHERE organizationId = IN_organizationId
      AND warehouseId = IN_warehouseId
      AND arrivalNo = IN_arrivalNo INTO r_Count;

      IF r_Count > 0 THEN
        SET OUT_returnCode = 'Ticket Has Already Been Issued';
        LEAVE ENDPROC;
      END IF;

      START TRANSACTION;
        SET OUT_Return_Code = '*_*';
        SET R_CurrentTime = NOW();
        CALL SPCOM_GetIDSequence_NEW(IN_organizationId, In_warehouseID, IN_languageId, 'TICKETNO', OUT_ReturnNo, OUT_Return_Code);

        IF SUBSTRING(OUT_Return_Code, 1, 3) <> '000' THEN
          ROLLBACK;
          LEAVE ENDPROC;
        END IF;

        SET OUT_ticketNo = OUT_ReturnNo;


        INSERT INTO DOC_ARRIVAL_PASSID (organizationId, warehouseId, arrivalNo, cardSerialNo, cardId, issueTime, udf01, addWho, addTime, editWho, editTime)
          VALUES (IN_organizationId, IN_warehouseId, IN_arrivalNo, OUT_ticketNo, OUT_ticketNo, R_CurrentTime, 'N', IN_userId, R_CurrentTime, IN_userId, R_CurrentTime);
      COMMIT;
    END IF;
  END
$$

DELIMITER ;