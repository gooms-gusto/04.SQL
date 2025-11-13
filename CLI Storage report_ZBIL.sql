SELECT
  DATE_FORMAT(StockDate, '%Y-%m-%d') AS stockDate,
  zba.warehouseId AS warehouseId,
  zib.customerId,
  zib.freightClass,
  zib.sku,
  SKUDesc AS skuDesc,
  UOM,
  sku_group6,
  qtyonHand,
  (zib.cube / 1000000) AS cbm,
  zib.totalCube / 1000000 AS totalcbm,
  CONVERT(DATEDIFF(zib.stockDate, CONVERT(ila.lotAtt03, date)), SIGNED) AS aging,
  CASE WHEN zba.storageBy = 'MONTH' THEN CASE WHEN zib.customerId LIKE "ECING%" THEN ROUND(((zib.totalCube / 1000000) * zba.`storage`), 4) WHEN (zib.customerId = 'RBIZ' AND
            CONVERT(DATEDIFF(zib.stockDate, CONVERT(ila.lotAtt03, date)), SIGNED) < 90) THEN 0 WHEN (zib.customerId = 'RBIZNAMEERA' AND
            CONVERT(DATEDIFF(zib.stockDate, CONVERT(ila.lotAtt03, date)), SIGNED) < 90) THEN 0 WHEN (zib.customerId LIKE "RBIZ%" AND
            CONVERT(DATEDIFF(zib.stockDate, CONVERT(ila.lotAtt03, date)), SIGNED) >= 90) THEN ROUND(((zib.totalCube / 1000000) * zba.`storage`), 4) WHEN (zib.totalCube / 1000000) < 1 AND
            zib.customerId = 'ECZAP' THEN ROUND(((zib.totalCube / 1000000)) * (zba.`storage` / '30'), 4) WHEN zib.customerId IN ('ECCLOX', 'ECLILI', 'ECTANG', 'ECX3ENG') THEN ROUND((zba.storageDay * (zib.totalCube / 1000000)), 4) ELSE ROUND((zib.totalCube / 1000000) * (zba.`storage` / '30'), 2) END ELSE CASE WHEN (zib.customerId = 'ECTUP' AND
          s.sku_group6 = '') THEN ROUND((zib.totalCube / 1000000) * (zba.`storage` / '30'), 2) WHEN (zib.customerId = 'ECTUP' AND
          s.sku_group6 = 'ACCESSORIES') THEN ROUND(qtyonHand * storageDay, 2) WHEN zib.customerId IN ('ECCLOX', 'ECLILI', 'ECTANG', 'ECX3ENG', 'ECZAP', 'ECZAP_2') THEN ROUND((zba.storageDay * (zib.totalCube / 1000000)), 4) ELSE qtyonHand * storageDay END END AS storageCharge
FROM Z_InventoryBalance_BILL zib
  LEFT JOIN Z_BIL_Aggrement zba
    ON zba.organizationId = zib.organizationId
    AND zba.warehouseId = zib.warehouseId
    AND zba.customerId = zib.customerId
  LEFT JOIN BAS_SKU s
    ON s.organizationId = zib.organizationId
    AND s.customerId = zib.customerId
    AND s.sku = zib.sku
  LEFT JOIN INV_LOT_ATT ila
    ON zib.organizationId = ila.organizationId
    AND zba.organizationId = ila.organizationId
    AND zib.lotNum = ila.lotNum
    AND zib.customerId = ila.customerId
    AND zib.sku = ila.sku
WHERE zib.organizationId = 'ID_8COM'
AND zib.qtyonHand > 0
AND zib.customerId = 'ECTUP'
AND StockDate BETWEEN '2022-06-20' AND '2022-06-25'
AND zib.warehouseId = 'WHPGD01'
AND zib.sku != 'FULLCARTON'
AND 1 = 1
ORDER BY StockDate DESC, zib.customerId, SKUDesc