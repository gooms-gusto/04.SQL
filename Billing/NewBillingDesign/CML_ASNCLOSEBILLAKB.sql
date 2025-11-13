-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE WMS_FTEST;

DELIMITER $$

--
-- Create procedure `CML_ASNCLOSEBILLAKB`
--
CREATE
DEFINER = 'wms_ftest'@'%'
PROCEDURE CML_ASNCLOSEBILLAKB (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_asnNo varchar(30),
IN IN_USERID varchar(30),
INOUT OUT_returnCode varchar(1000))
BEGIN
  DECLARE v_error int;
  DECLARE v_errormessage varchar(1000);

  DECLARE v_NO_COMMIT char(1);
  DECLARE l_organizationId varchar(30);
  DECLARE l_warehouseId varchar(30);
  DECLARE l_customerId varchar(30);
  DECLARE l_asnNo varchar(30);
  DECLARE l_sku varchar(30);
  DECLARE l_tariffMasterId varchar(30);
  DECLARE l_spname varchar(30);

  ################### curson run ####################
  DECLARE tariffm_done boolean DEFAULT FALSE;
  DECLARE cur_tariffm CURSOR FOR
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
  WHERE atl.warehouseId = IN_warehouseId
  -- AND dah.customerId = IN_CustomerId
  AND dah.asnNo = IN_asnNo
  AND atl.transactionType = 'IN'
  AND dah.asnType NOT IN ('FREE')
  AND atl.STATUS IN ('80', '99')
  AND dah.asnStatus IN ('99')
  AND bs.skuDescr1 NOT LIKE '%PALLET%';
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariffm_done = TRUE;
  OPEN cur_tariffm;

cur_tariffm_loop:
  LOOP
    FETCH FROM cur_tariffm INTO l_organizationId, l_warehouseId, l_customerId, l_asnNo, l_sku, l_tariffMasterId;

    IF tariffm_done THEN
      SET tariffm_done = FALSE;
      LEAVE cur_tariffm_loop;
    END IF;

    SET l_spname = '';

    SELECT
      bcm.codeDescr INTO l_spname
    FROM BIL_TARIFF_HEADER bth
      INNER JOIN BIL_TARIFF_DETAILS btd
        ON bth.organizationId = btd.organizationId
        AND bth.warehouseId = btd.warehouseId
        AND bth.tariffId = btd.tariffId
      INNER JOIN BSM_CODE_ML bcm
        ON btd.organizationId = bcm.organizationId
        AND bcm.codeType = 'RAT_BASCUSTOM'
        AND bcm.codeid = btd.udf09
    WHERE bth.tariffMasterId = l_tariffMasterId
    AND TIMESTAMPDIFF(SECOND, bth.effectiveFrom, NOW()) / (60 * 60 * 24) >= 0
    AND TIMESTAMPDIFF(SECOND, bth.effectiveTo, NOW()) / (60 * 60 * 24) <= 0
    AND btd.docType IN (SELECT
        dah.asnType
      FROM DOC_ASN_HEADER dah
      WHERE dah.asnNo = l_asnNo);

    -- INSERT INTO  CML_TEMP_LOG VALUES(CONCAT(NOW(),'--MASUK'));
    --   SELECT l_spname AS spname;
    IF EXISTS (SELECT
          1
        FROM BSM_CONFIG_RULES bcr
        WHERE bcr.customerId = l_customerId
        AND bcr.configId = '3PL_CUST'
        AND bcr.configValue = 'Y'
        AND bcr.activeFlag = 'Y') THEN
      IF LENGTH(l_spname) > 0 THEN
        SET @CMD = CONCAT("CALL ", l_spname, "(", '"', @IN_organizationId, '"', ",", '"', @IN_warehouseId, '"', ",", '"', @IN_USERID, '"', ",", '"EN"', ",", '"', l_customerId, '"', ",", '"', @IN_asnNo, '"', ",", '"', l_tariffMasterId, '"', ")");
        --  SELECT @CMD;

        -- PREPARE statement FROM @CMD;

        --   EXECUTE statement;

        --  DEALLOCATE PREPARE statement;


        --  CALL CML_BILLHIDOSTD(l_organizationId,l_warehouseId,'UDF','EN',l_customerId,l_asnNo,l_tariffMasterId,OUT_returnCode);

        -- INSERT INTO CML_TEMP_LOG VALUES(CONCAT(l_organizationId,l_warehouseId,l_customerId,l_asnNo,l_tariffMasterId));

        CALL CML_BILLHIDOSTD("OJV_CML", "CBT01", "EDI", "EN", "ADISUKSES", "ADISUKSES_ASNNO00037", "ADISUKSES");


        SET OUT_returnCode = '000';
      END IF;
    END IF;

  END LOOP cur_tariffm_loop;
  CLOSE cur_tariffm;

  SET OUT_returnCode = '000';
END
$$

DELIMITER ;