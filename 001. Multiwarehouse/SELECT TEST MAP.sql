SELECT doh.warehouseId,doh.orderNo,doh.soReference1,doh.hedi12, doh.hedi13 FROM DOC_ORDER_HEADER doh WHERE doh.organizationId='OJV_CML' AND doh.customerId='PT.ABC'
  AND doh.warehouseId='CBT02' AND doh.orderType='SO' 
  ORDER BY doh.addTime DESC LIMIT 7;