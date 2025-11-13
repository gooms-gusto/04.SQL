USE wms_cml;

DROP FUNCTION IF EXISTS ZgetPPGPalletType;

DELIMITER $$

CREATE
DEFINER = 'sa'@'%'
FUNCTION ZgetPPGPalletType (p_organizationId varchar(10), p_warehouseId varchar(30), p_customerId varchar(30), p_orderNo varchar(30), p_allocationDetail varchar(20))
RETURNS varchar(50) CHARSET utf8
BEGIN
  DECLARE PLT_TYP varchar(50);
  DECLARE SO_TYP varchar(50);
  DECLARE SO_NO varchar(50);
  DECLARE COUNT_WOR int(11);
  DECLARE COUNT_PMC int(11);
  DECLARE OD_ORDERNO varchar(50);
  DECLARE OD_ORDERTYPE varchar(50);
  DECLARE OD_SKU varchar(50);
  DECLARE OD_SKUGROUP varchar(50);
  DECLARE OD_CONSIGNEEID varchar(50);
  DECLARE OD_TRACEID varchar(50);
  DECLARE OD_QTY_EA decimal(18, 8);
  DECLARE OD_QTY_EA_INBOUND decimal(18, 8);
  DECLARE OD_CURSORDONE boolean DEFAULT FALSE;
  DECLARE _GETLINEORDER CURSOR FOR
  SELECT
    dod.orderNo,
    doh.ordertype,
    ald.SKU,
    bs.sku_group1,
    doh.consigneeId,
    ald.TRACEID,
    ald.qty_Each
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
  WHERE ald.organizationId = p_organizationId
  AND ald.warehouseId = p_warehouseId
  AND ald.customerId = p_customerId
  AND ald.allocationDetailsId = p_allocationDetail;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET OD_CURSORDONE = TRUE;
  OPEN _GETLINEORDER;
GETLINEORDERLOOP:
  LOOP FETCH FROM _GETLINEORDER INTO OD_ORDERNO, OD_ORDERTYPE, OD_SKU, OD_SKUGROUP, OD_CONSIGNEEID, OD_TRACEID, OD_QTY_EA;
    IF OD_CURSORDONE THEN
      SET OD_CURSORDONE = FALSE;
      LEAVE GETLINEORDERLOOP;
    END IF;

    BEGIN
    -- SELECT OD_ORDERNO,OD_ORDERTYPE,OD_SKU,OD_SKUGROUP,OD_CONSIGNEEID;
    END;
  END LOOP GETLINEORDERLOOP;
  CLOSE _GETLINEORDER;

  -- logic if qty trace ID INBOUND same or not
  SELECT
    SUM(atl.fmQty_Each) INTO OD_QTY_EA_INBOUND
  FROM ACT_TRANSACTION_LOG atl
  WHERE atl.organizationId = p_organizationId
  AND atl.warehouseId = p_warehouseId
  AND atl.FMCustomerID = p_customerId
  AND atl.transactionType = 'PA'
  AND atl.fmId = OD_TRACEID;

 

  IF (OD_SKUGROUP NOT LIKE '%PMC%') THEN

    -- IF IBC TANK
    IF (OD_SKU = 'KR-E6461/ID/1000K') THEN
      SET PLT_TYP = 'PALLETIZE';
      RETURN PLT_TYP;
    END IF;
     SET PLT_TYP = 'LOOSE';
    RETURN PLT_TYP;
  ELSEIF (OD_SKUGROUP = 'PMC-RM-PKG') THEN
    SET PLT_TYP = 'LOOSE';
    RETURN PLT_TYP;
  ELSE -- IF PMC
     SET PLT_TYP = 'PALLETIZE';
    RETURN PLT_TYP;
  END IF;

 -- #if consignee singapore or vietnam
  IF (OD_CONSIGNEEID IN ('GSG909', 'GVN0921', 'PPG-HCM', 'PPG-SGP', 'PSG01', 'PUS82', 'PVN01', 'PVN02')) THEN
    IF (OD_QTY_EA_INBOUND = OD_QTY_EA) THEN
      SET PLT_TYP = 'PALLETIZE';
      RETURN PLT_TYP;
    ELSE
      SET PLT_TYP = 'LOOSE';
      RETURN PLT_TYP;
    END IF;

    SET PLT_TYP = 'PALLETIZE';
    RETURN PLT_TYP;
  END IF;
  IF (OD_SKU IN ('01056127','00044893','00088956','00098095','01043662','01050380','01164644','01268008')) THEN
      SET PLT_TYP = 'LOOSE';
      RETURN PLT_TYP;
    END IF;

    IF (SO_TYP='IT') THEN
      SET PLT_TYP = 'LOOSE';
      RETURN PLT_TYP;
    END IF;

-- OTHER
      SET PLT_TYP = 'LOOSE';
      RETURN PLT_TYP;
END
$$

DELIMITER ;