     
SELECT aad.orderNo, aad.workStation ,aad.pickToTraceId, aad.udf05 ,dlh.ldlNo ,aad.traceId,aad.packFlag
FROM 
ACT_ALLOCATION_DETAILS aad
INNER JOIN DOC_ORDER_HEADER doh
ON (aad.organizationId = doh.organizationId AND aad.warehouseId = doh.warehouseId
AND aad.orderNo = doh.orderNo AND aad.customerId = doh.customerId AND aad.waveNo = doh.waveNo)
INNER JOIN DOC_ORDER_HEADER_UDF dohu ON (aad.organizationId = dohu.organizationId
AND aad.warehouseId = dohu.warehouseId AND aad.orderNo = dohu.orderNo)
INNER JOIN DOC_LOADING_HEADER dlh ON aad.organizationId = dlh.organizationId
AND aad.warehouseId = dlh.warehouseId AND aad.waveNo = dlh.waveNo
WHERE aad.organizationId='OJV_CML'
AND aad.warehouseId='CBT01'
AND aad.customerId='PPG'
 AND aad.udf05 IS NULL
AND  doh.soStatus='99'
AND DATE(dohu.closeTime) >='2025-04-01' 
AND DATE(dohu.closeTime) <= DATE(NOW());

SELECT * FROM ACT_ALLOCATION_DETAILS aad WHERE aad.organizationId='OJV_CML' 
AND aad.warehouseId='CBT01' AND aad.orderNo='SOPPG2506040038';


SELECT * FROM BAS_LOCATION bl WHERE bl.locationId ='C13A001';


SELECT * FROM DOC_LOADING_DETAILS dld WHERE dld.organizationId='OJV_CML'
AND dld.warehouseId='CBT01'
   AND dld.ldlNo='LDL250609030'
