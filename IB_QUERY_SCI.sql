SELECT customer, fulfillment_center_id, sku, SUM(qtyonHand) AS qtyonHand, SUM(qtyallocated) AS qtyallocated, SUM(qtyonHold) AS qtyonHold, SUM(qtyavailable) AS qtyavailable
FROM
(
	SELECT customer, fulfillment_center_id, replace(sku, '\n', '') AS sku, qtyonHand, qtyallocated, qtyonHold, qtyavailable FROM 
	(
		SELECT 	e.customerId  AS customer, 
						CASE WHEN e.customerId NOT IN ('RBIZ_TEST', 'ECBRIGHT') AND sm.warehouseId IS NULL THEN 'WHCPT01' ELSE sm.warehouseId END AS fulfillment_center_id,
						replace(e.sku, '\r\n', '') AS sku, 
						-- CONVERT(IFNULL(SUM(a.qty), 0),SIGNED) AS qtyonHand, 
						-- CONVERT(IFNULL(SUM(a.qtyallocated), 0),SIGNED) AS qtyallocated, 
						CASE WHEN a.locationId = 'SORTATIONWHCPT01' THEN 0 ELSE CONVERT(IFNULL(SUM(a.qty), 0),SIGNED) END AS qtyonHand, 
						CASE WHEN a.locationId = 'SORTATIONWHCPT01' THEN 0 ELSE CONVERT(IFNULL(SUM(a.qtyallocated), 0),SIGNED) END AS qtyallocated, 
						CONVERT(IFNULL(SUM(a.qtyOnHold), 0),SIGNED) AS qtyonHold,
						CONVERT(IFNULL(SUM(a.qty - a.qtyallocated - a.qtyOnHold - a.qtyRpOut - a.qtyMvOut), 0),SIGNED) AS qtyavailable
		FROM 	BAS_SKU e
		LEFT JOIN BAS_CUSTOMER cus ON e.customerId = cus.customerId AND e.organizationId = cus.organizationId
		LEFT JOIN BAS_SKU_MULTIWAREHOUSE sm ON sm.organizationId = e.organizationId AND sm.customerId = e.customerId AND sm.sku = e.sku
		LEFT JOIN INV_LOT_LOC_ID a ON a.organizationId = e.organizationId AND a.customerId = e.customerId AND a.sku = e.sku AND a.warehouseId = sm.warehouseId 
		LEFT JOIN BAS_PACKAGE_DETAILS d ON a.organizationId = d.organizationId AND a.customerId = d.customerId AND e.packId = d.packId AND d.packUom = 'EA'		
		WHERE e.activeFlag='Y' AND ((e.sku != 'NOSKU' ) OR a.locationId IS NULL) AND cus.activeFlag='Y' 
      AND a.warehouseId='CBT02-B2C'
      -- AND a.locationId != 'SORTATIONWHCPT01' AND
		and cus.customerType = 'OW'
		GROUP BY e.organizationId, sm.warehouseId, e.customerId, e.sku, a.locationId
	) s
)s
GROUP BY customer, fulfillment_center_id, sku
ORDER BY qtyavailable desc