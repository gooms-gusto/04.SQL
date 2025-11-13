SELECT  a.warehouseId, a.customerId AS CUSTOMERID, a.sku AS SKU, f.skuDescr1 AS DESCR, b.lotAtt03 as INBOUNDDATE, e.packId AS PACKID, a.locationId AS LOCATIONID, 
				a.traceId AS TRACEID, b.lotAtt04 as BATCH, b.lotAtt09 as EXTPO,
				case b.lotAtt08 when 'N' then 'OK' when 'Y' then 'HOLD' else '' end as STATUS,
				CONVERT(a.qty, SIGNED) AS qty, 
				CONVERT(IFNULL(SUM(a.qtyallocated), 0),SIGNED) AS qtyallocated, 
				CONVERT(IFNULL(SUM(a.qtyOnHold), 0),SIGNED) AS qtyonHold,
				CONVERT(IFNULL(SUM(a.qty - a.qtyallocated - a.qtyOnHold - a.qtyRpOut - a.qtyMvOut), 0),SIGNED) AS qtyavailable,
				e.uomDescr AS UOM,
				aad.orderNo, soTypeName, 
				b.lotAtt10 as PALLETNO, b.lotAtt01 AS PRODDATE, b.lotAtt02 AS EXPIREDATE, 
				DATEDIFF(CURDATE(), b.lotAtt03) as AGING,
				DATEDIFF(CURDATE(), b.lotAtt02) AS expirationLife
		FROM 		INV_LOT_LOC_ID a
		LEFT JOIN INV_LOT_ATT b ON a.organizationId = b.organizationId  AND a.lotNum = b.lotNum
		LEFT JOIN BAS_SKU f ON a.organizationId = f.organizationId AND a.customerId = f.customerId AND a.sku = f.sku
		LEFT JOIN BAS_PACKAGE_DETAILS e ON f.organizationId = e.organizationId AND f.customerId = e.customerId AND f.packId = e.packId AND e.packUom = 'EA'
		LEFT JOIN 
		(			
			SELECT 	organizationId, warehouseId, GROUP_CONCAT(orderNo SEPARATOR ', ') AS orderNo, traceId, SUM(qty_each) AS qtyEach
			FROM 		ACT_ALLOCATION_DETAILS
			WHERE  	warehouseId='BASF01' AND customerId='BASF01' AND `status`!='80'-- AND traceId='2103200050'
			GROUP BY organizationId, traceId
		) aad ON a.organizationId = aad.organizationId AND a.warehouseId=aad.warehouseId AND a.traceId = aad.traceId

		-- LEFT JOIN ACT_ALLOCATION_DETAILS aad ON a.organizationId = aad.organizationId AND a.warehouseId=aad.warehouseId AND a.traceId = aad.traceId
		LEFT JOIN DOC_ORDER_HEADER doh ON doh.organizationId = aad.organizationId AND doh.warehouseId=aad.warehouseId AND doh.orderNo = aad.orderNo
		LEFT JOIN
		(
		 	SELECT codeId, codeDescr as soTypeName from BSM_CODE_ML 
			WHERE codeType='SO_TYP' AND languageId='en'
		)
		c2 on c2.codeId = doh.orderType
		WHERE 	f.activeFLag='Y' AND CONVERT(a.qty, SIGNED) > 0  AND a.warehouseId = 'CBT02' AND a.customerId = ( 'ADS' ) AND a.qtyAllocated> 0
		GROUP BY a.organizationId, a.warehouseId, a.customerId, a.locationId, a.sku, f.skuDescr1,
						a.traceId, e.packId, b.lotAtt08, b.lotAtt05, a.qty, e.uomDescr, b.lotAtt01,
						b.lotAtt02, b.lotatt03, a.lotNum, b.lotAtt08, aad.orderNo, soTypeName
		ORDER BY a.sku