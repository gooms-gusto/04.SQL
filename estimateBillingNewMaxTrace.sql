 SELECT
              tb.organizationId,
              tb.warehouseId,
              tb.customerId,
              MAX(IF(tb.qtyTrace >= 9999999.00000000, 9999999.00000000 - 0, IF(tb.qtyTrace - 0 < 70, 70, tb.qtyTrace - 0))) AS totalqtyCharge,
 MAX(IF(tb.qtyTrace >= 9999999.00000000, 9999999.00000000 - 0, IF(tb.qtyTrace - 0 < 70, 70, tb.qtyTrace - 0))) * 66500.00000000 AS totalAmmount
            FROM (
  /*
   SELECT
                  a.organizationId,
                  a.warehouseId,
                 zib.StockDate,
                  a.customerId,
                  COUNT(DISTINCT a.locationId),
                  COUNT(DISTINCT a.traceId) AS qtyTrace,
                  COUNT(DISTINCT a.muid),
                  SUM(a.totalCube)
                FROM (SELECT
                    zib.organizationId,
                    zib.warehouseId,
                    zib.customerId,
                    zib.locationId,
                    zib.traceId,
                    zib.muid,
                    zib.totalCube
                  FROM Z_InventoryBalance_Real zib
                    INNER JOIN INV_LOT_ATT ila
                      ON ila.organizationId = zib.organizationId
                      AND ila.lotNum = zib.LotNum
                    INNER JOIN BAS_LOCATION bl
                      ON bl.organizationId = zib.organizationId
                      AND bl.warehouseId = zib.warehouseId
                      AND bl.locationId = zib.locationId
                    INNER JOIN BAS_SKU_MULTIWAREHOUSE bsm
                      ON bsm.organizationId = zib.organizationId
                      AND bsm.warehouseId = zib.warehouseId
                      AND bsm.customerId = zib.customerId
                      AND bsm.SKU = zib.sku
                  #
                  WHERE zib.organizationId = 'OJV_CML'
                  AND zib.warehouseId = 'CBT01'
                  AND zib.StockDate = '2023-04-19'
                  AND zib.customerId = 'ITOCHU'
                  AND (ila.lotAtt07 = 'R'
                  OR 'ST' <> 'PL')
                  AND bsm.tariffMasterId = 'BIL00015'
                  AND (ISNULL('')
                  OR '' = ''
                  OR bl.locationCategory = '')
                  AND (ISNULL('')
                  OR '' = ''
                  OR bl.udf05 = '')
                  AND (ISNULL('')
                  OR '' = ''
                  OR bl.locGroup1 = '')
                  ##
                  UNION ALL
                  SELECT
                    atl.organizationId,
                    atl.warehouseId,
                    atl.toCustomerId customerId,
                    atl.toLocation AS locationId,
                    atl.toId traceId,
                    atl.toMuid muid,
                    atl.totalCubic
                  FROM ACT_TRANSACTION_LOG atl
                    INNER JOIN INV_LOT_ATT ila
                      ON ila.organizationId = atl.organizationId
                      AND ila.lotNum = atl.toLotNum
                    INNER JOIN BAS_LOCATION bl
                      ON bl.organizationId = atl.organizationId
                      AND bl.warehouseId = atl.toWarehouse
                      AND bl.locationId = atl.toLocation
                    INNER JOIN BAS_SKU bs
                      ON bs.organizationId = atl.organizationId
                      AND bs.customerId = atl.toCustomerId
                      AND bs.sku = atl.toSku
                  #
                  WHERE atl.organizationId = 'OJV_CML'
                  AND atl.warehouseId = 'CBT01'
                  AND atl.status = '99'
                  AND atl.transactionType = 'IN'
                  AND atl.transactionTime >= STR_TO_DATE('2023-04-20', '%Y-%m-%d')
                  AND ila.lotAtt03 >= '2023-04-20'
                  AND ila.lotAtt03 <= '5/19/2023'
                  AND (ila.lotAtt07 = 'R'
                  OR 'ST' <> 'PL')
                  AND (ISNULL('')
                  OR '' = ''
                  OR bl.locationCategory = '')
                  AND (ISNULL('')
                  OR '' = ''
                  OR bl.udf05 = '')
                  AND (ISNULL('')
                  OR '' = ''
                  OR bl.locGroup1 = '')) a
                GROUP BY a.organizationId,
                         a.warehouseId,
                         a.customerId;
 */




  SELECT
                zib.organizationId,
                zib.warehouseId,
                zib.StockDate,
                zib.customerId,
                COUNT(DISTINCT zib.locationId),
                COUNT(DISTINCT zib.traceId) AS qtyTrace,
                COUNT(DISTINCT zib.muid),
                SUM(zib.totalCube)
              FROM Z_InventoryBalance_Real zib
                INNER JOIN INV_LOT_ATT ila
                  ON ila.organizationId = zib.organizationId
                  AND ila.lotNum = zib.LotNum
                INNER JOIN BAS_LOCATION bl
                  ON bl.organizationId = zib.organizationId
                  AND bl.warehouseId = zib.warehouseId
                  AND bl.locationId = zib.locationId
                INNER JOIN BAS_SKU_MULTIWAREHOUSE bsm
                  ON bsm.organizationId = zib.organizationId
                  AND bsm.warehouseId = zib.warehouseId
                  AND bsm.customerId = zib.customerId
                  AND bsm.SKU = zib.sku
              #
              WHERE zib.organizationId = 'OJV_CML'
              AND zib.warehouseId = 'CBT01'
              AND zib.StockDate >= '2023-03-26'
              AND zib.StockDate <= '2023-04-25'
              AND zib.customerId = 'ITOCHU'
              AND (ila.lotAtt07 = 'R'
              OR 'ST' <> 'PL')
              AND bsm.tariffMasterId = 'BIL00015'
              AND (ISNULL('')
              OR '' = ''
              OR bl.locationCategory = '')
              AND (ISNULL('')
              OR '' = ''
              OR bl.udf05 = '')
              AND (ISNULL('')
              OR '' = ''
              OR bl.locGroup1 = '')
              GROUP BY zib.organizationId,
                       zib.warehouseId,
                       zib.StockDate,
                       zib.customerId
  
  
  
  ) tb
            WHERE tb.qtyTrace > 0
            GROUP BY tb.organizationId,
                     tb.warehouseId,
                     tb.customerId;