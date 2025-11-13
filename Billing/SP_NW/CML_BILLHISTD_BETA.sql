--
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Drop procedure `CML_BILLHISTD_BETA`
--
DROP PROCEDURE IF EXISTS CML_BILLHISTD_BETA;

DELIMITER $$

--
-- Create procedure `CML_BILLHISTD_BETA`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLHISTD_BETA (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_trans_no varchar(30),
OUT p_success_flag char(1),
OUT p_message varchar(1000),
OUT p_record_count int)
BEGIN
  -- =============================================
  -- Stored Procedure: CML_BILLHISTD_BETA
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
  IF IN_organizationId IS NULL
    OR IN_organizationId = '' THEN
    SET p_message = 'Organization ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_CustomerId IS NULL
    OR IN_CustomerId = '' THEN
    SET p_message = 'Customer ID cannot be empty';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
  END IF;

  IF IN_trans_no IS NULL
    OR IN_trans_no = '' THEN
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
      CALL SPCOM_GetIDSequence_NEW(IN_organizationId,
      '*',
      IN_Language,
      'BILLINGSUMMARYIDCUST',
      v_billing_summary_id,
      v_return_code);

      -- Check if ID generation was successful
      IF v_return_code NOT LIKE '000%' THEN
        SET p_message = CONCAT('Failed to generate billing summary ID. Return code: ', v_return_code);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
      END IF;


      CREATE TEMPORARY TABLE IF NOT EXISTS temp_billing_data AS
      SELECT
        dah.organizationId,
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
        CASE WHEN bpdEA.uomDescr IN ('G', 'GRAM', 'Gram') THEN SUM(atl.toQty_Each / 1000) WHEN bpdEA.uomDescr IN ('MT', 'Metric Ton', 'METRIC TON') THEN SUM(atl.toQty_Each * 1000) ELSE SUM(atl.toQty_Each * bs.grossWeight) END AS qtyChargeGrossWeight,

        -- Metric ton calculation
        CASE WHEN atl.toCustomerId LIKE '%ABC%' THEN SUM((atl.toQty_Each * bpdCS.qty) / 1000) WHEN atl.toCustomerId IN ('ADASBY', 'CAI_MDN', 'CAI_SBY') THEN IFNULL(CAST(SUM((atl.toQty_Each * bs.netweight) / 1000) AS char(255)), 0) ELSE SUM(atl.toQty_Each / 1000) END AS qtyChargeMetricTon,


        -- Calculate billing quantity based on rate base
        CASE WHEN btd.ratebase = 'CUBIC' THEN SUM(atl.toQty_Each * bs.cube) WHEN btd.ratebase = 'M2' THEN CASE WHEN atl.tocustomerId = 'MAP' AND
                  ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
                  bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0)) ELSE SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0)) END WHEN btd.ratebase = 'IP' THEN COALESCE(CEIL(SUM(atl.toQty_Each / NULLIF(bpdIP.qty, 0))), 1) WHEN btd.ratebase = 'KG' THEN CASE WHEN atl.tocustomerId = 'MAP' AND
                  ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
                  bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0)) ELSE SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0)) END WHEN btd.ratebase = 'LITER' THEN CASE WHEN atl.tocustomerId = 'MAP' AND
                  ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
                  bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0)) ELSE SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0)) END WHEN btd.ratebase = 'QUANTITY' THEN CASE WHEN atl.tocustomerId = 'MAP' AND
                  ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
                  bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0)) ELSE SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0)) END WHEN btd.ratebase = 'DO' THEN COUNT(DISTINCT dah.asnNo) WHEN btd.ratebase = 'PALLET' THEN CEIL(SUM(atl.toQty_Each / NULLIF(bpdPL.qty, 0))) WHEN btd.ratebase = 'CASE' THEN CEIL(SUM(atl.toQty_Each / NULLIF(bpdCS.qty, 0))) WHEN btd.ratebase = 'NETWEIGHT' THEN SUM(atl.toQty_Each * bs.netWeight) WHEN btd.ratebase = 'GW' THEN CASE WHEN bpdEA.uomDescr IN ('G', 'GRAM', 'Gram') THEN SUM(atl.toQty_Each / 1000) WHEN bpdEA.uomDescr IN ('MT', 'Metric Ton', 'METRIC TON') THEN SUM(atl.toQty_Each * 1000) ELSE SUM(atl.toQty_Each * bs.grossWeight) END WHEN btd.ratebase = 'MT' THEN CASE WHEN atl.tocustomerId LIKE '%ABC%' THEN SUM((atl.toQty_Each * bpdCS.qty) / 1000) WHEN atl.tocustomerId IN ('ADASBY', 'CAI_MDN', 'CAI_SBY') THEN IFNULL(CAST(SUM((atl.toQty_Each * bs.netweight) / 1000) AS char(255)), 0) ELSE SUM(atl.toQty_Each / 1000) END ELSE 0 END AS qtyChargeBilling,
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
        CASE WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1 ELSE IFNULL(btr.classfrom, 0) END AS classFrom,
        IFNULL(classTo, 0) AS classTo,
        bth.contractNo,
        btr.cost,
        btd.billingParty,
        bl.locationCategory
      FROM ACT_TRANSACTION_LOG atl
        LEFT OUTER JOIN BAS_SKU bs
          ON bs.organizationId = atl.organizationId
          AND bs.customerId = atl.toCustomerId
          AND bs.SKU = atl.toSku
        LEFT OUTER JOIN BAS_SKU_MULTIWAREHOUSE bsm
          ON bsm.organizationId = atl.organizationId
          AND bsm.warehouseId = atl.warehouseId
          AND bsm.customerId = atl.tocustomerId
          AND bsm.SKU = atl.toSku
        LEFT OUTER JOIN DOC_ASN_HEADER dah
          ON dah.organizationId = atl.organizationId
          AND dah.warehouseId = atl.warehouseId
          AND dah.asnNo = atl.docNo
          AND dah.customerId = atl.fmCustomerId
        LEFT JOIN DOC_ASN_HEADER_UDF daf
          ON dah.organizationId = daf.organizationId
          AND dah.warehouseId = daf.warehouseId
          AND dah.asnNo = daf.asnNo
        LEFT OUTER JOIN DOC_ASN_DETAILS dad
          ON dad.organizationId = atl.organizationId
          AND dad.warehouseId = atl.warehouseId
          AND dad.asnNo = atl.docNo
          AND dad.asnLineNo = atl.docLineNo
          AND dad.sku = atl.toSku
        LEFT OUTER JOIN INV_LOT_ATT ila
          ON ila.organizationId = atl.organizationId
          AND ila.customerId = atl.toCustomerId
          AND ila.SKU = atl.toSku
          AND ila.lotNum = atl.toLotNum
        LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdEA
          ON bpdEA.organizationId = bs.organizationId
          AND bpdEA.packId = bs.packId
          AND bpdEA.customerId = bs.customerId
          AND bpdEA.packUom = 'EA'
        LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdIP
          ON bpdIP.organizationId = bs.organizationId
          AND bpdIP.packId = bs.packId
          AND bpdIP.customerId = bs.customerId
          AND bpdIP.packUom = 'IP'
        LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdCS
          ON bpdCS.organizationId = bs.organizationId
          AND bpdCS.packId = bs.packId
          AND bpdCS.customerId = bs.customerId
          AND bpdCS.packUom = 'CS'
        LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdPL
          ON bpdPL.organizationId = bs.organizationId
          AND bpdPL.packId = bs.packId
          AND bpdPL.customerId = bs.customerId
          AND bpdPL.packUom = 'PL'
        LEFT JOIN BSM_CODE_ML t1
          ON t1.organizationId = atl.organizationId
          AND t1.codeType = 'ASN_TYP'
          AND dah.asnType = t1.codeId
          AND t1.languageId = 'en'
        LEFT JOIN BSM_CODE BT
          ON BT.organizationId = atl.organizationId
          AND BT.codeType = 'BILLING_TRANSACTION_CATEGORY'
          AND BT.outerCode = ila.lotAtt07
        LEFT JOIN BAS_LOCATION bl
          ON bl.organizationId = atl.organizationId
          AND bl.warehouseId = atl.warehouseId
          AND bl.locationId = atl.toLocation
        LEFT JOIN BAS_ZONE bz
          ON bz.organizationId = bl.organizationId
          AND bz.organizationId = bl.organizationId
          AND bz.warehouseId = bl.warehouseId
          AND bz.zoneId = bl.zoneId
          AND bz.zoneGroup = bl.zoneGroup
        LEFT JOIN BIL_TARIFF_HEADER bth
          ON bth.organizationId = bsm.organizationId
          AND bth.tariffMasterId = bsm.tariffMasterId
        LEFT JOIN BIL_TARIFF_DETAILS btd
          ON btd.organizationId = bth.organizationId
          AND btd.tariffId = bth.tariffId
          AND btd.docType = dah.asnType
        LEFT JOIN BIL_TARIFF_RATE btr
          ON btr.organizationId = btd.organizationId
          AND btr.tariffId = btd.tariffId
          AND btr.tariffLineNo = btd.tariffLineNo
      WHERE atl.organizationId = IN_organizationId
      AND atl.warehouseId = IN_warehouseId
      AND dah.customerId = IN_CustomerId
      AND dah.asnNo = IN_trans_no
      AND COALESCE(ila.lotAtt04, '') NOT IN ('SET') /*AL validate batch*/
      AND atl.transactionType = 'IN'
      AND dah.asnType NOT IN ('FREE', 'IU', 'TTG')
      AND dad.skuDescr NOT LIKE '%PALLET%'
      AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND btd.chargeCategory = 'IB'
      AND (
      btd.billingTranCategory IS NULL
      OR btd.billingTranCategory = ''
      OR btd.billingTranCategory = BT.codeid
      )
      AND btr.rate > 0
      AND NOT EXISTS (SELECT
          1
        FROM Z_SKUNOTBILLING zsnb
        WHERE zsnb.organizationId = dah.organizationId
        AND zsnb.customerId = dah.customerId
        AND zsnb.sku = atl.toSku)
      AND atl.STATUS IN ('80', '99')
      AND dah.asnStatus IN ('99')
      GROUP BY atl.docNo,
               atl.docLineNo,
               atl.toCustomerId,
               atl.toSku,
               atl.toQty,
               atl.toQty_Each,
               atl.toUom,
               atl.addTime,
               atl.transactionTime,
               atl.toLotNum,
               atl.toId,
               atl.tomuid,
               atl.toLocation,
               atl.warehouseId,
               atl.tocustomerId,
               atl.transactionId,
               atl.editTime,
               dah.organizationId,
               dah.asnNo,
               dah.asnType,
               dah.asnReference1,
               dah.asnReference3,
               dah.asnReference1,
               dad.SkuDescr,
               bsm.tariffMasterId,
               bs.grossWeight,
               bs.cube,
               bs.sku_group1,
               bz.zoneDescr,
               bpdCS.packId,
               bpdPL.packId,
               bpdCS.qty,
               bpdPL.qty,
               ila.lotAtt04,
               ila.lotAtt07,
               t1.codeid,
               BT.codeid,
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
               btd.UDF03,
               btd.UDF01,
               btd.udf02,
               btd.udf04,
               btd.UDF05,
               btd.UDF06,
               btd.UDF07,
               btd.UDF08,
               btd.incomeTaxRate,
               bth.contractNo,
               bth.tariffMasterId,
               btr.cost,
               bl.locationCategory;

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
        SELECT
          organizationId,
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
          'ASN' AS docType,
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
      IF v_row_count = 0 THEN
        -- No data found, but this might be expected
        SET p_message = CONCAT('No billing data found for Order: ', IN_trans_no,
        ', Customer: ', IN_CustomerId);
        SET p_success_flag = 'W'; -- Warning flag
        SET p_record_count = 0;
        COMMIT; -- Commit even if no rows

        CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLHISTD', IN_trans_no, 'error', NULL, NULL, p_success_flag,
        p_message, p_record_count, v_start_time, v_end_time);
      ELSE
        -- Calculate execution time
        SET v_end_time = NOW();
        SET v_execution_time = TIMESTAMPDIFF(MICROSECOND, v_start_time, v_end_time) / 1000000;

        -- Commit transaction
        COMMIT;

        -- Set success output parameters
        SET p_success_flag = 'Y';
        SET p_message = CONCAT('Inbound billing processed successfully. ',
        'Billing Summary ID: ', v_billing_summary_id,
        '. Records: ', v_row_count,
        '. Execution time: ', v_execution_time, ' seconds');
        SET p_record_count = v_row_count;

        CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLHISTD', IN_trans_no, 'no error', NULL, NULL, p_success_flag,
        p_message, p_record_count, v_start_time, v_end_time);


      END IF;



    END;

END
$$

DELIMITER ;