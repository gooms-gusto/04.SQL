SELECT
  a.organizationId,
  a.warehouseId,
  a.customerId,
  a.sku,
  bas_sku.packId,
  a.locationId,
  a.lotNum AS fmLotnum,
  a.traceId AS fmId,
  a.qty AS qty_each,
  a.qty / (
  CASE WHEN IFNULL(l12p.qty, 0) != 0 AND
      IFNULL(
      CASE WHEN IFNULL(bsm.reportUom, '') != '' THEN bsm.reportUom ELSE bas_sku.reportUom END,
      '') = 'CS' THEN l12p.qty ELSE IFNULL(t.qty, 1) END) AS fmQty,
  a.qtyAllocated / (
  CASE WHEN IFNULL(l12p.qty, 0) != 0 AND
      IFNULL(
      CASE WHEN IFNULL(bsm.reportUom, '') != '' THEN bsm.reportUom ELSE bas_sku.reportUom END,
      '') = 'CS' THEN l12p.qty ELSE IFNULL(t.qty, 1) END) AS qtyAllocated,
  a.qtyAllocated AS qtyAllocated_each,
  (a.qtyOnHold + 0) / (
  CASE WHEN IFNULL(l12p.qty, 0) != 0 AND
      IFNULL(
      CASE WHEN IFNULL(bsm.reportUom, '') != '' THEN bsm.reportUom ELSE bas_sku.reportUom END,
      '') = 'CS' THEN l12p.qty ELSE IFNULL(t.qty, 1) END) AS qtyHolded,
  a.qtyOnHold + 0 AS qtyOnHold_each,
  CASE WHEN a.cubic < 0 THEN 0 ELSE a.cubic END AS totalCubic,
  CASE WHEN a.grossWeight < 0 THEN 0 ELSE a.grossWeight END AS totalGrossWeight,
  CASE WHEN a.netWeight < 0 THEN 0 ELSE a.netWeight END AS totalNetWeight,
  a.qty / (
  CASE WHEN IFNULL(l12p.qty, 0) != 0 THEN l12p.qty ELSE IFNULL(t.qty, 1) END) -
  a.qtyAllocated /
  (
  CASE WHEN IFNULL(l12p.qty, 0) != 0 
       THEN l12p.qty ELSE IFNULL(t.qty, 1) END) -
  (a.qtyOnHold +
  0) /
  (
  CASE WHEN IFNULL(l12p.qty, 0) != 0 THEN l12p.qty ELSE IFNULL(t.qty, 1) END) -
  a.qtyRpOut /
  (
  CASE WHEN IFNULL(l12p.qty, 0) != 0 
       THEN l12p.qty ELSE IFNULL(t.qty, 1) END) -
  a.qtyMvOut /
  (
  CASE WHEN IFNULL(l12p.qty, 0) != 0  THEN l12p.qty ELSE IFNULL(t.qty, 1) END) AS qty_available_cs,
  a.qty - a.qtyAllocated - (a.qtyOnHold + 0) - a.qtyRpOut - a.qtyMvOut AS qty_available_ea,
l12p.uomDescr AS uom_cs_dscr,
  bas_sku.skuDescr1,
  bas_sku.skuDescr2,
  ila.lotAtt01,
  ila.lotAtt02,
  ila.lotAtt03,
  ila.lotAtt04,
  ila.lotAtt05,
  ila.lotAtt06,
  ila.lotAtt07,
  ila.lotAtt08,
  ila.lotAtt09,
  ila.lotAtt10,
  ila.lotAtt11,
  ila.lotAtt12,
  ila.lotAtt13,
  t.packUom,
  t.uomDescr AS fmUom_name,
  DATE_FORMAT(a.addTime, '%Y-%m-%d %T') AS addTime,
  a.editWho,
  DATE_FORMAT(a.editTime, '%Y-%m-%d %T') AS editTime,
  a.qtyMvIn,
  a.qtyMvOut,
  a.qtyPa,
  a.addWho
FROM INV_LOT_LOC_ID a
  LEFT JOIN BAS_SKU bas_sku
    ON a.organizationId = bas_sku.organizationId
    AND bas_sku.customerId = a.customerId
    AND bas_sku.sku = a.sku
  LEFT JOIN BAS_CUSTOMER b
    ON a.organizationId = b.organizationId
    AND a.customerId = b.customerId
    AND b.customerType = 'OW'
  LEFT JOIN BAS_SKU_MULTIWAREHOUSE bsm
    ON a.organizationId = bsm.organizationId
    AND a.warehouseId = bsm.warehouseId
    AND a.customerId = bsm.customerId
    AND a.sku = bsm.sku
  LEFT JOIN BAS_PACKAGE_DETAILS t
    ON a.organizationId = t.organizationId
    AND CASE WHEN IFNULL(bsm.customerId, '') != '' THEN bsm.customerId ELSE bas_sku.customerId END
    = t.customerId
    AND CASE WHEN IFNULL(bsm.packId, '') != '' THEN bsm.packId ELSE bas_sku.packId END = t.packId
    AND CASE WHEN IFNULL(bsm.reportUom, '') != '' THEN bsm.reportUom ELSE bas_sku.reportUom END =
    t.packUom
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
    AND a.lotNum = ila.lotNum
  LEFT JOIN BAS_PACKAGE_DETAILS l12p
    ON bas_sku.organizationId = l12p.organizationId
    AND bas_sku.customerId = l12p.customerId
    AND bas_sku.packId = l12p.packId
    AND l12p.packUom = 'CS'
  LEFT JOIN (SELECT
      organizationId,
      warehouseId,
      locationId,
      lotNum,
      traceId,
      SUM(IFNULL(toQty, 0) - IFNULL(qty, 0)) AS toAdjQty
    FROM DOC_ADJ_DETAILS
    WHERE organizationId = 'ID_8COM'
    AND warehouseId = 'WHPGD01'
    AND adjLineStatus < '10'
    GROUP BY organizationId,
             warehouseId,
             locationId,
             lotNum,
             traceId) adj
    ON adj.organizationId = a.organizationId
    AND adj.warehouseId = a.warehouseId
    AND adj.locationId = a.locationId
    AND adj.lotNum = a.lotNum
    AND adj.traceId = a.traceId
WHERE a.organizationId = 'ID_8COM'
AND (
a.qty > 0
OR a.qtyRpIn > 0
OR a.qtyMvIn > 0
OR a.qtyPa > 0
)
AND a.warehouseId = 'WHPGD01'
AND a.customerId = 'ECCLOX' 
-- AND a.qty - a.qtyAllocated - (a.qtyOnHold + 0) - a.qtyRpOut - a.qtyMvOut > 0



-- SELECT * FROM INV_LOT_ATT ila WHERE ila.customerId='DNN_MDN';








/*
AND a.warehouseId = '@{bizWarehouseId}'
AND a.customerId = '${CHECK.customerId}'
AND a.lotNum IN ('${CHECK.lotNum}')
*/