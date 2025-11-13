-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE WMS_FTEST;

--
-- Create table `DOC_ASN_DETAILS`
--
CREATE TABLE DOC_ASN_DETAILS (
  organizationId varchar(20) binary NOT NULL,
  warehouseId varchar(20) binary NOT NULL,
  asnNo varchar(20) binary NOT NULL,
  asnLineNo int(11) NOT NULL,
  customerId varchar(30) binary NOT NULL,
  sku varchar(50) binary NOT NULL,
  skuDescr varchar(500) binary DEFAULT NULL,
  poNo varchar(20) binary DEFAULT NULL,
  poLineNo int(11) DEFAULT NULL,
  lineStatus varchar(2) binary NOT NULL,
  receivedTime timestamp NULL DEFAULT NULL,
  expectedQty decimal(18, 8) NOT NULL,
  expectedQty_Each decimal(18, 8) NOT NULL,
  receivedQty decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  receivedQty_Each decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  packId varchar(50) binary DEFAULT NULL,
  packUom varchar(10) binary NOT NULL,
  holdRejectCode varchar(2) binary DEFAULT NULL,
  holdRejectReason varchar(60) binary DEFAULT NULL,
  productStatus varchar(20) binary DEFAULT NULL,
  productStatus_Descr varchar(60) binary DEFAULT NULL,
  receivingLocation varchar(60) binary DEFAULT NULL,
  containerId varchar(30) binary DEFAULT NULL,
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
  totalCubic decimal(18, 8) NOT NULL,
  totalGrossWeight decimal(18, 8) NOT NULL,
  totalNetWeight decimal(18, 8) NOT NULL,
  totalPrice decimal(24, 8) NOT NULL DEFAULT 0.00000000,
  createSource varchar(35) binary DEFAULT NULL,
  palletizeQty_Each decimal(18, 8) DEFAULT NULL,
  palletizeMethod varchar(8) binary DEFAULT NULL,
  planToLoc varchar(60) binary DEFAULT NULL,
  reserve_Flag varchar(1) binary NOT NULL DEFAULT 'N',
  alternativeSku varchar(100) binary DEFAULT NULL,
  alternativeDescr varchar(200) binary DEFAULT NULL,
  printLabel varchar(1) binary DEFAULT NULL,
  damagedQty_Each decimal(18, 8) DEFAULT NULL,
  rejectedQty decimal(18, 8) DEFAULT NULL,
  rejectedQty_Each decimal(18, 8) DEFAULT NULL,
  qcStatus varchar(2) binary DEFAULT NULL,
  overRcvPercentage decimal(18, 8) DEFAULT NULL,
  referenceLineNo int(11) DEFAULT NULL,
  asnLineFilter varchar(100) binary DEFAULT NULL,
  operator varchar(35) binary DEFAULT NULL,
  preReceivedQty_Each decimal(18, 8) DEFAULT NULL,
  preReceivedLocation varchar(60) binary DEFAULT NULL,
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
  checkItemsFlag char(1) binary DEFAULT NULL,
  erpCancelFlag char(1) binary NOT NULL DEFAULT 'N',
  refLineNo varchar(30) binary DEFAULT NULL,
  PRIMARY KEY (organizationId, warehouseId, asnNo, asnLineNo)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 769,
CHARACTER SET utf8,
COLLATE utf8_bin;

--
-- Create index `auto_shard_key_organizationId` on table `DOC_ASN_DETAILS`
--
ALTER TABLE DOC_ASN_DETAILS
ADD INDEX auto_shard_key_organizationId (organizationId);

--
-- Create index `I_DOC_ASN_DETAILS_AE` on table `DOC_ASN_DETAILS`
--
ALTER TABLE DOC_ASN_DETAILS
ADD INDEX I_DOC_ASN_DETAILS_AE (organizationId, warehouseId, asnNo, expectedQty_Each);

--
-- Create index `I_DOC_ASN_DETAILS_CSA` on table `DOC_ASN_DETAILS`
--
ALTER TABLE DOC_ASN_DETAILS
ADD INDEX I_DOC_ASN_DETAILS_CSA (organizationId, warehouseId, customerId, asnNo, sku);

--
-- Create index `I_DOC_ASN_DETAILS_PP` on table `DOC_ASN_DETAILS`
--
ALTER TABLE DOC_ASN_DETAILS
ADD INDEX I_DOC_ASN_DETAILS_PP (organizationId, warehouseId, poNo, poLineNo);

--
-- Create index `I_DOC_ASN_DETAILS_PU` on table `DOC_ASN_DETAILS`
--
ALTER TABLE DOC_ASN_DETAILS
ADD INDEX I_DOC_ASN_DETAILS_PU (organizationId, warehouseId, packId, packUom);

--
-- Create index `I_DOC_ASN_DETAILS_OWAAL` on table `DOC_ASN_DETAILS`
--
ALTER TABLE DOC_ASN_DETAILS
ADD INDEX I_DOC_ASN_DETAILS_OWAAL (organizationId, warehouseId, asnNo, asnLineNo, lineStatus);

--
-- Create index `I_DOC_ASN_DETAILS_OWCAAS` on table `DOC_ASN_DETAILS`
--
ALTER TABLE DOC_ASN_DETAILS
ADD INDEX I_DOC_ASN_DETAILS_OWCAAS (organizationId, warehouseId, customerId, asnNo, asnLineNo, sku);