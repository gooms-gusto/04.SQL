SELECT
zib.customerId,
 bs.sku_group1 AS sku_type,
SUM(zib.qtyavailable) AS totalqty,
zib.StockDate
 FROM Z_InventoryBalance zib
 LEFT JOIN BAS_SKU bs ON zib.organizationId = bs.organizationId
 AND zib.customerId = bs.customerId
 WHERE DATE_FORMAT(zib.StockDate,'%Y-%m') ='2024-11' AND zib.customerId='MDS' 
 GROUP BY  zib.customerId,
 bs.sku_group1,
 zib.StockDate ORDER BY zib.StockDate;




SELECT * FROM  BAS_SKU WHERE organizationId='OJV_CML' AND customerId='MDS' AND sku='R.BG.3254'