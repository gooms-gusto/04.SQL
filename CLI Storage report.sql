SELECT 	DATE_FORMAT(StockDate, '%Y-%m-%d') as stockDate, zba.warehouseId AS warehouseId, zib.customerId, zib.freightClass, 
				zib.sku, SKUDesc AS skuDesc, UOM, sku_group6,
				qtyonHand, (zib.cube/1000000) as cbm, zib.totalCube/1000000 AS totalcbm,
  convert(DATEDIFF(zib.stockDate, CONVERT(ila.lotAtt03, DATE)), signed) AS aging, 
-- CASE WHEN zib.customerId LIKE 'RBIZ%' THEN aging ELSE 0 END AS aging,

  CASE  WHEN zba.storageBy = 'MONTH' THEN		
		CASE WHEN zib.customerId LIKE "ECING%" THEN ROUND(((zib.totalCube/1000000) * zba.`storage`),4)
				WHEN (zib.customerId = 'RBIZ' AND  convert(DATEDIFF(zib.stockDate, CONVERT(ila.lotAtt03, DATE)), signed) < 90) THEN 0
				WHEN (zib.customerId = 'RBIZNAMEERA' AND  convert(DATEDIFF(zib.stockDate, CONVERT(ila.lotAtt03, DATE)), signed) < 90) THEN 0
				WHEN (zib.customerId LIKE "RBIZ%" AND  convert(DATEDIFF(zib.stockDate, CONVERT(ila.lotAtt03, DATE)), signed) >= 90) THEN ROUND(((zib.totalCube/1000000) * zba.`storage`),4)
				-- WHEN totalCbm < 1 AND zib.customerId = 'ECZAP'   THEN ROUND((CEIL(totalCbm)) * (zba.`storage`/'${dayOfMonth}') ,4)
				WHEN (zib.totalCube/1000000) < 1 AND zib.customerId = 'ECZAP' THEN ROUND(((zib.totalCube/1000000)) * (zba.`storage`/'${dayOfMonth}') ,4)
WHEN zib.customerId in ('ECCLOX','ECLILI','ECTANG','ECX3ENG') then ROUND((zba.storageDay * (zib.totalCube/1000000)),4)
		ELSE
			ROUND((zib.totalCube/1000000) * (zba.`storage` / '${dayOfMonth}'), 2) 
		END
	ELSE
			CASE WHEN (zib.customerId = 'ECTUP' AND s.sku_group6='') 						THEN ROUND((zib.totalCube/1000000) * (zba.`storage` / '${dayOfMonth}'), 2)
				   WHEN (zib.customerId = 'ECTUP' AND s.sku_group6='ACCESSORIES') THEN ROUND(qtyonHand * storageDay,2)
                                   WHEN zib.customerId in ('ECCLOX','ECLILI','ECTANG','ECX3ENG','ECZAP','ECZAP_2') then ROUND((zba.storageDay * (zib.totalCube/1000000)),4)
			ELSE qtyonHand * storageDay
			END
END AS storageCharge

FROM 	Z_InventoryBalance_BILL zib
LEFT JOIN Z_BIL_Aggrement zba on zba.organizationId = zib.organizationId AND zba.warehouseId = zib.warehouseId  AND zba.customerId = zib.customerId
LEFT JOIN BAS_SKU s on s.organizationId = zib.organizationId AND s.customerId = zib.customerId AND s.sku=zib.sku
  LEFT JOIN INV_LOT_ATT ila ON zib.organizationId = ila.organizationId AND zba.organizationId = ila.organizationId AND zib.lotNum = ila.lotNum
  AND zib.customerId = ila.customerId AND zib.sku = ila.sku
WHERE 	zib.organizationId = 'ID_8COM'  AND zib.qtyonHand > 0 
		-- AND zib.customerId  = 'ECING_TSTER' AND StockDate BETWEEN '2020-02-25' AND '2020-03-24'
		AND zib.customerId  = 'ECTUP' AND StockDate BETWEEN '2022-06-20' AND '2022-06-25'
AND zib.warehouseId  = 'WHPGD01'
AND zib.sku != 'FULLCARTON' 
  -- AND zib.sku = '${sku}'
order by StockDate desc, zib.customerId, SKUDesc