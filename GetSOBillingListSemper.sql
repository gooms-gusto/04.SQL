SELECT * FROM 
  ACT_ALLOCATION_DETAILS aad INNER JOIN DOC_ORDER_HEADER doh ON (aad.organizationId=doh.organizationId
  AND aad.warehouseId = doh.warehouseId AND aad.customerId = doh.customerId AND aad.orderNo = doh.orderNo)
  WHERE aad.customerId='LTL' AND aad.warehouseId='SMPR01' AND  doh.orderType <> 'FREE'
  AND aad.editTime BETWEEN '2022-08-24' AND '2022-08-25'