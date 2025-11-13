-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE WMS_FTEST;

--
-- Create table `DOC_ASN_HEADER`
--
CREATE TABLE DOC_ASN_HEADER (
  organizationId varchar(20) binary NOT NULL,
  warehouseId varchar(20) binary NOT NULL,
  asnNo varchar(20) binary NOT NULL,
  asnType varchar(20) binary DEFAULT NULL,
  asnStatus varchar(2) binary NOT NULL,
  customerId varchar(30) binary NOT NULL,
  asnCreationTime timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expectedArriveTime1 timestamp NULL DEFAULT NULL,
  expectedArriveTime2 timestamp NULL DEFAULT NULL,
  asnReference1 varchar(50) binary DEFAULT NULL,
  asnReference2 varchar(50) binary DEFAULT NULL,
  asnReference3 varchar(50) binary DEFAULT NULL,
  asnReference4 varchar(50) binary DEFAULT NULL,
  asnReference5 varchar(50) binary DEFAULT NULL,
  door varchar(50) binary DEFAULT NULL,
  carrierId varchar(30) binary DEFAULT NULL,
  carrierName varchar(200) binary DEFAULT NULL,
  carrierContact varchar(200) binary DEFAULT NULL,
  carrierMail varchar(100) binary DEFAULT NULL,
  carrierFax varchar(50) binary DEFAULT NULL,
  carrierTel1 varchar(50) binary DEFAULT NULL,
  carrierTel2 varchar(40) binary DEFAULT NULL,
  carrierAddress1 varchar(200) binary DEFAULT NULL,
  carrierAddress2 varchar(200) binary DEFAULT NULL,
  carrierAddress3 varchar(100) binary DEFAULT NULL,
  carrierAddress4 varchar(100) binary DEFAULT NULL,
  carrierCity varchar(50) binary DEFAULT NULL,
  carrierProvince varchar(50) binary DEFAULT NULL,
  carrierCountry varchar(20) binary DEFAULT NULL,
  carrierZip varchar(10) binary DEFAULT NULL,
  countryOfOrigin varchar(2) binary DEFAULT NULL,
  countryOfDestination varchar(2) binary DEFAULT NULL,
  placeOfLoading varchar(60) binary DEFAULT NULL,
  placeOfDischarge varchar(60) binary DEFAULT NULL,
  placeOfDelivery varchar(60) binary DEFAULT NULL,
  deliveryVehicleNo varchar(20) binary DEFAULT NULL,
  driver varchar(10) binary DEFAULT NULL,
  paymentTerms varchar(4) binary DEFAULT NULL,
  paymentTermsDescr varchar(100) binary DEFAULT NULL,
  deliveryTerms varchar(10) binary DEFAULT NULL,
  deliveryTermsDescr varchar(100) binary DEFAULT NULL,
  poNo varchar(20) binary DEFAULT NULL,
  createSource varchar(35) binary DEFAULT NULL,
  byTrace_Flag varchar(1) binary NOT NULL DEFAULT 'N',
  reserve_Flag varchar(1) binary NOT NULL DEFAULT 'N',
  receiveId bigint(20) DEFAULT NULL,
  supplierId varchar(30) binary DEFAULT NULL,
  supplierName varchar(200) binary DEFAULT NULL,
  supplierContact varchar(500) binary DEFAULT NULL,
  supplierMail varchar(100) binary DEFAULT NULL,
  supplierFax varchar(50) binary DEFAULT NULL,
  supplierTel1 varchar(50) binary DEFAULT NULL,
  supplierTel2 varchar(40) binary DEFAULT NULL,
  supplierAddress1 varchar(200) binary DEFAULT NULL,
  supplierAddress2 varchar(200) binary DEFAULT NULL,
  supplierAddress3 varchar(100) binary DEFAULT NULL,
  supplierAddress4 varchar(100) binary DEFAULT NULL,
  supplierCity varchar(50) binary DEFAULT NULL,
  supplierProvince varchar(50) binary DEFAULT NULL,
  supplierCountry varchar(2) binary DEFAULT NULL,
  supplierZip varchar(10) binary DEFAULT NULL,
  billingClass_Group varchar(10) binary DEFAULT NULL,
  ediSendFlag varchar(1) binary NOT NULL DEFAULT 'N',
  ediSendTime1 timestamp NULL DEFAULT NULL,
  ediSendTime2 timestamp NULL DEFAULT NULL,
  ediSendTime3 timestamp NULL DEFAULT NULL,
  ediSendTime4 timestamp NULL DEFAULT NULL,
  ediSendTime5 timestamp NULL DEFAULT NULL,
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
  issuePartyId varchar(30) binary DEFAULT NULL,
  issuePartyName varchar(200) binary DEFAULT NULL,
  issuePartyContact varchar(200) binary DEFAULT NULL,
  issuePartyMail varchar(100) binary DEFAULT NULL,
  issuePartyFax varchar(50) binary DEFAULT NULL,
  issuePartyTel1 varchar(50) binary DEFAULT NULL,
  issuePartyTel2 varchar(40) binary DEFAULT NULL,
  issuePartyAddress1 varchar(200) binary DEFAULT NULL,
  issuePartyAddress2 varchar(200) binary DEFAULT NULL,
  issuePartyAddress3 varchar(100) binary DEFAULT NULL,
  issuePartyAddress4 varchar(100) binary DEFAULT NULL,
  issuePartyCity varchar(50) binary DEFAULT NULL,
  issuePartyProvince varchar(50) binary DEFAULT NULL,
  issuePartyCountry varchar(2) binary DEFAULT NULL,
  issuePartyZip varchar(10) binary DEFAULT NULL,
  deliveryVehicleType varchar(10) binary DEFAULT NULL,
  billingId varchar(30) binary DEFAULT NULL,
  billingName varchar(200) binary DEFAULT NULL,
  billingContact varchar(200) binary DEFAULT NULL,
  billingMail varchar(100) binary DEFAULT NULL,
  billingFax varchar(50) binary DEFAULT NULL,
  billingTel1 varchar(50) binary DEFAULT NULL,
  billingTel2 varchar(40) binary DEFAULT NULL,
  billingAddress1 varchar(200) binary DEFAULT NULL,
  billingAddress2 varchar(200) binary DEFAULT NULL,
  billingAddress3 varchar(100) binary DEFAULT NULL,
  billingAddress4 varchar(100) binary DEFAULT NULL,
  billingCity varchar(50) binary DEFAULT NULL,
  billingProvince varchar(50) binary DEFAULT NULL,
  billingCountry varchar(2) binary DEFAULT NULL,
  billingZip varchar(10) binary DEFAULT NULL,
  asnPrintFlag varchar(1) binary DEFAULT 'N',
  qcStatus varchar(2) binary DEFAULT NULL,
  returnPrintFlag varchar(1) binary DEFAULT 'N',
  zoneGroup varchar(20) binary DEFAULT NULL,
  priority varchar(1) binary DEFAULT NULL,
  releaseStatus varchar(1) binary NOT NULL DEFAULT 'Y',
  packMaterialConsume varchar(1) binary DEFAULT NULL,
  medicalXMLTime timestamp NULL DEFAULT NULL,
  followUp varchar(20) binary DEFAULT NULL,
  serialNoCatch varchar(1) binary NOT NULL DEFAULT 'N',
  userDefineA varchar(20) binary DEFAULT NULL,
  userDefineB varchar(20) binary DEFAULT NULL,
  lastReceivingTime timestamp NULL DEFAULT NULL,
  actualArriveTime timestamp NULL DEFAULT NULL,
  archiveFlag varchar(1) binary NOT NULL DEFAULT 'N',
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
  udf07 varchar(500) binary DEFAULT NULL,
  udf08 varchar(500) binary DEFAULT NULL,
  currentVersion int(11) NOT NULL DEFAULT 100,
  oprSeqFlag varchar(65) binary NOT NULL DEFAULT '2016',
  addWho varchar(40) binary DEFAULT NULL,
  addTime timestamp NULL DEFAULT NULL,
  editWho varchar(40) binary DEFAULT NULL,
  editTime timestamp NULL DEFAULT NULL,
  supplierDistrict varchar(50) binary DEFAULT NULL,
  supplierStreet varchar(50) binary DEFAULT NULL,
  carrierDistrict varchar(50) binary DEFAULT NULL,
  carrierStreet varchar(50) binary DEFAULT NULL,
  billingDistrict varchar(50) binary DEFAULT NULL,
  billingStreet varchar(50) binary DEFAULT NULL,
  issuePartyDistrict varchar(50) binary DEFAULT NULL,
  issuePartyStreet varchar(50) binary DEFAULT NULL,
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
  udf09 decimal(18, 8) DEFAULT NULL,
  udf10 decimal(18, 8) DEFAULT NULL,
  ocpNo varchar(50) binary DEFAULT NULL,
  splitFlag char(1) binary DEFAULT 'N',
  reverseAsnNo varchar(20) binary DEFAULT NULL,
  orderSource varchar(10) binary DEFAULT NULL,
  totalQty decimal(18, 8) DEFAULT NULL,
  PRIMARY KEY (organizationId, warehouseId, asnNo)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 697,
CHARACTER SET utf8,
COLLATE utf8_bin;

--
-- Create index `auto_shard_key_organizationId` on table `DOC_ASN_HEADER`
--
ALTER TABLE DOC_ASN_HEADER
ADD INDEX auto_shard_key_organizationId (organizationId);

--
-- Create index `IDX_DOC_ASN_HEADER_CUSTOMERID` on table `DOC_ASN_HEADER`
--
ALTER TABLE DOC_ASN_HEADER
ADD INDEX IDX_DOC_ASN_HEADER_CUSTOMERID (organizationId, warehouseId, customerId, asnStatus);

--
-- Create index `I_DOC_ASN_HEADER_ARCHIVEFLAG` on table `DOC_ASN_HEADER`
--
ALTER TABLE DOC_ASN_HEADER
ADD INDEX I_DOC_ASN_HEADER_ARCHIVEFLAG (organizationId, warehouseId, archiveFlag);

--
-- Create index `I_DOC_ASN_HEADER_EDI` on table `DOC_ASN_HEADER`
--
ALTER TABLE DOC_ASN_HEADER
ADD INDEX I_DOC_ASN_HEADER_EDI (organizationId, warehouseId, customerId, ediSendTime1, asnStatus);

--
-- Create index `I_DOC_ASN_HEADER_Supplier` on table `DOC_ASN_HEADER`
--
ALTER TABLE DOC_ASN_HEADER
ADD INDEX I_DOC_ASN_HEADER_Supplier (organizationId, supplierId);

--
-- Create index `I_DOC_ASN_HEADER_EDIFLAG` on table `DOC_ASN_HEADER`
--
ALTER TABLE DOC_ASN_HEADER
ADD INDEX I_DOC_ASN_HEADER_EDIFLAG (organizationId, warehouseId, ediSendFlag, asnStatus);

--
-- Create index `IDX_DOC_ASN_HEADER_REF1` on table `DOC_ASN_HEADER`
--
ALTER TABLE DOC_ASN_HEADER
ADD INDEX IDX_DOC_ASN_HEADER_REF1 (organizationId, warehouseId, asnReference1) KEY_BLOCK_SIZE = 300;

--
-- Create index `I_DOC_ASN_HEADER_ASNS` on table `DOC_ASN_HEADER`
--
ALTER TABLE DOC_ASN_HEADER
ADD INDEX I_DOC_ASN_HEADER_ASNS (organizationId, warehouseId, asnStatus);

--
-- Create index `I_DOC_ASN_HEADER_EDIFLAG1` on table `DOC_ASN_HEADER`
--
ALTER TABLE DOC_ASN_HEADER
ADD INDEX I_DOC_ASN_HEADER_EDIFLAG1 (organizationId, asnReference1);