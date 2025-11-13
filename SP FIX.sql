USE wms_cml;

DROP PROCEDURE IF EXISTS CML_BILLFIXCHG_BETA;

DELIMITER $$

CREATE 
	DEFINER = 'root'@'%'
PROCEDURE CML_BILLFIXCHG_BETA()
BEGIN
  DECLARE R_CURRENTDATE timestamp;
  DECLARE R_OPDATE varchar(10);
  DECLARE R_FMDATE varchar(10);
  DECLARE R_TODATE varchar(10);
  DECLARE R_BILLINGDAY integer;
  DECLARE R_BILLINGDATE varchar(10);
  DECLARE R_TARGETDATE varchar(10);
  DECLARE R_DAYOFMONTH int;
  DECLARE R_ORGANIZATIONID varchar(30);
  DECLARE R_WAREHOUSEID varchar(30);
  DECLARE R_CUSTOMERID varchar(30);
  DECLARE R_STOCKDATE varchar(10);
  DECLARE R_TARIFFID varchar(10);
  DECLARE R_TARIFFMASTERID varchar(20);
  DECLARE R_TARIFFLINENO int(11);
  DECLARE R_TARIFFCLASSNO int(11);
  DECLARE R_CHARGECATEGORY varchar(20);
  DECLARE R_CHARGETYPE varchar(20);
  DECLARE R_descrC varchar(50);
  DECLARE R_ratebase varchar(20);
  DECLARE R_docType varchar(20);
  DECLARE R_rateperunit decimal(24, 8);
  DECLARE R_rate decimal(24, 8);
  DECLARE R_minQty varchar(500);
  DECLARE R_minAmount decimal(24, 8);
  DECLARE R_fixAmount decimal(24, 8);
  DECLARE R_billQty decimal(24, 8);
  DECLARE R_Cost decimal(24, 8);
  DECLARE R_materialNo varchar(500);
  DECLARE R_itemChargeCategory varchar(500);
  DECLARE R_billMode varchar(500);
  DECLARE R_UDF06 varchar(500);
  DECLARE R_FINALAMOUNT decimal(24, 8);
  DECLARE R_billsummaryId varchar(30) DEFAULT '';
  DECLARE R_billsummaryNo varchar(30) DEFAULT '';
  DECLARE R_LOCATIONCAT char(2);
  DECLARE R_LOCATIONGROUP varchar(500);
  DECLARE R_INCOMETAX decimal(24, 8);
  DECLARE R_RESULTQTYCHARGE decimal(24, 8);  -- add for calculation
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
  DECLARE R_BILLTO varchar(30);
  DECLARE R_NROW integer;
  DECLARE R_PALLETCNT varchar(30);
  DECLARE R_UDF08 varchar(500);
  DECLARE R_UDF05 varchar(500);
  DECLARE R_UDF07 varchar(500);
  DECLARE R_Days int(11) DEFAULT NULL;
  DECLARE OUT_returnCode varchar(1000);
  ####################################################################
  DECLARE od_organizationId varchar(20);
  DECLARE od_warehouseId varchar(255);
  DECLARE od_customerId varchar(255);
  DECLARE od_tariffMasterId varchar(255);
  DECLARE od_tariffId varchar(50);
  DECLARE od_chargeType varchar(255);
  DECLARE od_fixAmount varchar(255);
  DECLARE od_incomeTaxRate varchar(20);
  DECLARE od_ratebase varchar(255);
  DECLARE od_udf02 varchar(255);
  DECLARE od_tariffLineNo varchar(255);
  DECLARE tariff_done int DEFAULT FALSE;
  DECLARE bil_done,
          attribute_done boolean DEFAULT FALSE;


        SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd
        SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
        SET R_billsummaryId = '';


        IF (R_billsummaryId = '') THEN
          SET @linenumber = 0;
          SET OUT_returnCode = '*_*';
          CALL SPCOM_GetIDSequence_NEW('OJV_CML', '*', 'en', 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);
        END IF;

      

        INSERT INTO BIL_SUMMARY (organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate, customerId
        , sku, lotNum, traceId, tariffId, chargeCategory, chargeType, descr, rateBase, chargePerUnits
        , qty, uom, cubic, weight, chargeRate, amount, billingAmount, cost, amountPayable, amountPaid
        , confirmTime, confirmWho, docType, docNo, createTransactionid, notes, ediSendTime
        , billTo, settleTime, settleWho, followUp, invoiceType, paidTo, costConfirmFlag
        , costConfirmTime, costConfirmWho, costSettleFlag, costSettleTime, costSettleWho, incomeTaxRate
        , costTaxRate, incomeTax, cosTax, incomeWithoutTax, cosWithoutTax, costInvoiceType, noteText
        , udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag, addWho, ADDTIME, editWho, editTime, locationCategory
        , manual, docLineNo, arNo, arLineNo, apNo, apLineNo, ediSendFlag, ediErrorCode, ediErrorMessage, ediSendTime2, ediSendFlag2
        , ediErrorCode2, ediErrorMessage2, billingTranCategory, orderType, containerType, containerSize)          
          SELECT
            warehouseId,
            customerId,
            CONCAT('', '*', LPAD(auto_sequence(), 3, '0')),
          --  R_BILLINGDATE,
          --  R_BILLINGDATE,
          '2017-01-01',
          '2017-01-01',
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
          ) fch;          
  SET OUT_returnCode = '000';
END
$$

DELIMITER ;