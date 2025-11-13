
 SELECT zib.organizationId,zib.warehouseId,zib.stockDate,zib.sku, SUM(zib.qtyEach) AS totalqtyRcv,
 SUM(zib.qtyEach)*bs.`cube` AS totalCBM,bs.`cube`
 FROM 
(SELECT ziba.organizationId,
ziba.warehouseId,
ziba.customerId,
ziba.stockDate AS stockDate,
DATE(zsih.addTime) AS incomingDate,
DATE(ziba.stopCalculateDate) AS  closeDateBillSortir,
ziba.sku,
ziba.qtyEach,DATEDIFF(ziba.stopCalculateDate,zsih.addTime)
FROM  Z_InventoryBalance_preASN ziba INNER JOIN
Z_SORTIR_INBOUND_HEADER zsih ON (ziba.organizationId = zsih.organizationId
AND ziba.warehouseId = zsih.warehouseId AND ziba.sortirId = zsih.sortirId AND ziba.customerId = zsih.customerId)
WHERE ziba.organizationId='OJV_CML' AND ziba.warehouseId IN ('CBT02','JBK01')
AND ziba.customerId='MAP' 
-- AND ziba.sku='000000000000150000A780'
AND (DATE(ziba.stockDate) > '2025-10-25'
AND DATE(ziba.stockDate) < '2025-11-26')
AND (DATE(ziba.stockDate) >= DATE(zsih.addTime) 
AND  DATE(ziba.stockDate) < DATE(COALESCE(ziba.stopCalculateDate,NOW())))) zib
INNER JOIN BAS_SKU bs
ON (bs.organizationId=zib.organizationId AND 
bs.sku=zib.sku AND 
bs.customerId=zib.customerId) 
GROUP BY zib.organizationId,zib.warehouseId,zib.stockDate,zib.sku






