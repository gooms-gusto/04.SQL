SELECT * FROM ACT_TRANSACTION_LOG atl 
  INNER JOIN DOC_ASN_HEADER dah ON (atl.organizationId=dah.organizationId AND atl.warehouseId = dah.warehouseId 
  AND atl.fmCustomerId=dah.customerId AND atl.docNo=dah.asnNo)
  WHERE atl.warehouseId='SMPR01' 
  AND atl.fmCustomerId='LTL'  AND atl.status=99  AND atl.status='99' AND atl.transactionType='IN' AND dah.asnType <> 'FREE'
  AND atl.editTime BETWEEN '2022-07-24' AND '2022-08-25'