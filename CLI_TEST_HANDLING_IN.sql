SELECT 
case when b.cube <= 2000 then "Barang Kecil" ELSE "Barang Besar" end goodsType,
t1.codeDescr AS orderType, a.warehouseId, a.fmCustomerId AS customerId, a.toSku AS sku, b.skuDescr1, a.docNo AS asnNo, t1.codeDescr AS asnType, a.docLineNo AS asnLineNo, 
	DATE_FORMAT( f.asnCreationTime, '%Y-%m-%d %T' ) AS asnCreationTime,
	DATE_FORMAT( a.transactionTime, '%Y-%m-%d %T' ) AS transactionTime,
	DATE_FORMAT( a.transactionTime, '%Y-%m-%d' ) AS transactionTime1,
	DATE_FORMAT( t2.putawayDate, '%Y-%m-%d %T' ) AS putawayDate,
	b.skuDescr2, b.sku_group1, b.freightClass as freightCode, e.freightDescr1 AS commodity,  b.packId, t.packUom, 
	CONVERT(( ( sum( a.toQty_Each ) ) / t.qty ), SIGNED) AS qty,
	CONVERT(pc.qty, SIGNED) AS qtyPerCase,
	IFNULL(CEIL(( ( sum( a.toQty_Each ) ) / pc.qty )),1) AS qtyCase,
CONVERT(pc.qty, SIGNED) AS qtyPerRenceng,
CONVERT(pc.qty, SIGNED) AS qtyPerRencengActual,
CONVERT(pc.qty, SIGNED) AS qtyPerRencengRoundup,
CASE WHEN (a.docLineNo = 1 AND a.udf01 is null) THEN ba.handlingIn ELSE 0 END handlingIn,
CONVERT(( ( sum( a.toQty_Each ) ) / t.qty ), SIGNED) * ba.handlingIn as chargeValueQty,
IFNULL(CEIL(( ( sum( a.toQty_Each ) ) / pc.qty )),1) * ba.handlingIn as chargeValueCase,
CASE WHEN a.docLineNo = '1' THEN CONVERT( (IFNULL(  CEIL(sum( a.toQty_Each )  / pc.qty), 1) * ba.handlingIn), SIGNED) ELSE 0 END chargeValuePoCase,
CASE WHEN a.docLineNo = '1' THEN CONVERT( (IFNULL(( ( sum( a.toQty_Each ) ) / t.qty ), 1) * ba.handlingIn ), SIGNED) ELSE 0 END chargeValuePoQty,
	( ( sum( a.toQty_Each ) ) / t.qty ) AS vasLabeling,
b.cube AS cube,
( ( sum( a.toQty_Each ) ) * b.cube) AS totalCube,
b.udf01 AS cbm,
( ( sum( a.toQty_Each ) ) * b.cube) / 1000000 as totalCbm,
	sum( a.totalGrossWeight ) AS grossWeight,
	f.udf02, f.carrierId, f.carrierName, f.supplierId, f.supplierName,f.asnReference1, f.asnReference3,
CASE WHEN (a.docLineNo = 1 AND a.udf01 is null) THEN 1 ELSE 0 END valuePo,
	d.lotAtt01 AS productionDate, d.lotAtt02 AS expirationDate, d.lotAtt03 AS inboundDate, d.lotAtt04 AS batchNumber,
	'' AS agingPeriod,
	d.lotAtt08 AS stockCondition, f.noteText AS noteText,
	'SYS' AS addWho, NOW() AS addTime
FROM ACT_TRANSACTION_LOG a
	LEFT OUTER JOIN BAS_CUSTOMER tt ON tt.organizationId = a.organizationId  AND tt.CustomerID = a.ToCustomerID  AND tt.customerType = 'OW'
	LEFT OUTER JOIN BAS_SKU b ON b.organizationId = a.organizationId AND b.customerId = a.toCustomerId AND b.sku = a.toSku
	LEFT OUTER JOIN BAS_CUSTOMERFREIGHT e ON e.organizationId = b.organizationId AND e.customerId = b.customerId AND e.freightCode = b.freightClass
	LEFT JOIN BAS_PACKAGE_DETAILS t ON tt.organizationId = t.organizationId AND tt.customerId = t.customerId AND tt.defaultReportUom = t.packUom AND b.packId = t.packId
	LEFT JOIN BAS_PACKAGE_DETAILS pc ON tt.organizationId = pc.organizationId AND tt.customerId = pc.customerId AND b.packId = pc.packId AND pc.packUom='CS'
	LEFT OUTER JOIN BAS_PACKAGE c ON c.organizationId = b.organizationId  AND c.customerId = b.customerId  AND c.PackID = b.PackID
	LEFT OUTER JOIN INV_LOT_ATT d ON d.organizationId = a.organizationId AND d.lotNum = a.toLotNum
	LEFT OUTER JOIN DOC_ASN_HEADER f ON f.organizationId = a.organizationId AND f.warehouseId = a.warehouseId AND f.asnNo = a.docNo
	LEFT JOIN BSM_CODE_ML t1 ON f.organizationId = t1.organizationId AND t1.codeType = 'ASN_TYP' AND f.asnType = t1.codeId AND t1.languageId = 'en'
	LEFT JOIN Z_BIL_Aggrement ba on ba.organizationId = f.organizationId AND ba.warehouseId = f.warehouseId  AND ba.customerId = f.customerId
	LEFT JOIN 
	(
		SELECT aa.organizationId, aa.warehouseId, aa.docNo, MAX( transactionTime ) putawayDate 
		FROM ACT_TRANSACTION_LOG aa 
		WHERE aa.organizationId = 'ID_8COM' AND aa.warehouseId IN ('WHCPT01','WHPGD01','WHSMG02') AND aa.transactionType = 'PA' AND aa.STATUS = '99' 
 			AND CONVERT(aa.transactionTime, DATE) >= '2022/06/20 00:00:00'
 			AND CONVERT(aa.transactionTime, DATE) <= '2022/06/25 23:59:59'
			AND aa.toCustomerId IN ('ECTUP')
		GROUP BY aa.organizationId, aa.warehouseId, aa.docNo 
	) t2 ON a.organizationId = t2.organizationId 
	AND a.warehouseId = t2.warehouseId 
	AND a.docNo = t2.docNo 
WHERE	 1 = 1 AND t1.organizationId = 'ID_8COM' AND a.warehouseId IN ('WHCPT01','WHPGD01','WHSMG02') AND a.transactionType = 'IN' AND a.STATUS = '99'  AND f.asnType NOT IN ('TRF')
	AND a.toCustomerId IN ('ECTUP') AND f.asnStatus='99'
  -- AND f.asnType='NOM' -- and f.asnType IN ('${asnType}')
	AND CONVERT(a.transactionTime, DATE) >= '2022/06/20 00:00:00'
	AND CONVERT(a.transactionTime, DATE) <= '2022/06/25 23:59:59'
-- AND a.docNo IN ('${docNo}')
AND a.warehouseId = ('WHPGD01')
	AND 1 = 1 
GROUP BY 	a.warehouseId, a.fmCustomerId, a.docNo, a.docLineNo, f.asnType, a.toSku, b.freightClass, b.skuDescr1, b.skuDescr2, c.packDescr, b.packId, t.qty, b.sku_group1, 
			d.lotAtt01, d.lotAtt02, d.lotAtt03, d.lotAtt04, d.lotAtt05, d.lotAtt06, d.lotAtt07, d.lotAtt08, f.asnReference1, f.asnReference2, f.asnReference3, f.asnReference4, f.asnReference5,
			f.udf01, f.udf02, f.udf03, f.udf04, f.udf05, f.carrierId, f.carrierName, f.supplierId, f.noteText, a.transactionTime, f.asnCreationTime, t1.codeDescr, e.freightDescr1, t.packUom, ba.handlingIn, f.supplierName, 
			t.packUom, e.freightCode, t2.putawayDate,b.cube, b.udf01, pc.qty,a.udf01
ORDER BY a.fmCustomerId, f.asnType, a.docNo, CONVERT(a.docLineNo, SIGNED), handlingIn