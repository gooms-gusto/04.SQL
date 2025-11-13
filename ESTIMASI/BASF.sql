SELECT * FROM bt_billing_detail_cml bbdc WHERE bbdc.idBillingHeader IN ('5587',
'5626','5951'); 


SELECT * FROM bt_billing_header_cml bbh 
WHERE bbh.customerId LIKE 'BAS%' AND 
bbh.transactionFromDate ='2024-10-01';

SELECT * FROM bm_customer_cml bcc WHERE bcc.customerId LIKE 'PAC%';





SELECT
IFNULL(CAST(bbh.warehouseId as char(255)),'') as warehouseId,
IFNULL(CAST(bmw.salesOffice as char(255)),'') as salesOffice,
IFNULL(CAST(bbt.SAPDivision as char(255)),'') as DivisionCode,
IFNULL(CAST(bmc.udf02SAPCode as char(255)),'') AS SAPCode,
IFNULL(CAST(sum(bbt.amountCategory) as char(255)),'') as Amount,YEAR(NOW()) AS YearPeriod, MONTH(NOW()) AS MonthPeriod
FROM bt_billing_header_cml bbh
left join bm_warehouse_cml bmw
on bmw.warehouseId = bbh.warehouseId
left join bm_customer_cml bmc 
on bmc.customerId = bbh.customerId
left join bt_billing_detail_cml bbt
on bbt.idBillingHeader = bbh.idBillingHeader
WHERE
 DATE_FORMAT(bbh.transactionFromDate,'%Y-%m-%d')  = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL  0 MONTH),'%Y-%m-01') 
 OR  DATE_FORMAT(bbh.transactionFromDate,'%Y-%m-%d')  =DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL  1 MONTH),'%Y-%m-26')
 AND bmc.udf02SAPCode  IN('3000000735','3000000733','3000004465','3000004171')
 AND bbt.amountCategory > 0
GROUP BY
bbh.warehouseId,
bmw.salesOffice ,
bbt.SAPDivision,
bmc.udf02SAPCode;


SELECT DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL  1 MONTH),'%Y-%m-26') 