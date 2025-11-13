select 
bs.sku AS SKU,bs.skuDescr1 AS DESCR,
ila.lotAtt10 AS SLOC,ila.lotAtt11 AS PLANT,
bs.packId AS PACKKEY,CAST(sum(illi.qty) as FLOAT64) as QTYONHAND,bpd.uomDescr as UOM_ONHAND,
CAST(sum(illi.qty)/(case when a.qty=0 then 1 else a.qty end) as FLOAT64) as QTYONHAND_CASE,a.uomDescr as UOM_ONHAND_CASE,
CAST(sum(CASE when ila.lotAtt08='Y' and illi.qtyAllocated=0 THEN 0 ELSE illi.qty END) - sum(illi.qtyAllocated) as FLOAT64) as QTYAVAILABLE,bpd.uomDescr as UOM_AVAILABLE,
CAST((sum(CASE when ila.lotAtt08='Y' and illi.qtyAllocated=0 THEN 0 ELSE illi.qty END)-sum(illi.qtyAllocated))/(case when a.qty=0 then 1 else a.qty end) as FLOAT64) as QTYAVAILABLE_CASE,a.uomDescr as UOM_AVAILABLE_CASE,
CAST(sum(CASE when ila.lotAtt08='Y' THEN illi.qty ELSE 0 END) as FLOAT64) as QTYONHOLD,
bpd.uomDescr as UOM_HOLD,
CAST(sum(CASE when ila.lotAtt08='Y' THEN illi.qty ELSE 0 END)/(case when a.qty=0 then 1 else a.qty end) as FLOAT64) as QTYONHOLD_CASE,a.uomDescr as UOM_ONHOLD_CASE,
CAST(sum(illi.qtyAllocated ) as FLOAT64) as QTYALLOCATED,
bpd.uomDescr as UOM_ALLOCATED,
CAST(case when sum(illi.qtyAllocated )=0 then 0 else sum(illi.qtyAllocated )/(case when a.qty=0 then 1 else a.qty end) end as FLOAT64) as QTYALLOCATED_CASE,a.uomDescr as UOM_ALLOCATED_CASE,
0 as QTYPICK,bpd.uomDescr as UOM_PICK,
0 as QTYPICK_CASE,bpd.uomDescr as UOM_PICK_CASE,
0 as QTYOUT,bpd.uomDescr as UOM_OUT
,0 as QTYOUT_CASE,bpd.uomDescr as UOM_OUT_CASE

from `linc-bi.wms_cml.INV_LOT` il left outer join 
`linc-bi.wms_cml.BAS_SKU` bs on il.customerId =bs.customerId and il.sku =bs.sku and il.organizationId=bs.organizationId left outer join 
`linc-bi.wms_cml.INV_LOT_ATT` ila on il.lotNum =ila.lotNum and ila.organizationId=bs.organizationId left outer join 
`linc-bi.wms_cml.INV_LOT_LOC_ID` illi on il.lotNum = illi.lotNum and illi.organizationId=bs.organizationId  left outer join 
(select organizationId,packid,packuom,uomdescr,qty,customerId  from `linc-bi.wms_cml.BAS_PACKAGE_DETAILS` where packuom='EA' ) bpd on bs.packId=bpd.packId and bpd.organizationId=bs.organizationId and bs.customerId=bpd.customerId  left outer join 
(select organizationId,packid,packuom,uomdescr,qty,customerId  from `linc-bi.wms_cml.BAS_PACKAGE_DETAILS` where packuom='CS' ) a on bs.packId=a.packId and a.organizationId=bs.organizationId and bs.customerId=a.customerId

where il.warehouseId='KIMSTR' AND il.customerId = 'DNN_MDN'  and bpd.packUom ='EA' and a.packuom='CS' and illi.qty>0
group by il.sku,bs.sku,bs.skuDescr1,ila.lotAtt06,bs.packId,bpd.uomDescr,a.qty,a.uomDescr,ila.lotAtt10,bs.skuDescr2,bs.sku_group1,bs.sku_group2,ila.lotAtt10 ,ila.lotAtt11
order by bs.sku