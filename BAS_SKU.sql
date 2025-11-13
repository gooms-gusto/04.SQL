--
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Create table `BAS_SKU`
--
CREATE TABLE BAS_SKU (
  organizationId varchar(20) binary NOT NULL,
  customerId varchar(30) binary NOT NULL,
  sku varchar(50) binary NOT NULL,
  activeFlag char(1) binary NOT NULL DEFAULT 'Y',
  skuDescr1 varchar(500) binary DEFAULT NULL,
  skuDescr2 varchar(500) binary DEFAULT NULL,
  grossWeight decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  netWeight decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  tare decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  `cube` decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  price decimal(24, 8) DEFAULT NULL,
  skuLength decimal(18, 4) NOT NULL DEFAULT 0.0000,
  skuWidth decimal(18, 4) NOT NULL DEFAULT 0.0000,
  skuHigh decimal(18, 4) NOT NULL DEFAULT 0.0000,
  putawayLocation varchar(60) binary DEFAULT NULL,
  putawayZone varchar(20) binary DEFAULT NULL,
  alternative_putawayZone1 varchar(20) binary DEFAULT NULL,
  alternative_putawayZone2 varchar(20) binary DEFAULT NULL,
  cycleClass varchar(1) binary DEFAULT NULL,
  lastCycleCount timestamp NULL DEFAULT NULL,
  reOrderQty decimal(18, 3) NOT NULL DEFAULT 0.000,
  shelfLife int NOT NULL DEFAULT 0,
  shelfLifeFlag char(1) binary NOT NULL DEFAULT 'N',
  shelfLifeType char(1) binary NOT NULL,
  shelfLifeAlertDays int NOT NULL DEFAULT 0,
  inboundLifeDays int NOT NULL DEFAULT 0,
  outboundLifeDays int NOT NULL DEFAULT 0,
  alternate_sku1 varchar(100) binary DEFAULT NULL,
  alternate_sku2 varchar(100) binary DEFAULT NULL,
  alternate_sku3 varchar(100) binary DEFAULT NULL,
  alternate_sku4 varchar(100) binary DEFAULT NULL,
  alternate_sku5 varchar(100) binary DEFAULT NULL,
  sku_group1 varchar(100) binary DEFAULT NULL,
  sku_group2 varchar(100) binary DEFAULT NULL,
  sku_group3 varchar(100) binary DEFAULT NULL,
  sku_group4 varchar(100) binary DEFAULT NULL,
  sku_group5 varchar(100) binary DEFAULT NULL,
  sku_group6 varchar(100) binary DEFAULT NULL,
  sku_group7 varchar(100) binary DEFAULT NULL,
  sku_group8 varchar(100) binary DEFAULT NULL,
  sku_group9 varchar(100) binary DEFAULT NULL,
  reservedField01 varchar(200) binary DEFAULT NULL,
  reservedField02 varchar(200) binary DEFAULT NULL,
  reservedField03 varchar(200) binary DEFAULT NULL,
  reservedField04 varchar(200) binary DEFAULT NULL,
  reservedField05 varchar(200) binary DEFAULT NULL,
  reservedField06 varchar(200) binary DEFAULT NULL,
  reservedField07 varchar(200) binary DEFAULT NULL,
  reservedField08 varchar(200) binary DEFAULT NULL,
  reservedField09 varchar(200) binary DEFAULT NULL,
  reservedField10 varchar(200) binary DEFAULT NULL,
  reservedField11 varchar(200) binary DEFAULT NULL,
  reservedField12 varchar(200) binary DEFAULT NULL,
  reservedField13 varchar(200) binary DEFAULT NULL,
  reservedField14 varchar(200) binary DEFAULT NULL,
  reservedField15 varchar(200) binary DEFAULT NULL,
  reservedField16 varchar(200) binary DEFAULT NULL,
  reservedField17 varchar(200) binary DEFAULT NULL,
  reservedField18 varchar(200) binary DEFAULT NULL,
  reservedField19 varchar(200) binary DEFAULT NULL,
  reservedField20 varchar(200) binary DEFAULT NULL,
  hazard_flag varchar(5) binary NOT NULL DEFAULT 'N',
  packId varchar(50) binary DEFAULT NULL,
  lotId varchar(10) binary NOT NULL,
  cartonGroup varchar(50) binary DEFAULT NULL,
  defaultReceivingUom varchar(10) binary DEFAULT NULL,
  defaultShipmentUom varchar(10) binary DEFAULT NULL,
  reportUom varchar(10) binary NOT NULL DEFAULT 'EA',
  defaultHold varchar(10) binary DEFAULT NULL,
  rotationId varchar(20) binary DEFAULT NULL,
  freightClass varchar(20) binary DEFAULT NULL,
  reserveCode varchar(2) binary NOT NULL,
  softAllocationRule varchar(20) binary DEFAULT NULL,
  allocationRule varchar(20) binary DEFAULT NULL,
  tariffId varchar(10) binary DEFAULT NULL,
  hsCode varchar(15) binary DEFAULT NULL,
  replenishRule varchar(20) binary DEFAULT NULL,
  chk_scn_uom varchar(10) binary NOT NULL DEFAULT 'EA',
  defaultCartonType varchar(50) binary DEFAULT NULL,
  system_type varchar(100) binary DEFAULT NULL,
  oneStepAllocation varchar(1) binary NOT NULL DEFAULT 'Y',
  orderBySql varchar(100) binary DEFAULT NULL,
  imageAddress varchar(200) binary DEFAULT NULL,
  invChgWithShipment char(1) binary NOT NULL DEFAULT 'N',
  qcTime decimal(4, 1) DEFAULT NULL,
  qcRule varchar(20) binary DEFAULT NULL,
  defaultSupplierId varchar(30) binary DEFAULT NULL,
  copyPackIdToLotAtt12 char(1) binary NOT NULL DEFAULT 'N',
  kitFlag char(1) binary NOT NULL DEFAULT 'N',
  qtyMin decimal(18, 3) NOT NULL DEFAULT 0.000,
  qtyMax decimal(18, 3) NOT NULL DEFAULT 0.000,
  overReceiving char(1) binary NOT NULL DEFAULT 'N',
  overRcvPercentage decimal(18, 4) DEFAULT 0.0000,
  firstInboundDate timestamp NULL DEFAULT NULL,
  allowReceiving char(1) binary NOT NULL DEFAULT 'Y',
  allowShipment char(1) binary NOT NULL DEFAULT 'Y',
  breakCs char(1) binary NOT NULL DEFAULT 'Y',
  breakIp char(1) binary NOT NULL DEFAULT 'Y',
  specialMaintenance varchar(10) binary NOT NULL DEFAULT 'GENERAL',
  maintenanceReason varchar(20) binary DEFAULT NULL,
  lastMaintenanceDate timestamp NULL DEFAULT NULL,
  firstOp char(1) binary NOT NULL DEFAULT 'N',
  medicalType varchar(15) binary DEFAULT NULL,
  approvalNo varchar(50) binary DEFAULT NULL,
  medicineSpecicalControl char(1) binary NOT NULL DEFAULT 'N',
  secondSerialNoCatch char(1) binary NOT NULL DEFAULT 'N',
  printMedicineQcReport char(1) binary NOT NULL DEFAULT 'N',
  inboundSerialNoQtyControl varchar(20) binary DEFAULT NULL,
  outboundSerialNoQtyControl varchar(20) binary DEFAULT NULL,
  sn_asn_qty char(1) binary NOT NULL DEFAULT 'N',
  sn_so_qty char(1) binary NOT NULL DEFAULT 'N',
  scanWhenCasePicking char(1) binary NOT NULL DEFAULT 'N',
  scanWhenPiecePicking char(1) binary NOT NULL DEFAULT 'N',
  scanWhenCheck char(1) binary NOT NULL DEFAULT 'N',
  scanWhenReceive char(1) binary NOT NULL DEFAULT 'N',
  scanWhenPutaway char(1) binary NOT NULL DEFAULT 'N',
  scanWhenPack char(1) binary NOT NULL DEFAULT 'N',
  scanWhenMove char(1) binary NOT NULL DEFAULT 'N',
  scanWhenQc char(1) binary NOT NULL DEFAULT 'N',
  serialNoCatch char(1) binary NOT NULL DEFAULT 'N',
  pickByWeight char(1) binary DEFAULT 'N',
  noteText mediumtext binary DEFAULT NULL,
  udf01 varchar(500) binary DEFAULT NULL,
  udf02 varchar(500) binary DEFAULT NULL,
  udf03 varchar(500) binary DEFAULT NULL,
  udf04 varchar(500) binary DEFAULT NULL,
  udf05 varchar(500) binary DEFAULT NULL,
  currentVersion int NOT NULL DEFAULT 100,
  oprSeqFlag varchar(65) binary NOT NULL DEFAULT '2016',
  addWho varchar(40) binary DEFAULT NULL,
  addTime timestamp NULL DEFAULT NULL,
  editWho varchar(40) binary DEFAULT NULL,
  editTime timestamp NULL DEFAULT NULL,
  cas_uld_phr int DEFAULT NULL,
  scanWhenInvScan char(1) binary DEFAULT NULL,
  inb_sku_lbl varchar(50) binary DEFAULT NULL,
  putawayRule varchar(20) binary DEFAULT NULL,
  easyCode varchar(500) binary DEFAULT NULL,
  freePickGift char(1) binary NOT NULL DEFAULT 'N',
  skuDescrURL varchar(200) binary DEFAULT NULL,
  shelfLifeUnit varchar(10) binary DEFAULT NULL,
  templateFlag char(1) binary DEFAULT NULL,
  templateName varchar(100) binary DEFAULT NULL,
  qcPoint varchar(15) binary DEFAULT NULL,
  rsLocationToZone varchar(20) binary DEFAULT NULL,
  originalCode varchar(50) binary DEFAULT NULL,
  scanWhenSort char(1) binary DEFAULT NULL,
  tolerance int NOT NULL DEFAULT 0,
  ShelfLifeUOM varchar(10) binary DEFAULT 'DAY',
  lot02Available varchar(10) binary DEFAULT 'NORMAL',
  PRIMARY KEY (organizationId, customerId, sku)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 687,
CHARACTER SET utf8mb3,
COLLATE utf8mb3_bin,
ROW_FORMAT = DYNAMIC;

--
-- Create index `auto_shard_key_organizationId` on table `BAS_SKU`
--
ALTER TABLE BAS_SKU
ADD INDEX auto_shard_key_organizationId (organizationId);

--
-- Create index `I_BAS_SKU_ALTERNATE_SKU1` on table `BAS_SKU`
--
ALTER TABLE BAS_SKU
ADD INDEX I_BAS_SKU_ALTERNATE_SKU1 (alternate_sku1);

--
-- Create index `I_BAS_SKU_ALTERNATE_SKU2` on table `BAS_SKU`
--
ALTER TABLE BAS_SKU
ADD INDEX I_BAS_SKU_ALTERNATE_SKU2 (alternate_sku2);

--
-- Create index `I_BAS_SKU_CF` on table `BAS_SKU`
--
ALTER TABLE BAS_SKU
ADD INDEX I_BAS_SKU_CF (organizationId, customerId, freightClass);

--
-- Create index `I_BAS_SKU_CSRP` on table `BAS_SKU`
--
ALTER TABLE BAS_SKU
ADD INDEX I_BAS_SKU_CSRP (customerId, sku, reportUom, packId);

--
-- Create index `I_BAS_SKU_Descr1` on table `BAS_SKU`
--
ALTER TABLE BAS_SKU
ADD FULLTEXT INDEX I_BAS_SKU_Descr1 (skuDescr1);

--
-- Create index `I_BAS_SKU_Descr2` on table `BAS_SKU`
--
ALTER TABLE BAS_SKU
ADD FULLTEXT INDEX I_BAS_SKU_Descr2 (skuDescr2);

--
-- Create index `i_BAS_SKU_flag` on table `BAS_SKU`
--
ALTER TABLE BAS_SKU
ADD INDEX i_BAS_SKU_flag (organizationId, customerId, activeFlag);

--
-- Create index `I_BAS_SKU_LOTID` on table `BAS_SKU`
--
ALTER TABLE BAS_SKU
ADD INDEX I_BAS_SKU_LOTID (organizationId, lotId);

--
-- Create index `I_BAS_SKU_OF` on table `BAS_SKU`
--
ALTER TABLE BAS_SKU
ADD INDEX I_BAS_SKU_OF (organizationId, activeFlag);

--
-- Create index `I_BAS_SKU_SDD5A` on table `BAS_SKU`
--
ALTER TABLE BAS_SKU
ADD INDEX I_BAS_SKU_SDD5A (organizationId, sku, alternate_sku5, alternate_sku4, alternate_sku3, alternate_sku2, alternate_sku1);

--
-- Create index `I_BAS_SKU_SO` on table `BAS_SKU`
--
ALTER TABLE BAS_SKU
ADD INDEX I_BAS_SKU_SO (organizationId, shelfLifeType, outboundLifeDays);

--
-- Create index `I_BAS_SKU_TPN` on table `BAS_SKU`
--
ALTER TABLE BAS_SKU
ADD INDEX I_BAS_SKU_TPN (organizationId, templateName);

--
-- Create index `idx_1` on table `BAS_SKU`
--
ALTER TABLE BAS_SKU
ADD INDEX idx_1 (organizationId, customerId, sku);

--
-- Create index `idx_sku_alt1` on table `BAS_SKU`
--
ALTER TABLE BAS_SKU
ADD INDEX idx_sku_alt1 (organizationId, alternate_sku1);

--
-- Create index `idx_sku_alt2` on table `BAS_SKU`
--
ALTER TABLE BAS_SKU
ADD INDEX idx_sku_alt2 (organizationId, alternate_sku2);