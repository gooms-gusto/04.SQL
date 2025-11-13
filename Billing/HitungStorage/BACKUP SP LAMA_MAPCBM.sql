USE wms_cml;

DROP PROCEDURE IF EXISTS CML_BILLSTORAGE_DAILY_CBM;

DELIMITER $$

CREATE
DEFINER = 'sa'@'%'
PROCEDURE CML_BILLSTORAGE_DAILY_CBM (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_trans_no varchar(30),
IN IN_tariffMaster varchar(30))
BEGIN
  -- Declare variables to hold cursor data
  DECLARE done int DEFAULT FALSE;
  DECLARE tariff_done int DEFAULT FALSE;
  DECLARE v_stockDate date;
  DECLARE v_customerId varchar(20);
  DECLARE v_warehouseId varchar(20);
  DECLARE v_skuGroup1 varchar(255);
  DECLARE v_workingArea varchar(255);
  DECLARE v_qtyCharge decimal(18, 4);

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
  DECLARE R_chamberName varchar(500);
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
  SELECT
    DATE_FORMAT(ls_storage.stockdate, '%Y-%m-%d') AS stockDate,
    ls_storage.warehouseid,
    ls_storage.customerid,
    ls_storage.workingArea,
    SUM(ls_storage.qtycbm)
  FROM (SELECT
      DATE_FORMAT(stockDate, '%Y-%m-%d') AS stockdate,
      zib.warehouseId AS warehouseid,
      sm.tariffMasterId AS tariffmasterid,
      CASE WHEN zib.customerId = 'LTL' THEN la1.codeDescr ELSE sm.tariffId END AS tariffid,
      CASE WHEN zib.customerId = 'XXX' THEN 'SAMSONITE' ELSE zib.customerId END AS customerid,
      zib.locationId AS locationid,
      zib.locationCategory AS locationcategory,
      lc.codeDescr AS locationcategorydescr,
      zib.TRACEID AS traceid,
      s.sku_group1 AS muidltl,
      zib.muid AS muid,
      zib.lotNum AS lotnum,
      s.PACKID AS packid,
      CASE WHEN zib.customerId = 'MDS' THEN 'KG' ELSE zib.UOM END AS uom,
      CASE WHEN zib.warehouseId = 'CBT02' THEN 'LINC' ELSE l.workingArea END AS workingArea,
      zib.SKU AS sku,
      skuDesc AS skudesc,
      la.lotatt09 AS ponum,
      lc1.codeDescr AS typepallet,
      CASE WHEN zib.customerId = 'MDS' THEN (
            CASE WHEN pd2.uomDescr = 'KG' THEN zib.qtyonHand ELSE zib.qtyonHand * s.sku_group6 END
            ) ELSE zib.qtyonHand END AS qtyonhand,
      pd.qty AS qtyperpallet,
      CASE zib.customerId WHEN 'ASP' THEN zib.cube WHEN 'MAP' THEN s.cube WHEN 'ONDULINE' THEN s.cube WHEN 'SST_JKT' THEN s.cube WHEN 'CPI_JKT' THEN s.cube ELSE s.cube / 1000000 END AS cbmsku,
      CASE zib.customerId WHEN 'MAP' THEN (
            CASE WHEN la.lotatt04 = 'SET' THEN 0 ELSE (s.cube * zib.qtyonHand) END
            ) WHEN 'ONDULINE' THEN s.cube * zib.qtyonHand ELSE totalcube END AS qtycbm,
      CASE WHEN LENGTH(zib.locationId) = 7 THEN SUBSTRING(zib.locationId, 1, 1) WHEN LENGTH(zib.locationId) = 8 THEN SUBSTRING(zib.locationId, 1, 1) WHEN SUBSTRING(zib.locationId, 1, 3) = 'TML' AND
          zib.customerId <> 'LTL' THEN SUBSTRING(zib.locationId, 4, 1) WHEN sm.putawayRule = 'LTL09' THEN 'E' WHEN zib.SKU IN ('000000001100012851', '000000001100010211', '000000001100000616', '000000001100013296', '000000001100008797', '000000001100012070', '000000001100012068', '000000001100012478', '000000001100012898', '000000001100014515') THEN 'G' WHEN sm.putawayRule IN ('LTL03', 'GMPA-NONDG', 'ICHIKOH-NONDG', 'ITOCHU-NONDG', 'PMM-NONDG', 'LTL06', 'LTL07') THEN 'G' WHEN sm.putawayRule IN ('LTL08', 'ITOCHU-DG', 'PMM-DG', 'LTL01', 'LTL02', 'SMT') THEN 'B' WHEN sm.putawayRule = 'LTL-BULK' THEN 'D' WHEN sm.putawayRule IN ('BAJ', 'PLB-LTL', 'ADF', 'CCDI', 'CTI') THEN 'A' WHEN sm.putawayRule IN ('GYI', 'DKJ') THEN 'J' WHEN sm.putawayRule = 'LTL04' THEN 'B' WHEN sm.putawayRule IN ('DNN', 'PMM', 'ITOCHU') THEN 'C' ELSE l.udf03 END AS chamber,
      sm.putawayRule AS putawayrule,
      la.lotatt04 AS batchno,
      la.lotatt02 AS expiredate,
      la.lotatt03 AS whdate,
      CASE WHEN zib.customerId = 'ECCOSBY' THEN (
            CASE WHEN SUBSTRING(zib.locationId, 3, 1) = 'I' THEN 'ECCO2' ELSE 'ECCO' END
            ) ELSE SUBSTRING(zib.locationId, 1, 1) END AS area,
      CASE WHEN zib.customerId = 'PLB-LTL' THEN la.lotatt10 ELSE la.lotatt09 END AS externalpo,
      lc2.codeDescr AS whetherdamaged,
      CEILING(qtyonHand / pd.qty) AS palletused,
      CASE WHEN zib.customerId = 'RBFOOD' THEN pd1.qty ELSE s.NETWEIGHT END AS netweight
    FROM Z_InventoryBalance zib
      LEFT JOIN INV_LOT_ATT la
        ON la.organizationId = zib.organizationId
        AND la.customerId = zib.customerId
        AND la.sku = zib.sku
        AND la.lotNum = zib.lotNum
      LEFT OUTER JOIN (SELECT
          *
        FROM BSM_CODE_ML
        WHERE codetype = 'OWNER_LTL'
        AND languageid = 'en') la1
        ON la.organizationId = la1.organizationId
        AND la.lotatt11 = la1.codeid
      LEFT JOIN BAS_LOCATION l
        ON l.organizationId = zib.organizationId
        AND l.locationId = zib.locationId
        AND l.warehouseId = zib.warehouseId
      LEFT JOIN BAS_SKU s
        ON s.organizationId = zib.organizationId
        AND s.customerId = zib.customerId
        AND s.sku = zib.sku
      LEFT JOIN BAS_SKU_MULTIWAREHOUSE sm
        ON sm.organizationId = zib.organizationId
        AND sm.customerId = zib.customerId
        AND sm.sku = zib.sku
        AND sm.warehouseId = zib.warehouseId
      LEFT JOIN BAS_PACKAGE_DETAILS pd
        ON sm.organizationId = pd.organizationId
        AND sm.customerId = pd.customerId
        AND sm.packId = pd.packId
        AND pd.packUom = 'PL'
      LEFT JOIN BAS_PACKAGE_DETAILS pd1
        ON sm.organizationId = pd1.organizationId
        AND sm.customerId = pd1.customerId
        AND sm.packId = pd1.packId
        AND pd1.packUom = 'CS'
      LEFT JOIN BAS_PACKAGE_DETAILS pd2
        ON sm.organizationId = pd2.organizationId
        AND sm.customerId = pd2.customerId
        AND sm.packId = pd2.packId
        AND pd2.packUom = 'EA'
      LEFT JOIN BSM_CODE_ML lc
        ON lc.organizationId = zib.organizationId
        AND zib.locationCategory = lc.codeid
        AND lc.codeType = 'LOC_CAT'
        AND lc.languageId = 'en'
      LEFT JOIN BSM_CODE_ML lc1
        ON lc1.organizationId = la.organizationId
        AND la.lotAtt07 = lc1.codeid
        AND lc1.codeType = 'PLT_TYP'
        AND lc1.languageId = 'en'
      LEFT JOIN BSM_CODE_ML lc2
        ON lc2.organizationId = la.organizationId
        AND la.lotAtt08 = lc2.codeid
        AND lc2.codeType = 'DMG_FLG'
        AND lc2.languageId = 'en'
    WHERE zib.organizationId = 'OJV_CML'
    -- AND zib.warehouseId IN ('CBT02', 'CBT03', 'LADC01')
    AND zib.warehouseId IN ('CBT03')
    AND zib.customerId = IN_CustomerId
    AND qtyonHand > 0
    AND zib.locationId NOT IN ('CONSWOR', 'LOST_CBT01', 'STG01', 'STG02', 'STG03', 'STG04', 'STG05', 'STG11', 'STG12', 'STG13', 'STG14', 'STG15', 'STG06', 'STG07', 'STG08', 'STG09', 'STG10', 'STG16', 'STG17', 'STG18', 'STG19', 'STG20', 'SORTATIONCBT01', 'CROSSDOCK_01', 'CROSSDOCK_02', 'SORTATIONLADC01', 'SORTATIONBASF01', 'SORTATIONCBT02', 'SORTATIONCBT03', 'SORTATION', 'SORTATIONMRD02', 'SORTATIONSMG-SO', 'SORTATION1', 'CYCLE-01S', 'LOST_CBT01', 'STO-01', 'STO-02', 'STO-03', 'STO-04', 'STO-05', 'WHAQC', 'WHCQC', 'WHCQC01', 'WHCQC03', 'WHCQC05', 'WHCQC09', 'WHCQC11', 'WHCQC13', 'WHCQC15', 'WHCQC17', 'WHCQC19', 'WHCQC21', 'WHCQC23', 'WHCQC25', 'WHCQC27', 'WHCQC29', 'WHCQC31', 'WHCQC33', 'WHCQC35', 'WHIQC', 'WORK_AREA', 'B04A065', 'B04A066', 'B04B065', 'B04B065')
    AND zib.sku NOT IN (SELECT
        sku
      FROM BAS_SKU bs2
      WHERE organizationId = zib.organizationId
      AND customerId = 'LTL'
      AND sku LIKE '13%'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU bs2
      WHERE organizationid = zib.organizationId
      AND customerid = 'SMARTSBY'
      AND sku = 'PALLET'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU
      WHERE organizationid = zib.organizationId
      AND customerid IN ('ECMAMA', 'ECMAMAB2C')
      AND sku LIKE '%TEST%'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU
      WHERE organizationid = zib.organizationId
      AND customerid IN ('MAP')
      AND sku IN ('DEMO TABLE AT', 'DEMO TABLE SAM', 'HOT STAMP'))
    AND DATE(zib.StockDate) = DATE(DATE_ADD(NOW(), INTERVAL -1 DAY))
    --     AND DATE(zib.StockDate) > '2024-10-25'
    --     AND DATE(zib.StockDate) < '2024-11-17'
    ORDER BY zib.customerId) ls_storage
  GROUP BY ls_storage.warehouseId,
           ls_storage.customerId,
           ls_storage.StockDate,
           ls_storage.workingArea
  ORDER BY ls_storage.customerId, stockDate, ls_storage.workingArea;

  -- Declare a handler for NOT FOUND condition
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  -- Open the cursor
  OPEN my_cursor;

-- Loop through the results
read_loop:
  LOOP
    -- Fetch the values into variables
    FETCH my_cursor INTO v_stockDate, v_warehouseId, v_customerId, v_workingArea, v_qtyCharge;



    --  SELECT v_customerId,R_CUSTOMERID,R_WAREHOUSEID,v_warehouseId;
    -- Exit the loop if no more rows
    IF done THEN
      LEAVE read_loop;
    END IF;

    IF NOT EXISTS (SELECT
          1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = IN_organizationId
        AND bs.warehouseId = v_warehouseId
        AND bs.customerId = v_customerId
        AND DATE(bs.billingFromDate) = DATE(DATE_ADD(CURDATE(), INTERVAL -1 DAY))
        AND bs.descr = v_workingArea
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
          btr.udf03,-- chamber name
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
        AND btr.udf03 = v_workingArea -- for filter chamber name
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
          R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_qtyMinimumContract, R_chamberName, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
          R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;
          IF tariff_done THEN
            SET tariff_done = FALSE;
            LEAVE getTariff;
          END IF;





          IF (LTRIM(RTRIM(R_WAREHOUSEID)) = LTRIM(RTRIM(v_warehouseId)))
            AND (LTRIM(RTRIM(R_CUSTOMERID)) = LTRIM(RTRIM(v_customerId)))
            AND (LTRIM(RTRIM(R_chamberName)) = LTRIM(RTRIM(v_workingArea))) THEN
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


            --           SELECT  'check=>',R_ratebase,R_TARIFFID;
            SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
            SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
            SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
            SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
            SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
            SET R_billsummaryId = '';


            IF (R_ratebase = 'CUBIC') THEN
              IF (v_qtyCharge > R_qtyMinimumContract) THEN
                SET R_RESULTQTYCHARGE = v_qtyCharge;
              ELSE
                SET R_RESULTQTYCHARGE = R_qtyMinimumContract;
              END IF;
            ELSEIF (R_ratebase = 'M2') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'IP') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'KG') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'LITER') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'DO') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'PALLET') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'CASE') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'QUANTITY') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'NETWEIGHT') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'GW') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            /*additional nettweight grossweight*/
            ELSEIF (R_ratebase = 'MT') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            END IF;

            SELECT
              'DEBUG=>',
              v_customerId,
              R_CUSTOMERID,
              R_WAREHOUSEID,
              v_warehouseId,
              R_RESULTQTYCHARGE;

            --           SELECT 'check 2=>',R_RESULTQTYCHARGE;

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
                CONCAT(v_workingArea),
                R_rateBase,
                R_rateperunit,
                v_qtyCharge,
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