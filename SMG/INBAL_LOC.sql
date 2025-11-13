select  a.sku,  a.loc,e.PUTAWAYZONE, a.id as pallet_id, convert(varchar(10),d.lottable04, 120) as whdate,convert(varchar(10),d.lottable05, 120) as expdate, a.qty-a.qtyallocated-a.qtypicked as qtyavailable,a.qty,
d.lottable02, case when a.status='OK'  then 'N' else 'Y' end as goodstatus, a.lot
from lotxlocxid a,  sku b, pack c, lotattribute d,loc e
where a.storerkey = b.storerkey and a.sku = b.sku and b.packkey = c.packkey and a.storerkey = d.storerkey and a.sku = d.sku and a.lot = d.lot and
b.storerkey = d.storerkey and b.sku = d.sku and a.qty > 0  and e.loc=a.loc and
a.storerkey = 'NLDC'
order by a.loc;

select * from LOC;


select distinct PUTAWAYZONE from LOC;