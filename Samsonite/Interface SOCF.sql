SELECT CONCAT(doh.udf02,'~',
  doh.soReference1,'~',
  doh.orderNo,'~',
  DATE_FORMAT(doh.addTime, '%Y%m%d') ,'~',
  DATE_FORMAT(doh.orderTime, '%Y%m%d') ,'~',
  DATE_FORMAT(doh.lastShipmentTime, '%Y%m%d') ,'~',
    doh.consigneeId,'~',
co.customerDescr1,'~',
  dod.dedi03,'~',
    dod.sku,'~',
  CAST(dod.qtyOrdered AS decimal(0)),'~',
  CAST(dod.qtyShipped_each AS  decimal(0)),'~',
  CAST(dod.qtyOrdered-dod.qtyShipped AS  decimal(0))
  ) 
  AS interface
FROM DOC_ORDER_HEADER doh
  INNER JOIN DOC_ORDER_DETAILS dod
    ON doh.warehouseId = dod.warehouseId
    AND doh.orderNo = dod.orderNo
    AND doh.customerId = dod.customerId
  LEFT OUTER JOIN
  (SELECT customerId,customerDescr1 from BAS_CUSTOMER WHERE customerType='CO') co
  ON (doh.consigneeId=co.customerId)
  WHERE doh.customerId='MAP' AND doh.soStatus='99' LIMIT 10;



-- SELECT * FROM DOC_ORDER_DETAILS dod WHERE dod.orderNo='MAPSO000000001';
-- 
-- SELECT * FROM DOC_ORDER_HEADER  dod WHERE dod.orderNo='MAPSO000000001';