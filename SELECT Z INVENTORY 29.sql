	INSERT INTO wms_cml.Z_InventoryBalance
		(organizationId,
		customerId,
		warehouseid,
		locationId,
		traceId,
		muid,
		lotNum,
		sku,
		qtyonHand,
		packkey,
		UOM,
		qtyallocated,
		qtyonHold,
		qtyavailable,
		qtyPicked,
		SKUDesc,
		StockDate,
		`cube`,
		totalCube,
		grossWeight,
		netWeight,
		freightClass,
		locationcategory,
		locGroup1,
		locGroup2,
		addWho,
		ADDTIME)
SELECT a.organizationId,
		a.customerId AS customer,
		a.warehouseId,
		a.locationId,
		a.traceId,
		a.muid,
		a.lotNum,
		a.sku AS sku,
		a.qty AS qtyonHand,
		d.packId AS packkey,
		d.uomdescr AS UOM,
		a.qtyallocated AS qtyallocated,
		a.qtyOnHold AS qtyonHold,
		(a.qty - a.qtyallocated - a.qtyOnHold - a.qtyRpOut - a.qtyMvOut) AS qtyavailable,
		(CASE WHEN c.locationusage = 'SS' THEN a.qtyallocated ELSE 0 END) AS qtyPicked,
		e.skuDescr1 AS SKUDesc,
	--	CAST(DATE_ADD(NOW(), INTERVAL - 1 DAY) AS DATE) AS StockDate,
	 '2022-07-01' AS StockDate,
		e.cube /*AS CUBE*/,
		CAST((a.qty * e.cube) AS DECIMAL(24,8))  AS TotalCube,
		e.grossWeight,
		e.netWeight,
		e.freightClass,
		c.locationCategory,
		c.locGroup1,
		c.locGroup2,
		'UDFSYSTEM' AS addWho, 
		NOW() AS ADDTIME
	FROM INV_LOT_LOC_ID.INV_LOT_LOC_ID_02 a
	LEFT JOIN wms_cml.BAS_LOCATION c ON c.organizationId = a.organizationId
	AND c.warehouseId = a.warehouseId
	AND c.locationid = a.locationid
	LEFT JOIN wms_cml.BAS_LOCGROUP1 bl1 ON bl1.warehouseId = c.warehouseId
	AND bl1.organizationId = c.organizationId
	AND bl1.locGroup1 = c.locGroup1
	LEFT JOIN wms_cml.BAS_SKU e ON a.organizationId = e.organizationId
	AND a.customerId = e.customerId
	AND a.sku = e.sku
	LEFT JOIN wms_cml.BAS_PACKAGE_DETAILS d
	ON d.organizationId = e.organizationId
	AND d.customerId = e.customerId
	AND d.packId = e.packId
	AND d.packUom = 'EA'
	WHERE a.qty + a.qtyPa +a.qtyRpIn +a.qtyMvIn >0