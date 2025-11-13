--
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

DELIMITER $$

--
-- Create event `TIMER_RULE_SPUDF07`
--
CREATE 
	DEFINER = 'sa'@'%'
EVENT TIMER_RULE_SPUDF07
	ON SCHEDULE EVERY '5' MINUTE
	STARTS '2025-02-03 11:10:00'
	DO 
BEGIN
  DECLARE IN_organizationId varchar(50);
  DECLARE IN_warehouseId varchar(50);
  DECLARE IN_userId varchar(50);
  DECLARE OUT_returnCode varchar(50);

  SET IN_organizationId = 'OJV_CML';
  SET IN_warehouseId = '*';
  SET IN_userId = 'UDF_TIMER';
  SET OUT_returnCode = '';

  CALL OJV_CML_SPUDF_Process7(IN_organizationId, IN_warehouseId, IN_userId, OUT_returnCode);
END
$$

ALTER 
	DEFINER = 'sa'@'%'
EVENT TIMER_RULE_SPUDF07
	ENABLE
$$

--
-- Create event `STORAGE_AKUM`
--
CREATE 
	DEFINER = 'root'@'%'
EVENT STORAGE_AKUM
	ON SCHEDULE EVERY '1' DAY
	STARTS '2025-02-21 03:10:00'
	DO 
BEGIN


--   CALL CML_COUNT_STORAGE_DAYS('OJV_CML', 'CBT01', 'en', 'PLB-LTL');
-- 
--   CALL CML_COUNT_STORAGE_DAYS('OJV_CML', 'CBT01', 'en', 'GCM');
-- 
--   -- CALL CML_COUNT_STORAGE_DAYS('OJV_CML', 'CBT03','en', 'FMI_JKT');
-- 
--   CALL CML_COUNT_STORAGE_DAYS('OJV_CML', 'CBT02-B2C', 'en', 'ECMAMA');
-- 
--   CALL CML_COUNT_STORAGE_DAYS('OJV_CML', 'CBT02-B2C', 'en', 'ECMAMAB2C');
-- 
--   CALL CML_COUNT_STORAGE_DAYS('OJV_CML', 'CBT02-B2C', 'en', 'MAPCLUB');
-- 
--   CALL CML_COUNT_STORAGE_DAYS('OJV_CML', 'KIMSTR', 'en', 'ONDULINE');
-- 
-- 
--   CALL CML_COUNT_RENT_PALLET_DAYS('OJV_CML', 'CBT01', 'en', 'PLB-LTL');
-- 
--   CALL CML_COUNT_RENT_PALLET_DAYS('OJV_CML', 'CBT01', 'en', 'GCM');


CALL Z_EXEC_BILLING_PalletRental();

CALL Z_EXEC_BILLING_Storage();

END
$$

ALTER 
	DEFINER = 'root'@'%'
EVENT STORAGE_AKUM
	ENABLE
$$

--
-- Create event `GEN_DAILY_STORAGE_MAP`
--
CREATE 
	DEFINER = 'mysql.sys'@'%'
EVENT GEN_DAILY_STORAGE_MAP
	ON SCHEDULE EVERY '1' DAY
	STARTS '2024-11-19 04:30:00'
	DO 
BEGIN
CALL CML_BILLSTORAGE_DAILY_CBM_250725('OJV_CML', '','CUSTOMBIL', 'en', 'MAP','','');
END
$$

ALTER 
	DEFINER = 'mysql.sys'@'%'
EVENT GEN_DAILY_STORAGE_MAP
	ENABLE
$$

--
-- Create event `GEN_26_BILFIXRATECML`
--
CREATE 
	DEFINER = 'sa'@'%'
EVENT GEN_26_BILFIXRATECML
	ON SCHEDULE EVERY '1' MONTH
	STARTS '2025-03-20 02:15:00'
	DO 
BEGIN
-- CALL CML_EXECUTE_BILLFIX(); REMARK AKB@IT-LINC 27.08.25

set @p_success_flag='';
set @p_message='';
set @p_record_count='';
CALL CML_BILLFIXCHG_NW(@p_success_flag, @p_message, @p_record_count);
SELECT
  @p_success_flag,
  @p_message,
  @p_record_count;

END
$$

ALTER 
	DEFINER = 'sa'@'%'
EVENT GEN_26_BILFIXRATECML
	ENABLE
$$

--
-- Create event `EVENT_INSERT_Z_INVENTORYBALANCE_ACTIVE_REAL`
--
CREATE 
	DEFINER = 'sa'@'localhost'
EVENT EVENT_INSERT_Z_INVENTORYBALANCE_ACTIVE_REAL
	ON SCHEDULE EVERY '1' DAY
	STARTS '2022-07-04 02:25:00'
	DO 
INSERT INTO Z_InventoryBalance_Real
		(organizationId,
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
		ADDTIME,
editwho,
edittime)
	SELECT a.organizationId,
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
		CAST(DATE_ADD(NOW(), INTERVAL - 1 DAY) AS DATE) AS StockDate,
		e.cube /*AS CUBE*/,
    CAST((a.qty * e.cube) AS DECIMAL(24,8)) AS TotalCube,
		-- (a.qty * e.cube) AS TotalCube,
		e.grossWeight,
		e.netWeight,
		e.freightClass,
		c.locationCategory,
		c.locGroup1,
		c.locGroup2,
		'UDFSYSTEM' AS addWho, 
		NOW() AS ADDTIME,
      'UDFSYSTEM' AS editwho,
      NOW() AS edittime
	FROM INV_LOT_LOC_ID a
	LEFT JOIN BAS_LOCATION c ON c.organizationId = a.organizationId
	AND c.warehouseId = a.warehouseId
	AND c.locationid = a.locationid
	LEFT JOIN BAS_LOCGROUP1 bl1 ON bl1.warehouseId = c.warehouseId
	AND bl1.organizationId = c.organizationId
	AND bl1.locGroup1 = c.locGroup1
	LEFT JOIN BAS_SKU e ON a.organizationId = e.organizationId
	AND a.customerId = e.customerId
	AND a.sku = e.sku
	LEFT JOIN BAS_PACKAGE_DETAILS d
	ON d.organizationId = e.organizationId
	AND d.customerId = e.customerId
	AND d.packId = e.packId
	AND d.packUom = 'EA'
	WHERE a.qty + a.qtyPa +a.qtyRpIn +a.qtyMvIn >0
$$

ALTER 
	DEFINER = 'sa'@'localhost'
EVENT EVENT_INSERT_Z_INVENTORYBALANCE_ACTIVE_REAL
	ENABLE
$$

--
-- Create event `EVENT_INSERT_Z_INVENTORYBALANCE_ACTIVE`
--
CREATE 
	DEFINER = 'sa'@'localhost'
EVENT EVENT_INSERT_Z_INVENTORYBALANCE_ACTIVE
	ON SCHEDULE EVERY '1' DAY
	STARTS '2022-07-04 02:10:00'
	DO 
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
  ADDTIME,
  editWho,
  editTime,addTimeStock,editTimeStock)
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
      CAST((a.qty * e.cube) AS decimal(24, 8)) AS TotalCube,
      e.grossWeight,
      e.netWeight,
      e.freightClass,
      c.locationCategory,
      c.locGroup1,
      c.locGroup2,
      'UDFSYSTEM' AS addWho,
      NOW() AS ADDTIME,
      'UDFSYSTEM' AS editwho,
      NOW() AS edittime,a.addTime,a.editTime
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
    WHERE a.qty + a.qtyPa + a.qtyRpIn + a.qtyMvIn > 0
$$

ALTER 
	DEFINER = 'sa'@'localhost'
EVENT EVENT_INSERT_Z_INVENTORYBALANCE_ACTIVE
	ENABLE
$$

--
-- Create event `CML_RECORD_MANPOWER`
--
CREATE 
	DEFINER = 'sa'@'%'
EVENT CML_RECORD_MANPOWER
	ON SCHEDULE EVERY '1' DAY
	STARTS '2023-12-06 23:50:22'
	DO 
BEGIN

  INSERT INTO BAS_MANPOWER (CustomerID
  , MPOperatorRR
  , MPOperatorCB
  , MPOperator
  , MPChecker
  , MPPicker
  , MPWOR
   ,Note
  , AddTime
  , EditTime
  , AddWho
  , EditWho)
    SELECT
      staffId AS CustomerID,
      staffName AS MPOperatorRR,
      team AS MPOperatorCB,
      email AS MPOperator,
      extension AS MPChecker,
      mobile AS MPPicker,
      title AS MPWOR,
      noteText AS Note,
      NOW(),
      NOW(),
      'EDI',
      'EDI'
    FROM BAS_STAFF bs
    WHERE DATE(bs.editTime) = DATE(NOW())
    AND bs.staffId IN ('LTL', 'BCA', 'PPG')
    AND bs.warehouseId = 'CBT01';

END
$$

ALTER 
	DEFINER = 'sa'@'%'
EVENT CML_RECORD_MANPOWER
	ENABLE
$$

--
-- Create event `CML_GENERATE_STORAGEBILLING`
--
CREATE 
	DEFINER = 'mysql.sys'@'%'
EVENT CML_GENERATE_STORAGEBILLING
	ON SCHEDULE EVERY '1' MONTH
	STARTS '2025-05-26 04:30:00'
	COMMENT 'for generate billing storage purpose'
	DO 
BEGIN

CALL CML_BILLSTORAGE_R_BILL_MODE('OJV_CML', 'CBT01','en', 'PLB-LTL');

CALL CML_BILLSTORAGE_R_BILL_MODE('OJV_CML', 'CBT01','en', 'GCM');

CALL CML_BILLSTORAGE_R_BILL_MODE('OJV_CML', 'CBT03','en', 'FMI_JKT');

CALL CML_BILLSTORAGE_R_BILL_MODE('OJV_CML', 'CBT02-B2C','en', 'ECMAMA');

CALL CML_BILLSTORAGE_R_BILL_MODE('OJV_CML', 'CBT02-B2C','en', 'ECMAMAB2C');

CALL CML_BILLSTORAGE_R_BILL_MODE('OJV_CML', 'CBT02-B2C','en', 'MAPCLUB');

END
$$

ALTER 
	DEFINER = 'mysql.sys'@'%'
EVENT CML_GENERATE_STORAGEBILLING
	ENABLE
$$

--
-- Create event `CML_GENERATE_PALLETRENTALBILLING`
--
CREATE 
	DEFINER = 'mysql.sys'@'%'
EVENT CML_GENERATE_PALLETRENTALBILLING
	ON SCHEDULE EVERY '1' MONTH
	STARTS '2025-05-26 04:45:00'
	DO 
BEGIN
       CALL CML_BILLRENTPALLET_R_BILL_MODE('OJV_CML', 'CBT01','CUSTOMBILL','en', 'PLB-LTL');

       CALL CML_BILLRENTPALLET_R_BILL_MODE('OJV_CML', 'CBT01','CUSTOMBILL','en', 'GCM');
END
$$

ALTER 
	DEFINER = 'mysql.sys'@'%'
EVENT CML_GENERATE_PALLETRENTALBILLING
	ENABLE
$$

--
-- Create event `CML_Event_ProcessBillingCML_BILLVASSPECIALSTD()`
--
CREATE 
	DEFINER = 'mysql.sys'@'%'
EVENT `CML_Event_ProcessBillingCML_BILLVASSPECIALSTD()`
	ON SCHEDULE EVERY '60' MINUTE
	STARTS '2025-08-28 13:09:11'
	DO 
BEGIN
   CALL Z_SP_ProcessBillingCML_BILLVASSPECIALSTD();
END
$$

ALTER 
	DEFINER = 'mysql.sys'@'%'
EVENT `CML_Event_ProcessBillingCML_BILLVASSPECIALSTD()`
	ENABLE
$$

--
-- Create event `CML_Event_ProcessBillingCML_BILLSOVASSTD()`
--
CREATE 
	DEFINER = 'mysql.sys'@'%'
EVENT `CML_Event_ProcessBillingCML_BILLSOVASSTD()`
	ON SCHEDULE EVERY '90' MINUTE
	STARTS '2025-08-28 13:09:11'
	DO 
BEGIN
   CALL Z_SP_ProcessBillingCML_BILLSOVASSTD();
END
$$

ALTER 
	DEFINER = 'mysql.sys'@'%'
EVENT `CML_Event_ProcessBillingCML_BILLSOVASSTD()`
	ENABLE
$$

--
-- Create event `CML_Event_ProcessBillingCML_BILLHOSTD_TYPE2()`
--
CREATE 
	DEFINER = 'mysql.sys'@'%'
EVENT `CML_Event_ProcessBillingCML_BILLHOSTD_TYPE2()`
	ON SCHEDULE EVERY '30' MINUTE
	STARTS '2025-08-28 13:09:11'
	DO 
BEGIN
   CALL Z_SP_ProcessBillingCML_BILLHOSTD_TYPE2();
END
$$

ALTER 
	DEFINER = 'mysql.sys'@'%'
EVENT `CML_Event_ProcessBillingCML_BILLHOSTD_TYPE2()`
	ENABLE
$$

--
-- Create event `CML_Event_ProcessBillingCML_BILLHOSTD()`
--
CREATE 
	DEFINER = 'mysql.sys'@'%'
EVENT `CML_Event_ProcessBillingCML_BILLHOSTD()`
	ON SCHEDULE EVERY '30' MINUTE
	STARTS '2025-08-28 13:09:11'
	DO 
BEGIN
  CALL Z_SP_ProcessBillingCML_BILLHOSTD();
END
$$

ALTER 
	DEFINER = 'mysql.sys'@'%'
EVENT `CML_Event_ProcessBillingCML_BILLHOSTD()`
	ENABLE
$$

--
-- Create event `CML_Event_ProcessBillingCML_BILLHISTD_TYPE2()`
--
CREATE 
	DEFINER = 'mysql.sys'@'%'
EVENT `CML_Event_ProcessBillingCML_BILLHISTD_TYPE2()`
	ON SCHEDULE EVERY '30' MINUTE
	STARTS '2025-08-28 13:09:11'
	DO 
BEGIN
   CALL Z_SP_ProcessBillingCML_BILLHISTD_TYPE2();
END
$$

ALTER 
	DEFINER = 'mysql.sys'@'%'
EVENT `CML_Event_ProcessBillingCML_BILLHISTD_TYPE2()`
	ENABLE
$$

--
-- Create event `CML_Event_ProcessBillingCML_BILLHISTD()`
--
CREATE 
	DEFINER = 'mysql.sys'@'%'
EVENT `CML_Event_ProcessBillingCML_BILLHISTD()`
	ON SCHEDULE EVERY '60' MINUTE
	STARTS '2025-08-28 13:09:11'
	DO 
BEGIN
  CALL Z_SP_ProcessBillingCML_BILLHISTD();
END
$$

ALTER 
	DEFINER = 'mysql.sys'@'%'
EVENT `CML_Event_ProcessBillingCML_BILLHISTD()`
	ENABLE
$$

--
-- Create event `CML_Event_ProcessBillingCML_BILLASNVASSTD()`
--
CREATE 
	DEFINER = 'mysql.sys'@'%'
EVENT `CML_Event_ProcessBillingCML_BILLASNVASSTD()`
	ON SCHEDULE EVERY '60' MINUTE
	STARTS '2025-08-28 13:09:11'
	DO 
BEGIN
   CALL Z_SP_ProcessBillingCML_BILLASNVASSTD();
END
$$

ALTER 
	DEFINER = 'mysql.sys'@'%'
EVENT `CML_Event_ProcessBillingCML_BILLASNVASSTD()`
	ENABLE
$$

--
-- Create event `BCA_UPDATE_DESTINATION`
--
CREATE 
	DEFINER = 'sa'@'localhost'
EVENT BCA_UPDATE_DESTINATION
	ON SCHEDULE EVERY '0:1' HOUR_MINUTE
	STARTS '2021-01-19 01:31:00'
	ON COMPLETION PRESERVE
	DO 
UPDATE  DOC_ORDER_HEADER doh
LEFT JOIN DOC_ORDER_DETAILS dod ON doh.organizationId = dod.organizationId AND doh.warehouseId = dod.warehouseId AND doh.orderNo = dod.orderNo
LEFT JOIN BAS_SKU s ON s.organizationId = dod.organizationId AND s.customerId = dod.customerId AND s.sku = dod.sku
LEFT JOIN BAS_CUSTOMER c ON doh.consigneeId = c.customerId AND customerType='CO' 
SET  doh.udf08 = CASE WHEN s.lotId ='SERIALNO' and s.sku<>'2IN-00IDS.201/13' AND s.sku<> '2IN-00IDS.601/94' AND s.sku<> '2IN-00IDS.201/17' AND s.sku<> '2IN-00IDS.202/08' AND s.sku<> '2IN-00IDS.203/17' AND s.sku<> '2IN-00IDS.206/18' AND s.sku<> '2IN-00ILS.501/05' AND s.sku<> '2IN-00ITS.501/02'
AND s.sku<> '2IN-00ITS.506/10' AND s.sku<> '2IN-00000-KS0100' AND s.sku<> '2IN-0000-KS0100A' AND s.sku<> '2IN-0000-KS0200A' AND s.sku<> '2IN-00UMM205B/05' THEN CONCAT(c.udf01, 'N') ELSE c.udf01 END
WHERE customerType='CO' and doh.customerId='BCA' AND doh.soStatus IN ('00','10','20','30','40') AND CONVERT(doh.addtime, date) BETWEEN DATE_SUB(now(), INTERVAL 30 DAY) and now()
$$

ALTER 
	DEFINER = 'sa'@'localhost'
EVENT BCA_UPDATE_DESTINATION
	ENABLE
$$

--
-- Create event `BACKUP_Z_INV_2025`
--
CREATE
DEFINER = 'root'@'%'
EVENT BACKUP_Z_INV_2025
ON SCHEDULE
EVERY
'1' DAY
STARTS
'2025-05-15 05:15:35'
DISABLE
DO
BEGIN
  SELECT
    *
  FROM Z_InventoryBalance zib
  WHERE zib.organizationId = 'OJV_CML'
  AND YEAR(zib.StockDate) = 2025 INTO OUTFILE '/var/lib/mysql-files/Z_INVENTORYBALANCE1.csv' FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '
';
END
$$

DELIMITER ;