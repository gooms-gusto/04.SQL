SELECT
 -- idEstimasi,
 -- organtizationId,
  warehouseId,
    salesOffice as salesarea,
 -- customerId,
   divisionNo as divcode,
  customerCode as sapcustomerid,
CASE WHEN rate > 1000000 THEN rate ELSE totalAmount END AS BillingAmount
FROM bt_estimasi_storage 
WHERE DATE_FORMAT(DATE(addDate),'%Y%m%d') = DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),'%Y%m%d')
UNION ALL
SELECT 'MRD01' AS warehouseId,'1911' AS salesarea, 61 AS divcode,'3000008984' AS sapcustomerid,266000000 AS BillingAmount
UNION ALL
SELECT 'MRD01' AS warehouseId,'1911' AS salesarea, 61 AS divcode,'3000008984' AS sapcustomerid,41700000 AS BillingAmount
UNION ALL
SELECT 'BTSR01' AS warehouseId,'1911' AS salesarea, 61 AS divcode,'3000008984' AS sapcustomerid,19000000 AS BillingAmount
UNION ALL
SELECT 'BTSR01' AS warehouseId,'1911' AS salesarea, 61 AS divcode,'3000008984' AS sapcustomerid,27600000 AS BillingAmount
UNION ALL
SELECT 'PLBG01' AS warehouseId,'1911' AS salesarea, 61 AS divcode,'3000008984' AS sapcustomerid,18000000 AS BillingAmount
UNION ALL
SELECT 'PLBG01' AS warehouseId,'1911' AS salesarea, 61 AS divcode,'3000008984' AS sapcustomerid,27600000 AS BillingAmount
UNION ALL
SELECT 'TRKM5' AS warehouseId,'1917' AS salesarea, 61 AS divcode,'3000008984' AS sapcustomerid,361200000 AS BillingAmount
UNION ALL
SELECT 'TRKM5' AS warehouseId,'1917' AS salesarea, 61 AS divcode,'3000008984' AS sapcustomerid,35800000 AS BillingAmount