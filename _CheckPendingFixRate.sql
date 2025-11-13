  
        SELECT fch.organizationId,
            warehouseId,
            CONCAT('', '*', LPAD(auto_sequence(), 3, '0')),
            STR_TO_DATE(CONCAT(YEAR(NOW()), '-', MONTH(NOW()), '-', fch.billingDate), '%Y-%m-%d'),
            STR_TO_DATE(CONCAT(YEAR(NOW()), '-', MONTH(NOW()), '-', fch.billingDate), '%Y-%m-%d'),
            customerId,
            '' sku,
            '' lotNum,
            '' traceId,
           fch.tariffId,
            fch.chargeCategory,
            fch.chargeType,
            fch.descrC,
            fch.ratebase,
            1,
            1,
            '' uom,
            0 cubic,
            0 grossWeight,
            fch.fixAmount,
            fch.fixAmount,
            fch.fixAmount,
            0,
            1,
            0,
            NOW() confirmTime,
            '' confirmWho,
            'FX',
            '' docNo,
            '' createTransactionid,
            '' notes,
            NOW() ediSendTime,
            fch.customerId billTo,
            NOW() settleTime,
            '' settleWho,
            '' followUp,
            '' invoiceType,
            '' paidTo,
            '' costConfirmFlag,
            NOW() costConfirmTime,
            '' costConfirmWho,
            '' costSettleFlag,
            NOW() costSettleTime,
            '' costSettleWho,
            0 incomeTaxRate,
            0 costTaxRate,
            fch.incomeTaxRate incomeTax,
            0 cosTax,
            1,
            0 cosWithoutTax,
            '' costInvoiceType,
            '' noteText,
            fch.MaterialNo AS udf01,
            fch.itemChargeCategory AS udf02,
            '' udf03,
           fch.divisionCode udf04,
            '' udf05,
            0 currentVersion,
            '2020' oprSeqFlag,
            'CUSTOMBILL' addWho,
            NOW() ADDTIME,
            'CUSTOMBILL' editWho,
            NOW() editTime,
            '' locationCategory,
            '' manual,
            0 lineCount,
            '*' arNo,
            0 arLineNo,
            '*' apNo,
            0 apLineNo,
            'N' ediSendFlag,
            '' ediErrorCode,
            '' ediErrorMessage,
            NOW() ediSendTime2,
            'N' ediSendFlag2,
            '' ediErrorCode2,
            '' ediErrorMessage2,
            '' billingTranCategory,
            '' orderType,
            '' containerType,
            '' containerSize
          FROM (
          SELECT DISTINCT
    bcm.organizationId,
    bcm.warehouseId,
    bcm.customerId,
    bcm.tariffMasterId,
    DAY(STR_TO_DATE(CONCAT(YEAR(NOW()), '-', MONTH(NOW()), '-', bth.udf02), '%Y-%m-%d')) AS billingDate,
    IFNULL(bth.tariffId, '*') AS tariffId,
    btd.tariffLineNo,
    btd.chargeCategory,
    btd.chargeType,
    btd.descrC,
    btd.ratebase,
    btd.incomeTaxRate,
    IF(btd.UDF03 = '', 0, btd.UDF03) AS fixAmount,
    btd.udf03,
    btd.minAmount,
    btd.UDF01 AS MaterialNo,
    btd.udf02 AS itemChargeCategory,
    -- Billing date handling (from sql2 logic)
    CASE 
        WHEN bth.udf02 = ' ' 
        THEN DAY(bth.billingDate) 
        ELSE bth.udf02 
    END AS udf02_processed,    
    btd.UDF05,
    btd.UDF06 AS divisionCode,
    btd.UDF07,
    btd.UDF08,
    bth.contractNo,
    bc.CustomerType
FROM BAS_CUSTOMER_MULTIWAREHOUSE bcm  
    -- Customer master data
    INNER JOIN BAS_CUSTOMER bc
        ON bc.customerId = bcm.customerId
        AND bc.organizationId = bcm.organizationId
        AND bc.CustomerType = 'OW' 
        AND bc.activeFlag='Y'  
    -- Tariff header (LEFT JOIN to accommodate both query patterns)
    LEFT JOIN BIL_TARIFF_HEADER bth
        ON bth.organizationId = bcm.organizationId
        AND bth.tariffMasterId = bcm.tariffMasterId   
    -- Tariff details
    LEFT JOIN BIL_TARIFF_DETAILS btd
        ON btd.organizationId = bth.organizationId
        AND btd.tariffId = bth.tariffId
WHERE 
    bcm.organizationId = 'OJV_CML'   
    -- Date range filtering
    AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
    AND (
        bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        OR 
        bth.effectiveTo >= DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '%Y-%m-%d')
    )    
    -- Charge category
    AND btd.chargeCategory = 'FX' 
ORDER BY 
    bcm.organizationId, 
    bcm.customerId, 
    btd.chargeCategory, 
    btd.chargeType,
    btd.tariffLineNo
          ) fch
          WHERE  NOT EXISTS
    (SELECT 1 FROM BIL_SUMMARY bs WHERE bs.organizationId='OJV_CML' AND bs.warehouseId=fch.warehouseId AND bs.customerId=fch.customerId
    AND bs.chargeCategory=fch.chargeCategory AND DATE(bs.billingFromDate) > '2025-07-25')
    AND fch.fixAmount > 0;