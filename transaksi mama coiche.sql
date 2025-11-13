SELECT COUNT(1)AS  total_transaksi_out
FROM ACT_ALLOCATION_DETAILS aad
WHERE aad.organizationId='OJV_CML' AND aad.customerId IN (
SELECT bc.customerId FROM BAS_CUSTOMER bc WHERE bc.customerType='OW' AND bc.activeFlag='Y'
)  AND aad.warehouseId IN ('CBT02','CBT02-B2C') 



AND aad.customerId IN ('ECMAMA',
'ECMAMAB2C')
GROUP BY aad.customerId,aad.warehouseId
union
SELECT COUNT(1)AS  total_transaksi_in
-- ,aad.fmCustomerId AS customerId 
FROM  ACT_TRANSACTION_LOG aad
WHERE aad.organizationId='OJV_CML' AND aad.fmCustomerId IN (
SELECT bc.customerId FROM BAS_CUSTOMER bc WHERE bc.customerType='OW' AND bc.activeFlag='Y'
)  AND aad.warehouseId IN ('CBT02','CBT02-B2C')




AND aad.warehouseId IN ('CBT02','CBT02-B2C') AND aad.fmCustomerId IN ('ECMAMA',
'ECMAMAB2C') AND aad.transactionType='IN'
GROUP BY aad.fmCustomerId,aad.warehouseId