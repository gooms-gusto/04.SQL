SELECT
        DISTINCT
        zib.customerId,
        zib.warehouseid,
        zib.organizationId,
        zib.UOM,
        zib.SKU,
        zib.SKUDesc,
        zib.muid,
        zib.traceId,
        zib.lotNum,
        zib.packkey,
        FORMAT_DATE("%Y-%m-%d",DATETIME (zib.StockDate)) as StockDate,
        CAST(zib.netWeight AS STRING) as netWeight,
        CAST(zib.grossWeight AS STRING) as grossWeight,
        zib.qtyonHand,
        zib.qtyPicked,
        zib.qtyavailable,
        zib.qtyallocated,
        CAST(zib.`cube` AS STRING) as `cubeNya`,
        CAST(zib.`totalcube` AS STRING) as `totalcube`,
        CAST((zib.totalcube/1000000) AS STRING) as TotalCBM,
        zib.locationId,
        zib.locationCategory,
        from `linc-sci.app.z_inventorybalance_bill` as zib
        where zib.customerId ='$company_id' and zib.warehouseid='$warehouseId'
        AND zib.SKU not in ('FULLCARTON') 
        AND zib.qtyOnHand > 0 
        AND StockDate between '$startDate' AND '$endDate'
        ORDER BY StockDate DESC LIMIT $maxResults OFFSET $skip;