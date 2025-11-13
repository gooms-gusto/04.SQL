-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Create table `ACT_ALLOCATION_DETAILS`
--
CREATE TABLE ACT_ALLOCATION_DETAILS (
  organizationId varchar(20) binary NOT NULL,
  warehouseId varchar(20) binary NOT NULL,
  allocationDetailsId varchar(20) binary NOT NULL,
  orderNo varchar(20) binary DEFAULT NULL,
  orderLineNo int(11) NOT NULL,
  skuLineNo int(11) NOT NULL DEFAULT 0,
  waveNo varchar(20) binary DEFAULT NULL,
  status char(2) binary DEFAULT NULL,
  customerId varchar(30) binary NOT NULL,
  sku varchar(50) binary NOT NULL,
  lotNum varchar(10) binary NOT NULL,
  location varchar(60) binary DEFAULT NULL,
  traceId varchar(30) binary DEFAULT NULL,
  packId varchar(50) binary DEFAULT NULL,
  uom varchar(10) binary NOT NULL,
  qty decimal(18, 8) DEFAULT NULL,
  qty_each decimal(18, 8) DEFAULT NULL,
  qtyPicked_each decimal(18, 8) DEFAULT NULL,
  qtyShipped_each decimal(18, 8) DEFAULT NULL,
  pickToLocation varchar(60) binary DEFAULT NULL,
  pickToTraceId varchar(30) binary DEFAULT NULL,
  pickedTime timestamp NULL DEFAULT NULL,
  pickedWho varchar(35) binary DEFAULT NULL,
  shipmentTime timestamp NULL DEFAULT NULL,
  shipmentWho varchar(35) binary DEFAULT NULL,
  reasonCode char(2) binary DEFAULT NULL,
  softAllocationDetailsId varchar(20) binary DEFAULT NULL,
  cubic decimal(18, 8) NOT NULL,
  grossWeight decimal(18, 8) NOT NULL,
  netWeight decimal(18, 8) NOT NULL,
  price decimal(24, 8) DEFAULT NULL,
  notes varchar(100) binary DEFAULT NULL,
  packFlag char(1) binary DEFAULT NULL,
  checkWho varchar(35) binary DEFAULT NULL,
  checkTime timestamp NULL DEFAULT NULL,
  printFlag char(1) binary DEFAULT 'N',
  sortationLocation varchar(60) binary DEFAULT NULL,
  dropId varchar(30) binary DEFAULT NULL,
  doubleCheckBy varchar(35) binary DEFAULT NULL,
  shipmentConfirmBy varchar(35) binary DEFAULT NULL,
  cartonSeqno int(11) DEFAULT 0,
  pickingTransactionId varchar(20) binary DEFAULT NULL,
  cartonId varchar(50) binary DEFAULT NULL,
  palletize char(1) binary DEFAULT NULL,
  workStation varchar(20) binary DEFAULT NULL,
  udfPrintFlag1 char(1) binary DEFAULT 'N',
  cartonGroup varchar(50) binary DEFAULT NULL,
  checkModule varchar(20) binary DEFAULT NULL,
  putToLightFlag char(1) binary DEFAULT 'N',
  noteText mediumtext binary DEFAULT NULL,
  udf01 varchar(500) binary DEFAULT NULL,
  udf02 varchar(500) binary DEFAULT NULL,
  udf03 varchar(500) binary DEFAULT NULL,
  udf04 varchar(500) binary DEFAULT NULL,
  udf05 varchar(500) binary DEFAULT NULL,
  currentVersion int(11) NOT NULL DEFAULT 100,
  oprSeqFlag varchar(65) binary NOT NULL DEFAULT '2016',
  addWho varchar(40) binary DEFAULT NULL,
  addTime timestamp NULL DEFAULT NULL,
  editWho varchar(40) binary DEFAULT NULL,
  editTime timestamp NULL DEFAULT NULL,
  shipmentTransactionId varchar(20) binary DEFAULT NULL,
  PRIMARY KEY (organizationId, warehouseId, allocationDetailsId)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 762,
CHARACTER SET utf8,
COLLATE utf8_bin;

--
-- Create index `auto_shard_key_organizationId` on table `ACT_ALLOCATION_DETAILS`
--
ALTER TABLE ACT_ALLOCATION_DETAILS
ADD INDEX auto_shard_key_organizationId (organizationId);

--
-- Create index `I_ACT_ALLOCATION_DETAILS_CSS` on table `ACT_ALLOCATION_DETAILS`
--
ALTER TABLE ACT_ALLOCATION_DETAILS
ADD INDEX I_ACT_ALLOCATION_DETAILS_CSS (organizationId, warehouseId, customerId, status, sku);

--
-- Create index `I_ACT_ALLOCATION_DETAILS_OO` on table `ACT_ALLOCATION_DETAILS`
--
ALTER TABLE ACT_ALLOCATION_DETAILS
ADD INDEX I_ACT_ALLOCATION_DETAILS_OO (organizationId, warehouseId, orderNo, orderLineNo);

--
-- Create index `I_ACT_ALLOCATION_DETAILS_OSP` on table `ACT_ALLOCATION_DETAILS`
--
ALTER TABLE ACT_ALLOCATION_DETAILS
ADD INDEX I_ACT_ALLOCATION_DETAILS_OSP (organizationId, warehouseId, orderNo, packFlag, sku);

--
-- Create index `I_ACT_ALLOCATION_DETAILS_OSPU` on table `ACT_ALLOCATION_DETAILS`
--
ALTER TABLE ACT_ALLOCATION_DETAILS
ADD INDEX I_ACT_ALLOCATION_DETAILS_OSPU (organizationId, warehouseId, orderNo, uom, packFlag, sku);

--
-- Create index `I_ACT_ALLOCATION_DETAILS_OSU` on table `ACT_ALLOCATION_DETAILS`
--
ALTER TABLE ACT_ALLOCATION_DETAILS
ADD INDEX I_ACT_ALLOCATION_DETAILS_OSU (organizationId, warehouseId, orderNo, uom, status);

--
-- Create index `I_ACT_ALLOCATION_DETAILS_P` on table `ACT_ALLOCATION_DETAILS`
--
ALTER TABLE ACT_ALLOCATION_DETAILS
ADD INDEX I_ACT_ALLOCATION_DETAILS_P (organizationId, warehouseId, packId);

--
-- Create index `I_ACT_ALLOCATION_DETAILS_P2` on table `ACT_ALLOCATION_DETAILS`
--
ALTER TABLE ACT_ALLOCATION_DETAILS
ADD INDEX I_ACT_ALLOCATION_DETAILS_P2 (organizationId, warehouseId, pickToTraceId);

--
-- Create index `I_ACT_ALLOCATION_DETAILS_PS` on table `ACT_ALLOCATION_DETAILS`
--
ALTER TABLE ACT_ALLOCATION_DETAILS
ADD INDEX I_ACT_ALLOCATION_DETAILS_PS (organizationId, warehouseId, pickToTraceId, status);

--
-- Create index `I_ACT_ALLOCATION_DETAILS_PU` on table `ACT_ALLOCATION_DETAILS`
--
ALTER TABLE ACT_ALLOCATION_DETAILS
ADD INDEX I_ACT_ALLOCATION_DETAILS_PU (organizationId, warehouseId, packId, uom);

--
-- Create index `I_ACT_ALLOCATION_DETAILS_WO` on table `ACT_ALLOCATION_DETAILS`
--
ALTER TABLE ACT_ALLOCATION_DETAILS
ADD INDEX I_ACT_ALLOCATION_DETAILS_WO (organizationId, warehouseId, waveNo, orderNo);

--
-- Create index `I_ACT_ALLOCATION_DETAILS_WS` on table `ACT_ALLOCATION_DETAILS`
--
ALTER TABLE ACT_ALLOCATION_DETAILS
ADD INDEX I_ACT_ALLOCATION_DETAILS_WS (organizationId, warehouseId, waveNo, status);

--
-- Create index `I_ACT_ALLOCATION_DETAILS_dropId` on table `ACT_ALLOCATION_DETAILS`
--
ALTER TABLE ACT_ALLOCATION_DETAILS
ADD INDEX I_ACT_ALLOCATION_DETAILS_dropId (organizationId, warehouseId, dropId);

--
-- Create index `i_act_allocation_dets_waveno` on table `ACT_ALLOCATION_DETAILS`
--
ALTER TABLE ACT_ALLOCATION_DETAILS
ADD INDEX i_act_allocation_dets_waveno (organizationId, warehouseId, waveNo);

--
-- Create index `I_ACT_ALLOCATION_DETAILS_OWP` on table `ACT_ALLOCATION_DETAILS`
--
ALTER TABLE ACT_ALLOCATION_DETAILS
ADD INDEX I_ACT_ALLOCATION_DETAILS_OWP (organizationId, warehouseId, pickToTraceId);

--
-- Create index `idx_1` on table `ACT_ALLOCATION_DETAILS`
--
ALTER TABLE ACT_ALLOCATION_DETAILS
ADD INDEX idx_1 (organizationId, warehouseId, orderNo);

--
-- Create index `idx_2` on table `ACT_ALLOCATION_DETAILS`
--
ALTER TABLE ACT_ALLOCATION_DETAILS
ADD INDEX idx_2 (organizationId, warehouseId, traceId);