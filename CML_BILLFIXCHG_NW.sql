USE wms_cml;

DROP PROCEDURE IF EXISTS CML_BILLFIXCHG_NW;

DELIMITER $$

CREATE DEFINER = 'root'@'%'
PROCEDURE CML_BILLFIXCHG_NW(
    OUT p_success_flag CHAR(1),
    OUT p_message VARCHAR(1000),
    OUT p_record_count INT
)
BEGIN
    -- =============================================
    -- Stored Procedure: CML_BILLFIXCHG_BETA
    -- Purpose: Process fixed charge billing for customers
    -- Author: [Akbar@IT-LINC]
    -- Date: [27.08.25]
    -- =============================================
    
    -- Declare variables
    DECLARE v_current_date TIMESTAMP;
    DECLARE v_billing_summary_id VARCHAR(30) DEFAULT '';
    DECLARE v_return_code VARCHAR(1000);
    DECLARE v_row_count INT DEFAULT 0;
    DECLARE v_error_code VARCHAR(5);
    DECLARE v_error_msg VARCHAR(1000);
    
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
        CALL SPCOM_GetIDSequence_NEW(
            'OJV_CML', 
            '*', 
            'en', 
            'BILLINGSUMMARYIDCUST', 
            v_billing_summary_id, 
            v_return_code
        );
        
        -- Check if ID generation was successful
        IF v_return_code NOT LIKE '000%' THEN
            SET p_message = CONCAT('Failed to generate billing summary ID. Return code: ', v_return_code);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
        END IF;
        
        -- Insert fixed charge billing data
        INSERT INTO BIL_SUMMARY (
            organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate,
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
            containerType, containerSize
        )
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
        FROM (
            SELECT DISTINCT
                bcm.organizationId,
                bcm.warehouseId,
                bcm.customerId,
                bcm.tariffMasterId,
                -- Extract billing date
                DAY(STR_TO_DATE(
                    CONCAT(YEAR(NOW()), '-', MONTH(NOW()), '-', bth.udf02), 
                    '%Y-%m-%d'
                )) AS billingDate,
                IFNULL(bth.tariffId, '*') AS tariffId,
                btd.tariffLineNo,
                btd.chargeCategory,
                btd.chargeType,
                btd.descrC,
                btd.ratebase,
                btd.incomeTaxRate,
                -- Calculate tax
                CASE 
                    WHEN btd.incomeTaxRate > 0 THEN 
                        (IFNULL(btd.UDF03, 0) * btd.incomeTaxRate / 100)
                    ELSE 0 
                END AS incomeTax,
                -- Fix amount
                IFNULL(btd.UDF03, 0) AS fixAmount,
                btd.minAmount,
                btd.UDF01 AS MaterialNo,
                btd.udf02 AS itemChargeCategory,
                btd.UDF06 AS divisionCode,
                bth.contractNo
            FROM BAS_CUSTOMER_MULTIWAREHOUSE bcm
            -- Join with customer master
            INNER JOIN BAS_CUSTOMER bc
                ON bc.customerId = bcm.customerId
                AND bc.organizationId = bcm.organizationId
                AND bc.CustomerType = 'OW'
                AND bc.activeFlag = 'Y'
            -- Join with tariff header
            LEFT JOIN BIL_TARIFF_HEADER bth
                ON bth.organizationId = bcm.organizationId
                AND bth.tariffMasterId = bcm.tariffMasterId
            -- Join with tariff details
            LEFT JOIN BIL_TARIFF_DETAILS btd
                ON btd.organizationId = bth.organizationId
                AND btd.tariffId = bth.tariffId
            WHERE 
                bcm.organizationId = 'OJV_CML'
                -- Date range validation
                AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
                AND (
                    bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
                    OR bth.effectiveTo >= DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '%Y-%m-%d')
                )
                -- Fixed charge category
                AND btd.chargeCategory = 'FX'
                -- Only process charges with positive amounts
                AND IFNULL(btd.UDF03, 0) > 0
        ) fch
        CROSS JOIN (SELECT @row_num := 0) r;
        
        -- Get the number of inserted rows
        SET v_row_count = ROW_COUNT();
        
        -- Check if any rows were inserted
        IF v_row_count = 0 THEN
            SET p_message = 'No fixed charges found for processing.';
            SET p_success_flag = 'W'; -- Warning flag
            SET p_record_count = 0;
            COMMIT; -- Commit even if no rows, as this is not an error
        ELSE
            -- Commit transaction if successful
            COMMIT;
            
            -- Set success output parameters
            SET p_success_flag = 'Y';
            SET p_message = CONCAT('Fixed charge billing processed period 20/',MONTH(NOW()),'/',YEAR(NOW()),' successfully. Prefix Billing Summary ID: ', 
                                 v_billing_summary_id,'*XXX', 
                                 '. Records inserted: ', 
                                 v_row_count);
            SET p_record_count = v_row_count;

            SELECT zcml_alert_message(p_message,'-4075819187');
        END IF;
        
    END;
    
END$$

DELIMITER ;