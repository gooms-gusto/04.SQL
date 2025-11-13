USE wms_cml;

select *
from wms_cml.IDX_ORDERSTATUS_LOG 
where warehouseId = 'CBT01' AND orderNo='P000056299' AND date(addTime) = '2023-02-09' AND editTime IS  null
order by editTime desc
limit 100;


select DISTINCT(warehouseId)
from wms_cml.IDX_ORDERSTATUS_LOG 
where  date(addTime) = '2023-02-08' AND editTime IS null
-- order by editTime desc
-- limit 100;