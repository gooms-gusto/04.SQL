SELECT ziba.organizationId, ziba.warehouseId, ziba.customerId,
ziba.sortirId, ziba.sku, SUM(ziba.qtyEach) AS qty, SUM(BS.`cube`) AS cbm_persku,
(SUM(ziba.qtyEach) * SUM(BS.`cube`)) AS total_cbm, ziba.stockDate
FROM Z_InventoryBalance_preASN ziba
     INNER JOIN
     Z_SORTIR_INBOUND_HEADER zsih
     ON ziba.organizationId = zsih.organizationId AND
       ziba.warehouseId = zsih.warehouseId AND
       ziba.sortirId = zsih.sortirId AND
       ziba.customerId = zsih.customerId
     INNER JOIN
     BAS_SKU BS
     ON ziba.organizationId = BS.organizationId AND
       ziba.customerId = BS.customerId AND
       ziba.sku = BS.sku
WHERE ziba.organizationId = 'OJV_CML' AND
      ziba.stockDate >= DATE(zsih.addTime) AND
      ziba.stockDate < DATE(IFNULL(zsih.completedTime, NOW()))
-- AND ziba.sortirId='STR0000001251108'
GROUP BY ziba.organizationId, ziba.warehouseId, ziba.customerId, 
ziba.sortirId, ziba.sku, ziba.stockDate;



-- SELECT *
-- FROM Z_SORTIR_INBOUND_HEADER
-- WHERE organizationId = 'OJV_CML' AND
--       warehouseId = 'CBT02' AND
--       customerId = 'MAP' AND
--       sortirId = 'STR00000000001251114'