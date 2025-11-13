SELECT A.warehouseId AS warehouseId, A.seqNo AS seqNo, A.orderNo AS orderNo, B.soreference1 AS docNo, A.orderStatus AS orderStatusCode
	, C.codeDescr AS orderStatusDescr, A.changeBy AS statusChangeBy, A.changeTime AS statusTime
FROM IDX_ORDERSTATUS_LOG A
	LEFT JOIN DOC_ORDER_HEADER B
	ON A.organizationId = B.organizationId
		AND A.warehouseId = B.warehouseId
		AND A.orderNo = B.orderNo
	LEFT JOIN BSM_CODE_ML C
	ON A.organizationId = C.organizationId
		AND A.orderStatus = C.codeId
		AND C.codeType = 'SO_STS'
		AND C.languageId = 'en'
WHERE 1 = 1
	AND A.ediSendFlag = 'Y' ORDER BY A.changeTime DESC