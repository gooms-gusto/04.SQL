select d.poReference1  as EXTERNPOKEY,b.poNo as POKEY,e.codeDescr as POTYPE,k.vehicleno as TRUCKNO,
f.sku AS SKU,f.skuDescr1 AS DESCR,
c.lotAtt10 AS SLOC,c.lotAtt11 AS PLANT,
c.lotAtt16  as LOTTABLE03
,FORMAT_DATE("%Y-%m-%d",DATE(a.transactionTime)) as DATERECEIVED
,a.toQty_Each as QTYIN,g.uomDescr AS UOM,a.toLocation AS LOCATION,a.toId AS PALLET_ID,
c.lotAtt02 as EXPIRED,
case c.lotAtt08 when 'N' then 'OK' when 'Y' then 'HOLD' else c.lotAtt08 end as STATUS
,c.lotAtt04 as BATCH
,'' as CONT_NO,k.Driver as DRIVER_NAME
from `linc-bi.wms_cml.ACT_TRANSACTION_LOG` a left outer join 
`linc-bi.wms_cml.DOC_ASN_HEADER` b on a.docNo=b.asnNo and a.warehouseId=b.warehouseId and a.organizationId=b.organizationId left outer join 
`linc-bi.wms_cml.INV_LOT_ATT` c on a.toLotNum=c.lotNum and b.warehouseId=a.warehouseId and b.organizationId=c.organizationId left outer join 
`linc-bi.wms_cml.DOC_PO_HEADER` d on b.poNo=d.poNo and c.organizationId =d.organizationId and b.warehouseId=d.warehouseId left outer join 
(select * from `linc-bi.wms_cml.BSM_CODE_ML` where codeType ='ASN_TYP' and languageId ='en') e on b.asnType=e.codeId and d.organizationId =e.organizationId left outer join 
`linc-bi.wms_cml.BAS_SKU` f on a.fmCustomerId =f.customerId and a.toSku=f.sku and e.organizationId=f.organizationId  left outer join 
(select organizationId,packid,packuom,uomdescr,customerid from `linc-bi.wms_cml.BAS_PACKAGE_DETAILS` where packuom='EA') g on f.PackId=g.packId and f.organizationId=g.organizationId and f.customerId=g.customerid left outer join 
`linc-bi.wms_cml.DOC_APPOINTMENT_DETAILS` h on a.docNo=h.docNo and a.warehouseId=h.warehouseId and a.organizationId=h.organizationId left outer join 
`linc-bi.wms_cml.DOC_APPOINTMENT_HEADER` i on h.organizationId=i.organizationId and h.warehouseId=i.warehouseId and h.appointmentNo=i.appointmentNo
left outer join `linc-bi.wms_cml.DOC_ARRIVAL_DETAILS` j on i.organizationId=j.organizationId and i.warehouseId=j.warehouseId and i.appointmentNo=j.appointmentno
left outer join (select * from `linc-bi.wms_cml.DOC_ARRIVAL_HEADER` where arrivalStatus<>'90') k on j.organizationId=k.organizationId and j.warehouseId=k.warehouseId and j.arrivalno=k.arrivalNo
where a.warehouseid='KIMSTR' and a.transactionType ='IN' and a.status='99'
and a.fmCustomerId = 'DNN_MDN' and a.toQty_Each>0 
and FORMAT_DATE("%Y%m",DATE(a.transactionTime))=FORMAT_DATE("%Y%m",DATETIME_ADD(CURRENT_DATETIME(), INTERVAL 7 HOUR)- interval 1 day)