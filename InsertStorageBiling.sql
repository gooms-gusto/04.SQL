
INSERT INTO Z_InventoryBalance (
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
		 CAST(DATE_ADD(NOW(), INTERVAL -1 DAY) AS DATE) AS StockDate, e.cube AS CUBE, (SUM(a.qty) * e.cube) AS TotalCube, 
		e.grossWeight, e.netWeight, e.freightClass,c.locationCategory , c.locGroup1,c.locGroup2
FROM 	INV_LOT_LOC_ID a
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

GROUP BY a.customerId, a.organizationId,a.warehouseId,a.locationId,c.locationCategory,c.locGroup1,c.locGroup2, a.traceid ,a.muid , a.lotNum 
HAVING  SUM(a.qty - a.qtyallocated - a.qtyOnHold - a.qtyRpOut - a.qtyMvOut)>0    
) INV WHERE INV.warehouseId='CBT02';



SELECT * FROM wms_cml.Z_InventoryBalance zib WHERE zib.warehouseId IN ('CBT02') ORDER BY zib.addTime DESC LIMIT 1

