-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Create table `BIL_CRM_DETAILS`
--
CREATE TABLE BIL_CRM_DETAILS (
  organizationId varchar(20) binary NOT NULL DEFAULT 'OJV_CML',
  warehouseid varchar(20) binary NOT NULL,
  OpportunityId varchar(50) binary NOT NULL,
  ProductCode varchar(50) binary NOT NULL,
  ProductDescr varchar(200) binary DEFAULT NULL,
  rate decimal(24, 8) NOT NULL,
  uom varchar(10) binary NOT NULL,
  addWho varchar(40) binary DEFAULT NULL,
  addTime datetime DEFAULT NULL,
  oprSeqFlag varchar(65) binary NOT NULL DEFAULT '2016',
  currentVersion int(11) NOT NULL DEFAULT 100,
  PRIMARY KEY (organizationId, warehouseid, OpportunityId, ProductCode, rate, uom)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 192,
CHARACTER SET utf8,
COLLATE utf8_bin;