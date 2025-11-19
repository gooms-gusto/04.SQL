SELECT DISTINCT dah.asnReference1
FROM DOC_ASN_HEADER dah
WHERE dah.organizationId = @organizationId
AND dah.warehouseId = @warehouseIdFrom
AND dah.customerId = @customerId
AND ((dah.hedi08 = ''
AND dah.hedi09 = '') OR 
 (dah.hedi08 IS NULL
AND dah.hedi09 is NULL))
AND dah.asnStatus IN ('99')
AND DATE(doh.addTime) > '2025-10-10'
ORDER BY dah.asnReference1
LIMIT @limit;


UPDATE DOC_ASN_HEADER dah
SET hedi08 = @fileName,
    hedi09 = @processDate
WHERE organizationId = @organizationId
  AND warehouseId = @warehouseIdFrom
  AND customerId = @customerId
  AND dah.asnReference1 = @soReference1;


SELECT CASE WHEN ((hedi08='' AND hedi09='') OR (hedi08 IS NULL AND hedi09 IS NULL)) 
THEN 'N' ELSE 'Y' END AS ediSendFlag
FROM DOC_ASN_HEADER
WHERE organizationId = @organizationId
AND customerId = @customerId
AND warehouseId IN (@warehouseIdFrom)
AND asnReference1 = @soReference1
LIMIT 1;