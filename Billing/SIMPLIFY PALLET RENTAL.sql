 SELECT
    zib4.organizationId,
    zib4.warehouseId,
    zib4.customerId,
    zib4.StockDate,
    SUM(zib4.qtyCharge_TraceId) AS qty_TraceId,
    SUM(zib4.qtyCharge_MUID) AS qty_MUID,
    'RP' AS chargeType
FROM (
    -- First part: Count locations by date
    SELECT
        zib.organizationId,
        zib.warehouseId,
        zib.customerId,
        DATE_FORMAT(zib.StockDate, '%Y-%m-%d') AS StockDate,
        COUNT(DISTINCT zib.locationId) AS qtyCharge_TraceId,
        COUNT(DISTINCT CASE WHEN zib.muid != '*' THEN zib.muid END) AS qtyCharge_MUID
    FROM Z_InventoryBalance zib
    LEFT JOIN INV_LOT_ATT ila ON
        ila.organizationId = zib.organizationId
        AND ila.SKU = zib.SKU
        AND ila.lotnum = zib.lotnum
    WHERE zib.organizationId = 'OJV_CML'
        AND zib.customerId = 'YFI'
        AND zib.warehouseid = 'CBT01'
        AND zib.SKU NOT IN ('FULLCARTON')
        AND zib.SKU NOT LIKE '13%'
        AND zib.qtyOnHand > 0
        AND CONVERT(zib.StockDate, DATE) BETWEEN '2025-04-26' AND '2025-05-25'
        AND ila.lotAtt07 NOT IN ('O', 'OP', 'OL', 'OPC')
        AND zib.locationId NOT IN (
            'CONSWOR', 'LOST_CBT01', 'STG01', 'STG02', 'STG03', 'STG04', 'STG05', 
            'STG11', 'STG12', 'STG13', 'STG14', 'STG15', 'STG06', 'STG07', 'STG08', 
            'STG09', 'STG10', 'STG16', 'STG17', 'STG18', 'STG19', 'STG20',
            'SORTATIONCBT01', 'CROSSDOCK_01', 'CROSSDOCK_02', 'SORTATIONLADC01', 
            'SORTATIONBASF01', 'SORTATION', 'SORTATIONCBT02', 'SORTATIONSMG-SO', 
            'SORTATION1', 'CYCLE-01S', 'STO-01', 'STO-02', 'STO-03', 'STO-04', 
            'STO-05', 'WHAQC', 'WHCQC', 'WHCQC01', 'WHCQC03', 'WHCQC05', 'WHCQC09', 
            'WHCQC11', 'WHCQC13', 'WHCQC15', 'WHCQC17', 'WHCQC19', 'WHCQC21', 
            'WHCQC23', 'WHCQC25', 'WHCQC27', 'WHCQC29', 'WHCQC31', 'WHCQC33', 
            'WHCQC35', 'WHIQC', 'WORK_AREA'
        )
        AND zib.locationCategory IN ('SD', 'DD', 'GR')
    GROUP BY
        zib.organizationId,
        zib.warehouseId,
        zib.customerId,
        DATE_FORMAT(zib.StockDate, '%Y-%m-%d')
    
    UNION ALL
    
    -- Second part: Count traceIds by date
    SELECT
        zib2.organizationId,
        zib2.warehouseId,
        zib2.customerId,
        DATE_FORMAT(zib2.StockDate, '%Y-%m-%d') AS StockDate,
        COUNT(DISTINCT 
            CASE 
                WHEN zib2.customerId IN ('API', 'ADS', 'FMI_JKT') THEN NULL 
                ELSE zib2.traceId 
            END
        ) AS qtyCharge_TraceId,
        CASE 
            WHEN COUNT(DISTINCT zib2.muid) >= 1 THEN 1 
            ELSE 0 
        END AS qtyCharge_MUID
    FROM Z_InventoryBalance zib2
    LEFT JOIN INV_LOT_ATT ila1 ON
        ila1.organizationId = zib2.organizationId
        AND ila1.SKU = zib2.SKU
        AND ila1.lotnum = zib2.lotnum
    WHERE zib2.organizationId = 'OJV_CML'
        AND zib2.customerId = 'YFI'
        AND zib2.warehouseid = 'CBT01'
        AND zib2.SKU NOT IN ('FULLCARTON')
        AND zib2.SKU NOT LIKE '13%'
        AND zib2.qtyOnHand > 0
        AND ila1.lotAtt07 NOT IN ('O', 'OP', 'OL', 'OPC')
        AND CONVERT(zib2.StockDate, DATE) BETWEEN '2025-04-26' AND '2025-05-25'
        AND zib2.locationId NOT IN (
            'CONSWOR', 'LOST_CBT01', 'STG01', 'STG02', 'STG03', 'STG04', 'STG05', 
            'STG11', 'STG12', 'STG13', 'STG14', 'STG15', 'STG06', 'STG07', 'STG08', 
            'STG09', 'STG10', 'STG16', 'STG17', 'STG18', 'STG19', 'STG20',
            'SORTATIONCBT01', 'CROSSDOCK_01', 'CROSSDOCK_02', 'SORTATIONLADC01', 
            'SORTATIONBASF01', 'SORTATION', 'SORTATIONCBT02', 'SORTATIONSMG-SO', 
            'SORTATION1', 'CYCLE-01S', 'STO-01', 'STO-02', 'STO-03', 'STO-04', 
            'STO-05', 'WHAQC', 'WHCQC', 'WHCQC01', 'WHCQC03', 'WHCQC05', 'WHCQC09', 
            'WHCQC11', 'WHCQC13', 'WHCQC15', 'WHCQC17', 'WHCQC19', 'WHCQC21', 
            'WHCQC23', 'WHCQC25', 'WHCQC27', 'WHCQC29', 'WHCQC31', 'WHCQC33', 
            'WHCQC35', 'WHIQC', 'WORK_AREA'
        )
        AND CASE 
            WHEN zib2.customerId IN ('ECMAMA', 'ECMAMAB2C') 
            THEN zib2.locationCategory IN ('BS', 'FS', 'DR', 'PK', 'VT')
            ELSE zib2.locationCategory IN ('BS', 'FS', 'DR', 'PK')
        END
    GROUP BY
        zib2.organizationId,
        zib2.warehouseId,
        zib2.customerId,
        DATE_FORMAT(zib2.StockDate, '%Y-%m-%d')
) AS zib4
GROUP BY
    zib4.organizationId,
    zib4.warehouseId,
    zib4.customerId,
    zib4.StockDate;


