USE wms_cml;

-- SET GLOBAL log_bin_trust_function_creators = 1;
DROP FUNCTION IF EXISTS ZgetPPGPalletType;
CREATE FUNCTION ZgetPPGPalletType (p_organizationId varchar(10), p_warehouseId varchar(30), p_customerId varchar(30), p_orderNo varchar(30), p_allocationDetail varchar(20))
RETURNS varchar(10) CHARSET utf8
BEGIN
  DECLARE PLT_TYP varchar(10);
  DECLARE SO_TYP varchar(10);
  DECLARE SO_NO varchar(10);
  DECLARE COUNT_WOR int(11);
  DECLARE COUNT_PMC int(11);
  DECLARE OD_ORDERNO varchar(30);
  DECLARE OD_ORDERTYPE varchar(30);
  DECLARE OD_SKU varchar(30);
  DECLARE OD_SKUGROUP varchar(30);
  DECLARE OD_CONSIGNEEID varchar(30);

  DECLARE _GETLINEORDER CURSOR FOR
  SELECT
    dod.orderNo,
    doh.orderType,
    ald.SKU,
    bs.sku_group3,
    doh.consigneeId
  FROM ACT_ALLOCATION_DETAILS ald
    INNER JOIN DOC_ORDER_DETAILS dod
      ON ald.organizationId = dod.organizationId
      AND ald.warehouseId = dod.warehouseId
      AND ald.orderNo = dod.orderNo
      AND ald.orderLineNo = dod.orderLineNo
      AND ald.customerId = dod.customerId
      AND ald.SKU = dod.SKU
    INNER JOIN DOC_ORDER_HEADER doh
      ON ald.organizationId = doh.organizationId
      AND ald.warehouseId = doh.warehouseId
      AND ald.orderNo = doh.orderNo
      AND ald.customerId = doh.customerId
    INNER JOIN BAS_SKU bs
      ON ald.organizationId = bs.organizationId
      AND ald.SKU = bs.SKU
  WHERE ald.organizationId=p_organizationId 
  AND ald.warehouseId=p_warehouseId
  AND ald.customerId=p_customerId
  AND  ald.allocationDetailsId = p_allocationDetail;
 OPEN _GETLINEORDER;
 GETLINEORDERLOOP:
 LOOP FETCH FROM _GETLINEORDER INTO OD_ORDERNO,OD_ORDERTYPE,OD_SKU,OD_SKUGROUP,OD_CONSIGNEEID;
 BEGIN
       -- SELECT OD_ORDERNO,OD_ORDERTYPE,OD_SKU,OD_SKUGROUP,OD_CONSIGNEEID;
        END;
 END LOOP GETLINEORDERLOOP;
 CLOSE _GETLINEORDER;




  -- logic jika ada WOR

--   SELECT
--     COUNT(1) INTO COUNT_WOR
--   FROM DOC_ORDER_VAS dov
--   WHERE dov.warehouseId = p_warehouseId
--   AND dov.organizationId = p_organizationId
--   AND dov.orderNo = p_orderNo;

--   IF (COUNT_WOR > 0) THEN
--     RETURN PLT_TYP = 'P';
--   END IF;

  -- logic jika non PMC

--   SELECT
--     COUNT(1) INTO COUNT_PMC
--   FROM ACT_ALLOCATION_DETAILS aad
--     INNER JOIN BAS_SKU bs
--       ON (aad.organizationId = bs.organizationId
--       AND aad.customerId = bs.customerId
--       AND aad.SKU = bs.SKU)
--   WHERE bs.customerId = p_customerId
--   AND bs.organizationId = p_organizationId
--   AND aad.allocationDetailsId = p_allocationDetail
--   AND bs.sku_group1 NOT LIKE '%PMC%';
-- 
--   IF (COUNT_PMC > 0) THEN
--     RETURN PLT_TYP = 'P';
--   END IF;


  -- logic jika PMC RM PKG













  -- 
  --   SELECT
  --     dod.orderNo INTO SO_NO
  --   FROM DOC_ORDER_HEADER doh
  --     INNER JOIN DOC_ORDER_DETAILS dod
  --       ON doh.organizationId = dod.organizationId
  --       AND doh.warehouseId = dod.warehouseId
  --       AND doh.orderNo = dod.orderNo;







  SET PLT_TYP = OD_ORDERNO;

  RETURN PLT_TYP;
END;


