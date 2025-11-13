SELECT
        ORGANIZATIONID                   ,
        CUSTOMERID_WH                    ,
        APPNO                            ,
        REMARKSCURAH                     ,
        LDLNO                            ,
        CUSTOMERID_OW                    ,
        WAVENO                           ,
        SOREFERENCE1                     ,
        VEHICLENO                        ,
        VEHICLETYPE                      ,
        CARRIERNAME                      ,
        DRIVER                           ,
        ORDERNO                          ,
        ORDERLINENO                      ,
        CONSIGNEECODE                    ,
        CONSIGNEENAME                    ,
        CONSIGNEEADDRESS                 ,
        CONSIGNEE_CITY                   ,
        CONSIGNEE_ZIP                    ,
        CONSIGNEE_STATE                  ,
        CONSIGNEE_CONT                   ,
        STATUS_KOTA                      ,
        SKU                              ,
        SKUDESCR                         ,
        SUM(QTY_TOTAL) AS QTY_TOTAL      ,
        UOM                              ,
        SUM(PICKQTYEA) AS PICKQTYEA      ,
        EAUOMTEXT                        ,
     --   SUM(WEIGHT_TOTAL) AS WEIGHT_TOTAL,
        SUM(CUBIC_TOTAL)  AS CUBIC_TOTAL ,
        BATCHNO                          ,
        NOTETEXT                         ,
        PACKID                           ,
        BILADDR1                         ,
        ORDERTIME                        ,
        SJPRINT_FLAG
FROM
        (
                
                SELECT
                        h2.organizationId                                                 AS ORGANIZATIONID,
                        h2.warehouseId                                                    AS CUSTOMERID_WH ,
                        dapd.appointmentNo                                                AS APPNO         ,
                        dapd.udf05                                                        AS REMARKSCURAH  ,
                        lh.ldlNo                                                          AS LDLNO         ,
                        h3.customerId                                                     AS CUSTOMERID_OW ,
                        h2.waveNo                                                         AS WAVENO        ,
                        h3.soReference1                                                   AS SOREFERENCE1  ,
                        lh.vehicalNo                                                      AS VEHICLENO     ,
                        lh.vehicleType                                                    AS VEHICLETYPE   ,
                        lh.carrierName                                                    AS CARRIERNAME   ,
                        lh.driver                                                         AS DRIVER        ,
                        CASE WHEN h2.dropId = '' THEN h2.pickToTraceId ELSE h2.dropId END AS
                        TRACEID                                 ,
                        h3.orderNo           AS ORDERNO         ,
                        h2.orderLineNo       AS ORDERLINENO     ,
                        h3.consigneeId       AS CONSIGNEECODE   ,
                        h3.consigneeName     AS CONSIGNEENAME   ,
                        h3.consigneeAddress1 AS CONSIGNEEADDRESS,
                        co.city              AS CONSIGNEE_CITY  ,
                        co.zipCode           AS CONSIGNEE_ZIP   ,
                        co.province          AS CONSIGNEE_STATE ,
                        co.contact1          AS CONSIGNEE_CONT  ,
                        CASE WHEN co.udf01 = 'DK' THEN 'Dalam Kota' WHEN co.udf01 = 'LK' THEN
                                        'Luar Kota' END AS STATUS_KOTA,
                        h2.sku                          AS SKU        ,
                        sku.skuDescr1                   AS SKUDESCR   ,
                        SUM(h2.qty_each)                AS QTY_TOTAL  ,
                        'PC'                            AS UOM        ,
                        bpduom.uomDescr                 AS UOMDESCR   ,
                        SUM(h2.qty_each)                AS PICKQTYEA  ,
                        T2.uomDescr                     AS EAUOMTEXT  ,
                
                        ROUND(SUM(h2.qty * sku.cube), 6)                                    AS CUBIC_TOTAL ,
                        dod.udf03                                                           AS BATCHNO     ,
                        h3.noteText                                                         AS NOTETEXT    ,
                        sku.packId                                                          AS PACKID      ,
                        h3.billingAddress1                                                  AS BILADDR1    ,
                        h3.ORDERTIME                                                        AS ORDERTIME   ,
                        CASE WHEN h3.deliveryNoteprintFlag = 'N' THEN '' ELSE 'Reprint' END AS
                        SJPRINT_FLAG
                FROM
                        ACT_ALLOCATION_DETAILS h2
                LEFT OUTER JOIN DOC_ORDER_HEADER h3
                ON
                        h2.organizationId  = h3.organizationId
                        AND h2.warehouseId = h3.warehouseId
                        AND h2.orderNo     = h3.orderNo
                LEFT OUTER JOIN DOC_ORDER_DETAILS dod1 ON(h2.warehouseId=dod1.warehouseId and
                h2.customerId=dod1.customerId and  h2.orderNo=dod1.orderNo AND h2.orderLineNo=dod1.orderLineNo AND h2.sku=dod1.sku)
                LEFT OUTER JOIN DOC_WAVE_HEADER wh
                ON
                        wh.organizationId  = h3.organizationId
                        AND wh.warehouseId = h3.warehouseId
                        AND wh.waveNo      = h3.waveNo
                LEFT OUTER JOIN DOC_LOADING_HEADER lh
                ON
                        lh.organizationId  = h3.organizationId
                        AND lh.warehouseId = h3.warehouseId
                        AND lh.waveNo      = h3.waveNo
                LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpduom
                ON
                        bpduom.organizationId = h2.organizationId
                        AND bpduom.customerId = h2.customerId
                        AND bpduom.packId     = h2.packId
                        AND bpduom.packUom    = h2.uom
                LEFT OUTER JOIN BAS_SKU sku
                ON
                        sku.organizationId = h2.organizationId
                        AND sku.sku        = h2.sku
                        AND sku.customerId = h2.customerId
                   LEFT JOIN BAS_PACKAGE_DETAILS ppg
                    ON dod1.organizationId = ppg.organizationId
                    AND dod1.customerId = ppg.customerId
                    AND dod1.packId = ppg.packId
                    AND dod1.packUom =ppg.packUom
                LEFT OUTER JOIN INV_LOT_ATT la
                ON
                        h2.organizationId = la.organizationId
                        AND h2.lotNum     = la.lotNum
                        AND h2.customerId = la.customerId
                        AND la.sku        = h2.sku
                LEFT OUTER JOIN BAS_PACKAGE_DETAILS T2
                ON
                        h2.organizationId = T2.organizationId
                        AND T2.packUom    = 'EA'
                        AND h2.packId     = T2.packId
                        AND h2.customerId = T2.customerId
                LEFT OUTER JOIN
                        (
                                
                                SELECT * FROM BAS_CUSTOMER WHERE customerType = 'CO'
                        )
                        co
                ON
                        co.customerId = h3.consigneeId
                LEFT OUTER JOIN
                        (
                                
                                SELECT * FROM DOC_APPOINTMENT_DETAILS WHERE docType = 'LOAD'
                        )
                        dapd
                ON
                        dapd.organizationId  = lh.organizationId
                        AND dapd.warehouseId = lh.warehouseId
                        AND dapd.docNo       = lh.ldlNo
                LEFT OUTER JOIN
                        (
                                
                                SELECT
                                        organizationid,
                                        orderNo       ,
                                        orderLineNo   ,
                                        customerid    ,
                                        warehouseid   ,
                                        SKU           ,
                                        udf03
                                FROM
                                        DOC_ORDER_DETAILS
                                GROUP BY
                                        organizationid,
                                        orderno       ,
                                        orderLineNo   ,
                                        customerid    ,
                                        warehouseid   ,
                                        SKU           ,
                                        udf03
                        )
                        dod
                ON
                        dod.organizationId  = h2.organizationId
                        AND dod.warehouseId = h2.warehouseId
                        AND dod.sku         = h2.sku
                        AND dod.orderNo     = h2.orderNo
                        AND dod.orderLineNo = h2.orderLineNo
                        AND dod.customerid  = h2.customerid
                WHERE
                        1                     = 1
                        AND h2.organizationId = 'OJV_CML'
                        AND h2.warehouseId   IN('PAPAYA')
                        AND h3.sostatus      >= '40'
                        AND h2.orderNo       IN('PSO202301250152')
                GROUP BY
                        h2.organizationId   ,
                        h2.warehouseId      ,
                        dapd.appointmentNo  ,
                        dapd.udf05          ,
                        lh.ldlNo            ,
                        h3.customerId       ,
                        h2.waveNo           ,
                        h3.soReference1     ,
                        lh.vehicalNo        ,
                        lh.vehicleType      ,
                        lh.carrierName      ,
                        lh.driver           ,
                        h2.dropId           ,
                        h2.pickToTraceId    ,
                        h3.orderNo          ,
                        h2.orderLineNo      ,
                        h3.consigneeId      ,
                        co.customerDescr1   ,
                        co.address1         ,
                        co.city             ,
                        co.zipCode          ,
                        co.province         ,
                        co.contact1         ,
                        co.udf01            ,
                        h2.sku              ,
                        sku.skuDescr1       ,
                        h2.uom              ,
                        bpduom.uomDescr     ,
                        T2.uomDescr         ,
                        la.lotAtt04         ,
                        h3.noteText         ,
                        sku.packId          ,
                        h3.consigneeName    ,
                        h3.consigneeAddress1,
                        dod.udf03
                ORDER BY
                        h2.orderNo    ,
                        h2.orderLineNo,
                        CASE WHEN h2.dropId = '' THEN h2.pickToTraceId ELSE h2.dropId END
        )
        XX
GROUP BY
        ORGANIZATIONID  ,
        CUSTOMERID_WH   ,
        APPNO           ,
        REMARKSCURAH    ,
        LDLNO           ,
        CUSTOMERID_OW   ,
        WAVENO          ,
        SOREFERENCE1    ,
        VEHICLENO       ,
        VEHICLETYPE     ,
        CARRIERNAME     ,
        DRIVER          ,
        ORDERNO         ,
        ORDERLINENO     ,
        CONSIGNEECODE   ,
        CONSIGNEENAME   ,
        CONSIGNEEADDRESS,
        CONSIGNEE_CITY  ,
        CONSIGNEE_ZIP   ,
        CONSIGNEE_STATE ,
        CONSIGNEE_CONT  ,
        STATUS_KOTA     ,
        SKU             ,
        SKUDESCR        ,
        UOM             ,
        EAUOMTEXT       ,
        BATCHNO         ,
        NOTETEXT        ,
        PACKID          ,
        BILADDR1        ,
        ORDERTIME
ORDER BY
        ORDERNO,
        SKU ASC;


  -- SELECT * FROM DOC_ORDER_DETAILS dod WHERE dod.orderNo='PSO202301250152';

