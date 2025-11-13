SELECT
IFNULL(CAST(bbh.warehouseId as char(255)),'') AS WAREHOUSE_ID,
IFNULL(CAST(bmw.salesOffice as char(255)),'') as SALES_AREA,
IFNULL(CAST(bbt.SAPDivision as char(255)),'') as DIVISION_CODE,
IFNULL(CAST(bmc.udf02SAPCode as char(255)),'') AS SAP_CUSTOMER_ID,
ROUND(SUM(CAST(bbt.amountCategory AS decimal)),2) as BILLING_AMOUNT,
 CASE
        WHEN DAY(DATE_ADD(CURDATE(), INTERVAL -1 DAY) ) > 25 THEN 
        DATE_FORMAT(DATE_ADD(DATE_ADD(CURDATE(), INTERVAL -1 DAY) , INTERVAL (25 - DAY(DATE_ADD(CURDATE(), INTERVAL -1 DAY) ) + DAY(LAST_DAY(DATE_ADD(CURDATE(), INTERVAL -1 DAY) ))) DAY),'%m')
        ELSE  DATE_FORMAT(DATE_ADD(DATE_ADD(CURDATE(), INTERVAL -1 DAY) , INTERVAL (25 - DAY(DATE_ADD(CURDATE(), INTERVAL -1 DAY) )) DAY),'%m') END AS MONTH_PERIOD,
        DATE_FORMAT(CURRENT_DATE(),'%Y') AS  YEAR_PERIOD
FROM bt_billing_header_cml bbh
left join bm_warehouse_cml bmw
on bmw.warehouseId = bbh.warehouseId
left join bm_customer_cml bmc 
on bmc.customerId = bbh.customerId
left join bt_billing_detail_cml bbt
on bbt.idBillingHeader = bbh.idBillingHeader
WHERE
--  CASE
--         WHEN DAY(DATE_ADD(CURDATE(), INTERVAL -1 DAY) ) > 25 THEN bbh.transactionFromDate BETWEEN DATE_ADD(DATE_ADD(CURDATE(), INTERVAL -1 DAY) , INTERVAL (26 - DAY(DATE_ADD(CURDATE(), INTERVAL -1 DAY) )) DAY) AND
--         DATE_ADD(DATE_ADD(CURDATE(), INTERVAL -1 DAY) , INTERVAL (25 - DAY(DATE_ADD(CURDATE(), INTERVAL -1 DAY) ) + DAY(LAST_DAY(DATE_ADD(CURDATE(), INTERVAL -1 DAY) ))) DAY)
--         ELSE bbh.transactionFromDate BETWEEN DATE_ADD(LAST_DAY(DATE_ADD(CURDATE(), INTERVAL -1 DAY)  - INTERVAL 1 MONTH), INTERVAL 26 DAY) AND DATE_ADD(DATE_ADD(CURDATE(), INTERVAL -1 DAY) , INTERVAL (25 - DAY(DATE_ADD(CURDATE(), INTERVAL -1 DAY) )) DAY)
--     END
  DATE_FORMAT(bbh.transactionFromDate,'%Y-%m-%d')  > '2024-12-25'
  AND  DATE_FORMAT(bbh.transactionFromDate,'%Y-%m-%d')  < '2025-01-30'
 AND bmc.udf02SAPCode  IN('3000004465','3000004171')
 AND bbt.amountCategory > 0
GROUP BY
bbh.warehouseId,
bmw.salesOffice ,
bbt.SAPDivision,
bmc.udf02SAPCode
