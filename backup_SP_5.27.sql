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
-- Create procedure `CML_BILLVASSPECIALSTD_NW`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLVASSPECIALSTD_NW
(
                 IN IN_organizationId varchar(30), IN IN_warehouseId varchar(30), IN IN_USERID varchar(30), IN IN_Language varchar(30), IN IN_CustomerId varchar(30), IN IN_trans_no varchar(30), OUT p_success_flag char(1), OUT p_message varchar(1000), OUT p_record_count int
)
BEGIN
  -- =============================================
  -- Stored Procedure: CML_BILLVASSPECIALSTD_NW
  -- Purpose: Process outbound billing for customers based on shipment transactions
  -- Author: [Akbar@IT-LINC]
  -- Date: [04.09.25]
  -- =============================================

  -- Variable declarations
  DECLARE v_billing_summary_id varchar(30) DEFAULT '';
  DECLARE v_return_code varchar(1000);
  DECLARE v_row_count int DEFAULT 0;
  DECLARE v_error_code varchar(5);
  DECLARE v_error_msg varchar(1000);
  DECLARE v_start_time timestamp DEFAULT NOW();
  DECLARE v_end_time timestamp;
  DECLARE v_execution_time decimal(10, 3);

  -- Declare handlers for exceptions
  DECLARE EXIT HANDLER FOR SQLEXCEPTION

  BEGIN
    -- Get error information
    GET DIAGNOSTICS CONDITION 1
    v_error_code = RETURNED_SQLSTATE,
    v_error_msg = MESSAGE_TEXT;

    -- Rollback transaction
    ROLLBACK;

    -- Set output parameters
    SET p_success_flag = 'N';
    SET p_message = CONCAT('Error Code: ', v_error_code, ' - ', v_error_msg);
    SET p_record_count = 0;

  -- Log error (optional)
  --         INSERT INTO ERROR_LOG (procedure_name, error_code, error_message, error_time, parameters)
  --         VALUES ('CML_BILLHOSTD_BETA', v_error_code, v_error_msg, NOW(), 
  --                 CONCAT('Org:', IN_organizationId, '|WH:', IN_warehouseId, 
  --                       '|Cust:', IN_CustomerId, '|Trans:', IN_trans_no));
  END;

  -- Initialize output parameters
  SET p_success_flag = 'N';
  SET p_message = '';
  SET p_record_count = 0;




  -- Validate input parameters
  IF IN_organizationId IS NULL OR
  IN_organizationId = ''
  THEN
    SET p_message = 'Organization ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_CustomerId IS NULL OR
  IN_CustomerId = ''
  THEN
    SET p_message = 'Customer ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_trans_no IS NULL OR
  IN_trans_no = ''
  THEN
    SET p_message = 'Transaction number cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  -- Start transaction
  START TRANSACTION;

  BEGIN
    -- Initialize row counter
    SET @row_num = 0;

    -- Generate billing summary ID
    SET v_return_code = '*_*';
    CALL SPCOM_GetIDSequence_NEW(IN_organizationId, '*', IN_Language, 'BILLINGSUMMARYIDCUST', v_billing_summary_id, v_return_code);

    -- Check if ID generation was successful
    IF v_return_code NOT LIKE '000%'
    THEN
      SET p_message = CONCAT('Failed to generate billing summary ID. Return code: ', v_return_code);
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
    END IF;

    DROP TEMPORARY TABLE IF EXISTS temp_billing_data;
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_billing_data AS
    SELECT dvh.organizationId,
    dvh.warehouseId,
    dvh.customerId,
    dvh.vasNo,
    dvh.editTime AS closeTime,
    dvs.vasType,
    dvh.kitReference1,
    dvh.kitReference2,
    dvh.kitReference3,
    dvh.kitReference4,
    dvh.kitReference5,
    dvd.sku,
    dvd.vasLineNo,
    dvf.rateQty1 AS qtyChargeBilling,
    dvf.chargeDate,
    bsm.tariffMasterId,
    bil.tariffId,
    bil.chargeCategory, bil.chargeType,
    bil.rate,
    bcm.codeDescr,
    'QUANTITY' AS ratebase,
    0 cost,
    1 AS rateperunit,
    bil.udf01,
    bil.udf06, NULL incomeTaxRate
    FROM DOC_VAS_HEADER dvh
         INNER JOIN
         DOC_VAS_DETAILS dvd
         ON dvh.organizationId = dvd.organizationId AND
           dvh.warehouseId = dvd.warehouseId AND
           dvh.vasNo = dvd.vasNo AND
           dvh.customerId = dvd.customerId
         INNER JOIN
         DOC_VAS_SERVICE dvs
         ON dvh.organizationId = dvs.organizationId AND
           dvh.warehouseId = dvs.warehouseId AND
           dvh.vasNo = dvs.vasNo
         INNER JOIN
         DOC_VAS_FEE dvf
         ON dvh.organizationId = dvf.organizationId AND
           dvd.warehouseId = dvf.warehouseId AND
           dvh.vasNo = dvf.vasNo
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING zbcc
         ON (dvh.organizationId = zbcc.organizationId AND
           dvh.warehouseId = zbcc.warehouseId AND
           dvh.customerId = zbcc.customerId)
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
         ON (zbcc.organizationId = zbccd.organizationId AND
           zbcc.lotatt01 = zbccd.idGroupSp)
         INNER JOIN
         BAS_SKU_MULTIWAREHOUSE bsm
         ON bsm.organizationId = dvd.organizationId AND
           bsm.warehouseId = dvd.warehouseId AND
           bsm.customerId = dvd.customerId AND
           bsm.SKU = dvd.sku
         INNER JOIN
         (SELECT btd.organizationId, btd.warehouseId, bth.tariffMasterId, btd.tariffId, btr.rate, btd.chargeCategory, btd.chargeType, btd.vasType, btd.udf01, btd.udf06
       FROM BIL_TARIFF_HEADER bth
            LEFT JOIN
            BIL_TARIFF_DETAILS btd
            ON btd.organizationId = bth.organizationId
              AND
              btd.tariffId = bth.tariffId
            LEFT JOIN
            BIL_TARIFF_RATE btr
            ON btr.organizationId = btd.organizationId
              AND
              btr.tariffId = btd.tariffId
              AND
              btr.tariffLineNo = btd.tariffLineNo
       WHERE btd.organizationId = 'OJV_CML' AND
             bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
             bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
             btd.chargeCategory = 'VA'
             -- AND btd.vasType <> ''
             AND btd.tariffLineNo > 100 AND
             btr.rate > 0
       GROUP BY btd.organizationId, btd.warehouseId, btd.tariffId, btr.rate, btd.chargeCategory, btd.chargeType, btd.vasType, btd.udf01, btd.UDF06) bil
         ON bil.organizationId = bsm.organizationId AND
           bil.warehouseId = bsm.warehouseId AND
           bil.tariffMasterId = bsm.tariffMasterId AND
           bil.vasType = dvs.vasType AND
           bil.chargeCategory = dvf.chargeCategory AND
           bil.chargeType = dvf.chargeType
         INNER JOIN
         BSM_CODE_ML bcm
         ON bcm.organizationId = bil.organizationId AND
           bcm.codeType = 'VAS_TYP' AND
           bcm.codeid = bil.vasType AND
           bcm.languageId = 'en'
    WHERE dvh.organizationId = IN_organizationId AND
          dvh.warehouseId = IN_warehouseId AND
          dvh.customerId = IN_CustomerId AND
          dvh.vasNo = IN_trans_no AND
          zbcc.lotatt01 <> '' AND
          zbcc.active = 'Y' AND
          zbccd.active = 'Y' AND
          zbccd.spName = 'CML_BILLVASSPECIALSTD' AND
          dvh.vasStatus = '99' AND
          DATE(dvh.editTime) >= getBillFMDate(25) AND
          NOT EXISTS (SELECT 1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = 'OJV_CML' AND
              bs.warehouseId = dvh.warehouseId AND
              bs.customerId = dvh.customerId AND
              bs.docNo = dvh.vasNo AND
              bs.chargeCategory = 'VA' AND
              DATE(bs.addTime) >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
    ORDER BY dvh.editTime ASC;




    -- Insert billing summary data
    INSERT INTO BIL_SUMMARY (organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate,
    customerId, sku, lotNum, traceId, tariffId, chargeCategory, chargeType,
    descr, rateBase, chargePerUnits, qty, uom, cubic, weight, chargeRate,
    amount, billingAmount, cost, amountPayable, amountPaid, confirmTime,
    confirmWho, docType, docNo, createTransactionid, notes, ediSendTime,
    billTo, settleTime, settleWho, followUp, invoiceType, paidTo,
    costConfirmFlag, costConfirmTime, costConfirmWho, costSettleFlag,
    costSettleTime, costSettleWho, incomeTaxRate, costTaxRate, incomeTax,
    cosTax, incomeWithoutTax, cosWithoutTax, costInvoiceType, noteText,
    udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag,
    addWho, addTime, editWho, editTime, locationCategory, manual,
    docLineNo, arNo, arLineNo, apNo, apLineNo, ediSendFlag,
    ediErrorCode, ediErrorMessage, ediSendTime2, ediSendFlag2,
    ediErrorCode2, ediErrorMessage2, billingTranCategory, orderType,
    containerType, containerSize)
           SELECT organizationId,
           warehouseId,
           CONCAT(v_billing_summary_id, '*', LPAD(auto_sequence(), 3, '0')) AS billingSummaryId,
           DATE(closeTime) AS billingFromDate,
           DATE(closeTime) AS billingToDate,
           customerId,
           sku,
           '' lotNum,
           '' traceId,
           tariffId,
           chargeCategory,
           chargeType,
           codeDescr AS descr,
           ratebase AS rateBase,
           rateperunit AS chargePerUnits,
           qtyChargeBilling AS qty,
           'EA' uom,
           0 AS cubic,
           0 AS weight,
           rate AS chargeRate,
           qtyChargeBilling * rate / ratePerUnit AS amount,
           (qtyChargeBilling * (rate / ratePerUnit)) +
           (qtyChargeBilling * (rate / ratePerUnit)) * incomeTaxRate / 100 AS billingAmount,
           cost,
           cost * qtyChargeBilling AS amountPayable,
           0 AS amountPaid,
           NOW() AS confirmTime,
           IN_USERID AS confirmWho,
           'VAS' AS docType,
           vasNo AS docNo,
           '' AS createTransactionid,
           '' AS notes,
           NOW() AS ediSendTime,
           customerId AS billTo,
           NOW() AS settleTime,
           IN_USERID AS settleWho,
           '' AS followUp,
           '' AS invoiceType,
           '' AS paidTo,
           'N' AS costConfirmFlag,
           NOW() AS costConfirmTime,
           '' AS costConfirmWho,
           'N' AS costSettleFlag,
           NOW() AS costSettleTime,
           '' AS costSettleWho,
           0 AS incomeTaxRate,
           0 AS costTaxRate,
           qtyChargeBilling * rate / ratePerUnit * incomeTaxRate / 100 AS incomeTax,
           0 AS cosTax,
           qtyChargeBilling * rate / ratePerUnit AS incomeWithoutTax,
           0 AS cosWithoutTax,
           '' AS costInvoiceType,
           '' AS noteText,
           udf01 AS udf01,
           '' AS udf02,
           '' AS udf03,
           udf06 AS udf04,
           '' AS udf05,
           100 AS currentVersion,
           '2020' AS oprSeqFlag,
           IN_USERID AS addWho,
           NOW() AS addTime,
           IN_USERID AS editWho,
           NOW() AS editTime,
           '' locationCategory,
           'N' AS manual,
           0 AS docLineNo,
           '*' AS arNo,
           0 AS arLineNo,
           '*' AS apNo,
           0 AS apLineNo,
           'N' AS ediSendFlag,
           '' AS ediErrorCode,
           '' AS ediErrorMessage,
           NOW() AS ediSendTime2,
           'N' AS ediSendFlag2,
           '' AS ediErrorCode2,
           '' AS ediErrorMessage2,
           '' AS billingTranCategory,
           '' docType,
           '' AS containerType,
           '' AS containerSize
           FROM temp_billing_data
           WHERE qtyChargeBilling > 0;  -- Only insert records with positive billing quantity

    -- Get the number of inserted rows
    SET v_row_count = ROW_COUNT();

    -- Clean up temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_billing_data;

    -- Check if any rows were inserted
    IF v_row_count = 0
    THEN
      -- No data found, but this might be expected
      SET p_message = CONCAT('No billing data found for Vas Special: ', IN_trans_no, ', Customer: ', IN_CustomerId);
      SET p_success_flag = 'W'; -- Warning flag
      SET p_record_count = 0;
      COMMIT; -- Commit even if no rows

    --   CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLSOVASSTD_NW', IN_trans_no, 'error', NULL, NULL, p_success_flag,
    -- p_message, p_record_count, v_start_time, v_end_time);
    ELSE
      -- Calculate execution time
      SET v_end_time = NOW();
      SET v_execution_time = TIMESTAMPDIFF(MICROSECOND, v_start_time, v_end_time) / 1000000;

      -- Commit transaction
      COMMIT;

      -- Set success output parameters
      SET p_success_flag = 'Y';
      SET p_message = CONCAT('VasSpecial billing processed successfully. ', 'Billing Summary ID: ', v_billing_summary_id, '. Records: ', v_row_count, '. Execution time: ', v_execution_time, ' seconds');
      SET p_record_count = v_row_count;

    --           CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId,IN_CustomerId,'CML_BILLHISTD_TYPE2',IN_trans_no,'no error',NULL,NULL,p_success_flag,
    --             p_message,p_record_count,v_start_time,v_end_time);


    END IF;



  END;

END
$$

--
-- Create procedure `Z_SP_ProcessBillingCML_BILLVASSPECIALSTD`
--
CREATE
DEFINER = 'mysql.sys'@'%'
PROCEDURE Z_SP_ProcessBillingCML_BILLVASSPECIALSTD()
  SP:
  BEGIN
    -- Deklarasi variabel untuk menyimpan data dari cursor
    DECLARE v_organizationId varchar(20);
    DECLARE v_warehouseId varchar(20);
    DECLARE v_customerId varchar(30);
    DECLARE v_trans_no varchar(20);
    DECLARE v_spName varchar(30);
    DECLARE v_flag int DEFAULT 0;
    -- Variabel untuk mengontrol loop
    DECLARE done int DEFAULT FALSE;



    -- Deklarasi cursor
    DECLARE billing_cursor CURSOR FOR SELECT DISTINCT dvh.organizationId, dvh.warehouseId, dvh.customerId, dvh.vasNo, zbccd.spName
    FROM DOC_VAS_HEADER dvh
         INNER JOIN
         DOC_VAS_DETAILS dvd
         ON dvh.organizationId = dvd.organizationId
           AND
           dvh.warehouseId = dvd.warehouseId
           AND
           dvh.vasNo = dvd.vasNo
           AND
           dvh.customerId = dvd.customerId
         INNER JOIN
         DOC_VAS_SERVICE dvs
         ON dvh.organizationId = dvs.organizationId
           AND
           dvh.warehouseId = dvs.warehouseId
           AND
           dvh.vasNo = dvs.vasNo
         INNER JOIN
         DOC_VAS_FEE dvf
         ON dvh.organizationId = dvf.organizationId
           AND
           dvd.warehouseId = dvf.warehouseId
           AND
           dvh.vasNo = dvf.vasNo
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING zbcc
         ON (dvh.organizationId = zbcc.organizationId AND
           dvh.warehouseId = zbcc.warehouseId AND
           dvh.customerId = zbcc.customerId)
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
         ON (zbcc.organizationId = zbccd.organizationId AND
           zbcc.lotatt01 = zbccd.idGroupSp)
         INNER JOIN
         BAS_SKU_MULTIWAREHOUSE bsm
         ON bsm.organizationId = dvd.organizationId
           AND
           bsm.warehouseId = dvd.warehouseId
           AND
           bsm.customerId = dvd.customerId
           AND
           bsm.SKU = dvd.sku
         INNER JOIN
         (SELECT btd.organizationId, btd.warehouseId, bth.tariffMasterId, btd.tariffId, btr.rate, btd.chargeCategory, btd.chargeType, btd.vasType, btd.udf01, btd.udf06
       FROM BIL_TARIFF_HEADER bth
            LEFT JOIN
            BIL_TARIFF_DETAILS btd
            ON btd.organizationId = bth.organizationId
              AND
              btd.tariffId = bth.tariffId
            LEFT JOIN
            BIL_TARIFF_RATE btr
            ON btr.organizationId = btd.organizationId
              AND
              btr.tariffId = btd.tariffId
              AND
              btr.tariffLineNo = btd.tariffLineNo
       WHERE btd.organizationId = 'OJV_CML' AND
             bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
             bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
             btd.chargeCategory = 'VA'
             -- AND btd.vasType <> ''
             AND btd.tariffLineNo > 100 AND
             btr.rate > 0
       GROUP BY btd.organizationId, btd.warehouseId, btd.tariffId, btr.rate, btd.chargeCategory, btd.chargeType, btd.vasType, btd.udf01, btd.UDF06) bil
         ON bil.organizationId = bsm.organizationId
           AND
           bil.warehouseId = bsm.warehouseId
           AND
           bil.tariffMasterId = bsm.tariffMasterId
           AND
           bil.vasType = dvs.vasType
           AND
           bil.chargeCategory = dvf.chargeCategory
           AND
           bil.chargeType = dvf.chargeType
    WHERE dvh.organizationId = 'OJV_CML'
          -- AND dvh.warehouseId='@warehouse' 
          -- AND dvh.customerId='@customer'
          AND zbcc.lotatt01 <> '' AND
          zbcc.active = 'Y' AND
          zbccd.active = 'Y' AND
          zbccd.spName = 'CML_BILLVASSPECIALSTD' AND
          dvh.vasStatus = '99' AND
          DATE(dvh.editTime) > getBillFMDate(25) AND
          NOT EXISTS (SELECT 1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = 'OJV_CML' AND
              bs.warehouseId = dvh.warehouseId AND
              bs.customerId = dvh.customerId AND
              bs.docNo = dvh.vasNo AND
              bs.chargeCategory = 'VA' AND
              DATE(bs.addTime) >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH));


    -- Handler untuk kondisi NOT FOUND
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Buka cursor
    OPEN billing_cursor;

    -- Loop untuk memproses setiap baris
    read_loop:
    LOOP
      -- Fetch data dari cursor
      FETCH billing_cursor INTO v_organizationId,
      v_warehouseId,
      v_customerId,
      v_trans_no,
      v_spName;

      -- Jika tidak ada data lagi, keluar dari loop
      IF done
      THEN

        LEAVE read_loop;
      END IF;




      SET @IN_organizationId = v_organizationId;
      SET @IN_warehouseId = v_warehouseId;
      SET @IN_USERID = 'CUSTOMBILL';
      SET @IN_Language = 'en';
      SET @IN_CustomerId = v_customerId;
      SET @IN_trans_no = v_trans_no;
      CALL CML_BILLVASSPECIALSTD_NW(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @p_success_flag, @p_message, @p_record_count);


    END LOOP;


    -- Tutup cursor
    CLOSE billing_cursor;



  END
  $$

--
-- Create procedure `CML_BILLTRFBAGGINGSTD_NW`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLTRFBAGGINGSTD_NW
(
                 IN IN_organizationId varchar(30), IN IN_warehouseId varchar(30), IN IN_USERID varchar(30), IN IN_Language varchar(30), IN IN_CustomerId varchar(30), IN IN_trans_no varchar(30), OUT p_success_flag char(1), OUT p_message varchar(1000), OUT p_record_count int
)
BEGIN
  -- =============================================
  -- Stored Procedure: CML_BILLTRFBAGGINGSTD_NW
  -- Purpose: Process Transbagging billing for customers
  -- Author: [Akbar@IT-LINC]
  -- Date: [08.09.25]
  -- =============================================

  -- Variable declarations
  DECLARE v_billing_summary_id varchar(30) DEFAULT '';
  DECLARE v_return_code varchar(1000);
  DECLARE v_row_count int DEFAULT 0;
  DECLARE v_error_code varchar(5);
  DECLARE v_error_msg varchar(1000);
  DECLARE v_start_time timestamp DEFAULT NOW();
  DECLARE v_end_time timestamp;
  DECLARE v_execution_time decimal(10, 3);

  -- Declare handlers for exceptions
  DECLARE EXIT HANDLER FOR SQLEXCEPTION

  BEGIN
    -- Get error information
    GET DIAGNOSTICS CONDITION 1
    v_error_code = RETURNED_SQLSTATE,
    v_error_msg = MESSAGE_TEXT;

    -- Rollback transaction
    ROLLBACK;

    -- Set output parameters
    SET p_success_flag = 'N';
    SET p_message = CONCAT('Error Code: ', v_error_code, ' - ', v_error_msg);
    SET p_record_count = 0;

  -- Log error (optional)
  --         INSERT INTO ERROR_LOG (procedure_name, error_code, error_message, error_time, parameters)
  --         VALUES ('CML_BILLHOSTD_BETA', v_error_code, v_error_msg, NOW(), 
  --                 CONCAT('Org:', IN_organizationId, '|WH:', IN_warehouseId, 
  --                       '|Cust:', IN_CustomerId, '|Trans:', IN_trans_no));
  END;

  -- Initialize output parameters
  SET p_success_flag = 'N';
  SET p_message = '';
  SET p_record_count = 0;




  -- Validate input parameters
  IF IN_organizationId IS NULL OR
  IN_organizationId = ''
  THEN
    SET p_message = 'Organization ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_CustomerId IS NULL OR
  IN_CustomerId = ''
  THEN
    SET p_message = 'Customer ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_trans_no IS NULL OR
  IN_trans_no = ''
  THEN
    SET p_message = 'Transaction number cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  -- Start transaction
  START TRANSACTION;

  BEGIN
    -- Initialize row counter
    SET @row_num = 0;

    -- Generate billing summary ID
    SET v_return_code = '*_*';
    CALL SPCOM_GetIDSequence_NEW(IN_organizationId, '*', IN_Language, 'BILLINGSUMMARYIDCUST', v_billing_summary_id, v_return_code);

    -- Check if ID generation was successful
    IF v_return_code NOT LIKE '000%'
    THEN
      SET p_message = CONCAT('Failed to generate billing summary ID. Return code: ', v_return_code);
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
    END IF;

    DROP TEMPORARY TABLE IF EXISTS temp_billing_data;
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_billing_data AS
    SELECT dth.organizationId,
    dth.warehouseId,
    dth.customerId,
    dth.tdocNo,
    dth.editTime AS closeTime,
    dth.tdocType,
    dtd.toLotAtt04,
    dtd.toLotAtt05,
    dtd.toLotAtt06,
    dtd.toLotAtt08,
    dtd.fmSku,
    dtd.toSku,
    dtd.fmQty,
    dtd.toQty AS qtyChargeBilling,
    dtd.tdocLineNo,
    bsm.tariffMasterId,
    bil.tariffId,
    bil.chargeCategory,
    bil.chargeType,
    bil.rate,
    bcm.codeDescr,
    'QUANTITY' AS ratebase,
    0 cost,
    1 AS rateperunit,
    bil.udf01,
    bil.udf06,
    NULL incomeTaxRate
    FROM DOC_TRANSFER_HEADER dth
         INNER JOIN
         DOC_TRANSFER_DETAILS dtd
         ON (dth.organizationId = dtd.organizationId AND
           dth.warehouseId = dtd.warehouseId AND
           dth.tdocNo = dtd.tdocNo)
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING zbcc
         ON (dth.organizationId = zbcc.organizationId AND
           dth.warehouseId = zbcc.warehouseId AND
           dth.customerId = zbcc.customerId)
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
         ON (zbcc.organizationId = zbccd.organizationId AND
           zbcc.lotatt01 = zbccd.idGroupSp)
         INNER JOIN
         BAS_SKU_MULTIWAREHOUSE bsm
         ON bsm.organizationId = dtd.organizationId AND
           bsm.warehouseId = dtd.warehouseId AND
           bsm.customerId = dtd.fmCustomerId AND
           bsm.SKU = dtd.fmSku
         INNER JOIN
         (SELECT btd.organizationId, btd.warehouseId, bth.tariffMasterId, btd.tariffId, btr.rate, btd.chargeCategory, btd.chargeType, btd.vasType, btd.udf01, btd.udf06
       FROM BIL_TARIFF_HEADER bth
            LEFT JOIN
            BIL_TARIFF_DETAILS btd
            ON btd.organizationId = bth.organizationId
              AND
              btd.tariffId = bth.tariffId
            LEFT JOIN
            BIL_TARIFF_RATE btr
            ON btr.organizationId = btd.organizationId
              AND
              btr.tariffId = btd.tariffId
              AND
              btr.tariffLineNo = btd.tariffLineNo
       WHERE btd.organizationId = 'OJV_CML' AND
             bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
             bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
             btd.chargeCategory = 'TD' AND
             btd.udf01 IN ('1700000008') AND
             btd.tariffLineNo > 100 AND
             btr.rate > 0
       GROUP BY btd.organizationId, btd.warehouseId, btd.tariffId, btr.rate, btd.chargeCategory, btd.chargeType, btd.vasType, btd.udf01, btd.UDF06) bil
         ON bil.organizationId = bsm.organizationId AND
           bil.warehouseId = bsm.warehouseId AND
           bil.tariffMasterId = bsm.tariffMasterId AND
           bil.chargeCategory = 'TD' AND
           bil.chargeType = dth.tdocType
         INNER JOIN
         BSM_CODE_ML bcm
         ON bcm.organizationId = bil.organizationId AND
           bcm.codeType = 'TRF_TYP' AND
           bcm.languageId = 'en' AND
           bcm.codeid = dth.tdocType
    WHERE dth.organizationId = IN_organizationId AND
          dth.warehouseId = IN_warehouseId AND
          dth.customerId = IN_CustomerId AND
          dth.tdocNo = IN_trans_no AND
          zbcc.lotatt01 <> '' AND
          zbcc.active = 'Y' AND
          zbccd.active = 'Y' AND
          zbccd.spName = 'CML_BILLTRFBAGGINGSTD' AND
          dth.status = '99' AND
          dtd.tdocLineStatus = '99' AND
          DATE(dth.editTime) >= getBillFMDate(25) AND
          NOT EXISTS (SELECT 1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = 'OJV_CML' AND
              bs.warehouseId = dth.warehouseId AND
              bs.customerId = dth.customerId AND
              bs.docNo = dth.tdocNo AND
              bs.chargeCategory = 'TD' AND
              DATE(bs.addTime) >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
    ORDER BY dth.editTime ASC;



    -- Insert billing summary data
    INSERT INTO BIL_SUMMARY (organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate,
    customerId, sku, lotNum, traceId, tariffId, chargeCategory, chargeType,
    descr, rateBase, chargePerUnits, qty, uom, cubic, weight, chargeRate,
    amount, billingAmount, cost, amountPayable, amountPaid, confirmTime,
    confirmWho, docType, docNo, createTransactionid, notes, ediSendTime,
    billTo, settleTime, settleWho, followUp, invoiceType, paidTo,
    costConfirmFlag, costConfirmTime, costConfirmWho, costSettleFlag,
    costSettleTime, costSettleWho, incomeTaxRate, costTaxRate, incomeTax,
    cosTax, incomeWithoutTax, cosWithoutTax, costInvoiceType, noteText,
    udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag,
    addWho, addTime, editWho, editTime, locationCategory, manual,
    docLineNo, arNo, arLineNo, apNo, apLineNo, ediSendFlag,
    ediErrorCode, ediErrorMessage, ediSendTime2, ediSendFlag2,
    ediErrorCode2, ediErrorMessage2, billingTranCategory, orderType,
    containerType, containerSize)
           SELECT organizationId,
           warehouseId,
           CONCAT(v_billing_summary_id, '*', LPAD(auto_sequence(), 3, '0')) AS billingSummaryId,
           DATE(closeTime) AS billingFromDate,
           DATE(closeTime) AS billingToDate,
           customerId,
           toSku,
           '' lotNum,
           '' traceId,
           tariffId,
           chargeCategory,
           chargeType,
           codeDescr AS descr,
           ratebase AS rateBase,
           rateperunit AS chargePerUnits,
           qtyChargeBilling AS qty,
           'EA' uom,
           0 AS cubic,
           0 AS weight,
           rate AS chargeRate,
           qtyChargeBilling * rate / ratePerUnit AS amount,
           (qtyChargeBilling * (rate / ratePerUnit)) +
           (qtyChargeBilling * (rate / ratePerUnit)) * incomeTaxRate / 100 AS billingAmount,
           cost,
           cost * qtyChargeBilling AS amountPayable,
           0 AS amountPaid,
           NOW() AS confirmTime,
           IN_USERID AS confirmWho,
           'TR' AS docType,
           tdocNo AS docNo,
           '' AS createTransactionid,
           '' AS notes,
           NOW() AS ediSendTime,
           customerId AS billTo,
           NOW() AS settleTime,
           IN_USERID AS settleWho,
           '' AS followUp,
           '' AS invoiceType,
           '' AS paidTo,
           'N' AS costConfirmFlag,
           NOW() AS costConfirmTime,
           '' AS costConfirmWho,
           'N' AS costSettleFlag,
           NOW() AS costSettleTime,
           '' AS costSettleWho,
           0 AS incomeTaxRate,
           0 AS costTaxRate,
           qtyChargeBilling * rate / ratePerUnit * incomeTaxRate / 100 AS incomeTax,
           0 AS cosTax,
           qtyChargeBilling * rate / ratePerUnit AS incomeWithoutTax,
           0 AS cosWithoutTax,
           '' AS costInvoiceType,
           '' AS noteText,
           udf01 AS udf01,
           '' AS udf02,
           '' AS udf03,
           udf06 AS udf04,
           '' AS udf05,
           100 AS currentVersion,
           '2020' AS oprSeqFlag,
           IN_USERID AS addWho,
           NOW() AS addTime,
           IN_USERID AS editWho,
           NOW() AS editTime,
           '' locationCategory,
           'N' AS manual,
           0 AS docLineNo,
           '*' AS arNo,
           0 AS arLineNo,
           '*' AS apNo,
           0 AS apLineNo,
           'N' AS ediSendFlag,
           '' AS ediErrorCode,
           '' AS ediErrorMessage,
           NOW() AS ediSendTime2,
           'N' AS ediSendFlag2,
           '' AS ediErrorCode2,
           '' AS ediErrorMessage2,
           '' AS billingTranCategory,
           '' docType,
           '' AS containerType,
           '' AS containerSize
           FROM temp_billing_data
           WHERE qtyChargeBilling > 0;  -- Only insert records with positive billing quantity

    -- Get the number of inserted rows
    SET v_row_count = ROW_COUNT();

    -- Clean up temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_billing_data;

    -- Check if any rows were inserted
    IF v_row_count = 0
    THEN
      -- No data found, but this might be expected
      SET p_message = CONCAT('No billing data found for Vas SO: ', IN_trans_no, ', Customer: ', IN_CustomerId);
      SET p_success_flag = 'W'; -- Warning flag
      SET p_record_count = 0;
      COMMIT; -- Commit even if no rows

    --   CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLSOVASSTD_NW', IN_trans_no, 'error', NULL, NULL, p_success_flag,
    -- p_message, p_record_count, v_start_time, v_end_time);
    ELSE
      -- Calculate execution time
      SET v_end_time = NOW();
      SET v_execution_time = TIMESTAMPDIFF(MICROSECOND, v_start_time, v_end_time) / 1000000;

      -- Commit transaction
      COMMIT;

      -- Set success output parameters
      SET p_success_flag = 'Y';
      SET p_message = CONCAT('TransferBagging billing processed successfully. ', 'Billing Summary ID: ', v_billing_summary_id, '. Records: ', v_row_count, '. Execution time: ', v_execution_time, ' seconds');
      SET p_record_count = v_row_count;

      CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLTRFBAGGINGSTD_NW', IN_trans_no, 'no error', NULL, NULL, p_success_flag, p_message, p_record_count, v_start_time, v_end_time);


    END IF;



  END;

END
$$

--
-- Create procedure `Z_SP_ProcessBillingCML_BILLTRFBAGGINGSTD`
--
CREATE
DEFINER = 'mysql.sys'@'%'
PROCEDURE Z_SP_ProcessBillingCML_BILLTRFBAGGINGSTD()
  SP:
  BEGIN
    -- Deklarasi variabel untuk menyimpan data dari cursor
    DECLARE v_organizationId varchar(20);
    DECLARE v_warehouseId varchar(20);
    DECLARE v_customerId varchar(30);
    DECLARE v_trans_no varchar(20);
    DECLARE v_spName varchar(30);
    DECLARE v_flag int DEFAULT 0;
    -- Variabel untuk mengontrol loop
    DECLARE done int DEFAULT FALSE;



    -- Deklarasi cursor
    DECLARE billing_cursor CURSOR FOR SELECT dah.organizationId, dah.warehouseId, dah.customerId, dah.tdocNo AS trans_no, zbccd.spName
    FROM DOC_TRANSFER_HEADER dah
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING zbcc
         ON (dah.organizationId = zbcc.organizationId AND
           dah.warehouseId = zbcc.warehouseId AND
           dah.customerId = zbcc.customerId)
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
         ON (zbcc.organizationId = zbccd.organizationId AND
           zbcc.lotatt01 = zbccd.idGroupSp)
    WHERE dah.organizationId = 'OJV_CML'
          -- AND dah.warehouseId='@warehouse'
          -- AND dah.customerId ='@customer'
          AND dah.tdocType IN (
          'TBD',
          'TBD1',
          'TBD10',
          'TBD101',
          'TBD11',
          'TBD12',
          'TBD13',
          'TBD14',
          'TBD2',
          'TBD3',
          'TBD4',
          'TBD5',
          'TBD6',
          'TBD7',
          'TBD8',
          'TBD9'
          ) AND
          zbcc.lotatt01 <> '' AND
          zbcc.active = 'Y' AND
          zbccd.active = 'Y' AND
          zbccd.spName = 'CML_BILLTRFBAGGINGSTD' AND
          dah.status IN ('99') AND
          dah.editTime > getBillFMDate(25) AND
          NOT EXISTS (SELECT 1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = 'OJV_CML' AND
              bs.warehouseId = dah.warehouseId AND
              bs.customerId = dah.customerId AND
              bs.docNo = dah.tdocNo AND
              bs.chargeCategory = 'TD' AND
              DATE(bs.addTime) >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
    ORDER BY dah.editTime ASC;


    -- Handler untuk kondisi NOT FOUND
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Buka cursor
    OPEN billing_cursor;

    -- Loop untuk memproses setiap baris
    read_loop:
    LOOP
      -- Fetch data dari cursor
      FETCH billing_cursor INTO v_organizationId,
      v_warehouseId,
      v_customerId,
      v_trans_no,
      v_spName;

      -- Jika tidak ada data lagi, keluar dari loop
      IF done
      THEN

        LEAVE read_loop;
      END IF;




      SET @IN_organizationId = v_organizationId;
      SET @IN_warehouseId = v_warehouseId;
      SET @IN_USERID = 'CUSTOMBILL';
      SET @IN_Language = 'en';
      SET @IN_CustomerId = v_customerId;
      SET @IN_trans_no = v_trans_no;
      CALL CML_BILLTRFBAGGINGSTD_NW(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @p_success_flag, @p_message, @p_record_count);


    END LOOP;


    -- Tutup cursor
    CLOSE billing_cursor;



  END
  $$

--
-- Create procedure `CML_BILLSOVASSTD_NW`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLSOVASSTD_NW
(
                 IN IN_organizationId varchar(30), IN IN_warehouseId varchar(30), IN IN_USERID varchar(30), IN IN_Language varchar(30), IN IN_CustomerId varchar(30), IN IN_trans_no varchar(30), OUT p_success_flag char(1), OUT p_message varchar(1000), OUT p_record_count int
)
BEGIN
  -- =============================================
  -- Stored Procedure: CML_BILLSOVASSTD_NW
  -- Purpose: Process outbound billing for customers based on shipment transactions
  -- Author: [Akbar@IT-LINC]
  -- Date: [04.09.25]
  -- =============================================

  -- Variable declarations
  DECLARE v_billing_summary_id varchar(30) DEFAULT '';
  DECLARE v_return_code varchar(1000);
  DECLARE v_row_count int DEFAULT 0;
  DECLARE v_error_code varchar(5);
  DECLARE v_error_msg varchar(1000);
  DECLARE v_start_time timestamp DEFAULT NOW();
  DECLARE v_end_time timestamp;
  DECLARE v_execution_time decimal(10, 3);

  -- Declare handlers for exceptions
  DECLARE EXIT HANDLER FOR SQLEXCEPTION

  BEGIN
    -- Get error information
    GET DIAGNOSTICS CONDITION 1
    v_error_code = RETURNED_SQLSTATE,
    v_error_msg = MESSAGE_TEXT;

    -- Rollback transaction
    ROLLBACK;

    -- Set output parameters
    SET p_success_flag = 'N';
    SET p_message = CONCAT('Error Code: ', v_error_code, ' - ', v_error_msg);
    SET p_record_count = 0;

  -- Log error (optional)
  --         INSERT INTO ERROR_LOG (procedure_name, error_code, error_message, error_time, parameters)
  --         VALUES ('CML_BILLHOSTD_BETA', v_error_code, v_error_msg, NOW(), 
  --                 CONCAT('Org:', IN_organizationId, '|WH:', IN_warehouseId, 
  --                       '|Cust:', IN_CustomerId, '|Trans:', IN_trans_no));
  END;

  -- Initialize output parameters
  SET p_success_flag = 'N';
  SET p_message = '';
  SET p_record_count = 0;




  -- Validate input parameters
  IF IN_organizationId IS NULL OR
  IN_organizationId = ''
  THEN
    SET p_message = 'Organization ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_CustomerId IS NULL OR
  IN_CustomerId = ''
  THEN
    SET p_message = 'Customer ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_trans_no IS NULL OR
  IN_trans_no = ''
  THEN
    SET p_message = 'Transaction number cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  -- Start transaction
  START TRANSACTION;

  BEGIN
    -- Initialize row counter
    SET @row_num = 0;

    -- Generate billing summary ID
    SET v_return_code = '*_*';
    CALL SPCOM_GetIDSequence_NEW(IN_organizationId, '*', IN_Language, 'BILLINGSUMMARYIDCUST', v_billing_summary_id, v_return_code);

    -- Check if ID generation was successful
    IF v_return_code NOT LIKE '000%'
    THEN
      SET p_message = CONCAT('Failed to generate billing summary ID. Return code: ', v_return_code);
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
    END IF;

    DROP TEMPORARY TABLE IF EXISTS temp_billing_data;
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_billing_data AS
    SELECT dov.organizationId,
    dov.warehouseId,
    doh.customerId,
    dov.orderNo,
    dahu.closeTime,
    dod.sku,
    dov.vasType,
    dov.vasQty AS qtyChargeBilling,
    dov.orderLineNo AS lineNo,
    bsm.tariffMasterId,
    bil.tariffId,
    bcm.codeDescr,
    bil.chargeCategory, bil.chargeType,
    bil.rate,
    'QUANTITY' AS ratebase,
    0 cost,
    1 AS rateperunit,
    bil.udf01,
    bil.udf06, NULL incomeTaxRate
    FROM DOC_ORDER_VAS dov
         INNER JOIN
         DOC_ORDER_HEADER doh
         ON dov.organizationId = doh.organizationId AND
           dov.warehouseId = doh.warehouseId AND
           dov.orderNo = doh.orderNo
         INNER JOIN
         DOC_ORDER_DETAILS dod
         ON dov.organizationId = dod.organizationId AND
           dov.warehouseId = dod.warehouseId AND
           dov.orderNo = dod.orderNo AND
           dov.orderLineNo = dod.orderLineNo
         LEFT OUTER JOIN
         BAS_SKU_MULTIWAREHOUSE bsm
         ON bsm.organizationId = doh.organizationId AND
           bsm.warehouseId = doh.warehouseId AND
           bsm.customerId = doh.customerId AND
           bsm.SKU = dod.Sku
         INNER JOIN
         (SELECT btd.organizationId, btd.warehouseId, bth.tariffMasterId, btd.tariffId, btr.rate, btd.chargeCategory, btd.chargeType, btd.vasType, btd.udf01, btd.udf06
       FROM BIL_TARIFF_HEADER bth
            LEFT JOIN
            BIL_TARIFF_DETAILS btd
            ON btd.organizationId = bth.organizationId
              AND
              btd.tariffId = bth.tariffId
            LEFT JOIN
            BIL_TARIFF_RATE btr
            ON btr.organizationId = btd.organizationId
              AND
              btr.tariffId = btd.tariffId
              AND
              btr.tariffLineNo = btd.tariffLineNo
       WHERE btd.organizationId = 'OJV_CML' AND
             bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
             bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
             btd.chargeCategory = 'VA' AND
             btd.vasType <> '' AND
             btd.tariffLineNo <= 100 AND
             btr.rate > 0
       GROUP BY btd.organizationId, btd.warehouseId, btd.tariffId, btr.rate, btd.chargeCategory, btd.chargeType, btd.vasType, btd.udf01, btd.UDF06) bil
         ON bil.organizationId = bsm.organizationId AND
           bil.warehouseId = bsm.warehouseId AND
           bil.tariffMasterId = bsm.tariffMasterId AND
           bil.vasType = dov.vasType
         INNER JOIN
         BSM_CODE_ML bcm
         ON dov.organizationId = bcm.organizationId AND
           bcm.codeType = 'VAS_TYP' AND
           bcm.codeid = dov.vasType AND
           bcm.languageId = 'en'
         INNER JOIN
         DOC_ORDER_HEADER_UDF dahu
         ON dov.organizationId = dahu.organizationId AND
           dov.warehouseId = dahu.warehouseId AND
           dov.orderNo = dahu.orderNo
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING zbcc
         ON (dov.organizationId = zbcc.organizationId AND
           dov.warehouseId = zbcc.warehouseId AND
           doh.customerId = zbcc.customerId)
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
         ON (zbcc.organizationId = zbccd.organizationId AND
           zbcc.lotatt01 = zbccd.idGroupSp)
    WHERE dov.organizationId = IN_organizationId AND
          dov.warehouseId = IN_warehouseId AND
          doh.customerId = IN_CustomerId AND
          DATE(dahu.closeTime) >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND
          zbcc.lotatt01 <> '' AND
          zbcc.active = 'Y' AND
          zbccd.active = 'Y' AND
          doh.soStatus IN ('99') AND
          doh.orderType NOT IN ('FREE') AND
          zbccd.spName = 'CML_BILLSOVASSTD' AND
          doh.orderNo = IN_trans_no;



    -- Insert billing summary data
    INSERT INTO BIL_SUMMARY (organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate,
    customerId, sku, lotNum, traceId, tariffId, chargeCategory, chargeType,
    descr, rateBase, chargePerUnits, qty, uom, cubic, weight, chargeRate,
    amount, billingAmount, cost, amountPayable, amountPaid, confirmTime,
    confirmWho, docType, docNo, createTransactionid, notes, ediSendTime,
    billTo, settleTime, settleWho, followUp, invoiceType, paidTo,
    costConfirmFlag, costConfirmTime, costConfirmWho, costSettleFlag,
    costSettleTime, costSettleWho, incomeTaxRate, costTaxRate, incomeTax,
    cosTax, incomeWithoutTax, cosWithoutTax, costInvoiceType, noteText,
    udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag,
    addWho, addTime, editWho, editTime, locationCategory, manual,
    docLineNo, arNo, arLineNo, apNo, apLineNo, ediSendFlag,
    ediErrorCode, ediErrorMessage, ediSendTime2, ediSendFlag2,
    ediErrorCode2, ediErrorMessage2, billingTranCategory, orderType,
    containerType, containerSize)
           SELECT organizationId,
           warehouseId,
           CONCAT(v_billing_summary_id, '*', LPAD(auto_sequence(), 3, '0')) AS billingSummaryId,
           DATE(closeTime) AS billingFromDate,
           DATE(closeTime) AS billingToDate,
           customerId,
           sku,
           '' lotNum,
           '' traceId,
           tariffId,
           chargeCategory,
           chargeType,
           codeDescr AS descr,
           ratebase AS rateBase,
           rateperunit AS chargePerUnits,
           qtyChargeBilling AS qty,
           'EA' uom,
           0 AS cubic,
           0 AS weight,
           rate AS chargeRate,
           qtyChargeBilling * rate / ratePerUnit AS amount,
           (qtyChargeBilling * (rate / ratePerUnit)) +
           (qtyChargeBilling * (rate / ratePerUnit)) * incomeTaxRate / 100 AS billingAmount,
           cost,
           cost * qtyChargeBilling AS amountPayable,
           0 AS amountPaid,
           NOW() AS confirmTime,
           IN_USERID AS confirmWho,
           'SO' AS docType,
           orderNo AS docNo,
           '' AS createTransactionid,
           '' AS notes,
           NOW() AS ediSendTime,
           customerId AS billTo,
           NOW() AS settleTime,
           IN_USERID AS settleWho,
           '' AS followUp,
           '' AS invoiceType,
           '' AS paidTo,
           'N' AS costConfirmFlag,
           NOW() AS costConfirmTime,
           '' AS costConfirmWho,
           'N' AS costSettleFlag,
           NOW() AS costSettleTime,
           '' AS costSettleWho,
           0 AS incomeTaxRate,
           0 AS costTaxRate,
           qtyChargeBilling * rate / ratePerUnit * incomeTaxRate / 100 AS incomeTax,
           0 AS cosTax,
           qtyChargeBilling * rate / ratePerUnit AS incomeWithoutTax,
           0 AS cosWithoutTax,
           '' AS costInvoiceType,
           '' AS noteText,
           udf01 AS udf01,
           '' AS udf02,
           '' AS udf03,
           udf06 AS udf04,
           '' AS udf05,
           100 AS currentVersion,
           '2020' AS oprSeqFlag,
           IN_USERID AS addWho,
           NOW() AS addTime,
           IN_USERID AS editWho,
           NOW() AS editTime,
           '' locationCategory,
           'N' AS manual,
           0 AS docLineNo,
           '*' AS arNo,
           0 AS arLineNo,
           '*' AS apNo,
           0 AS apLineNo,
           'N' AS ediSendFlag,
           '' AS ediErrorCode,
           '' AS ediErrorMessage,
           NOW() AS ediSendTime2,
           'N' AS ediSendFlag2,
           '' AS ediErrorCode2,
           '' AS ediErrorMessage2,
           '' AS billingTranCategory,
           '' docType,
           '' AS containerType,
           '' AS containerSize
           FROM temp_billing_data
           WHERE qtyChargeBilling > 0;  -- Only insert records with positive billing quantity

    -- Get the number of inserted rows
    SET v_row_count = ROW_COUNT();

    -- Clean up temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_billing_data;

    -- Check if any rows were inserted
    IF v_row_count = 0
    THEN
      -- No data found, but this might be expected
      SET p_message = CONCAT('No billing data found for Vas SO: ', IN_trans_no, ', Customer: ', IN_CustomerId);
      SET p_success_flag = 'W'; -- Warning flag
      SET p_record_count = 0;
      COMMIT; -- Commit even if no rows

    --   CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLSOVASSTD_NW', IN_trans_no, 'error', NULL, NULL, p_success_flag,
    -- p_message, p_record_count, v_start_time, v_end_time);
    ELSE
      -- Calculate execution time
      SET v_end_time = NOW();
      SET v_execution_time = TIMESTAMPDIFF(MICROSECOND, v_start_time, v_end_time) / 1000000;

      -- Commit transaction
      COMMIT;

      -- Set success output parameters
      SET p_success_flag = 'Y';
      SET p_message = CONCAT('VasSO billing processed successfully. ', 'Billing Summary ID: ', v_billing_summary_id, '. Records: ', v_row_count, '. Execution time: ', v_execution_time, ' seconds');
      SET p_record_count = v_row_count;

    --           CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId,IN_CustomerId,'CML_BILLHISTD_TYPE2',IN_trans_no,'no error',NULL,NULL,p_success_flag,
    --             p_message,p_record_count,v_start_time,v_end_time);


    END IF;



  END;

END
$$

--
-- Create procedure `Z_SP_ProcessBillingCML_BILLSOVASSTD`
--
CREATE
DEFINER = 'mysql.sys'@'%'
PROCEDURE Z_SP_ProcessBillingCML_BILLSOVASSTD()
  SP:
  BEGIN
    -- Deklarasi variabel untuk menyimpan data dari cursor
    DECLARE v_organizationId varchar(20);
    DECLARE v_warehouseId varchar(20);
    DECLARE v_customerId varchar(30);
    DECLARE v_trans_no varchar(20);
    DECLARE v_spName varchar(30);
    DECLARE v_flag int DEFAULT 0;
    -- Variabel untuk mengontrol loop
    DECLARE done int DEFAULT FALSE;



    -- Deklarasi cursor
    DECLARE billing_cursor CURSOR FOR SELECT DISTINCT dov.organizationId, dov.warehouseId, doh.customerId, dov.orderNo, zbccd.spName
    FROM DOC_ORDER_VAS dov
         INNER JOIN
         DOC_ORDER_HEADER doh
         ON dov.organizationId = doh.organizationId
           AND
           dov.warehouseId = doh.warehouseId
           AND
           dov.orderNo = doh.orderNo
         INNER JOIN
         DOC_ORDER_HEADER_UDF dahu
         ON dov.organizationId = dahu.organizationId
           AND
           dov.warehouseId = dahu.warehouseId
           AND
           dov.orderNo = dahu.orderNo
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING zbcc
         ON (dov.organizationId = zbcc.organizationId AND
           dov.warehouseId = zbcc.warehouseId AND
           doh.customerId = zbcc.customerId)
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
         ON (zbcc.organizationId = zbccd.organizationId AND
           zbcc.lotatt01 = zbccd.idGroupSp)
    WHERE dov.organizationId = 'OJV_CML' AND
          DATE(dahu.closeTime) > getBillFMDate(25) AND
          zbcc.lotatt01 <> '' AND
          zbcc.active = 'Y' AND
          zbccd.active = 'Y' AND
          doh.soStatus IN ('99') AND
          doh.orderType NOT IN ('FREE') AND
          zbccd.spName = 'CML_BILLSOVASSTD' AND
          NOT EXISTS (SELECT 1
        FROM BIL_SUMMARY
        WHERE organizationId = doh.organizationId AND
              warehouseId = doh.warehouseId AND
              customerId = doh.customerId AND
              chargeCategory = 'VA' AND
              docNo = dov.orderNo AND
              docType = 'SO' AND
              addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH));


    -- Handler untuk kondisi NOT FOUND
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Buka cursor
    OPEN billing_cursor;

    -- Loop untuk memproses setiap baris
    read_loop:
    LOOP
      -- Fetch data dari cursor
      FETCH billing_cursor INTO v_organizationId,
      v_warehouseId,
      v_customerId,
      v_trans_no,
      v_spName;

      -- Jika tidak ada data lagi, keluar dari loop
      IF done
      THEN

        LEAVE read_loop;
      END IF;




      SET @IN_organizationId = 'OJV_CML';
      SET @IN_warehouseId = v_warehouseId;
      SET @IN_USERID = 'CUSTOMBILL';
      SET @IN_Language = 'en';
      SET @IN_CustomerId = v_customerId;
      SET @IN_trans_no = v_trans_no;
      CALL CML_BILLSOVASSTD_NW(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @p_success_flag, @p_message, @p_record_count);


    END LOOP;


    -- Tutup cursor
    CLOSE billing_cursor;



  END
  $$

--
-- Create procedure `CML_BILLHOSTD_TYPE2_NW`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLHOSTD_TYPE2_NW
(
                 IN IN_organizationId varchar(30), IN IN_warehouseId varchar(30), IN IN_USERID varchar(30), IN IN_Language varchar(30), IN IN_CustomerId varchar(30), IN IN_trans_no varchar(30), OUT p_success_flag char(1), OUT p_message varchar(1000), OUT p_record_count int
)
BEGIN
  -- =============================================
  -- Stored Procedure: CML_BILLHOSTD_TYPE2
  -- Purpose: Process outbound billing for customers based on shipment transactions
  -- Author: [Akbar@IT-LINC]
  -- Date: [27.08.25]
  -- =============================================

  -- Variable declarations
  DECLARE v_billing_summary_id varchar(30) DEFAULT '';
  DECLARE v_return_code varchar(1000);
  DECLARE v_row_count int DEFAULT 0;
  DECLARE v_error_code varchar(5);
  DECLARE v_error_msg varchar(1000);
  DECLARE v_start_time timestamp DEFAULT NOW();
  DECLARE v_end_time timestamp;
  DECLARE v_execution_time decimal(10, 3);

  -- Declare handlers for exceptions
  DECLARE EXIT HANDLER FOR SQLEXCEPTION

  BEGIN
    -- Get error information
    GET DIAGNOSTICS CONDITION 1
    v_error_code = RETURNED_SQLSTATE,
    v_error_msg = MESSAGE_TEXT;

    -- Rollback transaction
    ROLLBACK;

    -- Set output parameters
    SET p_success_flag = 'N';
    SET p_message = CONCAT('Error Code: ', v_error_code, ' - ', v_error_msg);
    SET p_record_count = 0;

  -- Log error (optional)
  --         INSERT INTO ERROR_LOG (procedure_name, error_code, error_message, error_time, parameters)
  --         VALUES ('CML_BILLHOSTD_BETA', v_error_code, v_error_msg, NOW(), 
  --                 CONCAT('Org:', IN_organizationId, '|WH:', IN_warehouseId, 
  --                       '|Cust:', IN_CustomerId, '|Trans:', IN_trans_no));
  END;

  -- Initialize output parameters
  SET p_success_flag = 'N';
  SET p_message = '';
  SET p_record_count = 0;




  -- Validate input parameters
  IF IN_organizationId IS NULL OR
  IN_organizationId = ''
  THEN
    SET p_message = 'Organization ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_CustomerId IS NULL OR
  IN_CustomerId = ''
  THEN
    SET p_message = 'Customer ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_trans_no IS NULL OR
  IN_trans_no = ''
  THEN
    SET p_message = 'Transaction number cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  -- Start transaction
  START TRANSACTION;

  BEGIN
    -- Initialize row counter
    SET @row_num = 0;

    -- Generate billing summary ID
    SET v_return_code = '*_*';
    CALL SPCOM_GetIDSequence_NEW(IN_organizationId, '*', IN_Language, 'BILLINGSUMMARYIDCUST', v_billing_summary_id, v_return_code);

    -- Check if ID generation was successful
    IF v_return_code NOT LIKE '000%'
    THEN
      SET p_message = CONCAT('Failed to generate billing summary ID. Return code: ', v_return_code);
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
    END IF;


    CREATE TEMPORARY TABLE IF NOT EXISTS temp_billing_data AS

    SELECT doh.organizationId,
    doh.warehouseId,
    aad.customerId,
    doh.orderNo,
    doh.soReference1,
    doh.soReference3,
    doh.orderType,
    t1.codeType AS docType,
    '' orderLineNo,
    '' SKU,
    DATE_FORMAT(doh.editTime, '%Y-%m-%d') AS ShipmentTime,
    SUM(aad.qty) AS qty,
    SUM(aad.qty_each) AS qty_each,
    SUM(aad.qtyShipped_each) AS qtyShipped_each,
    '' uom,
    0 qtyChargeCS,
    0 AS qtyChargeIP,
    0 qtyChargePL,
    0 qtyChargeCBM,
    0 qtyChargeTotDO,
    0 qtyChargeTotLine,
    0 totalCube,

    '' editTime,
    '' lotNum,
    '' traceId,
    '' pickToTraceId,
    '' dropId,
    '' location,
    '' pickToLocation,
    '' allocationDetailsId,
    '' skuDescr1,
    0 grossWeight,
    0 cubeNya,
    '' tariffMasterId,
    0 QtyPerCases,
    0 QtyPerPallet,
    '' zone,
    '' batch,
    '' lotAtt07,
    '' billtranctg,
    0 qtyChargeNettWeight,
    CASE
         WHEN btd.ratebase = 'DO' AND
              aad.customerId IN ('ECMAMAB2C') THEN CEIL(SUM(aad.qty_each / btr.classTo))
         WHEN btd.ratebase = 'DO' AND
              aad.customerId NOT IN ('ECMAMAB2C') THEN COUNT(DISTINCT doh.orderNo)
         WHEN btd.ratebase = 'DID' THEN COUNT(DISTINCT aad.dropId)
         WHEN btd.ratebase = 'DID1' AND
              aad.customerId IN ('TMB_SMG') THEN COUNT(DISTINCT aad.dropId)
         ELSE 0
    END AS qtyChargeBilling,
    -- Tariff details
    btr.rate,
    btd.ratebase,
    btr.tariffId,
    btr.tariffLineNo,
    btr.tariffClassNo,
    btd.chargeCategory,
    btd.chargeType,
    btd.descrC,
    btr.ratePerUnit,
    btd.minAmount,
    btd.maxAmount,
    IF(btd.UDF03 = '', 0, btd.UDF03) AS minQty,
    btd.UDF01,
    btd.udf02,
    btd.udf04,
    btd.UDF05,
    btd.UDF06,
    btd.UDF07,
    btd.UDF08,
    IFNULL(btd.incomeTaxRate, 0) AS IncomeTaxRate,
    '' classFrom,
    '' classTo,
    '' contractNo,
    btr.cost,
    '' billingParty,
    '' locationCategory
    FROM ACT_ALLOCATION_DETAILS aad
         -- All the joins from original query
         INNER JOIN
         DOC_ORDER_HEADER doh
         ON doh.organizationId = aad.organizationId AND
           doh.customerId = aad.customerId AND
           doh.orderNo = aad.orderNo AND
           doh.orderType NOT IN ('FREE', 'KT', 'TROF', 'TTG')
         LEFT JOIN
         DOC_ORDER_HEADER_UDF df
         ON doh.organizationId = df.organizationId AND
           doh.warehouseId = df.warehouseId AND
           doh.orderNo = df.orderNo
         INNER JOIN
         BAS_SKU bs
         ON bs.organizationId = aad.organizationId AND
           bs.SKU = aad.SKU AND
           bs.customerId = aad.customerId AND
           bs.skuDescr1 NOT LIKE '%PALLET%'
         INNER JOIN
         BAS_SKU_MULTIWAREHOUSE bsm
         ON bsm.organizationId = bs.organizationId AND
           bsm.SKU = bs.SKU AND
           bsm.customerId = bs.customerId AND
           bsm.warehouseId = aad.warehouseId
         LEFT JOIN
         INV_LOT_ATT ila
         ON ila.organizationId = aad.organizationId AND
           ila.SKU = aad.SKU AND
           ila.lotnum = aad.lotnum AND
           ila.customerId = aad.customerId AND
           (ila.lotAtt04 IS NULL OR
           ila.lotAtt04 != 'SET')
         LEFT JOIN
         BAS_PACKAGE_DETAILS bpdEA
         ON bpdEA.organizationId = bs.organizationId AND
           bpdEA.packId = bs.packId AND
           bpdEA.customerId = bs.customerId AND
           bpdEA.packUom = 'EA'
         LEFT JOIN
         BAS_PACKAGE_DETAILS bpdIP
         ON bpdIP.organizationId = bs.organizationId AND
           bpdIP.packId = bs.packId AND
           bpdIP.customerId = bs.customerId AND
           bpdIP.packUom = 'IP'
         LEFT JOIN
         BAS_PACKAGE_DETAILS bpdCS
         ON bpdCS.organizationId = bs.organizationId AND
           bpdCS.packId = bs.packId AND
           bpdCS.customerId = bs.customerId AND
           bpdCS.packUom = 'CS'
         LEFT JOIN
         BAS_PACKAGE_DETAILS bpdPL
         ON bpdPL.organizationId = bs.organizationId AND
           bpdPL.packId = bs.packId AND
           bpdPL.customerId = bs.customerId AND
           bpdPL.packUom = 'PL'
         LEFT JOIN
         BSM_CODE_ML t1
         ON t1.organizationId = 'OJV_CML' AND
           t1.codeType = 'SO_TYP' AND
           t1.codeId = doh.orderType AND
           t1.languageId = 'en'
         LEFT JOIN
         BSM_CODE BT
         ON BT.organizationId = 'OJV_CML' AND
           BT.codeType = 'BILLING_TRANSACTION_CATEGORY' AND
           BT.outerCode = ila.lotAtt07
         LEFT JOIN
         BAS_LOCATION bl
         ON bl.organizationId = aad.organizationId AND
           bl.warehouseId = aad.warehouseId AND
           bl.locationId = aad.location
         LEFT JOIN
         BAS_ZONE bz
         ON bz.organizationId = bl.organizationId AND
           bz.warehouseId = bl.warehouseId AND
           bz.zoneId = bl.zoneId AND
           bz.zoneGroup = bl.zoneGroup
         LEFT JOIN
         BIL_TARIFF_HEADER bth
         ON bth.organizationId = bsm.organizationId AND
           bth.tariffMasterId = bsm.tariffMasterId
         LEFT JOIN
         BIL_TARIFF_DETAILS btd
         ON btd.organizationId = bth.organizationId AND
           btd.tariffId = bth.tariffId AND
           btd.docType = doh.orderType
         LEFT JOIN
         BIL_TARIFF_RATE btr
         ON btr.organizationId = btd.organizationId AND
           btr.tariffId = btd.tariffId AND
           btr.tariffLineNo = btd.tariffLineNo
    WHERE aad.organizationId = IN_organizationId AND
          aad.warehouseId = IN_warehouseId AND
          aad.customerId = IN_CustomerId AND
          aad.orderNo = IN_trans_no AND
          aad.Status IN ('99', '80') AND
          bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
          bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
          btd.chargeCategory = 'OB' AND
          (
          btd.billingTranCategory IS NULL OR
          btd.billingTranCategory = '' OR
          btd.billingTranCategory = BT.codeid
          ) AND
          btr.rate > 0 AND
          NOT EXISTS (SELECT 1
        FROM Z_SKUNOTBILLING zsnb
        WHERE zsnb.organizationId = aad.organizationId AND
              zsnb.customerId = aad.customerId AND
              zsnb.sku = aad.sku)
    GROUP BY doh.organizationId, doh.orderNo, doh.soReference1, doh.soReference3, doh.orderType, doh.warehouseId, aad.customerId, doh.editTime, bsm.tariffMasterId, btr.rate, btd.ratebase, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo, btd.chargeCategory, btd.chargeType, btd.descrC, btr.ratePerUnit, btd.minAmount, btd.maxAmount, btd.UDF03, btd.UDF01, btd.udf02, btd.udf04, btd.UDF05, btd.UDF06, btd.UDF07, btd.UDF08, btd.incomeTaxRate, bth.contractNo, bth.tariffMasterId, btr.cost, bl.locationCategory;


    -- Insert billing summary data
    INSERT INTO BIL_SUMMARY (organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate,
    customerId, sku, lotNum, traceId, tariffId, chargeCategory, chargeType,
    descr, rateBase, chargePerUnits, qty, uom, cubic, weight, chargeRate,
    amount, billingAmount, cost, amountPayable, amountPaid, confirmTime,
    confirmWho, docType, docNo, createTransactionid, notes, ediSendTime,
    billTo, settleTime, settleWho, followUp, invoiceType, paidTo,
    costConfirmFlag, costConfirmTime, costConfirmWho, costSettleFlag,
    costSettleTime, costSettleWho, incomeTaxRate, costTaxRate, incomeTax,
    cosTax, incomeWithoutTax, cosWithoutTax, costInvoiceType, noteText,
    udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag,
    addWho, addTime, editWho, editTime, locationCategory, manual,
    docLineNo, arNo, arLineNo, apNo, apLineNo, ediSendFlag,
    ediErrorCode, ediErrorMessage, ediSendTime2, ediSendFlag2,
    ediErrorCode2, ediErrorMessage2, billingTranCategory, orderType,
    containerType, containerSize)
           SELECT organizationId,
           warehouseId,
           CONCAT(v_billing_summary_id, '*', LPAD(auto_sequnce(), 3, '0')) AS billingSummaryId,
           DATE_FORMAT(shipmentTime, '%Y-%m-%d') AS billingFromDate,
           DATE_FORMAT(shipmentTime, '%Y-%m-%d') AS billingToDate,
           customerId,
           sku,
           lotNum,
           traceId,
           tariffId,
           chargeCategory,
           chargeType,
           descrC AS descr,
           ratebase AS rateBase,
           ratePerUnit AS chargePerUnits,
           qtyChargeBilling AS qty,
           uom,
           totalCube AS cubic,
           grossWeight AS weight,
           rate AS chargeRate,
           qtyChargeBilling * rate / ratePerUnit AS amount,
           (qtyChargeBilling * (rate / ratePerUnit)) +
           (qtyChargeBilling * (rate / ratePerUnit)) * incomeTaxRate / 100 AS billingAmount,
           cost,
           cost * qtyChargeBilling AS amountPayable,
           0 AS amountPaid,
           NOW() AS confirmTime,
           IN_USERID AS confirmWho,
           'SO' AS docType,
           orderNo AS docNo,
           '' AS createTransactionid,
           CONCAT('Trans:', IN_trans_no, '|User:', IN_USERID) AS notes,
           NOW() AS ediSendTime,
           customerId AS billTo,
           NOW() AS settleTime,
           IN_USERID AS settleWho,
           '' AS followUp,
           '' AS invoiceType,
           '' AS paidTo,
           'N' AS costConfirmFlag,
           NOW() AS costConfirmTime,
           '' AS costConfirmWho,
           'N' AS costSettleFlag,
           NOW() AS costSettleTime,
           '' AS costSettleWho,
           incomeTaxRate AS incomeTaxRate,
           0 AS costTaxRate,
           qtyChargeBilling * rate / ratePerUnit * incomeTaxRate / 100 AS incomeTax,
           0 AS cosTax,
           qtyChargeBilling * rate / ratePerUnit AS incomeWithoutTax,
           0 AS cosWithoutTax,
           '' AS costInvoiceType,
           '' AS noteText,
           UDF01 AS udf01,
           udf02 AS udf02,
           allocationDetailsId AS udf03,
           UDF06 AS udf04,
           '' AS udf05,
           100 AS currentVersion,
           '2020' AS oprSeqFlag,
           IN_USERID AS addWho,
           NOW() AS addTime,
           IN_USERID AS editWho,
           NOW() AS editTime,
           locationCategory,
           'N' AS manual,
           0 AS docLineNo,
           '*' AS arNo,
           0 AS arLineNo,
           '*' AS apNo,
           0 AS apLineNo,
           'N' AS ediSendFlag,
           '' AS ediErrorCode,
           '' AS ediErrorMessage,
           NOW() AS ediSendTime2,
           'N' AS ediSendFlag2,
           '' AS ediErrorCode2,
           '' AS ediErrorMessage2,
           billtranctg AS billingTranCategory,
           orderType,
           '' AS containerType,
           '' AS containerSize
           FROM temp_billing_data
           WHERE qtyChargeBilling > 0;  -- Only insert records with positive billing quantity

    -- Get the number of inserted rows
    SET v_row_count = ROW_COUNT();

    -- Clean up temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_billing_data;

    -- Check if any rows were inserted
    IF v_row_count = 0
    THEN
      -- No data found, but this might be expected
      SET p_message = CONCAT('No billing data found for Order: ', IN_trans_no, ', Customer: ', IN_CustomerId);
      SET p_success_flag = 'W'; -- Warning flag
      SET p_record_count = 0;
      COMMIT; -- Commit even if no rows

      CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLHOSTD2', IN_trans_no, 'error', NULL, NULL, p_success_flag, p_message, p_record_count, v_start_time, v_end_time);
    ELSE
      -- Calculate execution time
      SET v_end_time = NOW();
      SET v_execution_time = TIMESTAMPDIFF(MICROSECOND, v_start_time, v_end_time) / 1000000;

      -- Commit transaction
      COMMIT;

      -- Set success output parameters
      SET p_success_flag = 'Y';
      SET p_message = CONCAT('Outbound billing processed successfully. ', 'Billing Summary ID: ', v_billing_summary_id, '. Records: ', v_row_count, '. Execution time: ', v_execution_time, ' seconds');
      SET p_record_count = v_row_count;

      CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLHOSTD2', IN_trans_no, 'no error', NULL, NULL, p_success_flag, p_message, p_record_count, v_start_time, v_end_time);


    END IF;



  END;

END
$$

--
-- Create procedure `Z_SP_ProcessBillingCML_BILLHOSTD_TYPE2`
--
CREATE
DEFINER = 'mysql.sys'@'%'
PROCEDURE Z_SP_ProcessBillingCML_BILLHOSTD_TYPE2()
  SP:
  BEGIN
    -- Deklarasi variabel untuk menyimpan data dari cursor
    DECLARE v_organizationId varchar(20);
    DECLARE v_warehouseId varchar(20);
    DECLARE v_customerId varchar(30);
    DECLARE v_trans_no varchar(20);
    DECLARE v_spName varchar(30);
    DECLARE v_flag int DEFAULT 0;
    -- Variabel untuk mengontrol loop
    DECLARE done int DEFAULT FALSE;



    -- Deklarasi cursor
    DECLARE billing_cursor CURSOR FOR SELECT doh.organizationId, doh.warehouseId, doh.customerId, doh.orderNo AS trans_no, zbccd.spName
    FROM DOC_ORDER_HEADER doh
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING zbcc
         ON (doh.organizationId = zbcc.organizationId AND
           doh.warehouseId = zbcc.warehouseId AND
           doh.customerId = zbcc.customerId)
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
         ON zbcc.organizationId = zbccd.organizationId
           AND
           zbcc.lotatt01 = zbccd.idGroupSp
    WHERE doh.organizationId = 'OJV_CML' AND
          doh.orderType NOT IN ('FREE', 'KT', 'TROF', 'TTG')
          --   doh.warehouseId='' AND
          AND doh.soStatus = '99' AND
          zbcc.lotatt01 <> '' AND
          zbcc.active = 'Y' AND
          zbccd.active = 'Y' AND
          zbccd.spName = 'CML_BILLHOSTD_TYPE2' AND
          DATE(doh.orderTime) > getBillFMDate(25) AND
          NOT EXISTS (SELECT 1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = 'OJV_CML' AND
              bs.docNo = doh.orderNo AND
              bs.warehouseId = doh.warehouseId AND
              bs.customerId = doh.customerId AND
              bs.chargeCategory = 'OB' AND
              bs.addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
    --  GROUP BY doh.organizationId,doh.warehouseId, doh.customerId,trans_no,zbccd.spName
    ORDER BY doh.orderTime ASC;



    -- Handler untuk kondisi NOT FOUND
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Buka cursor
    OPEN billing_cursor;

    -- Loop untuk memproses setiap baris
    read_loop:
    LOOP
      -- Fetch data dari cursor
      FETCH billing_cursor INTO v_organizationId,
      v_warehouseId,
      v_customerId,
      v_trans_no,
      v_spName;

      -- Jika tidak ada data lagi, keluar dari loop
      IF done
      THEN

        LEAVE read_loop;
      END IF;




      SET @IN_organizationId = 'OJV_CML';
      SET @IN_warehouseId = v_warehouseId;
      SET @IN_USERID = 'CUSTOMBILL';
      SET @IN_Language = 'en';
      SET @IN_CustomerId = v_customerId;
      SET @IN_trans_no = v_trans_no;
      CALL CML_BILLHOSTD_TYPE2_NW(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @p_success_flag, @p_message, @p_record_count);


    END LOOP;

    UPDATE Z_SP_BILLING_LOCK zsbl
      SET zsbl.flag = 0,
      zsbl.changeTime = NOW()
    WHERE zsbl.spName = 'CML_BILLHOSTD_TYPE2';
    -- Tutup cursor
    CLOSE billing_cursor;



  END
  $$

--
-- Create procedure `CML_BILLHOSTD_NW`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLHOSTD_NW
(
                 IN IN_organizationId varchar(30), IN IN_warehouseId varchar(30), IN IN_USERID varchar(30), IN IN_Language varchar(30), IN IN_CustomerId varchar(30), IN IN_trans_no varchar(30), OUT p_success_flag char(1), OUT p_message varchar(1000), OUT p_record_count int
)
BEGIN
  -- =============================================
  -- Stored Procedure: CML_BILLHOSTD_BETA
  -- Purpose: Process outbound billing for customers based on shipment transactions
  -- Author: [Akbar@IT-LINC]
  -- Date: [27.08.25]
  -- =============================================

  -- Variable declarations
  DECLARE v_billing_summary_id varchar(30) DEFAULT '';
  DECLARE v_return_code varchar(1000);
  DECLARE v_row_count int DEFAULT 0;
  DECLARE v_error_code varchar(5);
  DECLARE v_error_msg varchar(1000);
  DECLARE v_start_time timestamp DEFAULT NOW();
  DECLARE v_end_time timestamp;
  DECLARE v_execution_time decimal(10, 3);

  -- Declare handlers for exceptions
  DECLARE EXIT HANDLER FOR SQLEXCEPTION

  BEGIN
    -- Get error information
    GET DIAGNOSTICS CONDITION 1
    v_error_code = RETURNED_SQLSTATE,
    v_error_msg = MESSAGE_TEXT;

    -- Rollback transaction
    ROLLBACK;

    -- Set output parameters
    SET p_success_flag = 'N';
    SET p_message = CONCAT('Error Code: ', v_error_code, ' - ', v_error_msg);
    SET p_record_count = 0;

  -- Log error (optional)
  --         INSERT INTO ERROR_LOG (procedure_name, error_code, error_message, error_time, parameters)
  --         VALUES ('CML_BILLHOSTD_BETA', v_error_code, v_error_msg, NOW(), 
  --                 CONCAT('Org:', IN_organizationId, '|WH:', IN_warehouseId, 
  --                       '|Cust:', IN_CustomerId, '|Trans:', IN_trans_no));
  END;

  -- Initialize output parameters
  SET p_success_flag = 'N';
  SET p_message = '';
  SET p_record_count = 0;




  -- Validate input parameters
  IF IN_organizationId IS NULL OR
  IN_organizationId = ''
  THEN
    SET p_message = 'Organization ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_CustomerId IS NULL OR
  IN_CustomerId = ''
  THEN
    SET p_message = 'Customer ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_trans_no IS NULL OR
  IN_trans_no = ''
  THEN
    SET p_message = 'Transaction number cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  -- Start transaction
  START TRANSACTION;

  BEGIN
    -- Initialize row counter
    SET @row_num = 0;

    -- Generate billing summary ID
    SET v_return_code = '*_*';
    CALL SPCOM_GetIDSequence_NEW(IN_organizationId, '*', IN_Language, 'BILLINGSUMMARYIDCUST', v_billing_summary_id, v_return_code);

    -- Check if ID generation was successful
    IF v_return_code NOT LIKE '000%'
    THEN
      SET p_message = CONCAT('Failed to generate billing summary ID. Return code: ', v_return_code);
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
    END IF;


    CREATE TEMPORARY TABLE IF NOT EXISTS temp_billing_data AS
    SELECT doh.organizationId,
    doh.warehouseId,
    aad.customerId,
    doh.orderNo,
    doh.soReference1,
    doh.soReference3,
    doh.orderType,
    t1.codeType AS docType,
    aad.orderLineNo,
    aad.SKU,
    DATE_FORMAT(aad.shipmentTime, '%Y-%m-%d') AS ShipmentTime,
    aad.qty,
    aad.qty_each,
    aad.qtyShipped_each,
    aad.uom,

    -- Calculate quantities based on different UOM
    CASE
         WHEN aad.customerId = 'MAP' AND
              ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
              bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0))
         ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0))
    END AS qtyChargeEA,

    CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdCS.qty, 0))) AS qtyChargeCS,
    COALESCE(CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdIP.qty, 0))), 1) AS qtyChargeIP,
    CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdPL.qty, 0))) AS qtyChargePL,
    SUM(aad.qtyShipped_each * bs.cube) AS qtyChargeCBM,
    COUNT(DISTINCT doh.orderNo) AS qtyChargeTotDO,
    COUNT(DISTINCT aad.orderLineNo) AS qtyChargeTotLine,
    SUM(aad.qtyShipped_each * bs.cube) AS totalCube,

    aad.editTime,
    aad.lotNum,
    aad.traceId,
    aad.pickToTraceId,
    aad.dropId,
    aad.location,
    aad.pickToLocation,
    aad.allocationDetailsId,
    bs.skuDescr1,
    bs.grossWeight,
    bs.cube AS cubeNya,
    bsm.tariffMasterId,
    bpdCS.qty AS QtyPerCases,
    bpdPL.qty AS QtyPerPallet,
    bz.zoneDescr AS zone,
    ila.lotAtt04 AS batch,
    IFNULL(ila.lotAtt07, '') AS lotAtt07,
    IFNULL(BT.codeid, '') AS billtranctg,
    SUM(aad.qtyShipped_each * bs.netWeight) AS qtyChargeNettWeight,

    -- Gross weight calculation
    CASE
         WHEN bpdEA.uomDescr IN ('G', 'GRAM', 'Gram') THEN SUM(aad.qtyShipped_each / 1000)
         WHEN bpdEA.uomDescr IN ('MT', 'Metric Ton', 'METRIC TON') THEN SUM(aad.qtyShipped_each * 1000)
         ELSE SUM(aad.qtyShipped_each * bs.grossWeight)
    END AS qtyChargeGrossWeight,

    -- Metric ton calculation
    CASE
         WHEN aad.customerId LIKE '%ABC%' THEN SUM((aad.qtyShipped_each * bpdCS.qty) / 1000)
         WHEN aad.customerId IN ('ADASBY', 'CAI_MDN', 'CAI_SBY') THEN IFNULL(CAST(SUM((aad.qtyShipped_each * bs.netweight) / 1000) AS char(255)), 0)
         ELSE SUM(aad.qtyShipped_each / 1000)
    END AS qtyChargeMetricTon,

    df.closeTime,

    -- Calculate billing quantity based on rate base
    CASE
         WHEN btd.ratebase = 'CUBIC' THEN SUM(aad.qtyShipped_each * bs.cube)
         WHEN btd.ratebase = 'M2' THEN CASE
              WHEN aad.customerId = 'MAP' AND
                   ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
                   bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0))
              ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0))
         END
         WHEN btd.ratebase = 'IP' THEN COALESCE(CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdIP.qty, 0))), 1)
         WHEN btd.ratebase = 'KG' THEN CASE
              WHEN aad.customerId = 'MAP' AND
                   ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
                   bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0))
              ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0))
         END
         WHEN btd.ratebase = 'LITER' THEN CASE
              WHEN aad.customerId = 'MAP' AND
                   ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
                   bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0))
              WHEN aad.customerId = 'PPG' THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) * NULLIF(bs.sku_group6, 0)
              ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0))
         END
         WHEN btd.ratebase = 'QUANTITY' THEN CASE
              WHEN aad.customerId = 'MAP' AND
                   ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
                   bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0))
              ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0))
         END
         --  WHEN btd.ratebase = 'DO' THEN COUNT(DISTINCT doh.orderNo) * DO Ratebase cannot use this store procedure
         WHEN btd.ratebase = 'PALLET' THEN CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdPL.qty, 0)))
         WHEN btd.ratebase = 'CASE' THEN CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdCS.qty, 0)))
         WHEN btd.ratebase = 'NETWEIGHT' THEN SUM(aad.qtyShipped_each * bs.netWeight)
         WHEN btd.ratebase = 'GW' THEN CASE
              WHEN bpdEA.uomDescr IN ('G', 'GRAM', 'Gram') THEN SUM(aad.qtyShipped_each / 1000)
              WHEN bpdEA.uomDescr IN ('MT', 'Metric Ton', 'METRIC TON') THEN SUM(aad.qtyShipped_each * 1000)
              ELSE SUM(aad.qtyShipped_each * bs.grossWeight)
         END
         WHEN btd.ratebase = 'MT' THEN CASE
              WHEN aad.customerId LIKE '%ABC%' THEN SUM((aad.qtyShipped_each * bpdCS.qty) / 1000)
              WHEN aad.customerId IN ('ADASBY', 'CAI_MDN', 'CAI_SBY') THEN IFNULL(CAST(SUM((aad.qtyShipped_each * bs.netweight) / 1000) AS char(255)), 0)
              ELSE SUM(aad.qtyShipped_each / 1000)
         END
         ELSE 0
    END AS qtyChargeBilling,

    -- Tariff details
    btr.rate,
    btd.ratebase,
    btr.tariffId,
    btr.tariffLineNo,
    btr.tariffClassNo,
    btd.chargeCategory,
    btd.chargeType,
    btd.descrC,
    btr.ratePerUnit,
    btd.minAmount,
    btd.maxAmount,
    IF(btd.UDF03 = '', 0, btd.UDF03) AS minQty,
    btd.UDF01,
    btd.udf02,
    btd.udf04,
    btd.UDF05,
    btd.UDF06,
    btd.UDF07,
    btd.UDF08,
    IFNULL(btd.incomeTaxRate, 0) AS IncomeTaxRate,
    CASE
         WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1
         ELSE IFNULL(btr.classfrom, 0)
    END AS classFrom,
    IFNULL(classTo, 0) AS classTo,
    bth.contractNo,
    btr.cost,
    btd.billingParty,
    bl.locationCategory
    FROM ACT_ALLOCATION_DETAILS aad
         -- All the joins from original query
         INNER JOIN
         DOC_ORDER_HEADER doh
         ON doh.organizationId = aad.organizationId AND
           doh.customerId = aad.customerId AND
           doh.orderNo = aad.orderNo AND
           doh.orderType NOT IN ('FREE', 'KT', 'TROF', 'TTG')
         LEFT JOIN
         DOC_ORDER_HEADER_UDF df
         ON doh.organizationId = df.organizationId AND
           doh.warehouseId = df.warehouseId AND
           doh.orderNo = df.orderNo
         INNER JOIN
         BAS_SKU bs
         ON bs.organizationId = aad.organizationId AND
           bs.SKU = aad.SKU AND
           bs.customerId = aad.customerId AND
           bs.skuDescr1 NOT LIKE '%PALLET%'
         INNER JOIN
         BAS_SKU_MULTIWAREHOUSE bsm
         ON bsm.organizationId = bs.organizationId AND
           bsm.SKU = bs.SKU AND
           bsm.customerId = bs.customerId AND
           bsm.warehouseId = aad.warehouseId
         LEFT JOIN
         INV_LOT_ATT ila
         ON ila.organizationId = aad.organizationId AND
           ila.SKU = aad.SKU AND
           ila.lotnum = aad.lotnum AND
           ila.customerId = aad.customerId AND
           (ila.lotAtt04 IS NULL OR
           ila.lotAtt04 != 'SET')
         LEFT JOIN
         BAS_PACKAGE_DETAILS bpdEA
         ON bpdEA.organizationId = bs.organizationId AND
           bpdEA.packId = bs.packId AND
           bpdEA.customerId = bs.customerId AND
           bpdEA.packUom = 'EA'
         LEFT JOIN
         BAS_PACKAGE_DETAILS bpdIP
         ON bpdIP.organizationId = bs.organizationId AND
           bpdIP.packId = bs.packId AND
           bpdIP.customerId = bs.customerId AND
           bpdIP.packUom = 'IP'
         LEFT JOIN
         BAS_PACKAGE_DETAILS bpdCS
         ON bpdCS.organizationId = bs.organizationId AND
           bpdCS.packId = bs.packId AND
           bpdCS.customerId = bs.customerId AND
           bpdCS.packUom = 'CS'
         LEFT JOIN
         BAS_PACKAGE_DETAILS bpdPL
         ON bpdPL.organizationId = bs.organizationId AND
           bpdPL.packId = bs.packId AND
           bpdPL.customerId = bs.customerId AND
           bpdPL.packUom = 'PL'
         LEFT JOIN
         BSM_CODE_ML t1
         ON t1.organizationId = 'OJV_CML' AND
           t1.codeType = 'SO_TYP' AND
           t1.codeId = doh.orderType AND
           t1.languageId = 'en'
         LEFT JOIN
         BSM_CODE BT
         ON BT.organizationId = 'OJV_CML' AND
           BT.codeType = 'BILLING_TRANSACTION_CATEGORY' AND
           CASE
                WHEN aad.customerId = 'PPG' THEN BT.outerCode = aad.udf05
                ELSE BT.outerCode = ila.lotAtt07
           END
         LEFT JOIN
         BAS_LOCATION bl
         ON bl.organizationId = aad.organizationId AND
           bl.warehouseId = aad.warehouseId AND
           bl.locationId = aad.location
         LEFT JOIN
         BAS_ZONE bz
         ON bz.organizationId = bl.organizationId AND
           bz.warehouseId = bl.warehouseId AND
           bz.zoneId = bl.zoneId AND
           bz.zoneGroup = bl.zoneGroup
         LEFT JOIN
         BIL_TARIFF_HEADER bth
         ON bth.organizationId = bsm.organizationId AND
           bth.tariffMasterId = bsm.tariffMasterId
         LEFT JOIN
         BIL_TARIFF_DETAILS btd
         ON btd.organizationId = bth.organizationId AND
           btd.tariffId = bth.tariffId AND
           btd.docType = doh.orderType
         LEFT JOIN
         BIL_TARIFF_RATE btr
         ON btr.organizationId = btd.organizationId AND
           btr.tariffId = btd.tariffId AND
           btr.tariffLineNo = btd.tariffLineNo
    WHERE aad.organizationId = IN_organizationId AND
          aad.warehouseId = IN_warehouseId AND
          aad.customerId = IN_CustomerId AND
          aad.orderNo = IN_trans_no AND
          aad.Status IN ('99', '80') AND
          bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
          bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
          btd.chargeCategory = 'OB' AND
          (
          btd.billingTranCategory IS NULL OR
          btd.billingTranCategory = '' OR
          btd.billingTranCategory = BT.codeid OR
          btd.billingTranCategory = aad.udf05
          ) AND
          btr.rate > 0 AND
          NOT EXISTS (SELECT 1
        FROM Z_SKUNOTBILLING zsnb
        WHERE zsnb.organizationId = 'OJV_CML' AND
              zsnb.customerId = aad.customerId AND
              zsnb.sku = aad.sku)
    GROUP BY doh.organizationId, doh.orderNo, doh.soReference1, doh.soReference3, t1.codeid, doh.soStatus, doh.orderType, doh.warehouseId, aad.orderLineNo, aad.traceId, aad.pickToTraceId, aad.dropId, aad.customerId, aad.location, aad.pickToLocation, aad.shipmentTime, aad.allocationDetailsId, aad.SKU, aad.qty, aad.qty_each, aad.qtyShipped_each, aad.uom, aad.editTime, aad.lotNum, bsm.tariffMasterId, bs.skuDescr1, bs.grossWeight, bs.cube, t1.codeDescr, bz.zoneDescr, ila.lotAtt04, ila.lotAtt07, BT.codeid, df.closeTime, bs.netWeight, bpdEA.qty, bpdEA.uomDescr, bpdCS.qty, bpdIP.qty, bpdPL.qty, btr.rate, btd.ratebase, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo, btd.chargeCategory, btd.chargeType, btd.descrC, btr.ratePerUnit, btd.minAmount, btd.maxAmount, btd.UDF03, btd.UDF01, btd.udf02, btd.udf04, btd.UDF05, btd.UDF06, btd.UDF07, btd.UDF08, btd.incomeTaxRate, bth.contractNo, bth.tariffMasterId, btr.cost, bl.locationCategory;

    -- Insert billing summary data
    INSERT INTO BIL_SUMMARY (organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate,
    customerId, sku, lotNum, traceId, tariffId, chargeCategory, chargeType,
    descr, rateBase, chargePerUnits, qty, uom, cubic, weight, chargeRate,
    amount, billingAmount, cost, amountPayable, amountPaid, confirmTime,
    confirmWho, docType, docNo, createTransactionid, notes, ediSendTime,
    billTo, settleTime, settleWho, followUp, invoiceType, paidTo,
    costConfirmFlag, costConfirmTime, costConfirmWho, costSettleFlag,
    costSettleTime, costSettleWho, incomeTaxRate, costTaxRate, incomeTax,
    cosTax, incomeWithoutTax, cosWithoutTax, costInvoiceType, noteText,
    udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag,
    addWho, addTime, editWho, editTime, locationCategory, manual,
    docLineNo, arNo, arLineNo, apNo, apLineNo, ediSendFlag,
    ediErrorCode, ediErrorMessage, ediSendTime2, ediSendFlag2,
    ediErrorCode2, ediErrorMessage2, billingTranCategory, orderType,
    containerType, containerSize)
           SELECT organizationId,
           warehouseId,
           CONCAT(v_billing_summary_id, '*', LPAD(auto_sequence(), 3, '0')) AS billingSummaryId,
           DATE_FORMAT(ShipmentTime, '%Y-%m-%d') AS billingFromDate,
           DATE_FORMAT(ShipmentTime, '%Y-%m-%d') AS billingToDate,
           customerId,
           sku,
           lotNum,
           traceId,
           tariffId,
           chargeCategory,
           chargeType,
           descrC AS descr,
           ratebase AS rateBase,
           ratePerUnit AS chargePerUnits,
           qtyChargeBilling AS qty,
           uom,
           totalCube AS cubic,
           grossWeight AS weight,
           rate AS chargeRate,
           qtyChargeBilling * rate / ratePerUnit AS amount,
           (qtyChargeBilling * (rate / ratePerUnit)) +
           (qtyChargeBilling * (rate / ratePerUnit)) * IncomeTaxRate / 100 AS billingAmount,
           cost,
           cost * qtyChargeBilling AS amountPayable,
           0 AS amountPaid,
           NOW() AS confirmTime,
           IN_USERID AS confirmWho,
           docType AS docType,
           orderNo AS docNo,
           '' AS createTransactionid,
           CONCAT('Trans:', IN_trans_no, '|User:', IN_USERID) AS notes,
           NOW() AS ediSendTime,
           customerId AS billTo,
           NOW() AS settleTime,
           IN_USERID AS settleWho,
           '' AS followUp,
           '' AS invoiceType,
           '' AS paidTo,
           'N' AS costConfirmFlag,
           NOW() AS costConfirmTime,
           '' AS costConfirmWho,
           'N' AS costSettleFlag,
           NOW() AS costSettleTime,
           '' AS costSettleWho,
           IncomeTaxRate AS incomeTaxRate,
           0 AS costTaxRate,
           qtyChargeBilling * rate / ratePerUnit * IncomeTaxRate / 100 AS incomeTax,
           0 AS cosTax,
           qtyChargeBilling * rate / ratePerUnit AS incomeWithoutTax,
           0 AS cosWithoutTax,
           '' AS costInvoiceType,
           '' AS noteText,
           UDF01 AS udf01,
           udf02 AS udf02,
           allocationDetailsId AS udf03,
           UDF06 AS udf04,
           '' AS udf05,
           100 AS currentVersion,
           '2020' AS oprSeqFlag,
           IN_USERID AS addWho,
           NOW() AS addTime,
           IN_USERID AS editWho,
           NOW() AS editTime,
           locationCategory,
           'N' AS manual,
           0 AS docLineNo,
           '*' AS arNo,
           0 AS arLineNo,
           '*' AS apNo,
           0 AS apLineNo,
           'N' AS ediSendFlag,
           '' AS ediErrorCode,
           '' AS ediErrorMessage,
           NOW() AS ediSendTime2,
           'N' AS ediSendFlag2,
           '' AS ediErrorCode2,
           '' AS ediErrorMessage2,
           billtranctg AS billingTranCategory,
           orderType,
           '' AS containerType,
           '' AS containerSize
           FROM temp_billing_data
           WHERE qtyChargeBilling > 0;  -- Only insert records with positive billing quantity

    -- Get the number of inserted rows
    SET v_row_count = ROW_COUNT();

    -- Clean up temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_billing_data;

    -- Check if any rows were inserted
    IF v_row_count = 0
    THEN
      -- No data found, but this might be expected
      SET p_message = CONCAT('No billing data found for Order: ', IN_trans_no, ', Customer: ', IN_CustomerId);
      SET p_success_flag = 'W'; -- Warning flag
      SET p_record_count = 0;
      COMMIT; -- Commit even if no rows

      CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLHOSTD', IN_trans_no, 'error', NULL, NULL, p_success_flag, p_message, p_record_count, v_start_time, v_end_time);
    ELSE
      -- Calculate execution time
      SET v_end_time = NOW();
      SET v_execution_time = TIMESTAMPDIFF(MICROSECOND, v_start_time, v_end_time) / 1000000;

      -- Commit transaction
      COMMIT;

      -- Set success output parameters
      SET p_success_flag = 'Y';
      SET p_message = CONCAT('Outbound billing processed successfully. ', 'Billing Summary ID: ', v_billing_summary_id, '. Records: ', v_row_count, '. Execution time: ', v_execution_time, ' seconds');
      SET p_record_count = v_row_count;

      CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLHOSTD_NW', IN_trans_no, 'no error', NULL, NULL, p_success_flag, p_message, p_record_count, v_start_time, v_end_time);


    END IF;



  END;

END
$$

--
-- Create procedure `Z_SP_ProcessBillingCML_BILLHOSTD`
--
CREATE
DEFINER = 'mysql.sys'@'%'
PROCEDURE Z_SP_ProcessBillingCML_BILLHOSTD()
  SP:
  BEGIN
    -- Deklarasi variabel untuk menyimpan data dari cursor
    DECLARE v_organizationId varchar(20);
    DECLARE v_warehouseId varchar(20);
    DECLARE v_customerId varchar(30);
    DECLARE v_trans_no varchar(20);
    DECLARE v_spName varchar(30);
    DECLARE v_flag int DEFAULT 0;
    -- Variabel untuk mengontrol loop
    DECLARE done int DEFAULT FALSE;



    -- Deklarasi cursor
    DECLARE billing_cursor CURSOR FOR SELECT doh.organizationId, doh.warehouseId, doh.customerId, doh.orderNo AS trans_no, zbccd.spName
    FROM DOC_ORDER_HEADER doh
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING zbcc
         ON (doh.organizationId = zbcc.organizationId AND
           doh.warehouseId = zbcc.warehouseId AND
           doh.customerId = zbcc.customerId)
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
         ON zbcc.organizationId = zbccd.organizationId
           AND
           zbcc.lotatt01 = zbccd.idGroupSp
    WHERE doh.organizationId = 'OJV_CML' AND
          doh.orderType NOT IN ('FREE', 'KT', 'TROF', 'TTG')
          --   doh.warehouseId='' AND
          AND doh.soStatus = '99' AND
          zbcc.lotatt01 <> '' AND
          zbcc.active = 'Y' AND
          zbccd.active = 'Y' AND
          zbccd.spName = 'CML_BILLHOSTD' AND
          DATE(doh.editTime) > getBillFMDate(25) AND
          NOT EXISTS (SELECT 1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = 'OJV_CML' AND
              bs.docNo = doh.orderNo AND
              bs.warehouseId = doh.warehouseId AND
              bs.customerId = doh.customerId AND
              bs.chargeCategory = 'OB' AND
              bs.addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
    --  GROUP BY doh.organizationId,doh.warehouseId, doh.customerId,trans_no,zbccd.spName
    ORDER BY doh.orderTime ASC;



    -- Handler untuk kondisi NOT FOUND
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Buka cursor
    OPEN billing_cursor;

    -- Loop untuk memproses setiap baris
    read_loop:
    LOOP
      -- Fetch data dari cursor
      FETCH billing_cursor INTO v_organizationId,
      v_warehouseId,
      v_customerId,
      v_trans_no,
      v_spName;

      -- Jika tidak ada data lagi, keluar dari loop
      IF done
      THEN

        LEAVE read_loop;
      END IF;




      SET @IN_organizationId = 'OJV_CML';
      SET @IN_warehouseId = v_warehouseId;
      SET @IN_USERID = 'CUSTOMBILL';
      SET @IN_Language = 'en';
      SET @IN_CustomerId = v_customerId;
      SET @IN_trans_no = v_trans_no;
      CALL CML_BILLHOSTD_NW(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @p_success_flag, @p_message, @p_record_count);


    END LOOP;

    UPDATE Z_SP_BILLING_LOCK zsbl
      SET zsbl.flag = 0,
      zsbl.changeTime = NOW()
    WHERE zsbl.spName = ' CML_BILLHOSTD_NW';
    -- Tutup cursor
    CLOSE billing_cursor;



  END
  $$

--
-- Create procedure `CML_BILLHISTD_TYPE2_NW`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLHISTD_TYPE2_NW
(
                 IN IN_organizationId varchar(30), IN IN_warehouseId varchar(30), IN IN_USERID varchar(30), IN IN_Language varchar(30), IN IN_CustomerId varchar(30), IN IN_trans_no varchar(30), OUT p_success_flag char(1), OUT p_message varchar(1000), OUT p_record_count int
)
BEGIN
  -- =============================================
  -- Stored Procedure: CML_BILLHISTD_TYPE2_NW
  -- Purpose: Process outbound billing for customers based on shipment transactions
  -- Author: [Akbar@IT-LINC]
  -- Date: [31.08.25]
  -- =============================================

  -- Variable declarations
  DECLARE v_billing_summary_id varchar(30) DEFAULT '';
  DECLARE v_return_code varchar(1000);
  DECLARE v_row_count int DEFAULT 0;
  DECLARE v_error_code varchar(5);
  DECLARE v_error_msg varchar(1000);
  DECLARE v_start_time timestamp DEFAULT NOW();
  DECLARE v_end_time timestamp;
  DECLARE v_execution_time decimal(10, 3);

  -- Declare handlers for exceptions
  DECLARE EXIT HANDLER FOR SQLEXCEPTION

  BEGIN
    -- Get error information
    GET DIAGNOSTICS CONDITION 1
    v_error_code = RETURNED_SQLSTATE,
    v_error_msg = MESSAGE_TEXT;

    -- Rollback transaction
    ROLLBACK;

    -- Set output parameters
    SET p_success_flag = 'N';
    SET p_message = CONCAT('Error Code: ', v_error_code, ' - ', v_error_msg);
    SET p_record_count = 0;

  -- Log error (optional)
  --         INSERT INTO ERROR_LOG (procedure_name, error_code, error_message, error_time, parameters)
  --         VALUES ('CML_BILLHOSTD_BETA', v_error_code, v_error_msg, NOW(), 
  --                 CONCAT('Org:', IN_organizationId, '|WH:', IN_warehouseId, 
  --                       '|Cust:', IN_CustomerId, '|Trans:', IN_trans_no));
  END;

  -- Initialize output parameters
  SET p_success_flag = 'N';
  SET p_message = '';
  SET p_record_count = 0;




  -- Validate input parameters
  IF IN_organizationId IS NULL OR
  IN_organizationId = ''
  THEN
    SET p_message = 'Organization ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_CustomerId IS NULL OR
  IN_CustomerId = ''
  THEN
    SET p_message = 'Customer ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_trans_no IS NULL OR
  IN_trans_no = ''
  THEN
    SET p_message = 'Transaction number cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  -- Start transaction
  START TRANSACTION;

  BEGIN
    -- Initialize row counter
    SET @row_num = 0;

    -- Generate billing summary ID
    SET v_return_code = '*_*';
    CALL SPCOM_GetIDSequence_NEW(IN_organizationId, '*', IN_Language, 'BILLINGSUMMARYIDCUST', v_billing_summary_id, v_return_code);

    -- Check if ID generation was successful
    IF v_return_code NOT LIKE '000%'
    THEN
      SET p_message = CONCAT('Failed to generate billing summary ID. Return code: ', v_return_code);
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
    END IF;


    CREATE TEMPORARY TABLE IF NOT EXISTS temp_billing_data AS
    SELECT dah.organizationId,
    dah.asnReference1,
    dah.asnReference3,
    '' skuDescr,
    dah.warehouseId,
    dah.customerId,
    dah.asnNo,
    '' docLineNo,
    '' toSku,
    '' toQty,
    '' toUom,
    '' toQty_Each,
    -- Gross weight calculation
    0 qtyChargeGrossWeight,

    -- Metric ton calculation
    0 qtyChargeMetricTon,


    -- Calculate billing quantity based on rate base
    CASE
         WHEN btd.ratebase = 'MUID' THEN CEIL(COUNT(DISTINCT (atl.fmMuid)) / btr.classTo)
         WHEN btd.ratebase = 'DID' THEN CEIL(COUNT(DISTINCT (atl.fmMuid)) / btr.classTo)
         WHEN btd.ratebase = 'DID1' THEN CEIL(COUNT(DISTINCT (atl.fmMuid)) / btr.classTo)
         WHEN btd.ratebase = 'DO' THEN CEIL(COUNT(DISTINCT (dah.asnNo)) / btr.classTo)
         WHEN btd.ratebase = 'PALLET' THEN CEIL(SUM(atl.toQty_Each / NULLIF(bpdPL.qty, 0)))
         WHEN btd.ratebase = 'CASE' THEN CEIL(SUM(atl.toQty_Each / NULLIF(bpdCS.qty, 0)))
         ELSE 0
    END AS qtyChargeBilling,
    0 AS qtyChargeTotDO,
    COUNT(atl.docLineNo) AS qtyChargeTotLine,
    0 AS totalCube,
    '' AS addTime,
    '' AS editTime,
    '' AS transactionTime,
    0 AS lotNum,
    0 AS traceId,
    0 AS muid,
    0 AS toLocation,
    t1.codeid AS docType,
    t1.codeDescr AS docTypeDescr,
    '' packId,
    0 QtyPerCases,
    0 QtyPerPallet,
    '' AS sku_group1,
    0 AS grossWeight,
    0 cubeNya,
    bsm.tariffMasterId AS tariffMasterId,
    '' AS zone,
    '' AS batch,
    '' AS lotAtt07,
    BT.codeid billtranctg,
    daf.closeTime,
    '' transactionId, -- add transaction line
    btr.rate,
    btd.ratebase,
    btr.tariffId,
    btr.tariffLineNo,
    btr.tariffClassNo,
    btd.chargeCategory,
    btd.chargeType,
    btd.descrC,
    btr.ratePerUnit,
    btd.minAmount,
    btd.maxAmount,
    IF(btd.UDF03 = '', 0, btd.UDF03) AS minQty,
    btd.UDF01,
    btd.udf02,
    btd.udf04,
    btd.UDF05,
    btd.UDF06,
    btd.UDF07,
    btd.UDF08,
    IFNULL(btd.incomeTaxRate, 0) AS IncomeTaxRate,
    CASE
         WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1
         ELSE IFNULL(btr.classfrom, 0)
    END AS classFrom,
    IFNULL(classTo, 0) AS classTo,
    bth.contractNo,
    btr.cost,
    btd.billingParty,
    bl.locationCategory
    FROM ACT_TRANSACTION_LOG atl
         LEFT OUTER JOIN
         BAS_SKU bs
         ON bs.organizationId = atl.organizationId AND
           bs.customerId = atl.toCustomerId AND
           bs.SKU = atl.toSku
         LEFT OUTER JOIN
         BAS_SKU_MULTIWAREHOUSE bsm
         ON bsm.organizationId = atl.organizationId AND
           bsm.warehouseId = atl.warehouseId AND
           bsm.customerId = atl.tocustomerId AND
           bsm.SKU = atl.toSku
         LEFT OUTER JOIN
         DOC_ASN_HEADER dah
         ON dah.organizationId = atl.organizationId AND
           dah.warehouseId = atl.warehouseId AND
           dah.asnNo = atl.docNo AND
           dah.customerId = atl.fmCustomerId
         LEFT JOIN
         DOC_ASN_HEADER_UDF daf
         ON dah.organizationId = daf.organizationId AND
           dah.warehouseId = daf.warehouseId AND
           dah.asnNo = daf.asnNo
         LEFT OUTER JOIN
         DOC_ASN_DETAILS dad
         ON dad.organizationId = atl.organizationId AND
           dad.warehouseId = atl.warehouseId AND
           dad.asnNo = atl.docNo AND
           dad.asnLineNo = atl.docLineNo AND
           dad.sku = atl.toSku
         LEFT OUTER JOIN
         INV_LOT_ATT ila
         ON ila.organizationId = atl.organizationId AND
           ila.customerId = atl.toCustomerId AND
           ila.SKU = atl.toSku AND
           ila.lotNum = atl.toLotNum
         LEFT OUTER JOIN
         BAS_PACKAGE_DETAILS bpdEA
         ON bpdEA.organizationId = bs.organizationId AND
           bpdEA.packId = bs.packId AND
           bpdEA.customerId = bs.customerId AND
           bpdEA.packUom = 'EA'
         LEFT OUTER JOIN
         BAS_PACKAGE_DETAILS bpdIP
         ON bpdIP.organizationId = bs.organizationId AND
           bpdIP.packId = bs.packId AND
           bpdIP.customerId = bs.customerId AND
           bpdIP.packUom = 'IP'
         LEFT OUTER JOIN
         BAS_PACKAGE_DETAILS bpdCS
         ON bpdCS.organizationId = bs.organizationId AND
           bpdCS.packId = bs.packId AND
           bpdCS.customerId = bs.customerId AND
           bpdCS.packUom = 'CS'
         LEFT OUTER JOIN
         BAS_PACKAGE_DETAILS bpdPL
         ON bpdPL.organizationId = bs.organizationId AND
           bpdPL.packId = bs.packId AND
           bpdPL.customerId = bs.customerId AND
           bpdPL.packUom = 'PL'
         LEFT JOIN
         BSM_CODE_ML t1
         ON t1.organizationId = atl.organizationId AND
           t1.codeType = 'ASN_TYP' AND
           dah.asnType = t1.codeId AND
           t1.languageId = 'en'
         LEFT JOIN
         BSM_CODE BT
         ON BT.organizationId = atl.organizationId AND
           BT.codeType = 'BILLING_TRANSACTION_CATEGORY' AND
           BT.outerCode = ila.lotAtt07
         LEFT JOIN
         BAS_LOCATION bl
         ON bl.organizationId = atl.organizationId AND
           bl.warehouseId = atl.warehouseId AND
           bl.locationId = atl.toLocation
         LEFT JOIN
         BAS_ZONE bz
         ON bz.organizationId = bl.organizationId AND
           bz.organizationId = bl.organizationId AND
           bz.warehouseId = bl.warehouseId AND
           bz.zoneId = bl.zoneId AND
           bz.zoneGroup = bl.zoneGroup
         LEFT JOIN
         BIL_TARIFF_HEADER bth
         ON bth.organizationId = bsm.organizationId AND
           bth.tariffMasterId = bsm.tariffMasterId
         LEFT JOIN
         BIL_TARIFF_DETAILS btd
         ON btd.organizationId = bth.organizationId AND
           btd.tariffId = bth.tariffId AND
           btd.docType = dah.asnType
         LEFT JOIN
         BIL_TARIFF_RATE btr
         ON btr.organizationId = btd.organizationId AND
           btr.tariffId = btd.tariffId AND
           btr.tariffLineNo = btd.tariffLineNo
    WHERE atl.organizationId = IN_organizationId AND
          atl.warehouseId = IN_warehouseId AND
          dah.customerId = IN_CustomerId AND
          dah.asnNo = IN_trans_no AND
          COALESCE(ila.lotAtt04, '') NOT IN ('SET') /*AL validate batch*/
          AND atl.transactionType = 'IN' AND
          dah.asnType NOT IN ('FREE', 'IU', 'TTG') AND
          dad.skuDescr NOT LIKE '%PALLET%' AND
          bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
          bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
          btd.chargeCategory = 'IB' AND
          (
          btd.billingTranCategory IS NULL OR
          btd.billingTranCategory = '' OR
          btd.billingTranCategory = BT.codeid
          ) AND
          btr.rate > 0 AND
          NOT EXISTS (SELECT 1
        FROM Z_SKUNOTBILLING zsnb
        WHERE zsnb.organizationId = dah.organizationId AND
              zsnb.customerId = dah.customerId AND
              zsnb.sku = atl.toSku) AND
          atl.STATUS IN ('80', '99') AND
          dah.asnStatus IN ('99')
    GROUP BY dah.organizationId, atl.warehouseId, dah.customerId, atl.docNo, dah.asnNo, dah.asnType, dah.asnReference1, dah.asnReference3, dah.asnReference1, t1.codeid, BT.codeid, btr.rate, btd.ratebase, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo, btd.chargeCategory, btd.chargeType, btd.descrC, btr.ratePerUnit, btd.minAmount, btd.maxAmount, btd.UDF03, btd.UDF01, btd.udf02, btd.udf04, btd.UDF05, btd.UDF06, btd.UDF07, btd.UDF08, btd.incomeTaxRate, bth.contractNo, bth.tariffMasterId, btr.cost, bl.locationCategory;


    -- Insert billing summary data
    INSERT INTO BIL_SUMMARY (organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate,
    customerId, sku, lotNum, traceId, tariffId, chargeCategory, chargeType,
    descr, rateBase, chargePerUnits, qty, uom, cubic, weight, chargeRate,
    amount, billingAmount, cost, amountPayable, amountPaid, confirmTime,
    confirmWho, docType, docNo, createTransactionid, notes, ediSendTime,
    billTo, settleTime, settleWho, followUp, invoiceType, paidTo,
    costConfirmFlag, costConfirmTime, costConfirmWho, costSettleFlag,
    costSettleTime, costSettleWho, incomeTaxRate, costTaxRate, incomeTax,
    cosTax, incomeWithoutTax, cosWithoutTax, costInvoiceType, noteText,
    udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag,
    addWho, addTime, editWho, editTime, locationCategory, manual,
    docLineNo, arNo, arLineNo, apNo, apLineNo, ediSendFlag,
    ediErrorCode, ediErrorMessage, ediSendTime2, ediSendFlag2,
    ediErrorCode2, ediErrorMessage2, billingTranCategory, orderType,
    containerType, containerSize)
           SELECT organizationId,
           warehouseId,
           CONCAT(v_billing_summary_id, '*', LPAD(auto_sequence(), 3, '0')) AS billingSummaryId,
           DATE_FORMAT(closeTime, '%Y-%m-%d') AS billingFromDate,
           DATE_FORMAT(closeTime, '%Y-%m-%d') AS billingToDate,
           customerId,
           toSku sku,
           lotNum,
           traceId,
           tariffId,
           chargeCategory,
           chargeType,
           descrC AS descr,
           ratebase AS rateBase,
           ratePerUnit AS chargePerUnits,
           qtyChargeBilling AS qty,
           toUom,
           totalCube AS cubic,
           grossWeight AS weight,
           rate AS chargeRate,
           qtyChargeBilling * rate / ratePerUnit AS amount,
           (qtyChargeBilling * (rate / ratePerUnit)) +
           (qtyChargeBilling * (rate / ratePerUnit)) * IncomeTaxRate / 100 AS billingAmount,
           cost,
           cost * qtyChargeBilling AS amountPayable,
           0 AS amountPaid,
           NOW() AS confirmTime,
           IN_USERID AS confirmWho,
           docType AS docType,
           asnNo AS docNo,
           '' AS createTransactionid,
           '' AS notes,
           NOW() AS ediSendTime,
           customerId AS billTo,
           NOW() AS settleTime,
           IN_USERID AS settleWho,
           '' AS followUp,
           '' AS invoiceType,
           '' AS paidTo,
           'N' AS costConfirmFlag,
           NOW() AS costConfirmTime,
           '' AS costConfirmWho,
           'N' AS costSettleFlag,
           NOW() AS costSettleTime,
           '' AS costSettleWho,
           IncomeTaxRate AS incomeTaxRate,
           0 AS costTaxRate,
           qtyChargeBilling * rate / ratePerUnit * IncomeTaxRate / 100 AS incomeTax,
           0 AS cosTax,
           qtyChargeBilling * rate / ratePerUnit AS incomeWithoutTax,
           0 AS cosWithoutTax,
           '' AS costInvoiceType,
           '' AS noteText,
           UDF01 AS udf01,
           udf02 AS udf02,
           transactionId AS udf03,
           UDF06 AS udf04,
           '' AS udf05,
           100 AS currentVersion,
           '2020' AS oprSeqFlag,
           IN_USERID AS addWho,
           NOW() AS addTime,
           IN_USERID AS editWho,
           NOW() AS editTime,
           locationCategory,
           'N' AS manual,
           0 AS docLineNo,
           '*' AS arNo,
           0 AS arLineNo,
           '*' AS apNo,
           0 AS apLineNo,
           'N' AS ediSendFlag,
           '' AS ediErrorCode,
           '' AS ediErrorMessage,
           NOW() AS ediSendTime2,
           'N' AS ediSendFlag2,
           '' AS ediErrorCode2,
           '' AS ediErrorMessage2,
           billtranctg AS billingTranCategory,
           docType,
           '' AS containerType,
           '' AS containerSize
           FROM temp_billing_data
           WHERE qtyChargeBilling > 0;  -- Only insert records with positive billing quantity

    -- Get the number of inserted rows
    SET v_row_count = ROW_COUNT();

    -- Clean up temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_billing_data;

    -- Check if any rows were inserted
    IF v_row_count = 0
    THEN
      -- No data found, but this might be expected
      SET p_message = CONCAT('No billing data found for Order: ', IN_trans_no, ', Customer: ', IN_CustomerId);
      SET p_success_flag = 'W'; -- Warning flag
      SET p_record_count = 0;
      COMMIT; -- Commit even if no rows

      CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLHISTD_TYPE2', IN_trans_no, 'error', NULL, NULL, p_success_flag, p_message, p_record_count, v_start_time, v_end_time);
    ELSE
      -- Calculate execution time
      SET v_end_time = NOW();
      SET v_execution_time = TIMESTAMPDIFF(MICROSECOND, v_start_time, v_end_time) / 1000000;

      -- Commit transaction
      COMMIT;

      -- Set success output parameters
      SET p_success_flag = 'Y';
      SET p_message = CONCAT('Inbound billing processed successfully. ', 'Billing Summary ID: ', v_billing_summary_id, '. Records: ', v_row_count, '. Execution time: ', v_execution_time, ' seconds');
      SET p_record_count = v_row_count;

      CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLHISTD_TYPE2_NW', IN_trans_no, 'no error', NULL, NULL, p_success_flag, p_message, p_record_count, v_start_time, v_end_time);


    END IF;



  END;

END
$$

--
-- Create procedure `Z_SP_ProcessBillingCML_BILLHISTD_TYPE2`
--
CREATE
DEFINER = 'mysql.sys'@'%'
PROCEDURE Z_SP_ProcessBillingCML_BILLHISTD_TYPE2()
  SP:
  BEGIN
    -- Deklarasi variabel untuk menyimpan data dari cursor
    DECLARE v_organizationId varchar(20);
    DECLARE v_warehouseId varchar(20);
    DECLARE v_customerId varchar(30);
    DECLARE v_trans_no varchar(20);
    DECLARE v_spName varchar(30);
    DECLARE v_flag int DEFAULT 0;
    -- Variabel untuk mengontrol loop
    DECLARE done int DEFAULT FALSE;



    -- Deklarasi cursor
    DECLARE billing_cursor CURSOR FOR SELECT dah.organizationId, dah.warehouseId, dah.customerId, dah.asnNo AS trans_no, zbccd.spName
    FROM DOC_ASN_HEADER dah
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING zbcc
         ON (dah.organizationId = zbcc.organizationId AND
           dah.warehouseId = zbcc.warehouseId AND
           dah.customerId = zbcc.customerId)
         INNER JOIN
         DOC_ASN_HEADER_UDF dahu
         ON (dah.organizationId = dahu.organizationId AND
           dah.warehouseId = dahu.warehouseId AND
           dah.asnNo = dahu.asnNo)
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
         ON zbcc.organizationId = zbccd.organizationId
           AND
           zbcc.lotatt01 = zbccd.idGroupSp
    WHERE dah.organizationId = 'OJV_CML' AND
          dah.asnType NOT IN ('FREE', 'KT', 'TROF', 'TTG')
          --   doh.warehouseId='' AND
          AND dah.asnStatus = '99' AND
          zbcc.lotatt01 <> '' AND
          zbcc.active = 'Y' AND
          zbccd.active = 'Y' AND
          zbccd.spName = 'CML_BILLHISTD_TYPE2' AND
          dahu.closeTime >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND
          NOT EXISTS (SELECT 1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = 'OJV_CML' AND
              bs.docNo = dah.asnNo AND
              bs.warehouseId = dah.warehouseId AND
              bs.customerId = dah.customerId AND
              bs.chargeCategory = 'IB' AND
              bs.addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
    --  GROUP BY doh.organizationId,doh.warehouseId, doh.customerId,trans_no,zbccd.spName
    ORDER BY dah.editTime ASC;




    -- Handler untuk kondisi NOT FOUND
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Buka cursor
    OPEN billing_cursor;

    -- Loop untuk memproses setiap baris
    read_loop:
    LOOP
      -- Fetch data dari cursor
      FETCH billing_cursor INTO v_organizationId,
      v_warehouseId,
      v_customerId,
      v_trans_no,
      v_spName;

      -- Jika tidak ada data lagi, keluar dari loop
      IF done
      THEN

        LEAVE read_loop;
      END IF;




      SET @IN_organizationId = 'OJV_CML';
      SET @IN_warehouseId = v_warehouseId;
      SET @IN_USERID = 'CUSTOMBILL';
      SET @IN_Language = 'en';
      SET @IN_CustomerId = v_customerId;
      SET @IN_trans_no = v_trans_no;
      CALL CML_BILLHISTD_TYPE2_NW(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @p_success_flag, @p_message, @p_record_count);


    END LOOP;



    -- Tutup cursor
    CLOSE billing_cursor;



  END
  $$

--
-- Create procedure `CML_BILLHISTD_NW`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLHISTD_NW
(
                 IN IN_organizationId varchar(30), IN IN_warehouseId varchar(30), IN IN_USERID varchar(30), IN IN_Language varchar(30), IN IN_CustomerId varchar(30), IN IN_trans_no varchar(30), OUT p_success_flag char(1), OUT p_message varchar(1000), OUT p_record_count int
)
BEGIN
  -- =============================================
  -- Stored Procedure: CML_BILLHISTD_NW
  -- Purpose: Process outbound billing for customers based on shipment transactions
  -- Author: [Akbar@IT-LINC]
  -- Date: [31.08.25]
  -- =============================================

  -- Variable declarations
  DECLARE v_billing_summary_id varchar(30) DEFAULT '';
  DECLARE v_return_code varchar(1000);
  DECLARE v_row_count int DEFAULT 0;
  DECLARE v_error_code varchar(5);
  DECLARE v_error_msg varchar(1000);
  DECLARE v_start_time timestamp DEFAULT NOW();
  DECLARE v_end_time timestamp;
  DECLARE v_execution_time decimal(10, 3);

  -- Declare handlers for exceptions
  DECLARE EXIT HANDLER FOR SQLEXCEPTION

  BEGIN
    -- Get error information
    GET DIAGNOSTICS CONDITION 1
    v_error_code = RETURNED_SQLSTATE,
    v_error_msg = MESSAGE_TEXT;

    -- Rollback transaction
    ROLLBACK;

    -- Set output parameters
    SET p_success_flag = 'N';
    SET p_message = CONCAT('Error Code: ', v_error_code, ' - ', v_error_msg);
    SET p_record_count = 0;

  -- Log error (optional)
  --         INSERT INTO ERROR_LOG (procedure_name, error_code, error_message, error_time, parameters)
  --         VALUES ('CML_BILLHOSTD_BETA', v_error_code, v_error_msg, NOW(), 
  --                 CONCAT('Org:', IN_organizationId, '|WH:', IN_warehouseId, 
  --                       '|Cust:', IN_CustomerId, '|Trans:', IN_trans_no));
  END;

  -- Initialize output parameters
  SET p_success_flag = 'N';
  SET p_message = '';
  SET p_record_count = 0;




  -- Validate input parameters
  IF IN_organizationId IS NULL OR
  IN_organizationId = ''
  THEN
    SET p_message = 'Organization ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_CustomerId IS NULL OR
  IN_CustomerId = ''
  THEN
    SET p_message = 'Customer ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_trans_no IS NULL OR
  IN_trans_no = ''
  THEN
    SET p_message = 'Transaction number cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  -- Start transaction
  START TRANSACTION;

  BEGIN
    -- Initialize row counter
    SET @row_num = 0;

    -- Generate billing summary ID
    SET v_return_code = '*_*';
    CALL SPCOM_GetIDSequence_NEW(IN_organizationId, '*', IN_Language, 'BILLINGSUMMARYIDCUST', v_billing_summary_id, v_return_code);

    -- Check if ID generation was successful
    IF v_return_code NOT LIKE '000%'
    THEN
      SET p_message = CONCAT('Failed to generate billing summary ID. Return code: ', v_return_code);
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
    END IF;


    CREATE TEMPORARY TABLE IF NOT EXISTS temp_billing_data AS
    SELECT dah.organizationId,
    dah.asnReference1,
    dah.asnReference3,
    dad.skuDescr,
    atl.warehouseId,
    atl.tocustomerId,
    atl.docNo,
    atl.docLineNo,
    atl.toSku,
    atl.toQty,
    atl.toUom,
    atl.toQty_Each,
    -- Gross weight calculation
    CASE
         WHEN bpdEA.uomDescr IN ('G', 'GRAM', 'Gram') THEN SUM(atl.toQty_Each / 1000)
         WHEN bpdEA.uomDescr IN ('MT', 'Metric Ton', 'METRIC TON') THEN SUM(atl.toQty_Each * 1000)
         ELSE SUM(atl.toQty_Each * bs.grossWeight)
    END AS qtyChargeGrossWeight,

    -- Metric ton calculation
    CASE
         WHEN atl.toCustomerId LIKE '%ABC%' THEN SUM((atl.toQty_Each * bpdCS.qty) / 1000)
         WHEN atl.toCustomerId IN ('ADASBY', 'CAI_MDN', 'CAI_SBY') THEN IFNULL(CAST(SUM((atl.toQty_Each * bs.netweight) / 1000) AS char(255)), 0)
         ELSE SUM(atl.toQty_Each / 1000)
    END AS qtyChargeMetricTon,


    -- Calculate billing quantity based on rate base
    CASE
         WHEN btd.ratebase = 'CUBIC' THEN SUM(atl.toQty_Each * bs.cube)
         WHEN btd.ratebase = 'M2' THEN CASE
              WHEN atl.tocustomerId = 'MAP' AND
                   ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
                   bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0))
              ELSE SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0))
         END
         WHEN btd.ratebase = 'IP' THEN COALESCE(CEIL(SUM(atl.toQty_Each / NULLIF(bpdIP.qty, 0))), 1)
         WHEN btd.ratebase = 'KG' THEN CASE
              WHEN atl.tocustomerId = 'MAP' AND
                   ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
                   bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0))
              ELSE SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0))
         END
         WHEN btd.ratebase = 'LITER' THEN CASE
              WHEN atl.tocustomerId = 'MAP' AND
                   ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
                   bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0))
              WHEN aad.customerId = 'PPG' THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) * NULLIF(bs.sku_group6, 0)
              ELSE SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0))
         END
         WHEN btd.ratebase = 'QUANTITY' THEN CASE
              WHEN atl.tocustomerId = 'MAP' AND
                   ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
                   bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0))
              ELSE SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0))
         END
         WHEN btd.ratebase = 'DO' THEN COUNT(DISTINCT dah.asnNo)
         WHEN btd.ratebase = 'PALLET' THEN CEIL(SUM(atl.toQty_Each / NULLIF(bpdPL.qty, 0)))
         WHEN btd.ratebase = 'CASE' THEN CEIL(SUM(atl.toQty_Each / NULLIF(bpdCS.qty, 0)))
         WHEN btd.ratebase = 'NETWEIGHT' THEN SUM(atl.toQty_Each * bs.netWeight)
         WHEN btd.ratebase = 'GW' THEN CASE
              WHEN bpdEA.uomDescr IN ('G', 'GRAM', 'Gram') THEN SUM(atl.toQty_Each / 1000)
              WHEN bpdEA.uomDescr IN ('MT', 'Metric Ton', 'METRIC TON') THEN SUM(atl.toQty_Each * 1000)
              ELSE SUM(atl.toQty_Each * bs.grossWeight)
         END
         WHEN btd.ratebase = 'MT' THEN CASE
              WHEN atl.tocustomerId LIKE '%ABC%' THEN SUM((atl.toQty_Each * bpdCS.qty) / 1000)
              WHEN atl.tocustomerId IN ('ADASBY', 'CAI_MDN', 'CAI_SBY') THEN IFNULL(CAST(SUM((atl.toQty_Each * bs.netweight) / 1000) AS char(255)), 0)
              ELSE SUM(atl.toQty_Each / 1000)
         END
         ELSE 0
    END AS qtyChargeBilling,
    atl.docNo AS qtyChargeTotDO,
    COUNT(atl.docLineNo) AS qtyChargeTotLine,
    SUM(bs.cube) AS totalCube,
    DATE_FORMAT(atl.addTime, '%Y-%m-%d') AS addTime,
    DATE_FORMAT(atl.editTime, '%Y-%m-%d') AS editTime,
    DATE_FORMAT(atl.transactionTime, '%Y-%m-%d') AS transactionTime,
    atl.tolotNum AS lotNum,
    atl.toId AS traceId,
    atl.tomuid AS muid,
    atl.toLocation AS toLocation,
    t1.codeid AS docType,
    t1.codeDescr AS docTypeDescr,
    bpdCS.packId AS packId,
    bpdCS.qty AS QtyPerCases,
    bpdPL.qty AS QtyPerPallet,
    bs.sku_group1 AS sku_group1,
    bs.grossWeight AS grossWeight,
    bs.cube,
    bsm.tariffMasterId AS tariffMasterId,
    bz.zoneDescr AS zone,
    ila.lotAtt04 AS batch,
    ila.lotAtt07 AS lotAtt07,
    BT.codeid billtranctg,
    daf.closeTime,
    atl.transactionId, -- add transaction line
    btr.rate,
    btd.ratebase,
    btr.tariffId,
    btr.tariffLineNo,
    btr.tariffClassNo,
    btd.chargeCategory,
    btd.chargeType,
    btd.descrC,
    btr.ratePerUnit,
    btd.minAmount,
    btd.maxAmount,
    IF(btd.UDF03 = '', 0, btd.UDF03) AS minQty,
    btd.UDF01,
    btd.udf02,
    btd.udf04,
    btd.UDF05,
    btd.UDF06,
    btd.UDF07,
    btd.UDF08,
    IFNULL(btd.incomeTaxRate, 0) AS IncomeTaxRate,
    CASE
         WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1
         ELSE IFNULL(btr.classfrom, 0)
    END AS classFrom,
    IFNULL(classTo, 0) AS classTo,
    bth.contractNo,
    btr.cost,
    btd.billingParty,
    bl.locationCategory
    FROM ACT_TRANSACTION_LOG atl
         LEFT OUTER JOIN
         BAS_SKU bs
         ON bs.organizationId = atl.organizationId AND
           bs.customerId = atl.toCustomerId AND
           bs.SKU = atl.toSku
         LEFT OUTER JOIN
         BAS_SKU_MULTIWAREHOUSE bsm
         ON bsm.organizationId = atl.organizationId AND
           bsm.warehouseId = atl.warehouseId AND
           bsm.customerId = atl.tocustomerId AND
           bsm.SKU = atl.toSku
         LEFT OUTER JOIN
         DOC_ASN_HEADER dah
         ON dah.organizationId = atl.organizationId AND
           dah.warehouseId = atl.warehouseId AND
           dah.asnNo = atl.docNo AND
           dah.customerId = atl.fmCustomerId
         LEFT JOIN
         DOC_ASN_HEADER_UDF daf
         ON dah.organizationId = daf.organizationId AND
           dah.warehouseId = daf.warehouseId AND
           dah.asnNo = daf.asnNo
         LEFT OUTER JOIN
         DOC_ASN_DETAILS dad
         ON dad.organizationId = atl.organizationId AND
           dad.warehouseId = atl.warehouseId AND
           dad.asnNo = atl.docNo AND
           dad.asnLineNo = atl.docLineNo AND
           dad.sku = atl.toSku
         LEFT OUTER JOIN
         INV_LOT_ATT ila
         ON ila.organizationId = atl.organizationId AND
           ila.customerId = atl.toCustomerId AND
           ila.SKU = atl.toSku AND
           ila.lotNum = atl.toLotNum
         LEFT OUTER JOIN
         BAS_PACKAGE_DETAILS bpdEA
         ON bpdEA.organizationId = bs.organizationId AND
           bpdEA.packId = bs.packId AND
           bpdEA.customerId = bs.customerId AND
           bpdEA.packUom = 'EA'
         LEFT OUTER JOIN
         BAS_PACKAGE_DETAILS bpdIP
         ON bpdIP.organizationId = bs.organizationId AND
           bpdIP.packId = bs.packId AND
           bpdIP.customerId = bs.customerId AND
           bpdIP.packUom = 'IP'
         LEFT OUTER JOIN
         BAS_PACKAGE_DETAILS bpdCS
         ON bpdCS.organizationId = bs.organizationId AND
           bpdCS.packId = bs.packId AND
           bpdCS.customerId = bs.customerId AND
           bpdCS.packUom = 'CS'
         LEFT OUTER JOIN
         BAS_PACKAGE_DETAILS bpdPL
         ON bpdPL.organizationId = bs.organizationId AND
           bpdPL.packId = bs.packId AND
           bpdPL.customerId = bs.customerId AND
           bpdPL.packUom = 'PL'
         LEFT JOIN
         BSM_CODE_ML t1
         ON t1.organizationId = atl.organizationId AND
           t1.codeType = 'ASN_TYP' AND
           dah.asnType = t1.codeId AND
           t1.languageId = 'en'
         LEFT JOIN
         BSM_CODE BT
         ON BT.organizationId = atl.organizationId AND
           BT.codeType = 'BILLING_TRANSACTION_CATEGORY' AND
           CASE
                WHEN aad.customerId = 'PPG' THEN BT.outerCode = aad.udf05
                ELSE BT.outerCode = ila.lotAtt07
           END
         LEFT JOIN
         BAS_LOCATION bl
         ON bl.organizationId = atl.organizationId AND
           bl.warehouseId = atl.warehouseId AND
           bl.locationId = atl.toLocation
         LEFT JOIN
         BAS_ZONE bz
         ON bz.organizationId = bl.organizationId AND
           bz.organizationId = bl.organizationId AND
           bz.warehouseId = bl.warehouseId AND
           bz.zoneId = bl.zoneId AND
           bz.zoneGroup = bl.zoneGroup
         LEFT JOIN
         BIL_TARIFF_HEADER bth
         ON bth.organizationId = bsm.organizationId AND
           bth.tariffMasterId = bsm.tariffMasterId
         LEFT JOIN
         BIL_TARIFF_DETAILS btd
         ON btd.organizationId = bth.organizationId AND
           btd.tariffId = bth.tariffId AND
           btd.docType = dah.asnType
         LEFT JOIN
         BIL_TARIFF_RATE btr
         ON btr.organizationId = btd.organizationId AND
           btr.tariffId = btd.tariffId AND
           btr.tariffLineNo = btd.tariffLineNo
    WHERE atl.organizationId = IN_organizationId AND
          atl.warehouseId = IN_warehouseId AND
          dah.customerId = IN_CustomerId AND
          dah.asnNo = IN_trans_no AND
          COALESCE(ila.lotAtt04, '') NOT IN ('SET') /*AL validate batch*/
          AND atl.transactionType = 'IN' AND
          dah.asnType NOT IN ('FREE', 'IU', 'TTG') AND
          dad.skuDescr NOT LIKE '%PALLET%' AND
          bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
          bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
          btd.chargeCategory = 'IB' AND
          (
          btd.billingTranCategory IS NULL OR
          btd.billingTranCategory = '' OR
          btd.billingTranCategory = BT.codeid OR
          btd.billingTranCategory = aad.udf05  -- for PPG palletize & loose
          ) AND
          btr.rate > 0 AND
          NOT EXISTS (SELECT 1
        FROM Z_SKUNOTBILLING zsnb
        WHERE zsnb.organizationId = dah.organizationId AND
              zsnb.customerId = dah.customerId AND
              zsnb.sku = atl.toSku) AND
          atl.STATUS IN ('80', '99') AND
          dah.asnStatus IN ('99')
    GROUP BY atl.docNo, atl.docLineNo, atl.toCustomerId, atl.toSku, atl.toQty, atl.toQty_Each, atl.toUom, atl.addTime, atl.transactionTime, atl.toLotNum, atl.toId, atl.tomuid, atl.toLocation, atl.warehouseId, atl.tocustomerId, atl.transactionId, atl.editTime, dah.organizationId, dah.asnNo, dah.asnType, dah.asnReference1, dah.asnReference3, dah.asnReference1, dad.SkuDescr, bsm.tariffMasterId, bs.grossWeight, bs.cube, bs.sku_group1, bz.zoneDescr, bpdCS.packId, bpdPL.packId, bpdCS.qty, bpdPL.qty, ila.lotAtt04, ila.lotAtt07, t1.codeid, BT.codeid, btr.rate, btd.ratebase, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo, btd.chargeCategory, btd.chargeType, btd.descrC, btr.ratePerUnit, btd.minAmount, btd.maxAmount, btd.UDF03, btd.UDF01, btd.udf02, btd.udf04, btd.UDF05, btd.UDF06, btd.UDF07, btd.UDF08, btd.incomeTaxRate, bth.contractNo, bth.tariffMasterId, btr.cost, bl.locationCategory;

    -- Insert billing summary data
    INSERT INTO BIL_SUMMARY (organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate,
    customerId, sku, lotNum, traceId, tariffId, chargeCategory, chargeType,
    descr, rateBase, chargePerUnits, qty, uom, cubic, weight, chargeRate,
    amount, billingAmount, cost, amountPayable, amountPaid, confirmTime,
    confirmWho, docType, docNo, createTransactionid, notes, ediSendTime,
    billTo, settleTime, settleWho, followUp, invoiceType, paidTo,
    costConfirmFlag, costConfirmTime, costConfirmWho, costSettleFlag,
    costSettleTime, costSettleWho, incomeTaxRate, costTaxRate, incomeTax,
    cosTax, incomeWithoutTax, cosWithoutTax, costInvoiceType, noteText,
    udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag,
    addWho, addTime, editWho, editTime, locationCategory, manual,
    docLineNo, arNo, arLineNo, apNo, apLineNo, ediSendFlag,
    ediErrorCode, ediErrorMessage, ediSendTime2, ediSendFlag2,
    ediErrorCode2, ediErrorMessage2, billingTranCategory, orderType,
    containerType, containerSize)
           SELECT organizationId,
           warehouseId,
           CONCAT(v_billing_summary_id, '*', LPAD(auto_sequence(), 3, '0')) AS billingSummaryId,
           DATE_FORMAT(closeTime, '%Y-%m-%d') AS billingFromDate,
           DATE_FORMAT(closeTime, '%Y-%m-%d') AS billingToDate,
           toCustomerId,
           toSku sku,
           lotNum,
           traceId,
           tariffId,
           chargeCategory,
           chargeType,
           descrC AS descr,
           ratebase AS rateBase,
           ratePerUnit AS chargePerUnits,
           qtyChargeBilling AS qty,
           toUom,
           totalCube AS cubic,
           grossWeight AS weight,
           rate AS chargeRate,
           qtyChargeBilling * rate / ratePerUnit AS amount,
           (qtyChargeBilling * (rate / ratePerUnit)) +
           (qtyChargeBilling * (rate / ratePerUnit)) * IncomeTaxRate / 100 AS billingAmount,
           cost,
           cost * qtyChargeBilling AS amountPayable,
           0 AS amountPaid,
           NOW() AS confirmTime,
           IN_USERID AS confirmWho,
           docType AS docType,
           docNo AS docNo,
           '' AS createTransactionid,
           '' AS notes,
           NOW() AS ediSendTime,
           toCustomerId AS billTo,
           NOW() AS settleTime,
           IN_USERID AS settleWho,
           '' AS followUp,
           '' AS invoiceType,
           '' AS paidTo,
           'N' AS costConfirmFlag,
           NOW() AS costConfirmTime,
           '' AS costConfirmWho,
           'N' AS costSettleFlag,
           NOW() AS costSettleTime,
           '' AS costSettleWho,
           IncomeTaxRate AS incomeTaxRate,
           0 AS costTaxRate,
           qtyChargeBilling * rate / ratePerUnit * IncomeTaxRate / 100 AS incomeTax,
           0 AS cosTax,
           qtyChargeBilling * rate / ratePerUnit AS incomeWithoutTax,
           0 AS cosWithoutTax,
           '' AS costInvoiceType,
           '' AS noteText,
           UDF01 AS udf01,
           udf02 AS udf02,
           transactionId AS udf03,
           UDF06 AS udf04,
           '' AS udf05,
           100 AS currentVersion,
           '2020' AS oprSeqFlag,
           IN_USERID AS addWho,
           NOW() AS addTime,
           IN_USERID AS editWho,
           NOW() AS editTime,
           locationCategory,
           'N' AS manual,
           0 AS docLineNo,
           '*' AS arNo,
           0 AS arLineNo,
           '*' AS apNo,
           0 AS apLineNo,
           'N' AS ediSendFlag,
           '' AS ediErrorCode,
           '' AS ediErrorMessage,
           NOW() AS ediSendTime2,
           'N' AS ediSendFlag2,
           '' AS ediErrorCode2,
           '' AS ediErrorMessage2,
           billtranctg AS billingTranCategory,
           docType,
           '' AS containerType,
           '' AS containerSize
           FROM temp_billing_data
           WHERE qtyChargeBilling > 0;  -- Only insert records with positive billing quantity

    -- Get the number of inserted rows
    SET v_row_count = ROW_COUNT();

    -- Clean up temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_billing_data;

    -- Check if any rows were inserted
    IF v_row_count = 0
    THEN
      -- No data found, but this might be expected
      SET p_message = CONCAT('No billing data found for Order: ', IN_trans_no, ', Customer: ', IN_CustomerId);
      SET p_success_flag = 'W'; -- Warning flag
      SET p_record_count = 0;
      COMMIT; -- Commit even if no rows

      CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLHISTD', IN_trans_no, 'error', NULL, NULL, p_success_flag, p_message, p_record_count, v_start_time, v_end_time);
    ELSE
      -- Calculate execution time
      SET v_end_time = NOW();
      SET v_execution_time = TIMESTAMPDIFF(MICROSECOND, v_start_time, v_end_time) / 1000000;

      -- Commit transaction
      COMMIT;

      -- Set success output parameters
      SET p_success_flag = 'Y';
      SET p_message = CONCAT('Inbound billing processed successfully. ', 'Billing Summary ID: ', v_billing_summary_id, '. Records: ', v_row_count, '. Execution time: ', v_execution_time, ' seconds');
      SET p_record_count = v_row_count;

      CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLHISTD_NW', IN_trans_no, 'no error', NULL, NULL, p_success_flag, p_message, p_record_count, v_start_time, v_end_time);


    END IF;



  END;

END
$$

--
-- Create procedure `Z_SP_ProcessBillingCML_BILLHISTD`
--
CREATE
DEFINER = 'mysql.sys'@'%'
PROCEDURE Z_SP_ProcessBillingCML_BILLHISTD()
  SP:
  BEGIN
    -- Deklarasi variabel untuk menyimpan data dari cursor
    DECLARE v_organizationId varchar(20);
    DECLARE v_warehouseId varchar(20);
    DECLARE v_customerId varchar(30);
    DECLARE v_trans_no varchar(20);
    DECLARE v_spName varchar(30);
    DECLARE v_flag int DEFAULT 0;
    -- Variabel untuk mengontrol loop
    DECLARE done int DEFAULT FALSE;



    -- Deklarasi cursor
    DECLARE billing_cursor CURSOR FOR SELECT dah.organizationId, dah.warehouseId, dah.customerId, dah.asnNo AS trans_no, zbccd.spName
    FROM DOC_ASN_HEADER dah
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING zbcc
         ON (dah.organizationId = zbcc.organizationId AND
           dah.warehouseId = zbcc.warehouseId AND
           dah.customerId = zbcc.customerId)
         INNER JOIN
         DOC_ASN_HEADER_UDF dahu
         ON (dah.organizationId = dahu.organizationId AND
           dah.warehouseId = dahu.warehouseId AND
           dah.asnNo = dahu.asnNo)
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
         ON zbcc.organizationId = zbccd.organizationId
           AND
           zbcc.lotatt01 = zbccd.idGroupSp
    WHERE dah.organizationId = 'OJV_CML' AND
          dah.asnType NOT IN ('FREE', 'KT', 'TROF', 'TTG')
          --   doh.warehouseId='' AND
          AND dah.asnStatus = '99' AND
          zbcc.lotatt01 <> '' AND
          zbcc.active = 'Y' AND
          zbccd.active = 'Y' AND
          zbccd.spName = 'CML_BILLHISTD' AND
          DATE(dahu.closeTime) > getBillFMDate(25) AND
          NOT EXISTS (SELECT 1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = 'OJV_CML' AND
              bs.docNo = dah.asnNo AND
              bs.warehouseId = dah.warehouseId AND
              bs.customerId = dah.customerId AND
              bs.chargeCategory = 'IB' AND
              bs.addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
    --  GROUP BY doh.organizationId,doh.warehouseId, doh.customerId,trans_no,zbccd.spName
    ORDER BY dah.editTime ASC;




    -- Handler untuk kondisi NOT FOUND
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Buka cursor
    OPEN billing_cursor;

    -- Loop untuk memproses setiap baris
    read_loop:
    LOOP
      -- Fetch data dari cursor
      FETCH billing_cursor INTO v_organizationId,
      v_warehouseId,
      v_customerId,
      v_trans_no,
      v_spName;

      -- Jika tidak ada data lagi, keluar dari loop
      IF done
      THEN

        LEAVE read_loop;
      END IF;




      SET @IN_organizationId = 'OJV_CML';
      SET @IN_warehouseId = v_warehouseId;
      SET @IN_USERID = 'CUSTOMBILL';
      SET @IN_Language = 'en';
      SET @IN_CustomerId = v_customerId;
      SET @IN_trans_no = v_trans_no;
      CALL CML_BILLHISTD_NW(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @p_success_flag, @p_message, @p_record_count);


    END LOOP;

    UPDATE Z_SP_BILLING_LOCK zsbl
      SET zsbl.flag = 0,
      zsbl.changeTime = NOW()
    WHERE zsbl.spName = 'CML_BILLHISTD_NW';
    -- Tutup cursor
    CLOSE billing_cursor;



  END
  $$

--
-- Create procedure `CML_BILLASNVASSTD_NW`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLASNVASSTD_NW
(
                 IN IN_organizationId varchar(30), IN IN_warehouseId varchar(30), IN IN_USERID varchar(30), IN IN_Language varchar(30), IN IN_CustomerId varchar(30), IN IN_trans_no varchar(30), OUT p_success_flag char(1), OUT p_message varchar(1000), OUT p_record_count int
)
BEGIN
  -- =============================================
  -- Stored Procedure: CML_BILLASNVASSTD_NW
  -- Purpose: Process outbound billing for customers based on shipment transactions
  -- Author: [Akbar@IT-LINC]
  -- Date: [04.09.25]
  -- =============================================

  -- Variable declarations
  DECLARE v_billing_summary_id varchar(30) DEFAULT '';
  DECLARE v_return_code varchar(1000);
  DECLARE v_row_count int DEFAULT 0;
  DECLARE v_error_code varchar(5);
  DECLARE v_error_msg varchar(1000);
  DECLARE v_start_time timestamp DEFAULT NOW();
  DECLARE v_end_time timestamp;
  DECLARE v_execution_time decimal(10, 3);

  -- Declare handlers for exceptions
  DECLARE EXIT HANDLER FOR SQLEXCEPTION

  BEGIN
    -- Get error information
    GET DIAGNOSTICS CONDITION 1
    v_error_code = RETURNED_SQLSTATE,
    v_error_msg = MESSAGE_TEXT;

    -- Rollback transaction
    ROLLBACK;

    -- Set output parameters
    SET p_success_flag = 'N';
    SET p_message = CONCAT('Error Code: ', v_error_code, ' - ', v_error_msg);
    SET p_record_count = 0;

  -- Log error (optional)
  --         INSERT INTO ERROR_LOG (procedure_name, error_code, error_message, error_time, parameters)
  --         VALUES ('CML_BILLHOSTD_BETA', v_error_code, v_error_msg, NOW(), 
  --                 CONCAT('Org:', IN_organizationId, '|WH:', IN_warehouseId, 
  --                       '|Cust:', IN_CustomerId, '|Trans:', IN_trans_no));
  END;

  -- Initialize output parameters
  SET p_success_flag = 'N';
  SET p_message = '';
  SET p_record_count = 0;




  -- Validate input parameters
  IF IN_organizationId IS NULL OR
  IN_organizationId = ''
  THEN
    SET p_message = 'Organization ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_CustomerId IS NULL OR
  IN_CustomerId = ''
  THEN
    SET p_message = 'Customer ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_trans_no IS NULL OR
  IN_trans_no = ''
  THEN
    SET p_message = 'Transaction number cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  -- Start transaction
  START TRANSACTION;

  BEGIN
    -- Initialize row counter
    SET @row_num = 0;

    -- Generate billing summary ID
    SET v_return_code = '*_*';
    CALL SPCOM_GetIDSequence_NEW(IN_organizationId, '*', IN_Language, 'BILLINGSUMMARYIDCUST', v_billing_summary_id, v_return_code);

    -- Check if ID generation was successful
    IF v_return_code NOT LIKE '000%'
    THEN
      SET p_message = CONCAT('Failed to generate billing summary ID. Return code: ', v_return_code);
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
    END IF;

    DROP TEMPORARY TABLE IF EXISTS temp_billing_data;
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_billing_data AS
    SELECT dav.organizationId,
    dav.warehouseId,
    dah.customerId,
    dav.asnNo,
    dahu.closeTime,
    dad.sku,
    dav.vasType,
    dav.vasQty AS qtyChargeBilling,
    dav.asnLineNo AS lineNo,
    bsm.tariffMasterId,
    bil.tariffId,
    bcm.codeDescr,
    bil.chargeCategory, bil.chargeType,
    bil.rate,
    'QUANTITY' AS ratebase,
    0 cost,
    1 AS rateperunit,
    bil.udf01,
    bil.udf06, NULL incomeTaxRate
    FROM DOC_ASN_VAS dav
         INNER JOIN
         DOC_ASN_HEADER dah
         ON dav.organizationId = dah.organizationId AND
           dav.warehouseId = dah.warehouseId AND
           dav.asnNo = dah.asnNo
         INNER JOIN
         DOC_ASN_DETAILS dad
         ON dav.organizationId = dad.organizationId AND
           dav.warehouseId = dad.warehouseId AND
           dav.asnNo = dad.asnNo AND
           dav.asnLineNo = dad.asnLineNo
         LEFT OUTER JOIN
         BAS_SKU_MULTIWAREHOUSE bsm
         ON bsm.organizationId = dah.organizationId AND
           bsm.warehouseId = dah.warehouseId AND
           bsm.customerId = dah.customerId AND
           bsm.SKU = dad.Sku
         INNER JOIN
         (SELECT btd.organizationId, btd.warehouseId, bth.tariffMasterId, btd.tariffId, btr.rate, btd.chargeCategory, btd.chargeType, btd.vasType, btd.udf01, btd.udf06
       FROM BIL_TARIFF_HEADER bth
            LEFT JOIN
            BIL_TARIFF_DETAILS btd
            ON btd.organizationId = bth.organizationId
              AND
              btd.tariffId = bth.tariffId
            LEFT JOIN
            BIL_TARIFF_RATE btr
            ON btr.organizationId = btd.organizationId
              AND
              btr.tariffId = btd.tariffId
              AND
              btr.tariffLineNo = btd.tariffLineNo
       WHERE btd.organizationId = 'OJV_CML' AND
             bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
             bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
             btd.chargeCategory = 'VA' AND
             btd.vasType <> '' AND
             btd.tariffLineNo <= 100 AND
             btr.rate > 0
       GROUP BY btd.organizationId, btd.warehouseId, btd.tariffId, btr.rate, btd.chargeCategory, btd.chargeType, btd.vasType, btd.udf01, btd.udf06) bil
         ON bil.organizationId = bsm.organizationId AND
           bil.warehouseId = bsm.warehouseId AND
           bil.tariffMasterId = bsm.tariffMasterId AND
           bil.vasType = dav.vasType
         INNER JOIN
         BSM_CODE_ML bcm
         ON dav.organizationId = bcm.organizationId AND
           bcm.codeType = 'VAS_TYP' AND
           bcm.codeid = dav.vasType AND
           bcm.languageId = 'en'
         INNER JOIN
         DOC_ASN_HEADER_UDF dahu
         ON dav.organizationId = dahu.organizationId AND
           dav.warehouseId = dahu.warehouseId AND
           dav.asnNo = dahu.asnNo
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING zbcc
         ON (dav.organizationId = zbcc.organizationId AND
           dav.warehouseId = zbcc.warehouseId AND
           dah.customerId = zbcc.customerId)
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
         ON (zbcc.organizationId = zbccd.organizationId AND
           zbcc.lotatt01 = zbccd.idGroupSp)
    WHERE dav.organizationId = IN_organizationId AND
          dav.warehouseId = IN_warehouseId AND
          dah.customerId = IN_CustomerId AND
          DATE(dahu.closeTime) >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND
          zbcc.lotatt01 <> '' AND
          zbcc.active = 'Y' AND
          zbccd.active = 'Y' AND
          dah.asnStatus IN ('99') AND
          dah.asnType NOT IN ('FREE') AND
          zbccd.spName = 'CML_BILLASNVASSTD' AND
          dah.asnNo = IN_trans_no;



    -- Insert billing summary data
    INSERT INTO BIL_SUMMARY (organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate,
    customerId, sku, lotNum, traceId, tariffId, chargeCategory, chargeType,
    descr, rateBase, chargePerUnits, qty, uom, cubic, weight, chargeRate,
    amount, billingAmount, cost, amountPayable, amountPaid, confirmTime,
    confirmWho, docType, docNo, createTransactionid, notes, ediSendTime,
    billTo, settleTime, settleWho, followUp, invoiceType, paidTo,
    costConfirmFlag, costConfirmTime, costConfirmWho, costSettleFlag,
    costSettleTime, costSettleWho, incomeTaxRate, costTaxRate, incomeTax,
    cosTax, incomeWithoutTax, cosWithoutTax, costInvoiceType, noteText,
    udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag,
    addWho, addTime, editWho, editTime, locationCategory, manual,
    docLineNo, arNo, arLineNo, apNo, apLineNo, ediSendFlag,
    ediErrorCode, ediErrorMessage, ediSendTime2, ediSendFlag2,
    ediErrorCode2, ediErrorMessage2, billingTranCategory, orderType,
    containerType, containerSize)
           SELECT organizationId,
           warehouseId,
           CONCAT(v_billing_summary_id, '*', LPAD(auto_sequence(), 3, '0')) AS billingSummaryId,
           DATE(closeTime) AS billingFromDate,
           DATE(closeTime) AS billingToDate,
           customerId,
           sku,
           '' lotNum,
           '' traceId,
           tariffId,
           chargeCategory,
           chargeType,
           codeDescr AS descr,
           ratebase AS rateBase,
           rateperunit AS chargePerUnits,
           qtyChargeBilling AS qty,
           'EA' uom,
           0 AS cubic,
           0 AS weight,
           rate AS chargeRate,
           qtyChargeBilling * rate / ratePerUnit AS amount,
           (qtyChargeBilling * (rate / ratePerUnit)) +
           (qtyChargeBilling * (rate / ratePerUnit)) * incomeTaxRate / 100 AS billingAmount,
           cost,
           cost * qtyChargeBilling AS amountPayable,
           0 AS amountPaid,
           NOW() AS confirmTime,
           IN_USERID AS confirmWho,
           'ASN' AS docType,
           asnNo AS docNo,
           '' AS createTransactionid,
           '' AS notes,
           NOW() AS ediSendTime,
           customerId AS billTo,
           NOW() AS settleTime,
           IN_USERID AS settleWho,
           '' AS followUp,
           '' AS invoiceType,
           '' AS paidTo,
           'N' AS costConfirmFlag,
           NOW() AS costConfirmTime,
           '' AS costConfirmWho,
           'N' AS costSettleFlag,
           NOW() AS costSettleTime,
           '' AS costSettleWho,
           0 AS incomeTaxRate,
           0 AS costTaxRate,
           qtyChargeBilling * rate / ratePerUnit * incomeTaxRate / 100 AS incomeTax,
           0 AS cosTax,
           qtyChargeBilling * rate / ratePerUnit AS incomeWithoutTax,
           0 AS cosWithoutTax,
           '' AS costInvoiceType,
           '' AS noteText,
           udf01 AS udf01,
           '' AS udf02,
           '' AS udf03,
           udf06 AS udf04,
           '' AS udf05,
           100 AS currentVersion,
           '2020' AS oprSeqFlag,
           IN_USERID AS addWho,
           NOW() AS addTime,
           IN_USERID AS editWho,
           NOW() AS editTime,
           '' locationCategory,
           'N' AS manual,
           0 AS docLineNo,
           '*' AS arNo,
           0 AS arLineNo,
           '*' AS apNo,
           0 AS apLineNo,
           'N' AS ediSendFlag,
           '' AS ediErrorCode,
           '' AS ediErrorMessage,
           NOW() AS ediSendTime2,
           'N' AS ediSendFlag2,
           '' AS ediErrorCode2,
           '' AS ediErrorMessage2,
           '' AS billingTranCategory,
           '' docType,
           '' AS containerType,
           '' AS containerSize
           FROM temp_billing_data
           WHERE qtyChargeBilling > 0;  -- Only insert records with positive billing quantity

    -- Get the number of inserted rows
    SET v_row_count = ROW_COUNT();

    -- Clean up temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_billing_data;

    -- Check if any rows were inserted
    IF v_row_count = 0
    THEN
      -- No data found, but this might be expected
      SET p_message = CONCAT('No billing data found for Vas SO: ', IN_trans_no, ', Customer: ', IN_CustomerId);
      SET p_success_flag = 'W'; -- Warning flag
      SET p_record_count = 0;
      COMMIT; -- Commit even if no rows

    --   CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLSOVASSTD_NW', IN_trans_no, 'error', NULL, NULL, p_success_flag,
    -- p_message, p_record_count, v_start_time, v_end_time);
    ELSE
      -- Calculate execution time
      SET v_end_time = NOW();
      SET v_execution_time = TIMESTAMPDIFF(MICROSECOND, v_start_time, v_end_time) / 1000000;

      -- Commit transaction
      COMMIT;

      -- Set success output parameters
      SET p_success_flag = 'Y';
      SET p_message = CONCAT('VasASN billing processed successfully. ', 'Billing Summary ID: ', v_billing_summary_id, '. Records: ', v_row_count, '. Execution time: ', v_execution_time, ' seconds');
      SET p_record_count = v_row_count;

      CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLASNVASSTD_NW', IN_trans_no, 'no error', NULL, NULL, p_success_flag, p_message, p_record_count, v_start_time, v_end_time);


    END IF;



  END;

END
$$

--
-- Create procedure `Z_SP_ProcessBillingCML_BILLASNVASSTD`
--
CREATE
DEFINER = 'mysql.sys'@'%'
PROCEDURE Z_SP_ProcessBillingCML_BILLASNVASSTD()
  SP:
  BEGIN
    -- Deklarasi variabel untuk menyimpan data dari cursor
    DECLARE v_organizationId varchar(20);
    DECLARE v_warehouseId varchar(20);
    DECLARE v_customerId varchar(30);
    DECLARE v_trans_no varchar(20);
    DECLARE v_spName varchar(30);
    DECLARE v_flag int DEFAULT 0;
    -- Variabel untuk mengontrol loop
    DECLARE done int DEFAULT FALSE;



    -- Deklarasi cursor
    DECLARE billing_cursor CURSOR FOR SELECT DISTINCT dav.organizationId, dav.warehouseId, dah.customerId, dav.asnNo, zbccd.spName
    FROM DOC_ASN_VAS dav
         INNER JOIN
         DOC_ASN_HEADER dah
         ON dav.organizationId = dah.organizationId
           AND
           dav.warehouseId = dah.warehouseId
           AND
           dav.asnNo = dah.asnNo
         INNER JOIN
         DOC_ASN_HEADER_UDF dahu
         ON dav.organizationId = dahu.organizationId
           AND
           dav.warehouseId = dahu.warehouseId
           AND
           dav.asnNo = dahu.asnNo
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING zbcc
         ON (dav.organizationId = zbcc.organizationId AND
           dav.warehouseId = zbcc.warehouseId AND
           dah.customerId = zbcc.customerId)
         INNER JOIN
         Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
         ON (zbcc.organizationId = zbccd.organizationId AND
           zbcc.lotatt01 = zbccd.idGroupSp)
    WHERE dav.organizationId = 'OJV_CML' AND
          DATE(dahu.closeTime) > getBillFMDate(25) AND
          zbcc.lotatt01 <> '' AND
          zbcc.active = 'Y' AND
          zbccd.active = 'Y' AND
          dah.asnStatus IN ('99') AND
          dah.asnType NOT IN ('FREE') AND
          zbccd.spName = 'CML_BILLASNVASSTD' AND
          NOT EXISTS (SELECT 1
        FROM BIL_SUMMARY
        WHERE organizationId = dah.organizationId AND
              warehouseId = dah.warehouseId AND
              customerId = dah.customerId AND
              chargeCategory = 'VA' AND
              docNo = dav.asnNo AND
              docType = 'ASN' AND
              addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH));


    -- Handler untuk kondisi NOT FOUND
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Buka cursor
    OPEN billing_cursor;

    -- Loop untuk memproses setiap baris
    read_loop:
    LOOP
      -- Fetch data dari cursor
      FETCH billing_cursor INTO v_organizationId,
      v_warehouseId,
      v_customerId,
      v_trans_no,
      v_spName;

      -- Jika tidak ada data lagi, keluar dari loop
      IF done
      THEN

        LEAVE read_loop;
      END IF;




      SET @IN_organizationId = 'OJV_CML';
      SET @IN_warehouseId = v_warehouseId;
      SET @IN_USERID = 'CUSTOMBILL';
      SET @IN_Language = 'en';
      SET @IN_CustomerId = v_customerId;
      SET @IN_trans_no = v_trans_no;
      CALL CML_BILLASNVASSTD_NW(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @p_success_flag, @p_message, @p_record_count);


    END LOOP;


    -- Tutup cursor
    CLOSE billing_cursor;



  END
  $$

--
-- Create procedure `CML_BILLFIXCHG_NW`
--
CREATE
DEFINER = 'root'@'%'
PROCEDURE CML_BILLFIXCHG_NW
(
                 OUT p_success_flag char(1), OUT p_message varchar(1000), OUT p_record_count int
)
BEGIN
  -- =============================================
  -- Stored Procedure: CML_BILLFIXCHG_BETA
  -- Purpose: Process fixed charge billing for customers
  -- Author: [Akbar@IT-LINC]
  -- Date: [27.08.25]
  -- =============================================

  -- Declare variables
  DECLARE v_current_date timestamp;
  DECLARE v_billing_summary_id varchar(30) DEFAULT '';
  DECLARE v_return_code varchar(1000);
  DECLARE v_row_count int DEFAULT 0;
  DECLARE v_error_code varchar(5);
  DECLARE v_error_msg varchar(1000);

  -- Declare handlers for exceptions
  DECLARE EXIT HANDLER FOR SQLEXCEPTION

  BEGIN
    -- Get error information
    GET DIAGNOSTICS CONDITION 1
    v_error_code = RETURNED_SQLSTATE,
    v_error_msg = MESSAGE_TEXT;

    -- Rollback transaction
    ROLLBACK;

    -- Set output parameters
    SET p_success_flag = 'N';
    SET p_message = CONCAT('Error Code: ', v_error_code, ' - ', v_error_msg);
    SET p_record_count = 0;

  -- Log error (optional - uncomment if you have error log table)
  -- INSERT INTO ERROR_LOG (procedure_name, error_code, error_message, error_time)
  -- VALUES ('CML_BILLFIXCHG_BETA', v_error_code, v_error_msg, NOW());
  END;

  -- Initialize output parameters
  SET p_success_flag = 'N';
  SET p_message = '';
  SET p_record_count = 0;

  -- Start transaction
  START TRANSACTION;

  BEGIN
    -- Set current date
    SET v_current_date = CURDATE();

    -- Generate billing summary ID
    SET v_return_code = '*_*';
    CALL SPCOM_GetIDSequence_NEW('OJV_CML', '*', 'en', 'BILLINGSUMMARYIDCUST', v_billing_summary_id, v_return_code);

    -- Check if ID generation was successful
    IF v_return_code NOT LIKE '000%'
    THEN
      SET p_message = CONCAT('Failed to generate billing summary ID. Return code: ', v_return_code);
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
    END IF;

    -- Insert fixed charge billing data
    INSERT INTO BIL_SUMMARY (organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate,
    customerId, sku, lotNum, traceId, tariffId, chargeCategory, chargeType,
    descr, rateBase, chargePerUnits, qty, uom, cubic, weight, chargeRate,
    amount, billingAmount, cost, amountPayable, amountPaid, confirmTime,
    confirmWho, docType, docNo, createTransactionid, notes, ediSendTime,
    billTo, settleTime, settleWho, followUp, invoiceType, paidTo,
    costConfirmFlag, costConfirmTime, costConfirmWho, costSettleFlag,
    costSettleTime, costSettleWho, incomeTaxRate, costTaxRate, incomeTax,
    cosTax, incomeWithoutTax, cosWithoutTax, costInvoiceType, noteText,
    udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag,
    addWho, addTime, editWho, editTime, locationCategory, manual,
    docLineNo, arNo, arLineNo, apNo, apLineNo, ediSendFlag,
    ediErrorCode, ediErrorMessage, ediSendTime2, ediSendFlag2,
    ediErrorCode2, ediErrorMessage2, billingTranCategory, orderType,
    containerType, containerSize)
           SELECT
           -- Organization and warehouse
           fch.organizationId,
           fch.warehouseId,
           -- 'CBT01',
           CONCAT(v_billing_summary_id, '*', LPAD(@row_num := @row_num + 1, 3, '0')) AS billingSummaryId,

           -- Billing dates
           STR_TO_DATE(CONCAT(YEAR(NOW()), '-', MONTH(NOW()), '-', fch.billingDate), '%Y-%m-%d') AS billingFromDate,
           STR_TO_DATE(CONCAT(YEAR(NOW()), '-', MONTH(NOW()), '-', fch.billingDate), '%Y-%m-%d') AS billingToDate,

           -- Customer and SKU information
           fch.customerId,
           -- 'PT.ABC',
           '' AS sku,
           '' AS lotNum,
           '' AS traceId,

           -- Tariff information
           fch.tariffId,
           fch.chargeCategory,
           fch.chargeType,
           fch.descrC,
           fch.ratebase,

           -- Quantity and amount
           1 AS chargePerUnits,
           1 AS qty,
           '' AS uom,
           0 AS cubic,
           0 AS weight,
           fch.fixAmount AS chargeRate,
           fch.fixAmount AS amount,
           fch.fixAmount AS billingAmount,
           0 AS cost,
           fch.fixAmount AS amountPayable,
           0 AS amountPaid,

           -- Timestamps and users
           NOW() AS confirmTime,
           'SYSTEM' AS confirmWho,
           'FX' AS docType,
           '' AS docNo,
           '' AS createTransactionid,
           '' AS notes,
           NOW() AS ediSendTime,
           fch.customerId AS billTo,
           NOW() AS settleTime,
           'SYSTEM' AS settleWho,
           '' AS followUp,
           '' AS invoiceType,
           '' AS paidTo,

           -- Cost confirmation flags
           'N' AS costConfirmFlag,
           NOW() AS costConfirmTime,
           '' AS costConfirmWho,
           'N' AS costSettleFlag,
           NOW() AS costSettleTime,
           '' AS costSettleWho,

           -- Tax information
           fch.incomeTaxRate,
           0 AS costTaxRate,
           fch.incomeTax,
           0 AS cosTax,
           fch.fixAmount AS incomeWithoutTax,
           0 AS cosWithoutTax,
           '' AS costInvoiceType,
           '' AS noteText,

           -- User defined fields
           fch.MaterialNo AS udf01,
           fch.itemChargeCategory AS udf02,
           '' AS udf03,
           fch.divisionCode AS udf04,
           '' AS udf05,

           -- System fields
           100 AS currentVersion,
           '2020' AS oprSeqFlag,
           'CUSTOMBILL' AS addWho,
           NOW() AS addTime,
           'CUSTOMBILL' AS editWho,
           NOW() AS editTime,

           -- Additional fields
           '' AS locationCategory,
           'N' AS manual,
           0 AS docLineNo,
           '*' AS arNo,
           0 AS arLineNo,
           '*' AS apNo,
           0 AS apLineNo,

           -- EDI fields
           'N' AS ediSendFlag,
           '' AS ediErrorCode,
           '' AS ediErrorMessage,
           NOW() AS ediSendTime2,
           'N' AS ediSendFlag2,
           '' AS ediErrorCode2,
           '' AS ediErrorMessage2,

           -- Category fields
           '' AS billingTranCategory,
           '' AS orderType,
           '' AS containerType,
           '' AS containerSize
           FROM (SELECT DISTINCT bcm.organizationId, bcm.warehouseId, bcm.customerId, bcm.tariffMasterId,
           -- Extract billing date
           DAY(STR_TO_DATE(CONCAT(YEAR(NOW()), '-', MONTH(NOW()), '-', bth.udf02), '%Y-%m-%d')) AS billingDate, IFNULL(bth.tariffId, '*') AS tariffId, btd.tariffLineNo, btd.chargeCategory, btd.chargeType, btd.descrC, btd.ratebase, btd.incomeTaxRate,
           -- Calculate tax
           CASE WHEN btd.incomeTaxRate > 0 THEN (IFNULL(btd.UDF03, 0) * btd.incomeTaxRate / 100) ELSE 0 END AS incomeTax,
           -- Fix amount
           IFNULL(btd.UDF03, 0) AS fixAmount, btd.minAmount, btd.UDF01 AS MaterialNo, btd.udf02 AS itemChargeCategory, btd.UDF06 AS divisionCode, bth.contractNo
         FROM BAS_CUSTOMER_MULTIWAREHOUSE bcm
              -- Join with customer master
              INNER JOIN
              BAS_CUSTOMER bc
              ON bc.customerId = bcm.customerId
                AND
                bc.organizationId = bcm.organizationId
                AND
                bc.CustomerType = 'OW'
                AND
                bc.activeFlag = 'Y'
              -- Join with tariff header
              LEFT JOIN
              BIL_TARIFF_HEADER bth
              ON bth.organizationId = bcm.organizationId
                AND
                bth.tariffMasterId = bcm.tariffMasterId
              -- Join with tariff details
              LEFT JOIN
              BIL_TARIFF_DETAILS btd
              ON btd.organizationId = bth.organizationId
                AND
                btd.tariffId = bth.tariffId
         WHERE bcm.organizationId = 'OJV_CML'
               -- Date range validation
               AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d') AND
               (
               bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d') OR
               bth.effectiveTo >= DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '%Y-%m-%d')
               )
               -- Fixed charge category
               AND btd.chargeCategory = 'FX'
               -- Only process charges with positive amounts
               AND IFNULL(btd.UDF03, 0) > 0) fch
                CROSS JOIN
                (SELECT @row_num := 0) r;

    -- Get the number of inserted rows
    SET v_row_count = ROW_COUNT();

    -- Check if any rows were inserted
    IF v_row_count = 0
    THEN
      SET p_message = 'No fixed charges found for processing.';
      SET p_success_flag = 'W'; -- Warning flag
      SET p_record_count = 0;
      COMMIT; -- Commit even if no rows, as this is not an error
    ELSE
      -- Commit transaction if successful
      COMMIT;

      -- Set success output parameters
      SET p_success_flag = 'Y';
      SET p_message = CONCAT('Fixed charge billing processed period 20/', MONTH(NOW()), '/', YEAR(NOW()), ' successfully. Prefix Billing Summary ID: ', v_billing_summary_id, '*XXX', '. Records inserted: ', v_row_count);
      SET p_record_count = v_row_count;

      SELECT zcml_alert_message(p_message, '-4075819187');
    END IF;

  END;

END
$$

DELIMITER ;