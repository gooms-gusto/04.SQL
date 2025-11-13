  
SELECT
  dah.orderNo,
  dah.soReference1,dod.totalsku
FROM wms_cml.DOC_ORDER_HEADER dah
  INNER JOIN (SELECT
      customerid,
      warehouseid,
      orderNo,
      COUNT(sku) AS totalsku
    FROM wms_cml.DOC_ORDER_DETAILS
    WHERE customerId = 'MAP'
    AND warehouseId = 'CBT01'
    group BY customerid, warehouseid, orderNo) dod ON (
     dah.warehouseId = dod.warehouseId
    AND dah.customerId = dod.customerId AND dah.orderNo=dod.orderNo)
WHERE dah.customerId = 'MAP'
GROUP BY dah.orderNo,
         dah.soReference1