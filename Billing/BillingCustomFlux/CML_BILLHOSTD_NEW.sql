USE WMS_FTEST;

DROP PROCEDURE IF EXISTS CML_BILLHOSTD;

DELIMITER $$

CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLHOSTD (IN IN_organizationId varchar(30),
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
  DECLARE R_PALLETCNT varchar(30);
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
  DECLARE od_organizationId varchar(20);
  DECLARE od_orderNo varchar(20);
  DECLARE od_soReference1 varchar(255);
  DECLARE od_soReference3 varchar(255);
  DECLARE od_orderType varchar(255);
  DECLARE od_docType varchar(255);
  DECLARE od_docTypeDescr varchar(255);
  DECLARE od_soStatus varchar(255);
  DECLARE od_warehouseId varchar(255);
  DECLARE od_customerId varchar(255);
  DECLARE od_orderLineNo varchar(255);
  DECLARE od_SKU varchar(255);
  DECLARE od_ShipmentTime varchar(255);
  DECLARE od_qty varchar(255);
  DECLARE od_qty_each varchar(255);
  DECLARE od_qtyShipped_each varchar(255);
  DECLARE od_uom varchar(255);
  DECLARE od_qtyCharge varchar(255);
  DECLARE od_totalCube varchar(255);
  DECLARE od_editTime varchar(255);
  DECLARE od_lotNum varchar(255);
  DECLARE od_traceId varchar(255);
  DECLARE od_pickToTraceId varchar(255);
  DECLARE od_dropId varchar(255);
  DECLARE od_location varchar(255);
  DECLARE od_pickToLocation varchar(255);
  DECLARE od_allocationDetailsId varchar(255);
  DECLARE od_skuDescr1 varchar(255);
  DECLARE od_grossWeight varchar(255);
  DECLARE od_cubeNya varchar(255);
  DECLARE od_tariffMasterId varchar(255);
  DECLARE od_QtyPerCases varchar(255);
  DECLARE od_QtyPerPallet varchar(255);
  DECLARE od_zone varchar(255);
  DECLARE od_batch varchar(255);
  DECLARE od_lotAtt07 varchar(255);
  DECLARE od_RecType varchar(21);
  DECLARE od_Billtranctg varchar(21);
  DECLARE OUT_returnCode varchar(1000);
  ####################################################################
  DECLARE od_qtyChargeEA varchar(255);
  DECLARE od_qtyChargeCS varchar(255);
  DECLARE od_qtyChargeIP varchar(255);
  DECLARE od_qtyChargePL varchar(255);
  DECLARE od_qtyChargeCBM varchar(255);
  DECLARE od_qtyChargeTotDO varchar(255);
  DECLARE od_qtyChargeTotLine varchar(255);
  DECLARE od_qtyChargeNettWeight varchar(255);/*additional nettweight Gross Weight ABYuhuu*/
  DECLARE od_qtyChargeGrossWeight varchar(255);
  ####################################################################

  ##游标定义
  DECLARE inventory_done int DEFAULT FALSE;
  DECLARE tariff_done int DEFAULT FALSE;
  DECLARE order_done,
          attribute_done boolean DEFAULT FALSE;
  DECLARE cur_orderno CURSOR FOR
  SELECT
    IFNULL(CAST(doh.organizationId AS char), '') AS organizationId,
    IFNULL(CAST(doh.orderNo AS char), '') AS orderNo,
    IFNULL(CAST(doh.soReference1 AS char(255)), '') AS soReference1,
    IFNULL(CAST(doh.soReference3 AS char(255)), '') AS soReference3,
    IFNULL(CAST(doh.orderType AS char(255)), '') AS orderType,
    IFNULL(CAST(t1.codeType AS char(255)), '') AS docType,
    IFNULL(CAST(t1.codeDescr AS char(255)), '') AS docTypeDescr,
    IFNULL(CAST(doh.soStatus AS char(255)), '') AS soStatus,
    IFNULL(CAST(doh.warehouseId AS char(255)), '') AS warehouseId,
    IFNULL(CAST(aad.customerId AS char(255)), '') AS customerId,
    IFNULL(CAST(aad.orderLineNo AS char(255)), 0) AS orderLineNo,
    IFNULL(CAST(aad.SKU AS char(255)), '') AS SKU,
    CAST(DATE_FORMAT(aad.shipmentTime, '%Y-%m-%d') AS char(255)) AS ShipmentTime,
    IFNULL(CAST(aad.qty AS char(255)), 0) AS qty,
    IFNULL(CAST(aad.qty_each AS char(255)), 0) AS qty_each,
    IFNULL(CAST(aad.qtyShipped_each AS char(255)), 0) AS qtyShipped_each,
    IFNULL(CAST(aad.uom AS char(255)), '') AS uom,
    IFNULL(CAST(SUM(aad.qtyShipped_each / bpdEA.qty) AS char(255)), 0) AS qtyChargeEA,
    IFNULL(CAST(CEIL(SUM(aad.qtyShipped_each / bpdCS.qty)) AS char(255)), 0) AS qtyChargeCS,
    IFNULL(CAST(CEIL(SUM(aad.qtyShipped_each / bpdIP.qty)) AS char(255)), 0) AS qtyChargeIP,
    IFNULL(CAST(CEIL(SUM(aad.qtyShipped_each / bpdPL.qty)) AS char(255)), 0) AS qtyChargePL,
    IFNULL(CAST(SUM(aad.qtyShipped_each * bs.cube) AS char(255)), 0) AS qtyChargeCBM,
    IFNULL(CAST(COUNT(doh.orderNo) AS char(255)), 0) AS qtyChargeTotDO,
    IFNULL(CAST(COUNT(aad.orderLineNo) AS char(255)), 0) AS qtyChargeTotLine,
    IFNULL(CAST((SUM(aad.qtyShipped_each * bs.cube)) AS char(255)), 0) AS totalCube,
    IFNULL(CAST(aad.editTime AS char(255)), '') AS editTime,
    IFNULL(CAST(aad.lotNum AS char(255)), '') AS lotNum,
    IFNULL(CAST(aad.traceId AS char(255)), '') AS traceId,
    IFNULL(CAST(aad.pickToTraceId AS char(255)), '') AS pickToTraceId,
    IFNULL(CAST(aad.dropId AS char(255)), '') AS dropId,
    IFNULL(CAST(aad.location AS char(255)), '') AS location,
    IFNULL(CAST(aad.pickToLocation AS char(255)), '') AS pickToLocation,
    IFNULL(CAST(aad.allocationDetailsId AS char(255)), '') AS allocationDetailsId,
    IFNULL(CAST(bs.skuDescr1 AS char(255)), '') AS skuDescr1,
    IFNULL(CAST(bs.grossWeight AS char(255)), 0) AS grossWeight,
    IFNULL(CAST(bs.cube AS char(255)), 0) AS cubeNya,
    IFNULL(CAST(bsm.tariffMasterId AS char(255)), '') AS tariffMasterId,
    IFNULL(CAST(bpdCS.qty AS char(255)), 0) AS QtyPerCases,
    IFNULL(CAST(bpdPL.qty AS char(255)), 0) AS QtyPerPallet,
    IFNULL(CAST(bz.zoneDescr AS char(255)), '') AS zone,
    IFNULL(CAST(ila.lotAtt04 AS char(255)), '') AS batch,
    IFNULL(CAST(ila.lotAtt07 AS char(255)), '') AS lotAtt07,
    IFNULL(CAST(BT.codeid AS char(255)), '') AS billtranctg,
    IFNULL(CAST(SUM(aad.qtyShipped_each * bs.netWeight) AS char(255)), 0) AS qtyChargeNettWeight,
    IFNULL(CAST(SUM(aad.qtyShipped_each * bs.grossWeight) AS char(255)), 0) AS qtyChargeGrossWeight
  /*additional nettweight Gross Weight ABYuhuu*/
  FROM ACT_ALLOCATION_DETAILS aad
    LEFT OUTER JOIN DOC_ORDER_HEADER doh
      ON doh.organizationId = aad.organizationId
      AND doh.customerId = aad.customerId
      AND doh.orderNo = aad.orderNo
    LEFT OUTER JOIN BAS_SKU bs
      ON bs.organizationId = aad.organizationId
      AND bs.SKU = aad.SKU
      AND bs.customerId = aad.customerId
    LEFT OUTER JOIN BAS_SKU_MULTIWAREHOUSE bsm
      ON bsm.organizationId = bs.organizationId
      AND bsm.SKU = bs.SKU
      AND bsm.customerId = bs.customerId
      AND bsm.warehouseId = aad.warehouseId
    LEFT OUTER JOIN INV_LOT_ATT ila
      ON ila.organizationId = aad.organizationId
      AND ila.SKU = aad.SKU
      AND ila.lotnum = aad.lotnum
      AND ila.customerId = aad.customerId
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
      ON t1.organizationId = aad.organizationId
      AND t1.codeType = 'SO_TYP'
      AND t1.codeId = doh.orderType
      AND t1.languageId = 'en'
    LEFT JOIN BSM_CODE BT
      ON BT.organizationId = aad.organizationId
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
  WHERE aad.customerId = IN_CustomerId
  AND aad.warehouseId = IN_warehouseId
  AND doh.orderNo = IN_trans_no
  -- AND bsm.tariffMasterId = IN_tariffMaster
  -- AND DATE_FORMAT(aad.shipmentTime, '%Y-%m-%d') >= '2023-09-10'
  --  AND DATE_FORMAT(aad.shipmentTime, '%Y-%m-%d') <= '2023-09-12'
  AND aad.Status IN ('99', '80')
  AND bs.skuDescr1 NOT LIKE '%PALLET%'
  AND doh.orderType NOT IN ('FREE', 'KT')

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
           BT.codeid;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET order_done = TRUE;
  OPEN cur_orderno;
cur_order_loop:
  LOOP
    FETCH FROM cur_orderno INTO
    od_organizationId, 
    od_orderNo,
    od_soReference1,
    od_soReference3, 
    od_orderType, 
    od_docType,
    od_docTypeDescr, od_soStatus, od_warehouseId,
    od_customerId, od_orderLineNo, od_SKU, od_ShipmentTime, od_qty,
    od_qty_each, od_qtyShipped_each, od_uom,
    od_qtyChargeEA,
    od_qtyChargeCS,
    od_qtyChargeIP,
    od_qtyChargePL,
    od_qtyChargeCBM,
    od_qtyChargeTotDO,
    od_qtyChargeTotLine,
    od_totalCube,
    od_editTime, od_lotNum, od_traceId, od_pickToTraceId, od_dropId,
    od_location, od_pickToLocation, od_allocationDetailsId, od_skuDescr1,
    od_grossWeight, od_cubeNya, od_tariffMasterId, od_QtyPerCases,
    od_QtyPerPallet, od_zone, od_batch, od_lotAtt07, od_Billtranctg, od_qtyChargeNettWeight, od_qtyChargeGrossWeight;/*additional nettweight Gross Weight ABYuhuu*/

    IF order_done THEN
      SET order_done = FALSE;
      LEAVE cur_order_loop;
    END IF;

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
        btd.udf05,
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
      AND bth.tariffMasterId = od_tariffMasterId
      AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND btd.chargeCategory = 'OB'
      AND btd.docType=od_orderType
      AND btr.rate > 0
      #AND IFNULL(DAY(bth.billingdate),0)!=0 
      ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = TRUE;
      ####################################################################


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


        -- ADDING AKBAR RULE => JIKA BILLING CATEGORY TIDAK DI SETUP DI BILING SETUP, SKIP VALIDASI 07.03.2024

        IF R_BILLINGTRANCATEGORY IS NULL
          OR R_BILLINGTRANCATEGORY = '' THEN
          SET R_BILLINGTRANCATEGORY = od_Billtranctg;
        END IF;

        IF (RTRIM(LTRIM(od_orderType)) = RTRIM(LTRIM(R_docType)))
          AND (RTRIM(LTRIM(od_Billtranctg)) = RTRIM(LTRIM(R_BILLINGTRANCATEGORY))) THEN

          --       SELECT
          --           od_orderType,
          --           R_docType,
          --           od_Billtranctg,
          --           R_BILLINGTRANCATEGORY;


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

          IF (R_ratebase = 'CUBIC') THEN
            SET R_RESULTQTYCHARGE = od_qtyChargeCBM;
          ELSEIF (R_ratebase = 'M2') THEN
            SET R_RESULTQTYCHARGE = od_qtyChargeEA;
          ELSEIF (R_ratebase = 'IP') THEN
            SET R_RESULTQTYCHARGE = od_qtyChargeIP;
          ELSEIF (R_ratebase = 'KG') THEN
            SET R_RESULTQTYCHARGE = od_qtyChargeEA;
          ELSEIF (R_ratebase = 'LITER') THEN
            SET R_RESULTQTYCHARGE = od_qtyChargeEA;
          ELSEIF (R_ratebase = 'QUANTITY') THEN
            SET R_RESULTQTYCHARGE = od_qtyChargeEA;
          ELSEIF (R_ratebase = 'DO') THEN
            SET R_RESULTQTYCHARGE = od_qtyChargeTotDO;
          ELSEIF (R_ratebase = 'PALLET') THEN
            SET R_RESULTQTYCHARGE = od_qtyChargePL;
          ELSEIF (R_ratebase = 'NETWEIGHT') THEN
            SET R_RESULTQTYCHARGE = od_qtyChargeNettWeight;
          ELSEIF (R_ratebase = 'GW') THEN
            SET R_RESULTQTYCHARGE = od_qtyChargeGrossWeight;/*additional nettweight Gross Weight ABYuhuu*/
          --             IF (R_PALLETCNT = 'N') THEN
          --               SET R_RESULTQTYCHARGE = od_qtyCharge;
          --             ELSEIF (R_PALLETCNT = 'Y') THEN
          --               SET R_RESULTQTYCHARGE = od_qtyCharge;
          --             ELSEIF (R_PALLETCNT = 'X') THEN
          --               SET R_RESULTQTYCHARGE = od_qtyCharge;
          --             END IF;
          END IF;


--         SELECT 'check=>',R_RESULTQTYCHARGE,R_TARIFFID;


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
          END IF;
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
              od_lotNum,
              od_traceId,
              R_TARIFFID,
              R_CHARGECATEGORY,
              R_chargetype,
              R_descrC,
              R_rateBase,
              R_rateperunit,
              od_qtyShipped_each,
              od_uom,
              od_totalCube,
              od_grossWeight,
              R_rate,
              R_RESULTQTYCHARGE * R_rate / R_rateperunit,
              (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
              0,
              R_cost * R_RESULTQTYCHARGE,
              0,
              NOW() confirmTime,
              '' confirmWho,
              'SO',
              od_orderNo,
              '' createTransactionid,
              '' notes,
              NOW() ediSendTime,
              R_BILLTO billTo,
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
              R_UDF08 udf03,
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
              od_orderType orderType,
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