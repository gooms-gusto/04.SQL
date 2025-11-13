-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE WMS_FTEST;

--
-- Create table `DOC_ORDER_HEADER`
--
CREATE TABLE DOC_ORDER_HEADER (
  organizationId varchar(20) binary NOT NULL,
  warehouseId varchar(20) binary NOT NULL,
  orderNo varchar(20) binary NOT NULL,
  orderType varchar(20) binary NOT NULL,
  soStatus varchar(2) binary NOT NULL,
  orderTime timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expectedShipmentTime1 timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expectedShipmentTime2 timestamp NULL DEFAULT NULL,
  requiredDeliveryTime timestamp NULL DEFAULT NULL,
  customerId varchar(30) binary NOT NULL,
  soReference1 varchar(50) binary DEFAULT NULL,
  soReference2 varchar(50) binary DEFAULT NULL,
  soReference3 varchar(50) binary DEFAULT NULL,
  soReference4 varchar(50) binary DEFAULT NULL,
  soReference5 varchar(50) binary DEFAULT NULL,
  releaseStatus char(1) binary NOT NULL DEFAULT 'N',
  priority char(1) binary DEFAULT NULL,
  consigneeId varchar(30) binary NOT NULL,
  consigneeName varchar(200) binary DEFAULT NULL,
  consigneeAddress1 varchar(200) binary DEFAULT NULL,
  consigneeAddress2 varchar(200) binary DEFAULT NULL,
  consigneeAddress3 varchar(100) binary DEFAULT NULL,
  consigneeAddress4 varchar(100) binary DEFAULT NULL,
  consigneeCity varchar(50) binary DEFAULT NULL,
  consigneeProvince varchar(50) binary DEFAULT NULL,
  consigneeCountry varchar(20) binary DEFAULT NULL,
  consigneeZip varchar(10) binary DEFAULT NULL,
  consigneeContact varchar(200) binary DEFAULT NULL,
  consigneeEmail varchar(100) binary DEFAULT NULL,
  consigneeFax varchar(20) binary DEFAULT NULL,
  consigneeTel1 varchar(40) binary DEFAULT NULL,
  consigneeTel2 varchar(40) binary DEFAULT NULL,
  billingId varchar(30) binary DEFAULT NULL,
  billingName varchar(200) binary DEFAULT NULL,
  billingAddress1 varchar(200) binary DEFAULT NULL,
  billingAddress2 varchar(200) binary DEFAULT NULL,
  billingAddress3 varchar(100) binary DEFAULT NULL,
  billingAddress4 varchar(100) binary DEFAULT NULL,
  billingCity varchar(50) binary DEFAULT NULL,
  billingProvince varchar(50) binary DEFAULT NULL,
  billingCountry varchar(20) binary DEFAULT NULL,
  billingZip varchar(10) binary DEFAULT NULL,
  billingContact varchar(200) binary DEFAULT NULL,
  billingEmail varchar(100) binary DEFAULT NULL,
  billingFax varchar(50) binary DEFAULT NULL,
  billingTel1 varchar(50) binary DEFAULT NULL,
  billingTel2 varchar(50) binary DEFAULT NULL,
  deliveryTerms varchar(10) binary DEFAULT NULL,
  deliveryTermsDescr varchar(100) binary DEFAULT NULL,
  paymentTerms varchar(10) binary DEFAULT NULL,
  paymentTermsDescr varchar(100) binary DEFAULT NULL,
  transportation varchar(100) binary DEFAULT NULL,
  door varchar(10) binary DEFAULT NULL,
  route varchar(30) binary DEFAULT NULL,
  placeOfLoading varchar(60) binary DEFAULT NULL,
  placeOfDischarge varchar(60) binary DEFAULT NULL,
  placeOfDelivery varchar(60) binary DEFAULT NULL,
  carrierId varchar(30) binary DEFAULT NULL,
  carrierName varchar(200) binary DEFAULT NULL,
  carrierAddress1 varchar(200) binary DEFAULT NULL,
  carrierAddress3 varchar(100) binary DEFAULT NULL,
  carrierAddress2 varchar(200) binary DEFAULT NULL,
  carrierAddress4 varchar(100) binary DEFAULT NULL,
  carrierCity varchar(50) binary DEFAULT NULL,
  carrierProvince varchar(50) binary DEFAULT NULL,
  carrierCountry varchar(20) binary DEFAULT NULL,
  carrierZip varchar(10) binary DEFAULT NULL,
  carrierContact varchar(200) binary DEFAULT NULL,
  carrierEmail varchar(50) binary DEFAULT NULL,
  carrierFax varchar(50) binary DEFAULT NULL,
  carrierTel1 varchar(50) binary DEFAULT NULL,
  carrierTel2 varchar(40) binary DEFAULT NULL,
  issuePartyId varchar(30) binary DEFAULT NULL,
  issuePartyName varchar(200) binary DEFAULT NULL,
  issuePartyAddress1 varchar(200) binary DEFAULT NULL,
  issuePartyAddress2 varchar(200) binary DEFAULT NULL,
  issuePartyAddress3 varchar(100) binary DEFAULT NULL,
  issuePartyAddress4 varchar(100) binary DEFAULT NULL,
  issuePartyCity varchar(50) binary DEFAULT NULL,
  issuePartyProvince varchar(50) binary DEFAULT NULL,
  issuePartyCountry varchar(20) binary DEFAULT NULL,
  issuePartyZip varchar(10) binary DEFAULT NULL,
  issuePartyContact varchar(200) binary DEFAULT NULL,
  issuePartyEmail varchar(100) binary DEFAULT NULL,
  issuePartyFax varchar(20) binary DEFAULT NULL,
  issuePartyTel1 varchar(40) binary DEFAULT NULL,
  issuePartyTel2 varchar(40) binary DEFAULT NULL,
  hedi01 varchar(200) binary DEFAULT NULL,
  hedi02 varchar(200) binary DEFAULT NULL,
  hedi03 varchar(200) binary DEFAULT NULL,
  hedi04 varchar(200) binary DEFAULT NULL,
  hedi05 varchar(200) binary DEFAULT NULL,
  hedi06 varchar(200) binary DEFAULT NULL,
  hedi07 varchar(200) binary DEFAULT NULL,
  hedi08 varchar(200) binary DEFAULT NULL,
  hedi09 decimal(18, 8) DEFAULT NULL,
  hedi10 decimal(18, 8) DEFAULT NULL,
  ediSendFlag char(1) binary NOT NULL DEFAULT 'N',
  ediSendTime1 timestamp NULL DEFAULT NULL,
  ediSendTime2 timestamp NULL DEFAULT NULL,
  ediSendTime3 timestamp NULL DEFAULT NULL,
  ediSendTime4 timestamp NULL DEFAULT NULL,
  ediSendTime5 timestamp NULL DEFAULT NULL,
  pickingPrintFlag char(1) binary NOT NULL DEFAULT 'N',
  orderPrintFlag char(1) binary NOT NULL DEFAULT 'N',
  rfGetTask char(1) binary NOT NULL DEFAULT 'N',
  erpCancelFlag char(1) binary NOT NULL DEFAULT 'N',
  singleMatch varchar(20) binary NOT NULL DEFAULT 'N',
  serialNoCatch char(1) binary NOT NULL DEFAULT 'N',
  requireDeliveryNo char(1) binary DEFAULT NULL,
  archiveFlag char(1) binary NOT NULL DEFAULT 'N',
  ful_alc char(1) binary DEFAULT NULL,
  channel varchar(50) binary NOT NULL DEFAULT '*',
  expressPrintFlag char(1) binary NOT NULL DEFAULT 'N',
  deliveryNotePrintFlag char(1) binary NOT NULL DEFAULT 'N',
  weightingFlag char(1) binary NOT NULL DEFAULT 'N',
  allowShipment char(1) binary NOT NULL DEFAULT 'N',
  ediCarrierFlag varchar(50) binary NOT NULL DEFAULT 'N',
  udfPrintFlag1 char(1) binary NOT NULL DEFAULT 'N',
  udfPrintFlag2 char(1) binary NOT NULL DEFAULT 'N',
  udfPrintFlag3 char(1) binary NOT NULL DEFAULT 'N',
  lastShipmentTime timestamp NULL DEFAULT NULL,
  createSource varchar(35) binary DEFAULT NULL,
  zoneGroup varchar(20) binary DEFAULT NULL,
  medicalXmlTime timestamp NULL DEFAULT NULL,
  followUp varchar(20) binary DEFAULT NULL,
  userDefineA varchar(20) binary DEFAULT NULL,
  userDefineB varchar(20) binary DEFAULT NULL,
  invoicePrintFlag char(1) binary NOT NULL DEFAULT 'N',
  invoiceNo varchar(100) binary DEFAULT NULL,
  invoiceTitle varchar(100) binary DEFAULT NULL,
  invoiceType varchar(100) binary DEFAULT NULL,
  invoiceItem varchar(100) binary DEFAULT NULL,
  invoiceAmount decimal(24, 8) DEFAULT NULL,
  salesOrderno varchar(20) binary DEFAULT NULL,
  putToLocation varchar(60) binary DEFAULT NULL,
  deliveryNo varchar(30) binary NOT NULL DEFAULT '*',
  allocationCount int(11) NOT NULL DEFAULT 0,
  waveNo varchar(20) binary NOT NULL DEFAULT '*',
  cartonGroup varchar(50) binary DEFAULT NULL,
  cartonId varchar(50) binary DEFAULT NULL,
  orderGroupNo varchar(20) binary DEFAULT NULL,
  transServiceLevel varchar(20) binary DEFAULT NULL,
  orderHandleInstruction varchar(200) binary DEFAULT NULL,
  totalCubic decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  totalGrossWeight decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  totalNetWeight decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  totalPrice decimal(24, 8) NOT NULL DEFAULT 0.00000000,
  totalLineCount int(11) NOT NULL DEFAULT 0,
  curLineNo int(11) NOT NULL DEFAULT 0,
  totalSkuCount int(11) NOT NULL DEFAULT 0,
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
  locGroup1List varchar(100) binary DEFAULT NULL,
  locGroup2List varchar(100) binary DEFAULT NULL,
  allowPartialShip char(1) binary DEFAULT 'Y',
  waveRule varchar(20) binary DEFAULT NULL,
  consigneeDistrict varchar(50) binary DEFAULT NULL,
  consigneeStreet varchar(50) binary DEFAULT NULL,
  carrierDistrict varchar(50) binary DEFAULT NULL,
  carrierStreet varchar(50) binary DEFAULT NULL,
  billingDistrict varchar(50) binary DEFAULT NULL,
  billingStreet varchar(50) binary DEFAULT NULL,
  issuePartyDistrict varchar(50) binary DEFAULT NULL,
  issuePartyStreet varchar(50) binary DEFAULT NULL,
  parcelMark varchar(50) binary DEFAULT NULL,
  parcelConsolidation varchar(50) binary DEFAULT NULL,
  stopStation varchar(10) binary DEFAULT NULL,
  warehouseTransferFlag char(1) binary DEFAULT 'N',
  shipmentCount int(11) DEFAULT 0,
  udf08 varchar(500) binary DEFAULT NULL,
  erpCancelReason varchar(100) binary DEFAULT NULL,
  ediSendTime timestamp NULL DEFAULT NULL,
  ediErrorCode varchar(50) binary DEFAULT NULL,
  ediErrorMessage text binary DEFAULT NULL,
  ediSendFlag2 char(1) binary NOT NULL DEFAULT 'N',
  ediErrorCode2 varchar(50) binary DEFAULT NULL,
  ediErrorMessage2 text binary DEFAULT NULL,
  ediSendFlag3 char(1) binary NOT NULL DEFAULT 'N',
  ediErrorCode3 varchar(50) binary DEFAULT NULL,
  ediErrorMessage3 text binary DEFAULT NULL,
  expressPlatform varchar(50) binary DEFAULT NULL,
  udf09 decimal(18, 8) DEFAULT NULL,
  udf10 decimal(18, 8) DEFAULT NULL,
  udf07 varchar(500) binary DEFAULT NULL,
  ocpNo varchar(50) binary DEFAULT NULL,
  vehicleNo varchar(100) binary DEFAULT NULL,
  vehicleType varchar(20) binary DEFAULT NULL,
  driver varchar(100) binary DEFAULT NULL,
  hedi11 varchar(50) binary DEFAULT NULL,
  hedi12 varchar(50) binary DEFAULT NULL,
  hedi13 varchar(50) binary DEFAULT NULL,
  hedi14 varchar(50) binary DEFAULT NULL,
  hedi15 varchar(50) binary DEFAULT NULL,
  hedi16 varchar(50) binary DEFAULT NULL,
  hedi17 varchar(50) binary DEFAULT NULL,
  hedi18 varchar(50) binary DEFAULT NULL,
  hedi19 varchar(50) binary DEFAULT NULL,
  hedi20 varchar(50) binary DEFAULT NULL,
  splitFlag char(1) binary DEFAULT 'N',
  reverseOrderNo varchar(20) binary DEFAULT NULL,
  orderSource varchar(10) binary DEFAULT NULL,
  shop varchar(20) binary DEFAULT NULL,
  taskFlag char(1) binary NOT NULL DEFAULT 'N',
  rpGroupId varchar(20) binary NOT NULL DEFAULT '*',
  totalQty decimal(18, 8) DEFAULT NULL,
  PRIMARY KEY (organizationId, warehouseId, orderNo)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 1338,
CHARACTER SET utf8,
COLLATE utf8_bin;

--
-- Create index `auto_shard_key_organizationId` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX auto_shard_key_organizationId (organizationId);

--
-- Create index `IDX_DOC_ORDER_HEADER_P` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX IDX_DOC_ORDER_HEADER_P (organizationId, warehouseId, allocationCount, soStatus, priority);

--
-- Create index `I_DOC_ORDER_DETAILS_TIME` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX I_DOC_ORDER_DETAILS_TIME (organizationId, warehouseId, expectedShipmentTime1, customerId);

--
-- Create index `I_DOC_ORDER_HEADER_ARCHIVEFLAG` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX I_DOC_ORDER_HEADER_ARCHIVEFLAG (organizationId, warehouseId, archiveFlag);

--
-- Create index `I_DOC_ORDER_HEADER_CONSIGNEEID` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX I_DOC_ORDER_HEADER_CONSIGNEEID (organizationId, warehouseId, consigneeId);

--
-- Create index `I_DOC_ORDER_HEADER_CS` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX I_DOC_ORDER_HEADER_CS (organizationId, warehouseId, customerId, soStatus);

--
-- Create index `I_DOC_ORDER_HEADER_EDI` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX I_DOC_ORDER_HEADER_EDI (organizationId, warehouseId, customerId, ediSendTime1, soStatus);

--
-- Create index `I_DOC_ORDER_HEADER_EDISENDFLAG` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX I_DOC_ORDER_HEADER_EDISENDFLAG (organizationId, warehouseId, ediSendFlag);

--
-- Create index `I_DOC_ORDER_HEADER_OS` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX I_DOC_ORDER_HEADER_OS (organizationId, warehouseId, orderNo, soStatus);

--
-- Create index `I_DOC_ORDER_HEADER_R2` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX I_DOC_ORDER_HEADER_R2 (organizationId, warehouseId, soReference2);

--
-- Create index `I_DOC_ORDER_HEADER_R3` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX I_DOC_ORDER_HEADER_R3 (organizationId, warehouseId, soReference3);

--
-- Create index `I_DOC_ORDER_HEADER_R4` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX I_DOC_ORDER_HEADER_R4 (organizationId, warehouseId, soReference4);

--
-- Create index `I_DOC_ORDER_HEADER_R5` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX I_DOC_ORDER_HEADER_R5 (organizationId, warehouseId, soReference5);

--
-- Create index `I_DOC_ORDER_HEADER_CSO` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX I_DOC_ORDER_HEADER_CSO (organizationId, warehouseId, soStatus, orderTime, customerId);

--
-- Create index `idx_DOC_ORDER_HEADER_CS` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX idx_DOC_ORDER_HEADER_CS (organizationId, warehouseId, customerId, singleMatch);

--
-- Create index `I_DOC_ORDER_HEADER_R1` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX I_DOC_ORDER_HEADER_R1 (organizationId, soReference1);

--
-- Create index `I_DOC_ORDER_HEADER_WAVE` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX I_DOC_ORDER_HEADER_WAVE (organizationId, warehouseId, orderNo, soStatus, orderType, singleMatch, carrierId);

--
-- Create index `I_DOC_ORDER_HEADER_WAVE2` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX I_DOC_ORDER_HEADER_WAVE2 (organizationId, warehouseId, customerId, carrierId, orderType, waveRule, soStatus, soReference1, singleMatch);

--
-- Create index `i_doc_order_header_waveno` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX i_doc_order_header_waveno (organizationId, warehouseId, waveNo);

--
-- Create index `I_DOC_ORDER_HEADER_OO` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX I_DOC_ORDER_HEADER_OO (orderNo, organizationId);

--
-- Create index `I_DOC_ORDER_HEADER_CSS5` on table `DOC_ORDER_HEADER`
--
ALTER TABLE DOC_ORDER_HEADER
ADD INDEX I_DOC_ORDER_HEADER_CSS5 (organizationId, warehouseId, customerId, soStatus, soReference1, soReference2, soReference3, soReference4, soReference5);