SELECT
        doh.customerId,
        doh.orderNo,
        doh.organizationId,
        aad.SKU,
        FORMAT_DATE("%Y-%m-%d %H:%M:%S",DATETIME (aad.shipmentTime)) AS ShipmentTime,
        CAST(aad.qty AS STRING) AS qty,
        CAST(aad.qty_each AS STRING) AS qty_each,
        CAST(aad.qtyShipped_each AS STRING) AS qtyShipped_each,
        aad.uom,
        bsm.SKU,
        bsm.tariffMasterId,
        CAST(bs.grossWeight AS STRING) AS grossWeight,
        FORMAT_DATE("%Y-%m-%d %H:%M:%S", DATETIME (aad.editTime)) AS editTime,
        aad.lotNum,
        aad.traceId,
        aad.pickToTraceId,
        aad.dropId,
        aad.location,
        aad.pickToLocation,
        doh.soStatus,
        doh.orderType,
        doh.warehouseId,
        ila.lotatt01,
        ila.lotatt02,
        ila.lotatt03,
        ila.lotatt04,
        ila.lotatt05,
        ila.lotatt06,
        ila.lotatt07,
        ops.cartonId,
        bc.cartonDescr,
        bc.udf01,
        FROM
        `linc-sci.app.ACT_ALLOCATION_DETAILS` aad
        LEFT OUTER JOIN
        `linc-sci.app.DOC_ORDER_HEADER` AS doh
        ON
        doh.orderNo = aad.orderNo
        AND doh.customerId = aad.customerId
        AND doh.warehouseId = aad.warehouseId
        LEFT OUTER JOIN
        `linc-sci.app.BAS_SKU` AS bs
        ON
        bs.SKU= aad.SKU
        AND bs.customerId = aad.customerId
        LEFT OUTER JOIN
        `linc-sci.app.BAS_SKU_MULTIWAREHOUSE` AS bsm
        ON
        bsm.SKU = aad.SKU
        AND bsm.customerId = aad.customerId
        AND bsm.warehouseId = doh.warehouseId
        LEFT JOIN
        `linc-sci.app.INV_LOT_ATT` AS ila
        ON
        ila.SKU = aad.SKU
        AND ila.lotNum = aad.lotNum
        and ila.customerId = aad.customerId
        LEFT JOIN `linc-sci.app.DOC_ORDER_PACKING_SUMMARY` ops on ops.organizationId = aad.organizationId AND ops.warehouseId = aad.warehouseId  AND ops.orderNo = aad.orderNo
        LEFT JOIN `linc-sci.app.BAS_CARTON` bc ON ops.cartonId = bc.cartonId AND                
            CASE                
            WHEN bs.customerId IN('ECMAMA','ECBBA', 'ECCOCO', 'ECCOCO_2', 'ECTUP') THEN 'STANDARD'              
            WHEN bs.customerId IN ('ECINGSAL', 'ECINGCOM', 'ECING_TSTER') THEN 'ECING'              
            WHEN bs.customerId IN ('RBIZB2B', 'RBIZBUSTAR', 'RBIZNAMEERA') THEN 'RBIZ'              
            WHEN bs.customerId IN ('ECZAP_2', 'ECZAPLAZ', 'ECZAPSPE') THEN 'ECZAP'              
            ELSE bs.customerId END = CASE WHEN bc.cartonGroup = 'LOG99' THEN 'LOGISTIC_99' ELSE bc.cartonGroup END  
        WHERE
        aad.warehouseId = '$warehouseId'
        AND aad.customerId = '$company_id'
        AND aad.status = '80'
        AND date( aad.shipmentTime ,"Asia/Jakarta") >= '$startDate'
        AND date( aad.shipmentTime ,"Asia/Jakarta") <= '$endDate'
        AND DOH.orderType NOT IN ('TROF', 'REOF')        
        group by
        doh.customerId,
        doh.orderNo,
        doh.organizationId,
        aad.SKU,
        ShipmentTime,
        aad.qty,
        aad.qty_each,
        aad.qtyShipped_each,
        aad.uom,
        bsm.SKU,
        bsm.tariffMasterId,
        bs.grossWeight,
        aad.editTime,
        aad.lotNum,
        aad.traceId,
        aad.pickToTraceId,
        aad.dropId,
        aad.location,
        aad.pickToLocation,
        doh.soStatus,
        doh.orderType,
        doh.warehouseId,
        ila.lotatt01,
        ila.lotatt02,
        ila.lotatt03,
        ila.lotatt04,
        ila.lotatt05,
        ila.lotatt06,
        ila.lotatt07,
        ops.cartonId,
        bc.cartonDescr,
        bc.udf01
        ORDER BY ShipmentTime DESC LIMIT $maxResults OFFSET $skip;