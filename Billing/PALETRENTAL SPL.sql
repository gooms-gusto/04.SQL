
SELECT 
    zib.organizationId,
    zib.warehouseId,
    zib.customerId,
    DATE(zib.StockDate) AS StockDate,
    COUNT(DISTINCT zib.locationId) AS qty_TraceId,
    COUNT(DISTINCT zib.muid) AS qty_MUID,
    CASE 
        WHEN zib.customerId = 'LTL' AND zib.warehouseId = 'CBT01' AND zib.locationId LIKE 'K%' 
            THEN 'WH-K' 
        ELSE 'NOT WH-K' 
    END AS locType,
    'RP' AS chargeType,
    NOW() AS addTime,
    'CUSTOMBILL' AS addWho
FROM 
    Z_InventoryBalance zib
LEFT JOIN BAS_SKU bs ON 
    bs.organizationId = zib.organizationId 
    AND bs.sku = zib.sku 
    AND bs.customerId = zib.customerId
LEFT JOIN BAS_SKU_MULTIWAREHOUSE bsm ON 
    bsm.organizationId = zib.organizationId 
    AND bsm.sku = zib.sku 
    AND bsm.customerId = zib.customerId 
    AND bsm.warehouseId = zib.warehouseId
LEFT JOIN INV_LOT_ATT ila ON 
    ila.organizationId = zib.organizationId 
    AND ila.sku = zib.sku 
    AND ila.lotnum = zib.lotnum
LEFT JOIN BAS_LOCATION bl ON 
    bl.organizationId = zib.organizationId 
    AND bl.warehouseId = zib.warehouseId 
    AND bl.locationId = zib.locationId
WHERE 
    zib.organizationId = 'OJV_CML'  -- Ganti dengan parameter @IN_organizationId
    AND zib.customerId = 'PPG'      -- Ganti dengan parameter @IN_CustomerId
    AND zib.warehouseId = 'CBT01'   -- Ganti dengan parameter @IN_WarehouseId
    AND zib.sku NOT IN ('FULLCARTON')
    AND zib.sku NOT LIKE '130000%'
    AND zib.qtyOnHand > 0
    AND DATE(zib.StockDate) > '2025-09-25'
    AND DATE(zib.StockDate) < '2025-10-26'
    AND COALESCE(ila.lotAtt07, '') NOT IN ('O', 'OP', 'OL', 'OPC')
    AND zib.locationId NOT IN (
        'CONSWOR', 'LOST_CBT01', 'STG01', 'STG02', 'STG03', 'STG04', 'STG05',
        'STG11', 'STG12', 'STG13', 'STG14', 'STG15', 'STG06', 'STG07', 'STG08',
        'STG09', 'STG10', 'STG16', 'STG17', 'STG18', 'STG19', 'STG20',
        'SORTATIONCBT01', 'CROSSDOCK_01', 'CROSSDOCK_02', 'SORTATIONLADC01',
        'SORTATIONBASF01', 'SORTATION', 'SORTATIONCBT02', 'SORTATIONSMG-SO',
        'SORTATIONJBK01', 'SORTATION1', 'CYCLE-01S', 'STO-01', 'STO-02',
        'STO-03', 'STO-04', 'STO-05', 'WHAQC', 'WHCQC', 'WHCQC01', 'WHCQC03',
        'WHCQC05', 'WHCQC09', 'WHCQC11', 'WHCQC13', 'WHCQC15', 'WHCQC17',
        'WHCQC19', 'WHCQC21', 'WHCQC23', 'WHCQC25', 'WHCQC27', 'WHCQC29',
        'WHCQC31', 'WHCQC33', 'WHCQC35', 'WHIQC', 'WORK_AREA'
    )
    AND zib.locationCategory IN ('SD', 'DD', 'GR')
    AND COALESCE(bl.workingArea, '') NOT IN ('LTL-BULK')
GROUP BY 
    zib.organizationId,
    zib.warehouseId,
    zib.customerId,
    DATE(zib.StockDate),
    locType
ORDER BY 
    StockDate ASC;





SELECT * FROM Z_BIL_AKUM_DAYS_STORAGE zbads WHERE zbads.customerId='BCAFIN' AND zbads.chargeType='RP' AND 
     DATE(StockDate) > '2025-09-25'
    AND DATE(StockDate) < '2025-10-26'