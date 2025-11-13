 SELECT
      a.organizationId,
      a.warehouseId,
      a.customerId,
      a.SKU,
      a.lotnum,
      a.locationId,
      a.TRACEID,
      a.muid,
      a.qtyOnHold,
      a.qty - a.qtyAllocated - (a.qtyOnHold + 0) - a.qtyRpOut - a.qtyMvOut AS qtyAvailed_each
    FROM INV_LOT_LOC_ID a
      LEFT JOIN BAS_SKU bas_sku
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
        WHERE organizationId = 'OJV_CML'
        AND warehouseId = 'PAPAYA'
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
    WHERE a.organizationId = 'OJV_CML'
    AND (a.qty - a.qtyAllocated - (a.qtyOnHold + 0) - a.qtyRpOut - a.qtyMvOut) > 0
    AND (a.qty > 0
    OR a.qtyRpIn > 0
    OR a.qtyMvIn > 0
    OR a.qtyPa > 0)
    AND a.warehouseId = 'PAPAYA'
    AND a.customerId = 'PAPAYA'
    AND ila.lotatt08 = 'Y'
    AND a.qtyOnHold =0;


USE WMS_FTEST;

SET @p_organizationId = 'OJV_CML';
SET @p_warehouseId = 'PAPAYA';
SET @p_customerId = 'PAPAYA';
SET @p_language = 'en';
SET @p_user = 'WM_MARDIANSAH';
SET @OUT_Return_Code = '';
CALL Z_AUTOHOLD_DMG(@p_organizationId, @p_warehouseId, @p_customerId, @p_language, @p_user, @OUT_Return_Code);
SELECT
  @OUT_Return_Code;

SET @p_organizationId = 'OJV_CML';
set @p_language='en';
set @v_idHold='';
set @OUT_Return_Code='';
 CALL SPCOM_GetIDSequence_NEW(@p_organizationId, '*', @p_language, 'INVENTORYHOLDID', @v_idHold, @OUT_Return_Code);
 SELECT @v_idHold, @OUT_Return_Code;