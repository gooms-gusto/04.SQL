SELECT * FROM BSM_CODE_ML bcm WHERE bcm.codeid LIKE 'RAT%';


SELECT * FROM BIL_TARIFF_DETAILS btd WHERE btd.tariffId='BIL00385'

  SELECT
      bcm.codeDescr -- INTO l_spname
    FROM BIL_TARIFF_HEADER bth
      INNER JOIN BIL_TARIFF_DETAILS btd
        ON bth.organizationId = btd.organizationId
        AND bth.warehouseId = btd.warehouseId
        AND bth.tariffId = btd.tariffId
      INNER JOIN BSM_CODE_ML bcm
        ON btd.organizationId = bcm.organizationId
        AND bcm.codeType = 'RAT_BASCUSTOM'
        AND bcm.codeid = btd.udf09
    WHERE bth.tariffMasterId = 'ADISUKSES'
    AND TIMESTAMPDIFF(SECOND, bth.effectiveFrom, NOW()) / (60 * 60 * 24) >= 0
    AND TIMESTAMPDIFF(SECOND, bth.effectiveTo, NOW()) / (60 * 60 * 24) <= 0
    AND btd.docType IN (SELECT
        dah.asnType
      FROM DOC_ASN_HEADER dah
      WHERE dah.asnNo = 'ADISUKSES_ASNNO00012');


  SELECT
      bcm.codeDescr -- INTO l_spname
    FROM BIL_TARIFF_HEADER bth
      INNER JOIN BIL_TARIFF_DETAILS btd
        ON bth.organizationId = btd.organizationId
        AND bth.warehouseId = btd.warehouseId
        AND bth.tariffId = btd.tariffId
      INNER JOIN BSM_CODE_ML bcm
        ON btd.organizationId = bcm.organizationId
        AND bcm.codeType = 'RAT_BASCUSTOM'
        AND bcm.codeid = btd.udf09
    WHERE bth.tariffMasterId = 'ADISUKSES'
    AND TIMESTAMPDIFF(SECOND, bth.effectiveFrom, NOW()) / (60 * 60 * 24) >= 0
    AND TIMESTAMPDIFF(SECOND, bth.effectiveTo, NOW()) / (60 * 60 * 24) <= 0
    AND btd.docType IN (SELECT
        doh.orderType
      FROM DOC_ORDER_HEADER doh
      WHERE doh.orderNo = 'ADISUKSES_ORDERNO004');



USE WMS_FTEST;

SET @IN_organizationId ='OJV_CML';
SET @IN_warehouseId = 'CBT01';
SET @IN_asnNo = 'ADISUKSES_ASNNO00037';
SET @IN_USERID = 'EDI';
SET @OUT_returnCode ='';
CALL CML_ASNCLOSEBILLAKB(@IN_organizationId, @IN_warehouseId,@IN_asnNo,@IN_USERID,@OUT_returnCode);
SELECT
  @OUT_returnCode;

USE WMS_FTEST;

SET @IN_organizationId ='OJV_CML';
SET @IN_warehouseId = 'CBT01';
SET @IN_USERID = 'EDI';
SET @IN_Language ='EN';
SET @IN_CustomerId = 'ADISUKSES';
SET @IN_orderNo = 'ADISUKSES_ORDERNO007';
SET @OUT_returnCode = '';
CALL CML_SOCLOSEBILLAKB(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_orderNo, @OUT_returnCode);
SELECT
  @OUT_returnCode;


SELECT * FROM BIL_CRM_HEADER bch WHERE bch.OpportunityId='0060k00000GEc25AAD';
SELECT * FROM BIL_CRM_DETAILS  bbd  WHERE bbd.OpportunityId='0060k00000GEc25AAD';

SELECT * FROM CML_TEMP_LOG ctl

DELETE FROM CML_TEMP_LOG;

INSERT INTO  CML_TEMP_LOG VALUES(NOW())

SELECT * FROM DOC_ASN_

USE WMS_FTEST;

INSERT INTO BIL_CRM_DETAILS (organizationId, warehouseid, OpportunityId, ProductCode, ProductDescr, rate, uom, addWho, addTime, oprSeqFlag, currentVersion) VALUES
('OJV_CML', 'CBT01', '0060k00000GEc25AAD', '1700000046', 'Handling Out', 10.00000000, 'DO', 'EDI', '2023-09-07 16:03:59', 'EDI1694077439412', 100);



USE WMS_FTEST;

DROP TRIGGER IF EXISTS GENERATE_ GENERATE_BILLING_CUSTOM_INBOUND;

DELIMITER $$

CREATE
DEFINER = 'sa'@'localhost'
TRIGGER GENERATE_BILLING_CUSTOM_INBOUND
AFTER UPDATE ON 
 DOC_ASN_HEADER
FOR EACH ROW
BEGIN
  DECLARE errorMessage varchar(255);
  IF NEW.asnStatus = '99' THEN

SET @IN_organizationId ='OJV_CML';
SET @IN_warehouseId = NEW.warehouseId;
SET @IN_USERID = 'EDI';
SET @IN_Language ='EN';
SET @IN_CustomerId = NEW.customerId;
SET @IN_asnNo = NEW.asnNo;
SET @OUT_returnCode ='';
CALL CML_ASNCLOSEBILLAKB(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_asnNo,@OUT_returnCode);

      SET errorMessage = CONCAT('SP Error Billing custom');
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = errorMessage;

  END IF;
END
$$



  SELECT DISTINCT
    IFNULL(CAST(doh.organizationId AS char), '') AS organizationId,
    IFNULL(CAST(doh.warehouseId AS char(255)), '') AS warehouseId,
    IFNULL(CAST(aad.customerId AS char(255)), '') AS customerId,
    IFNULL(CAST(doh.orderNo AS char), '') AS orderNo,
    IFNULL(CAST(aad.SKU AS char(255)), '') AS SKU,
    IFNULL(CAST(bsm.tariffMasterId AS char(255)), '') AS tariffMasterId
  FROM ACT_ALLOCATION_DETAILS aad

    LEFT OUTER JOIN DOC_ORDER_HEADER doh
      ON doh.organizationId = aad.organizationId
      AND doh.customerId = aad.customerId
      AND doh.orderNo = aad.orderNo
    LEFT OUTER JOIN BAS_SKU bs
      ON bs.organizationId = aad.organizationId
      AND bs.SKU = aad.SKU
      AND bs.customerId = aad.customerId
    LEFT OUTER JOIN BAS_SKU_MULTIWAREHOUSE bsm
      ON bsm.organizationId = bs.organizationId
      AND bsm.SKU = bs.SKU
      AND bsm.customerId = bs.customerId
      AND bsm.warehouseId = aad.warehouseId
  WHERE aad.customerId = 'ADISUKSES'
  AND aad.warehouseId = 'CBT01'
  AND aad.orderNo = 'ADISUKSES_ASNNO00018'
  AND aad.Status IN ('99', '80')
  AND bs.skuDescr1 NOT LIKE '%PALLET%'
  AND doh.orderType NOT IN ('FREE', 'KT');


  SELECT DISTINCT
    IFNULL(CAST(dah.organizationId AS char(255)), '') AS organizationId,
    IFNULL(CAST(atl.warehouseId AS char(255)), '') AS warehouseId,
    IFNULL(CAST(atl.tocustomerId AS char(255)), '') AS customerId,
    IFNULL(CAST(atl.docNo AS char(255)), '') AS asnNo,
    IFNULL(CAST(atl.toSku AS char(255)), '') AS sku,
    IFNULL(CAST(bsm.tariffMasterId AS char(255)), '') AS tariffMasterId
  FROM ACT_TRANSACTION_LOG atl
    LEFT OUTER JOIN BAS_SKU bs
      ON bs.organizationId = atl.organizationId
      AND bs.customerId = atl.toCustomerId
      AND bs.SKU = atl.toSku
    LEFT OUTER JOIN BAS_SKU_MULTIWAREHOUSE bsm
      ON bsm.organizationId = atl.organizationId
      AND bsm.warehouseId = atl.warehouseId
      AND bsm.customerId = atl.tocustomerId
      AND bsm.SKU = atl.toSku
    LEFT OUTER JOIN DOC_ASN_HEADER dah
      ON dah.organizationId = atl.organizationId
      AND dah.warehouseId = atl.warehouseId
      AND dah.asnNo = atl.docNo
      AND dah.customerId = atl.fmCustomerId
  WHERE atl.warehouseId = 'CBT01'
  AND dah.customerId = 'ADISUKSES'
  AND dah.asnNo = 'ADISUKSES_ASNNO00018'
  AND atl.transactionType = 'IN'
  AND dah.asnType NOT IN ('FREE')
  AND atl.STATUS IN ('80', '99')
  AND dah.asnStatus IN ('99')
  AND bs.skuDescr1 NOT LIKE '%PALLET%';

     -- CALL CML_BILLHIDOSTD("OJV_CML","CBT01","EDI","EN","ADISUKSES","ADISUKSES_ASNNO00037","ADISUKSES",OUT_returnCode);