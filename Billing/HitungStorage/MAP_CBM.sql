 -- CREATE VIEW cml_ls_view_storage AS

SELECT 
ls_storage.warehouseid,
SUM( ls_storage.qtycbm)
FROM (
 SELECT
    DATE_FORMAT(stockDate, '%Y-%m-%d') AS stockdate,
    zib.warehouseId AS warehouseid,
    sm.tariffMasterId AS tariffmasterid,
    CASE WHEN zib.customerId = 'LTL' THEN la1.codeDescr ELSE sm.tariffId END AS tariffid,
    CASE WHEN zib.customerId = 'MAP' THEN 'SAMSONITE' ELSE zib.customerId END AS customerid,
    zib.locationId AS locationid,
    zib.locationCategory AS locationcategory,
    lc.codeDescr AS locationcategorydescr,
    zib.TRACEID AS traceid,
    s.sku_group1 AS muidltl,
    zib.muid AS muid,
    zib.lotNum AS lotnum,
    s.PACKID AS packid,
    CASE WHEN zib.customerId = 'MDS' THEN 'KG' ELSE zib.UOM END AS uom,
    zib.SKU AS sku,
    skuDesc AS skudesc,
    la.lotatt09 AS ponum,
    lc1.codeDescr AS typepallet,
    CASE WHEN zib.customerId = 'MDS' THEN (
            CASE WHEN pd2.uomDescr = 'KG' THEN zib.qtyonHand ELSE zib.qtyonHand * s.sku_group6 END
        ) ELSE zib.qtyonHand 
    END AS qtyonhand,
    pd.qty AS qtyperpallet,
    CASE zib.customerId 
        WHEN 'ASP' THEN zib.cube 
        WHEN 'MAP' THEN s.cube 
        WHEN 'ONDULINE' THEN s.cube 
        WHEN 'SST_JKT' THEN s.cube 
        WHEN 'CPI_JKT' THEN s.cube 
        ELSE s.cube / 1000000 
    END AS cbmsku,
    CASE zib.customerId 
        WHEN 'MAP' THEN (
            CASE WHEN la.lotatt04 = 'SET' THEN 0 ELSE (s.cube * zib.qtyonHand) END
        ) WHEN 'ONDULINE' THEN s.cube * zib.qtyonHand 
        ELSE totalcube 
    END AS qtycbm,
    CASE 
        WHEN LENGTH(zib.locationId) = 7 THEN SUBSTRING(zib.locationId, 1, 1) 
        WHEN LENGTH(zib.locationId) = 8 THEN SUBSTRING(zib.locationId, 1, 1) 
        WHEN SUBSTRING(zib.locationId, 1, 3) = 'TML' AND zib.customerId <> 'LTL' THEN SUBSTRING(zib.locationId, 4, 1) 
        WHEN sm.putawayRule = 'LTL09' THEN 'E' 
        WHEN zib.SKU IN ('000000001100012851', '000000001100010211', '000000001100000616', '000000001100013296', '000000001100008797', '000000001100012070', '000000001100012068', '000000001100012478', '000000001100012898', '000000001100014515') THEN 'G' 
        WHEN sm.putawayRule IN ('LTL03', 'GMPA-NONDG', 'ICHIKOH-NONDG', 'ITOCHU-NONDG', 'PMM-NONDG', 'LTL06', 'LTL07') THEN 'G' 
        WHEN sm.putawayRule IN ('LTL08', 'ITOCHU-DG', 'PMM-DG', 'LTL01', 'LTL02', 'SMT') THEN 'B' 
        WHEN sm.putawayRule = 'LTL-BULK' THEN 'D' 
        WHEN sm.putawayRule IN ('BAJ', 'PLB-LTL', 'ADF', 'CCDI', 'CTI') THEN 'A' 
        WHEN sm.putawayRule IN ('GYI', 'DKJ') THEN 'J' 
        WHEN sm.putawayRule = 'LTL04' THEN 'B' 
        WHEN sm.putawayRule IN ('DNN', 'PMM', 'ITOCHU') THEN 'C' 
        ELSE l.udf03 
    END AS chamber,
    sm.putawayRule AS putawayrule,
    la.lotatt04 AS batchno,
    la.lotatt02 AS expiredate,
    la.lotatt03 AS whdate,
    CASE 
        WHEN zib.customerId = 'ECCOSBY' THEN (
            CASE WHEN SUBSTRING(zib.locationId, 3, 1) = 'I' THEN 'ECCO2' ELSE 'ECCO' END
        ) ELSE SUBSTRING(zib.locationId, 1, 1) 
    END AS area,
    CASE WHEN zib.customerId = 'PLB-LTL' THEN la.lotatt10 ELSE la.lotatt09 END AS externalpo,
    lc2.codeDescr AS whetherdamaged,
    CEILING(qtyonHand / pd.qty) AS palletused,
    CASE WHEN zib.customerId = 'RBFOOD' THEN pd1.qty ELSE s.NETWEIGHT END AS netweight
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
            zib.organizationId ='OJV_CML'
            AND zib.warehouseId IN ('CBT02','CBT03','LADC01')
            AND zib.customerId ='MAP'
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
          AND date(zib.StockDate) = date(DATE_ADD(NOW(), INTERVAL - 1 DAY))
           -- AND date(zib.StockDate) > '2024-10-31' AND date(zib.StockDate) < '2024-11-15'
        ORDER BY zib.customerId
        ) ls_storage
        GROUP BY ls_storage.warehouseid