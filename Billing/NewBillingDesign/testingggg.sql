-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE WMS_FTEST;

--
-- Create table `ACT_TRANSACTION_LOG`

SELECT * FROM CML_MIDDLEWARE_CST;
--
CREATE TABLE CML_MIDDLEWARE_CST (
  transactionId int  NOT NULL AUTO_INCREMENT PRIMARY KEY,
  organizationId varchar(20) binary NOT NULL,
  warehouseId varchar(20) binary NOT NULL,
  transactionType varchar(20) binary NOT NULL,
  docType varchar(10) binary DEFAULT NULL,
  docNo varchar(20) binary DEFAULT NULL,
  docLineNo int(11) DEFAULT NULL,
  status varchar(2) binary DEFAULT NULL,
  CustomerId varchar(30) binary DEFAULT NULL,
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
  editTime timestamp NULL DEFAULT NULL
)



SELECT * FROM CML_MIDDLEWARE_CST;


CALL CML_EXECBILLHI();

BEGIN
SET @OUTR=''
CALL CML_EXECBILLHO('','',@OUTR);
END;


SELECT doh.customerId 
        FROM DOC_ASN_HEADER doh INNER JOIN
        BSM_CONFIG_RULES bcr
         ON (doh.customerID=bcr.customerId)
        WHERE
         bcr.configId = '3PL_CUST'
        AND bcr.configValue = 'Y'
        AND bcr.activeFlag = 'Y'
        AND doh.warehouseId='CBT01'
        AND doh.asnNo='ADISUKSES_ASNNO00056';


SELECT * FROM BIL_TARIFF_DETAILS btd WHERE btd.tariffId='BIL00389'


USE WMS_FTEST;

SET @IN_bizOrgId = '';
SET @IN_bizWarehouseId ='';
SET @OUT_returnCode = '';
CALL CML_EXECBILLHO(@IN_bizOrgId, @IN_bizWarehouseId, @OUT_returnCode);
SELECT
  @OUT_returnCode;

SELECT * FROM bil

UPDATE BIL_SUMMARY SET billingFromDate = '2023-09-21' WHERE organizationId = 'OJV_CML' AND warehouseId = 'CBT01' AND billingSummaryId = 'SP0060391*001';