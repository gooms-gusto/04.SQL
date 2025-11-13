USE wms_cml;


SELECT * 
FROM DOC_TRANSFER_HEADER dth
INNER JOIN DOC_TRANSFER_DETAILS dtd
ON dth.organizationId = dtd.organizationId
AND dth.warehouseId = dtd.warehouseId
AND dth.tdocNo = dtd.tdocNo
WHERE dtd.organizationId='OJV_CML'
AND dtd.warehouseId='CBT02-B2C'
AND dth.customerId='ECMAMA'
AND dth.tdocNo=''