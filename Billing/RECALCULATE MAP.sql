SELECT *  FROM BIL_SUMMARY 
where organizationId = 'OJV_CML' AND 
warehouseId IN ('CBT02','JBK01') and customerId = 'MAP' 
and billingFromDate between '2025-10-26' 
and '2025-11-25' 
and chargeCategory IN ('IB','OB','IV')  and (arNo = '*' or arNo IS NULL) 
AND addWho='CUSTOMBILL'; 