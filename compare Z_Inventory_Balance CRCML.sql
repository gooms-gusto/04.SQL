SELECT * FROM WMS_FTEST.INV_LOT_LOC_ID illi WHERE illi.warehouseId='SMG-SO' AND illi.customerId='NLDC' AND illi.sku='F0001421';


SELECT zib.locationCategory,SUM(zib.totalCube) sumtotalcube FROM 
  Z_InventoryBalance zib WHERE zib.StockDate BETWEEN '2022-07-22' AND '2022-08-21' AND zib.customerId='MAP'
  GROUP BY zib.locationCategory