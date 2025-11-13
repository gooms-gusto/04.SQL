      
     -- SELECT * FROM BIL_SUMMARY bs WHERE bs.organizationId='OJV_CML' AND bs.warehouseId='K 
      
      SELECT DISTINCT dod.warehouseId, dod.orderNo FROM DOC_ORDER_DETAILS dod
       INNER JOIN DOC_ORDER_HEADER_UDF dohu ON dod.organizationId = dohu.organizationId AND
       dod.warehouseId = dohu.warehouseId AND dod.orderNo = dohu.orderNo
       WHERE dod.organizationId='OJV_CML'
         AND dod.customerId='MAP' 
       AND dod.sku IN ('0000000000001567201041',
'0000000000001567211041',
'0000000000001572031508',
'0000000000001572031339',
'0000000000001567221041')
       AND dohu.closeTime > getBillFMDate(25);


       SELECT DISTINCT dad.asnNo,dad.warehouseId FROM DOC_ASN_DETAILS dad 
       INNER JOIN DOC_ASN_HEADER_UDF dahu   ON dad.organizationId = dahu.organizationId AND
       dad.warehouseId = dahu.warehouseId AND dad.asnNo = dahu.asnNo
       WHERE dad.organizationId='OJV_CML'
        AND dad.customerId='MAP' 
       AND dad.sku IN ('0000000000001567201041',
'0000000000001567211041',
'0000000000001572031508',
'0000000000001572031339',
'0000000000001567221041')
       AND dahu.closeTime > getBillFMDate(25);