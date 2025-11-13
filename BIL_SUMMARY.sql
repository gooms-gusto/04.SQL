--
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Create table `BIL_SUMMARY`
--
CREATE TABLE BIL_SUMMARY (
  organizationId varchar(20) binary NOT NULL,
  warehouseId varchar(20) binary NOT NULL,
  billingSummaryId varchar(30) binary NOT NULL,
  billingFromDate varchar(10) binary NOT NULL,
  billingToDate varchar(10) binary NOT NULL,
  customerId varchar(30) binary NOT NULL,
  sku varchar(50) binary DEFAULT NULL,
  lotNum varchar(10) binary DEFAULT NULL,
  traceId varchar(30) binary DEFAULT NULL,
  tariffId varchar(10) binary DEFAULT NULL,
  chargeCategory varchar(20) binary DEFAULT NULL,
  chargeType varchar(20) binary NOT NULL,
  descr varchar(60) binary NOT NULL,
  rateBase varchar(20) binary DEFAULT NULL,
  chargePerUnits decimal(18, 3) DEFAULT NULL,
  qty decimal(18, 8) DEFAULT NULL,
  uom varchar(10) binary DEFAULT NULL,
  cubic decimal(24, 8) DEFAULT NULL,
  weight decimal(18, 8) DEFAULT NULL,
  chargeRate decimal(24, 8) DEFAULT NULL,
  amount decimal(24, 8) NOT NULL DEFAULT 0.00000000,
  billingAmount decimal(24, 8) DEFAULT NULL,
  cost decimal(24, 8) DEFAULT NULL,
  amountPayable decimal(24, 8) DEFAULT NULL,
  amountPaid decimal(24, 8) DEFAULT NULL,
  confirmTime timestamp NULL DEFAULT NULL,
  confirmWho varchar(30) binary DEFAULT NULL,
  docType varchar(20) binary DEFAULT NULL,
  docNo varchar(20) binary DEFAULT NULL,
  createTransactionid varchar(20) binary DEFAULT NULL,
  notes mediumtext binary DEFAULT NULL,
  ediSendTime timestamp NULL DEFAULT NULL,
  billTo varchar(35) binary DEFAULT NULL,
  settleTime timestamp NULL DEFAULT NULL,
  settleWho varchar(30) binary DEFAULT NULL,
  followUp varchar(20) binary DEFAULT NULL,
  invoiceType varchar(20) binary DEFAULT NULL,
  paidTo varchar(30) binary DEFAULT NULL,
  costConfirmFlag char(1) binary DEFAULT NULL,
  costConfirmTime timestamp NULL DEFAULT NULL,
  costConfirmWho varchar(30) binary DEFAULT NULL,
  costSettleFlag char(1) binary DEFAULT NULL,
  costSettleTime timestamp NULL DEFAULT NULL,
  costSettleWho varchar(30) binary DEFAULT NULL,
  incomeTaxRate decimal(24, 8) DEFAULT NULL,
  costTaxRate decimal(24, 8) DEFAULT NULL,
  incomeTax decimal(24, 8) DEFAULT NULL,
  cosTax decimal(24, 8) DEFAULT NULL,
  incomeWithoutTax decimal(24, 8) DEFAULT NULL,
  cosWithoutTax decimal(24, 8) DEFAULT NULL,
  costInvoiceType varchar(20) binary DEFAULT NULL,
  noteText mediumtext binary DEFAULT NULL,
  udf01 varchar(500) binary DEFAULT NULL,
  udf02 varchar(500) binary DEFAULT NULL,
  udf03 varchar(500) binary DEFAULT NULL,
  udf04 varchar(500) binary DEFAULT NULL,
  udf05 varchar(500) binary DEFAULT NULL,
  currentVersion int NOT NULL DEFAULT 100,
  oprSeqFlag varchar(65) binary NOT NULL DEFAULT '2016',
  addWho varchar(40) binary DEFAULT NULL,
  addTime timestamp NULL DEFAULT NULL,
  editWho varchar(40) binary DEFAULT NULL,
  editTime timestamp NULL DEFAULT NULL,
  locationCategory varchar(10) binary DEFAULT NULL,
  manual char(1) binary DEFAULT NULL,
  docLineNo int DEFAULT NULL,
  arNo varchar(20) binary DEFAULT NULL,
  arLineNo int DEFAULT NULL,
  apNo varchar(20) binary DEFAULT NULL,
  apLineNo int DEFAULT NULL,
  ediSendFlag char(1) binary NOT NULL DEFAULT 'N',
  ediErrorCode varchar(50) binary DEFAULT NULL,
  ediErrorMessage text binary DEFAULT NULL,
  ediSendTime2 timestamp NULL DEFAULT NULL,
  ediSendFlag2 char(1) binary NOT NULL DEFAULT 'N',
  ediErrorCode2 varchar(50) binary DEFAULT NULL,
  ediErrorMessage2 text binary DEFAULT NULL,
  billingTranCategory varchar(10) binary DEFAULT NULL,
  orderType varchar(20) binary DEFAULT NULL,
  containerType char(2) binary DEFAULT NULL,
  containerSize char(2) binary DEFAULT NULL,
  PRIMARY KEY (organizationId, warehouseId, billingSummaryId)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 502,
CHARACTER SET utf8mb3,
COLLATE utf8mb3_bin,
ROW_FORMAT = DYNAMIC;

--
-- Create index `auto_shard_key_organizationId` on table `BIL_SUMMARY`
--
ALTER TABLE BIL_SUMMARY
ADD INDEX auto_shard_key_organizationId (organizationId);

--
-- Create index `I_BIL_SUMMARY_A` on table `BIL_SUMMARY`
--
ALTER TABLE BIL_SUMMARY
ADD INDEX I_BIL_SUMMARY_A (organizationId, warehouseId, billingFromDate, chargeCategory);

--
-- Create index `I_BIL_SUMMARY_OWAA` on table `BIL_SUMMARY`
--
ALTER TABLE BIL_SUMMARY
ADD INDEX I_BIL_SUMMARY_OWAA (organizationId, warehouseId, arNo, arLineNo);

--
-- Create index `IDX_BIL_SUMMARY` on table `BIL_SUMMARY`
--
ALTER TABLE BIL_SUMMARY
ADD INDEX IDX_BIL_SUMMARY (organizationId, warehouseId, customerId);

--
-- Create index `IDX_BIL_SUMMARY_3` on table `BIL_SUMMARY`
--
ALTER TABLE BIL_SUMMARY
ADD INDEX IDX_BIL_SUMMARY_3 (organizationId, warehouseId, customerId, chargeType, billingFromDate);

--
-- Create index `IDX_BIL_SUMMARY_BYDOCNO` on table `BIL_SUMMARY`
--
ALTER TABLE BIL_SUMMARY
ADD INDEX IDX_BIL_SUMMARY_BYDOCNO (organizationId, warehouseId, docNo, chargeType, docType);

DELIMITER $$

--
-- Create trigger `BEFORE_INSERT_BILLINGSUMMARY`
--
CREATE
DEFINER = 'root'@'localhost'
TRIGGER BEFORE_INSERT_BILLINGSUMMARY
AFTER INSERT
ON BIL_SUMMARY
FOR EACH ROW
BEGIN

  IF (NEW.ediErrorCode2 <> '') THEN
    INSERT INTO TEMP_API (lot01, lot02, lot03, lot04)
      VALUES (NEW.organizationId, NEW.warehouseId, NEW.billingSummaryId, NEW.ediErrorCode2);


  END IF;
END
$$

DELIMITER ;