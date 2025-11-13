INSERT INTO Z_InventoryBalance 
		(organizationId, customerId, fulfillment_center_id, sku, qtyonHand, packkey, uom, 
		qtyallocated, qtyonHold, qtyavailable, qtyPicked, SKUDesc, stockDate, 
		cube, totalCube, totalCbm, grossWeight, netWeight, freightClass, totalLocation, 
		lotNum, lotAtt03, aging, 
		addWho, addTime)
SELECT 	d.organizationId, d.customerId, fulfillment_center_id, d.sku, qtyonHand, packkey, uom, 
		qtyallocated, qtyonHold, qtyavailable, qtyPicked, SKUDesc, stockDate,
		cube, totalCube, totalCube/1000000, grossWeight, netWeight, freightClass, totalLocation, 
		d.lotNum, ifnull(la.lotAtt03, ''),  convert(DATEDIFF(stockDate, CONVERT(la.lotAtt03, DATE)), signed) AS aging, 
		'UDFSYSTEM' AS addWho, NOW() as addTime 
FROM (
	SELECT 	a.organizationId, a.customerId AS customerId, a.warehouseId as fulfillment_center_id, a.sku AS sku,
			CONVERT(SUM(a.qty), SIGNED) AS qtyonHand,
			d.packId AS packkey,
			d.uomdescr AS uom,
			CONVERT(SUM(a.qtyallocated), SIGNED) AS qtyallocated,
			CONVERT(SUM(a.qtyOnHold), SIGNED) AS qtyonHold,
			CONVERT(SUM(a.qty - a.qtyallocated - a.qtyOnHold - a.qtyRpOut - a.qtyMvOut), SIGNED) AS qtyavailable,
			CONVERT(ifnull(SUM(CASE WHEN c.locationusage = 'SS' THEN a.qtyallocated END), 0), SIGNED) AS qtyPicked,
			e.skuDescr1 AS SKUDesc,
			CAST(NOW() AS DATE) AS stockDate, e.cube as Cube, (SUM(a.qty) * e.cube) as totalCube, 
			e.grossWeight, e.netWeight, e.freightClass,
			count(a.locationId) AS totalLocation,
			min(a.lotNum) AS lotNum
	FROM 	INV_LOT_LOC_ID a
	LEFT JOIN BAS_LOCATION c ON c.organizationId = a.organizationId AND c.warehouseId = a.warehouseId AND c.locationid  = a.locationid
	LEFT JOIN BAS_SKU e ON a.organizationId = e.organizationId AND a.customerId = e.customerId AND a.sku = e.sku AND e.activeFlag='Y'
	LEFT JOIN BAS_PACKAGE_DETAILS d ON a.organizationId = d.organizationId AND a.customerId = d.customerId AND e.packId = d.packId AND d.packUom = 'EA'
	GROUP BY a.organizationId, a.customerId, a.warehouseId, a.sku, d.packId, d.uomdescr, e.skuDescr1,e.cube,e.grossWeight, e.netWeight, e.freightClass
) d
LEFT JOIN INV_LOT_ATT la ON d.organizationId = la.organizationId AND d.lotNum = la.lotNum
WHERE d.sku NOT IN ('NOSKU', 'FULLCARTON')