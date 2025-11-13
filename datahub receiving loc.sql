UPDATE DOC_ASN_DETAILS A, BSM_CONFIG B SET A.receivingLocation = B.defaultValue 
WHERE B.organizationId = 'OJV_CML'
AND B.configId = 'DFT_RCV_LOC'
AND A.organizationId = 'OJV_CML'
AND A.warehouseId = 'CBT02'
AND A.customerId = 'MAP'
AND A.asnNo = 'ASN000074'
AND A.asnLineNo = 1
AND A.receivingLocation IS NULL