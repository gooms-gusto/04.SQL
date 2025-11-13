select COUNT(asnNo) from  app.DOC_ASN_HEADER WHERE warehouseId='WHPGD01' AND cast(addTime AS date) < cast(NOW() AS date) ORDER BY asnNo DESC;

SELECT  cast(NOW() AS date) FROM 



SELECT * FROM app.DOC_ASN_HEADER dah WHERE dah.asnNo='ASNPGD22102500002'