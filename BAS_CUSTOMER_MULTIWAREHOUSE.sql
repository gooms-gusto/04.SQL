-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Create table `BAS_CUSTOMER_MULTIWAREHOUSE`
--
CREATE TABLE BAS_CUSTOMER_MULTIWAREHOUSE (
  organizationId varchar(20) binary NOT NULL,
  customerId varchar(30) binary NOT NULL,
  customerType varchar(2) binary NOT NULL,
  warehouseId varchar(20) binary NOT NULL,
  tariffId varchar(10) binary DEFAULT NULL,
  allInFlag char(1) binary NOT NULL DEFAULT 'N',
  allInRate decimal(24, 8) DEFAULT NULL,
  allInArea decimal(18, 8) DEFAULT NULL,
  allInRateType varchar(10) binary DEFAULT NULL,
  billingDate int(11) DEFAULT NULL,
  bil_obd_stk char(1) binary NOT NULL DEFAULT 'N',
  invChgWithShipment char(1) binary NOT NULL DEFAULT 'N',
  incomeTaxRate decimal(24, 8) DEFAULT NULL,
  putawayRule varchar(20) binary DEFAULT NULL,
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
  csCycleGroup varchar(10) binary DEFAULT NULL,
  eaCycleGroup varchar(10) binary DEFAULT NULL,
  carrierId varchar(30) binary DEFAULT NULL,
  replenishRule varchar(20) binary DEFAULT NULL,
  cycleCalcDays int(11) DEFAULT NULL,
  cycleLastCalc timestamp NULL DEFAULT NULL,
  rankBy varchar(5) binary DEFAULT NULL,
  cycleCalcBase varchar(10) binary DEFAULT NULL,
  reserveCode varchar(2) binary DEFAULT NULL,
  tariffMasterId varchar(20) binary DEFAULT NULL,
  PRIMARY KEY (organizationId, customerId, customerType, warehouseId)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 176,
CHARACTER SET utf8,
COLLATE utf8_bin;

--
-- Create index `auto_shard_key_organizationId` on table `BAS_CUSTOMER_MULTIWAREHOUSE`
--
ALTER TABLE BAS_CUSTOMER_MULTIWAREHOUSE
ADD INDEX auto_shard_key_organizationId (organizationId);