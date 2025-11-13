SELECT
  doh.soReference1 AS f01,
  dod.dedi03 AS f02,
  dod.dedi07 AS f03,
  dod.dedi08 AS f04,
  dod.dedi11 AS f05,
  '' AS f06,
  dod.qtyOrdered AS f07,
  '1' AS f08,
  pklist.qtyPick AS f09,
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
  INNER JOIN DOC_ORDER_DETAILS dod
    ON doh.warehouseId = dod.warehouseId
    AND doh.orderNo = dod.orderNo
    AND doh.customerId = dod.customerId
  LEFT OUTER JOIN (SELECT
      customerId,
      customerDescr1
    FROM BAS_CUSTOMER
    WHERE customerType = 'CO') co
    ON (doh.consigneeId = co.customerId) 
    LEFT OUTER JOIN
    (SELECT pk.organizationId,pk.customerId,pk.soReference1,pk.orderLineNo,SUM(pk.qtyPick) qtyPick FROM 
    (SELECT aad.organizationId,aad.warehouseId,aad.customerId, SUM(aad.qtyPicked_each) qtyPick,aad.orderNo,aad.orderLineNo,ddoh.soReference1 
    FROM ACT_ALLOCATION_DETAILS aad
    left outer join DOC_ORDER_HEADER ddoh on
    aad.organizationId=ddoh.organizationId
    and aad.warehouseId=ddoh.warehouseid
    and aad.customerId=ddoh.customerId
    and aad.orderNo=ddoh.orderNo
    WHERE aad.organizationId='OJV_CML'
    AND aad.warehouseId IN ('CBT02','JBK01')
    AND aad.customerId='PT.ABC'
    GROUP BY aad.organizationId,aad.warehouseId,aad.customerId,aad.orderNo,aad.orderLineNo,ddoh.soReference1) pk 
    GROUP BY pk.organizationId,pk.customerId,pk.orderLineNo,pk.soReference1) pklist
    ON dod.organizationId=pklist.organizationId
    AND dod.customerId = pklist.customerId
    AND dod.orderLineNo = pklist.orderLineNo 
    AND doh.soReference1 =pklist.soReference1
WHERE doh.organizationId = 'OJV_CML'
 AND doh.warehouseId IN ( 'CBT02')
AND doh.customerId = 'PT.ABC'
-- AND doh.soStatus >= '99'
-- AND doh.addWho = 'EDI'
AND doh.soReference1 IN('073085TEST-3')
ORDER BY doh.orderNo, CAST(dod.dedi03 AS SIGNED);