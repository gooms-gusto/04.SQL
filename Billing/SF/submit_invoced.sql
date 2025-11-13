USE wms_cml;

SELECT -- *
  MAX(date(transmit_date)) AS TransmitDate,
  MAX(OpportunityId) AS OpportunityId,
  MAX(warehouseId) AS warehouseId, 
  MAX(rateBase) AS rateBase,
  MAX(sapmaterialid) AS sapmaterialid,  
  MAX(directRate) AS directRate,
  SUM(qty) AS qty,
  SUM(CEIL(qtyIp)) AS qtyIp,
  SUM(CEIL(qtyCs)) AS` qtyCs,
  SUM(CEIL(qtyPl)) AS qtyPl,
   MAX(chargerate) AS chargerate,
  SUM(billingamount) AS billingamount
FROM ZV_BILLING_DATA
WHERE arNo IS NOT NULL
AND transmit_status = '40'
AND OpportunityId IS NOT NULL
AND STR_TO_DATE(transmit_date, '%Y-%m-%d') BETWEEN '2024-03-26' AND '2024-04-01'
 -- AND OpportunityId = '0062w00000NguxHAAR'
GROUP BY 
-- billingFromDate,
         OpportunityId,
         warehouseId,
         rateBase,
         chargerate,
         sapmaterialid,
         directRate;