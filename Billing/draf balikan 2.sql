SELECT
  doh.soReference1 AS f01,
  dod.dedi03 AS f02,
  dod.dedi07 AS f03,
  dod.dedi08 AS f04,
  dod.dedi11 AS f05,
  '' AS f06,
  dod.qtyOrdered  AS f07,
   '1' AS f08,
  ln.qtyAllocated  AS f09,
  '' AS f10,
  DATE_FORMAT(CASE WHEN doh.lastShipmentTime IS NULL THEN doh.editTime ELSE doh.lastShipmentTime END, "%Y%m%d") AS f11,
  '' AS f12,
  '' AS f13,
  '' AS f14,
  DATE_FORMAT(CASE WHEN doh.lastShipmentTime IS NULL THEN doh.editTime ELSE doh.lastShipmentTime END, "%Y%m%d") AS f15,
  '' AS f16,
  '' AS f17,
  '' AS f18,
  '' AS f19,
  '' AS f20,
  '' AS f21,
  '' AS f22,
  '' AS f23
FROM DOC_ORDER_HEADER doh 
INNER JOIN
 DOC_ORDER_DETAILS  dod ON doh.organizationId = dod.organizationId
 AND doh.warehouseId = dod.warehouseId
 AND doh.orderNo =dod.orderNo
INNER JOIN
(SELECT SUM(aad.qty_each) AS qtyAllocated,aad.orderLineNo FROM ACT_ALLOCATION_DETAILS aad INNER JOIN
DOC_ORDER_HEADER doh1 ON aad.organizationId = doh1.organizationId
AND aad.warehouseId = doh1.warehouseId
AND aad.orderNo = doh1.orderNo
AND doh1.soReference1='073085TEST-3'
AND aad.customerId=doh1.customerId
AND aad.warehouseId IN ('CBT02','JBK01')
GROUP BY aad.organizationId,aad.customerId,aad.orderLineNo) ln
 ON dod.orderLineNo=ln.orderLineNo
 WHERE doh.organizationId='OJV_CML'
AND doh.warehouseId IN ('CBT02')
AND doh.customerId='PT.ABC'
AND doh.soReference1='073085TEST-3';