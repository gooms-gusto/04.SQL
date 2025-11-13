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
-- Create trigger `BEFORE_UPDATE_PREVENT_WAVE_NULL`
--
CREATE
DEFINER = 'root'@'%'
TRIGGER BEFORE_UPDATE_PREVENT_WAVE_NULL
BEFORE UPDATE
ON DOC_LOADING_HEADER
FOR EACH ROW
BEGIN
  DECLARE errorMessage varchar(255);
  IF NEW.warehouseId <> 'CBT02-B2C' THEN
    IF new.waveNo IS NULL
      OR new.waveNo = '' THEN
      SET errorMessage = CONCAT('Wave No Tidak Boleh Kosong');
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = errorMessage;
    END IF;
  END IF;
END
$$

--
-- Create trigger `BEFORE_UPDATE_PREVENT_SAME_VEHICLENO_WITH_SAME_STATUS`
--
CREATE
DEFINER = 'root'@'%'
TRIGGER BEFORE_UPDATE_PREVENT_SAME_VEHICLENO_WITH_SAME_STATUS
BEFORE UPDATE
ON DOC_LOADING_HEADER
FOR EACH ROW
FOLLOWS BEFORE_UPDATE_PREVENT_WAVE_NULL
BEGIN


  DECLARE errorMessage varchar(255);
  IF NEW.warehouseId <> 'CBT02-B2C' THEN
    IF NEW.vehicalNo IN (SELECT
          A.vehicalNo
        FROM DOC_LOADING_HEADER A
        WHERE (NEW.vehicalNo = A.vehicalNo
        AND NEW.warehouseId = A.warehouseId
        AND A.ldlStatus = 00
        AND A.vehicalNo IS NULL)) THEN
      SET errorMessage = CONCAT('Vehicle No ini masih ada Loading List yang belum di Closed, Cek terlebih dahulu');
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = errorMessage;

    END IF;

  END IF;

END
$$

--
-- Create trigger `BEFORE_UPDATE_PREVENT_SAME_WAVE`
--
CREATE
DEFINER = 'root'@'%'
TRIGGER BEFORE_UPDATE_PREVENT_SAME_WAVE
BEFORE UPDATE
ON DOC_LOADING_HEADER
FOR EACH ROW
FOLLOWS BEFORE_UPDATE_PREVENT_SAME_VEHICLENO_WITH_SAME_STATUS
BEGIN
  DECLARE errorMessage varchar(255);
  IF NEW.warehouseId <> 'CBT02-B2C' THEN
    IF NEW.waveNo = (SELECT
          A.waveNo
        FROM DOC_LOADING_HEADER A
        WHERE (NEW.waveNo = A.waveNo
        AND NEW.warehouseId = A.warehouseId
        AND A.ldlStatus = 00
        AND NEW.ldlNo <> A.ldlNo)) THEN
      SET errorMessage = CONCAT('Wave No Tidak Boleh Sama');
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = errorMessage;

    ELSEIF NEW.vehicalNo = (SELECT
          A.vehicalNo
        FROM DOC_LOADING_HEADER A
        WHERE (NEW.vehicalNo = A.vehicalNo
        AND NEW.warehouseId = A.warehouseId
        AND A.ldlStatus = 00
        AND NEW.ldlNo <> A.ldlNo)) THEN
      SET errorMessage = CONCAT('Vehicle No Tidak Boleh Sama');
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = errorMessage;

    END IF;
  END IF;
END
$$

--
-- Create trigger `TRG_DETAIL_LOADINGLIST_UP`
--
CREATE
DEFINER = 'mysql.sys'@'%'
TRIGGER TRG_DETAIL_LOADINGLIST_UP
BEFORE UPDATE
ON DOC_LOADING_HEADER
FOR EACH ROW
FOLLOWS BEFORE_UPDATE_PREVENT_SAME_WAVE
BEGIN


  DECLARE vCount int;
  SET NEW.editTime = NOW();

  IF (NEW.ldlStatus = '99'
    OR NEW.ldlStatus = '60') THEN

    SELECT
      COUNT(1) INTO vCount
    FROM ACT_ALLOCATION_DETAILS aad
      INNER JOIN DOC_ORDER_HEADER doh
        ON (aad.organizationId = doh.organizationId
        AND aad.warehouseId = doh.warehouseId
        AND aad.customerId = doh.customerId
        AND aad.waveNo = doh.waveNo)
    WHERE aad.organizationId = NEW.organizationId
    AND aad.warehouseId = NEW.warehouseId
    AND (aad.udf05 IS NULL
    OR LENGTH(aad.udf05) = 0)
    AND aad.waveNo = NEW.waveNo
    AND aad.customerId IN ('PPG', 'PT.ABC');

    IF (vCount > 0) THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Cannot change status: there is UDF05 Blank/Null';
    END IF;

  END IF;




END
$$

--
-- Create trigger `TRG_DOC_ASN_VAS_BEFORE_UPDATE`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER TRG_DOC_ASN_VAS_BEFORE_UPDATE
BEFORE UPDATE
ON DOC_ASN_VAS
FOR EACH ROW
BEGIN
  DECLARE v_asn_status varchar(2);

  -- Get the ASN status from DOC_ASN_HEADER table
  SELECT
    asnStatus INTO v_asn_status
  FROM DOC_ASN_HEADER
  WHERE organizationId = NEW.organizationId
  AND warehouseId = NEW.warehouseId
  AND asnNo = NEW.asnNo;

  -- Check if ASN status is 99 (closed)
  IF v_asn_status = '99' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'status asn already closed';
  END IF;
END
$$

--
-- Create trigger `TRG_VAS_UPDATE_ON_CLOSED_ASN`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER TRG_VAS_UPDATE_ON_CLOSED_ASN
BEFORE UPDATE
ON DOC_ASN_VAS
FOR EACH ROW
FOLLOWS TRG_DOC_ASN_VAS_BEFORE_UPDATE
BEGIN
  DECLARE v_asn_status varchar(2);

  -- Get the ASN status from DOC_ASN_HEADER table
  SELECT
    asnStatus INTO v_asn_status
  FROM DOC_ASN_HEADER
  WHERE organizationId = NEW.organizationId
  AND warehouseId = NEW.warehouseId
  AND asnNo = NEW.asnNo;

  -- Check if ASN status is 99 (closed)
  IF v_asn_status = '99' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'status asn already closed';
  END IF;
END
$$

--
-- Create trigger `TRG_GENERATE_CARTONGROUP`
--
CREATE
DEFINER = 'root'@'%'
TRIGGER TRG_GENERATE_CARTONGROUP
BEFORE INSERT
ON DOC_ORDER_HEADER
FOR EACH ROW
BEGIN

  IF (new.warehouseID = 'CBT02-B2C') THEN
    SET new.cartonGroup = new.customerId;
  END IF;
END
$$

--
-- Create trigger `TRG_CHECK_DUPLICATE_SO_REF01`
--
CREATE
DEFINER = 'sa'@'%'
TRIGGER TRG_CHECK_DUPLICATE_SO_REF01
BEFORE INSERT
ON DOC_ORDER_HEADER
FOR EACH ROW
FOLLOWS TRG_GENERATE_CARTONGROUP
BEGIN
  DECLARE duplicate int;
  DECLARE actived int;
  SELECT
    COUNT(*) INTO duplicate
  FROM DOC_ORDER_HEADER olds
  WHERE olds.soReference1 = NEW.soReference1
  AND olds.customerId = NEW.customerId
  AND olds.warehouseId = NEW.warehouseId
  AND olds.soStatus <> '90';

  SELECT
    COUNT(1) INTO actived
  FROM BSM_CONFIG_RULES h1
  WHERE 1 = 1
  AND h1.organizationId = NEW.organizationId
  AND h1.configId = 'REF_CHK_SO'
  AND h1.customerId = NEW.customerId
  AND h1.warehouseId = NEW.warehouseId
  AND h1.configValue = 'Y';
  IF duplicate > 0
    AND actived <> 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Duplicate insert key soReference1';
  END IF;
END
$$

--
-- Create trigger `BEFORE_UPDATE_ARRIVAL_CLOSE`
--
CREATE
DEFINER = 'root'@'%'
TRIGGER BEFORE_UPDATE_ARRIVAL_CLOSE
BEFORE UPDATE
ON DOC_ARRIVAL_HEADER
FOR EACH ROW
BEGIN
  DECLARE errorMessage varchar(255);
  DECLARE status_asn varchar(2);

  IF (new.arrivalstatus = 90
    AND old.arrivalstatus > 20) THEN
    IF EXISTS (SELECT
          1
        FROM DOC_ARRIVAL_HEADER AH
        WHERE (AH.ARRIVALNO = old.ARRIVALNO)
        OR (AH.starttime IS NOT NULL)
        OR (AH.endtime IS NOT NULL)) THEN

      SET errorMessage = CONCAT('Cannot cancel arrival, because operation already started');
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = errorMessage;
    END IF;
  END IF;


  IF (new.arrivalstatus = '99') THEN

    IF EXISTS (SELECT
          1
        FROM DOC_ARRIVAL_HEADER AH
        WHERE (AH.ARRIVALNO = old.ARRIVALNO)
        AND (AH.starttime IS NOT NULL)
        AND (AH.endtime IS NOT NULL)
        AND (AH.arrivalStatus <> '00')) THEN

      --       IF (old.ARRIVALTYPE = 'INBOUND') THEN
      --         IF EXISTS (SELECT
      --               1
      --             FROM DOC_ASN_HEADER A
      --               INNER JOIN DOC_APPOINTMENT_DETAILS B
      --                 ON (A.ASNNO = B.PONO)
      --               INNER JOIN DOC_ARRIVAL_DETAILS C
      --                 ON (B.APPOINTMENTNO = C.APPOINTMENTNO)
      --             WHERE A.warehouseId = C.warehouseId
      --             AND C.ARRIVALNO = old.ARRIVALNO
      --             AND A.warehouseId = old.warehouseId
      --             AND A.warehouseId = B.warehouseId
      --             AND A.ASNSTATUS IN ('00', '05', '10')) THEN
      --           SET errorMessage = CONCAT('Cannot change arrival status to Leave, ASN still not received status!');
      --           SIGNAL SQLSTATE '45000'
      --           SET MESSAGE_TEXT = errorMessage;
      --         END IF;
      --       ELSE
      IF (old.ARRIVALTYPE = 'OUTBOUND') THEN
        IF EXISTS (SELECT
              1
            FROM DOC_ARRIVAL_HEADER dah
              INNER JOIN DOC_ARRIVAL_DETAILS dad
                ON (dah.organizationId = dad.organizationId
                AND dah.warehouseId = dad.warehouseId
                AND dah.arrivalNo = dad.arrivalno)
              INNER JOIN DOC_APPOINTMENT_DETAILS dad1
                ON (dad.organizationId = dad1.organizationId
                AND dad.warehouseId = dad1.warehouseId
                AND dad.appointmentno = dad1.appointmentNo)
              INNER JOIN DOC_LOADING_HEADER dlh
                ON (dad1.organizationId = dlh.organizationId
                AND dad1.warehouseId = dlh.warehouseId
                AND dad1.docNo = dlh.ldlNo)
              INNER JOIN DOC_ORDER_HEADER doh
                ON (dlh.organizationId = doh.organizationId
                AND dlh.warehouseId = doh.warehouseId
                AND dlh.waveNo = doh.waveNo)
            WHERE dad.warehouseId = old.warehouseId
            AND dad1.docType = 'LOAD'
            AND dah.arrivalType = 'OUTBOUND'
            AND doh.soStatus NOT IN ('99')
            AND dad.arrivalno = old.ARRIVALNO) THEN
          SET errorMessage = CONCAT('Cannot change arrival status to Leave, SO still not close status!');
          SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = errorMessage;
        END IF;
      END IF;

    ELSE
      SET errorMessage = CONCAT('Please check! status arrival still create or arrival not checkin or checkout process!');
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = errorMessage;
    END IF;
  END IF;
END
$$

--
-- Create trigger `BEFORE_UPDATE_ARRIVAL`
--
CREATE
DEFINER = 'root'@'%'
TRIGGER BEFORE_UPDATE_ARRIVAL
BEFORE UPDATE
ON DOC_ARRIVAL_HEADER
FOR EACH ROW
FOLLOWS BEFORE_UPDATE_ARRIVAL_CLOSE
BEGIN
  DECLARE errorMessage varchar(255);
  DECLARE status_asn varchar(2);

  IF NEW.arrivalStatus = 20 THEN
    --       UPDATE DOC_ARRIVAL_HEADER dah
    IF NEW.warehouseId <> 'PAPAYA' THEN
      SET NEW.entranceTime = NOW();
    --           WHERE dah.organizationId = NEW.organizationId
    --           AND dah.warehouseId = NEW.warehouseId
    --           AND dah.arrivalNo = NEW.arrivalNo;
    END IF;
  END IF;

  IF (new.arrivalstatus = 90
    AND old.arrivalstatus > 20) THEN
    IF EXISTS (SELECT
          1
        FROM DOC_ARRIVAL_HEADER AH
        WHERE (AH.ARRIVALNO = old.ARRIVALNO)
        OR (AH.starttime IS NOT NULL)
        OR (AH.endtime IS NOT NULL)) THEN

      SET errorMessage = CONCAT('Cannot cancel arrival, because operation already started');
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = errorMessage;
    END IF;
  END IF;


  IF (new.arrivalstatus = '99') THEN

    IF EXISTS (SELECT
          1
        FROM DOC_ARRIVAL_HEADER AH
        WHERE (AH.ARRIVALNO = old.ARRIVALNO)
        AND (AH.starttime IS NOT NULL)
        AND (AH.endtime IS NOT NULL)
        AND (AH.arrivalStatus <> '00')) THEN
      SET NEW.leaveTime = NOW();

      --       IF (old.ARRIVALTYPE = 'INBOUND') THEN
      --         IF EXISTS (SELECT
      --               1
      --             FROM DOC_ASN_HEADER A
      --               INNER JOIN DOC_APPOINTMENT_DETAILS B
      --                 ON (A.ASNNO = B.PONO)
      --               INNER JOIN DOC_ARRIVAL_DETAILS C
      --                 ON (B.APPOINTMENTNO = C.APPOINTMENTNO)
      --             WHERE A.warehouseId = C.warehouseId
      --             AND C.ARRIVALNO = old.ARRIVALNO
      --             AND A.warehouseId = old.warehouseId
      --             AND A.warehouseId = B.warehouseId
      --             AND A.ASNSTATUS IN ('00', '05', '10')) THEN
      --           SET errorMessage = CONCAT('Cannot change arrival status to Leave, ASN still not received status!');
      --           SIGNAL SQLSTATE '45000'
      --           SET MESSAGE_TEXT = errorMessage;
      --         END IF;
      --       ELSE
      IF (old.ARRIVALTYPE = 'OUTBOUND') THEN
        IF EXISTS (SELECT
              1
            FROM DOC_ARRIVAL_HEADER dah
              INNER JOIN DOC_ARRIVAL_DETAILS dad
                ON (dah.organizationId = dad.organizationId
                AND dah.warehouseId = dad.warehouseId
                AND dah.arrivalNo = dad.arrivalno)
              INNER JOIN DOC_APPOINTMENT_DETAILS dad1
                ON (dad.organizationId = dad1.organizationId
                AND dad.warehouseId = dad1.warehouseId
                AND dad.appointmentno = dad1.appointmentNo)
              INNER JOIN DOC_LOADING_HEADER dlh
                ON (dad1.organizationId = dlh.organizationId
                AND dad1.warehouseId = dlh.warehouseId
                AND dad1.docNo = dlh.ldlNo)
              INNER JOIN DOC_ORDER_HEADER doh
                ON (dlh.organizationId = doh.organizationId
                AND dlh.warehouseId = doh.warehouseId
                AND dlh.waveNo = doh.waveNo)
            WHERE dad.warehouseId = old.warehouseId
            AND dad1.docType = 'LOAD'
            AND dah.arrivalType = 'OUTBOUND'
            AND doh.soStatus NOT IN ('99')
            AND dad.arrivalno = old.ARRIVALNO) THEN
          SET errorMessage = CONCAT('Cannot change arrival status to Leave, SO still not close status!');
          SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = errorMessage;
        END IF;
      END IF;

    ELSE
      SET errorMessage = CONCAT('Please check! status arrival still create or arrival not checkin or checkout process!');
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = errorMessage;
    END IF;
  END IF;
END
$$

--
-- Create trigger `BEFORE_INSERT_PREVENT_SAME_VEHICLENO_WITH_SAME_STATUS`
--
CREATE
DEFINER = 'root'@'%'
TRIGGER BEFORE_INSERT_PREVENT_SAME_VEHICLENO_WITH_SAME_STATUS
BEFORE INSERT
ON DOC_LOADING_HEADER
FOR EACH ROW
BEGIN
  DECLARE errorMessage varchar(255);

  IF NEW.vehicalNo IN (SELECT
        A.vehicalNo
      FROM DOC_LOADING_HEADER A
      WHERE (NEW.vehicalNo = A.vehicalNo
      AND NEW.warehouseId = A.warehouseId
      AND A.ldlStatus = 00
      AND A.waveNo IS NULL)) THEN
    SET errorMessage = CONCAT('Vehicle No ini masih ada Loading List yang belum di Closed, Cek terlebih dahulu');
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = errorMessage;






  END IF;
END
$$

--
-- Create trigger `BEFORE_INSERT_PREVENT_SAME_WAVE_WITH_SAME_STATUS`
--
CREATE
DEFINER = 'root'@'%'
TRIGGER BEFORE_INSERT_PREVENT_SAME_WAVE_WITH_SAME_STATUS
BEFORE INSERT
ON DOC_LOADING_HEADER
FOR EACH ROW
FOLLOWS BEFORE_INSERT_PREVENT_SAME_VEHICLENO_WITH_SAME_STATUS
BEGIN
  DECLARE errorMessage varchar(255);
  -- IF NEW.warehouseId <> 'CBT02-B2C' THEN
  IF NEW.waveNo IS NULL
    OR NEW.waveNo = '' THEN
    IF NEW.warehouseId <> 'CBT02-B2C' THEN
      SET errorMessage = CONCAT('Wave No Tidak Boleh Kosong');
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = errorMessage;
    END IF;
  ELSEIF NEW.waveNo IN (SELECT
        A.waveNo
      FROM DOC_LOADING_HEADER A
      WHERE (A.organizationId = 'OJV_CML'
      AND NEW.waveNo = A.waveNo
      AND NEW.warehouseId = A.warehouseId)) THEN
    SET errorMessage = CONCAT('Loading List untuk Wave No  ini sudah dibuat');
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = errorMessage;

  ELSEIF NEW.vehicalNo IN (SELECT
        A.vehicalNo
      FROM DOC_LOADING_HEADER A
      WHERE (NEW.vehicalNo = A.vehicalNo
      AND NEW.warehouseId = A.warehouseId
      AND A.ldlStatus = 00)) THEN
    SET errorMessage = CONCAT('Loading List untuk Vehicle No ini sudah dibuat, silahkan Closed Loading List terlebih dahulu');
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = errorMessage;

  END IF;


-- END IF;
END
$$

--
-- Create trigger `update_product_code_before_insert`
--
CREATE
DEFINER = 'mysql.sys'@'%'
TRIGGER update_product_code_before_insert
BEFORE INSERT
ON BIL_CRM_DETAILS
FOR EACH ROW
BEGIN
  IF NEW.ProductCode = '0'
    AND NOT EXISTS (SELECT
        1
      FROM BIL_CRM_DETAILS bcd
      WHERE bcd.organizationId = 'OJV_CML'
      AND bcd.OpportunityId = NEW.OpportunityId
      AND bcd.ProductCode = '1700000145'
      AND bcd.rate = NEW.rate)
    AND NEW.ProductDescr NOT IN ('VAS - Bagging', 'VAS - Wrapping', 'VAS-Wrapping Material', 'VAS-Repacking'
    ) THEN
    SET NEW.ProductCode = '1700000145';
  END IF;
END
$$

--
-- Create trigger `trigger_deletion_act_allocation_details`
--
CREATE
DEFINER = 'root'@'%'
TRIGGER trigger_deletion_act_allocation_details
AFTER DELETE
ON ACT_ALLOCATION_DETAILS
FOR EACH ROW
BEGIN
  INSERT INTO LOG_DELETION_WMS (table_name, column_name, value, process, addTime, editTime)
    VALUES ('ACT_ALLOCATION_DETAILS', 'organizationId||warehouseId||allocationDetailsId', CONCAT(OLD.organizationId, '||', OLD.warehouseId, '||', OLD.allocationDetailsId), 0, NOW(), NOW());
END
$$

--
-- Create trigger `trigger_after_delete_doc_po_header`
--
CREATE
DEFINER = 'root'@'%'
TRIGGER trigger_after_delete_doc_po_header
AFTER DELETE
ON DOC_PO_HEADER
FOR EACH ROW
BEGIN
  INSERT INTO Z_ACT_LOG_DELETION (`tableName`, `value`, `process`, `addTime`, `editTime`)
    VALUES ('DOC_PO_HEADER', CONCAT(OLD.organizationId, '||', OLD.warehouseId, '||', OLD.poNo), 0, NOW(), NOW());
END
$$

--
-- Create trigger `trigger_after_delete_doc_po_details`
--
CREATE
DEFINER = 'root'@'%'
TRIGGER trigger_after_delete_doc_po_details
AFTER DELETE
ON DOC_PO_DETAILS
FOR EACH ROW
BEGIN
  INSERT INTO Z_ACT_LOG_DELETION (`tableName`, `value`, `process`, `addTime`, `editTime`)
    VALUES ('DOC_PO_DETAILS', CONCAT(OLD.organizationId, '||', OLD.warehouseId, '||', OLD.poNo, '||', OLD.poLineNo), 0, NOW(), NOW());
END
$$

--
-- Create trigger `trigger_after_delete_doc_order_header`
--
CREATE
DEFINER = 'sa'@'%'
TRIGGER trigger_after_delete_doc_order_header
AFTER DELETE
ON DOC_ORDER_HEADER
FOR EACH ROW
BEGIN
  INSERT INTO Z_ACT_LOG_DELETION (`tableName`, `value`, `process`, `addTime`, `editTime`)
    VALUES ('DOC_ORDER_HEADER', CONCAT(OLD.organizationId, '||', OLD.warehouseId, '||', OLD.orderNo), 0, NOW(), NOW());
END
$$

--
-- Create trigger `trigger_after_delete_doc_order_details`
--
CREATE
DEFINER = 'sa'@'%'
TRIGGER trigger_after_delete_doc_order_details
AFTER DELETE
ON DOC_ORDER_DETAILS
FOR EACH ROW
BEGIN
  INSERT INTO Z_ACT_LOG_DELETION (`tableName`, `value`, `process`, `addTime`, `editTime`)
    VALUES ('DOC_ORDER_DETAILS', CONCAT(OLD.organizationId, '||', OLD.warehouseId, '||', OLD.orderNo, '||', OLD.orderLineNo), 0, NOW(), NOW());
END
$$

--
-- Create trigger `TRG_VAS_UPDATE_ON_CLOSED_SO`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER TRG_VAS_UPDATE_ON_CLOSED_SO
BEFORE UPDATE
ON DOC_ORDER_VAS
FOR EACH ROW
BEGIN
  DECLARE v_order_status varchar(2);

  -- Get the order status from DOC_ORDER_HEADER table
  SELECT
    soStatus INTO v_order_status
  FROM DOC_ORDER_HEADER
  WHERE organizationId = NEW.organizationId
  AND warehouseId = NEW.warehouseId
  AND ORDERNo = NEW.ORDERNo;

  -- Check if order status is 99 (closed)
  IF v_order_status = '99' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Status ORDER already closed';
  END IF;

END
$$

--
-- Create trigger `TRG_VAS_INSERT_ON_CLOSED_SO`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER TRG_VAS_INSERT_ON_CLOSED_SO
BEFORE INSERT
ON DOC_ORDER_VAS
FOR EACH ROW
BEGIN
  DECLARE v_order_status varchar(2);

  -- Get the order status from DOC_ORDER_HEADER table
  SELECT
    soStatus INTO v_order_status
  FROM DOC_ORDER_HEADER
  WHERE organizationId = NEW.organizationId
  AND warehouseId = NEW.warehouseId
  AND ORDERNo = NEW.ORDERNo;

  -- Check if order status is 99 (closed)
  IF v_order_status = '99' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Status ORDER already closed';
  END IF;

END
$$

--
-- Create trigger `TRG_VAS_INSERT_ON_CLOSED_ASN`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER TRG_VAS_INSERT_ON_CLOSED_ASN
BEFORE INSERT
ON DOC_ASN_VAS
FOR EACH ROW
BEGIN
  DECLARE v_asn_status varchar(2);

  -- Get the ASN status from DOC_ASN_HEADER table
  SELECT
    asnStatus INTO v_asn_status
  FROM DOC_ASN_HEADER
  WHERE organizationId = NEW.organizationId
  AND warehouseId = NEW.warehouseId
  AND asnNo = NEW.asnNo;

  -- Check if ASN status is 99 (closed)
  IF v_asn_status = '99' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Status ASN already closed';
  END IF;

END
$$

--
-- Create trigger `TRG_GENERATE_VALIDATEION_CODE`
--
CREATE
DEFINER = 'root'@'%'
TRIGGER TRG_GENERATE_VALIDATEION_CODE
BEFORE INSERT
ON BAS_LOCATION
FOR EACH ROW
BEGIN
  DECLARE sValidationCode varchar(10);
  DECLARE nCount int;

  SET sValidationCode := '*';

  REPEAT
    SET sValidationCode := FLOOR(RAND() * (999999) + 1);
    SET nCount := 0;
    SELECT
      COUNT(validationCode)
    FROM BAS_LOCATION
    WHERE validationCode = sValidationCode
    LIMIT 1 INTO nCount;
    IF nCount > 0 THEN
      SET sValidationCode := '*';
    END IF;

  UNTIL sValidationCode <> '*'
  END REPEAT;

  SET new.validationCode = sValidationCode;
END
$$

--
-- Create trigger `trg_generateId_z_temp_util_wh`
--
CREATE
DEFINER = 'mysql.sys'@'%'
TRIGGER trg_generateId_z_temp_util_wh
BEFORE INSERT
ON Z_TEMP_UTIL_WH
FOR EACH ROW
BEGIN
  DECLARE v_returnNo varchar(40);
  DECLARE v_returnCode varchar(1000);
  DECLARE v_sequenceName varchar(30);

  -- Set sequence name untuk table Z_TEMP_UTIL_WH
  SET v_sequenceName = 'IDUTILWH';
  -- Initialize return code
  SET v_returnCode = '';

  -- Cek jika utilWhId belum diisi atau NULL
  IF NEW.utilWhId IS NULL
    OR NEW.utilWhId = ''
    OR NEW.utilWhId = '0'
    OR SUBSTRING(NEW.utilWhId, 1, 2) = 'ID' THEN

    SET NEW.utilWhId = FNSPCOM_GetIDSequence('OJV_CML', '*', v_sequenceName);

  END IF;

END
$$

--
-- Create trigger `trg_generateId_z_temp_ot`
--
CREATE
DEFINER = 'mysql.sys'@'%'
TRIGGER trg_generateId_z_temp_ot
BEFORE INSERT
ON Z_TEMP_OT
FOR EACH ROW
BEGIN
  DECLARE v_returnNo varchar(40);
  DECLARE v_returnCode varchar(1000);
  DECLARE v_sequenceName varchar(30);

  -- Set sequence name untuk table Z_TEMP_OT
  SET v_sequenceName = 'IDOVERTIME';
  -- Initialize return code
  SET v_returnCode = '';

  -- Cek jika idOt belum diisi atau NULL
  IF NEW.idOt IS NULL
    OR NEW.idOt = ''
    OR NEW.idOt = '0'
    OR SUBSTRING(NEW.idOt, 1, 2) = 'ID' THEN

    SET NEW.idOt = FNSPCOM_GetIDSequence('OJV_CML', '*', v_sequenceName);

  END IF;



END
$$

--
-- Create trigger `TRG_DETAIL_LOADINGLIST_DEL`
--
CREATE
DEFINER = 'mysql.sys'@'%'
TRIGGER TRG_DETAIL_LOADINGLIST_DEL
BEFORE DELETE
ON DOC_LOADING_DETAILS
FOR EACH ROW
BEGIN

  UPDATE ACT_ALLOCATION_DETAILS
  SET udf05 = NULL,
      editTime = NOW()
  WHERE organizationId = OLD.organizationId
  AND warehouseId = OLD.warehouseId
  AND OLD.allocationDetailsId = OLD.allocationDetailsId
  AND orderNo = OLD.orderNo
  AND pickToTraceId = OLD.traceId;


END
$$

--
-- Create trigger `TRG_CHECK_PALLET_VALIDATION_BEFORE_INSERT`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER TRG_CHECK_PALLET_VALIDATION_BEFORE_INSERT
BEFORE INSERT
ON INV_LOT_LOC_ID
FOR EACH ROW
BEGIN
  -- Variables for over pallet check
  DECLARE v_overPallet_returnCode varchar(3);
  DECLARE v_overPallet_message varchar(500);
  DECLARE v_currentPalletUsage decimal(18, 8);
  DECLARE v_incomingPallet decimal(18, 8);
  DECLARE v_totalPalletAfter decimal(18, 8);
  DECLARE v_maxPalletCapacity decimal(18, 8);
  DECLARE v_percentageAfter decimal(18, 8);
  DECLARE v_overPallet_errorMessage varchar(1000);

  -- Variables for type pallet check
  DECLARE v_typePallet_returnCode varchar(3);
  DECLARE v_typePallet_errorMessage varchar(255);

  -- ===============================================
  -- VALIDASI 1: CHECK OVER PALLET
  -- ===============================================
  -- Hanya cek jika qty > 0 dan bukan lokasi receiving
  IF NEW.qty > 0
    AND NEW.locationId NOT LIKE '%RCV%'
    AND NEW.customerId NOT IN ('SMART_SBY') THEN

    -- Panggil stored procedure untuk cek over pallet
    CALL CML_SP_CHECK_OVER_PALLET(NEW.organizationId,
    NEW.warehouseId,
    NEW.locationId,
    NEW.qty,
    NEW.sku,
    NEW.customerId,
    v_overPallet_returnCode,
    v_overPallet_message,
    v_currentPalletUsage,
    v_incomingPallet,
    v_totalPalletAfter,
    v_maxPalletCapacity,
    v_percentageAfter);

    -- Jika return code 111 (over pallet), block insert
    IF v_overPallet_returnCode = '111' THEN
      -- Batasi panjang pesan error maksimal 128 karakter
      SET v_overPallet_errorMessage = CONCAT('OVER PALLET LOC:', NEW.locationId);
      IF LENGTH(v_overPallet_errorMessage) > 100 THEN
        SET v_overPallet_errorMessage = LEFT(v_overPallet_errorMessage, 100);
      END IF;
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_overPallet_errorMessage;
    END IF;
  END IF;

  -- ===============================================
  -- VALIDASI 2: CHECK TYPE PALLET
  -- ===============================================
  -- Hanya lakukan validasi jika qty > 0 dan customer tertentu
  IF NEW.qty > 0
    AND NEW.warehouseId IN ('CBT01', 'CBT02', 'CBT03', 'JBK01', 'CBT02-B2C') THEN

    -- Panggil stored procedure untuk validasi type pallet
    CALL CML_SP_CHECK_OVER_TYPEPALLET(NEW.organizationId,
    NEW.warehouseId,
    NEW.locationId,
    NEW.qty,
    NEW.sku,
    NEW.customerId,
    NEW.lotNum,
    v_typePallet_returnCode);

    -- Jika return code bukan 000, lempar error
    IF v_typePallet_returnCode = '444' THEN
      -- Batasi panjang pesan error maksimal 64 karakter
      SET v_typePallet_errorMessage = CONCAT('OVER TYPE PALLET LOC:', LEFT(NEW.locationId, 30));
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_typePallet_errorMessage;
    END IF;
  END IF;

END
$$

--
-- Create trigger `TRG_CHECK_OVERPALLET_BEFORE_UPDATE`
--
CREATE
DEFINER = 'mysql.sys'@'%'
TRIGGER TRG_CHECK_OVERPALLET_BEFORE_UPDATE
BEFORE UPDATE
ON INV_LOT_LOC_ID
FOR EACH ROW
BEGIN
  DECLARE v_returnCode varchar(3);
  DECLARE v_message varchar(500);
  DECLARE v_currentPalletUsage decimal(18, 8);
  DECLARE v_incomingPallet decimal(18, 8);
  DECLARE v_totalPalletAfter decimal(18, 8);
  DECLARE v_maxPalletCapacity decimal(18, 8);
  DECLARE v_percentageAfter decimal(18, 8);
  DECLARE v_qtyDiff decimal(18, 8);
  DECLARE v_errorMessage varchar(1000);

  -- Hitung selisih qty
  -- SET v_qtyDiff = NEW.qty; -- OLD.qty;

  -- Hanya cek jika ada penambahan qty dan bukan lokasi receiving
  IF NEW.oprSeqFlag LIKE '%[A2505]%' THEN
    -- Panggil stored procedure dengan qty difference
    CALL CML_SP_CHECK_OVER_PALLET(NEW.organizationId,
    NEW.warehouseId,
    NEW.locationId,
    NEW.qty,
    NEW.sku,
    NEW.customerId,
    v_returnCode,
    v_message,
    v_currentPalletUsage,
    v_incomingPallet,
    v_totalPalletAfter,
    v_maxPalletCapacity,
    v_percentageAfter);

    -- Jika return code 111 (over pallet), block update
    IF v_returnCode = '111' THEN
      SET v_errorMessage = CONCAT('OVER PALLET LOC:', NEW.locationId);
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_errorMessage;
    END IF;
  END IF;
END
$$

--
-- Create trigger `TRG_BAS_SKU_CUBE_UPDATE`
--
CREATE
DEFINER = 'mysql.sys'@'%'
TRIGGER TRG_BAS_SKU_CUBE_UPDATE
AFTER UPDATE
ON BAS_SKU
FOR EACH ROW
BEGIN
  -- Trigger aktif jika nilai cube asal > 0
  IF (OLD.cube > 0)
    AND (OLD.cube <> NEW.cube) THEN
    IF NEW.customerId IN ('MAP', 'ONDULINE', 'ECMAMAB2B', 'PANDA', 'MAPCLUB', 'PT.ABC') THEN


      SET @p_to_emails = 'it.wms@lincgrp.com';
      SET @p_subject = CONCAT('Detected CBM/CUBE SKU changed! ', OLD.customerId, ' -', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'));
      SET @p_body = CONCAT('Edit who:', NEW.editWho, '|perubahan CBM SKU:', OLD.sku, '| From=> ', OLD.cube, ' |to=> ', NEW.cube);
      SET @p_secretkey = 'linc2025';
      SET @p_is_html = TRUE;
      SET @p_cc_emails = 'mahmud.sampurna@lincgrp.com;nahot.hutagalung@lincgrp.com';
      SET @p_bcc_emails = NULL;
      SET @p_attachments = NULL;
      CALL Z_sp_send_email(@p_to_emails, @p_subject, @p_body, @p_is_html, @p_cc_emails, @p_bcc_emails, @p_attachments, @p_secretkey, @p_status, @p_message);


    END IF;
  END IF;
END
$$

--
-- Create trigger `PREVENT DUPLICATE APPOINT ON ARRIVAL`
--
CREATE
DEFINER = 'root'@'%'
TRIGGER `PREVENT DUPLICATE APPOINT ON ARRIVAL`
BEFORE INSERT
ON DOC_ARRIVAL_DETAILS
FOR EACH ROW
BEGIN
  DECLARE errorMessage varchar(255);
  IF
    NEW.appointmentNo IN (SELECT
        A.appointmentNo
      FROM DOC_ARRIVAL_DETAILS A
        LEFT JOIN DOC_ARRIVAL_HEADER B
          ON A.organizationId = B.organizationId
          AND A.warehouseId = B.warehouseId
          AND A.arrivalno = B.arrivalNo
      WHERE (NEW.appointmentNo = A.appointmentNo
      AND NEW.warehouseId = A.warehouseId
      AND B.arrivalStatus != 90)) THEN

    SET errorMessage = CONCAT('Appointment ini sudah dibuat Arrival');
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = errorMessage;

  END IF;

END
$$

--
-- Create trigger `BEFORE_UPDATE_DOC_ORDER_HEADER`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER BEFORE_UPDATE_DOC_ORDER_HEADER
BEFORE UPDATE
ON DOC_ORDER_HEADER
FOR EACH ROW
BEGIN
  DECLARE errorMessage varchar(255);
  DECLARE status_asn varchar(2);

  IF NEW.orderType = 'OT' THEN

    IF NEW.warehouseId = 'SBYKK'
      AND NEW.customerId = 'ECCOSBY' THEN
      INSERT INTO Z_LogUdfTran (docType
      , docNo
      , userId
      , lottable01
      , lottable02
      , lottable03
      , lottable04
      , addDate
      , addWho
      , editDate
      , editWho
      , organizationId)
        VALUES (NEW.orderType, NEW.orderNo, NEW.editWho, 'Update SO Type to Overtime', '', '', '', NOW(), 'EDI', NOW(), '', 'OJV_CML');

    END IF;
  END IF;
END
$$

--
-- Create trigger `BEFORE_INSERT_ZDOC_MANPOWER_OT`
--
CREATE
DEFINER = 'root'@'%'
TRIGGER BEFORE_INSERT_ZDOC_MANPOWER_OT
BEFORE INSERT
ON ZDOC_MANPOWER_OT
FOR EACH ROW
BEGIN
  DECLARE errorMessage varchar(255);
  DECLARE status_asn varchar(2);
  DECLARE IN_organizationId varchar(255);
  DECLARE IN_warehouseId varchar(255);
  DECLARE IN_Language varchar(255);
  DECLARE IN_Sequence_Name varchar(255);
  DECLARE OUT_ReturnNo varchar(255);
  DECLARE OUT_Return_Code varchar(255);
  DECLARE IDCODE varchar(255);

  SET NEW.idBillingOTMP = (FNSPCOM_GetIDSequence('OJV_CML', NEW.warehouseId, 'IDMANPOWEROT'));
END
$$

--
-- Create trigger `BEFORE_INSERT_BILLINGSUMMARY`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER BEFORE_INSERT_BILLINGSUMMARY
AFTER INSERT
ON BIL_SUMMARY
FOR EACH ROW
BEGIN

  IF (NEW.ediErrorCode2 <> '') THEN
    INSERT INTO TEMP_API (lot01, lot02, lot03, lot04)
      VALUES (NEW.organizationId, NEW.warehouseId, NEW.billingSummaryId, NEW.ediErrorCode2);


  END IF;
END
$$

--
-- Create trigger `AUTO_UPDATE_ALLOCATION_DOCTYPE_IT_PPG`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER AUTO_UPDATE_ALLOCATION_DOCTYPE_IT_PPG
AFTER UPDATE
ON DOC_ORDER_HEADER
FOR EACH ROW
BEGIN
  DECLARE errorMessage varchar(255);
  DECLARE status_asn varchar(2);


  IF (new.soStatus = 99)
    AND (old.orderType = 'IT') THEN
    UPDATE ACT_ALLOCATION_DETAILS aad
    SET aad.udf05 = 'LS',
        aad.editTime = NOW()
    WHERE aad.organizationId = 'OJV_CML'
    AND aad.customerId = 'PPG'
    AND aad.orderNo = old.orderNo
    AND aad.warehouseId = old.warehouseId;
  END IF;

END
$$

DELIMITER ;