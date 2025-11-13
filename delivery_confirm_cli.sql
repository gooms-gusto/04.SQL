SELECT * FROM wms_cml.DOC_DELIVERYCONFIRM_HEADER WHERE warehouseId='CBT02-B2C';
SELECT * FROM wms_cml.DOC_DELIVERYCONFIRM_DETAILS  WHERE warehouseId='CBT02-B2C';
SELECT * FROM wms_cml.DOC_DELIVERYCONFIRM_HEADER_UDF WHERE warehouseId='CBT02-B2C';

SELECT doh.orderNo,doh.soReference5 AS awb_no, doh.carrierId,doh.carrierName,
    DATE_FORMAT(doh.lastShipmentTime, '%Y-%m-%d %T') AS orderclose,
   DATE_FORMAT(ddd.addTime, '%Y-%m-%d %T') AS handovertime
FROM wms_cml.DOC_ORDER_HEADER doh
  INNER JOIN DOC_DELIVERYCONFIRM_DETAILS ddd ON (doh.organizationId = ddd.organizationId
  AND doh.warehouseId = ddd.warehouseId AND doh.soReference5 = ddd.deliveryNo)
  INNER JOIN DOC_DELIVERYCONFIRM_HEADER ddh ON 
  (doh.organizationId = ddh.organizationId
  AND doh.warehouseId = ddh.warehouseId AND ddd.deliveryConfirmNo = ddh.deliveryConfirmNo)
  WHERE  doh.organizationId = '@{bizOrgId}'
        AND  doh.warehouseId    = '@{bizWarehouseId}'

