



select ''+char(39)+loc +char(39)+ ',' from LincDataProd.wh5.lotxlocxid where storerkey='MAP' AND QTY>0 AND loc <> 'PICKTO';

select *  from LincDataProd.wh5.sku where sku in (
    select DISTINCT SKU from LincDataProd.wh5.lotxlocxid where storerkey='MAP' AND QTY>0 AND loc <> 'PICKTO'
    )


SELECT * FROM LincDataProd.wh5.STORER WHERE STORERKEY='MAP';



select  a.sku,  a.loc, a.id as pallet_id, convert(varchar(10),d.lottable04, 120) as whdate, a.qty-a.qtyallocated-a.qtypicked as qtyavailable,a.qty,
d.lottable02, case when a.status='OK'  then 'N' else 'Y' end as goodstatus, a.lot
from lotxlocxid a,  sku b, pack c, lotattribute d
where a.storerkey = b.storerkey and a.sku = b.sku and b.packkey = c.packkey and a.storerkey = d.storerkey and a.sku = d.sku and a.lot = d.lot and
b.storerkey = d.storerkey and b.sku = d.sku and a.qty > 0  and
a.storerkey = 'NLDC'
order by a.loc;


select * from wh5.lotxlocxid where 1=2




