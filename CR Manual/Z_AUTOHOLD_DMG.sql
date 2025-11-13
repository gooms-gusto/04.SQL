USE WMS_FTEST;

DROP PROCEDURE IF EXISTS Z_AUTOHOLD_DMG;

DELIMITER $$

CREATE
DEFINER = 'root'@'localhost'
PROCEDURE Z_AUTOHOLD_DMG (IN p_organizationId varchar(255),
IN p_warehouseId varchar(255),
IN p_customerId varchar(255),
IN p_language varchar(10),
IN p_user varchar(20))
BEGIN
  DECLARE done int DEFAULT FALSE;
  DECLARE v_organizationId varchar(255);
  DECLARE v_warehouseId varchar(255);
  DECLARE v_customerId varchar(255);
  DECLARE v_idHold varchar(50);
  DECLARE v_sku varchar(255);
  DECLARE v_lotNum varchar(255);
  DECLARE v_locationId varchar(255);
  DECLARE v_traceId varchar(255);
  DECLARE v_muid varchar(255);
  DECLARE v_qty_each decimal(18, 2);
  DECLARE v_fmQty decimal(18, 2);
  DECLARE v_qtyAllocated decimal(18, 2);
  DECLARE v_qtyAllocated_each decimal(18, 2);
  DECLARE v_qtyHolded decimal(18, 2);
  DECLARE v_qtyOnHold_each decimal(18, 2);
  DECLARE v_qtyAvailed_each decimal(18, 2);

  DECLARE cur CURSOR FOR
  SELECT
    a.organizationId,
    a.warehouseId,
    a.customerId,
    a.SKU,
    a.lotnum,
    a.locationId,
    a.TRACEID,
    a.muid,
    a.qty AS qty_each,
    a.qty / (
    CASE WHEN IFNULL(l12p.qty, 0) != 0 AND
        IFNULL(CASE WHEN IFNULL(bsm.reportUom, '') != '' THEN bsm.reportUom ELSE bas_sku.reportUom END, '') = 'CS' THEN l12p.qty ELSE IFNULL(t.qty, 1) END
    ) AS fmQty,
    a.qtyAllocated / (
    CASE WHEN IFNULL(l12p.qty, 0) != 0 AND
        IFNULL(CASE WHEN IFNULL(bsm.reportUom, '') != '' THEN bsm.reportUom ELSE bas_sku.reportUom END, '') = 'CS' THEN l12p.qty ELSE IFNULL(t.qty, 1) END
    ) AS qtyAllocated,
    a.qtyAllocated AS qtyAllocated_each,
    (a.qtyOnHold + 0) / (
    CASE WHEN IFNULL(l12p.qty, 0) != 0 AND
        IFNULL(CASE WHEN IFNULL(bsm.reportUom, '') != '' THEN bsm.reportUom ELSE bas_sku.reportUom END, '') = 'CS' THEN l12p.qty ELSE IFNULL(t.qty, 1) END
    ) AS qtyHolded,
    a.qtyOnHold + 0 AS qtyOnHold_each,
    a.qty - a.qtyAllocated - (a.qtyOnHold + 0) - a.qtyRpOut - a.qtyMvOut AS qtyAvailed_each
  FROM INV_LOT_LOC_ID a
    LEFT JOIN bas_sku bas_sku
      ON a.organizationId = bas_sku.organizationId
      AND bas_sku.customerId = a.customerId
      AND bas_sku.SKU = a.SKU
    LEFT JOIN BAS_CUSTOMER b
      ON a.organizationId = b.organizationId
      AND a.customerId = b.customerId
      AND b.customerType = 'OW'
    LEFT JOIN BAS_SKU_MULTIWAREHOUSE bsm
      ON a.organizationId = bsm.organizationId
      AND a.warehouseId = bsm.warehouseId
      AND a.customerId = bsm.customerId
      AND a.SKU = bsm.SKU
    LEFT JOIN BAS_PACKAGE_DETAILS t
      ON a.organizationId = t.organizationId
      AND CASE WHEN IFNULL(bsm.customerId, '') != '' THEN bsm.customerId ELSE bas_sku.customerId END = t.customerId
      AND CASE WHEN IFNULL(bsm.PACKID, '') != '' THEN bsm.PACKID ELSE bas_sku.PACKID END = t.PACKID
      AND CASE WHEN IFNULL(bsm.reportUom, '') != '' THEN bsm.reportUom ELSE bas_sku.reportUom END = t.packUom
    LEFT JOIN BAS_LOCATION d
      ON a.organizationId = d.organizationId
      AND a.warehouseId = d.warehouseId
      AND a.locationId = d.locationId
    LEFT JOIN BAS_ZONE h
      ON a.organizationId = h.organizationId
      AND a.warehouseId = h.warehouseId
      AND d.zoneId = h.zoneId
    LEFT JOIN BAS_ZONEGROUP BAS_ZONEGROUP
      ON a.organizationId = BAS_ZONEGROUP.organizationId
      AND a.warehouseId = BAS_ZONEGROUP.warehouseId
      AND h.zoneGroup = BAS_ZONEGROUP.zoneGroup
    LEFT JOIN INV_LOT_ATT ila
      ON a.organizationId = ila.organizationId
      AND a.lotnum = ila.lotnum
    LEFT JOIN BAS_PACKAGE_DETAILS l12p
      ON ila.organizationId = l12p.organizationId
      AND ila.customerId = l12p.customerId
      AND ila.lotatt12 = l12p.PACKID
      AND l12p.packUom = 'CS'
    LEFT JOIN (SELECT
        organizationId,
        warehouseId,
        locationId,
        lotnum,
        TRACEID,
        SUM(IFNULL(TOQTY, 0) - IFNULL(qty, 0)) AS toAdjQty
      FROM DOC_ADJ_DETAILS
      WHERE organizationId = p_organizationId
      AND warehouseId = p_customerId
      AND adjLineStatus < '10'
      GROUP BY organizationId,
               warehouseId,
               locationId,
               lotnum,
               TRACEID) adj
      ON adj.organizationId = a.organizationId
      AND adj.warehouseId = a.warehouseId
      AND adj.locationId = a.locationId
      AND adj.lotnum = a.lotnum
      AND adj.TRACEID = a.TRACEID
  WHERE a.organizationId = p_organizationId
  AND (a.qty > 0
  OR a.qtyRpIn > 0
  OR a.qtyMvIn > 0
  OR a.qtyPa > 0)
  AND a.warehouseId = p_warehouseId
  AND a.customerId = p_customerId
  AND ila.lotatt08 = 'Y'
  AND a.qtyOnHold = 0;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;

read_loop:
  LOOP
    FETCH cur INTO v_organizationId, v_warehouseId, v_customerId, v_sku, v_lotNum, v_locationId, v_traceId, v_muid, v_qty_each, v_fmQty, v_qtyAllocated, v_qtyAllocated_each, v_qtyHolded, v_qtyOnHold_each, v_qtyAvailed_each;
    IF done THEN
      LEAVE read_loop;
    END IF;

    -- Akbar Process data here. you can print the values==>
    SELECT
      v_organizationId,
      v_warehouseId,
      v_customerId,
      v_sku,
      v_lotNum,
      v_locationId,
      v_traceId,
      v_muid,
      v_qty_each,
      v_fmQty,
      v_qtyAllocated,
      v_qtyAllocated_each,
      v_qtyHolded,
      v_qtyOnHold_each,
      v_qtyAvailed_each;



    UPDATE INV_LOT_LOC_ID
    SET onHoldLocker = IFNULL(onHoldLocker, 0) + 1,
        qtyOnHold = v_qtyAvailed_each,
        editWho = p_user(),
        currentVersion = currentVersion + 1,
        editTime = NOW()
    WHERE organizationId = p_organizationId AND customerId=v_customerId
    AND warehouseId = p_warehouseId
    AND lotnum = v_lotNum
    AND locationId = v_locationId
    AND TRACEID = v_traceId;


 update INV_LOT INNER JOIN 
 ( SELECT Sum(QtyOnHold) qty,LotNum,organizationId,warehouseId
 FROM INV_LOT_LOC_ID h1  WHERE h1.organizationId=v_organizationId
 AND h1.warehouseId=v_warehouseId AND h1.LotNUM = v_lotNum
 AND h1.locationId = v_locationId AND h1.traceId = v_traceId
 group by LotNum,organizationId,warehouseId ) x  
 set editWho=p_user,editTime=NOW(), currentVersion=currentVersion+1 ,
 INV_LOT.QtyOnHold = x.qty  where INV_LOT.organizationId = x.organizationId AND
 INV_LOT.warehouseId = x.warehouseId and INV_LOT.LotNum = x.LotNum  AND
 INV_LOT.organizationId=p_organizationId AND INV_LOT.warehouseId=p_warehouseId;

 CALL SPCOM_GetIDSequence_NEW(p_organizationId, '*',p_warehouseId, 'INVENTORYHOLDID', v_idHold, OUT_returnCode);

    INSERT INTO `ACT_INVENTORYHOLD` (`organizationid`,`warehouseid`,`inventoryholdid`,`holdflag`,`holdby`,
    `holdcode`,`holdreason`,`customerid`,`sku`,`lotnum`,`locationid`,`traceid`,`qtyonhold`,`dateon`,`whoon`,
    `transactionid`,`oprseqflag`,
    `addwho`,`editwho`,`addtime`,`edittime`) 
    VALUES(p_organizationId,v_warehouseId,'HL2501230001','Y','5','DM','DM',
    v_customerId,v_sku,v_lotNum,v_locationId,v_traceId,v_qtyAvailed_each ,NOW(),
    p_user ,'*','20250123150131000562RA172031009087[A2503]'
    ,p_user , p_user,NOW(),NOW());


 INSERT INTO ACT_TRANSACTION_LOG (organizationId, TransactionID, QC_TaskID, QCSequence, QCFlag, PATaskID, PASequence, PAFlag
        , TransactionType, DocNo, DocLineNo, DocType
        , FMCustomerID, FMSku
        , FMLotNum, FMLocation, FMID, FMPackID, FMUOM, FMQty, FMQty_Each
        , ToCustomerID, ToSku
        , ToLotNum, ToLocation, ToID, ToPackID, ToUOM, ToQty, ToQty_Each
        , STATUS
        , TotalCubic, TotalGrossWeight, TotalNetWeight, TotalPrice
        , ReasonCode, Reason
        , WarehouseID
        , ADDTIME, AddWho, EditTime, EditWho, TransactionTime
        , Edisendflag
        , Operator)
          VALUES (p_organizationId, r_TransactionID, '*', 0, 'N', '*', '0', 'N', r_HoldRelease, '', 5, '*',
          p_customerId, v_sku, v_lotNum, v_locationId, v_traceId, '*', 'EA', ABS(R_QtyOnHold - R_QtyOnHold_Before),
          ABS(R_QtyOnHold - R_QtyOnHold_Before), v_customerId, v_sku, v_lotNum, v_locationId, v_traceId, '*', 'EA', 
          ABS(R_QtyOnHold - R_QtyOnHold_Before), ABS(R_QtyOnHold - R_QtyOnHold_Before), '99', 0, 0, 0, 0, 
          NULL, NULL, p_warehouseId, NOW(), p_user, NOW(), p_user, NOW(), r_UDF2, p_user);



  END LOOP;

  CLOSE cur;

END
$$

DELIMITER ;