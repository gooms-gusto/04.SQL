SELECT
IFNULL(CAST(bbh.warehouseId as char(255)),'') AS WAREHOUSE_ID,
IFNULL(CAST(bmw.salesOffice as char(255)),'') as SALES_AREA,
IFNULL(CAST(bbt.SAPDivision as char(255)),'') as DIVISION_CODE,
IFNULL(CAST(bmc.udf02SAPCode as char(255)),'') AS SAP_CUSTOMER_ID,
ROUND(SUM(CAST(bbt.amountCategory AS decimal)),2) as BILLING_AMOUNT,
DATE_FORMAT( DATE_ADD(CURDATE(),INTERVAL - 1 DAY),'%m')  AS  MONTH_PERIOD,
DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL - 1 DAY),'%Y') AS  YEAR_PERIOD
FROM bt_billing_header_cml bbh
left join bm_warehouse_cml bmw
on bmw.warehouseId = bbh.warehouseId
left join bm_customer_cml bmc 
on bmc.customerId = bbh.customerId
left join bt_billing_detail_cml bbt
on bbt.idBillingHeader = bbh.idBillingHeader
WHERE
 (DATE_FORMAT(bbh.transactionFromDate,'%Y-%m-%d')  >= DATE_FORMAT(DATE_SUB(DATE_ADD(CURDATE(),INTERVAL-1 DAY), INTERVAL DAYOFMONTH(DATE_ADD(CURDATE(),INTERVAL-1 DAY))-1 DAY),'%Y-%m-%d')
 AND  DATE_FORMAT(bbh.transactionFromDate,'%Y-%m-%d')  <= DATE_FORMAT(LAST_DAY(DATE_ADD(CURDATE(),INTERVAL - 1 DAY)),'%Y-%m-%d')) 
 AND bmc.udf02SAPCode  IN('3000000735','3000000733','3000003459')
 AND bbt.amountCategory > 0
GROUP BY
bbh.warehouseId,
bbh.customerId,
bmw.salesOffice ,
bbt.SAPDivision,
bmc.udf02SAPCode