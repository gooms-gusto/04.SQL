SELECT
DISTINCT
 -- idEstimasi,
 -- organtizationId,
  warehouseId,
    salesOffice as salesarea,
 -- customerId,
 CASE WHEN divisionNo = '' THEN '62' ELSE divisionNo END  AS divcode,
  customerCode as sapcustomerid,
CASE WHEN rate > 1000000 THEN rate ELSE totalAmount END AS BillingAmount,YEAR(NOW()) AS YearPeriod, MONTH(NOW()) AS MonthPeriod
FROM bt_estimasi_storage 
WHERE DATE_FORMAT(DATE(addDate),'%Y%m%d') = DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),'%Y%m%d') and warehouseId NOT IN ('SMARTSBY01');