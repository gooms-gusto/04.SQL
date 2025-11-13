SELECT  A.sku AS lotNum,
 A.sku AS traceId,
 A.sku AS locationId,
 A.warehouseId AS warehouseId, 
 A.customerId AS customerId
	, A.sku AS sku,
		SUM(A.qty - A.qtyAllocated - A.qtyOnHold - A.qtyRpOut - A.qtyMvOut ) AS qty,
  SUM(A.qty) AS qtyOnHand,
  SUM(A.qtyOnHold) AS qtyOnHold,
  SUM(A.qtyAllocated) AS qtyAllocated,
  SUM(A.qtyRpOut) AS qtyRpOut,
  SUM(A.qtyMvOut) AS qtyMvOut,
	'' AS grossWeight , '' AS netWeight, '' AS cubic
	, ''  AS price, '' AS lotAtt01, '' AS lotAtt02, '' AS lotAtt03,'' AS lotAtt04
	, ''  AS lotAtt05, ''  AS lotAtt06,''  AS lotAtt07, ''  AS lotAtt08, ''  AS lotAtt09
	, ''  AS lotAtt10, ''  AS lotAtt11, ''  AS lotAtt12, ''  AS lotAtt13, ''  AS lotAtt14
	, ''  AS lotAtt15, ''  AS lotAtt16, ''  AS lotAtt17, ''  AS lotAtt18, ''  AS lotAtt19
	, ''  AS lotAtt20, ''  AS lotAtt21, ''  AS lotAtt22, ''  AS lotAtt23, ''  AS lotAtt24
	, ''  AS userDefine1, ''  AS  userDefine2, ''  AS  userDefine3, ''  AS  userDefine4, ''  AS  userDefine5
	, ''  AS noteText
FROM INV_LOT_LOC_ID  A
WHERE   1 =  1

GROUP BY A.organizationId,A.warehouseId,A.customerId,A.sku