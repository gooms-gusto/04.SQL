SELECT * FROM  wms_cml.Z_InventoryBalance_XX WHERE customerId='SASA';

SELECT COUNT(*) FROM Z_InventoryBalance_XX zibx WHERE zibx.StockDate BETWEEN '2022-06-29 00:00:00' AND '2022-06-29 23:59:59';


DELETE FROM Z_InventoryBalance
WHERE StockDate BETWEEN '2022-06-29 00:00:00' AND '2022-06-29 23:59:59';

SELECT COUNT(*) FROM Z_InventoryBalance_XX zibx WHERE zibx.StockDate BETWEEN '2022-06-30 00:00:00' AND '2022-06-30 23:59:59';


SELECT COUNT(*) FROM Z_InventoryBalance zibx WHERE zibx.StockDate BETWEEN '2022-06-29 00:00:00' AND '2022-06-29 23:59:59';

SELECT COUNT(*) FROM Z_InventoryBalance zibx WHERE zibx.StockDate BETWEEN '2022-06-30 00:00:00' AND '2022-06-30 23:59:59';



-- wms_cml.INV_LOT_LOC_ID_290622;
-- wms_cml.INV_LOT_LOC_ID_300622

INSERT INTO Z_InventoryBalance(
organizationId, customerId, warehouseid,locationId,traceId,muid, lotNum, sku, qtyonHand, packkey, UOM, qtyallocated, qtyonHold, qtyavailable, qtyPicked, SKUDesc,
StockDate, CUBE, totalCube, grossWeight, netWeight, freightClass, locationcategory , locGroup1 , locGroup2, addWho, ADDTIME)
SELECT *, 'UDFSYSTEM' AS addWho, NOW() AS ADDTIME FROM (
SELECT 	a.organizationId, a.customerId  AS customer    , a.warehouseId ,a.locationId ,traceId, muid,lotNum, 
        a.sku                                                               AS sku         ,
        SUM(a.qty)                                                          AS qtyonHand   ,
        d.packId                                                            AS packkey     ,
        d.uomdescr                                                          AS UOM         ,
        SUM(a.qtyallocated)                                                 AS qtyallocated,
        SUM(a.qtyOnHold)                                                    AS qtyonHold   ,
        SUM(a.qty - a.qtyallocated - a.qtyOnHold - a.qtyRpOut - a.qtyMvOut) AS qtyavailable,
        IFNULL(SUM(CASE WHEN c.locationusage = 'SS' THEN a.qtyallocated END), 0) AS qtyPicked,
        e.skuDescr1                                                           AS SKUDesc,
		 '2022-06-29' AS StockDate, e.cube AS CUBE, 
  CAST((SUM(a.qty) * e.cube)AS DECIMAL(24,8)) AS TotalCube,
  -- (SUM(a.qty) * e.cube) AS TotalCube, *remark 01/07/22 ID (need validation truncate data)
		e.grossWeight, e.netWeight, e.freightClass,c.locationCategory , c.locGroup1,c.locGroup2
FROM 	INV_LOT_LOC_ID_290622 a
LEFT JOIN BAS_LOCATION c ON c.organizationId  = a.organizationId AND c.warehouseId = a.warehouseId AND c.locationid  = a.locationid
LEFT JOIN BAS_LOCGROUP1 bl1 ON bl1.warehouseId=c.warehouseId AND bl1.organizationId=c.organizationId AND bl1.locGroup1=c.locGroup1
LEFT JOIN BAS_SKU e
ON
        a.organizationId = e.organizationId
        AND a.customerId = e.customerId
        AND a.sku        = e.sku
LEFT JOIN BAS_PACKAGE_DETAILS d
ON
        a.organizationId = d.organizationId
        AND a.customerId = d.customerId
        AND e.packId     = d.packId
        AND d.packUom    = 'EA'   
GROUP BY a.customerId, a.organizationId,a.warehouseId,a.locationId,c.locationCategory,c.locGroup1,c.locGroup2, a.traceid ,a.muid , a.lotNum,a.sku
HAVING  SUM(a.qty - a.qtyallocated - a.qtyOnHold - a.qtyRpOut - a.qtyMvOut)>0    
) INV