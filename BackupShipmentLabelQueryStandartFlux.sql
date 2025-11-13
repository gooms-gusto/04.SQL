SELECT
 a.organizationId,
 a.warehouseId,
 a.waveNo,
 a.pickToTraceId,
 a.pickToLocation,
 a.cartonSeqno,
 sum(a.qty_each) qty,
 b.customerId,
 b.consigneeId,
 b.consigneeAddress1,
 b.consigneeZip,
 b.consigneeCity,
 b.consigneeProvince,
 b.consigneeCountry,
 b.consigneeName,
 b.consigneeContact,
 b.consigneeTel1,
 b.carrierId,
 b.carrierName,
 b.soReference1,
 b.soReference2,
 b.soReference3,
 b.soReference4,
 b.soReference5,
 b.expectedShipmentTime1,
 b.orderType,
 c1.codeDescr orderTypeName,
 c2.codeDescr route,
 b.hedi01,
 b.hedi02,
 b.hedi03,
 b.hedi04,
 b.hedi05,
 b.hedi06,
 b.hedi07,
 b.hedi08,
 b.hedi09,
 b.hedi10,
 g.cubic,
 g.qty qty01,
 g.udf01,
 g.udf02,
 g.udf03,
 g.udf04,
 g.udf05,
 h.cartonDescr,
 a.orderNo
 @queryFields
FROM
 ACT_ALLOCATION_DETAILS a
LEFT JOIN DOC_ORDER_HEADER b ON a.organizationId = b.organizationId
AND a.warehouseId = b.warehouseId
AND a.orderNo = b.orderNo
LEFT JOIN BAS_SKU c ON a.organizationId = c.organizationId
AND a.sku = c.sku
AND a.customerId = c.customerId
LEFT JOIN BAS_CUSTOMER f ON a.organizationId = f.organizationId
AND b.consigneeId = f.customerId
AND f.customerType = 'CO'
LEFT JOIN DOC_ORDER_PACKING_SUMMARY g ON a.organizationId = g.organizationId
AND a.warehouseId = g.warehouseId
AND a.orderNo = g.orderNo
AND a.pickToTraceId = g.traceId
LEFT JOIN BSM_CODE_ML c1 ON a.organizationId = c1.organizationId
AND c1.codeId = b.orderType
AND c1.codeType = 'SO_TYP'
AND c1.languageId = 'XXX'
LEFT JOIN BSM_CODE_ML c2 ON a.organizationId = c2.organizationId
AND c2.codeId = b.route
AND c2.codeType = 'ROU_COD'
AND c2.languageId = 'XXX'
LEFT JOIN BAS_CARTON h ON a.organizationId = h.organizationId
AND a.warehouseId = h.warehouseId
AND g.cartonGroup = h.cartonId
@joinTables
WHERE
 a.organizationId = 'XXX'
AND a.warehouseId = 'XXX'
AND a.packflag = 'Y'
AND a.pickToTraceId = 'XXX'
GROUP BY
 a.organizationId,
 a.warehouseId,
 a.waveNo,
 a.pickToTraceId,
 a.pickToLocation,
 b.customerId,
 b.consigneeId,
 b.consigneeName,
 b.consigneeAddress1,
 b.consigneeZip,
 b.consigneeCity,
 b.consigneeProvince,
 b.consigneeCountry,
 b.consigneeContact,
 b.consigneeTel1,
 a.cartonSeqno,
 b.carrierId,
 b.carrierName,
 b.soReference1,
 b.soReference2,
 b.soReference3,
 b.soReference4,
 b.soReference5,
 c1.codeDescr,
 c2.codeDescr,
 b.hedi01,
 b.hedi02,
 b.hedi03,
 b.hedi04,
 b.hedi05,
 b.orderType,
 b.hedi06,
 b.hedi07,
 b.hedi08,
 b.hedi09,
 b.hedi10,
 g.cubic,
 g.qty,
 g.udf01,
 g.udf02,
 g.udf03,
 g.udf04,
 g.udf05,
 h.cartonDescr,
 b.expectedShipmentTime1,
 a.orderNo
 @groupByFields
@orderByFields