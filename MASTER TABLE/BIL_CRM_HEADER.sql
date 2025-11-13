-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Create table `BIL_CRM_HEADER`
--
CREATE TABLE BIL_CRM_HEADER (
  organizationId varchar(20) binary NOT NULL DEFAULT 'OJV_CML',
  warehouseId varchar(20) binary NOT NULL,
  OpportunityId varchar(50) binary NOT NULL,
  AgreementNo varchar(255) binary DEFAULT NULL,
  CustomerId varchar(30) binary DEFAULT NULL,
  effectiveFrom datetime DEFAULT NULL,
  effectiveTo datetime DEFAULT NULL,
  addWho varchar(40) binary DEFAULT NULL,
  addTime datetime DEFAULT NULL,
  oprSeqFlag varchar(65) binary NOT NULL DEFAULT '2016',
  currentVersion int(11) NOT NULL DEFAULT 100,
  PRIMARY KEY (organizationId, warehouseId, OpportunityId)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 268,
CHARACTER SET utf8,
COLLATE utf8_bin;