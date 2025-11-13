SELECT
        lh.ORGANIZATIONID                                                 AS ORGANIZATIONID,
        lh.WAREHOUSEID                                                    AS CUSTOMERID_WH ,
        lh.LDLNO                                                          AS LDLNO         ,
        h2.waveNo                                                         AS WAVENO        ,
        h3.customerId                                                     AS CUSTOMERID_OW ,
        h3.soReference1                                                   AS SOREFERENCE1  ,
        lh.vehicalNo                                                      AS VEHICLENO     ,
        lh.vehicleType                                                    AS VEHICLETYPE   ,
        lh.carrierName                                                    AS CARRIERNAME   ,
        lh.driver                                                         AS DRIVER        ,
        CASE WHEN h2.dropId = '' THEN h2.pickToTraceId ELSE h2.dropId END AS TRACEID       ,
        h3.OrderNo                                                        AS ORDERNO       ,
        h3.CONSIGNEENAME                                                  AS CONSIGNEENAME ,
        h2.sku                                                            AS SKU           ,
        sku.skuDescr1                                                     AS SKUDESCR      ,
        SUM(h2.qty)                                                       AS QTY_TOTAL     ,
        h2.uom                                                            AS UOM           ,
        SUM(h2.qty_each)                                                  AS PICKQTYEA     ,
        T2.uomDescr                                                       AS EAUOMTEXT     ,
        SUM(h2.qty * sku.grossWeight)                                     AS WEIGHT_TOTAL  ,
        SUM(h2.qty * sku.cube)                                            AS CUBIC_TOTAL   ,
        la.lotAtt04                                                       AS BATCHNO       ,
        DATE_FORMAT(la.lotAtt02, '%d-%M-%Y')                              AS EXPIRED       ,
        la.lotAtt15                                                       AS IDPALLET      ,
        h3.noteText                                                       AS NOTETEXT      ,
        sku.packId                                                        AS PACKID        ,
        bcm.codedescr                                                     AS WHETHERDAMAGED
FROM
        DOC_LOADING_HEADER lh
INNER JOIN DOC_WAVE_HEADER wh
ON
        lh.organizationId  = wh.organizationId
        AND lh.warehouseId = wh.warehouseId
        AND lh.waveNo      = wh.waveNo
LEFT JOIN ACT_ALLOCATION_DETAILS h2
ON
        lh.organizationId  = h2.organizationId
        AND lh.warehouseId = h2.warehouseId
        AND lh.waveNo      = h2.waveNo
INNER JOIN DOC_ORDER_HEADER h3
ON
        h2.organizationId  = h3.organizationId
        AND h2.warehouseId = h3.warehouseId
        AND h2.orderNo     = h3.orderNo
INNER JOIN BAS_SKU sku
ON
        sku.organizationId = h2.organizationId
        AND sku.sku        = h2.sku
        AND sku.customerId = h2.customerId
INNER JOIN INV_LOT_ATT la
ON
        h2.organizationId = la.organizationId
        AND h2.lotNum     = la.lotNum
        AND h2.customerId = la.customerId
        AND la.sku        = h2.sku
LEFT JOIN
        (
                
                SELECT * FROM BSM_CODE_ML bcm WHERE codeType = 'DMG_FLG' AND languageId = 'en'
        )
        bcm
ON
        la.organizationId = bcm.organizationId
        AND la.lotAtt08   = bcm.codeid
LEFT JOIN BAS_PACKAGE_DETAILS T2
ON
        h2.organizationId = T2.organizationId
        AND T2.packUom    = 'EA'
        AND h2.packId     = T2.packId
        AND h2.customerId = T2.customerId
WHERE
        1                                   = 1
      --  AND lh.organizationId               = '@{bizOrgId}'
        AND lh.warehouseId                  =('CBT02')
        AND CONVERT(wh.waveStatus, signed) >= 60
        AND lh.LDLNO                        = 'LDL22012012'
    --    AND h2.waveNo                      IN('${CHECK.waveNo}')
GROUP BY
        lh.vehicalNo     ,
        lh.driver        ,
        lh.vehicleType   ,
        lh.carrierName   ,
        h2.PickToTraceID ,
        h3.orderNo       ,
        h3.consigneeName ,
        h2.traceId       ,
        h2.dropId        ,
        lh.organizationId,
        lh.warehouseId   ,
        lh.ldlNo         ,
        h2.sku           ,
        sku.skuDescr1    ,
        h2.uom           ,
        la.lotAtt04      ,
        la.lotAtt15      ,
        lh.noteText      ,
        T2.uomDescr      ,
        sku.packId       ,
        bcm.codedescr    ,
        DATE_FORMAT(la.lotAtt02, '%d-%M-%Y')
ORDER BY  h2.sku,la.lotAtt04
--         h2.orderNo,
--         CASE WHEN h2.dropId = '' THEN h2.pickToTraceId ELSE h2.dropId END