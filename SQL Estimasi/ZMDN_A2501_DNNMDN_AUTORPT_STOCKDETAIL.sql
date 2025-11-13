select illi.customerId as STORER,
bs.sku AS SKU,bs.skuDescr1 AS DESCR,
ila.lotAtt10 AS SLOC,ila.lotAtt11 AS PLANT,
ila.lotAtt16 as LOTTABLE03,
bs.packId AS PACKKEY,
illi.locationId as LOC,
illi.traceId AS PALLET_ID,
ila.lotAtt02 as EXPIRED,
ila.lotAtt03 as RECEIPTDATE,
case ila.lotAtt08 when 'N' then 'OK' when 'Y' then 'HOLD' else ila.lotAtt08 end as STATUS,
DATE_DIFF(DATETIME_ADD(CURRENT_DATETIME(), INTERVAL 7 HOUR), DATE(ila.lotAtt03), DAY) as AGING,
CAST(illi.qty as FLOAT64) AS QTY,bpd.uomDescr AS UOM
,CAST(illi.qty/(case when a.qty=0 then 1 else a.qty end) as FLOAT64) as QTYCASE
,a.uomDescr as UOMCASE
,ila.lotAtt04 as BATCH
,ila.lotAtt09 as EXTPO
from `linc-bi.wms_cml.INV_LOT_LOC_ID` illi left outer join 
`linc-bi.wms_cml.BAS_SKU` bs on illi.customerId =bs.customerId and illi.sku =bs.sku and illi.organizationId = bs.organizationId left outer join 
`linc-bi.wms_cml.INV_LOT_ATT` ila on illi.lotNum =ila.lotNum and ila.organizationId = bs.organizationId left outer join 
(select organizationId,packid,packuom,uomdescr,qty,customerId from `linc-bi.wms_cml.BAS_PACKAGE_DETAILS` where packuom='EA' ) bpd on bs.packId=bpd.packId and bpd.organizationId=bs.organizationId and bs.customerId=bpd.customerId left outer join 
(select organizationId,packid,packuom,uomdescr,qty,customerId from `linc-bi.wms_cml.BAS_PACKAGE_DETAILS` where packuom='CS') a on bs.packId=a.packId and a.organizationId=bs.organizationId and bs.customerId=a.customerId
where illi.warehouseId='KIMSTR' AND illi.customerId = 'DNN_MDN' and bpd.packUom ='EA' and a.packuom='CS' and illi.qty >0