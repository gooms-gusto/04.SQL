SELECT 
warehouseid,salesarea,
CASE WHEN MAX(divcode) IS NULL THEN '62' ELSE MAX(divcode) END  AS divcode,
sapcustomerid,
sum(billingamount) AS billingamount,YEAR(NOW()) AS YearPeriod, MONTH(NOW()) AS MonthPeriod
FROM ZV_BILLING_DATA
WHERE (DATE_FORMAT(DATE(billingfromdate),'%Y-%m-%d') >= getBillFMDate(26)
 AND DATE_FORMAT(DATE(billingfromdate),'%Y-%m-%d') <=  getBillTODate(26)) AND chargecategory <> 'IV'
  AND sapcustomerid NOT IN('3000000733','3000000735','3000016576','3000005193') AND (sapcustomerid NOT IN('8000000010') AND warehouseid NOT IN ('SBYMM'))
GROUP BY 
warehouseid,salesarea,sapcustomerid;