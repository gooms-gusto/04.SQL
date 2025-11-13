USE WMS_FTEST;

DROP PROCEDURE IF EXISTS CML_BILLVASBAGGINGSTD;

DELIMITER $$

CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLVASBAGGINGSTD (IN IN_organizationId varchar(30),
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
    DECLARE od_firstQty decimal(18, 8);
    DECLARE od_lastQty decimal(18, 8);


    DECLARE odh_organizationId varchar(20);
    DECLARE odh_warehouseId varchar(20);
    DECLARE odh_tdocNo varchar(20);
     DECLARE vodh_tdocNo varchar(20);
    DECLARE odh_tdocType varchar(20);
    DECLARE odh_status varchar(2);
    DECLARE odh_customerId varchar(30);
    DECLARE odh_tdocCreationTime timestamp;
    DECLARE odh_transferTime timestamp;
    DECLARE odh_reasonCode varchar(15);
    DECLARE odh_reason varchar(100);
    DECLARE odh_userDefineA varchar(20);
    DECLARE odh_userDefineB varchar(20);
    DECLARE odh_source varchar(10);
    DECLARE odh_sourceNo varchar(20);
    DECLARE odh_approveTime timestamp;
    DECLARE odh_approveBy varchar(35);
    DECLARE odh_noteText mediumtext;
    DECLARE odh_udf01 varchar(500);
    DECLARE odh_udf02 varchar(500);
    DECLARE odh_udf03 varchar(500);
    DECLARE odh_udf04 varchar(500);
    DECLARE odh_udf05 varchar(500);
    DECLARE odh_currentVersion int(11);
    DECLARE odh_oprSeqFlag varchar(65);
    DECLARE odh_addWho varchar(40);
    DECLARE odh_addTime timestamp;
    DECLARE odh_editWho varchar(40);
    DECLARE odh_editTime timestamp;
    DECLARE odh_hedi01 varchar(200);
    DECLARE odh_hedi02 varchar(200);
    DECLARE odh_hedi03 varchar(200);
    DECLARE odh_hedi04 varchar(200);
    DECLARE odh_hedi05 varchar(200);
    DECLARE odh_hedi06 varchar(200);
    DECLARE odh_hedi07 varchar(200);
    DECLARE odh_hedi08 varchar(200);
    DECLARE odh_hedi09 decimal(18, 8);
    DECLARE odh_hedi10 decimal(18, 8);
    DECLARE odh_ediSendFlag char(1);
    DECLARE odh_ediSendTime timestamp;
    DECLARE odh_ediErrorCode varchar(50);
    DECLARE odh_ediErrorMessage text;
    DECLARE odh_ediSendTime2 timestamp;
    DECLARE odh_ediSendFlag2 char(1);
    DECLARE odh_ediErrorCode2 varchar(50);
    DECLARE odh_ediErrorMessage2 text;
    DECLARE odh_ediSendTime3 timestamp;
    DECLARE odh_ediSendFlag3 char(1);
    DECLARE odh_ediErrorCode3 varchar(50);
    DECLARE odh_ediErrorMessage3 text;
    DECLARE odh_listPrintFlag char(1);


    DECLARE odd_organizationId varchar(20);
    DECLARE odd_warehouseId varchar(20);
    DECLARE odd_tdocNo varchar(20);
    DECLARE odd_tdocLineNo int(11);
    DECLARE odd_tdocLineStatus varchar(2);
    DECLARE odd_fmCustomerId varchar(30);
    DECLARE odd_fmSku varchar(50);
    DECLARE odd_fmLotNum varchar(10);
    DECLARE odd_fmLocation varchar(60);
    DECLARE odd_fmId varchar(30);
    DECLARE odd_fmQty decimal(18, 8);
    DECLARE odd_fmQtyAllocated decimal(18, 8);
    DECLARE odd_fmQtyOnHold decimal(18, 8);
    DECLARE odd_fmQtyAvailable decimal(18, 8);
    DECLARE odd_fmGrossWeight decimal(18, 8);
    DECLARE odd_fmNetWeight decimal(18, 8);
    DECLARE odd_fmCubic decimal(18, 8);
    DECLARE odd_fmPrice decimal(24, 8);
    DECLARE odd_toCustomerId varchar(30);
    DECLARE odd_toSku varchar(50);
    DECLARE odd_toLocation varchar(60);
    DECLARE odd_toId varchar(30);
    DECLARE odd_toQty decimal(18, 8);
    DECLARE odd_toGrossWeight decimal(18, 8);
    DECLARE odd_toNetWeight decimal(18, 8);
    DECLARE odd_toCubic decimal(18, 8);
    DECLARE odd_toPrice decimal(24, 8);
    DECLARE odd_toLotAtt01 varchar(20);
    DECLARE odd_toLotAtt02 varchar(20);
    DECLARE odd_toLotAtt03 varchar(20);
    DECLARE odd_toLotAtt04 varchar(100);
    DECLARE odd_toLotAtt05 varchar(100);
    DECLARE odd_toLotAtt06 varchar(100);
    DECLARE odd_toLotAtt07 varchar(100);
    DECLARE odd_toLotAtt08 varchar(100);
    DECLARE odd_toLotAtt09 varchar(100);
    DECLARE odd_toLotAtt10 varchar(100);
    DECLARE odd_toLotAtt11 varchar(100);
    DECLARE odd_toLotAtt12 varchar(100);
    DECLARE odd_gainLossQty decimal(18, 8);
    DECLARE odd_approveTime timestamp;
    DECLARE odd_approveBy varchar(35);
    DECLARE odd_noteText mediumtext;
    DECLARE odd_udf01 varchar(500);
    DECLARE odd_udf02 varchar(500);
    DECLARE odd_udf03 varchar(500);
    DECLARE odd_udf04 varchar(500);
    DECLARE odd_udf05 varchar(500);
    DECLARE odd_currentVersion int(11);
    DECLARE odd_oprSeqFlag varchar(65);
    DECLARE odd_addWho varchar(40);
    DECLARE odd_addTime timestamp;
    DECLARE odd_editWho varchar(40);
    DECLARE odd_editTime timestamp;
    DECLARE odd_toLotAtt13 varchar(100);
    DECLARE odd_toLotAtt14 varchar(100);
    DECLARE odd_toLotAtt15 varchar(100);
    DECLARE odd_toLotAtt16 varchar(100);
    DECLARE odd_toLotAtt17 varchar(100);
    DECLARE odd_toLotAtt18 varchar(100);
    DECLARE odd_toLotAtt19 varchar(100);
    DECLARE odd_toLotAtt20 varchar(100);
    DECLARE odd_toLotAtt21 varchar(100);
    DECLARE odd_toLotAtt22 varchar(100);
    DECLARE odd_toLotAtt23 varchar(100);
    DECLARE odd_toLotAtt24 varchar(100);
    DECLARE odd_sourceId varchar(20);
    DECLARE odd_reasonCode varchar(15);
    DECLARE odd_reason varchar(100);
    DECLARE odd_toMuId varchar(30);
DECLARE OUT_Return_Code varchar(1000);
DECLARE tariff_done int DEFAULT 0;
    DECLARE _GETLINEORDER CURSOR FOR
    SELECT
      dth.organizationId,
      dth.warehouseId,
      dth.tdocNo,
      dth.tdocType,
      dth.STATUS,
      dth.customerId,
      dth.tdocCreationTime,
      dth.transferTime,
      dth.reasonCode,
      dth.reason,
      dth.userDefineA,
      dth.userDefineB,
      dth.source,
      dth.sourceNo,
      dth.approveTime,
      dth.approveBy,
      dth.noteText,
      dth.udf01,
      dth.udf02,
      dth.udf03,
      dth.udf04,
      dth.udf05,
      dth.currentVersion,
      dth.oprSeqFlag,
      dth.addWho,
      dth.addTime,
      dth.editWho,
      dth.editTime,
      dth.HEDI01,
      dth.HEDI02,
      dth.HEDI03,
      dth.HEDI04,
      dth.HEDI05,
      dth.hedi06,
      dth.hedi07,
      dth.hedi08,
      dth.hedi09,
      dth.hedi10,
      dth.ediSendFlag,
      dth.EDISendTime,
      dth.ediErrorCode,
      dth.ediErrorMessage,
      dth.ediSendTime2,
      dth.ediSendFlag2,
      dth.ediErrorCode2,
      dth.ediErrorMessage2,
      dth.ediSendTime3,
      dth.ediSendFlag3,
      dth.ediErrorCode3,
      dth.ediErrorMessage3,
      dth.listPrintFlag,
      dtd.organizationId,
      dtd.warehouseId,
      dtd.tdocNo,
      dtd.tdocLineNo,
      dtd.tdocLineStatus,
      dtd.FMCustomerID,
      dtd.fmSku,
      dtd.fmLotNum,
      dtd.fmLocation,
      dtd.fmId,
      dtd.fmQty,
      dtd.fmQtyAllocated,
      dtd.fmQtyOnHold,
      dtd.fmQtyAvailable,
      dtd.fmGrossWeight,
      dtd.fmNetWeight,
      dtd.fmCubic,
      dtd.fmPrice,
      dtd.toCustomerId,
      dtd.toSku,
      dtd.toLocation,
      dtd.toId,
      dtd.TOQTY,
      dtd.toGrossWeight,
      dtd.toNetWeight,
      dtd.toCubic,
      dtd.toPrice,
      dtd.toLotatt01,
      dtd.toLotatt02,
      dtd.toLotatt03,
      dtd.toLotatt04,
      dtd.toLotatt05,
      dtd.toLotatt06,
      dtd.toLotatt07,
      dtd.toLotatt08,
      dtd.toLotatt09,
      dtd.toLotatt10,
      dtd.toLotatt11,
      dtd.toLotatt12,
      dtd.gainLossQty,
      dtd.approveTime,
      dtd.approveBy,
      dtd.noteText,
      dtd.udf01,
      dtd.udf02,
      dtd.udf03,
      dtd.udf04,
      dtd.udf05,
      dtd.currentVersion,
      dtd.oprSeqFlag,
      dtd.addWho,
      dtd.addTime,
      dtd.editWho,
      dtd.editTime,
      dtd.toLotatt13,
      dtd.toLotatt14,
      dtd.toLotatt15,
      dtd.toLotatt16,
      dtd.toLotatt17,
      dtd.toLotatt18,
      dtd.toLotatt19,
      dtd.toLotatt20,
      dtd.toLotatt21,
      dtd.toLotatt22,
      dtd.toLotatt23,
      dtd.toLotatt24,
      dtd.sourceId,
      dtd.reasonCode,
      dtd.reason,
      dtd.toMuid
    FROM DOC_TRANSFER_HEADER dth
      INNER JOIN DOC_TRANSFER_DETAILS dtd
        ON dth.organizationId = dtd.organizationId
        AND dth.warehouseId = dtd.warehouseId
        AND dth.tdocNo = dtd.tdocNo
    WHERE dth.organizationId = IN_organizationId
    AND dtd.warehouseId = IN_warehouseId
    AND dth.tdocNo = IN_trans_no
    AND dth.customerId=IN_CustomerId
    AND dth.status=10;
    -- AND dtd.tdocLineNo = IN_lineNO;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET OD_CURSORDONE = TRUE;
    OPEN _GETLINEORDER;
    GETLINEORDERLOOP:
    LOOP FETCH FROM _GETLINEORDER INTO
      odh_organizationId,
      odh_warehouseId,
      odh_tdocNo,
      odh_tdocType,
      odh_status,
      odh_customerId,
      odh_tdocCreationTime,
      odh_transferTime,
      odh_reasonCode,
      odh_reason,
      odh_userDefineA,
      odh_userDefineB,
      odh_source,
      odh_sourceNo,
      odh_approveTime,
      odh_approveBy,
      odh_noteText,
      odh_udf01,
      odh_udf02,
      odh_udf03,
      odh_udf04,
      odh_udf05,
      odh_currentVersion,
      odh_oprSeqFlag,
      odh_addWho,
      odh_addTime,
      odh_editWho,
      odh_editTime,
      odh_hedi01,
      odh_hedi02,
      odh_hedi03,
      odh_hedi04,
      odh_hedi05,
      odh_hedi06,
      odh_hedi07,
      odh_hedi08,
      odh_hedi09,
      odh_hedi10,
      odh_ediSendFlag,
      odh_ediSendTime,
      odh_ediErrorCode,
      odh_ediErrorMessage,
      odh_ediSendTime2,
      odh_ediSendFlag2,
      odh_ediErrorCode2,
      odh_ediErrorMessage2,
      odh_ediSendTime3,
      odh_ediSendFlag3,
      odh_ediErrorCode3,
      odh_ediErrorMessage3,
      odh_listPrintFlag,
      odd_organizationId,
      odd_warehouseId,
      odd_tdocNo,
      odd_tdocLineNo,
      odd_tdocLineStatus,
      odd_fmCustomerId,
      odd_fmSku,
      odd_fmLotNum,
      odd_fmLocation,
      odd_fmId,
      odd_fmQty,
      odd_fmQtyAllocated,
      odd_fmQtyOnHold,
      odd_fmQtyAvailable,
      odd_fmGrossWeight,
      odd_fmNetWeight,
      odd_fmCubic,
      odd_fmPrice,
      odd_toCustomerId,
      odd_toSku,
      odd_toLocation,
      odd_toId,
      odd_toQty,
      odd_toGrossWeight,
      odd_toNetWeight,
      odd_toCubic,
      odd_toPrice,
      odd_toLotAtt01,
      odd_toLotAtt02,
      odd_toLotAtt03,
      odd_toLotAtt04,
      odd_toLotAtt05,
      odd_toLotAtt06,
      odd_toLotAtt07,
      odd_toLotAtt08,
      odd_toLotAtt09,
      odd_toLotAtt10,
      odd_toLotAtt11,
      odd_toLotAtt12,
      odd_gainLossQty,
      odd_approveTime,
      odd_approveBy,
      odd_noteText,
      odd_udf01,
      odd_udf02,
      odd_udf03,
      odd_udf04,
      odd_udf05,
      odd_currentVersion,
      odd_oprSeqFlag,
      odd_addWho,
      odd_addTime,
      odd_editWho,
      odd_editTime,
      odd_toLotAtt13,
      odd_toLotAtt14,
      odd_toLotAtt15,
      odd_toLotAtt16,
      odd_toLotAtt17,
      odd_toLotAtt18,
      odd_toLotAtt19,
      odd_toLotAtt20,
      odd_toLotAtt21,
      odd_toLotAtt22,
      odd_toLotAtt23,
      odd_toLotAtt24,
      odd_sourceId,
      odd_reasonCode,
      odd_reason,
      odd_toMuId;


      IF OD_CURSORDONE THEN
        SET OD_CURSORDONE = FALSE;
        LEAVE GETLINEORDERLOOP;
      END IF;

      BEGIN

        IF (odh_tdocType <> 'BG') THEN
          SET OUT_Return_Code = '201';
          LEAVE ENDPROC;
        END IF;


SELECT btm.tariffMasterId INTO IN_tariffMaster
FROM BIL_TARIFF_MASTER btm WHERE btm.organizationId=IN_organizationId AND btm.customerId=IN_CustomerId;
     
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
      AND btd.chargeCategory = 'VA'
      AND btd.vasType='TRB'
      AND btd.udf01 IN ('1700000145', '1700000008')
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


          SET R_RESULTQTYCHARGE = od_qtyCharge;

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
              DATE_FORMAT(od_closetime, '%Y-%m-%d'),
              DATE_FORMAT(od_closetime, '%Y-%m-%d'),
              od_customerId,
              od_sku,
              '',
              '',
              R_TARIFFID,
              R_CHARGECATEGORY,
              R_chargetype,
              R_descrC,
              R_rateBase,
              R_rateperunit,
              od_qtyCharge,
              od_uom,
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
              od_vasNo,
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