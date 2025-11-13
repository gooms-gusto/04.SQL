SELECT
  flux_data.opportunityid,
  flux_data.warehouseid,
  flux_data.ratebase,
  flux_data.product,
  flux_data.directrate,
  flux_data.qty,
  flux_data.transaction_date,
  flux_data.type,
  flux_data.qtyIp,
  flux_data.qtyCs,
  flux_data.qtyPl,
  flux_data.billingamount,
  flux_data.chargerate,
  flux_data.created_at,
  flux_data.datas,
  flux_data.datas_response
FROM flux_data
WHERE DATE_FORMAT(flux_data.created_at, '%Y-%m-%d') = DATE_FORMAT(CURDATE(), '%Y-%m-%d')
AND flux_data.type = 'uninvoiced'