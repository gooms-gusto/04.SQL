SELECT 	organizationId, warehouseId, goodsType, customerId, orderno, orderLineNo, orderType, consigneeId, consigneeName, soReference1, soReference2, soReference5, address, 
		sku_group1, sku_group2, sku_group3, sku_group6, freightCode, sku, skuDescr1, skuDescr2, packUom, packId, 
		qtyOrdered, 
CASE WHEN (goodsType = 'Barang Kecil' AND customerId='ECLSA' AND orderType='B2BO') THEN 0 
		ELSE qtyShipped END AS qtyShipped, 	
qtyCase AS qtyCase,
qtyPerCase,  qtyCase2, qtyShippedRencengActual, qtyCaseUp, 
		CASE 
				WHEN (goodsType = 'Barang Kecil' AND customerId='ECLSA' AND sku_group6='CASE') THEN  handlingOut
				WHEN (goodsType = 'Barang Kecil' AND customerId='ECLSA' AND sku_group6!='CASE') THEN  766
				WHEN (goodsType = 'B2C (Small Item)' AND customerId='ECINNOVINE') THEN 1900 
		ELSE handlingOut END AS handlingOut,

	CASE WHEN (goodsType = 'Barang Besar' AND customerId='ECLSA') THEN 0 
	 		 WHEN (goodsType = 'Barang Kecil' AND customerId='ECLSA' AND sku_group6='CASE') THEN 0
	 WHEN (goodsType = 'Barang Kecil' AND customerId='ECLSA' AND orderType='B2CO') THEN 766 *  qtyShipped -- ADD
	 WHEN (goodsType = 'Barang Kecil' AND customerId='ECLSA' AND orderType='B2BO') THEN 0 -- ADD
	 WHEN (goodsType = 'B2C (Small Item)' AND customerId='ECINNOVINE') THEN 1900 *  qtyShipped
	 WHEN sku_group7='N' THEN 0
ELSE chargeValueQty END AS chargeValueQty,

		CASE WHEN (goodsType = 'Barang Besar' AND customerId='ECLSA') THEN (qtyCase * handlingOut)
 		 WHEN (goodsType = 'Barang Kecil' AND customerId='ECLSA' AND sku_group6='CASE') THEN (qtyCase * handlingOut) -- ADD
		 WHEN (goodsType = 'Barang Kecil' AND customerId='ECLSA' AND orderType='B2BO') THEN (qtyCase * handlingOut) -- ADD
		 WHEN (goodsType = 'Barang Kecil' AND customerId='ECLSA' AND orderType='B2CO') THEN 0 -- ADD
		 WHEN (goodsType = 'Barang Kecil' AND customerId='ECLSA') THEN 0
		 WHEN sku_group7='N' THEN 0
		 WHEN customerId='ECINNOVINE' THEN 0
ELSE chargeValueCase END AS chargeValueCase,
		valueSo, consigneeCity, cartonId, packingSize, packingCharge, qtyAmplop, cubic, cbm, grossWeight,
		udf02, carrierId, carrierName, orderSource, cod, orderTime, transactionTime,
		transactionTime1, shipmentTime, shipmentTime1, productionDate, expiredDate, inboundDate, batchNum, stockCondition, addWho, addTime
FROM (
SELECT 	a.organizationId, a.warehouseId, 
	CASE 
		WHEN a.customerId = 'ECLSA' THEN CASE  WHEN b.cube <= 2000 then "Barang Kecil" ELSE "Barang Besar"  END
		WHEN a.customerId = 'ECINNOVINE' THEN CASE WHEN b.cube <= 225 THEN "B2C (Small Item)" ELSE "B2C" END 
		WHEN a.customerId = 'SHOPINTAR' THEN CASE WHEN e.orderType = 'PTS' THEN 'CROSSDOCK' ELSE "Regular" END 
 	ELSE  '' 
END AS goodsType,
CASE WHEN a.customerId != 'ECMAMA' THEN a.customerId
	ELSE 
		CASE WHEN e.orderType = 'B2CO' THEN 'ECMAMA - PT. MAMAS CHOICE MERCHANDISING'
			 WHEN e.orderType = 'B2BO' THEN 'ECMAMA - PT. MAMAC DISTRIBUSINDO'
		END
END customerId,
		a.orderno, a.orderLineNo, e.orderType, e.consigneeId, e.consigneeName, e.soReference1, e.soReference2, e.soReference5,
		CONCAT(IFNULL(e.consigneeAddress1, '') , ',', IFNULL(e.consigneeAddress2, ''), ',', IFNULL(e.consigneeDistrict, ''), ',', IFNULL(e.consigneeCity, ''), ',', IFNULL(e.consigneeProvince, ''), ',', IFNULL(e.consigneeZip, ''), ',', IFNULL(e.consigneeCountry, '')) AS address,
		b.sku_group1, b.sku_group2, b.sku_group3, sku_group6, sku_group7,
		b.freightClass as freightCode, a.sku, b.skuDescr1, b.skuDescr2, h.uomDescr AS packUom, b.packId, 
		CONVERT(SUM(a.qty_each), SIGNED) AS qtyOrdered,
		CONVERT(SUM(a.qtyShipped_each), SIGNED) AS qtyShipped, IFNULL(CONVERT(pc.qty, SIGNED),1) AS qtyPerCase,
		IFNULL(CEIL( sum( a.qtyShipped_each) / pc.qty ),1) AS qtyCase,
		IFNULL(CEIL( sum( a.qtyShipped_each) / pc.qty ),1) AS qtyCase2,
		IFNULL(CEIL( sum( a.qtyShipped_each) / pc.qty ),1) AS qtyShippedRencengActual,
		IFNULL(CEIL( sum( a.qtyShipped_each) / pc.qty ),1) AS qtyCaseUp,

CASE WHEN e.orderType = 'B2CO'  THEN CONVERT(ba.handlingOut, SIGNED)
	WHEN e.orderType = 'B2BO' THEN CONVERT(ba.handlingOutB2b, SIGNED)
END AS handlingOut,

CASE WHEN ba.isCondition = 0 THEN
	CASE WHEN e.orderType = 'B2CO' THEN CONVERT((SUM(a.qtyShipped_each) * ba.handlingOut), SIGNED)
		  WHEN (e.orderType = 'B2BO' AND a.customerId = 'ECBBA') THEN 0
		  WHEN e.orderType = 'B2BO'  THEN CONVERT((SUM(a.qtyShipped_each) * ba.handlingOutB2b), SIGNED)
	END
ELSE
	CASE WHEN e.orderType = 'B2CO' 
			THEN CONVERT(CEIL(SUM(a.qtyShipped_each) / ba.qtyConHoB2C) * ba.handlingOut, SIGNED)
		WHEN e.orderType = 'B2BO' 
			THEN CONVERT((SUM(a.qtyShipped_each) * ba.handlingOutB2b), SIGNED)
	END
END AS chargeValueQty,

CASE	WHEN sku_group7 = 'N'  THEN 0
			WHEN ba.isCondition = 0 THEN
				CASE 	WHEN e.orderType = 'B2CO' AND a.customerId = 'ECBBA' THEN 0
							WHEN e.orderType = 'B2CO' THEN CONVERT((CEIL(SUM(a.qtyShipped_each) / pc.qty) * ba.handlingOut), SIGNED)
					WHEN e.orderType = 'B2BO' 
						-- THEN CONVERT((SUM(a.qtyShipped_each) * ba.handlingOutB2b), SIGNED)
							THEN IFNULL(CEIL(SUM(a.qtyShipped_each) / pc.qty),1) * ba.handlingOutB2b
				END
				ELSE
					CASE 	WHEN e.orderType = 'B2CO' THEN CEIL(sum(a.qtyShipped_each)/ ba.qtyConHoB2C) * ba.handlingOut
								WHEN e.orderType = 'B2BO'  AND a.customerId IN ('ECMAMA','ECMAMAB2C','ECBBA') THEN IFNULL(CEIL(SUM(a.qtyShipped_each) / pc.qty),1) * ba.handlingOutB2b
								WHEN e.orderType = 'B2BO' THEN CONVERT((SUM(a.qtyShipped_each) * ba.handlingOutB2b), SIGNED)
					END
END AS chargeValueCase,

		CASE WHEN a.skuLineNo = '1' THEN 1 ELSE 0 END valueSo,
		consigneeCity, ops.cartonId as cartonId, 
CASE 	WHEN bc.udf01 = '' THEN '0' WHEN bc.udf01 IS NULL THEN '0' ELSE bc.udf01 end as packingSize,
CASE  WHEN sku_group7 = 'N'  THEN 0 
			WHEN a.skuLineNo = '1' AND (a.customerId LIKE 'RBIZ%') AND bc.udf01='S' AND consigneeAddress4='JABODETABEK' THEN 0
				WHEN a.skuLineNo = '1' THEN IFNULL(bc.billingRate,0) ELSE 0 END AS packingCharge,
		0 as qtyAmplop, 
		SUM(a.Qty_Each * b.cube) AS cubic, SUM(a.Qty_Each * b.cube) / 1000000 AS cbm,
		(b.grossWeight * SUM(a.qtyShipped_each)) grossWeight,
		e.udf02, e.carrierId, e.carrierName, e.hedi01 as orderSource,
		e.hedi05 AS cod, DATE_FORMAT(e.orderTime, '%Y-%m-%d %T') AS orderTime,
DATE_FORMAT(e.addTime, '%Y-%m-%d %T') AS transactionTime,
DATE_FORMAT(e.addTime, '%Y-%m-%d') AS transactionTime1,
DATE_FORMAT(a.shipmentTime, '%Y-%m-%d %T') AS shipmentTime,
DATE_FORMAT(a.shipmentTime, '%Y-%m-%d') AS shipmentTime1, 
		d.lotAtt01 AS productionDate,  d.lotAtt02 AS expiredDate, d.lotAtt03 AS inboundDate, d.lotAtt04 AS batchNum, d.lotAtt08 AS stockCondition, 'SYS' AS addWho, NOW() AS addTime
FROM 	ACT_ALLOCATION_DETAILS a
LEFT OUTER JOIN BAS_CUSTOMER tt ON tt.organizationId = a.organizationId AND tt.customerId = a.CustomerId AND tt.customerType = 'OW'
LEFT OUTER JOIN BAS_SKU b ON b.organizationId = a.organizationId AND b.customerId = a.CustomerId AND b.sku = a.Sku
LEFT OUTER JOIN INV_LOT_ATT d ON d.organizationId = a.organizationId AND d.customerid = a.customerId AND d.sku = a.sku AND d.lotNum = a.LotNum
LEFT OUTER JOIN DOC_ORDER_HEADER e ON a.organizationId = e.organizationId AND a.CustomerId = e.customerId  AND e.warehouseId = a.warehouseId AND a.orderno = e.orderNo
LEFT JOIN BAS_PACKAGE_DETAILS h ON a.organizationId = h.organizationId AND a.CustomerId = h.customerId AND a.PackId = h.packId AND h.packUom = 'EA'
LEFT JOIN BAS_PACKAGE_DETAILS pc ON tt.organizationId = pc.organizationId AND tt.customerId = pc.customerId AND b.packId = pc.packId AND pc.packUom='CS'
LEFT JOIN DOC_ORDER_PACKING_SUMMARY ops on ops.organizationId = e.organizationId AND ops.warehouseId = e.warehouseId  AND ops.orderNo = e.orderNo
LEFT JOIN Z_BIL_Aggrement ba on ba.organizationId = e.organizationId AND ba.warehouseId = e.warehouseId  AND ba.customerId = e.customerId
LEFT JOIN BAS_CARTON bc ON ops.warehouseId = bc.warehouseId AND  ops.cartonId = bc.cartonId AND 
CASE 
WHEN e.customerId IN('ECMAMA','ECBBA', 'ECCOCO', 'ECCOCO_2','ECCOCO_3', 'ECTUP') THEN 'STANDARD'
WHEN e.customerId IN ('ECINGSAL', 'ECINGCOM', 'ECING_TSTER') THEN 'ECING'
WHEN e.customerId IN ('RBIZB2B', 'RBIZBUSTAR', 'RBIZNAMEERA') THEN 'RBIZ'
WHEN e.customerId IN ('ECZAP_2', 'ECZAPLAZ', 'ECZAPSPE') THEN 'ECZAP'
ELSE e.customerId END = CASE WHEN bc.cartonGroup = 'LOG99' THEN 'LOGISTIC_99' ELSE bc.cartonGroup END

WHERE  a.STATUS = '80' and a.organizationId = 'ID_8COM' AND a.warehouseId IN ('WHCPT01','WHPGD01','WHSMG02') AND e.orderType NOT IN ('TROF', 'REOF')
	AND a.customerId IN ('ECTUP') 
 -- AND e.orderType = ('${orderType}')
	AND CONVERT(a.shipmentTime, DATE) >=  '2022/06/20 00:00:00'
	AND CONVERT(a.shipmentTime, DATE) <= '2022/06/25 23:59:59'
--	AND a.orderno IN ('${orderno}')
  AND a.warehouseId IN ('WHPGD01')
-- AND (b.udf02 = '${vas}' ) -- AND b.sku_group7 != 'N' -- AND b.sku='PV4891425499458584623'
AND e.orderNo != 'SO20050900206'

GROUP BY
a.organizationId, a.warehouseId, a.customerId, a.orderno, a.orderLineNo, e.orderType, e.consigneeId, e.consigneeName, e.soReference1, e.soReference2, e.soReference5, b.sku_group1, b.sku_group2, b.sku_group3, 
b.freightClass, a.sku, b.skuDescr1, b.skuDescr2, b.reportUom, 
h.uomDescr, b.packId, ba.handlingOut, ba.handlingOutB2b,
a.shipmentTime,
e.hedi05, e.carrierName,
e.addTime,
e.udf02, e.carrierId, e.carrierName, consigneeCity, e.orderTime, 
d.lotAtt01,  d.lotAtt02, d.lotAtt03, d.lotAtt04, d.lotAtt08, e.hedi01,ops.cartonId, bc.udf01, bc.billingRate, skuLineNo,
CONCAT(IFNULL(e.consigneeAddress1, '') , ',', IFNULL(e.consigneeAddress2, ''), ',', IFNULL(e.consigneeCity, ''), ',', IFNULL(e.consigneeProvince, ''), ',', IFNULL(e.consigneeZip, ''), ',', IFNULL(e.consigneeCountry, ''))
, ba.isCondition, ba.qtyConHoB2C
-- ORDER BY a.customerId, e.orderType, a.orderno, a.orderLineNo
ORDER BY CASE WHEN a.customerId IN ('ECLSA','SHOPINTAR', 'ECINNOVINE') THEN goodsType END, a.customerId, e.orderType, a.orderno, a.orderLineNo
)d
-- WHERE goodsType =  '${goodsType}'
ORDER BY CASE WHEN customerId = 'ECLSA' THEN goodsType END