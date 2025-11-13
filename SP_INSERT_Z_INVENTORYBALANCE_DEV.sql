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
-- Create procedure `SP_INSERT_Z_INVENTORYBALANCE`
--
CREATE DEFINER = 'wms_ftest'@'%'
PROCEDURE SP_INSERT_Z_INVENTORYBALANCE (IN IN_organizationId varchar(20),
IN IN_warehouseId varchar(20),
IN IN_userId varchar(40),
OUT OUT_returnCode varchar(1000))
BEGIN
  DECLARE r_alertID varchar(20);
  DECLARE r_receipientAdd varchar(600);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1
    @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT, @p3 = MYSQL_ERRNO, @p4 = TABLE_NAME, @p5 = COLUMN_NAME;
    ROLLBACK;
    --
    INSERT INTO SYS_ALERT_LOG (organizationId,
    warehouseId,
    alertMessageId,
    alertId,
    alertDate,
    alertAddress,
    subjectText,
    readFlag,
    messageLevel,
    sendAlertFlag,
    field02,
    noteText,
    addWho,
    addTime,
    editWho,
    editTime)
      VALUES ('OJV_CML', 'CBT01', REPLACE(UUID(), '-', ''), r_alertid, CURRENT_TIMESTAMP, r_receipientAdd, 'Daily Inventory Alert', 'N', 1, 'N', LEFT(CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text), 100), CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text), 'UDFTIMER', CURRENT_TIMESTAMP, 'UDFTIMER', CURRENT_TIMESTAMP);
    COMMIT;
    -- SET OUT_returnCode = CONCAT('999#BILL_STORAGE_DETAIL,',IFNULL(@p1,''),',',IFNULL(@p2,''),',',IFNULL(@p3,''),',',IFNULL(@p4,''),',',IFNULL(@p5,''));
    SET OUT_returnCode = '000';
    SELECT
      OUT_returnCode;
  END;

  SET r_alertID = 'INV_ALERT';
  SET r_receipientAdd = '';
  BEGIN
    ##原始镜像表
    INSERT INTO Z_InventoryBalance (organizationId,
    customerId,
    warehouseid,
    locationId,
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
    SKUDesc,
    StockDate,
    `cube`,
    totalCube,
    grossWeight,
    netWeight,
    freightClass,
    locationcategory,
    locGroup1,
    locGroup2,
    addWho,
    ADDTIME)
      SELECT
        a.organizationId,
        a.customerId AS customer,
        a.warehouseId,
        a.locationId,
        a.traceId,
        a.muid,
        a.lotNum,
        a.sku AS sku,
        a.qty AS qtyonHand,
        d.packId AS packkey,
        d.uomdescr AS UOM,
        a.qtyallocated AS qtyallocated,
        a.qtyOnHold AS qtyonHold,
        (a.qty - a.qtyallocated - a.qtyOnHold - a.qtyRpOut - a.qtyMvOut) AS qtyavailable,
        (CASE WHEN c.locationusage = 'SS' THEN a.qtyallocated ELSE 0 END) AS qtyPicked,
        e.skuDescr1 AS SKUDesc,
        CAST(DATE_ADD(NOW(), INTERVAL -1 DAY) AS date) AS StockDate,
        e.cube /*AS CUBE*/,
        (a.qty * e.cube) AS TotalCube,
        e.grossWeight,
        e.netWeight,
        e.freightClass,
        c.locationCategory,
        c.locGroup1,
        c.locGroup2,
        'UDFSYSTEM' AS addWho,
        NOW() AS ADDTIME
      FROM INV_LOT_LOC_ID a
        LEFT JOIN BAS_LOCATION c
          ON c.organizationId = a.organizationId
          AND c.warehouseId = a.warehouseId
          AND c.locationid = a.locationid
        LEFT JOIN BAS_LOCGROUP1 bl1
          ON bl1.warehouseId = c.warehouseId
          AND bl1.organizationId = c.organizationId
          AND bl1.locGroup1 = c.locGroup1
        LEFT JOIN BAS_SKU e
          ON a.organizationId = e.organizationId
          AND a.customerId = e.customerId
          AND a.sku = e.sku
        LEFT JOIN BAS_PACKAGE_DETAILS d
          ON d.organizationId = e.organizationId
          AND d.customerId = e.customerId
          AND d.packId = e.packId
          AND d.packUom = 'EA'
      WHERE a.qty + a.qtyPa + a.qtyRpIn + a.qtyMvIn > 0;

    #计费用表（3月数据）
    INSERT INTO Z_InventoryBalance_Real (organizationId,
    customerId,
    warehouseid,
    locationId,
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
    SKUDesc,
    StockDate,
    `cube`,
    totalCube,
    grossWeight,
    netWeight,
    freightClass,
    locationcategory,
    locGroup1,
    locGroup2,
    addWho,
    ADDTIME)
      SELECT
        a.organizationId,
        a.customerId AS customer,
        a.warehouseId,
        a.locationId,
        a.traceId,
        a.muid,
        a.lotNum,
        a.sku AS sku,
        a.qty AS qtyonHand,
        d.packId AS packkey,
        d.uomdescr AS UOM,
        a.qtyallocated AS qtyallocated,
        a.qtyOnHold AS qtyonHold,
        (a.qty - a.qtyallocated - a.qtyOnHold - a.qtyRpOut - a.qtyMvOut) AS qtyavailable,
        (CASE WHEN c.locationusage = 'SS' THEN a.qtyallocated ELSE 0 END) AS qtyPicked,
        e.skuDescr1 AS SKUDesc,
        CAST(DATE_ADD(NOW(), INTERVAL -1 DAY) AS date) AS StockDate,
        e.cube /*AS CUBE*/,
        (a.qty * e.cube) AS TotalCube,
        e.grossWeight,
        e.netWeight,
        e.freightClass,
        c.locationCategory,
        c.locGroup1,
        c.locGroup2,
        'UDFSYSTEM' AS addWho,
        NOW() AS ADDTIME
      FROM INV_LOT_LOC_ID a
        LEFT JOIN BAS_LOCATION c
          ON c.organizationId = a.organizationId
          AND c.warehouseId = a.warehouseId
          AND c.locationid = a.locationid
        LEFT JOIN BAS_LOCGROUP1 bl1
          ON bl1.warehouseId = c.warehouseId
          AND bl1.organizationId = c.organizationId
          AND bl1.locGroup1 = c.locGroup1
        LEFT JOIN BAS_SKU e
          ON a.organizationId = e.organizationId
          AND a.customerId = e.customerId
          AND a.sku = e.sku
        LEFT JOIN BAS_PACKAGE_DETAILS d
          ON d.organizationId = e.organizationId
          AND d.customerId = e.customerId
          AND d.packId = e.packId
          AND d.packUom = 'EA'
      WHERE a.qty + a.qtyPa + a.qtyRpIn + a.qtyMvIn > 0;

    ##清理3月前数据
    DELETE
      FROM Z_InventoryBalance_Real
    WHERE ADDTIME <= DATE_ADD(NOW(), INTERVAL -3 MONTH);
  END;
  SET OUT_returnCode = '000';
  COMMIT;
END
$$

DELIMITER ;