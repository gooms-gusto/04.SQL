SELECT
            DATE_FORMAT(zib.StockDate, '%Y-%m-%d') AS stockDate,
            zib.warehouseId AS warehouseId,
            s.sku_group1 AS skugroup1,
            SUM(CASE WHEN zib.customerId = 'MDS' THEN (CASE WHEN pd2.uomdescr = 'KG' THEN zib.qtyonHand ELSE zib.qtyonHand * s.sku_group6 END) ELSE zib.qtyonHand END) AS qtyCharge
        FROM
            Z_InventoryBalance zib
        LEFT JOIN INV_LOT_ATT la ON la.organizationId = zib.organizationId AND la.customerId = zib.customerId AND la.sku = zib.sku AND la.lotNum = zib.lotNum
        LEFT OUTER JOIN (SELECT * FROM BSM_CODE_ML WHERE codetype = 'OWNER_LTL' AND languageid = 'en') la1 ON la.organizationId = la1.organizationId AND la.lotatt11 = la1.codeid
        LEFT JOIN BAS_LOCATION l ON l.organizationId = zib.organizationId AND l.locationId = zib.locationId AND l.warehouseId = zib.warehouseId
        LEFT JOIN BAS_SKU s ON s.organizationId = zib.organizationId AND s.customerId = zib.customerId AND s.sku = zib.sku
        LEFT JOIN BAS_SKU_MULTIWAREHOUSE sm ON sm.organizationId = zib.organizationId AND sm.customerId = zib.customerId AND sm.sku = zib.sku AND sm.warehouseId = zib.warehouseId
        LEFT JOIN BAS_PACKAGE_DETAILS pd ON sm.organizationId = pd.organizationId AND sm.customerId = pd.customerId AND sm.packId = pd.packId AND pd.packUom = 'PL'
        LEFT JOIN BAS_PACKAGE_DETAILS pd1 ON sm.organizationId = pd1.organizationId AND sm.customerId = pd1.customerId AND sm.packId = pd1.packId AND pd1.packUom = 'CS'
        LEFT JOIN BAS_PACKAGE_DETAILS pd2 ON sm.organizationId = pd2.organizationId AND sm.customerId = pd2.customerId AND sm.packId = pd2.packId AND pd2.packUom = 'EA'
        LEFT JOIN BSM_CODE_ML lc ON lc.organizationId = zib.organizationId AND zib.locationCategory = lc.codeid AND lc.codeType = 'LOC_CAT' AND lc.languageId = 'en'
        LEFT JOIN BSM_CODE_ML lc1 ON lc1.organizationId = la.organizationId AND la.lotAtt07 = lc1.codeid AND lc1.codeType = 'PLT_TYP' AND lc1.languageId = 'en'
        LEFT JOIN BSM_CODE_ML lc2 ON lc2.organizationId = la.organizationId AND la.lotAtt08 = lc2.codeid AND lc2.codeType = 'DMG_FLG' AND lc2.languageId = 'en'
        WHERE
            zib.organizationId ='OJV_CML' -- IN_organizationId
            AND zib.warehouseId ='CBT01' -- IN_warehouseId
            AND zib.customerId ='MDS' -- IN_CustomerId
            AND qtyonHand > 0
            AND zib.locationId NOT IN('CONSWOR', 'LOST_CBT01', 'STG01', 'STG02', 'STG03', 'STG04', 'STG05', 'STG11', 'STG12', 'STG13', 'STG14', 'STG15', 'STG06', 'STG07', 'STG08', 'STG09', 'STG10', 'STG16', 'STG17', 'STG18', 'STG19', 'STG20', 'SORTATIONCBT01', 'CROSSDOCK_01', 'CROSSDOCK_02', 'SORTATIONLADC01', 'SORTATIONBASF01', 'SORTATIONCBT02', 'SORTATIONCBT03', 'SORTATION', 'SORTATIONMRD02', 'SORTATIONSMG-SO', 'SORTATION1', 'CYCLE-01S', 'LOST_CBT01', 'STO-01', 'STO-02', 'STO-03', 'STO-04', 'STO-05', 'WHAQC', 'WHCQC', 'WHCQC01', 'WHCQC03', 'WHCQC05', 'WHCQC09', 'WHCQC11', 'WHCQC13', 'WHCQC15', 'WHCQC17', 'WHCQC19', 'WHCQC21', 'WHCQC23', 'WHCQC25', 'WHCQC27', 'WHCQC29', 'WHCQC31', 'WHCQC33', 'WHCQC35', 'WHIQC', 'WORK_AREA', 'B04A065', 'B04A066', 'B04B065', 'B04B065')
            AND zib.sku NOT IN (
                SELECT sku FROM BAS_SKU bs2 WHERE organizationId = zib.organizationId AND customerId = 'LTL' AND sku LIKE '13%'
                UNION ALL
                SELECT sku FROM BAS_SKU bs2 WHERE organizationid = zib.organizationId AND customerid = 'SMARTSBY' AND sku = 'PALLET'
                UNION ALL
                SELECT sku FROM BAS_SKU WHERE organizationid = zib.organizationId AND customerid IN('ECMAMA', 'ECMAMAB2C') AND sku LIKE '%TEST%'
                UNION ALL
                SELECT sku FROM BAS_SKU WHERE organizationid = zib.organizationId AND customerid IN('MAP') AND sku IN('DEMO TABLE AT', 'DEMO TABLE SAM', 'HOT STAMP')
            ) 
            AND date(zib.StockDate) > '2024-09-30' AND date(zib.StockDate) < '2024-11-01'
            GROUP BY zib.warehouseId,s.sku_group1,zib.StockDate
        ORDER BY  
            zib.customerId; 