USE wms_cml;

CALL CML_BILLFIXCHG_NW(@p_success_flag, @p_message, @p_record_count);
SELECT
  @p_success_flag,
  @p_message,
  @p_record_count;

USE wms_cml;

SELECT * FROM BIL_SUMMARY bs WHERE bs.organizationId='OJV_CML' 
AND bs.warehouseId='CBT01' AND bs.customerId='PT.ABC' AND DATE(bs.addTime)=DATE(NOW());

DELETE  FROM BIL_SUMMARY bs WHERE bs.organizationId='OJV_CML' 
AND bs.warehouseId='CBT01' AND bs.customerId='PT.ABC' AND DATE(bs.addTime)=DATE(NOW());




SELECT * FROM BIL_SUMMARY bs WHERE bs.organizationId='OJV_CML' AND bs.warehouseId='CBT03' AND bs.customerId='LSH_JKT'
AND bs.addWho='CUSTOMBILL' AND date(bs.billingFromDate)> '2025-07-25' AND bs.chargeCategory='FX';


DELETE FROM BIL_SUMMARY WHERE organizationId ='OJV_CML' AND chargeCategory='FX'
AND billingSummaryId IN 
('*016',
'*028',
'*020',
'*021',
'*049',
'*001',
'*023',
'*026',
'*058',
'*017',
'*043',
'*003',
'*004',
'*005',
'*006',
'*007',
'*008',
'*009',
'*010',
'*011',
'*012',
'*013',
'*014',
'*015',
'*018',
'*019',
'*024',
'*025',
'*057',
'*034',
'*036',
'*038',
'*029',
'*042',
'*060',
'*062',
'*044',
'*045',
'*046',
'*047',
'*048',
'*050',
'*051',
'*052',
'*053',
'*054',
'*063',
'*064',
'*035',
'*037',
'*039',
'*040',
'*041',
'*022',
'*030',
'*027',
'*055',
'*056',
'*002',
'INVC250827000000001513*001',
'*031',
'*032',
'*033',
'*059',
'*061');




SELECT
            warehouseId,
            customerId,
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
          WHERE fch.customerId='APR';   