USE WMS_FTEST;

DROP PROCEDURE IF EXISTS CML_BILLSOVASSTD;

DELIMITER $$

CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLSOVASSTD (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_trans_no varchar(30),
IN IN_tariffMaster varchar(30))
BEGIN


  ####################################################################
  ##变量定义
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
  DECLARE c_WAREHOUSEID varchar(30);
  DECLARE c_CUSTOMERID varchar(30);
  DECLARE c_chargecategory varchar(30);
  DECLARE c_charegetype varchar(30);
  DECLARE c_locationId varchar(60);
  DECLARE c_sku varchar(255);
  DECLARE c_qtyonHand int(11) DEFAULT NULL;
  DECLARE c_packkey varchar(255) binary DEFAULT NULL;
  DECLARE c_UOM varchar(255) binary DEFAULT NULL;
  DECLARE c_qtyallocated int(11) DEFAULT NULL;
  DECLARE c_qtyonHold int(11) DEFAULT NULL;
  DECLARE c_qtyavailable int(11) DEFAULT NULL;
  DECLARE c_qtyPicked int(11) DEFAULT NULL;
  DECLARE c_SKUDesc varchar(550) binary DEFAULT NULL;
  DECLARE c_stockDate date DEFAULT NULL;
  DECLARE c_Cub decimal(24, 8) DEFAULT NULL;
  DECLARE c_totalCub decimal(24, 8) DEFAULT NULL;
  DECLARE c_grossWeight decimal(18, 8) DEFAULT NULL;
  DECLARE c_netWeight decimal(18, 8) DEFAULT NULL;
  DECLARE c_freightClass varchar(255) binary DEFAULT NULL;
  DECLARE c_locationCategory varchar(10) DEFAULT '';
  DECLARE R_UDF08 varchar(500);
  DECLARE R_UDF07 varchar(500);
  DECLARE R_Days int(11) DEFAULT NULL;
  ####################################################################
  DECLARE od_organizationId varchar(255);
  DECLARE od_soReference1 varchar(255);
  DECLARE od_skuDescr1 varchar(255);
  DECLARE od_warehouseId varchar(255);
  DECLARE od_customerId varchar(255);
  DECLARE od_soNo varchar(255);
  DECLARE od_soLineNo varchar(255);
  DECLARE od_sku varchar(255);
  DECLARE od_qtyReceived varchar(255);
  DECLARE od_uom varchar(255);
  DECLARE od_qtyReceivedEach varchar(255);
  DECLARE od_totalCube varchar(255);
  DECLARE od_vasType varchar(255);
  DECLARE od_qtyCharge varchar(255);
  DECLARE OUT_returnCode varchar(1000);

  ####################################################################
  ##游标定义
  DECLARE inventory_done int DEFAULT 0;
  DECLARE tariff_done int DEFAULT 0;
  DECLARE order_done,
          attribute_done int DEFAULT 0;



  DECLARE cur_orderno CURSOR FOR
  SELECT
    IFNULL(CAST(doh.organizationId AS char(255)), '') AS organizationId,
    IFNULL(CAST(doh.warehouseId AS char(255)), '') AS warehouseId,
    IFNULL(CAST(doh.customerId AS char(255)), '') AS customerId,
    IFNULL(CAST(doh.orderNo AS char(255)), '') AS orderNo,
    IFNULL(CAST(doh.soReference1 AS char(255)), '') AS soReference1,
    IFNULL(CAST(dod.sku AS char(255)), '') AS sku,
    IFNULL(CAST(bs.skuDescr1 AS char(255)), '') AS skuDescr1,
    vsdo.orderLineNo AS orderlineNo,
    IFNULL(CAST(vsdo.vasType AS char(255)), '') AS vasType,
    IFNULL(CAST(vsdo.vasqty AS char(255)), '') AS qtyCharge,
    IFNULL(CAST(vsdo.packUom AS char(255)), '') AS packUom
  FROM DOC_ORDER_HEADER doh
    LEFT OUTER JOIN DOC_ORDER_VAS vsdo
      ON doh.organizationId = vsdo.organizationId
      AND doh.warehouseId = vsdo.warehouseId
      AND doh.orderNo = vsdo.orderNo
    LEFT OUTER JOIN DOC_ORDER_DETAILS dod
      ON dod.organizationId = vsdo.organizationId
      AND dod.warehouseId = vsdo.warehouseId
      AND dod.orderNo = vsdo.orderNo
      AND dod.orderLineNo = vsdo.orderLineNo
    LEFT OUTER JOIN BAS_SKU bs
      ON bs.organizationId = dod.organizationId
      AND bs.customerId = dod.customerId
      AND bs.SKU = dod.sku
  WHERE vsdo.warehouseId = IN_warehouseId
  AND doh.customerId = IN_CustomerId
  AND doh.orderNo = IN_trans_no
  -- AND bsm.tariffMasterId = 'BIL00418'
  AND doh.orderType NOT IN ('FREE')
  AND doh.soStatus IN ('99')
  GROUP BY doh.organizationId,
           doh.orderNo,
           doh.soReference1,
           dod.sku,
           bs.skuDescr1,
           vsdo.orderLineNo,
           vsdo.vasType,
           vsdo.packUom;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET order_done = 1;
  OPEN cur_orderno;
cur_order_loop:
  LOOP
    FETCH FROM cur_orderno INTO
    od_organizationId,
    od_warehouseId,
    od_customerId,
    od_soNo,
    od_soReference1,
    od_sku,
    od_skuDescr1,
    od_soLineNo,
    od_vasType,
    od_qtyCharge,
    od_uom;

    IF order_done = 1 THEN

      SET order_done = 0;
      LEAVE cur_order_loop;
    END IF;
  --     SELECT
  --       CONCAT('** DEBUG:', od_asnNo) AS debug;

  BLOCK2:
    BEGIN
      --  IF (od_tariffMasterId <> '') THEN

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
      --       AND btd.docType IN (SELECT
      --           dah.asnType
      --         FROM DOC_ASN_HEADER dah
      --         WHERE dah.asnNo = IN_asnNo)
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
        R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
        R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;
        IF tariff_done THEN
          SET tariff_done = FALSE;
          LEAVE getTariff;
        END IF;


        SELECT
          UPPER(R_CHARGETYPE),
          UPPER(od_vasType),
          R_docType;

        IF (UPPER(R_CHARGETYPE) = UPPER(od_vasType)) THEN
          -- CALCULATION
          -- UOM
          -- PALLET
          -- CUBIC
          -- M2
          -- CASE
          -- IP
          -- PIECES
          -- KG
          -- LITER
          -- DO
          -- HOUR
          -- MONTH



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
            SET OUT_returnCode = '*_*';
            CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, R_WAREHOUSEID, IN_Language, 'BILLINGSUMMARYID', R_billsummaryId, OUT_returnCode);
            IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
              SET OUT_returnCode = '999#计费流水获取异常';
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
              CURDATE(),
              CURDATE(),
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
              'SO' dockType,
              od_soNo,
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

        END IF; -- END IF docType

      END LOOP getTariff;
      CLOSE cur_Tariff;


    --  END IF; 
    --  END IF TARIFF ORDER KOSONG
    END;




  END LOOP cur_order_loop;
  CLOSE cur_orderno;
  SET OUT_returnCode = '000';
END
$$

DELIMITER ;