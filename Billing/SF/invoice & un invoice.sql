
#1.	Un-invoice
SELECT -- *
  billingFromDate AS transaction_date,
  OpportunityId,
  LENGTH(OpportunityId) AS len_op,
  warehouseId,
  rateBase,
  sapmaterialid AS product,
  directRate,
  SUM(qty) AS qty,
  SUM(CEIL(qtyIp)) AS qtyIp,
  SUM(CEIL(qtyCs)) AS qtyCs,
  SUM(CEIL(qtyPl)) AS qtyPl,
  chargerate AS chargerate,
  SUM(billingamount) AS billingamount
FROM ZV_BILLING_DATA
WHERE billingFromDate = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 0 DAY), '%Y-%m-%d')
AND ((arNo IS NULL)
OR (arNo = '*')
OR (arNo IS NOT NULL
AND transmit_status = '00'))
AND OpportunityId IS NOT NULL
GROUP BY billingFromDate,
         OpportunityId,
         warehouseId,
         rateBase,
         chargerate,
         sapmaterialid,
         directRate,
         len_op;


#2. Invoice

SELECT -- *
  billingFromDate AS transaction_date,
  OpportunityId,
  warehouseId,
  rateBase,
  sapmaterialid AS product,
  directRate,
  SUM(qty) AS qty,
  SUM(CEIL(qtyIp)) AS qtyIp,
  SUM(CEIL(qtyCs)) AS qtyCs,
  SUM(CEIL(qtyPl)) AS qtyPl,
  chargerate AS chargerate,
  SUM(billingamount) AS billingamount
FROM ZV_BILLING_DATA
WHERE arNo IS NOT NULL
AND transmit_status = '40'
AND OpportunityId IS NOT NULL
AND STR_TO_DATE(transmit_date, '%Y-%m-%d') BETWEEN '2023-10-26' AND '2023-11-03'
AND OpportunityId = '0062w00000NguxHAAR'
GROUP BY billingFromDate,
         OpportunityId,
         warehouseId,
         rateBase,
         chargerate,
         sapmaterialid,
         directRate;


