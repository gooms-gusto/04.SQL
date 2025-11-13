SELECT bbh.transactionFromDate,bbh.transactionToDate,
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
bbt.SAPMaterialCode not in ('1700000037')
and DATE_FORMAT(bbh.transactionFromDate,'%Y-%m-d%')  >= getBillFMDate(26)
and DATE_FORMAT(bbh.transactionToDate,'%Y-%m-d%') <= getBillTODate(26)
 AND bmc.udf02SAPCode  NOT IN('3000000735','3000020580')
 AND bbt.amountCategory > 0
GROUP BY
bbh.warehouseId,
bmw.salesOffice ,
bbt.SAPDivision,
bmc.udf02SAPCode,
 bbh.transactionFromDate,bbh.transactionToDate
