--
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Create table `Z_CYCLECOUNT_DETAIL`
--
CREATE TABLE Z_CYCLECOUNT_DETAIL (
  idDocumentDetailCycle varchar(50) binary NOT NULL,
  idDocumentCycle varchar(50) binary NOT NULL,
  organizationId varchar(50) binary DEFAULT NULL,
  warehouseId varchar(50) binary DEFAULT NULL,
  countingSequence varchar(50) binary DEFAULT NULL,
  location varchar(50) binary DEFAULT NULL,
  sku varchar(50) binary DEFAULT NULL,
  skuDescr varchar(500) binary DEFAULT NULL,
  qtyOnHand decimal(23, 8) DEFAULT NULL,
  uom varchar(10) binary DEFAULT NULL,
  status varchar(10) binary DEFAULT NULL,
  lotnum varchar(50) binary DEFAULT NULL,
  batch varchar(50) binary DEFAULT NULL,
  expDate datetime DEFAULT NULL,
  traceId varchar(50) binary DEFAULT NULL,
  dateTransaction datetime DEFAULT NULL,
  count1 decimal(23, 8) DEFAULT NULL,
  count2 decimal(23, 8) DEFAULT NULL,
  count3 decimal(23, 8) DEFAULT NULL,
  countFinal decimal(23, 8) DEFAULT NULL,
  countDifferent decimal(23, 8) DEFAULT NULL,
  countStatus varchar(23) binary DEFAULT NULL,
  findingFlag varchar(1) binary DEFAULT NULL,
  customerId varchar(50) binary DEFAULT NULL,
  groupIdTask varchar(200) binary DEFAULT NULL,
  udf01 varchar(100) binary DEFAULT NULL,
  udf02 varchar(100) binary DEFAULT NULL,
  udf03 varchar(100) binary DEFAULT NULL,
  udf04 varchar(100) binary DEFAULT NULL,
  udf05 varchar(100) binary DEFAULT NULL,
  addTime datetime DEFAULT NULL,
  addWho varchar(50) binary DEFAULT NULL,
  editTime datetime DEFAULT NULL,
  editWho varchar(50) binary DEFAULT NULL,
  noteText text binary DEFAULT NULL,
  currentVersion varchar(50) binary DEFAULT NULL,
  oprSeqFlag varchar(100) binary DEFAULT NULL,
  count1Status varchar(1) binary DEFAULT 'N',
  count2Status varchar(1) binary DEFAULT 'N',
  count3Status varchar(1) binary DEFAULT 'N',
  PRIMARY KEY (idDocumentDetailCycle)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 5461,
CHARACTER SET utf8mb3,
COLLATE utf8mb3_bin,
ROW_FORMAT = DYNAMIC;

--
-- Create index `idx_idDocumentCycle` on table `Z_CYCLECOUNT_DETAIL`
--
ALTER TABLE Z_CYCLECOUNT_DETAIL
ADD INDEX idx_idDocumentCycle (idDocumentCycle);

--
-- Create index `idx_location` on table `Z_CYCLECOUNT_DETAIL`
--
ALTER TABLE Z_CYCLECOUNT_DETAIL
ADD INDEX idx_location (location);

--
-- Create index `idx_sku` on table `Z_CYCLECOUNT_DETAIL`
--
ALTER TABLE Z_CYCLECOUNT_DETAIL
ADD INDEX idx_sku (sku);

--
-- Create index `idx_status` on table `Z_CYCLECOUNT_DETAIL`
--
ALTER TABLE Z_CYCLECOUNT_DETAIL
ADD INDEX idx_status (status);