--
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Drop procedure `CML_BILLHOSTD_BETA`
--
DROP PROCEDURE IF EXISTS CML_BILLHOSTD_BETA;

DELIMITER $$

--
-- Create procedure `CML_BILLHOSTD_BETA`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLHOSTD_BETA (IN IN_organizationId varchar(30),
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
        doh.organizationId,
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
        CASE WHEN aad.customerId = 'MAP' AND
            ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
            bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) END AS qtyChargeEA,

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
        CASE WHEN bpdEA.uomDescr IN ('G', 'GRAM', 'Gram') THEN SUM(aad.qtyShipped_each / 1000) WHEN bpdEA.uomDescr IN ('MT', 'Metric Ton', 'METRIC TON') THEN SUM(aad.qtyShipped_each * 1000) ELSE SUM(aad.qtyShipped_each * bs.grossWeight) END AS qtyChargeGrossWeight,

        -- Metric ton calculation
        CASE WHEN aad.customerId LIKE '%ABC%' THEN SUM((aad.qtyShipped_each * bpdCS.qty) / 1000) WHEN aad.customerId IN ('ADASBY', 'CAI_MDN', 'CAI_SBY') THEN IFNULL(CAST(SUM((aad.qtyShipped_each * bs.netweight) / 1000) AS char(255)), 0) ELSE SUM(aad.qtyShipped_each / 1000) END AS qtyChargeMetricTon,

        df.closeTime,

        -- Calculate billing quantity based on rate base
        CASE WHEN btd.ratebase = 'CUBIC' THEN SUM(aad.qtyShipped_each * bs.cube) WHEN btd.ratebase = 'M2' THEN CASE WHEN aad.customerId = 'MAP' AND
                  ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
                  bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) END WHEN btd.ratebase = 'IP' THEN COALESCE(CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdIP.qty, 0))), 1) WHEN btd.ratebase = 'KG' THEN CASE WHEN aad.customerId = 'MAP' AND
                  ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
                  bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) END WHEN btd.ratebase = 'LITER' THEN CASE WHEN aad.customerId = 'MAP' AND
                  ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
                  bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) END WHEN btd.ratebase = 'QUANTITY' THEN CASE WHEN aad.customerId = 'MAP' AND
                  ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
                  bsm.tariffMasterId LIKE '%PIECE%' THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) END
          --  WHEN btd.ratebase = 'DO' THEN COUNT(DISTINCT doh.orderNo) * DO Ratebase cannot use this store procedure
          WHEN btd.ratebase = 'PALLET' THEN CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdPL.qty, 0))) WHEN btd.ratebase = 'CASE' THEN CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdCS.qty, 0))) WHEN btd.ratebase = 'NETWEIGHT' THEN SUM(aad.qtyShipped_each * bs.netWeight) WHEN btd.ratebase = 'GW' THEN CASE WHEN bpdEA.uomDescr IN ('G', 'GRAM', 'Gram') THEN SUM(aad.qtyShipped_each / 1000) WHEN bpdEA.uomDescr IN ('MT', 'Metric Ton', 'METRIC TON') THEN SUM(aad.qtyShipped_each * 1000) ELSE SUM(aad.qtyShipped_each * bs.grossWeight) END WHEN btd.ratebase = 'MT' THEN CASE WHEN aad.customerId LIKE '%ABC%' THEN SUM((aad.qtyShipped_each * bpdCS.qty) / 1000) WHEN aad.customerId IN ('ADASBY', 'CAI_MDN', 'CAI_SBY') THEN IFNULL(CAST(SUM((aad.qtyShipped_each * bs.netweight) / 1000) AS char(255)), 0) ELSE SUM(aad.qtyShipped_each / 1000) END ELSE 0 END AS qtyChargeBilling,

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
        CASE WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1 ELSE IFNULL(btr.classfrom, 0) END AS classFrom,
        IFNULL(classTo, 0) AS classTo,
        bth.contractNo,
        btr.cost,
        btd.billingParty,
        bl.locationCategory
      FROM ACT_ALLOCATION_DETAILS aad
        -- All the joins from original query
        INNER JOIN DOC_ORDER_HEADER doh
          ON doh.organizationId = aad.organizationId
          AND doh.customerId = aad.customerId
          AND doh.orderNo = aad.orderNo
          AND doh.orderType NOT IN ('FREE', 'KT', 'TROF', 'TTG')
        LEFT JOIN DOC_ORDER_HEADER_UDF df
          ON doh.organizationId = df.organizationId
          AND doh.warehouseId = df.warehouseId
          AND doh.orderNo = df.orderNo
        INNER JOIN BAS_SKU bs
          ON bs.organizationId = aad.organizationId
          AND bs.SKU = aad.SKU
          AND bs.customerId = aad.customerId
          AND bs.skuDescr1 NOT LIKE '%PALLET%'
        INNER JOIN BAS_SKU_MULTIWAREHOUSE bsm
          ON bsm.organizationId = bs.organizationId
          AND bsm.SKU = bs.SKU
          AND bsm.customerId = bs.customerId
          AND bsm.warehouseId = aad.warehouseId
        LEFT JOIN INV_LOT_ATT ila
          ON ila.organizationId = aad.organizationId
          AND ila.SKU = aad.SKU
          AND ila.lotnum = aad.lotnum
          AND ila.customerId = aad.customerId
          AND (ila.lotAtt04 IS NULL
          OR ila.lotAtt04 != 'SET')
        LEFT JOIN BAS_PACKAGE_DETAILS bpdEA
          ON bpdEA.organizationId = bs.organizationId
          AND bpdEA.packId = bs.packId
          AND bpdEA.customerId = bs.customerId
          AND bpdEA.packUom = 'EA'
        LEFT JOIN BAS_PACKAGE_DETAILS bpdIP
          ON bpdIP.organizationId = bs.organizationId
          AND bpdIP.packId = bs.packId
          AND bpdIP.customerId = bs.customerId
          AND bpdIP.packUom = 'IP'
        LEFT JOIN BAS_PACKAGE_DETAILS bpdCS
          ON bpdCS.organizationId = bs.organizationId
          AND bpdCS.packId = bs.packId
          AND bpdCS.customerId = bs.customerId
          AND bpdCS.packUom = 'CS'
        LEFT JOIN BAS_PACKAGE_DETAILS bpdPL
          ON bpdPL.organizationId = bs.organizationId
          AND bpdPL.packId = bs.packId
          AND bpdPL.customerId = bs.customerId
          AND bpdPL.packUom = 'PL'
        LEFT JOIN BSM_CODE_ML t1
          ON t1.organizationId = 'OJV_CML'
          AND t1.codeType = 'SO_TYP'
          AND t1.codeId = doh.orderType
          AND t1.languageId = 'en'
        LEFT JOIN BSM_CODE BT
          ON BT.organizationId = 'OJV_CML'
          AND BT.codeType = 'BILLING_TRANSACTION_CATEGORY'
          AND BT.outerCode = ila.lotAtt07
        LEFT JOIN BAS_LOCATION bl
          ON bl.organizationId = aad.organizationId
          AND bl.warehouseId = aad.warehouseId
          AND bl.locationId = aad.location
        LEFT JOIN BAS_ZONE bz
          ON bz.organizationId = bl.organizationId
          AND bz.warehouseId = bl.warehouseId
          AND bz.zoneId = bl.zoneId
          AND bz.zoneGroup = bl.zoneGroup
        LEFT JOIN BIL_TARIFF_HEADER bth
          ON bth.organizationId = bsm.organizationId
          AND bth.tariffMasterId = bsm.tariffMasterId
        LEFT JOIN BIL_TARIFF_DETAILS btd
          ON btd.organizationId = bth.organizationId
          AND btd.tariffId = bth.tariffId
          AND btd.docType = doh.orderType
        LEFT JOIN BIL_TARIFF_RATE btr
          ON btr.organizationId = btd.organizationId
          AND btr.tariffId = btd.tariffId
          AND btr.tariffLineNo = btd.tariffLineNo
      WHERE aad.organizationId = IN_organizationId
      AND aad.warehouseId = IN_warehouseId
      AND aad.customerId = IN_CustomerId

      AND aad.orderNo = IN_trans_no
      AND aad.Status IN ('99', '80')
      AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND btd.chargeCategory = 'OB'
      AND (
      btd.billingTranCategory IS NULL
      OR btd.billingTranCategory = ''
      OR btd.billingTranCategory = BT.codeid
      )
      AND btr.rate > 0
      AND NOT EXISTS (SELECT
          1
        FROM Z_SKUNOTBILLING zsnb
        WHERE zsnb.organizationId = 'OJV_CML'
        AND zsnb.customerId = aad.customerId
        AND zsnb.sku = aad.sku)
      GROUP BY doh.organizationId,
               doh.orderNo,
               doh.soReference1,
               doh.soReference3,
               t1.codeid,
               doh.soStatus,
               doh.orderType,
               doh.warehouseId,
               aad.orderLineNo,
               aad.traceId,
               aad.pickToTraceId,
               aad.dropId,
               aad.customerId,
               aad.location,
               aad.pickToLocation,
               aad.shipmentTime,
               aad.allocationDetailsId,
               aad.SKU,
               aad.qty,
               aad.qty_each,
               aad.qtyShipped_each,
               aad.uom,
               aad.editTime,
               aad.lotNum,
               bsm.tariffMasterId,
               bs.skuDescr1,
               bs.grossWeight,
               bs.cube,
               t1.codeDescr,
               bz.zoneDescr,
               ila.lotAtt04,
               ila.lotAtt07,
               BT.codeid,
               df.closeTime,
               bs.netWeight,
               bpdEA.qty,
               bpdEA.uomDescr,
               bpdCS.qty,
               bpdIP.qty,
               bpdPL.qty,
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
          CONCAT(v_billing_summary_id, '*', LPAD(@row_num := @row_num + 1, 3, '0')) AS billingSummaryId,
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
      IF v_row_count = 0 THEN
        -- No data found, but this might be expected
        SET p_message = CONCAT('No billing data found for Order: ', IN_trans_no,
        ', Customer: ', IN_CustomerId);
        SET p_success_flag = 'W'; -- Warning flag
        SET p_record_count = 0;
        COMMIT; -- Commit even if no rows

        CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLHOSTD', IN_trans_no, 'error', NULL, NULL, p_success_flag,
        p_message, p_record_count, v_start_time, v_end_time);
      ELSE
        -- Calculate execution time
        SET v_end_time = NOW();
        SET v_execution_time = TIMESTAMPDIFF(MICROSECOND, v_start_time, v_end_time) / 1000000;

        -- Commit transaction
        COMMIT;

        -- Set success output parameters
        SET p_success_flag = 'Y';
        SET p_message = CONCAT('Outbound billing processed successfully. ',
        'Billing Summary ID: ', v_billing_summary_id,
        '. Records: ', v_row_count,
        '. Execution time: ', v_execution_time, ' seconds');
        SET p_record_count = v_row_count;

        CALL Z_RECORD_SPBILLINGLOG(IN_warehouseId, IN_CustomerId, 'CML_BILLHOSTD', IN_trans_no, 'no error', NULL, NULL, p_success_flag,
        p_message, p_record_count, v_start_time, v_end_time);


      END IF;



    END;

END
$$

DELIMITER ;