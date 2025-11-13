--
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Create table `Z_CYCLECOUNT_HEADER`
--
CREATE TABLE Z_CYCLECOUNT_HEADER (
  idDocumentCycle varchar(50) binary NOT NULL,
  methodCycle varchar(50) binary NOT NULL,
  organizationId varchar(30) binary NOT NULL,
  warehouseId varchar(50) binary NOT NULL,
  customerId varchar(50) binary NOT NULL,
  sku varchar(50) binary NOT NULL,
  chamber varchar(10) binary NOT NULL,
  aisle varchar(10) binary NOT NULL,
  level varchar(10) binary NOT NULL,
  userCountTotal int NOT NULL,
  status varchar(2) binary NOT NULL DEFAULT '00',
  dateFromTransaction datetime DEFAULT NULL,
  dateToTransaction datetime DEFAULT NULL,
  udf01 varchar(100) binary NOT NULL,
  udf02 varchar(100) binary DEFAULT NULL,
  udf03 varchar(100) binary DEFAULT NULL,
  udf04 varchar(100) binary NOT NULL,
  udf05 varchar(100) binary DEFAULT NULL,
  addTime datetime NOT NULL,
  addWho varchar(50) binary NOT NULL,
  editTime datetime DEFAULT NULL,
  editWho varchar(50) binary DEFAULT NULL,
  noteText text binary DEFAULT NULL,
  currentVersion varchar(50) binary NOT NULL,
  oprSeqFlag varchar(100) binary DEFAULT NULL,
  PRIMARY KEY (idDocumentCycle)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 8192,
CHARACTER SET utf8mb3,
COLLATE utf8mb3_bin,
ROW_FORMAT = DYNAMIC;

--
-- Create index `idx_addTime` on table `Z_CYCLECOUNT_HEADER`
--
ALTER TABLE Z_CYCLECOUNT_HEADER
ADD INDEX idx_addTime (addTime);

--
-- Create index `idx_customerId` on table `Z_CYCLECOUNT_HEADER`
--
ALTER TABLE Z_CYCLECOUNT_HEADER
ADD INDEX idx_customerId (customerId);

--
-- Create index `idx_sku` on table `Z_CYCLECOUNT_HEADER`
--
ALTER TABLE Z_CYCLECOUNT_HEADER
ADD INDEX idx_sku (sku);

--
-- Create index `idx_status` on table `Z_CYCLECOUNT_HEADER`
--
ALTER TABLE Z_CYCLECOUNT_HEADER
ADD INDEX idx_status (status);

--
-- Create index `idx_warehouseId` on table `Z_CYCLECOUNT_HEADER`
--
ALTER TABLE Z_CYCLECOUNT_HEADER
ADD INDEX idx_warehouseId (warehouseId);