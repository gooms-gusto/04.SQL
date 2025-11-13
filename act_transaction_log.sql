-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Create table `ACT_TRANSACTION_LOG`
--
CREATE TABLE ACT_TRANSACTION_LOG (
  organizationId varchar(20) binary NOT NULL,
  warehouseId varchar(20) binary NOT NULL,
  transactionId varchar(20) binary NOT NULL,
  transactionType varchar(20) binary NOT NULL,
  docType varchar(10) binary DEFAULT NULL,
  docNo varchar(20) binary DEFAULT NULL,
  docLineNo int(11) DEFAULT NULL,
  status varchar(2) binary DEFAULT NULL,
  fmCustomerId varchar(30) binary DEFAULT NULL,
  fmSku varchar(50) binary DEFAULT NULL,
  fmLotNum varchar(10) binary DEFAULT NULL,
  fmLocation varchar(60) binary DEFAULT NULL,
  fmId varchar(30) binary DEFAULT NULL,
  fmPackId varchar(50) binary DEFAULT NULL,
  fmUom varchar(10) binary DEFAULT NULL,
  fmQty decimal(18, 8) DEFAULT NULL,
  fmQty_Each decimal(18, 8) DEFAULT NULL,
  toCustomerId varchar(30) binary DEFAULT NULL,
  toSku varchar(50) binary DEFAULT NULL,
  toLotNum varchar(10) binary DEFAULT NULL,
  toLocation varchar(60) binary DEFAULT NULL,
  toId varchar(30) binary DEFAULT NULL,
  toPackId varchar(50) binary DEFAULT NULL,
  toUom varchar(10) binary DEFAULT NULL,
  toQty decimal(18, 8) DEFAULT NULL,
  toQty_Each decimal(18, 8) DEFAULT NULL,
  totalPrice decimal(24, 8) DEFAULT NULL,
  totalNetWeight decimal(18, 8) NOT NULL,
  totalGrossWeight decimal(18, 8) NOT NULL,
  totalCubic decimal(18, 8) NOT NULL,
  transactionTime timestamp NULL DEFAULT NULL,
  paFlag char(1) binary DEFAULT 'N',
  paTaskId varchar(20) binary DEFAULT NULL,
  paSequence int(11) DEFAULT NULL,
  qcFlag char(1) binary DEFAULT 'N',
  qcTaskId varchar(20) binary DEFAULT NULL,
  qcSequence char(1) binary DEFAULT NULL,
  reasonCode varchar(10) binary DEFAULT NULL,
  reason varchar(60) binary DEFAULT NULL,
  EDISendTime timestamp NULL DEFAULT NULL,
  operator varchar(35) binary DEFAULT NULL,
  ediSendFlag char(1) binary NOT NULL DEFAULT 'N',
  callModule varchar(20) binary DEFAULT NULL,
  callWorkStation varchar(20) binary DEFAULT NULL,
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
  cancelledQty decimal(18, 8) DEFAULT NULL,
  fmLpn varchar(30) binary DEFAULT NULL,
  toLpn varchar(30) binary DEFAULT NULL,
  toWarehouse varchar(20) binary DEFAULT NULL,
  billingTranCategory varchar(10) binary DEFAULT NULL,
  relatedTranId varchar(20) binary DEFAULT NULL,
  fmMuid varchar(30) binary DEFAULT NULL,
  toMuid varchar(30) binary DEFAULT NULL,
  PRIMARY KEY (organizationId, warehouseId, transactionId)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 517,
CHARACTER SET utf8,
COLLATE utf8_bin;

--
-- Create index `auto_shard_key_organizationId` on table `ACT_TRANSACTION_LOG`
--
ALTER TABLE ACT_TRANSACTION_LOG
ADD INDEX auto_shard_key_organizationId (organizationId);

--
-- Create index `I_ACT_TRANSACTION_LOG_DD` on table `ACT_TRANSACTION_LOG`
--
ALTER TABLE ACT_TRANSACTION_LOG
ADD INDEX I_ACT_TRANSACTION_LOG_DD (organizationId, warehouseId, docNo, docLineNo);

--
-- Create index `I_ACT_TRANSACTION_LOG_DDT` on table `ACT_TRANSACTION_LOG`
--
ALTER TABLE ACT_TRANSACTION_LOG
ADD INDEX I_ACT_TRANSACTION_LOG_DDT (organizationId, warehouseId, docNo, transactionType, docType);

--
-- Create index `I_ACT_TRANSACTION_LOG_DT` on table `ACT_TRANSACTION_LOG`
--
ALTER TABLE ACT_TRANSACTION_LOG
ADD INDEX I_ACT_TRANSACTION_LOG_DT (organizationId, warehouseId, docNo, transactionType);

--
-- Create index `I_ACT_TRANSACTION_LOG_FF` on table `ACT_TRANSACTION_LOG`
--
ALTER TABLE ACT_TRANSACTION_LOG
ADD INDEX I_ACT_TRANSACTION_LOG_FF (organizationId, warehouseId, fmCustomerId, fmSku);

--
-- Create index `I_ACT_TRANSACTION_LOG_FFF` on table `ACT_TRANSACTION_LOG`
--
ALTER TABLE ACT_TRANSACTION_LOG
ADD INDEX I_ACT_TRANSACTION_LOG_FFF (organizationId, warehouseId, fmLotNum, fmId, fmLocation);

--
-- Create index `I_ACT_TRANSACTION_LOG_P` on table `ACT_TRANSACTION_LOG`
--
ALTER TABLE ACT_TRANSACTION_LOG
ADD INDEX I_ACT_TRANSACTION_LOG_P (organizationId, warehouseId, paTaskId);

--
-- Create index `I_ACT_TRANSACTION_LOG_TDES` on table `ACT_TRANSACTION_LOG`
--
ALTER TABLE ACT_TRANSACTION_LOG
ADD INDEX I_ACT_TRANSACTION_LOG_TDES (organizationId, warehouseId, transactionType, status, editTime, docType);

--
-- Create index `I_ACT_TRANSACTION_LOG_TFDD` on table `ACT_TRANSACTION_LOG`
--
ALTER TABLE ACT_TRANSACTION_LOG
ADD INDEX I_ACT_TRANSACTION_LOG_TFDD (organizationId, warehouseId, transactionTime, docLineNo, docNo, fmCustomerId);

--
-- Create index `I_ACT_TRANSACTION_LOG_TFF` on table `ACT_TRANSACTION_LOG`
--
ALTER TABLE ACT_TRANSACTION_LOG
ADD INDEX I_ACT_TRANSACTION_LOG_TFF (organizationId, warehouseId, transactionTime, fmSku, fmCustomerId);

--
-- Create index `I_ACT_TRANSACTION_LOG_TS` on table `ACT_TRANSACTION_LOG`
--
ALTER TABLE ACT_TRANSACTION_LOG
ADD INDEX I_ACT_TRANSACTION_LOG_TS (organizationId, warehouseId, transactionType, status);

--
-- Create index `I_ACT_TRANSACTION_LOG_TT` on table `ACT_TRANSACTION_LOG`
--
ALTER TABLE ACT_TRANSACTION_LOG
ADD INDEX I_ACT_TRANSACTION_LOG_TT (organizationId, warehouseId, toCustomerId, toSku);

--
-- Create index `I_ACT_TRANSACTION_LOG_TTF` on table `ACT_TRANSACTION_LOG`
--
ALTER TABLE ACT_TRANSACTION_LOG
ADD INDEX I_ACT_TRANSACTION_LOG_TTF (organizationId, warehouseId, transactionType, toLotNum, fmSku, fmCustomerId, transactionTime);

--
-- Create index `I_ACT_TRANSACTION_LOG_TTFFS` on table `ACT_TRANSACTION_LOG`
--
ALTER TABLE ACT_TRANSACTION_LOG
ADD INDEX I_ACT_TRANSACTION_LOG_TTFFS (organizationId, warehouseId, transactionType, status, fmSku, fmCustomerId, transactionTime);

--
-- Create index `I_ACT_TRANSACTION_LOG_TTS` on table `ACT_TRANSACTION_LOG`
--
ALTER TABLE ACT_TRANSACTION_LOG
ADD INDEX I_ACT_TRANSACTION_LOG_TTS (organizationId, warehouseId, transactionTime, status, transactionType);

--
-- Create index `I_ACT_TRANSACTION_LOG_TTT` on table `ACT_TRANSACTION_LOG`
--
ALTER TABLE ACT_TRANSACTION_LOG
ADD INDEX I_ACT_TRANSACTION_LOG_TTT (organizationId, warehouseId, toLotNum, toId, toLocation);

--
-- Create index `I_ACT_TRANSACTION_LOG_FTCUSTOMERID` on table `ACT_TRANSACTION_LOG`
--
ALTER TABLE ACT_TRANSACTION_LOG
ADD INDEX I_ACT_TRANSACTION_LOG_FTCUSTOMERID (organizationId, warehouseId, fmCustomerId, toCustomerId);