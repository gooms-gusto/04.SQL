SELECT  tzb.warehouseId,
  tzb.customerId,
  tzb.StockDate, 
  tzb.sku,clc.tariffId,
  clc.tariffMasterId,
  SUM(tzb.qtyavailable) AS qtytotal
FROM 
  wms_cml.Z_InventoryBalance tzb
  INNER JOIN wms_cml.BAS_CUSTOMER tbc ON (tzb.organizationId=tbc.organizationId AND tzb.customerId = tbc.customerId AND tbc.customerType='OW')
  INNER JOIN (
  SELECT bsm.warehouseId,bsm.customerId,bsm.sku,bth.tariffId,bth.tariffMasterId
  FROM wms_cml.BAS_SKU_MULTIWAREHOUSE bsm  LEFT JOIN 
    wms_cml.BIL_TARIFF_HEADER bth 
    ON ( bsm.tariffMasterId = bth.tariffMasterId 
    AND  CURRENT_DATE() < date(bth.effectiveTo))) clc ON (tzb.warehouseId=clc.warehouseId 
  AND tzb.customerId=clc.customerId AND tzb.sku=clc.sku)
WHERE tzb.StockDate BETWEEN '2023-05-01' AND '2023-05-01' AND tzb.customerId='MAP' and tzb.qtyavailable> 0
  GROUP BY tzb.warehouseId,tzb.customerId,tzb.StockDate,tzb.sku,
clc.tariffId,
  clc.tariffMasterId;