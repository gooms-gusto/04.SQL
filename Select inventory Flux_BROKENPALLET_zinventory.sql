SELECT 
AL.warehouseId AS WAREHOUSE_ID,
AL.customerId AS CUSTOMER_ID,
AL.sku,AL.skuDescr1 AS SKU_DESCR,
-- AL.packId AS PACKEY,
AL.qtymaksimumperpalet AS MAKS_QTY_PERPALLET,
SUM(AL.qty_available_ea) AS QTY_AVAILABLE,
AL.locationId AS LOCATIONID
-- AL.lotNum AS LOTNUM,
-- AL.locationCategory AS LOCATION_CATEGORY,
-- AL.lotAtt04 AS BATCH_SKU,
-- AL.fmId AS TRACEID
FROM(

SELECT
  a.organizationId,
  a.warehouseId,
  a.customerId,
  a.sku,
  bsm.packId,
  l13p.qty AS qtymaksimumperpalet,
  a.locationId,
  d.locationCategory,
  a.lotNum AS fmLotnum,
  a.traceId AS fmId,
  a.muid,
  a.qtyonhand AS qty_each,
  a.qtyonhand / (
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
  CASE WHEN a.cube < 0 THEN 0 ELSE a.cube END AS totalCubic,
  CASE WHEN a.grossWeight < 0 THEN 0 ELSE a.grossWeight END AS totalGrossWeight,
  CASE WHEN a.netWeight < 0 THEN 0 ELSE a.netWeight END AS totalNetWeight,

  a.qtyavailable - a.qtyonHold  AS qty_available_ea,
l12p.uomDescr AS uom_cs_dscr,
a.lotNum,
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
  a.addWho,l13p.qty as QTYPERPALLET,bas_sku.CUBE
FROM Z_InventoryBalance  a
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
    ON bsm.organizationId = l12p.organizationId
    AND bsm.customerId = l12p.customerId
    AND bsm.packId = l12p.packId
AND bsm.warehouseid=a.warehouseid
    AND l12p.packUom = 'CS'
LEFT JOIN BAS_PACKAGE_DETAILS l13p
    ON bsm.organizationId = l13p.organizationId
    AND bsm.customerId = l13p.customerId
    AND bsm.packId = l13p.packId
AND bsm.warehouseid=a.warehouseid
    AND l13p.packUom = 'PL'
  LEFT JOIN (SELECT
      organizationId,
      warehouseId,
      locationId,
      lotNum,
      traceId,
      SUM(IFNULL(toQty, 0) - IFNULL(qty, 0)) AS toAdjQty
    FROM DOC_ADJ_DETAILS
    WHERE organizationId = 'OJV_CML'
    AND warehouseId = ''
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
    AND a.StockDate='2023-08-18'
WHERE a.organizationId = 'OJV_CML'
  AND bas_sku.lotId <> 'SERIALNO' 
-- AND d.mix_flag <> 'Y'
   AND 
        a.customerId  IN (
           'MAP',
          'PPG',
         'LTL',
        'YFI',
       'ITOCHU'
       'HPK',
       'MDS',
       'PLB-LTL',
       'HPK',
       'BCA',
       'BCAFIN',
       'DNN',
        'GYVTL',
        'RBFOOD'

        )
--         AND a.sku        IN('${sku}')
--         AND a.locationId like '${locationId}'
--         AND a.traceId like '${fmId}'
AND a.warehouseid in ('CBT02','CBT01')) AL 
WHERE AL.qtymaksimumperpalet <> AL.qty_available_ea
AND AL.qty_available_ea < (0.99*AL.qtymaksimumperpalet)
-- AND AL.qty_available_ea > 0
-- AND AL.customerId='MDS'
AND AL.locationCategory IN ('SD','DD') 
-- AND AL.locationId IN (
-- 'I01C028',
-- 'I01D025',
-- 'I02A042',
-- 'I02A042'
-- )
GROUP BY  AL.warehouseId,AL.customerId,AL.sku,AL.locationId
ORDER BY AL.warehouseId,AL.customerId,AL.sku,AL.locationId