SELECT zib.locationCategory,SUM(zib.totalCube) AS totalcube FROM 
  Z_InventoryBalance_Real zib WHERE zib.StockDate
  BETWEEN '2022-07-21' AND '2022-08-22' 
  AND zib.customerId='MAP' AND zib.warehouseId='CBT01' AND zib.locationCategory IN ('FS','GR')
  GROUP BY zib.locationCategory;

  SELECT zib.locationCategory,zib.totalCube ,zib.StockDate,zib.traceId,zib.locationId FROM 
  Z_InventoryBalance_Real zib WHERE zib.StockDate
  BETWEEN '2022-07-21' AND '2022-08-22' 
  AND zib.customerId='MAP' AND zib.warehouseId='CBT01' AND zib.locationCategory IN ('FS','GR')
  GROUP BY zib.locationCategory;