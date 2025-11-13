USE WMS_FTEST;

DROP PROCEDURE IF EXISTS CML_EXECBILLHO;

DELIMITER $$

CREATE
DEFINER = 'wms_ftest'@'%'
PROCEDURE CML_EXECBILLHO (IN IN_bizOrgId varchar(20),
IN IN_bizWarehouseId varchar(20),
INOUT OUT_returnCode varchar(1000))
END_PROC:
BEGIN
  DECLARE v_error int;
  DECLARE v_errormessage varchar(1000);

  DECLARE v_NO_COMMIT char(1);
  DECLARE l_organizationId varchar(30);
  DECLARE l_warehouseId varchar(30);
   DECLARE l_customerId varchar(30);
  DECLARE l_docNo varchar(30);
  DECLARE l_docType varchar(30);
  DECLARE l_tariffMasterId varchar(30);
  DECLARE l_spname varchar(30);

  ################### curson run ####################
  DECLARE tariffm_done boolean DEFAULT FALSE;
  DECLARE cur_tariffm CURSOR FOR

  SELECT cmc.organizationId,cmc.warehouseId,cmc.CustomerId,cmc.docType,cmc.docNo,btm.tariffMasterId
  FROM CML_MIDDLEWARE_CST cmc INNER JOIN BIL_TARIFF_MASTER btm ON 
  (cmc.organizationId = btm.organizationId AND cmc.CustomerId = btm.customerId)
  WHERE cmc.udf01='N' AND cmc.transactionType='SO';

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariffm_done = TRUE;
  OPEN cur_tariffm;

cur_tariffm_loop:
  LOOP
    FETCH FROM cur_tariffm INTO l_organizationId, l_warehouseId,l_customerId,l_docType,l_docNo,l_tariffMasterId;

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
        doh.orderType
      FROM DOC_ORDER_HEADER doh
      WHERE doh.orderNo = l_docNo);

    -- INSERT INTO  CML_TEMP_LOG VALUES(CONCAT(NOW(),'--MASUK'));
       SELECT l_spname AS spname;
    IF EXISTS (SELECT
          1
        FROM BSM_CONFIG_RULES bcr
        WHERE bcr.customerId = l_customerId
        AND bcr.configId = '3PL_CUST'
        AND bcr.configValue = 'Y'
        AND bcr.activeFlag = 'Y') THEN
      IF LENGTH(l_spname) > 0 THEN
        SET @CMD = CONCAT("CALL ", l_spname, "(", '"',l_organizationId, '"', ",", '"', l_warehouseId, '"', ",", '"EDI"', ",", '"EN"', ",", '"', l_customerId, '"', ",", '"', l_docNo, '"', ",", '"', l_tariffMasterId, '"', ")");
        --  SELECT @CMD;

         PREPARE statement FROM @CMD;

         EXECUTE statement;

         DEALLOCATE PREPARE statement;

        UPDATE CML_MIDDLEWARE_CST
        set udf01='Y', editWho='EDI',editTime=NOW()
        WHERE docNo=l_docNo AND warehouseId=l_warehouseId AND CustomerId=l_customerId AND transactionType='SO';
        


        --  CALL CML_BILLHIDOSTD(l_organizationId,l_warehouseId,'UDF','EN',l_customerId,l_docNo,l_tariffMasterId,OUT_returnCode);
        -- INSERT INTO CML_TEMP_LOG VALUES(CONCAT(l_organizationId,l_warehouseId,l_customerId,l_docNo,l_tariffMasterId));
        -- CALL CML_BILLHIDOSTD("OJV_CML", "CBT01", "EDI", "EN", "ADISUKSES", "ADISUKSES_ASNNO00037", "ADISUKSES");


     
      END IF;
    END IF;

  END LOOP cur_tariffm_loop;
  CLOSE cur_tariffm;
set OUT_returnCode='000';
END
$$

DELIMITER ;