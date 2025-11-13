select DOH.organizationId,
       DOH.warehouseId,
       DOH.customerId,
       DOH.waveNo,
       DOH.orderNo,
       DOH.soReference1,
       DOH.consigneeId,
       DOH.consigneeName,
       DOH.consigneeAddress1,
       DOH.udf02                                                                      AS MATDOC,
       DOH.orderType,
       DOH.soStatus,
       SYSCODE.codeDescr AS SO_STATUS,
       DLH.ldlNo,
       ARH.arrivalNo,
       AAD.orderLineNo,
       AAD.sku,
       SKU.skuDescr1                                                                  AS SKUDescr,
       AAD.qty,
       AAD.uom,
       AAD.qty_each,
       AAD.pickToTraceId,
       AAD.traceId,
       AAD.dropId,
       AAD.location,
       AAD.pickToLocation,
       AAD.lotNum,
       AAD.cubic,
       AAD.grossWeight,
       AAD.netWeight,
       AAD.pickedWho,
      -- DATE_FORMAT(AAD.pickedTime, '%Y-%m-%d %T')                                     AS pickedTime,
       AAD.checkWho,
       AAD.shipmentWho,
       --DATE_FORMAT(AAD.shipmentTime, '%Y-%m-%d %T')                                   AS shipmentTime,
       CASE WHEN BSM.putawayRule = 'LTL-BULK' THEN 'BULK' ELSE 'PACKAGE' END          AS typeGood,
       ATT.lotAtt01                                                                   AS prodDate,
       ATT.lotAtt02                                                                   AS expDate,
       ATT.lotAtt03                                                                   AS warehouseDate,
       CASE
           WHEN ATT.lotAtt07 = 'R' THEN 'Rental Pallet'
           WHEN ATT.lotAtt07 = 'O' THEN 'Own Pallet'
           END                                                                        AS palletType,
       ATT.lotAtt08                                                                   AS whetherDamaged,
       ATT.lotAtt09                                                                   AS PO,
       ATT.lotAtt04                                                                   AS Batch,
       ATT.lotAtt16                                                                   AS CoaNo,
       CASE WHEN DOH.waveNo = '*' THEN APDS.appointmentNo ELSE APDL.appointmentNo END AS
                                                                                         appointmentNo
      -- ,DATE_FORMAT(PK.openTime, '%Y-%m-%d %T')                                        AS STARTPICKINGTIME,
      -- DATE_FORMAT(PK.closeTime, '%Y-%m-%d %T')                                       AS ENDPICKINGTIME,
      -- DATE_FORMAT(IDX.changeTime, '%Y-%m-%d %T')                                     AS GITIME
from wms_cml.DOC_ORDER_HEADER DOH
         left join wms_cml.ACT_ALLOCATION_DETAILS AAD
                   ON (DOH.organizationId = AAD.organizationId AND
                       DOH.warehouseId = AAD.warehouseId AND
                       DOH.orderNo = AAD.orderNo)
         left join wms_cml.DOC_LOADING_HEADER DLH
                   on (DLH.warehouseId = DOH.warehouseId AND
                       DLH.organizationId = DOH.organizationId AND
                       DLH.waveNo = AAD.waveNo)
         left join wms_cml.DOC_LOADING_DETAILS DLD
                   on (DLD.organizationId = AAD.organizationId AND
                       DLD.warehouseId = AAD.warehouseId AND
                       DLD.orderNo = AAD.orderNo AND
                       DLD.allocationDetailsId = AAD.allocationDetailsId)
         left join wms_cml.INV_LOT_ATT ATT
                   on (ATT.organizationId = DLD.organizationId AND
                       ATT.sku = AAD.sku AND
                       ATT.lotNum = AAD.lotNum)
         left join wms_cml.BAS_SKU SKU
                   on (SKU.organizationId = AAD.organizationId AND
                       SKU.sku = AAD.sku)
         left join wms_cml.BAS_SKU_MULTIWAREHOUSE BSM
                   on (BSM.organizationId = AAD.organizationId AND
                       BSM.warehouseId = AAD.warehouseId AND
                       BSM.SKU = AAD.sku)
         left join wms_cml.DOC_APPOINTMENT_DETAILS APDL
                   ON
                               DOH.organizationId = APDL.organizationId
                           AND DOH.warehouseId = APDL.warehouseId
                           AND DLH.ldlNo = APDL.docNo
                           AND APDL.docType = 'LOAD'
         left join wms_cml.DOC_APPOINTMENT_DETAILS APDS
                   ON
                               DOH.organizationId = APDS.organizationId
                           AND DOH.warehouseId = APDS.warehouseId
                           AND DOH.orderNo = APDS.docNo
                           AND APDS.docType = 'SO'
         left join wms_cml.DOC_ARRIVAL_DETAILS ARD
                   ON ARD.warehouseId = DOH.warehouseId and
                      ARD.organizationId = DOH.organizationId and
                      ARD.appointmentno = (
                          CASE WHEN DOH.waveNo = '*' THEN APDS.appointmentNo ELSE APDL.appointmentNo END
                          )
         inner join wms_cml.DOC_ARRIVAL_HEADER ARH ON
            ARH.warehouseId = ARD.warehouseId and
            ARH.organizationId = ARD.organizationId and
            ARH.arrivalno = ARD.arrivalno and
            ARH.arrivalStatus <> '90'
         left join wms_cml.TSK_TASKLISTS PK on
            PK.organizationId = AAD.organizationId AND
            PK.warehouseId = AAD.warehouseId AND
            PK.docNo = AAD.orderNo AND
            PK.fmId = AAD.traceId
        AND PK.planToId = AAD.dropId
         left join wms_cml.IDX_ORDERSTATUS_LOG IDX ON
            IDX.organizationId = DOH.organizationId AND
            IDX.warehouseId = DOH.warehouseId AND
            IDX.orderNo = DOH.orderNo AND
            IDX.orderStatus = '99'
left join wms_cml.BSM_CODE_ML SYSCODE ON
SYSCODE.codeid=DOH.soStatus AND SYSCODE.codeType='SO_STS' and SYSCODE.languageId='en'
WHERE DOH.organizationId = 'OJV_CML'
  AND DOH.warehouseId = 'CBT01'
  AND DOH.orderNo = 'SO21080400004'
  AND DLH.ldlStatus = '99'