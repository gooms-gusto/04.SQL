-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE WMS_FTEST;

--
-- Create table `DOC_ORDER_DETAILS`
--
CREATE TABLE DOC_ORDER_DETAILS (
  organizationId varchar(20) binary NOT NULL,
  warehouseId varchar(20) binary NOT NULL,
  orderNo varchar(20) binary NOT NULL,
  orderLineNo int(11) NOT NULL,
  customerId varchar(30) binary NOT NULL,
  sku varchar(50) binary NOT NULL,
  lineStatus varchar(2) binary NOT NULL,
  lotNum varchar(10) binary DEFAULT NULL,
  lotAtt01 varchar(20) binary DEFAULT NULL,
  lotAtt02 varchar(20) binary DEFAULT NULL,
  lotAtt03 varchar(20) binary DEFAULT NULL,
  lotAtt04 varchar(100) binary DEFAULT NULL,
  lotAtt05 varchar(100) binary DEFAULT NULL,
  lotAtt06 varchar(100) binary DEFAULT NULL,
  lotAtt07 varchar(100) binary DEFAULT NULL,
  lotAtt08 varchar(100) binary DEFAULT NULL,
  lotAtt09 varchar(100) binary DEFAULT NULL,
  lotAtt10 varchar(100) binary DEFAULT NULL,
  lotAtt11 varchar(100) binary DEFAULT NULL,
  lotAtt12 varchar(100) binary DEFAULT NULL,
  pickZone varchar(20) binary DEFAULT NULL,
  location varchar(60) binary DEFAULT NULL,
  traceId varchar(30) binary DEFAULT NULL,
  qtyOrdered decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  qtySoftAllocated decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  qtyAllocated decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  qtyPicked decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  qtyShipped decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  packId varchar(50) binary DEFAULT NULL,
  packUom varchar(10) binary NOT NULL,
  qtyOrdered_each decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  qtySoftAllocated_each decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  qtyAllocated_each decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  qtyPicked_each decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  qtyShipped_each decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  rotationId varchar(20) binary DEFAULT NULL,
  softAllocationRule varchar(20) binary NOT NULL,
  allocationRule varchar(20) binary NOT NULL,
  grossWeight decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  netWeight decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  cubic decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  price decimal(24, 8) NOT NULL DEFAULT 0.00000000,
  dedi01 varchar(200) binary DEFAULT NULL,
  dedi02 varchar(200) binary DEFAULT NULL,
  dedi03 varchar(200) binary DEFAULT NULL,
  dedi04 varchar(200) binary DEFAULT NULL,
  dedi05 varchar(200) binary DEFAULT NULL,
  dedi06 varchar(200) binary DEFAULT NULL,
  dedi07 varchar(200) binary DEFAULT NULL,
  dedi08 varchar(200) binary DEFAULT NULL,
  dedi09 decimal(18, 8) DEFAULT NULL,
  dedi10 decimal(18, 8) DEFAULT NULL,
  dedi11 varchar(200) binary DEFAULT NULL,
  dedi12 varchar(200) binary DEFAULT NULL,
  dedi13 varchar(200) binary DEFAULT NULL,
  dedi14 varchar(200) binary DEFAULT NULL,
  dedi15 varchar(200) binary DEFAULT NULL,
  dedi16 varchar(200) binary DEFAULT NULL,
  dedi17 varchar(200) binary DEFAULT NULL,
  dedi18 varchar(200) binary DEFAULT NULL,
  dedi19 varchar(200) binary DEFAULT NULL,
  dedi20 varchar(200) binary DEFAULT NULL,
  alternativeSku varchar(100) binary DEFAULT NULL,
  kitReferenceNo int(11) DEFAULT NULL,
  orderLineReferenceNo varchar(30) binary DEFAULT NULL,
  kitSku varchar(50) binary DEFAULT NULL,
  erpCancelFlag char(1) binary NOT NULL DEFAULT 'N',
  zoneGroup varchar(20) binary DEFAULT NULL,
  locGroup1 varchar(10) binary DEFAULT NULL,
  locGroup2 varchar(10) binary DEFAULT NULL,
  commingleSku char(1) binary NOT NULL DEFAULT 'Y',
  ONESTEPALLOCATION char(1) binary DEFAULT NULL,
  orderLotControl char(1) binary NOT NULL DEFAULT 'N',
  fullCaseLotControl char(1) binary NOT NULL DEFAULT 'N',
  pieceLotControl char(1) binary NOT NULL DEFAULT 'N',
  referenceLineNo int(11) DEFAULT NULL,
  salesOrderNo varchar(20) binary DEFAULT NULL,
  salesOrderLineNo varchar(20) binary DEFAULT NULL,
  qtyReleased decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  rule3Flag char(1) binary NOT NULL DEFAULT 'N',
  pickInstruction varchar(500) binary DEFAULT NULL,
  noteText mediumtext binary DEFAULT NULL,
  udf01 varchar(500) binary DEFAULT NULL,
  udf02 varchar(500) binary DEFAULT NULL,
  udf03 varchar(500) binary DEFAULT NULL,
  udf04 varchar(500) binary DEFAULT NULL,
  udf05 varchar(500) binary DEFAULT NULL,
  udf06 varchar(500) binary DEFAULT NULL,
  currentVersion int(11) NOT NULL DEFAULT 100,
  oprSeqFlag varchar(65) binary NOT NULL DEFAULT '2016',
  addWho varchar(40) binary DEFAULT NULL,
  addTime timestamp NULL DEFAULT NULL,
  editWho varchar(40) binary DEFAULT NULL,
  editTime timestamp NULL DEFAULT NULL,
  lotAtt13 varchar(100) binary DEFAULT NULL,
  lotAtt14 varchar(100) binary DEFAULT NULL,
  lotAtt15 varchar(100) binary DEFAULT NULL,
  lotAtt16 varchar(100) binary DEFAULT NULL,
  lotAtt17 varchar(100) binary DEFAULT NULL,
  lotAtt18 varchar(100) binary DEFAULT NULL,
  lotAtt19 varchar(100) binary DEFAULT NULL,
  lotAtt20 varchar(100) binary DEFAULT NULL,
  lotAtt21 varchar(100) binary DEFAULT NULL,
  lotAtt22 varchar(100) binary DEFAULT NULL,
  lotAtt23 varchar(100) binary DEFAULT NULL,
  lotAtt24 varchar(100) binary DEFAULT NULL,
  freePickGift char(1) binary NOT NULL DEFAULT 'N',
  allocationWhereSQL varchar(500) binary DEFAULT NULL,
  refLineNo varchar(30) binary DEFAULT NULL,
  originalSku varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  PRIMARY KEY (organizationId, warehouseId, orderNo, orderLineNo)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 1174,
CHARACTER SET utf8,
COLLATE utf8_bin;

--
-- Create index `auto_shard_key_organizationId` on table `DOC_ORDER_DETAILS`
--
ALTER TABLE DOC_ORDER_DETAILS
ADD INDEX auto_shard_key_organizationId (organizationId);

--
-- Create index `I_DOC_ORDER_DETAILS_CSPLT` on table `DOC_ORDER_DETAILS`
--
ALTER TABLE DOC_ORDER_DETAILS
ADD INDEX I_DOC_ORDER_DETAILS_CSPLT (organizationId, warehouseId, customerId, traceId, location, pickZone, sku);

--
-- Create index `I_DOC_ORDER_DETAILS_L` on table `DOC_ORDER_DETAILS`
--
ALTER TABLE DOC_ORDER_DETAILS
ADD INDEX I_DOC_ORDER_DETAILS_L (organizationId, warehouseId, lineStatus);

--
-- Create index `I_DOC_ORDER_DETAILS_OCS` on table `DOC_ORDER_DETAILS`
--
ALTER TABLE DOC_ORDER_DETAILS
ADD INDEX I_DOC_ORDER_DETAILS_OCS (organizationId, warehouseId, orderNo, sku, customerId);

--
-- Create index `I_DOC_ORDER_DETAILS_OL` on table `DOC_ORDER_DETAILS`
--
ALTER TABLE DOC_ORDER_DETAILS
ADD INDEX I_DOC_ORDER_DETAILS_OL (organizationId, warehouseId, orderNo, lineStatus);

--
-- Create index `I_DOC_ORDER_DETAILS_OLQQ` on table `DOC_ORDER_DETAILS`
--
ALTER TABLE DOC_ORDER_DETAILS
ADD INDEX I_DOC_ORDER_DETAILS_OLQQ (organizationId, warehouseId, orderNo, qtyAllocated_each, qtyOrdered_each, lineStatus);

--
-- Create index `I_DOC_ORDER_DETAILS_OQ` on table `DOC_ORDER_DETAILS`
--
ALTER TABLE DOC_ORDER_DETAILS
ADD INDEX I_DOC_ORDER_DETAILS_OQ (organizationId, warehouseId, orderNo, qtyOrdered_each);

--
-- Create index `I_DOC_ORDER_DETAILS_SS` on table `DOC_ORDER_DETAILS`
--
ALTER TABLE DOC_ORDER_DETAILS
ADD INDEX I_DOC_ORDER_DETAILS_SS (organizationId, warehouseId, salesOrderNo, salesOrderLineNo);

--
-- Create index `I_DOC_ORDER_DETAILS_PU` on table `DOC_ORDER_DETAILS`
--
ALTER TABLE DOC_ORDER_DETAILS
ADD INDEX I_DOC_ORDER_DETAILS_PU (organizationId, packId, packUom);

--
-- Create index `I_DOC_ORDER_DETAILS_O` on table `DOC_ORDER_DETAILS`
--
ALTER TABLE DOC_ORDER_DETAILS
ADD INDEX I_DOC_ORDER_DETAILS_O (organizationId, orderNo, warehouseId);

--
-- Create index `I_DOC_ORDER_DETAILS_OWCOOS` on table `DOC_ORDER_DETAILS`
--
ALTER TABLE DOC_ORDER_DETAILS
ADD INDEX I_DOC_ORDER_DETAILS_OWCOOS (organizationId, warehouseId, customerId, orderNo, orderLineNo, sku);