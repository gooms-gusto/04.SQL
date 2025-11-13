SELECT
  oh.customer_code,
  fd.flux_data_id,
  fd.transaction_date,
  fd.warehouseid,
  fd.ratebase,
  fd.product,
  fd.directrate,
  fd.qty,
  fd.qtyIp,
  fd.qtyCs,
  fd.qtyPl,
  fd.billingamount,
  fd.interface_status,
  fd.created_at,
  fd.datas,
  fd.datas_response
FROM flux_data fd
INNER JOIN opportunity_header oh ON fd.opportunityid=oh.opportunity_sf_id 
--  INNER JOIN BAS_CUSTOMER bc ON bc.udf02=oh.customer_code AND bc.customerType='OW'
WHERE fd.datas_response LIKE '%400%'
AND DATE(fd.created_at) = DATE(ADDDATE(NOW(), -7));


-- SELECT * FROM BAS_CUSTOMER bc WHERE bc.udf02='3000007550' AND bc.customerType='OW'