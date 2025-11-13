use wh5;
select alt1.sku,alt1.ean1,alt2.ean2 from (

SELECT sku,max(altsku) as ean1  FROM LincDataProd.wh5.altsku where sku in (
    select sku from LincDataProd.wh5.sku where  cwflag is null and susr6='0170'
    )
group by sku) alt1 left outer join
    (
    SELECT top 2 sku,altsku as ean2  FROM LincDataProd.wh5.altsku where sku in (
    select sku from LincDataProd.wh5.sku where  cwflag is null and susr6='0170'
    )
group by sku) alt2
on alt1.sku=alt2.sku and alt2.ean2 <> alt1.ean1;

create view alt1sku as
SELECT sku,max(altsku) as ean1  FROM LincDataProd.wh5.altsku where sku in (
    select sku from LincDataProd.wh5.sku where  cwflag is null and susr6='0170'
    )
group by sku

drop view alt2sku;

select * from alt4sku;

create view alt5sku as
SELECT ori.sku,max(ori.altsku) as ean5  FROM LincDataProd.wh5.altsku ori where ori.sku in (
    select sku from LincDataProd.wh5.sku where  cwflag is null and susr6='0170'
    )
and altsku not in (select ean1 from alt1sku where sku =ori.sku)
and altsku not in (select ean2 from alt2sku where sku =ori.sku)
and altsku not in (select ean3 from alt3sku where sku =ori.sku)
and altsku not in (select ean4 from alt4sku where sku =ori.sku)
--and altsku not in (select ean5 from alt5sku where sku =ori.sku)
group by ori.sku


select alt1.sku,alt1.ean1,alt2.ean2,alt3.ean3,alt4.ean4,alt5.ean5
from alt1sku alt1 left outer join
    alt2sku alt2 on(alt1.sku=alt2.sku)
left outer join alt3sku alt3 on (alt1.sku=alt3.sku)
left outer join alt4sku alt4 on (alt1.sku=alt4.sku)
left outer join alt5sku alt5 on (alt1.sku=alt5.sku)
where alt1.sku='SLRGT4041003NAV000'

select * from LincDataProd.wh5.altsku where sku='ACR34A00901200B77#'
