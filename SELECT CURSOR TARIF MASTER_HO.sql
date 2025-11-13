	  SELECT DISTINCT
              IFNULL(CAST(doh.organizationId AS char), '') AS organizationId,
              IFNULL(CAST(doh.orderNo AS char), '') AS orderNo,       
              IFNULL(CAST(doh.warehouseId AS char(255)), '') AS warehouseId,
              IFNULL(CAST(aad.customerId AS char(255)), '') AS customerId,          
              IFNULL(CAST(aad.SKU AS char(255)), '') AS SKU,
              IFNULL(CAST(bsm.tariffMasterId AS char(255)), '') AS tariffMasterId
            FROM ACT_ALLOCATION_DETAILS aad

              LEFT OUTER JOIN DOC_ORDER_HEADER doh
                ON doh.organizationId = aad.organizationId
                AND doh.customerId = aad.customerId
                AND doh.orderNo = aad.orderNo
              LEFT OUTER JOIN BAS_SKU bs
                ON bs.organizationId = aad.organizationId
                AND bs.SKU = aad.SKU
                AND bs.customerId = aad.customerId
              LEFT OUTER JOIN BAS_SKU_MULTIWAREHOUSE bsm
                ON bsm.organizationId = bs.organizationId
                AND bsm.SKU = bs.SKU
                AND bsm.customerId = bs.customerId
                AND bsm.warehouseId = aad.warehouseId
            WHERE aad.customerId = 'MAP'
            AND aad.warehouseId = 'CBT01'
			       AND aad.orderNo='MAPASN1309230001'
            AND aad.Status IN ('99', '80')
            AND bs.skuDescr1 NOT LIKE '%PALLET%'
            AND doh.orderType NOT IN ('FREE', 'KT', 'OT')
