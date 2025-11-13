SELECT DISTINCT
        doh.organizationId             ,
        doh.warehouseId AS WAREHOUSE_ID,
        --   ddd.deliveryConfirmNo,
        doh.customerId                                                                 AS CUSTOMER_CODE ,
        dlh.ldlNo                                                                      AS LOADING_NUMBER,
        doh.waveNo                                                                     AS WAVE_NUMBER   ,
        doh.orderNo                                                                    AS ORDERNO       ,
        doh.soReference1                                                               AS SO_MAP        ,
        ald.totqtyship                                                                 AS TOTALQTYSHIPEA,
        odd.totqtyorder                                                                AS TOTALORDER    ,
        odd.totalqtyCS AS TOTALORDERCS,
        ald.tothu                                                                      AS TOTALHU       ,
        odd.totcbm                                                                     AS TOTALCBM      ,
        odd.totsku                                                                     AS TOTALSKU      ,
        CASE WHEN doh.waveNo = '*' THEN apds.appointmentNo ELSE apdl.appointmentNo END AS
        APPOINTMENT_NUMBER                    ,
        arh.arrivalNo                                                                         AS ARRIVAL_NO   ,
        doh.consigneeId                                                                       AS STORECODE    ,
        doh.consigneeName                                                                     AS STORE_NAME   ,
        doh.consigneeAddress1                                                                 AS STORE_ADDRESS,
        CASE WHEN co.udf01 = 'DK' THEN 'Dalam Kota' WHEN co.udf01 = 'LK' THEN 'Luar Kota' END AS
        AREA                          ,
        doh.orderType   AS DO_TYPE    ,
        c2.soTypeName   AS SO_TYPE    ,
        doh.soStatus    AS SO_STATUS  ,
        c1.soStatusName AS STATUS_NAME,
        -- doh.releaseStatus,
        -- arh.appointmentNo,  --   doh.carrierId, doh.carrierName,
        --   CASE WHEN doh.waveNo = '*' THEN apds.udf02 ELSE apdl.udf02 END AS tkbm,
        --   CASE WHEN doh.waveNo = '*' THEN apds.udf03 ELSE apdl.udf03 END AS typeTkbm,
        --   CASE WHEN doh.waveNo = '*' THEN apds.udf04 ELSE apdl.udf04 END AS qtyTkbm,
        arh.carrierId AS EXPEDITION_ID,
        ca.carrierId                                                                AS EXPEDITION_NAME,
        arh.dockNo                                                           AS DOCK_NUMBER    ,
        arh.vehicleType                                                      AS TRUCK_TYPE     ,
        arh.vehicleNo                                                        AS TRUCK_NUMBER   ,
        arh.driver                                                           AS DRIVER         ,
        CASE WHEN sm.putawayRule = 'LTL-BULK' THEN 'BULK' ELSE 'PACKAGE' END AS TYPEGOOD       ,
        DATE_FORMAT(doh.addTime, '%Y-%m-%d %T')                              AS ADD_TIME_SO    ,
        DATE_FORMAT(doh.orderTime, '%Y-%m-%d %T')                            AS ORDERTIME      ,
        DATE_FORMAT(doh.expectedShipmentTime1, '%Y-%m-%d %T')                AS
        EXPECTEDSHIPMENTTIME                                        ,
        DATE_FORMAT(arh.arriveTime, '%Y-%m-%d %T')   AS ARRIVETIME  ,
        DATE_FORMAT(arh.entranceTime, '%Y-%m-%d %T') AS ENTRANCETIME,
        DATE_FORMAT(p1.openTime, '%Y-%m-%d %T')      AS STARTPICKING,
        DATE_FORMAT(p2.closeTime, '%Y-%m-%d %T')     AS ENDPICKING  ,
        -- DATE_FORMAT(arh.dockAssignmentTime, '%Y-%m-%d %T') AS dockAssignmentTime,
        DATE_FORMAT(dlh.loadingFromTime, '%Y-%m-%d %T')  AS START_LOADING,
        DATE_FORMAT(dlh.loadingToTime, '%Y-%m-%d %T')    AS END_LOADING  ,
        DATE_FORMAT(OSC.changeTime, '%Y-%m-%d %T') AS GI_TIME      ,
        DATE_FORMAT(arh.leaveTime, '%Y-%m-%d %T')  AS LEAVE_TIME_TRUCK
FROM
        DOC_ORDER_HEADER doh
INNER JOIN DOC_ORDER_DETAILS dod
ON
        doh.organizationId  = dod.organizationId
        AND doh.warehouseId = dod.warehouseId
        AND doh.orderNo     = dod.orderNo
LEFT OUTER JOIN
        (
                
                SELECT
                        organizationId                        ,
                        orderNo                               ,
                        COUNT(DISTINCT pickToTraceId) AS totHU,
                        SUM(qtyShipped_each)          AS totqtyship
                FROM
                        ACT_ALLOCATION_DETAILS
                WHERE
                        customerId = 'MAP'
                GROUP BY
                        orderNo,
                        organizationId
        )
        ald
ON
        (
                ald.organizationId = dod.organizationId
                AND ald.orderNo    = dod.orderNo
        )
LEFT OUTER JOIN
        (
                
                SELECT
                        dod.organizationId                                     ,
                        dod.orderNo                                            ,
                        ROUND(SUM(dod.qtyOrdered * sku.cube), 2) AS totcbm     ,
                        SUM(dod.qtyOrdered/bpd.qty) AS totalqtyCS,
                        SUM(dod.qtyOrdered)                      AS totqtyorder,
                        COUNT(DISTINCT dod.sku)                  AS totsku
                FROM
                        DOC_ORDER_DETAILS dod
                INNER JOIN BAS_SKU sku
                ON
                        (
                                dod.organizationId = sku.organizationId
                                AND dod.customerId = sku.customerId
                                AND dod.sku        = sku.sku
                        )
                LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpd ON
                  bpd.organizationId=sku.organizationId
                  AND bpd.packId=sku.packId
                  AND bpd.packUom='CS'

                WHERE
                        dod .customerId = 'MAP'
                GROUP BY
                        dod .orderNo,
                        dod.organizationId
        )
        odd ON
        (
                odd.organizationId = dod.organizationId
                AND odd.orderNo    = dod.orderNo
        )
INNER JOIN BAS_SKU_MULTIWAREHOUSE sm
ON
        sm.organizationId = dod.organizationId
        AND sm.customerId = dod.customerId
        AND sm.sku        = dod.sku
LEFT JOIN DOC_LOADING_HEADER dlh
ON
        doh.organizationId  = dlh.organizationId
        AND doh.warehouseId = dlh.warehouseId
        AND doh.waveNo      = dlh.waveNo
LEFT OUTER JOIN
        (
                
                SELECT * FROM BAS_CUSTOMER WHERE customerType = 'CO'
        )
        co
ON
        co.organizationId = doh.organizationId
        AND co.customerId = doh.consigneeId
LEFT JOIN DOC_APPOINTMENT_DETAILS apdl
ON
        doh.organizationId  = apdl.organizationId
        AND doh.warehouseId = apdl.warehouseId
        AND dlh.ldlNo       = apdl.docNo
        AND apdl.docType    = 'LOAD'
LEFT JOIN DOC_APPOINTMENT_DETAILS apds
ON
        doh.organizationId  = apds.organizationId
        AND doh.warehouseId = apds.warehouseId
        AND doh.orderNo     = apds.docNo
        AND apds.docType    = 'SO'
LEFT JOIN DOC_ARRIVAL_DETAILS ard
ON
        doh.organizationId  = ard.organizationId
        AND doh.warehouseId = ard.warehouseId
        AND
        (
                CASE WHEN doh.waveNo = '*' THEN apds.appointmentNo ELSE apdl.appointmentNo END
        )
        = ard.appointmentNo
LEFT JOIN DOC_ARRIVAL_HEADER arh
ON
        ard.organizationId  = arh.organizationId
        AND ard.warehouseId = arh.warehouseId
        AND arh.arrivalNo   = ard.arrivalNo
LEFT JOIN
        (
                
                SELECT DISTINCT
                        organizationId,
                        warehouseId   ,
                        docNo         ,
                        MIN(openTime) AS openTime -- , closeWho, closeTime
                FROM
                        TSK_TASKLISTS
                WHERE
                        taskType = 'PK' -- AND docNo='SO20083100029'
                GROUP BY
                        organizationId,
                        warehouseId   ,
                        docNo
        )
        p1
ON
        p1.organizationId  = doh.organizationId
        AND p1.warehouseId = doh.warehouseId
        AND p1.docNo       = doh.orderNo
LEFT JOIN
        (
                
                SELECT DISTINCT
                        organizationId,
                        warehouseId   ,
                        docNo         ,
                        MIN(closeTime) AS closeTime -- , closeWho, closeTime
                FROM
                        TSK_TASKLISTS
                WHERE
                        taskType = 'PK' -- AND docNo='SO20083100029'
                GROUP BY
                        organizationId,
                        warehouseId   ,
                        docNo
        )
        p2
ON
        p2.organizationId  = doh.organizationId
        AND p2.warehouseId = doh.warehouseId
        AND p2.docNo       = doh.orderNo
LEFT JOIN
        (
                
                SELECT
                        organizationId,
                        warehouseId   ,
                        orderNo       ,
                        changeTime
                FROM
                        IDX_ORDERSTATUS_LOG
                WHERE
                        orderStatus = '99'
        )
        OSC
ON
        OSC.organizationId  = doh.organizationId
        AND OSC.warehouseId = doh.warehouseId
        AND OSC.orderNo     = doh.orderNo
INNER JOIN
        (
                
                SELECT
                        codeId,
                        codeDescr AS soStatusName
                FROM
                        BSM_CODE_ML
                WHERE
                        codeType       = 'SO_STS'
                        AND languageId = 'en'
        )
        c1
ON
        c1.codeId = doh.soStatus
INNER JOIN
        (
                
                SELECT
                        codeId,
                        codeDescr AS soTypeName
                FROM
                        BSM_CODE_ML
                WHERE
                        codeType       = 'SO_TYP'
                        AND languageId = 'en'
        )
        c2
ON
        c2.codeId = doh.orderType
  LEFT OUTER JOIN
        (
                
                SELECT organizationId,customerId,customerDescr1 AS carrierId FROM BAS_CUSTOMER WHERE customerType = 'CA' LIMIT 1
        )
        ca
ON
  ca.organizationId=arh.organizationId AND
  ca.customerId = arh.carrierId
WHERE
        1                                 = 1
--         AND doh.organizationId            = '@{bizOrgId}'
        AND doh.warehouseId               = 'CBT01'
        AND doh.soStatus             IN('99')
         AND doh.customerId               IN('MAP')
--         AND doh.carrierId                 = '${carrierId}'
--         AND doh.orderNo                  IN('${orderNo}')
--         AND doh.soReference1             IN('${soReference1}')
--         AND doh.waveNo                   IN('${waveNo}')
--         AND CONVERT(doh.orderTime, DATE) >= '${orderTimeFM}'
--         AND CONVERT(doh.orderTime, DATE) <= '${orderTimeTO}'
--         AND CONVERT(doh.addTime,   DATE) >= '${addTimeFM}'
--         AND CONVERT(doh.addTime,   DATE) <= '${addTimeTO}'
--         AND sm.putawayRule                =('${typeGood}')
--         AND doh.orderType                 = '${orderType}'
--         AND arh.arrivalNo                 = '${arrivalNo}'
--         AND arh.vehicleNo                 = '${vehicleNo}'
--         AND co.udf01                      = '${area}'
--         AND
--         CASE WHEN doh.waveNo = '*' THEN apds.appointmentNo ELSE apdl.appointmentNo END =
--         '${appointmentNo}'
ORDER BY
        orderNo; -- soStatus, orderTime;



--   SELECT * FROM WMS_FTEST.DOC_LOADING_HEADER WHERE waveNo='W220126001' AND warehouseId='CBT01';
-- 
-- 
--   SELECT * FROM DOC_LOADING_DETAILS dld WHERE dld.ldlNo='LDL2201260003';

