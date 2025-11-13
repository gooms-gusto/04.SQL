 SELECT  bsm.warehouseId,bsm.organizationId,bsm.customerId,bsm.sku,bth.tariffId,bth.tariffMasterId
  FROM BAS_SKU_MULTIWAREHOUSE bsm  INNER JOIN  
    BIL_TARIFF_HEADER bth 
    ON ( bsm.tariffMasterId = bth.tariffMasterId 
    AND  NOW() < bth.effectiveTo) WHERE  bsm.sku='000000001100002040'

-- double karena semper ada dengan tarif master yang sama
SELECT  bsm.tariffId,bsm.tariffMasterId,bsm.warehouseid FROM BAS_SKU_MULTIWAREHOUSE bsm WHERE sku ='000000001100002040';

SELECT * FROM BIL_TARIFF_HEADER bth WHERE bth.tariffMasterId='BIL00032'