SELECT 
        CASE WHEN b.cube <= 2000 THEN "Barang Kecil" ELSE "Barang Besar" END goodsType,
        a.warehouseId, a.fmCustomerId AS customerId, a.toSku AS sku, b.skuDescr1, a.docNo AS asnNo, t1.codeDescr AS asnType, a.docLineNo AS asnLineNo,
        FORMAT_DATE("%Y-%m-%d %H:%M:%S", DATETIME (f.asnCreationTime))AS asnCreationTime,
        FORMAT_DATE("%Y-%m-%d %H:%M:%S", DATETIME ( a.transactionTime)) AS transactionTime,
        CAST(SUM( a.toQty_Each ) AS STRING) AS qtyEA,
        -- CAST((IFNULL(sum( a.toQty_Each ),1) / IFNULL(pc.qty,1)) AS STRING) AS qtyCS,
        CAST(IFNULL(SUM( a.toQty_Each ),1) AS STRING) AS qtyCS2,
        CAST(IFNULL(pc.qty,1) AS STRING) AS qtyCS3,
        b.skuDescr2, b.sku_group1, b.freightClass as freightCode,
        b.packId, t.packUom, 
        CAST(( ( SUM( a.toQty_Each ) ) / t.qty ) AS STRING) AS vasLabeling,
        CAST(b.cube AS STRING) AS cubeNya,
        CAST(( ( SUM( a.toQty_Each ) ) * b.cube) AS STRING) AS totalCube,
        b.udf01 AS cbm,
        CAST((( ( SUM( a.toQty_Each ) ) * b.cube) / 1000000) AS STRING) AS totalCbm,
        CAST(SUM( a.totalGrossWeight ) AS STRING) AS grossWeight,
        f.udf02, f.carrierId, f.carrierName, f.supplierId, f.supplierName,f.asnReference1, f.asnReference3,
        CASE WHEN (a.docLineNo = 1 AND a.udf01 is null) THEN 1 ELSE 0 END valuePo,
        d.lotAtt01 AS productionDate, d.lotAtt02 AS expirationDate, d.lotAtt03 AS inboundDate, d.lotAtt04 AS batchNumber,
        '' AS agingPeriod,d.lotAtt08 AS stockCondition, f.noteText AS noteText
        FROM linc-sci.app.ACT_TRANSACTION_LOG a
        LEFT OUTER JOIN linc-sci.app.BAS_CUSTOMER tt ON tt.organizationId = a.organizationId  AND tt.CustomerID = a.ToCustomerID  AND tt.customerType = 'OW'
        LEFT OUTER JOIN linc-sci.app.BAS_SKU b ON b.organizationId = a.organizationId AND b.customerId = a.toCustomerId AND b.sku = a.toSku
        LEFT JOIN linc-sci.app.BAS_PACKAGE_DETAILS t ON tt.organizationId = t.organizationId AND tt.customerId = t.customerId AND tt.defaultReportUom = t.packUom AND b.packId = t.packId
        LEFT JOIN linc-sci.app.BAS_PACKAGE_DETAILS pc ON tt.organizationId = pc.organizationId AND tt.customerId = pc.customerId AND b.packId = pc.packId AND pc.packUom='CS'
        LEFT OUTER JOIN linc-sci.app.BAS_PACKAGE c ON c.organizationId = b.organizationId  AND c.customerId = b.customerId  AND c.PackID = b.PackID
        LEFT OUTER JOIN linc-sci.app.INV_LOT_ATT d ON d.organizationId = a.organizationId AND d.lotNum = a.toLotNum
        LEFT OUTER JOIN linc-sci.app.DOC_ASN_HEADER f ON f.organizationId = a.organizationId AND f.warehouseId = a.warehouseId AND f.asnNo = a.docNo
        LEFT JOIN linc-sci.app.BSM_CODE_ML t1 ON f.organizationId = t1.organizationId AND t1.codeType = 'ASN_TYP' AND f.asnType = t1.codeId AND t1.languageId = 'en'
        WHERE	 1 = 1 AND t1.organizationId = 'ID_8COM' AND a.warehouseId IN ('$warehouseId') AND a.transactionType = 'IN' AND a.STATUS = '99'  AND f.asnType NOT IN ('TRF')
        AND a.toCustomerId IN ('$company_id') AND f.asnStatus='99'
        AND date( a.transactionTime,"Asia/Jakarta") >= "$startDate"
        AND date( a.transactionTime,"Asia/Jakarta") <= "$endDate"
        AND a.warehouseId = ('$warehouseId')
        AND 1 = 1 
        GROUP BY a.warehouseId, a.fmCustomerId, a.docNo, a.docLineNo, f.asnType, a.toSku, b.freightClass, b.skuDescr1, b.skuDescr2, c.packDescr, b.packId, t.qty, b.sku_group1,
        d.lotAtt01, d.lotAtt02, d.lotAtt03, d.lotAtt04, d.lotAtt05, d.lotAtt06, d.lotAtt07, d.lotAtt08, f.asnReference1, f.asnReference2, f.asnReference3, f.asnReference4, f.asnReference5,
        f.udf01, f.udf02, f.udf03, f.udf04, f.udf05, f.carrierId, f.carrierName, f.supplierId, f.noteText, a.transactionTime, f.asnCreationTime, t1.codeDescr,
        t.packUom,f.supplierName, t.packUom, b.cube, b.udf01,pc.qty,a.udf01 
        ORDER BY a.fmCustomerId, f.asnType, a.docNo ASC LIMIT $maxResults OFFSET $skip;