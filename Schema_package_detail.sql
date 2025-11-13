-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Create table `BAS_PACKAGE_DETAILS`
--
CREATE TABLE BAS_PACKAGE_DETAILS (
  organizationId varchar(20) binary NOT NULL,
  packId varchar(50) binary NOT NULL,
  packUom varchar(10) binary NOT NULL,
  qty decimal(18, 8) NOT NULL,
  uomDescr varchar(20) binary NOT NULL,
  packMaterial varchar(20) binary DEFAULT NULL,
  cartonizeFlag char(1) binary NOT NULL DEFAULT 'N',
  in_label char(1) binary NOT NULL DEFAULT 'N',
  out_label varchar(2) binary DEFAULT NULL,
  rpl_label char(1) binary NOT NULL DEFAULT 'N',
  serialNoCatch char(1) binary NOT NULL DEFAULT 'N',
  length decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  width decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  height decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  cube decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  weight decimal(18, 8) NOT NULL DEFAULT 0.00000000,
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
  showSequence int(11) NOT NULL DEFAULT 100,
  customerId varchar(30) binary NOT NULL,
  cube1 decimal(18, 8) NOT NULL DEFAULT 0.00000000,
  PRIMARY KEY (organizationId, customerId, packId, packUom)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 472,
CHARACTER SET utf8,
COLLATE utf8_bin;

--
-- Create index `auto_shard_key_organizationId` on table `BAS_PACKAGE_DETAILS`
--
ALTER TABLE BAS_PACKAGE_DETAILS
ADD INDEX auto_shard_key_organizationId (organizationId);

--
-- Create index `I_BAS_PACKAGE_DETAILS_OCPU` on table `BAS_PACKAGE_DETAILS`
--
ALTER TABLE BAS_PACKAGE_DETAILS
ADD INDEX I_BAS_PACKAGE_DETAILS_OCPU (organizationId, customerId, packId, uomDescr);

--
-- Create index `I_BAS_PACKAGE_DETAILS_OPP` on table `BAS_PACKAGE_DETAILS`
--
ALTER TABLE BAS_PACKAGE_DETAILS
ADD INDEX I_BAS_PACKAGE_DETAILS_OPP (organizationId, packUom, packId);

--
-- Create index `I_BAS_PACKAGE_DETAILS_OPPC` on table `BAS_PACKAGE_DETAILS`
--
ALTER TABLE BAS_PACKAGE_DETAILS
ADD INDEX I_BAS_PACKAGE_DETAILS_OPPC (organizationId, packId, packUom, customerId);