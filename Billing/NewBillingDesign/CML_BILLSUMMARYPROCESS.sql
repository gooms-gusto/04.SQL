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
-- Create procedure `CML_BILLSUMMARYPROCESS`
--
CREATE
DEFINER = 'wms_ftest'@'%'
PROCEDURE CML_BILLSUMMARYPROCESS (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_BillingSummaryID text)
ENDPROC:
  BEGIN
    DECLARE delimiterChar text;
    DECLARE inputString text;
    DECLARE OUT_returnCode varchar(1000);
    DROP TEMPORARY TABLE IF EXISTS temp_bilsummaryId;
    CREATE TEMPORARY TABLE temp_bilsummaryId (
      vals text
    );
    SET delimiterChar = ',';
    SET inputString = IN_BillingSummaryID;
    WHILE LOCATE(delimiterChar, inputString) > 1 DO
      INSERT INTO temp_bilsummaryId
        SELECT
          SUBSTRING_INDEX (inputString, delimiterChar, 1);
      SET inputString = REPLACE(inputString, (SELECT
          LEFT(inputString, LOCATE(delimiterChar, inputString))), '');
    END WHILE;
    INSERT INTO temp_bilsummaryId (vals)
      VALUES (inputString);

    -- GENERATE ARNUMBER
    SET OUT_returnCode = '*_*';
    SET @linenumber = 0;
    CALL SPCOM_GetIDSequence_NEW(IN_organizationId, IN_warehouseId, IN_Language, 'BILLINGAR', r_generateArno, OUT_returnCode);
    IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
      SET OUT_returnCode = '999#计费流水获取异常';
    --   LEAVE cur_billingsm_loop;
    END IF;


    BEGIN


      DECLARE r_organizationId varchar(20);
      DECLARE r_warehouseId varchar(20);
      DECLARE r_billingSummaryId varchar(30);
      DECLARE r_billingFromDate varchar(10);
      DECLARE r_billingToDate varchar(10);
      DECLARE r_customerId varchar(30);
      DECLARE r_sku varchar(50);
      DECLARE r_lotNum varchar(10);
      DECLARE r_traceId varchar(30);
      DECLARE r_tariffId varchar(10);
      DECLARE r_chargeCategory varchar(20);
      DECLARE r_chargeType varchar(20);
      DECLARE r_descr varchar(60);
      DECLARE r_rateBase varchar(20);
      DECLARE r_chargePerUnits decimal(18, 3);
      DECLARE r_qty decimal(18, 8);
      DECLARE r_uom varchar(10);
      DECLARE r_cubic decimal(24, 8);
      DECLARE r_weight decimal(18, 8);
      DECLARE r_chargeRate decimal(24, 8);
      DECLARE r_amount decimal(24, 8);
      DECLARE r_billingAmount decimal(24, 8);
      DECLARE r_cost decimal(24, 8);
      DECLARE r_amountPayable decimal(24, 8);
      DECLARE r_amountPaid decimal(24, 8);
      DECLARE r_confirmTime timestamp;
      DECLARE r_confirmWho varchar(30);
      DECLARE r_docType varchar(20);
      DECLARE r_docNo varchar(20);
      DECLARE r_createTransactionid varchar(20);
      DECLARE r_notes mediumtext binary;
      DECLARE r_ediSendTime timestamp;
      DECLARE r_billTo varchar(35);
      DECLARE r_settleTime timestamp;
      DECLARE r_settleWho varchar(30);
      DECLARE r_followUp varchar(20);
      DECLARE r_invoiceType varchar(20);
      DECLARE r_paidTo varchar(30);
      DECLARE r_costConfirmFlag char(1);
      DECLARE r_costConfirmTime timestamp;
      DECLARE r_costConfirmWho varchar(30);
      DECLARE r_costSettleFlag char(1);
      DECLARE r_costSettleTime timestamp;
      DECLARE r_costSettleWho varchar(30);
      DECLARE r_incomeTaxRate decimal(24, 8);
      DECLARE r_costTaxRate decimal(24, 8);
      DECLARE r_incomeTax decimal(24, 8);
      DECLARE r_cosTax decimal(24, 8);
      DECLARE r_incomeWithoutTax decimal(24, 8);
      DECLARE r_cosWithoutTax decimal(24, 8);
      DECLARE r_costInvoiceType varchar(20);
      DECLARE r_noteText mediumtext binary;
      DECLARE r_udf01 varchar(500);
      DECLARE r_udf02 varchar(500);
      DECLARE r_udf03 varchar(500);
      DECLARE r_udf04 varchar(500);
      DECLARE r_udf05 varchar(500);
      DECLARE r_currentVersion int(11);
      DECLARE r_oprSeqFlag varchar(65);
      DECLARE r_locationCategory varchar(10);
      DECLARE r_manual char(1);
      DECLARE r_docLineNo int(11);
      DECLARE r_arNo varchar(20);
      DECLARE r_arLineNo int(11);
      DECLARE r_apNo varchar(20);
      DECLARE r_apLineNo int(11);
      DECLARE r_ediSendFlag char(1);
      DECLARE r_ediErrorCode varchar(50);
      DECLARE r_ediErrorMessage text;
      DECLARE r_ediSendTime2 timestamp;
      DECLARE r_ediSendFlag2 char(1);
      DECLARE r_ediErrorCode2 varchar(50);
      DECLARE r_ediErrorMessage2 text binary;
      DECLARE r_billingTranCategory varchar(10);
      DECLARE r_orderType varchar(20);
      DECLARE r_containerType char(2);
      DECLARE r_containerSize char(2);
      DECLARE r_generateArno char(15);



      DECLARE inventory_done int DEFAULT 0;
      DECLARE tariff_done int DEFAULT 0;
      DECLARE billing_sm_done,
              attribute_done int DEFAULT 0;




      DECLARE cur_billingsm CURSOR FOR
      SELECT
        organizationId,
        warehouseId,
        billingSummaryId,
        billingFromDate,
        billingToDate,
        customerId,
        sku,
        lotNum,
        traceId,
        tariffId,
        chargeCategory,
        chargeType,
        descr,
        rateBase,
        chargePerUnits,
        qty,
        uom,
        cubic,
        weight,
        chargeRate,
        amount,
        billingAmount,
        cost,
        amountPayable,
        amountPaid,
        confirmTime,
        confirmWho,
        docType,
        docNo,
        createTransactionid,
        notes,
        ediSendTime,
        billTo,
        settleTime,
        settleWho,
        followUp,
        invoiceType,
        paidTo,
        costConfirmFlag,
        costConfirmTime,
        costConfirmWho,
        costSettleFlag,
        costSettleTime,
        costSettleWho,
        incomeTaxRate,
        costTaxRate,
        incomeTax,
        cosTax,
        incomeWithoutTax,
        cosWithoutTax,
        costInvoiceType,
        noteText,
        udf01,
        udf02,
        udf03,
        udf04,
        udf05,
        currentVersion,
        oprSeqFlag,
        locationCategory,
        manual,
        docLineNo,
        arNo,
        arLineNo,
        apNo,
        apLineNo,
        ediSendFlag,
        ediErrorCode,
        ediErrorMessage,
        ediSendTime2,
        ediSendFlag2,
        ediErrorCode2,
        ediErrorMessage2,
        billingTranCategory,
        orderType,
        containerType,
        containerSize
      FROM BIL_SUMMARY bs
      WHERE bs.organizationId = IN_organizationId
      AND bs.warehouseId = IN_warehouseId
      AND bs.billingSummaryId IN (SELECT
          vals
        FROM temp_string);

      DECLARE CONTINUE HANDLER FOR NOT FOUND SET billing_sm_done = 1;
      OPEN cur_billingsm;
    cur_billingsm_loop:
      LOOP
        FETCH FROM cur_billingsm INTO r_organizationId,
        r_warehouseId, r_billingSummaryId, r_billingFromDate, r_billingToDate, r_customerId, r_sku, r_lotNum, r_traceId, r_tariffId, r_chargeCategory, r_chargeType, r_descr, r_rateBase,
        r_chargePerUnits, r_qty, r_uom, r_cubic, r_weight, r_chargeRate, r_amount, r_billingAmount, r_cost, r_amountPayable, r_amountPaid, r_confirmTime, r_confirmWho, r_docType, r_docNo,
        r_createTransactionid, r_notes, r_ediSendTime, r_billTo, r_settleTime, r_settleWho, r_followUp, r_invoiceType, r_paidTo, r_costConfirmFlag, r_costConfirmTime, r_costConfirmWho, r_costSettleFlag,
        r_costSettleTime, r_costSettleWho, r_incomeTaxRate, r_costTaxRate, r_incomeTax, r_cosTax, r_incomeWithoutTax, r_cosWithoutTax, r_costInvoiceType, r_noteText, r_udf01, r_udf02,
        r_udf03, r_udf04, r_udf05, r_currentVersion, r_oprSeqFlag, r_locationCategory, r_manual, r_docLineNo, r_arNo, r_arLineNo, r_apNo, r_apLineNo, r_ediSendFlag,
        r_ediErrorCode, r_ediErrorMessage, r_ediSendTime2, r_ediSendFlag2, r_ediErrorCode2, r_ediErrorMessage2, r_billingTranCategory, r_orderType, r_containerType, r_containerSize;

        IF billing_sm_done = 1 THEN
          SET billing_sm_done = 0;
          LEAVE cur_billingsm_loop;
        END IF;


        INSERT INTO CML_TEMP_LOG (ID_STATUS)
          VALUES (r_billingSummaryId);

        UPDATE BIL_SUMMARY bs
        SET bs.arNo = r_generateArno
        WHERE bs.billingSummaryId = r_billingSummaryId
        AND bs.warehouseId = r_warehouseId
        AND bs.customerId = r_customerId;

        SELECT
          r_generateArno;

      END LOOP cur_billingsm_loop;
      CLOSE cur_billingsm;
      -- SET OUT_returnCode = '000';\
      DROP TEMPORARY TABLE IF EXISTS temp_string;
      COMMIT;
    END;
  END
  $$

DELIMITER ;