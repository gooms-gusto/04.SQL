
SELECT a.orderNo,a.shipmentTime FROM ACT_ALLOCATION_DETAILS a
  LEFT OUTER JOIN DOC_ORDER_HEADER e ON a.organizationId = e.organizationId AND a.CustomerId = e.customerId  AND e.warehouseId = a.warehouseId AND a.orderno = e.orderNo
WHERE  a.STATUS = '80' and a.organizationId = 'ID_8COM' AND a.warehouseId IN ('WHCPT01','WHPGD01','WHSMG02') AND e.orderType NOT IN ('TROF', 'REOF')
	AND a.customerId IN ('ECTUP') 
 -- AND e.orderType = ('${orderType}')
	AND CONVERT(a.shipmentTime, DATE) >=  '2022/06/20 00:00:00'
	AND CONVERT(a.shipmentTime, DATE) <= '2022/06/25 23:59:59'
--	AND a.orderno IN ('${orderno}')
  AND a.warehouseId IN ('WHPGD01') ORDER BY a.shipmentTime desc