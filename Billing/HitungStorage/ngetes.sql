SELECT * FROM BIL_SUMMARY bs
WHERE bs.organizationId='OJV_CML' AND bs.customerId='MAP' AND bs.chargeCategory='IV' AND warehouseId IN ('CBT02','CBT03','LADC01')
AND DATE(bs.billingFromDate)>='2024-10-26'
AND DATE(bs.billingFromDate)<='2024-11-25'
ORDER BY bs.billingFromDate DESC;




DELETE FROM BIL_SUMMARY 
WHERE organizationId='OJV_CML' AND customerId='MAP' AND chargeCategory='IV'  AND warehouseId IN ('CBT02','CBT03','LADC01')
AND DATE(billingFromDate)>='2024-10-26'
AND DATE(billingFromDate)<='2024-11-25';


 CALL CML_BILLSTORAGE_DAILY_CBM('OJV_CML', '', 'CUSTOMBIL', 'en', 'MAP', '', '');