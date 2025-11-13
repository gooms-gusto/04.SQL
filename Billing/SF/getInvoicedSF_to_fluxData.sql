                SELECT
                billingfromdate AS transaction_date,
                opportunityid,
                warehouseid,
                ratebase,
                sapmaterialid as product,
                directrate,
                sum(qty) AS qty,
                sum(ceil(qtyip)) AS qtyIp,
                sum(ceil(qtyCs)) AS qtyCs,
                sum(ceil(qtyPl)) AS qtyPl,
                chargerate AS chargerate,
                sum(billingamount) AS billingamount,CONCAT(
                "INSERT INTO flux_data
( type
 ,transaction_date
 ,opportunityid
 ,warehouseid
 ,ratebase
 ,product
 ,directrate
 ,qty
 ,qtyIp
 ,qtyCs
 ,qtyPl
 ,chargerate
 ,billingamount
 ,interface_status
)
VALUES
('invoiced','",billingfromdate,"','",opportunityid,"','",warehouseid,"','",ratebase,product)
                FROM ZV_BILLING_DATA
                WHERE arno is not NULL AND transmit_status = '40'
                AND opportunityid IS NOT null
                and STR_TO_DATE(transmit_date, '%Y-%m-%d') = '2023-11-30' AND opportunityid='0062w00000NguxDAAR'
                GROUP BY billingfromdate, opportunityid, warehouseid, ratebase,chargerate, sapmaterialid, directrate;


SELECT bc.customerId,bc.udf02,bch.OpportunityId 
FROM BAS_CUSTOMER bc LEFT JOIN BIL_CRM_HEADER bch ON bc.udf02=bch.CustomerId
 WHERE bc.customerId='ITOCHU' AND bc.customerType='OW';
