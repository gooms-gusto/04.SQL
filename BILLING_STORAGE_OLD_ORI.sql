-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE WMS_FTEST;

DELIMITER $$

--
-- Create procedure `BILL_STORAGE_DETAIL`
--
CREATE DEFINER = 'wms_ftest'@'%'
PROCEDURE BILL_STORAGE_DETAIL (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
INOUT OUT_returnCode varchar(1000))
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
  DECLARE R_TARIFFMASTERID varchar(10);
  DECLARE R_TARIFFLINENO int(11);
  DECLARE R_TARIFFCLASSNO int(11);
  DECLARE R_CHARGECATEGORY varchar(20);
  DECLARE R_CHARGETYPE varchar(20);
  DECLARE R_descrC varchar(50);
  DECLARE R_ratebase varchar(20);
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
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
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
  DECLARE c_cube decimal(24, 8) DEFAULT NULL;
  DECLARE c_totalCube decimal(24, 8) DEFAULT NULL;
  DECLARE c_grossWeight decimal(18, 8) DEFAULT NULL;
  DECLARE c_netWeight decimal(18, 8) DEFAULT NULL;
  DECLARE c_freightClass varchar(255) binary DEFAULT NULL;
  DECLARE c_locationCategory varchar(10) DEFAULT '';

  DECLARE tariff_done int DEFAULT FALSE;
  DECLARE inventory_done int DEFAULT FALSE;


  DECLARE cur_Tariff CURSOR FOR
  SELECT DISTINCT
    bsm.organizationId,
    bsm.warehouseId,
    bsm.CUSTOMERID,
    DAY(bth.billingdate) billingDate,
    btd.tariffId,
    btd.tariffLineNo,
    btr.tariffClassNo,
    btd.chargeCategory,
    btd.chargeType,
    btd.descrC,
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
    btd.UDF05 R_LOCATIONGROUP,
    btd.UDF06,
    IFNULL(btd.incomeTaxRate, 0) IncomeTaxRate,
    CASE WHEN chargeType = 'ES' THEN btr.classfrom - 1 ELSE btr.classfrom END,
    classTo,
    bth.contractNo,
    bth.tariffMasterId,
    btr.cost,
    btd.billingParty
  FROM BAS_SKU_MULTIWAREHOUSE bsm
    LEFT JOIN BAS_CUSTOMER bc
      ON bc.customerId = bsm.customerId
      AND bc.organizationId = bsm.organizationId
    LEFT JOIN BIL_TARIFF_HEADER bth
      ON bth.organizationId = bsm.organizationId
      AND bth.tariffMasterId = bsm.tariffMasterId
    LEFT JOIN BIL_TARIFF_DETAILS btd
      ON btd.organizationId = bth.organizationId
      AND btd.tariffId = bth.tariffId
    LEFT JOIN BIL_TARIFF_RATE btr
      ON btr.organizationId = btd.organizationId
      AND btr.tariffId = btd.tariffId
      AND btr.tariffLineNo = btd.tariffLineNo
  WHERE bsm.tariffMasterId != ''
  AND bth.tariffId IS NOT NULL
  AND bc.customerType = 'OW'
  AND btd.chargeCategory = 'IV'
  AND btr.rate IS NOT NULL
  AND bsm.customerId LIKE IN_CustomerId
  AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  AND IFNULL(DAY(bth.billingdate), 0) != 0
  ORDER BY bsm.organizationId, bsm.customerId, btd.tariffId, btd.tariffId, btd.tariffLineNo, btr.tariffClassNo;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;
  BEGIN
    SET R_CURRENTDATE = CURDATE();
    OPEN cur_Tariff;
  getTariff:
    LOOP
      FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC,
      R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06,
      R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY;
      IF tariff_done THEN
        SET tariff_done = FALSE;
        LEAVE getTariff;
      END IF;

      SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
      SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
      SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
      SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
      SET R_billsummaryId = '';
      IF R_BILLINGPARTY = 'BI' THEN
        SET R_BILLTO = R_CustomerId;
        SELECT
          CUSTOMERID INTO R_BILLTO
        FROM BAS_CUSTOMER
        WHERE refOwner = R_CustomerId
        AND CustomerType = 'BI'
        LIMIT 1;
      ELSE
        SET R_BILLTO = R_CustomerId;
      END IF;

      IF (R_BILLINGDATE = R_CURRENTDATE) THEN
      BEGIN

        DROP TABLE IF EXISTS TMP_BIL_SUMMARY_INFORMATION;
        CREATE TEMPORARY TABLE TMP_BIL_SUMMARY_INFORMATION (
          organizationId varchar(20),
          warehouseId varchar(20),
          customerId varchar(30),
          billsummaryId varchar(30),
          LineNo int(11),
          tariffId varchar(10),
          tariffLineNo int(11),
          descrC varchar(60),
          chargeCategory varchar(20),
          chargeType varchar(20),
          ratebase varchar(20),
          minQty varchar(500),
          billingMode varchar(500),
          ratePerUnit decimal(24, 8) DEFAULT NULL,
          rate decimal(24, 8) NOT NULL DEFAULT 0.00000000,
          tariffClassNo int(11) NOT NULL,
          classFrom decimal(24, 8) NOT NULL,
          classTo decimal(24, 8) NOT NULL,
          StockDate date DEFAULT NULL,
          locationId varchar(60) binary DEFAULT NULL,
          locationCategory varchar(10) binary NOT NULL,
          zoneId varchar(20) DEFAULT NULL,
          traceId varchar(30) binary NOT NULL,
          muid varchar(30) binary NOT NULL DEFAULT '*',
          lotNum varchar(10) binary NOT NULL,
          sku varchar(255) binary NOT NULL DEFAULT '',
          qtyonHand int(11) DEFAULT NULL,
          packkey varchar(255) binary DEFAULT NULL,
          UOM varchar(255) binary DEFAULT NULL,
          qtyallocated int(11) DEFAULT NULL,
          qtyonHold int(11) DEFAULT NULL,
          qtyavailable int(11) DEFAULT NULL,
          qtyPicked int(11) DEFAULT NULL,
          palletUsed int(11) DEFAULT NULL,
          SKUDesc varchar(550) binary DEFAULT NULL,
          CUBE decimal(24, 8) DEFAULT NULL,
          totalCube decimal(24, 8) DEFAULT NULL,
          grossWeight decimal(18, 8) DEFAULT NULL,
          netWeight decimal(18, 8) DEFAULT NULL,
          freightClass varchar(255) binary DEFAULT NULL,
          addWho varchar(255) binary NOT NULL DEFAULT '',
          ADDTIME datetime DEFAULT NULL,
          editWho varchar(255) binary DEFAULT NULL,
          editTime datetime DEFAULT NULL
        );
        SET @linenumber = 0;
        IF (R_CHARGECATEGORY = 'IV'
          AND R_CHARGETYPE = 'PL') THEN
          CASE
            WHEN R_billMode = 'INTRACE' THEN  -- GET STORAGE FROM OPENING INVENTORY with HANDLING IN
              BEGIN
                INSERT INTO TMP_BIL_SUMMARY_INFORMATION
                  SELECT
                    zib.organizationId,
                    zib.warehouseId,
                    zib.customerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    StockDate,
                    zib.locationId,
                    IFNULL(bl.locationCategory, '') LocationCategory,
                    IFNULL(bl.zoneId, '') AS zoneId,
                    zib.traceId,
                    zib.muid,
                    zib.lotNum,
                    zib.sku,
                    SUM(qtyonHand),
                    zib.packkey,
                    zib.UOM,
                    SUM(qtyallocated),
                    SUM(qtyonHold),
                    SUM(qtyavailable),
                    SUM(qtyPicked),
                    1 palletUsed,
                    SKUDesc,
                    SUM(CUBE),
                    SUM(totalCube),
                    SUM(grossWeight),
                    SUM(netWeight),
                    freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM Z_InventoryBalance zib
                    LEFT JOIN INV_LOT_ATT ila
                      ON ila.organizationId = zib.organizationId
                      AND ila.lotNum = zib.LotNum
                    LEFT JOIN BAS_LOCATION bl
                      ON bl.organizationId = zib.organizationId
                      AND bl.warehouseId = zib.warehouseId
                      AND bl.locationId = zib.locationId
                    LEFT JOIN BAS_LOCGROUP1 bl1
                      ON bl1.organizationId = bl.organizationId
                      AND bl1.warehouseId = bl.warehouseId
                      AND bl1.locGroup1 = bl.locGroup1
                    LEFT JOIN BAS_SKU_MULTIWAREHOUSE bsm
                      ON (
                      bsm.organizationId = zib.organizationId
                      AND bsm.warehouseId = zib.warehouseId
                      AND bsm.customerId = zib.customerId
                      AND bsm.SKU = zib.sku
                      AND bsm.tariffMasterId = R_TARIFFMASTERID
                      )
                  WHERE zib.organizationId = R_ORGANIZATIONID
                  AND zib.warehouseId = R_WAREHOUSEID
                  AND zib.customerId = R_CUSTOMERID
                  AND bsm.tariffMasterId = R_TARIFFMASTERID
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  AND zib.traceId NOT IN ('*', ' ')
                  -- AND zib.muid IN ('*','',' ') 
                  AND ila.lotAtt07 = 'R'
                  AND zib.StockDate = R_OPDATE
                  GROUP BY zib.organizationId,
                           zib.warehouseId,
                           zib.locationId,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           zib.customerId,
                           zib.StockDate,
                           zib.sku,
                           zib.SKUDesc,
                           zib.UOM,
                           zib.lotNum,
                           zib.packkey,
                           zib.traceId,
                           zib.muid,
                           zib.freightClass
                  UNION ALL
                  SELECT
                    atl.organizationId,
                    atl.warehouseId,
                    atl.toCustomerId customerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    ila.lotAtt03 AS StockDate,
                    atl.toLocation AS locationId,
                    IFNULL(bl.locationCategory, '') LocationCategory,
                    IFNULL(bl.zoneId, '') AS zoneId,
                    atl.toId traceId,
                    '' muid,
                    ila.lotNum,
                    atl.toSku,
                    SUM(atl.toQty_Each),
                    atl.toPackId packkey,
                    atl.toUom UOM,
                    0 qtyallocated,
                    0 qtyonHold,
                    0 qtyavailable,
                    0 qtyPicked,
                    1 palletUsed,
                    bs.skuDescr1 AS SKUDesc,
                    SUM(CUBE),
                    SUM(atl.totalCubic),
                    SUM(grossWeight),
                    SUM(netWeight),
                    '' freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM ACT_TRANSACTION_LOG atl
                    LEFT JOIN INV_LOT_ATT ila
                      ON ila.organizationId = atl.organizationId
                      AND ila.lotNum = atl.toLotNum
                    LEFT JOIN BAS_LOCATION bl
                      ON bl.organizationId = bl.organizationId
                      AND bl.warehouseId = atl.toWarehouse
                      AND bl.locationId = atl.toLocation
                    LEFT JOIN BAS_LOCGROUP1 bl1
                      ON bl1.organizationId = bl.organizationId
                      AND bl1.warehouseId = bl.warehouseId
                      AND bl1.locGroup1 = bl.locGroup1
                    LEFT JOIN BAS_SKU bs
                      ON bs.organizationId = atl.organizationId
                      AND bs.customerId = bs.customerId
                      AND bs.sku = atl.fmSku
                  WHERE ila.lotAtt03 >= R_FMDATE
                  AND ila.lotAtt03 <= R_TODATE
                  AND ila.lotAtt03 IS NOT NULL
                  AND atl.status = '99'
                  AND atl.transactionType = 'IN'
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  AND atl.toId NOT IN ('*', '', ' ')
                  -- AND atl.toMuid IN ('*','',' ') 
                  AND ila.lotAtt07 = 'R'
                  GROUP BY atl.organizationId,
                           atl.warehouseId,
                           atl.toCustomerId,
                           atl.toLocation,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           atl.toSku,
                           bs.skuDescr1,
                           atl.toUom,
                           ila.lotAtt03,
                           atl.toPackId,
                           atl.toLotNum,
                           atl.toId;
              END;
            WHEN R_billMode IN ('MAXTRACE', 'DAILYTRACE', 'MONTHTRACE') THEN BEGIN
                INSERT INTO TMP_BIL_SUMMARY_INFORMATION
                  SELECT
                    zib.organizationId,
                    zib.warehouseId,
                    zib.customerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    zib.StockDate,
                    zib.locationId,
                    IFNULL(bl.locationCategory, ''),
                    IFNULL(bl.zoneId, '') AS zoneId,
                    zib.traceId,
                    '*' muid,
                    zib.lotNum,
                    zib.sku,
                    SUM(qtyonHand),
                    zib.packkey,
                    zib.UOM,
                    SUM(qtyallocated),
                    SUM(qtyonHold),
                    SUM(qtyavailable),
                    SUM(qtyPicked),
                    1 palletUsed,
                    SKUDesc,
                    SUM(CUBE),
                    SUM(totalCube),
                    SUM(grossWeight),
                    SUM(netWeight),
                    freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM Z_InventoryBalance zib
                    LEFT JOIN BAS_LOCATION bl
                      ON bl.organizationId = zib.organizationId
                      AND bl.warehouseId = zib.warehouseId
                      AND bl.locationId = zib.locationId
                    LEFT JOIN BAS_LOCGROUP1 bl1
                      ON bl1.organizationId = bl.organizationId
                      AND bl1.warehouseId = bl.warehouseId
                      AND bl1.locGroup1 = bl.locGroup1
                    LEFT JOIN INV_LOT_ATT ila
                      ON ila.organizationId = zib.organizationId
                      AND ila.customerId = zib.customerId
                      AND ila.sku = zib.sku
                      AND ila.lotNum = zib.lotNum
                    LEFT JOIN BAS_SKU_MULTIWAREHOUSE bsm
                      ON (
                      bsm.organizationId = zib.organizationId
                      AND bsm.warehouseId = zib.warehouseId
                      AND bsm.customerId = zib.customerId
                      AND bsm.SKU = zib.sku
                      AND bsm.tariffMasterId = R_TARIFFMASTERID
                      )
                  WHERE zib.organizationId = R_ORGANIZATIONID
                  AND zib.warehouseId = R_WAREHOUSEID
                  AND zib.customerId = R_CUSTOMERID
                  AND bsm.tariffMasterId = R_TARIFFMASTERID
                  AND zib.StockDate >= R_FMDATE
                  AND zib.StockDate <= R_TODATE
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  AND ila.lotAtt07 = 'R'
                  GROUP BY zib.organizationId,
                           zib.warehouseId,
                           zib.customerId,
                           zib.locationId,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           zib.StockDate,
                           zib.sku,
                           zib.SKUDesc,
                           zib.UOM,
                           zib.lotNum,
                           zib.packkey,
                           zib.traceId,
                           zib.freightClass;
              END;
            WHEN R_billMode = 'INPL' THEN  -- GET STORAGE FROM OPENING INVENTORY with HANDLING IN WITH  MUID
              BEGIN
                INSERT INTO TMP_BIL_SUMMARY_INFORMATION
                  SELECT
                    zib.organizationId,
                    zib.warehouseId,
                    zib.customerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    StockDate,
                    zib.locationId,
                    IFNULL(bl.locationCategory, '') LocationCategory,
                    IFNULL(bl.zoneId, '') AS zoneId,
                    zib.traceId,
                    zib.muid,
                    zib.lotNum,
                    zib.sku,
                    SUM(qtyonHand),
                    zib.packkey,
                    zib.UOM,
                    SUM(qtyallocated),
                    SUM(qtyonHold),
                    SUM(qtyavailable),
                    SUM(qtyPicked),
                    1 palletUsed,
                    SKUDesc,
                    SUM(CUBE),
                    SUM(totalCube),
                    SUM(grossWeight),
                    SUM(netWeight),
                    freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM Z_InventoryBalance zib
                    LEFT JOIN INV_LOT_ATT ila
                      ON ila.organizationId = zib.organizationId
                      AND ila.lotNum = zib.LotNumLEFT
                    JOIN BAS_LOCATION bl
                      ON bl.organizationId = zib.organizationId
                      AND bl.warehouseId = zib.warehouseId
                      AND bl.locationId = zib.locationId
                    LEFT JOIN BAS_LOCGROUP1 bl1
                      ON bl1.organizationId = bl.organizationId
                      AND bl1.warehouseId = bl.warehouseId
                      AND bl1.locGroup1 = bl.locGroup1
                    LEFT JOIN BAS_SKU_MULTIWAREHOUSE bsm
                      ON (
                      bsm.organizationId = zib.organizationId
                      AND bsm.warehouseId = zib.warehouseId
                      AND bsm.customerId = zib.customerId
                      AND bsm.SKU = zib.sku
                      AND bsm.tariffMasterId = R_TARIFFMASTERID
                      )
                  WHERE zib.organizationId = R_ORGANIZATIONID
                  AND zib.warehouseId = R_WAREHOUSEID
                  AND zib.customerId = R_CUSTOMERID
                  AND bsm.tariffMasterId = R_TARIFFMASTERID
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  AND tb.muid NOT IN ('*', '', ' ')
                  AND ila.lotAtt07 = 'R'
                  AND zib.StockDate = R_OPDATE
                  GROUP BY zib.organizationId,
                           zib.warehouseId,
                           zib.locationId,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           zib.customerId,
                           zib.StockDate,
                           zib.sku,
                           zib.SKUDesc,
                           zib.UOM,
                           zib.lotNum,
                           zib.packkey,
                           zib.traceId,
                           zib.muid,
                           zib.freightClass
                  UNION ALL
                  SELECT
                    atl.organizationId,
                    atl.warehouseId,
                    atl.toCustomerId customerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    ila.lotAtt03 AS StockDate,
                    atl.toLocation AS LocationId,
                    IFNULL(bl.locationCategory, '') LocationCategory,
                    IFNULL(bl.zoneId, '') AS zoneId,
                    atl.toId traceId,
                    atl.toMuid muid,
                    ila.lotNum,
                    atl.toSku,
                    SUM(atl.toQty_Each),
                    atl.toPackId packkey,
                    atl.toUom UOM,
                    0 qtyallocated,
                    0 qtyonHold,
                    0 qtyavailable,
                    0 qtyPicked,
                    1 palletUsed,
                    bs.skuDescr1 AS SKUDesc,
                    SUM(CUBE),
                    SUM(atl.totalCubic),
                    SUM(grossWeight),
                    SUM(netWeight),
                    '' freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM ACT_TRANSACTION_LOG atl
                    LEFT JOIN INV_LOT_ATT ila
                      ON ila.organizationId = zib.organizationId
                      AND ila.lotNum = zib.LotNumLEFT
                    JOIN BAS_LOCATION bl
                      ON bl.organizationId = bl.organizationId
                      AND bl.warehouseId = atl.toWarehouse
                      AND bl.locationId = atl.toLocation
                    LEFT JOIN BAS_LOCGROUP1 bl1
                      ON bl1.organizationId = bl.organizationId
                      AND bl1.warehouseId = bl.warehouseId
                      AND bl1.locGroup1 = bl.locGroup1
                    LEFT JOIN BAS_SKU bs
                      ON bs.organizationId = atl.organizationId
                      AND bs.customerId = bs.customerId
                      AND bs.sku = atl.fmSku
                  WHERE ila.lotAtt03 >= R_FMDATE
                  AND ila.lotAtt03 <= R_TODATE
                  AND ila.lotAtt03 IS NOT NULL
                  AND atl.status = '99'
                  AND atl.transactionType = 'IN'
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  AND atl.toMuid NOT IN ('*', '', ' ')
                  AND ila.lotAtt07 = 'R'
                  GROUP BY atl.organizationId,
                           atl.warehouseId,
                           atl.toCustomerId,
                           atl.toLocation,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           atl.toSku,
                           bs.skuDescr1,
                           atl.toUom,
                           ila.lotAtt03,
                           atl.toPackId,
                           atl.toLotNum,
                           atl.toId,
                           atl.toMuid;
              END;
            WHEN R_billMode IN ('MAXPL', 'MONTHPL') THEN BEGIN
                INSERT INTO TMP_BIL_SUMMARY_INFORMATION
                  SELECT
                    zib.organizationId,
                    zib.warehouseId,
                    zib.customerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    StockDate,
                    zib.locationId,
                    IFNULL(bl.locationCategory, ''),
                    IFNULL(bl.zoneId, '') AS zoneId,
                    '' traceId,
                    zib.muid,
                    zib.lotNum,
                    zib.sku,
                    SUM(qtyonHand),
                    packkey,
                    UOM,
                    SUM(qtyallocated),
                    SUM(qtyonHold),
                    SUM(qtyavailable),
                    SUM(qtyPicked),
                    1 palletUsed,
                    SKUDesc,
                    SUM(CUBE),
                    SUM(totalCube),
                    SUM(grossWeight),
                    SUM(netWeight),
                    freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM Z_InventoryBalance zib
                    LEFT JOIN BAS_LOCATION bl
                      ON bl.organizationId = zib.organizationId
                      AND bl.warehouseId = zib.warehouseId
                      AND bl.locationId = zib.locationId
                    LEFT JOIN BAS_LOCGROUP1 bl1
                      ON bl1.organizationId = bl.organizationId
                      AND bl1.warehouseId = bl.warehouseId
                      AND bl1.locGroup1 = bl.locGroup1
                    LEFT JOIN INV_LOT_ATT ila
                      ON ila.organizationId = zib.organizationId
                      AND ila.customerId = zib.customerId
                      AND ila.sku = zib.sku
                      AND ila.lotNum = zib.lotNum
                    LEFT JOIN BAS_SKU_MULTIWAREHOUSE bsm
                      ON (
                      bsm.organizationId = zib.organizationId
                      AND bsm.warehouseId = zib.warehouseId
                      AND bsm.customerId = zib.customerId
                      AND bsm.SKU = zib.sku
                      AND bsm.tariffMasterId = R_TARIFFMASTERID
                      )
                  WHERE zib.organizationId = R_ORGANIZATIONID
                  AND zib.warehouseId = R_WAREHOUSEID
                  AND zib.customerId = R_CUSTOMERID
                  AND bsm.tariffMasterId = R_TARIFFMASTERID
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  AND ila.lotAtt07 = 'R'
                  GROUP BY zib.organizationId,
                           zib.warehouseId,
                           zib.customerId,
                           zib.locationId,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           zib.StockDate,
                           zib.sku,
                           zib.SKUDesc,
                           zib.UOM,
                           zib.lotNum,
                           zib.packkey,
                           zib.muid,
                           zib.freightClass;
              END;
            WHEN R_billMode = 'INLOC' THEN  -- GET STORAGE FROM OPENING INVENTORY with HANDLING IN WITH LOCATION
              BEGIN
                INSERT INTO TMP_BIL_SUMMARY_INFORMATION
                  SELECT
                    zib.organizationId,
                    zib.warehouseId,
                    zib.customerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    StockDate,
                    zib.locationId,
                    IFNULL(bl.locationCategory, '') LocationCategory,
                    IFNULL(bl.zoneId, '') AS zoneId,
                    zib.traceId,
                    zib.muid,
                    zib.lotNum,
                    zib.sku,
                    SUM(qtyonHand),
                    zib.packkey,
                    zib.UOM,
                    SUM(qtyallocated),
                    SUM(qtyonHold),
                    SUM(qtyavailable),
                    SUM(qtyPicked),
                    1 palletUsed,
                    SKUDesc,
                    SUM(CUBE),
                    SUM(totalCube),
                    SUM(grossWeight),
                    SUM(netWeight),
                    freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM Z_InventoryBalance zib
                    LEFT JOIN INV_LOT_ATT ila
                      ON ila.organizationId = zib.organizationId
                      AND ila.lotNum = zib.LotNumLEFT
                    JOIN BAS_LOCATION bl
                      ON bl.organizationId = zib.organizationId
                      AND bl.warehouseId = zib.warehouseId
                      AND bl.locationId = zib.locationId
                    LEFT JOIN BAS_LOCGROUP1 bl1
                      ON bl1.organizationId = bl.organizationId
                      AND bl1.warehouseId = bl.warehouseId
                      AND bl1.locGroup1 = bl.locGroup1
                    LEFT JOIN BAS_SKU_MULTIWAREHOUSE bsm
                      ON (
                      bsm.organizationId = zib.organizationId
                      AND bsm.warehouseId = zib.warehouseId
                      AND bsm.customerId = zib.customerId
                      AND bsm.SKU = zib.sku
                      AND bsm.tariffMasterId = R_TARIFFMASTERID
                      )
                  WHERE zib.organizationId = R_ORGANIZATIONID
                  AND zib.warehouseId = R_WAREHOUSEID
                  AND zib.customerId = R_CUSTOMERID
                  AND bsm.tariffMasterId = R_TARIFFMASTERID
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  AND ila.lotAtt07 = 'R'
                  AND zib.StockDate = R_OPDATE
                  GROUP BY zib.organizationId,
                           zib.warehouseId,
                           zib.locationId,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           zib.customerId,
                           zib.StockDate,
                           zib.sku,
                           zib.skuDesc,
                           zib.UOM,
                           zib.lotNum,
                           zib.packkey,
                           zib.traceId,
                           zib.muid,
                           zib.freightClass
                  UNION ALL
                  SELECT
                    atl.organizationId,
                    atl.warehouseId,
                    atl.toCustomerId customerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    ila.lotAtt03 AS StockDate,
                    atl.toLocation AS LocationId,
                    IFNULL(bl.locationCategory, '') LocationCategory,
                    IFNULL(bl.zoneId, '') AS zoneId,
                    atl.toId traceId,
                    atl.toMuid muid,
                    ila.lotNum,
                    atl.toSku,
                    SUM(atl.toQty_Each),
                    atl.toPackId packkey,
                    atl.toUom UOM,
                    0 qtyallocated,
                    0 qtyonHold,
                    0 qtyavailable,
                    0 qtyPicked,
                    1 palletUsed,
                    bs.skuDescr1 AS SKUDesc,
                    SUM(CUBE),
                    SUM(atl.totalCubic),
                    SUM(grossWeight),
                    SUM(netWeight),
                    '' freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM ACT_TRANSACTION_LOG atl
                    LEFT JOIN INV_LOT_ATT ila
                      ON ila.organizationId = atl.organizationId
                      AND ila.lotNum = atl.toLotNum
                    LEFT JOIN BAS_LOCATION bl
                      ON bl.organizationId = bl.organizationId
                      AND bl.warehouseId = atl.toWarehouse
                      AND bl.locationId = atl.toLocation
                    LEFT JOIN BAS_LOCGROUP1 bl1
                      ON bl1.organizationId = bl.organizationId
                      AND bl1.warehouseId = bl.warehouseId
                      AND bl1.locGroup1 = bl.locGroup1
                    LEFT JOIN BAS_SKU bs
                      ON bs.organizationId = atl.organizationId
                      AND bs.customerId = bs.customerId
                      AND bs.sku = atl.fmSku
                  WHERE ila.lotAtt03 >= R_FMDATE
                  AND ila.lotAtt03 <= R_TODATE
                  AND ila.lotAtt03 IS NOT NULL
                  AND atl.status = '99'
                  AND atl.transactionType = 'IN'
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  AND ila.lotAtt07 = 'R'
                  GROUP BY atl.organizationId,
                           atl.warehouseId,
                           atl.toCustomerId,
                           atl.toLocation,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           atl.toSku,
                           bs.skuDescr1,
                           atl.toUom,
                           ila.lotAtt03,
                           atl.toPackId,
                           atl.toLotNum,
                           atl.toId,
                           atl.toMuid;
              END;
            WHEN R_billMode IN ('MAXLOC', 'MONTHLOC') THEN BEGIN
                INSERT INTO TMP_BIL_SUMMARY_INFORMATION
                  SELECT
                    zib.organizationId,
                    zib.warehouseId,
                    zib.customerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    StockDate,
                    zib.locationId,
                    IFNULL(bl.locationCategory, ''),
                    IFNULL(bl.zoneId, '') AS zoneId,
                    '' traceId,
                    '' muid,
                    zib.lotNum,
                    zib.sku,
                    SUM(qtyonHand),
                    packkey,
                    'PL' UOM,
                    SUM(qtyallocated),
                    SUM(qtyonHold),
                    SUM(qtyavailable),
                    SUM(qtyPicked),
                    1 palletUsed,
                    SKUDesc,
                    SUM(CUBE),
                    SUM(totalCube),
                    SUM(grossWeight),
                    SUM(netWeight),
                    freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM Z_InventoryBalance zib
                    LEFT JOIN BAS_LOCATION bl
                      ON bl.organizationId = zib.organizationId
                      AND bl.warehouseId = zib.warehouseId
                      AND bl.locationId = zib.locationId
                    LEFT JOIN BAS_LOCGROUP1 bl1
                      ON bl1.organizationId = bl.organizationId
                      AND bl1.warehouseId = bl.warehouseId
                      AND bl1.locGroup1 = bl.locGroup1
                    LEFT JOIN INV_LOT_ATT ila
                      ON ila.organizationId = zib.organizationId
                      AND ila.customerId = zib.customerId
                      AND ila.sku = zib.sku
                      AND ila.lotNum = zib.lotNum
                    LEFT JOIN BAS_SKU_MULTIWAREHOUSE bsm
                      ON (
                      bsm.organizationId = zib.organizationId
                      AND bsm.warehouseId = zib.warehouseId
                      AND bsm.customerId = zib.customerId
                      AND bsm.SKU = zib.sku
                      AND bsm.tariffMasterId = R_TARIFFMASTERID
                      )
                  WHERE zib.organizationId = R_ORGANIZATIONID
                  AND zib.warehouseId = R_WAREHOUSEID
                  AND zib.customerId = R_CUSTOMERID
                  AND bsm.tariffMasterId = R_TARIFFMASTERID
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  AND ila.lotAtt07 = 'R'
                  GROUP BY zib.organizationId,
                           zib.warehouseId,
                           zib.customerId,
                           zib.locationId,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           zib.StockDate,
                           zib.sku,
                           zib.SKUDesc,
                           zib.UOM,
                           zib.lotNum,
                           zib.packkey,
                           zib.freightClass;
              END;
            WHEN R_billMode = 'DAILYCBM' THEN -- Daily accumulated CBM
              BEGIN
                INSERT INTO TMP_BIL_SUMMARY_INFORMATION
                  SELECT
                    zib.organizationId,
                    zib.warehouseId,
                    zib.customerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    StockDate,
                    zib.locationId,
                    IFNULL(bl.locationCategory, '') LocationCategory,
                    IFNULL(bl.zoneId, '') AS zoneId,
                    zib.traceId,
                    zib.muid,
                    zib.lotNum,
                    zib.sku,
                    SUM(qtyonHand),
                    packkey,
                    UOM,
                    SUM(qtyallocated),
                    SUM(qtyonHold),
                    SUM(qtyavailable),
                    SUM(qtyPicked),
                    1 palletUsed,
                    SKUDesc,
                    SUM(CUBE),
                    SUM(totalCube),
                    SUM(grossWeight),
                    SUM(netWeight),
                    freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM Z_InventoryBalance zib
                    LEFT JOIN BAS_LOCATION bl
                      ON bl.organizationId = zib.organizationId
                      AND bl.warehouseId = zib.warehouseId
                      AND bl.locationId = zib.locationId
                    LEFT JOIN BAS_LOCGROUP1 bl1
                      ON bl1.organizationId = bl.organizationId
                      AND bl1.warehouseId = bl.warehouseId
                      AND bl1.locGroup1 = bl.locGroup1
                  WHERE zib.StockDate >= R_FMDATE
                  AND zib.StockDate <= R_TODATE
                  AND zib.organizationId = R_ORGANIZATIONID
                  AND zib.warehouseId = R_WAREHOUSEID
                  AND zib.customerId = R_CUSTOMERID
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  GROUP BY zib.organizationId,
                           zib.warehouseId,
                           zib.customerId,
                           zib.locationId,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           zib.StockDate,
                           zib.sku,
                           zib.SKUDesc,
                           zib.UOM,
                           zib.lotNum,
                           zib.packkey,
                           zib.traceId,
                           zib.muid,
                           zib.freightClass,
                           bl.locationCategory;
              END;
            ELSE SELECT
                'BILLING METHOD FOR PALLET RENTAL NOT FOUND' AS MESSAGE;
          END CASE;
        ELSE
        ## GET STORAGE FROM INVENTORY
        BEGIN
          CASE
            WHEN R_billMode = 'INTRACE' THEN  -- GET STORAGE FROM OPENING INVENTORY with HANDLING IN
              BEGIN
                INSERT INTO TMP_BIL_SUMMARY_INFORMATION
                  SELECT
                    zib.organizationId,
                    zib.warehouseId,
                    zib.customerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    StockDate,
                    zib.locationId,
                    IFNULL(bl.locationCategory, '') LocationCategory,
                    IFNULL(bl.zoneId, '') AS zoneId,
                    zib.traceId,
                    zib.muid,
                    zib.lotNum,
                    zib.sku,
                    SUM(qtyonHand),
                    zib.packkey,
                    zib.UOM,
                    SUM(qtyallocated),
                    SUM(qtyonHold),
                    SUM(qtyavailable),
                    SUM(qtyPicked),
                    1 palletUsed,
                    zib.SKUDesc,
                    SUM(CUBE),
                    SUM(totalCube),
                    SUM(grossWeight),
                    SUM(netWeight),
                    freightClass,
                    IN_USERID addWho,
                    CURDATE() ADDTIME,
                    IN_USERID editWho,
                    CURDATE() editTime
                  FROM Z_InventoryBalance zib
                    LEFT JOIN BAS_LOCATION bl
                      ON bl.organizationId = zib.organizationId
                      AND bl.warehouseId = zib.warehouseId
                      AND bl.locationId = zib.locationId
                    LEFT JOIN BAS_SKU_MULTIWAREHOUSE bsm
                      ON (
                      bsm.organizationId = zib.organizationId
                      AND bsm.warehouseId = zib.warehouseId
                      AND bsm.customerId = zib.customerId
                      AND bsm.SKU = zib.sku
                      AND bsm.tariffMasterId = R_TARIFFMASTERID
                      )
                  WHERE zib.organizationId = R_ORGANIZATIONID
                  AND zib.warehouseId = R_WAREHOUSEID
                  AND zib.customerId = R_CUSTOMERID
                  AND zib.StockDate = R_OPDATE
                  AND bsm.tariffMasterId = R_TARIFFMASTERID
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  AND TRACEID NOT IN ('*')
                  -- AND MUID IN ('*')                                         
                  GROUP BY zib.organizationId,
                           zib.warehouseId,
                           zib.customerId,
                           zib.locationId,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           zib.StockDate,
                           zib.sku,
                           zib.SKUDesc,
                           zib.UOM,
                           zib.lotNum,
                           zib.packkey,
                           zib.traceId,
                           zib.muid,
                           zib.freightClass
                  UNION ALL
                  SELECT
                    atl.organizationId,
                    atl.warehouseId,
                    atl.toCustomerId CustomerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    ila.lotAtt03 AS StockDate,
                    atl.toLocation AS locationId,
                    IFNULL(bl.locationCategory, '') LocationCategory,
                    IFNULL(bl.zoneId, '') AS zoneId,
                    atl.toId traceId,
                    '' muid,
                    atl.toLotNum lotNum,
                    atl.toSku sku,
                    SUM(atl.toQty) qtyOnHand,
                    atl.toPackId packkey,
                    atl.toUom UOM,
                    0 qtyallocated,
                    0 qtyonHold,
                    0 qtyavailable,
                    0 qtyPicked,
                    1 palletUsed,
                    bs.skuDescr1 SKUDesc,
                    SUM(bs.cube),
                    SUM(atl.totalCubic),
                    SUM(bs.grossWeight * atl.toQty_Each),
                    SUM(bs.netWeight * atl.toQty_Each),
                    '' freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM ACT_TRANSACTION_LOG atl
                    LEFT JOIN INV_LOT_ATT ila
                      ON ila.organizationId = atl.organizationId
                      AND ila.lotNum = atl.toLotNum
                    LEFT JOIN BAS_LOCATION bl
                      ON bl.organizationId = atl.organizationId
                      AND bl.warehouseId = atl.toWarehouse
                      AND bl.locationId = atl.toLocation
                    LEFT JOIN BAS_LOCGROUP1 bl1
                      ON bl1.organizationId = bl.organizationId
                      AND bl1.warehouseId = bl.warehouseId
                      AND bl1.locGroup1 = bl.locGroup1
                    LEFT JOIN BAS_SKU bs
                      ON bs.organizationId = atl.organizationId
                      AND bs.customerId = atl.toCustomerId
                      AND bs.sku = atl.toSku
                  WHERE ila.lotAtt03 >= R_FMDATE
                  AND ila.lotAtt03 <= R_TODATE
                  AND ila.lotAtt03 IS NOT NULL
                  AND atl.toCustomerId = R_CUSTOMERID
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  AND atl.toId NOT IN ('*')
                  -- AND atl.toMuid IN ('*') 
                  AND atl.status = '99'
                  AND atl.transactionType = 'IN'
                  GROUP BY atl.organizationId,
                           atl.warehouseId,
                           atl.toCustomerId,
                           atl.toLocation,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           atl.toSku,
                           bs.skuDescr1,
                           atl.toUom,
                           ila.lotAtt03,
                           atl.toPackId,
                           atl.toLotNum,
                           atl.toId;
              END;
            WHEN R_billMode IN ('MAXTRACE', 'DAILYTRACE', 'MONTHTRACE') THEN BEGIN
                INSERT INTO TMP_BIL_SUMMARY_INFORMATION
                  SELECT
                    zib.organizationId,
                    zib.warehouseId,
                    zib.customerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    zib.StockDate,
                    zib.locationId,
                    IFNULL(bl.locationCategory, '') LocationCategory,
                    IFNULL(bl.zoneId, '') AS zoneId,
                    zib.traceId,
                    zib.muid,
                    zib.lotNum,
                    zib.sku,
                    SUM(qtyonHand),
                    zib.packkey,
                    zib.UOM,
                    SUM(qtyallocated),
                    SUM(qtyonHold),
                    SUM(qtyavailable),
                    SUM(qtyPicked),
                    1 palletUsed,
                    SKUDesc,
                    SUM(CUBE),
                    SUM(totalCube),
                    SUM(grossWeight),
                    SUM(netWeight),
                    freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM Z_InventoryBalance zib
                    LEFT JOIN BAS_LOCATION bl
                      ON bl.organizationId = zib.organizationId
                      AND bl.warehouseId = zib.warehouseId
                      AND bl.locationId = zib.locationId
                    LEFT JOIN BAS_LOCGROUP1 bl1
                      ON bl1.organizationId = bl.organizationId
                      AND bl1.warehouseId = bl.warehouseId
                      AND bl1.locGroup1 = bl.locGroup1
                    LEFT JOIN BAS_SKU_MULTIWAREHOUSE bsm
                      ON (
                      bsm.organizationId = zib.organizationId
                      AND bsm.warehouseId = zib.warehouseId
                      AND bsm.customerId = zib.customerId
                      AND bsm.SKU = zib.sku
                      AND bsm.tariffMasterId = R_TARIFFMASTERID
                      )
                  WHERE zib.organizationId = R_ORGANIZATIONID
                  AND zib.warehouseId = R_WAREHOUSEID
                  AND zib.customerId = R_CUSTOMERID
                  AND bsm.tariffMasterId = R_TARIFFMASTERID
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  AND TRACEID NOT IN ('*')
                  -- AND MUID IN ('*')
                  AND zib.StockDate >= R_FMDATE
                  AND zib.StockDate <= R_TODATE
                  GROUP BY zib.organizationId,
                           zib.warehouseId,
                           bsm.tariffMasterId,
                           zib.customerId,
                           zib.locationId,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           zib.StockDate,
                           zib.sku,
                           zib.SKUDesc,
                           zib.UOM,
                           zib.lotNum,
                           zib.packkey,
                           zib.traceId,
                           zib.muid,
                           zib.freightClass;
              END;
            WHEN R_billMode = 'INPL' THEN BEGIN
                INSERT INTO TMP_BIL_SUMMARY_INFORMATION
                  SELECT
                    zib.organizationId,
                    zib.warehouseId,
                    zib.customerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    StockDate,
                    zib.locationId,
                    IFNULL(bl.locationCategory, '') LocationCategory,
                    IFNULL(bl.zoneId, '') AS zoneId,
                    zib.traceId,
                    zib.muid,
                    zib.lotNum,
                    zib.sku,
                    SUM(qtyonHand),
                    zib.packkey,
                    zib.UOM,
                    SUM(qtyallocated),
                    SUM(qtyonHold),
                    SUM(qtyavailable),
                    SUM(qtyPicked),
                    1 palletUsed,
                    zib.SKUDesc,
                    SUM(CUBE),
                    SUM(totalCube),
                    SUM(grossWeight),
                    SUM(netWeight),
                    freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM Z_InventoryBalance zib
                    LEFT JOIN BAS_LOCATION bl
                      ON bl.organizationId = zib.organizationId
                      AND bl.warehouseId = zib.warehouseId
                      AND bl.locationId = zib.locationId
                    LEFT JOIN BAS_SKU_MULTIWAREHOUSE bsm
                      ON (
                      bsm.organizationId = zib.organizationId
                      AND bsm.warehouseId = zib.warehouseId
                      AND bsm.customerId = zib.customerId
                      AND bsm.SKU = zib.sku
                      AND bsm.tariffMasterId = R_TARIFFMASTERID
                      )
                  WHERE zib.organizationId = R_ORGANIZATIONID
                  AND zib.warehouseId = R_WAREHOUSEID
                  AND zib.customerId = R_CUSTOMERID
                  AND zib.StockDate = R_OPDATE
                  AND bsm.tariffMasterId = R_TARIFFMASTERID
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  AND MUID NOT IN ('*')
                  GROUP BY zib.organizationId,
                           zib.warehouseId,
                           zib.customerId,
                           zib.locationId,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           zib.StockDate,
                           zib.sku,
                           zib.SKUDesc,
                           zib.UOM,
                           zib.lotNum,
                           zib.packkey,
                           zib.traceId,
                           zib.muid,
                           zib.freightClass
                  UNION ALL
                  SELECT
                    atl.organizationId,
                    atl.warehouseId,
                    atl.toCustomerId CustomerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    ila.lotAtt03 AS StockDate,
                    atl.toLocation AS locationId,
                    IFNULL(bl.locationCategory, '') LocationCategory,
                    IFNULL(bl.zoneId, '') AS zoneId,
                    atl.toId traceId,
                    atl.toMuid muid,
                    atl.toLotNum lotNum,
                    atl.toSku sku,
                    SUM(atl.toQty) qtyOnHand,
                    atl.toPackId packkey,
                    atl.toUom UOM,
                    0 qtyallocated,
                    0 qtyonHold,
                    0 qtyavailable,
                    0 qtyPicked,
                    1 palletUsed,
                    bs.skuDescr1 SKUDesc,
                    SUM(bs.cube),
                    SUM(atl.totalCubic),
                    SUM(bs.grossWeight * atl.toQty_Each),
                    SUM(bs.netWeight * atl.toQty_Each),
                    '' freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM ACT_TRANSACTION_LOG atl
                    LEFT JOIN INV_LOT_ATT ila
                      ON ila.organizationId = atl.organizationId
                      AND ila.lotNum = atl.toLotNum
                    LEFT JOIN BAS_LOCATION bl
                      ON bl.organizationId = atl.organizationId
                      AND bl.warehouseId = atl.toWarehouse
                      AND bl.locationId = atl.toLocation
                    LEFT JOIN BAS_LOCGROUP1 bl1
                      ON bl1.organizationId = bl.organizationId
                      AND bl1.warehouseId = bl.warehouseId
                      AND bl1.locGroup1 = bl.locGroup1
                    LEFT JOIN BAS_SKU bs
                      ON bs.organizationId = atl.organizationId
                      AND bs.customerId = atl.toCustomerId
                      AND bs.sku = atl.toSku
                  WHERE ila.lotAtt03 >= R_FMDATE
                  AND ila.lotAtt03 <= R_TODATE
                  AND ila.lotAtt03 IS NOT NULL
                  AND atl.toCustomerId = R_CUSTOMERID
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  AND atl.toMuid NOT IN ('*')
                  AND atl.status = '99'
                  AND atl.transactionType = 'IN'
                  GROUP BY atl.organizationId,
                           atl.warehouseId,
                           atl.toCustomerId,
                           atl.toLocation,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           atl.toSku,
                           bs.skuDescr1,
                           atl.toUom,
                           ila.lotAtt03,
                           atl.toPackId,
                           atl.toLotNum,
                           atl.toId,
                           atl.toMuid;
              END;
            WHEN R_billMode IN ('MAXPL', 'MONTHPL') THEN BEGIN
                INSERT INTO TMP_BIL_SUMMARY_INFORMATION
                  SELECT
                    zib.organizationId,
                    zib.warehouseId,
                    zib.customerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    StockDate,
                    zib.locationId,
                    IFNULL(bl.locationCategory, '') LocationCategory,
                    IFNULL(bl.zoneId, '') AS zoneId,
                    zib.traceId,
                    zib.muid,
                    zib.lotNum,
                    zib.sku,
                    SUM(qtyonHand),
                    packkey,
                    UOM,
                    SUM(qtyallocated),
                    SUM(qtyonHold),
                    SUM(qtyavailable),
                    SUM(qtyPicked),
                    1 palletUsed,
                    SKUDesc,
                    SUM(CUBE),
                    SUM(totalCube),
                    SUM(grossWeight),
                    SUM(netWeight),
                    freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM Z_InventoryBalance zib
                    LEFT JOIN BAS_LOCATION bl
                      ON bl.organizationId = zib.organizationId
                      AND bl.warehouseId = zib.warehouseId
                      AND bl.locationId = zib.locationId
                    LEFT JOIN BAS_LOCGROUP1 bl1
                      ON bl1.organizationId = bl.organizationId
                      AND bl1.warehouseId = bl.warehouseId
                      AND bl1.locGroup1 = bl.locGroup1
                    LEFT JOIN BAS_SKU_MULTIWAREHOUSE bsm
                      ON (
                      bsm.organizationId = zib.organizationId
                      AND bsm.warehouseId = zib.warehouseId
                      AND bsm.customerId = zib.customerId
                      AND bsm.SKU = zib.sku
                      AND bsm.tariffMasterId = R_TARIFFMASTERID
                      )
                  WHERE zib.organizationId = R_ORGANIZATIONID
                  AND zib.warehouseId = R_WAREHOUSEID
                  AND zib.customerId = R_CUSTOMERID
                  AND bsm.tariffMasterId = R_TARIFFMASTERID
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  AND zib.StockDate >= R_FMDATE
                  AND zib.StockDate <= R_TODATE
                  AND MUID NOT IN ('*')
                  GROUP BY zib.organizationId,
                           zib.warehouseId,
                           bsm.tariffMasterId,
                           zib.customerId,
                           zib.locationId,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           zib.StockDate,
                           zib.sku,
                           zib.SKUDesc,
                           zib.UOM,
                           zib.lotNum,
                           zib.packkey,
                           zib.traceId,
                           zib.muid,
                           zib.freightClass;
              END;
            WHEN R_billMode = 'INLOC' THEN BEGIN
                INSERT INTO TMP_BIL_SUMMARY_INFORMATION
                  SELECT
                    zib.organizationId,
                    zib.warehouseId,
                    zib.customerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    StockDate,
                    zib.locationId,
                    IFNULL(bl.locationCategory, '') LocationCategory,
                    IFNULL(bl.zoneId, '') AS zoneId,
                    zib.traceId,
                    zib.muid,
                    zib.lotNum,
                    zib.sku,
                    SUM(qtyonHand),
                    zib.packkey,
                    zib.UOM,
                    SUM(qtyallocated),
                    SUM(qtyonHold),
                    SUM(qtyavailable),
                    SUM(qtyPicked),
                    1 palletUsed,
                    SKUDesc,
                    SUM(CUBE),
                    SUM(totalCube),
                    SUM(grossWeight),
                    SUM(netWeight),
                    freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM Z_InventoryBalance zib
                    LEFT JOIN BAS_LOCATION bl
                      ON bl.organizationId = zib.organizationId
                      AND bl.warehouseId = zib.warehouseId
                      AND bl.locationId = zib.locationId
                    LEFT JOIN BAS_SKU_MULTIWAREHOUSE bsm
                      ON (
                      bsm.organizationId = zib.organizationId
                      AND bsm.warehouseId = zib.warehouseId
                      AND bsm.customerId = zib.customerId
                      AND bsm.SKU = zib.sku
                      AND bsm.tariffMasterId = R_TARIFFMASTERID
                      )
                  WHERE zib.organizationId = R_ORGANIZATIONID
                  AND zib.warehouseId = R_WAREHOUSEID
                  AND zib.customerId = R_CUSTOMERID
                  AND zib.StockDate = R_OPDATE
                  AND bsm.tariffMasterId = R_TARIFFMASTERID
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  GROUP BY zib.organizationId,
                           zib.warehouseId,
                           zib.customerId,
                           zib.locationId,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           zib.StockDate,
                           zib.sku,
                           zib.SKUDesc,
                           zib.UOM,
                           zib.lotNum,
                           zib.packkey,
                           zib.traceId,
                           zib.muid,
                           zib.freightClass
                  UNION ALL
                  SELECT
                    atl.organizationId,
                    atl.warehouseId,
                    atl.toCustomerId CustomerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    ila.lotAtt03 AS StockDate,
                    atl.toLocation AS locationId,
                    IFNULL(bl.locationCategory, '') LocationCategory,
                    IFNULL(bl.zoneId, '') AS zoneId,
                    atl.toId traceId,
                    '' muid,
                    atl.toLotNum lotNum,
                    atl.toSku sku,
                    SUM(atl.toQty) qtyOnHand,
                    atl.toPackId packkey,
                    atl.toUom UOM,
                    0 qtyallocated,
                    0 qtyonHold,
                    0 qtyavailable,
                    0 qtyPicked,
                    1 palletUsed,
                    bs.skuDescr1 SKUDesc,
                    SUM(bs.cube),
                    SUM(atl.totalCubic),
                    SUM(bs.grossWeight * atl.toQty_Each),
                    SUM(bs.netWeight * atl.toQty_Each),
                    '' freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM ACT_TRANSACTION_LOG atl
                    LEFT JOIN INV_LOT_ATT ila
                      ON ila.organizationId = atl.organizationId
                      AND ila.lotNum = atl.toLotNum
                    LEFT JOIN BAS_LOCATION bl
                      ON bl.organizationId = atl.organizationId
                      AND bl.warehouseId = atl.toWarehouse
                      AND bl.locationId = atl.toLocation
                    LEFT JOIN BAS_LOCGROUP1 bl1
                      ON bl1.organizationId = bl.organizationId
                      AND bl1.warehouseId = bl.warehouseId
                      AND bl1.locGroup1 = bl.locGroup1
                    LEFT JOIN BAS_SKU bs
                      ON bs.organizationId = atl.organizationId
                      AND bs.customerId = atl.toCustomerId
                      AND bs.sku = atl.toSku
                  WHERE ila.lotAtt03 >= R_FMDATE
                  AND ila.lotAtt03 <= R_TODATE
                  AND ila.lotAtt03 IS NOT NULL
                  AND atl.toCustomerId = R_CUSTOMERID
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  AND atl.status = '99'
                  AND atl.transactionType = 'IN'
                  GROUP BY atl.organizationId,
                           atl.warehouseId,
                           atl.toCustomerId,
                           atl.toLocation,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           atl.toSku,
                           bs.skuDescr1,
                           atl.toUom,
                           ila.lotAtt03,
                           atl.toPackId,
                           atl.toLotNum,
                           atl.toId;
              END;
            WHEN R_billMode IN ('MAXLOC', 'MONTHLOC') THEN BEGIN
                INSERT INTO TMP_BIL_SUMMARY_INFORMATION
                  SELECT
                    zib.organizationId,
                    zib.warehouseId,
                    zib.customerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    StockDate,
                    zib.locationId,
                    IFNULL(bl.locationCategory, '') LocationCategory,
                    IFNULL(bl.zoneId, '') AS zoneId,
                    zib.traceId,
                    zib.muid,
                    zib.lotNum,
                    zib.sku,
                    SUM(qtyonHand),
                    packkey,
                    UOM,
                    SUM(qtyallocated),
                    SUM(qtyonHold),
                    SUM(qtyavailable),
                    SUM(qtyPicked),
                    1 palletUsed,
                    SKUDesc,
                    SUM(CUBE),
                    SUM(totalCube),
                    SUM(grossWeight),
                    SUM(netWeight),
                    freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM Z_InventoryBalance zib
                    LEFT JOIN BAS_LOCATION bl
                      ON bl.organizationId = zib.organizationId
                      AND bl.warehouseId = zib.warehouseId
                      AND bl.locationId = zib.locationId
                    LEFT JOIN BAS_LOCGROUP1 bl1
                      ON bl1.organizationId = bl.organizationId
                      AND bl1.warehouseId = bl.warehouseId
                      AND bl1.locGroup1 = bl.locGroup1
                    LEFT JOIN BAS_SKU_MULTIWAREHOUSE bsm
                      ON (
                      bsm.organizationId = zib.organizationId
                      AND bsm.warehouseId = zib.warehouseId
                      AND bsm.customerId = zib.customerId
                      AND bsm.SKU = zib.sku
                      AND bsm.tariffMasterId = R_TARIFFMASTERID
                      )
                  WHERE zib.organizationId = R_ORGANIZATIONID
                  AND zib.warehouseId = R_WAREHOUSEID
                  AND zib.customerId = R_CUSTOMERID
                  AND bsm.tariffMasterId = R_TARIFFMASTERID
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  AND zib.StockDate >= R_FMDATE
                  AND zib.StockDate <= R_TODATE
                  GROUP BY zib.organizationId,
                           zib.warehouseId,
                           zib.customerId,
                           zib.locationId,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           zib.StockDate,
                           zib.sku,
                           zib.SKUDesc,
                           zib.UOM,
                           zib.lotNum,
                           zib.packkey,
                           zib.traceId,
                           zib.muid,
                           zib.freightClass;
              END;
            WHEN R_billMode = 'DAILYCBM' THEN BEGIN
                INSERT INTO TMP_BIL_SUMMARY_INFORMATION
                  SELECT
                    zib.organizationId,
                    zib.warehouseId,
                    zib.customerId,
                    '' billingSummaryId,
                    (@linenumber := @linenumber + 1) billingSummryLineNo,
                    R_tariffId,
                    R_TARIFFLINENO,
                    R_descrC,
                    r_chargeCategory,
                    R_CHARGETYPE,
                    R_ratebase,
                    R_minQty,
                    R_billMode,
                    R_rateperunit,
                    R_rate,
                    R_TARIFFCLASSNO,
                    R_CLASSFROM,
                    R_CLASSTO,
                    StockDate,
                    zib.locationId,
                    IFNULL(bl.locationCategory, '') LocationCategory,
                    IFNULL(bl.zoneId, '') AS zoneId,
                    zib.traceId,
                    zib.muid,
                    zib.lotNum,
                    zib.sku,
                    SUM(qtyonHand),
                    packkey,
                    UOM,
                    SUM(qtyallocated),
                    SUM(qtyonHold),
                    SUM(qtyavailable),
                    SUM(qtyPicked),
                    1 palletUsed,
                    SKUDesc,
                    SUM(CUBE),
                    SUM(totalCube),
                    SUM(grossWeight),
                    SUM(netWeight),
                    freightClass,
                    IN_USERID AS addWho,
                    CURDATE() ADDTIME,
                    IN_USERID AS editWho,
                    CURDATE() editTime
                  FROM Z_InventoryBalance zib
                    LEFT JOIN BAS_LOCATION bl
                      ON bl.organizationId = zib.organizationId
                      AND bl.warehouseId = zib.warehouseId
                      AND bl.locationId = zib.locationId
                    LEFT JOIN BAS_LOCGROUP1 bl1
                      ON bl1.organizationId = bl.organizationId
                      AND bl1.warehouseId = bl.warehouseId
                      AND bl1.locGroup1 = bl.locGroup1
                  WHERE zib.StockDate >= R_FMDATE
                  AND zib.StockDate <= R_TODATE
                  AND zib.organizationId = R_ORGANIZATIONID
                  AND zib.warehouseId = R_WAREHOUSEID
                  AND zib.customerId = R_CUSTOMERID
                  AND (ISNULL(R_LOCATIONCAT)
                  OR R_LOCATIONCAT = ''
                  OR bl.locationCategory = R_LOCATIONCAT)
                  AND (ISNULL(R_LOCATIONGROUP)
                  OR R_LOCATIONGROUP = ''
                  OR bl.udf05 = R_LOCATIONGROUP)
                  GROUP BY zib.organizationId,
                           zib.warehouseId,
                           zib.customerId,
                           zib.locationId,
                           bl.locationCategory,
                           bl.udf05,
                           bl.zoneId,
                           zib.StockDate,
                           zib.sku,
                           zib.SKUDesc,
                           zib.UOM,
                           zib.lotNum,
                           zib.packkey,
                           zib.traceId,
                           zib.muid,
                           zib.freightClass;
              END;
            ELSE SELECT
                'BILLING METHOD FOR NORMAL STORAGE NOT FOUND' AS MESSAGE;
          END CASE;
        END;
        END IF;

        DROP TEMPORARY TABLE IF EXISTS TMP_BIL_SUMMARY;
        CREATE TEMPORARY TABLE TMP_BIL_SUMMARY (
          organizationId varchar(20),
          warehouseId varchar(20),
          billingSummaryId varchar(30),
          customerId varchar(30),
          sku varchar(50),
          lotNum varchar(10),
          traceId varchar(30),
          tariffId varchar(10),
          chargeCategory varchar(20),
          chargeType varchar(20),
          descr varchar(60),
          rateBase varchar(20),
          chargePerUnits decimal(18, 3),
          qty decimal(18, 8),
          uom varchar(10),
          cubic decimal(24, 8),
          weight decimal(18, 8),
          chargeRate decimal(24, 8),
          locationCategory varchar(10),
          amount decimal(24, 8) NOT NULL DEFAULT 0.00000000,
          billingAmount decimal(24, 8) NOT NULL DEFAULT 0.00000000,
          udf01 varchar(500),
          udf02 varchar(500) binary DEFAULT NULL,
          udf03 varchar(500),
          udf04 varchar(500),
          udf05 varchar(500)
        );
        IF EXISTS (SELECT
              *
            FROM TMP_BIL_SUMMARY_INFORMATION) THEN
          -- SELECT * FROM TMP_BIL_SUMMARY_INFORMATION;
          /* select stockdate,sum(PalletUsed) from (
     		SELECT stockdate,traceId,1 PalletUsed FROM TMP_BIL_SUMMARY_INFORMATION
             group by stockdate,traceId
             )plt group by stockdate;
           */
          SET IN_Language = 'en';
          SET @line_number = 0;
          SET @row_number = 0;
          SET R_billsummaryId = '';


          CASE
            WHEN R_billMode IN ('INTRACE') THEN BEGIN
                INSERT INTO TMP_BIL_SUMMARY
                  SELECT
                    organizationId,
                    warehouseId,
                    R_billsummaryId,
                    customerId,
                    '' SKU,
                    '' lotNum,
                    '' traceId,
                    R_TARIFFID,
                    R_CHARGECATEGORY,
                    R_CHARGETYPE,
                    R_descrC,
                    R_ratebase,
                    R_rateperunit,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) Qty,
                    'PL' uom,
                    SUM(DailyTrace.Cube) TotalCube,
                    SUM(DailyTrace.Weight) TotalWeight,
                    R_rate,
                    DailyTrace.locationCategory,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) * R_rateperunit * R_rate Amount,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) * R_rateperunit * R_rate BillAmount,
                    R_materialNo AS UDF01,
                    R_itemChargeCategory AS UDF02,
                    '' UDF03,
                    '' UDF04,
                    '' UDF05
                  FROM (SELECT
                      organizationId,
                      warehouseId,
                      R_billsummaryId,
                      customerId,
                      '' SKU,
                      '' lotNum,
                      tb.traceId,
                      R_TARIFFID,
                      R_CHARGECATEGORY,
                      R_CHARGETYPE,
                      R_descrC,
                      R_ratebase,
                      R_rateperunit,
                      1 PalletQty,
                      'PL' uom,
                      SUM(CUBE) CUBE,
                      SUM(netWeight) Weight,
                      R_rate chargeRate,
                      '' locationCategory,
                      1 * R_rateperunit * R_rate Amount,
                      1 * R_rateperunit * R_rate BillAmount,
                      '' UDF01,
                      '' UDF02,
                      '' UDF03,
                      '' UDF04,
                      '' UDF05
                    FROM TMP_BIL_SUMMARY_INFORMATION tb
                    WHERE organizationId = R_ORGANIZATIONID
                    AND warehouseId = R_WAREHOUSEID
                    AND customerId = R_customerId
                    AND tb.traceId NOT IN ('*', '', ' ')
                    --  AND tb.muid IN ('*','',' ')
                    GROUP BY organizationId,
                             warehouseId,
                             customerId,
                             tariffId,
                             tariffLineNo,
                             StockDate,
                             traceId) DailyTrace
                  GROUP BY organizationId,
                           warehouseId,
                           customerId
                  HAVING SUM(PalletQty) > R_CLASSFROM LIMIT 1;
              END;
            WHEN R_billMode IN ('MAXTRACE') THEN BEGIN
                INSERT INTO TMP_BIL_SUMMARY
                  SELECT
                    organizationId,
                    warehouseId,
                    R_billsummaryId,
                    customerId,
                    SKU,
                    '' lotNum,
                    '' traceId,
                    R_TARIFFID,
                    R_CHARGECATEGORY,
                    R_CHARGETYPE,
                    R_descrC,
                    R_ratebase,
                    R_rateperunit,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) Qty,
                    MaxTrace.uom,
                    SUM(MaxTrace.Cube) TotalCube,
                    SUM(MaxTrace.Weight) TotalWeight,
                    R_rate,
                    MaxTrace.locationCategory,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) * R_rateperunit * R_rate Amount,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) * R_rateperunit * R_rate BillAmount,
                    R_materialNo AS UDF01,
                    R_itemChargeCategory AS UDF02,
                    MaxTrace.UDF03,
                    MaxTrace.UDF04,
                    MaxTrace.UDF05
                  FROM (SELECT
                      organizationId,
                      warehouseId,
                      R_billsummaryId,
                      customerId,
                      tb.Stockdate,
                      '' SKU,
                      '' lotNum,
                      tb.traceId traceId,
                      R_TARIFFID,
                      R_CHARGECATEGORY,
                      R_CHARGETYPE,
                      R_descrC,
                      R_ratebase,
                      R_rateperunit,
                      1 PalletQty,
                      'PL' uom,
                      SUM(CUBE) CUBE,
                      SUM(netWeight) Weight,
                      R_rate chargeRate,
                      '' locationCategory,
                      1 * R_rateperunit * R_rate Amount,
                      1 * R_rateperunit * R_rate BillAmount,
                      '' UDF01,
                      '' UDF02,
                      '' UDF03,
                      '' UDF04,
                      '' UDF05
                    FROM TMP_BIL_SUMMARY_INFORMATION tb
                    WHERE organizationId = R_ORGANIZATIONID
                    AND warehouseId = R_WAREHOUSEID
                    AND customerId = R_customerId
                    AND tb.traceId NOT IN ('*', ' ')
                    -- AND tb.muid IN ('*',' ')
                    GROUP BY organizationId,
                             warehouseId,
                             customerId,
                             tariffId,
                             tariffLineNo,
                             StockDate,
                             traceId) MaxTrace
                  GROUP BY organizationId,
                           warehouseId,
                           customerId,
                           MaxTrace.StockDate
                  HAVING SUM(PalletQty) > R_CLASSFROM
                  ORDER BY SUM(PalletQty) DESC LIMIT 1;
              END;
            WHEN R_billMode IN ('DAILYTRACE', 'MONTHTRACE') THEN BEGIN
                INSERT INTO TMP_BIL_SUMMARY
                  SELECT
                    organizationId,
                    warehouseId,
                    R_billsummaryId,
                    customerId,
                    '' SKU,
                    '' lotNum,
                    '' traceId,
                    R_TARIFFID,
                    R_CHARGECATEGORY,
                    R_CHARGETYPE,
                    R_descrC,
                    R_ratebase,
                    R_rateperunit,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) Qty,
                    'PL' uom,
                    SUM(MonthTrace.Cube) TotalCube,
                    SUM(MonthTrace.Weight) TotalWeight,
                    R_rate,
                    '' locationCategory,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) * R_rateperunit * R_rate Amount,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) * R_rateperunit * R_rate BillAmount,
                    R_materialNo AS UDF01,
                    R_itemChargeCategory AS UDF02,
                    '' UDF03,
                    '' UDF04,
                    '' UDF05
                  FROM (SELECT
                      organizationId,
                      warehouseId,
                      R_billsummaryId,
                      customerId,
                      stockdate,
                      traceid,
                      1 PalletQty,
                      SUM(CUBE) CUBE,
                      SUM(Weight) Weight
                    FROM (SELECT
                        organizationId,
                        warehouseId,
                        R_billsummaryId,
                        customerId,
                        stockdate,
                        '' SKU,
                        '' lotNum,
                        tb.traceId,
                        R_TARIFFID,
                        R_CHARGECATEGORY,
                        R_CHARGETYPE,
                        R_descrC,
                        R_ratebase,
                        R_rateperunit,
                        1 PalletQty,
                        'PL' uom,
                        CUBE,
                        netWeight Weight,
                        R_rate chargeRate,
                        '' locationCategory,
                        1 * R_rateperunit * R_rate Amount,
                        1 * R_rateperunit * R_rate BillAmount,
                        '' UDF01,
                        '' UDF02,
                        '' UDF03,
                        '' UDF04,
                        '' UDF05
                      FROM TMP_BIL_SUMMARY_INFORMATION tb
                      WHERE organizationId = R_ORGANIZATIONID
                      AND warehouseId = R_WAREHOUSEID
                      AND customerId = R_customerId
                      AND TRACEID NOT IN ('*')
                    -- AND MUID IN ('*')
                    ) inventoryPlt
                    GROUP BY organizationId,
                             warehouseId,
                             customerId,
                             stockdate,
                             traceid) MonthTrace
                  GROUP BY organizationId,
                           warehouseId,
                           customerId
                  HAVING SUM(PalletQty) > R_CLASSFROM;
              END;
            WHEN R_billMode IN ('INPL') THEN BEGIN
                INSERT INTO TMP_BIL_SUMMARY
                  SELECT
                    organizationId,
                    warehouseId,
                    R_billsummaryId,
                    customerId,
                    '' SKU,
                    '' lotNum,
                    '' traceId,
                    R_TARIFFID,
                    R_CHARGECATEGORY,
                    R_CHARGETYPE,
                    R_descrC,
                    R_ratebase,
                    R_rateperunit,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) Qty,
                    'PL' uom,
                    SUM(InMuid.Cube) TotalCube,
                    SUM(InMuid.Weight) TotalWeight,
                    R_rate,
                    InMuid.locationCategory,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) * R_rateperunit * R_rate Amount,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) * R_rateperunit * R_rate BillAmount,
                    R_materialNo AS UDF01,
                    R_itemChargeCategory AS UDF02,
                    '' UDF03,
                    '' UDF04,
                    '' UDF05
                  FROM (SELECT
                      organizationId,
                      warehouseId,
                      R_billsummaryId,
                      customerId,
                      '' SKU,
                      '' lotNum,
                      '' traceId,
                      R_TARIFFID,
                      R_CHARGECATEGORY,
                      R_CHARGETYPE,
                      R_descrC,
                      R_ratebase,
                      R_rateperunit,
                      1 PalletQty,
                      'PL' uom,
                      SUM(CUBE) CUBE,
                      SUM(netWeight) Weight,
                      R_rate chargeRate,
                      '' locationCategory,
                      1 * R_rateperunit * R_rate Amount,
                      1 * R_rateperunit * R_rate BillAmount,
                      '' UDF01,
                      '' UDF02,
                      '' UDF03,
                      '' UDF04,
                      '' UDF05
                    FROM TMP_BIL_SUMMARY_INFORMATION tb
                    WHERE organizationId = R_ORGANIZATIONID
                    AND warehouseId = R_WAREHOUSEID
                    AND customerId = R_customerId
                    AND tb.muid NOT IN ('*', '', ' ')
                    GROUP BY organizationId,
                             warehouseId,
                             customerId,
                             tariffId,
                             tariffLineNo,
                             StockDate,
                             Muid) InMuid
                  GROUP BY organizationId,
                           warehouseId,
                           customerId
                  HAVING SUM(PalletQty) > R_CLASSFROM LIMIT 1;
              END;
            WHEN R_billMode IN ('MAXPL') THEN BEGIN
                INSERT INTO TMP_BIL_SUMMARY
                  SELECT
                    organizationId,
                    warehouseId,
                    R_billsummaryId,
                    customerId,
                    SKU,
                    MaxMuid.lotNum,
                    MaxMuid.traceId,
                    R_TARIFFID,
                    R_CHARGECATEGORY,
                    R_CHARGETYPE,
                    R_descrC,
                    R_ratebase,
                    R_rateperunit,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) Qty,
                    'PL' uom,
                    SUM(MaxTrace.Cube) TotalCube,
                    SUM(MaxTrace.Weight) TotalWeight,
                    R_rate,
                    MaxMuid.locationCategory,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) * R_rateperunit * R_rate Amount,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) * R_rateperunit * R_rate BillAmount,
                    R_materialNo AS UDF01,
                    R_itemChargeCategory AS UDF02,
                    MaxMuid.UDF03,
                    MaxMuid.UDF04,
                    MaxMuid.UDF05
                  FROM (SELECT
                      organizationId,
                      warehouseId,
                      R_billsummaryId,
                      customerId,
                      '' SKU,
                      '' lotNum,
                      '' traceId,
                      R_TARIFFID,
                      R_CHARGECATEGORY,
                      R_CHARGETYPE,
                      R_descrC,
                      R_ratebase,
                      R_rateperunit,
                      1 PalletQty,
                      'PL' uom,
                      SUM(CUBE) CUBE,
                      SUM(netWeight) Weight,
                      R_rate chargeRate,
                      '' locationCategory,
                      1 * R_rateperunit * R_rate Amount,
                      1 * R_rateperunit * R_rate BillAmount,
                      '' UDF01,
                      '' UDF02,
                      '' UDF03,
                      '' UDF04,
                      '' UDF05
                    FROM TMP_BIL_SUMMARY_INFORMATION tb
                    WHERE organizationId = R_ORGANIZATIONID
                    AND warehouseId = R_WAREHOUSEID
                    AND customerId = R_customerId
                    AND tb.muid NOT IN ('*')
                    GROUP BY organizationId,
                             warehouseId,
                             customerId,
                             tariffId,
                             tariffLineNo,
                             StockDate,
                             muid) MaxMuid
                  GROUP BY organizationId,
                           warehouseId,
                           customerId
                  HAVING SUM(PalletQty) > R_CLASSFROM
                  ORDER BY SUM(PalletQty) DESC LIMIT 1;
              END;
            WHEN R_billMode IN ('MONTHPL') THEN BEGIN
                INSERT INTO TMP_BIL_SUMMARY
                  SELECT
                    organizationId,
                    warehouseId,
                    R_billsummaryId,
                    customerId,
                    '' SKU,
                    '' lotNum,
                    '' traceId,
                    R_TARIFFID,
                    R_CHARGECATEGORY,
                    R_CHARGETYPE,
                    R_descrC,
                    R_ratebase,
                    R_rateperunit,
                    IF((COUNT(*) - R_CLASSFROM) <= R_minQty, R_minQty, COUNT(*) - R_CLASSFROM) Qty,
                    'PL' uom,
                    SUM(MonthMuid.Cube) TotalCube,
                    SUM(MonthMuid.Weight) TotalWeight,
                    R_rate,
                    '' locationCategory,
                    IF((COUNT(*) - R_CLASSFROM) <= R_minQty, R_minQty, COUNT(*) - R_CLASSFROM) * R_rateperunit * R_rate Amount,
                    IF((COUNT(*) - R_CLASSFROM) <= R_minQty, R_minQty, COUNT(*) - R_CLASSFROM) * R_rateperunit * R_rate BillAmount,
                    R_materialNo AS UDF01,
                    R_itemChargeCategory AS UDF02,
                    '' UDF03,
                    '' UDF04,
                    '' UDF05
                  FROM (SELECT
                      organizationId,
                      warehouseId,
                      R_billsummaryId,
                      customerId,
                      stockdate,
                      '' traceid,
                      1 PalletQty,
                      SUM(CUBE) CUBE,
                      SUM(Weight) Weight
                    FROM (SELECT
                        organizationId,
                        warehouseId,
                        R_billsummaryId,
                        customerId,
                        stockdate,
                        '' SKU,
                        '' lotNum,
                        '' traceId,
                        R_TARIFFID,
                        R_CHARGECATEGORY,
                        R_CHARGETYPE,
                        R_descrC,
                        R_ratebase,
                        R_rateperunit,
                        1 PalletQty,
                        'PL' uom,
                        CUBE,
                        netWeight Weight,
                        R_rate chargeRate,
                        '' locationCategory,
                        1 * R_rateperunit * R_rate Amount,
                        1 * R_rateperunit * R_rate BillAmount,
                        '' UDF01,
                        '' UDF02,
                        '' UDF03,
                        '' UDF04,
                        tb.muid muid
                      FROM TMP_BIL_SUMMARY_INFORMATION tb
                      WHERE organizationId = R_ORGANIZATIONID
                      AND warehouseId = R_WAREHOUSEID
                      AND customerId = R_customerId
                      AND MUID NOT IN ('*')) inventoryPlt
                    GROUP BY organizationId,
                             warehouseId,
                             customerId,
                             stockdate,
                             muid) MonthMuid
                  GROUP BY organizationId,
                           warehouseId,
                           customerId
                  HAVING SUM(PalletQty) > R_CLASSFROM LIMIT 1;
              END;
            WHEN R_billMode IN ('INLOC') THEN BEGIN
                INSERT INTO TMP_BIL_SUMMARY
                  SELECT
                    organizationId,
                    warehouseId,
                    R_billsummaryId,
                    customerId,
                    '' SKU,
                    '' lotNum,
                    '' traceId,
                    R_TARIFFID,
                    R_CHARGECATEGORY,
                    R_CHARGETYPE,
                    R_descrC,
                    R_ratebase,
                    R_rateperunit,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) Qty,
                    'PL' uom,
                    SUM(InLoc.Cube) TotalCube,
                    SUM(InLoc.Weight) TotalWeight,
                    R_rate,
                    InLoc.locationCategory,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) * R_rateperunit * R_rate Amount,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) * R_rateperunit * R_rate BillAmount,
                    R_materialNo AS UDF01,
                    R_itemChargeCategory AS UDF02,
                    '' UDF03,
                    '' UDF04,
                    '' UDF05
                  FROM (SELECT
                      organizationId,
                      warehouseId,
                      R_billsummaryId,
                      customerId,
                      '' SKU,
                      '' lotNum,
                      '' traceId,
                      R_TARIFFID,
                      R_CHARGECATEGORY,
                      R_CHARGETYPE,
                      R_descrC,
                      R_ratebase,
                      R_rateperunit,
                      1 PalletQty,
                      'PL' uom,
                      SUM(CUBE) CUBE,
                      SUM(netWeight) Weight,
                      R_rate chargeRate,
                      '' locationCategory,
                      1 * R_rateperunit * R_rate Amount,
                      1 * R_rateperunit * R_rate BillAmount,
                      '' UDF01,
                      '' UDF02,
                      '' UDF03,
                      '' UDF04,
                      '' UDF05
                    FROM TMP_BIL_SUMMARY_INFORMATION tb
                    WHERE organizationId = R_ORGANIZATIONID
                    AND warehouseId = R_WAREHOUSEID
                    AND customerId = R_customerId
                    AND tb.muid NOT IN ('*', '', ' ')
                    GROUP BY organizationId,
                             warehouseId,
                             customerId,
                             tariffId,
                             tariffLineNo,
                             StockDate,
                             tb.locationId) InLoc
                  GROUP BY organizationId,
                           warehouseId,
                           customerId
                  HAVING SUM(PalletQty) > R_CLASSFROM LIMIT 1;
              END;

            WHEN R_billMode IN ('MAXLOC') THEN  -- Highest location count
              BEGIN
                INSERT INTO TMP_BIL_SUMMARY
                  SELECT
                    organizationId,
                    warehouseId,
                    R_billsummaryId,
                    customerId,
                    SKU,
                    MaxLoc.lotNum,
                    MaxLoc.traceId,
                    R_TARIFFID,
                    R_CHARGECATEGORY,
                    R_CHARGETYPE,
                    R_descrC,
                    R_ratebase,
                    R_rateperunit,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) Qty,
                    'PL' uom,
                    SUM(MaxLoc.Cube) TotalCube,
                    SUM(MaxLoc.Weight) TotalWeight,
                    R_rate,
                    MaxLoc.locationCategory,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) * R_rateperunit * R_rate Amount,
                    IF((SUM(PalletQty) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(PalletQty) - R_CLASSFROM) * R_rateperunit * R_rate BillAmount,
                    R_materialNo AS UDF01,
                    R_itemChargeCategory AS UDF02,
                    MaxLoc.UDF03,
                    MaxLoc.UDF04,
                    MaxLoc.UDF05
                  FROM (SELECT
                      organizationId,
                      warehouseId,
                      R_billsummaryId,
                      customerId,
                      '' SKU,
                      '' lotNum,
                      '' traceId,
                      R_TARIFFID,
                      R_CHARGECATEGORY,
                      R_CHARGETYPE,
                      R_descrC,
                      R_ratebase,
                      R_rateperunit,
                      1 PalletQty,
                      'PL' uom,
                      SUM(CUBE) CUBE,
                      SUM(netWeight) Weight,
                      R_rate chargeRate,
                      '' locationCategory,
                      1 * R_rateperunit * R_rate,
                      1 * R_rateperunit * R_rate,
                      '' UDF01,
                      '' UDF02,
                      '' UDF03,
                      '' UDF04,
                      tb.locationId UDF05
                    FROM TMP_BIL_SUMMARY_INFORMATION tb
                    WHERE organizationId = R_ORGANIZATIONID
                    AND warehouseId = R_WAREHOUSEID
                    AND customerId = R_customerId
                    AND tb.muid NOT IN ('*')
                    GROUP BY organizationId,
                             warehouseId,
                             customerId,
                             tariffId,
                             tariffLineNo,
                             StockDate,
                             tb.locationId) MaxLoc
                  GROUP BY organizationId,
                           warehouseId,
                           customerId
                  HAVING SUM(PalletQty) > R_CLASSFROM
                  ORDER BY SUM(PalletQty) DESC LIMIT 1;
              END;
            WHEN R_billMode IN ('MONTHLOC') THEN -- Daily accumulated total location
              BEGIN
                INSERT INTO TMP_BIL_SUMMARY
                  SELECT
                    organizationId,
                    warehouseId,
                    R_billsummaryId,
                    customerId,
                    '' SKU,
                    '' lotNum,
                    '' traceId,
                    R_TARIFFID,
                    R_CHARGECATEGORY,
                    R_CHARGETYPE,
                    R_descrC,
                    R_ratebase,
                    R_rateperunit,
                    IF((COUNT(*) - R_CLASSFROM) <= R_minQty, R_minQty, COUNT(*) - R_CLASSFROM) Qty,
                    'PL' uom,
                    SUM(MonthLoc.Cube) TotalCube,
                    SUM(MonthLoc.Weight) TotalWeight,
                    R_rate,
                    '' locationCategory,
                    IF((COUNT(*) - R_CLASSFROM) <= R_minQty, R_minQty, COUNT(*) - R_CLASSFROM) * R_rateperunit * R_rate Amount,
                    IF((COUNT(*) - R_CLASSFROM) <= R_minQty, R_minQty, COUNT(*) - R_CLASSFROM) * R_rateperunit * R_rate BillAmount,
                    R_materialNo AS UDF01,
                    R_itemChargeCategory AS UDF02,
                    '' UDF03,
                    '' UDF04,
                    '' UDF05
                  FROM (SELECT
                      organizationId,
                      warehouseId,
                      R_billsummaryId,
                      customerId,
                      stockdate,
                      1 PalletQty,
                      '' traceid,
                      SUM(CUBE) CUBE,
                      SUM(Weight) Weight
                    FROM (SELECT
                        organizationId,
                        warehouseId,
                        R_billsummaryId,
                        customerId,
                        stockdate,
                        '' SKU,
                        '' lotNum,
                        '' traceId,
                        R_TARIFFID,
                        R_CHARGECATEGORY,
                        R_CHARGETYPE,
                        R_descrC,
                        R_ratebase,
                        R_rateperunit,
                        1 PalletQty,
                        'PL' uom,
                        CUBE,
                        netWeight Weight,
                        R_rate chargeRate,
                        tb.locationId,
                        1 * R_rateperunit * R_rate Amount,
                        1 * R_rateperunit * R_rate BillAmount,
                        '' UDF01,
                        '' UDF02,
                        '' UDF03,
                        '' UDF04,
                        '' UDF05
                      FROM TMP_BIL_SUMMARY_INFORMATION tb
                      WHERE organizationId = R_ORGANIZATIONID
                      AND warehouseId = R_WAREHOUSEID
                      AND customerId = R_customerId) inventoryPlt
                    GROUP BY organizationId,
                             warehouseId,
                             customerId,
                             stockdate,
                             locationId) MonthLoc
                  GROUP BY organizationId,
                           warehouseId,
                           customerId
                  HAVING SUM(PalletQty) > R_CLASSFROM LIMIT 1;
              END;
            WHEN R_billMode IN ('DAILYCBM') THEN -- Daily accumulated total cbm
              BEGIN
                INSERT INTO TMP_BIL_SUMMARY
                  SELECT
                    organizationId,
                    warehouseId,
                    R_billsummaryId,
                    customerId,
                    '' SKU,
                    '' lotNum,
                    '' traceId,
                    R_TARIFFID,
                    R_CHARGECATEGORY,
                    R_CHARGETYPE,
                    R_descrC,
                    R_ratebase,
                    R_rateperunit,
                    IF((SUM(tb.totalCube) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(tb.totalCube) - R_CLASSFROM) Qty,
                    'm3' uom,
                    SUM(tb.totalCube) CUBE,
                    SUM(netWeight) Weight,
                    R_rate AS chargerate,
                    '' locationCategory,
                    IF((SUM(tb.totalCube) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(tb.totalCube) - R_CLASSFROM) * R_rateperunit * R_rate Amount,
                    IF((SUM(tb.totalCube) - R_CLASSFROM) <= R_minQty, R_minQty, SUM(tb.totalCube) - R_CLASSFROM) * R_rateperunit * R_rate BillAmount,
                    R_materialNo AS UDF01,
                    R_itemChargeCategory AS UDF02,
                    '' UDF03,
                    '' UDF04,
                    '' UDF05
                  FROM TMP_BIL_SUMMARY_INFORMATION tb
                  WHERE organizationId = R_ORGANIZATIONID
                  AND warehouseId = R_WAREHOUSEID
                  AND customerId = R_customerId
                  GROUP BY organizationId,
                           warehouseId,
                           customerId,
                           tariffId,
                           tariffLineNo,
                           stockDate
                  HAVING SUM(tb.totalCube) >= R_CLASSFROM;
              -- LIMIT 1;
              END;
            ELSE BEGIN
              SELECT
                CONCAT('Bill Mode : ', R_billMode, ' not found.') AS Message;
            END;
          END CASE;

          IF EXISTS (SELECT
                *
              FROM TMP_BIL_SUMMARY) THEN
            IF EXISTS (SELECT
                  *
                FROM BIL_SUMMARY
                WHERE billingFromDate >= R_FMDATE
                AND BillingToDate <= R_TODATE
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
                WHERE billingFromDate >= R_FMDATE
                AND BillingToDate <= R_TODATE
                AND ChargeCategory = R_CHARGECATEGORY
                AND chargeType = R_CHARGETYPE
                AND CustomerID = R_CUSTOMERID
                AND billTo = R_BILLTO
                AND rateBase = R_rateBase
                AND arNo IN ('*');

              DELETE bsi
                FROM BIL_SUMMARY_INFORMATION bsi
              WHERE billingFromDate >= R_FMDATE
                AND BillingToDate <= R_TODATE
                AND bsi.ChargeCategory = R_CHARGECATEGORY
                AND bsi.chargeType = R_CHARGETYPE
                AND rateBase = R_rateBase
                AND bsi.CustomerID = R_CUSTOMERID;

              DELETE
                FROM BIL_SUMMARY
              WHERE DATE_FORMAT(billingFromDate, '%Y-%m-%d') >= R_FMDATE
                AND DATE_FORMAT(BillingToDate, '%Y-%m-%d') <= R_TODATE
                AND ChargeCategory = R_CHARGECATEGORY
                AND chargeType = R_CHARGETYPE
                AND rateBase = R_rateBase
                AND CustomerID = R_CUSTOMERID
                AND billTo = R_BILLTO
                AND arNo IN ('*');

            END IF;

            IF (R_billsummaryId = '') THEN
              CALL SPCOM_GetIDSequence(R_ORGANIZATIONID, R_WAREHOUSEID, IN_Language, 'BILLINGSUMMARYID', R_billsummaryId, OUT_returnCode);
            -- SET  R_billsummaryId = 'TEST';
            END IF;

            INSERT INTO BIL_SUMMARY (organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate, customerId
            , sku, lotNum, traceId, tariffId, chargeCategory, chargeType, descr, rateBase, chargePerUnits
            , qty, uom, cubic, weight, chargeRate, amount, billingAmount, cost, amountPayable, amountPaid
            , confirmTime, confirmWho, docType, docNo, createTransactionid, notes, ediSendTime, billTo, settleTime, settleWho
            , followUp, invoiceType, paidTo, costConfirmFlag, costConfirmTime, costConfirmWho, costSettleFlag, costSettleTime
            , costSettleWho, incomeTaxRate, costTaxRate, incomeTax, cosTax, incomeWithoutTax, cosWithoutTax, costInvoiceType, noteText
            , udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag, addWho, ADDTIME, editWho, editTime, locationCategory
            , manual, docLineNo, arNo, arLineNo, apNo, apLineNo, ediSendFlag, ediErrorCode, ediErrorMessage, ediSendTime2, ediSendFlag2
            , ediErrorCode2, ediErrorMessage2, billingTranCategory, orderType, containerType, containerSize)
              SELECT
                bil.organizationId,
                bil.warehouseId,
                CONCAT(R_billsummaryId, '*', LPAD((@row_number := @row_number + 1), 3, '0')),
                DATE_FORMAT(R_TODATE, '%Y-%m-%d') billingFromDate,
                DATE_FORMAT(R_TODATE, '%Y-%m-%d') billingToDate,
                bil.customerId,
                bil.SKU,
                bil.LotNum LotNum,
                bil.traceId traceId,
                bil.tariffId,
                R_CHARGECATEGORY chargeCategory,
                R_chargetype ChargeType,
                R_descrC descr,
                R_rateBase ratebase,
                R_rateperunit AS chargePerUnit,
                SUM(qty) qty,
                bil.uom uom,
                SUM(bil.cubic) cubic,
                SUM(bil.weight) weight,
                R_rate chargeRate,
                R_rateperunit * R_rate * SUM(qty) Amount,
                R_rateperunit * R_rate * SUM(qty) + (R_rateperunit * R_rate * SUM(qty) * R_INCOMETAX) BillingAmount,
                0 cost,
                R_cost * SUM(qty) amountPayable,
                0 amountPaid,
                NOW() confirmTime,
                '' confirmWho,
                '' docType,
                '' docNo,
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
                R_rateperunit * R_rate * SUM(qty) incomeWithoutTax,
                0 cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                R_materialNo AS udf01,
                R_itemChargeCategory AS udf02,
                bil.UDF03 udf03,
                R_UDF06 udf04,
                bil.UDF05 udf05,
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
                '' containerSize
              FROM TMP_BIL_SUMMARY bil
              GROUP BY bil.organizationId,
                       bil.warehouseid,
                       bil.customerId,
                       bil.locationCategory,
                       bil.SKU,
                       bil.LotNum,
                       bil.uom,
                       bil.traceId,
                       bil.tariffId,
                       bil.UDF01,
                       bil.UDF02,
                       bil.UDF03,
                       bil.UDF04,
                       bil.UDF05;

            SET @countRow = ROW_COUNT();

            IF (@countRow > 0) THEN
              SELECT
                CONCAT('BIL SUMMARY INSERTED SUCESSFULLY FOR ', R_CUSTOMERID, ' WITH CHARGES : ', R_CHARGECATEGORY, ',', R_chargetype);
              INSERT INTO BIL_SUMMARY_INFORMATION
                SELECT
                  organizationId,
                  warehouseId,
                  R_billsummaryId,
                  LineNo,
                  R_TODATE,
                  R_TODATE,
                  customerId,
                  tariffId,
                  tariffLineNo,
                  descrC,
                  chargeCategory,
                  chargeType,
                  ratebase,
                  minQty,
                  billingMode,
                  ratePerUnit,
                  rate,
                  tariffClassNo,
                  classFrom,
                  classTo,
                  StockDate,
                  locationId,
                  locationCategory,
                  tbsi.zoneId,
                  traceId,
                  muid,
                  lotNum,
                  sku,
                  qtyonHand,
                  packkey,
                  UOM,
                  qtyallocated,
                  qtyonHold,
                  qtyavailable,
                  qtyPicked,
                  palletUsed,
                  SKUDesc,
                  CUBE,
                  totalCube,
                  grossWeight,
                  netWeight,
                  freightClass,
                  IN_USERID addWho,
                  NOW(),
                  IN_USERID editWho,
                  NOW()
                FROM TMP_BIL_SUMMARY_INFORMATION tbsi;
            END IF;

          ELSE
            SELECT
              CONCAT('NO BILING SUMMARY GENERATED FOR ', R_CUSTOMERID, ' ON CHARGE:', R_CHARGECATEGORY, ',', R_CHARGETYPE) AS MESSAGE,
              R_ORGANIZATIONID,
              R_WAREHOUSEID,
              R_CUSTOMERID,
              R_chargecategory,
              R_CHARGETYPE,
              R_ratebase,
              R_billMode,
              R_minQty,
              R_CLASSFROM,
              R_CLASSTO;
          END IF;
        ELSE
          SELECT
            CONCAT('BIL SUMMARY DETAIL/INFORMATION NOT FOUND FOR ', R_CUSTOMERID, ' ON CHARGE:', R_CHARGECATEGORY, ',', R_CHARGETYPE) AS Msg;
          IF (R_MinQty > 0) THEN
          BEGIN
            SELECT
              CONCAT('MIN CHARGE APPLIED FOR ', R_CUSTOMERID, ' ON CHARGE:', R_CHARGECATEGORY, ',', R_CHARGETYPE) AS Msg;

            IF (R_billsummaryId = '') THEN
              CALL SPCOM_GetIDSequence(R_ORGANIZATIONID, R_WAREHOUSEID, IN_Language, 'BILLINGSUMMARYID', R_billsummaryId, OUT_returnCode);
            -- SET  R_billsummaryId = 'TEST';
            END IF;

            INSERT INTO BIL_SUMMARY (organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate, customerId
            , sku, lotNum, traceId, tariffId, chargeCategory, chargeType, descr, rateBase, chargePerUnits
            , qty, uom, cubic, weight, chargeRate, amount, billingAmount, cost, amountPayable, amountPaid
            , confirmTime, confirmWho, docType, docNo, createTransactionid, notes, ediSendTime, billTo, settleTime, settleWho
            , followUp, invoiceType, paidTo, costConfirmFlag, costConfirmTime, costConfirmWho, costSettleFlag, costSettleTime
            , costSettleWho, incomeTaxRate, costTaxRate, incomeTax, cosTax, incomeWithoutTax, cosWithoutTax, costInvoiceType, noteText
            , udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag, addWho, ADDTIME, editWho, editTime, locationCategory
            , manual, docLineNo, arNo, arLineNo, apNo, apLineNo, ediSendFlag, ediErrorCode, ediErrorMessage, ediSendTime2, ediSendFlag2
            , ediErrorCode2, ediErrorMessage2, billingTranCategory, orderType, containerType, containerSize)
              SELECT
                R_ORGANIZATIONID,
                R_WAREHOUSEID,
                R_billsummaryId,
                DATE_FORMAT(R_TODATE, '%Y-%m-%d') billingFromDate,
                DATE_FORMAT(R_TODATE, '%Y-%m-%d') billingToDate,
                R_CUSTOMERID,
                '' SKU,
                '' lotNum,
                '' traceId,
                R_TARIFFID,
                R_CHARGECATEGORY,
                R_CHARGETYPE,
                R_descrC,
                R_ratebase,
                R_rateperunit,
                R_MinQty BillQty,
                'PL' uom,
                0 CUBE,
                0 Weight,
                R_rate chargeRate,
                R_MinQty * R_rateperunit * R_rate Amount,
                R_rateperunit * R_rate * R_MinQty + (R_rateperunit * R_rate * R_MinQty * R_INCOMETAX) BillAmount,
                0 AS COST,
                (R_MinQty * R_Cost) amountPayable,
                0 amountPaid,
                NOW() confirmTime,
                '' confirmWho,
                '' docType,
                '' docNo,
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
                R_rateperunit * R_rate * R_MinQty incomeWithoutTax,
                0 cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                R_materialNo AS udf01,
                R_itemChargeCategory AS udf02,
                '' udf03,
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
          END;
          END IF;
        END IF;

        DROP TEMPORARY TABLE IF EXISTS TMP_BIL_SUMMARY;
        DROP TEMPORARY TABLE IF EXISTS TMP_BIL_SUMMARY_INFORMATION;
      END;
      END IF;
    END LOOP getTariff;
    CLOSE cur_Tariff;
    SET OUT_returnCode = '000';
  END;
END
$$

DELIMITER ;