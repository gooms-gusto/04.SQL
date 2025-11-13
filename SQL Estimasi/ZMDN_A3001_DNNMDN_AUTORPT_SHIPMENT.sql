select FORMAT_DATE("%Y-%m-%d",DATE(b.orderTime)) as ORDERDATE,FORMAT_DATE("%Y-%m-%d",DATE(b.lastShipmentTime)) as ACTUALSHIPDATE,
c.sku AS SKU,c.skuDescr1 AS DESCR,
e.lotAtt10 AS SLOC,e.lotAtt11 AS PLANT,
b.orderType AS ORDER_TYPE,b.soReference1 AS EXTERNORDERKEY,CONCAT(j.vehicleNo,'/',j.driver) as TRUCKNO,b.consigneeName AS CONSIGNEE,CAST(a.qty_each as FLOAT64) AS QTY,d.uomDescr AS UOM,a.traceid as PALLET_ID,e.lotAtt02 as EXPIRED,e.lotAtt04 as BATCH,e.lotAtt09 as EXTERNPOKEY,FORMAT_DATE("%Y-%m-%d",DATE(b.addTime)) as RECEIPTDATE

from `linc-bi.wms_cml.ACT_ALLOCATION_DETAILS` a left outer join 
`linc-bi.wms_cml.DOC_ORDER_HEADER` b on a.orderNo=b.orderNo and a.organizationId=b.organizationId and a.warehouseId=b.warehouseId
left outer join `linc-bi.wms_cml.BAS_SKU` c on a.sku=c.sku and a.customerId=c.customerId and a.organizationId=c.organizationId left outer join 
(select organizationId,packid,packuom,uomdescr,qty,customerId  from `linc-bi.wms_cml.BAS_PACKAGE_DETAILS` where packuom='EA' ) d on a.packId=d.packId and a.organizationId=d.organizationId and a.customerId=d.customerId left outer join 
`linc-bi.wms_cml.INV_LOT_ATT` e on a.lotNum=e.lotNum and a.organizationId=e.organizationId left outer join 
`linc-bi.wms_cml.DOC_LOADING_HEADER` f on b.organizationId=f.organizationId and b.warehouseId=f.warehouseId and b.waveNo=f.waveNo
left outer join `linc-bi.wms_cml.DOC_APPOINTMENT_DETAILS` g on f.organizationId=g.organizationId and f.warehouseId=g.warehouseId and f.ldlNo=g.docNo
left outer join `linc-bi.wms_cml.DOC_APPOINTMENT_HEADER` h on g.organizationId=h.organizationId and g.warehouseId=h.warehouseId and g.appointmentNo=h.appointmentNo
left outer join `linc-bi.wms_cml.DOC_ARRIVAL_DETAILS` i on h.organizationId=i.organizationId and h.warehouseId=i.warehouseId and h.appointmentNo=i.appointmentNo
left outer join (select * from `linc-bi.wms_cml.DOC_ARRIVAL_HEADER` where arrivalStatus<>'90') j on i.organizationId=j.organizationId and i.warehouseId=j.warehouseId
and i.arrivalno=j.arrivalNo
where a.warehouseid='KIMSTR' AND a.customerId = 'DNN_MDN' and b.soStatus>='80' and a.status>='80'
and FORMAT_DATE("%Y%m",DATE(b.lastShipmentTime))=FORMAT_DATE("%Y%m",DATETIME_ADD(CURRENT_DATETIME(), INTERVAL 7 HOUR)- interval 1 day)