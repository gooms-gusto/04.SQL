USE WMS_FTEST;

DROP PROCEDURE IF EXISTS CML_SOCLOSEBILLAKB;

DELIMITER $$

CREATE
DEFINER = 'wms_ftest'@'%'
PROCEDURE CML_SOCLOSEBILLAKB(IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_orderNo varchar(30),
INOUT OUT_returnCode varchar(1000))
BEGIN
  DECLARE v_error int;
  DECLARE v_errormessage varchar(1000);
  
  DECLARE v_NO_COMMIT char(1);
  DECLARE l_organizationId varchar(30);
  DECLARE l_warehouseId varchar(30);
  DECLARE l_customerId varchar(30);
  DECLARE l_orderNo varchar(30);
  DECLARE l_sku varchar(30);
  DECLARE l_tariffMasterId varchar(30);
  DECLARE l_spname varchar(30);
   
################### curson run ####################
 DECLARE tariffm_done boolean DEFAULT FALSE;
 DECLARE cur_tariffm CURSOR FOR
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
            WHERE aad.customerId = IN_CustomerId
            AND aad.warehouseId = IN_warehouseId
			       AND aad.orderNo=IN_orderNo
            AND aad.Status IN ('99', '80')
            AND bs.skuDescr1 NOT LIKE '%PALLET%'
            AND doh.orderType NOT IN ('FREE', 'KT');

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariffm_done = TRUE;
  OPEN cur_tariffm;

cur_tariffm_loop:
  LOOP
    FETCH FROM cur_tariffm INTO l_organizationId,l_warehouseId,l_customerId,l_orderNo,l_sku,l_tariffMasterId;

    IF tariffm_done THEN
      SET tariffm_done = FALSE;
      LEAVE cur_tariffm_loop;
    END IF;

  set l_spname='';

  SELECT bcm.codeDescr into l_spname
  FROM BIL_TARIFF_HEADER bth INNER JOIN BIL_TARIFF_DETAILS btd
  ON bth.organizationId = btd.organizationId AND bth.warehouseId = btd.warehouseId
  AND bth.tariffId=btd.tariffId
  INNER JOIN BSM_CODE_ML bcm
  ON btd.organizationId = bcm.organizationId
  AND bcm.codeType='RAT_BASCUSTOM'
  AND bcm.codeid=btd.udf09
  WHERE bth.tariffMasterId=l_tariffMasterId 
   AND TIMESTAMPDIFF(SECOND, bth.effectiveFrom, NOW()) / (60 * 60 * 24) >= 0
  AND TIMESTAMPDIFF(SECOND, bth.effectiveTo, NOW()) / (60 * 60 * 24) <= 0
  AND btd.docType IN (SELECT
      doh.orderType
    FROM DOC_ORDER_HEADER doh
    WHERE doh.orderNo = IN_orderNo);
  
  
 -- SELECT l_spname AS spname;

  IF LENGTH(l_spname) >0 THEN
  SET @CMD = CONCAT("CALL ",l_spname,"(",'"',@IN_organizationId,'"',",",'"', @IN_warehouseId,'"',",",'"', @IN_USERID,'"',",",'"', @IN_Language,'"',",",'"', @IN_CustomerId,'"',",",'"',@IN_orderNo,'"',",",'"',l_tariffMasterId,'"',")");
 -- SELECT @CMD;
 PREPARE statement FROM @CMD;

  EXECUTE statement;

 DEALLOCATE PREPARE statement;

  set OUT_returnCode='Processed SP';
  END IF;


  END LOOP cur_tariffm_loop;
      CLOSE cur_tariffm;

set OUT_returnCode='Nothing Processed';
END
$$

DELIMITER ;