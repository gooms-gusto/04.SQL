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