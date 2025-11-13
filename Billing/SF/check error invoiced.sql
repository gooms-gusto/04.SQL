-- SELECT * FROM flux_data fd WHERE fd.datas_response NOT LIKE '%200%' AND type='invoiced';
-- SELECT DISTINCT(fd.opportunityid) FROM flux_data fd WHERE fd.datas_response NOT LIKE '%200%' AND type='invoiced';

SELECT date(NOW());
-- successfully invoiced to SF
SELECT DISTINCT(fd.opportunityid), bc.customerId
FROM flux_data fd  INNER JOIN opportunity_header oh ON fd.opportunityid= oh.opportunity_sf_id 
INNER JOIN BAS_CUSTOMER bc ON oh.customer_code=bc.udf02
WHERE fd.datas_response  LIKE '%200%' AND type='invoiced' AND date(fd.created_at) BETWEEN '11/26/2023' AND date(NOW())
AND fd.opportunityid NOT IN
(
SELECT DISTINCT(fd.opportunityid) FROM flux_data fd WHERE fd.datas_response NOT LIKE '%200%' AND type='invoiced'
);

-- failed 

SELECT DISTINCT(fd.opportunityid) ,fd.datas_response
FROM flux_data fd 
WHERE fd.datas_response  NOT LIKE '%200%' AND type='invoiced'
-- AND fd.opportunityid NOT IN
-- (
-- SELECT DISTINCT(fd.opportunityid) FROM flux_data fd WHERE fd.datas_response  LIKE '%200%' AND type='invoiced'
-- );