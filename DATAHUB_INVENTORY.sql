SELECT A.lotNum, A.traceId AS traceId, A.locationId AS locationId, A.warehouseId AS warehouseId, A.customerId AS customerId, A.sku AS sku, A.qty AS qty, A.grossWeight AS grossWeight
	, A.netWeight AS netWeight, A.cubic AS cubic, A.price AS price, B.lotAtt01, B.lotAtt02
	, B.lotAtt03, B.lotAtt04, B.lotAtt05, B.lotAtt06, B.lotAtt07
	, B.lotAtt08, B.lotAtt09, B.lotAtt10, B.lotAtt11, B.lotAtt12
	, B.lotAtt13, B.lotAtt14, B.lotAtt15, B.lotAtt16, B.lotAtt17
	, B.lotAtt18, B.lotAtt19, B.lotAtt20, B.lotAtt21, B.lotAtt22
	, B.lotAtt23, B.lotAtt24, A.UDF01 AS userDefine1, A.UDF02 AS userDefine2, A.UDF03 AS userDefine3
	, A.UDF04 AS userDefine4, A.UDF05 AS userDefine5, A.noteText
FROM INV_LOT_LOC_ID A
	LEFT JOIN INV_LOT_ATT B
	ON A.organizationId = B.organizationId
		AND A.lotNum = B.lotNum
WHERE 1 = 1