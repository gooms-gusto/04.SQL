USE wms_cml;

DROP PROCEDURE IF EXISTS CML_BILLSTORAGE_MONTH_CBM;

DELIMITER $$

CREATE 
	DEFINER = 'sa'@'%'
PROCEDURE CML_BILLSTORAGE_MONTH_CBM(IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_userId varchar(30),
IN IN_language varchar(30),
IN IN_customerId varchar(30)
)
BEGIN
  -- Declare variables to hold cursor data
  DECLARE done int DEFAULT 0;
  DECLARE tariff_done int DEFAULT 0;
  DECLARE v_stockDate date;
  DECLARE v_customerId varchar(20);
  DECLARE v_warehouseId varchar(20);
  DECLARE v_skuGroup1 varchar(255);
  DECLARE v_qtyCharge decimal(18, 4);
  DECLARE v_storagetype  varchar(100);


  -- Declare for Billing
  DECLARE R_CURRENTDATE timestamp;
  DECLARE R_OPDATE varchar(10);
  DECLARE R_FMDATE varchar(10);
  DECLARE R_TODATE varchar(10);
  DECLARE R_BILLINGDAY integer;
  DECLARE R_BILLINGDATE varchar(10);
  DECLARE R_Days int;
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
  DECLARE R_maxAmount decimal(24, 8);
  DECLARE R_billQty decimal(24, 8);
  DECLARE R_Cost decimal(24, 8);
  DECLARE R_materialNo varchar(500);
  DECLARE R_itemChargeCategory varchar(500);
  DECLARE R_billMode varchar(500);
  DECLARE R_UDF03 varchar(500);
  DECLARE R_UDF06 varchar(500);
  DECLARE R_UDF07 varchar(500);
  DECLARE R_UDF08 varchar(500);
  DECLARE R_qtyMinimumContract decimal(24, 8);
  DECLARE R_customInformation varchar(500);
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
  DECLARE OUT_returnCode varchar(1000);


  -- Declare the cursor
  DECLARE my_cursor CURSOR FOR

SELECT zbads.warehouseId,
zbads.customerId,  
MAX(zbads.qty_cbm) AS qty_charge,
zbads.UDF01 AS storage_type,DATE(DATE_ADD(NOW(), INTERVAL -1 DAY)) AS stockdate   -- stock date generate must H-1 26 end of month
FROM Z_BIL_AKUM_DAYS_STORAGE zbads
WHERE zbads.organizationId=IN_organizationId AND
zbads.chargeType='STRG' AND 
zbads.customerId=IN_CustomerId AND
DATE(zbads.StockDate) >= '2025-04-26' AND
DATE(zbads.StockDate) <= '2025-05-18'
GROUP BY zbads.warehouseId,zbads.customerId, zbads.UDF01;

  -- Declare a handler for NOT FOUND condition
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  -- Open the cursor
  OPEN my_cursor;

-- Loop through the results
read_loop:
  LOOP
    -- Fetch the values into variables
    FETCH my_cursor INTO  v_warehouseId, v_customerId, v_qtyCharge, v_storagetype,v_stockDate;

     SELECT   v_warehouseId, v_customerId, v_qtyCharge, v_storagetype,v_stockDate;

    IF done = 1 THEN
      LEAVE read_loop;
    END IF;

    IF NOT EXISTS (SELECT
          1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = IN_organizationId
        AND bs.warehouseId = v_warehouseId
        AND bs.customerId = v_customerId
        -- AND DATE(bs.billingFromDate) = DATE(DATE_ADD(CURDATE(), INTERVAL -1 DAY))
        AND DATE(bs.billingFromDate) = DATE(NOW())
        AND bs.descr = v_storagetype
        AND bs.chargeCategory = 'IV') THEN

                   

    BLOCK2:
      BEGIN
        DECLARE cur_Tariff CURSOR FOR
        SELECT DISTINCT
          bsm.organizationId,
          bsm.warehouseId,
          bsm.CUSTOMERID,
          DAY(bth.billingdate) billingDate,
          btr.tariffId,
          btr.tariffLineNo,
          btr.tariffClassNo,
          btd.chargeCategory,
          btd.chargeType,
          btd.descrC,
          btd.docType,
          btd.udf05, -- sementara pengganti ratebase
          btr.ratePerUnit,
          btr.rate,
          btd.minAmount,
          btd.maxAmount,
          btr.udf02,-- minimum billing
          btr.udf03,-- chamber name  / storage type
          IF(btd.UDF03 = '', 0, btd.UDF03) minQty,
          btd.UDF01 AS MaterialNo,
          btd.udf02 AS itemChargeCategory,
          btd.udf04 billMode,
          locationCategory,
          btd.UDF05,
          btd.UDF06,
          btd.UDF07,
          btd.UDF08,
          IFNULL(btd.incomeTaxRate, 0) IncomeTaxRate,
          CASE WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1 ELSE IFNULL(btr.classfrom, 0) END,
          IFNULL(classTo, 0),
          bth.contractNo,
          bth.tariffMasterId,
          btr.cost,
          btd.billingParty,
          -- btd.billingTranCategory,
          IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
        FROM BAS_SKU_MULTIWAREHOUSE bsm
          INNER JOIN BAS_CUSTOMER bc
            ON bc.customerId = bsm.customerId
            AND bc.organizationId = bsm.organizationId
            AND bc.CustomerType = 'OW'
          INNER JOIN BIL_TARIFF_HEADER bth
            ON bth.organizationId = bsm.organizationId
            AND bth.tariffMasterId = bsm.tariffMasterId
          INNER JOIN BIL_TARIFF_DETAILS btd
            ON btd.organizationId = bth.organizationId
            AND btd.tariffId = bth.tariffId
          INNER JOIN BIL_TARIFF_RATE btr
            ON btr.organizationId = btd.organizationId
            AND btr.tariffId = btd.tariffId
            AND btr.tariffLineNo = btd.tariffLineNo
        WHERE bsm.organizationId = 'OJV_CML'
        AND bsm.warehouseId = v_warehouseId
        AND bsm.customerId = v_customerId
        AND btr.udf03 = v_storagetype -- for filter chamber name /custom information
        -- AND bth.tariffMasterId = od_tariffMasterId
        AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND btd.chargeCategory = 'IV'
        AND btr.rate > 0
        #AND IFNULL(DAY(bth.billingdate),0)!=0 
        ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;


        SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd

        #
        OPEN cur_Tariff;
      getTariff:
        LOOP
          FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
          R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_qtyMinimumContract, R_customInformation, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
          R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;


          IF tariff_done = 1 THEN
            SET tariff_done = 0;
            LEAVE getTariff;
          END IF;



             SELECT  R_WAREHOUSEID, v_warehouseId, R_CUSTOMERID, v_customerId,R_customInformation,v_storagetype;

          IF (LTRIM(RTRIM(R_WAREHOUSEID)) = LTRIM(RTRIM(v_warehouseId)))
            AND (LTRIM(RTRIM(R_CUSTOMERID)) = LTRIM(RTRIM(v_customerId)))
            AND (LTRIM(RTRIM(R_customInformation)) = LTRIM(RTRIM(v_storagetype))) THEN



            --           SELECT  'check=>',R_ratebase,R_TARIFFID;
            SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
            SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
            SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
            SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
            SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
            SET R_billsummaryId = '';


           
              IF (v_qtyCharge > R_qtyMinimumContract) THEN
                SET R_RESULTQTYCHARGE = v_qtyCharge;
              ELSE
                SET R_RESULTQTYCHARGE = R_qtyMinimumContract;
                END IF;
            





            IF EXISTS (SELECT
                  1
                FROM BIL_SUMMARY
                WHERE billingFromDate = R_BILLINGDATE
                AND BillingToDate = R_BILLINGDATE
                AND ChargeCategory = R_CHARGECATEGORY
                AND chargeType = R_CHARGETYPE
                AND CustomerID = R_CUSTOMERID
                AND billTo = R_BILLTO
                AND rateBase = R_rateBase
                AND arNo IN ('*')) THEN
              INSERT INTO BIL_SUMMARY_LOG
                SELECT
                  *
                FROM BIL_SUMMARY
                WHERE billingFromDate = R_BILLINGDATE
                AND BillingToDate = R_BILLINGDATE
                AND ChargeCategory = R_CHARGECATEGORY
                AND chargeType = R_CHARGETYPE
                AND CustomerID = R_CUSTOMERID
                AND billTo = R_BILLTO
                AND rateBase = R_rateBase
                AND arNo IN ('*');
              DELETE
                FROM BIL_SUMMARY
              WHERE billingFromDate = R_BILLINGDATE
                AND BillingToDate = R_BILLINGDATE
                AND ChargeCategory = R_CHARGECATEGORY
                AND chargeType = R_CHARGETYPE
                AND CustomerID = R_CUSTOMERID
                AND billTo = R_BILLTO
                AND rateBase = R_rateBase
                AND arNo IN ('*');
            END IF; -- EXIST BILLING SUMMARY
            #
            IF (R_billsummaryId = '') THEN
              SET @linenumber = 0;
              SET OUT_returnCode = '';
              CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);

              IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
                SET OUT_returnCode = '999#计费流水获取异常';
                LEAVE getTariff;
              END IF;
            END IF;
              #
            SELECT
              R_billsummaryId;


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
                IN_organizationId,
                v_warehouseId,
                CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')),
                DATE_FORMAT(v_stockDate, '%Y-%m-%d'),
                DATE_FORMAT(v_stockDate, '%Y-%m-%d'),
                v_customerId,
                '',
                '',
                '',
                R_TARIFFID,
                R_CHARGECATEGORY,
                R_chargetype,
                -- R_descrC,
                CONCAT(v_storagetype),
                R_rateBase,
                R_rateperunit,
                R_RESULTQTYCHARGE,
                '',
                0,
                0,
                R_rate,
                R_RESULTQTYCHARGE * R_rate / R_rateperunit,
                (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
                0,
                R_cost * R_RESULTQTYCHARGE,
                0,
                NOW() confirmTime,
                '' confirmWho,
                '',
                '',
                '' createTransactionid,
                '' notes,
                NOW() ediSendTime,
                v_customerId AS billTo,
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
                R_INCOMETAX incomeTax,
                0 cosTax,
                R_RESULTQTYCHARGE * R_rate / R_rateperunit incomeWithoutTax,
                0 cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                R_materialNo AS udf01,
                R_itemChargeCategory AS udf02,
                0 udf03,
                R_UDF06 udf04,
                '' udf05,
                0 currentVersion,
                '2020' oprSeqFlag,
                IN_USERID addWho,
                NOW() ADDTIME,
                IN_USERID editWho,
                NOW() editTime,
                R_LOCATIONCAT locationCategory,
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
                '' containerSize;

          END IF; -- END IF docType

        END LOOP getTariff;
        CLOSE cur_Tariff;



      END;
    ELSE
      ITERATE read_loop;
    END IF;



  END LOOP;

  -- Close the cursor
  CLOSE my_cursor;

END
$$

DELIMITER ;