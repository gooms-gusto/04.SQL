SELECT * FROM bm_rate_header_cml;

SELECT * FROM prod_apibilling.bm_customer_cml;
SELECT * FROM prod_apibilling.bm_tarifMasterHeader;
SELECT * FROM bt_billing_detail_cml;

SELECT * FROM bm_rate_header_cml;
SELECT * FROM bm_rate_detail_storage;


SELECT  DISTINCT rh.customerId,rs.SAPDivision AS divisionNo,rs.rate,DATE_FORMAT(rh.effectiveFromDate,'%Y-%m-%d') AS effectiveFromDate,DATE_FORMAT(rh.effectiveToDate,'%Y-%m-%d') AS effectiveToDate,
                            DATE_ADD(DATE_FORMAT(CONCAT(YEAR(NOW()),'-', MONTH(NOW()),'-',CASE WHEN DAY(rh.firstBilingDate)=31 THEN 30 ELSE DAY(rh.firstBilingDate) END ),"%Y-%m-%d"), INTERVAL -1 MONTH)  AS CURRENT_FM_BILLINGDATE,
               DATE_ADD(DATE_FORMAT(CONCAT(YEAR(NOW()),'-', MONTH(NOW()),'-',CASE WHEN DAY(rh.firstBilingDate)=31 THEN 30 ELSE DAY(rh.firstBilingDate) END ),"%Y-%m-%d"),INTERVAL -1 DAY)  AS CURRENT_TO_BILLINGDATE
FROM bm_rate_header_cml rh
INNER JOIN bm_rate_detail_storage rs
ON rh.idRateHeader = rs.idRateHeader 
WHERE rh.customerId IN (SELECT tm.customerId FROM  bm_tarifMasterHeader tm WHERE status='ACTIVE')
AND DATE_FORMAT(rh.effectiveFromDate,'%Y-%m-%d') <= DATE_FORMAT(NOW(),'%Y-%m-%d')
AND  DATE_FORMAT(rh.effectiveToDate,'%Y-%m-%d') >= DATE_FORMAT(NOW(),'%Y-%m-%d');


SELECT * FROM bm_rate_header_cml;
SELECT * FROM bm_rate_detail_storage rs;
SELECT * FROM bm_ratebase;