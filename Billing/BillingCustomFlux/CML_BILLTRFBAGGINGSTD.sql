

DROP PROCEDURE IF EXISTS CML_BILLTRFBAGGINGSTD;

DELIMITER $$

CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLTRFBAGGINGSTD (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_trans_no varchar(30),
IN IN_tariffMaster varchar(30))
ENDPROC:
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
    DECLARE R_maxAmount decimal(24, 8);
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
    DECLARE R_UDF08 varchar(500);
    DECLARE R_UDF07 varchar(500);
    DECLARE R_Days int(11) DEFAULT NULL;
    DECLARE OD_CURSORDONE boolean DEFAULT FALSE;
    DECLARE odh_organizationId varchar(20);
    DECLARE odh_warehouseId varchar(20);
    DECLARE odh_tdocNo varchar(20);
    DECLARE vodh_tdocNo varchar(20);
    DECLARE od_tdocType varchar(20);
    DECLARE od_status varchar(2);
    DECLARE od_customerId varchar(30);
    DECLARE od_organizationId varchar(20);
    DECLARE od_warehouseId varchar(20);
    DECLARE od_tdocNo varchar(20);
    DECLARE od_tdocLineNo int(11);
    DECLARE od_tdocLineStatus varchar(2);
    DECLARE od_fmCustomerId varchar(30);
    DECLARE od_fmSku varchar(50);
    DECLARE od_fmQty decimal(18, 8);
    DECLARE od_toCustomerId varchar(30);
    DECLARE od_toSku varchar(50);
    DECLARE od_toQty decimal(18, 8);
    DECLARE od_closedtime timestamp;
    DECLARE OUT_Return_Code varchar(1000);
    DECLARE tariff_done int DEFAULT 0;
    DECLARE _GETLINEORDER CURSOR FOR
    SELECT
     dth.organizationId,
dth.warehouseId,
dth.customerId,
dth.tdocNo,
dth.tdocType,
dtd.tdocLineNo,
dtd.toSku,
dtd.fmSku,
dtd.fmQty,
dtd.toQty,
dth.editTime
    FROM DOC_TRANSFER_HEADER dth
      INNER JOIN DOC_TRANSFER_DETAILS dtd
        ON dth.organizationId = dtd.organizationId
        AND dth.warehouseId = dtd.warehouseId
        AND dth.tdocNo = dtd.tdocNo
    WHERE dth.organizationId = IN_organizationId
    AND dtd.warehouseId = IN_warehouseId
    AND dth.tdocNo = IN_trans_no
    AND dth.customerId = IN_CustomerId
AND dth.status='10'
AND dtd.tdocLineStatus='10'
AND dth.tdocType='BG';
    -- AND dtd.tdocLineNo = IN_lineNO;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET OD_CURSORDONE = TRUE;
    OPEN _GETLINEORDER;
  GETLINEORDERLOOP:
    LOOP FETCH FROM _GETLINEORDER INTO
      od_organizationId,
      od_warehouseId,
      od_customerId,
      od_tdocNo,
      od_tdocType,
      od_tdocLineNo,
      od_toSku,
      od_fmSku,
      od_fmQty,
      od_toQty,
      od_closedtime;


      IF OD_CURSORDONE THEN
        SET OD_CURSORDONE = FALSE;
        LEAVE GETLINEORDERLOOP;
      END IF;

      BEGIN

        IF (od_tdocType <> 'BG') THEN
          SET OUT_Return_Code = '201';
          LEAVE ENDPROC;
        END IF;


        SELECT
          btm.tariffMasterId INTO IN_tariffMaster
        FROM BIL_TARIFF_MASTER btm
        WHERE btm.organizationId = IN_organizationId
        AND btm.customerId = IN_CustomerId;

      --         CALL SPCOM_GetIDSequence_NEW(IN_organizationId,
      --         IN_warehouseId,'en',
      --         'TDOCNO',
      --         vodh_tdocNo,
      --         OUT_Return_Code);

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
            btd.ratebase,
            btr.ratePerUnit,
            btr.rate,
            btd.minAmount,
            btd.maxAmount,
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
          AND bsm.warehouseId = IN_warehouseId
          AND bsm.customerId = IN_CustomerId
          AND bth.tariffMasterId = IN_tariffMaster
          AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
          AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
          AND btd.chargeCategory = 'TD'
          AND btd.chargeType='TDB'
          AND btd.vasType = 'BG'
          AND btd.udf01 IN ('1700000008')
          AND btr.rate > 0
          AND btd.tariffLineNo > 100
          #AND IFNULL(DAY(bth.billingdate),0)!=0 
          ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;

          SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd
          #
          OPEN cur_Tariff;
        getTariff:
          LOOP
            FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
            R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
            R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;
            IF tariff_done THEN
              SET tariff_done = FALSE;
              LEAVE getTariff;
            END IF;
            SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
            SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
            SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
            SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
            SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
            SET R_billsummaryId = '';


            SET R_RESULTQTYCHARGE = od_toQty;

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
              SET OUT_Return_Code = '*_*';
              CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_Return_Code);
              IF SUBSTRING(OUT_Return_Code, 1, 3) <> '000' THEN
                SET OUT_Return_Code = '999#计费流水获取异常';
                LEAVE getTariff;
              END IF;
            END IF;
            #


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
                od_organizationId,
                od_warehouseId,
                CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')),
                DATE_FORMAT(od_closedtime, '%Y-%m-%d'),
                DATE_FORMAT(od_closedtime, '%Y-%m-%d'),
                od_customerId,
                od_toSku,
                '',
                '',
                R_TARIFFID,
                R_CHARGECATEGORY,
                R_chargetype,
                R_descrC,
                R_rateBase,
                R_rateperunit,
                od_toQty,
                '',
                '0',
                '0',
                R_rate,
                R_RESULTQTYCHARGE * R_rate / R_rateperunit,
                (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
                0,
                R_cost * R_RESULTQTYCHARGE,
                0,
                NULL confirmTime,
                '' confirmWho,
                'VAS' dockType,
                od_tdocNo,
                '' createTransactionid,
                R_CHARGETYPE notes,
                NULL ediSendTime,
                R_BILLTO billTo,
                NULL settleTime,
                '' settleWho,
                '' followUp,
                '' invoiceType,
                '' paidTo,
                '' costConfirmFlag,
                NULL costConfirmTime,
                '' costConfirmWho,
                '' costSettleFlag,
                NULL costSettleTime,
                '' costSettleWho,
                NULL incomeTaxRate,
                0 costTaxRate,
                NULL incomeTax,
                0 cosTax,
                NULL incomeWithoutTax,
                NULL cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                R_materialNo AS udf01,
                R_itemChargeCategory AS udf02,
                R_UDF08 udf03,
                R_UDF06 udf04,
                NULL udf05,
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
                NULL ediSendTime2,
                'N' ediSendFlag2,
                '' ediErrorCode2,
                '' ediErrorMessage2,
                '' billingTranCategory,
                '' orderType,
                '' containerType,
                '' containerSize;



          END LOOP getTariff;
          CLOSE cur_Tariff;






        END;
      END;
    END LOOP GETLINEORDERLOOP;
    CLOSE _GETLINEORDER;

  END
$$

DELIMITER ;