SELECT * FROM Z_BAS_CUSTOMER_CUSTBILLING zbcc WHERE zbcc.active='Y';

SELECT bs.organizationId,bs.warehouseId,bs.customerId,COUNT(bs.billingSummaryId) as line_billing,SUM(bs.billingAmount) total_ammount
FROM BIL_SUMMARY bs
INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
ON bs.organizationId = zbcc.organizationId AND bs.warehouseId = zbcc.warehouseId AND bs.customerId = zbcc.customerId
WHERE zbcc.active='Y'
    AND (DATE_FORMAT(bs.billingFromDate, '%Y-%m-%d') >= getBillFMDate(26)
    AND DATE_FORMAT(bs.billingFromDate, '%Y-%m-%d') <= getBillTODate(26))
GROUP BY bs.organizationId,bs.warehouseId,bs.customerId
