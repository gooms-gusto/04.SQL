USE WMS_FTEST;

SELECT dvh.organizationId,dvh.warehouseId,dvh.vasNo,dvh.vasStatus,
dvd.customerId,dvd.vasLineNo,dvd.lineStatus ,dvd.sku,dvd.locationId,
dvs.vasType,dvf.chargeCategory,dvf.chargeType,
dvf.rateQty1 AS qtycharge
FROM 
DOC_VAS_HEADER dvh INNER JOIN 
DOC_VAS_DETAILS dvd ON 
dvh.organizationId = dvd.organizationId
AND dvh.warehouseId = dvd.warehouseId
AND dvh.vasNo = dvd.vasNo
AND dvh.customerId = dvd.customerId
INNER JOIN DOC_VAS_SERVICE dvs ON 
dvh.organizationId = dvs.organizationId 
AND dvh.warehouseId = dvs.warehouseId
AND dvh.vasNo = dvs.vasNo
INNER JOIN DOC_VAS_FEE dvf ON 
dvh.organizationId = dvf.organizationId
AND dvd.warehouseId = dvf.warehouseId
AND dvh.vasNo = dvf.vasNo
WHERE dvh.vasNo='KT240110001'
