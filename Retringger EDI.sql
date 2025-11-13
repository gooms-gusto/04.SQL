USE wms_cml

SELECT * FROM DOC_ORDER_HEADER doh WHERE doh.soReference1 IN ('0675189747',
'0675235831',
'0675235832',
'0675235828')


  USE wms_cml;
UPDATE DOC_ORDER_HEADER SET
 ediSendFlag = 'N', editTime=NOW()
 WHERE organizationId = 'OJV_CML'
 AND warehouseId = 'CBT01' 
AND customerId = 'PPGTESTING'
AND soReference1 IN ('0675189747',
'0675235831',
'0675235832',
'0675235828')
;


SELECT * FROM DOC_ASN_HEADER dah WHERE dah.asnReference1 IN 
(
'0675235829',
'0675235827',
'0675235828'
) AND dah.customerId='PPGTESTING'


USE wms_cml;
UPDATE DOC_ASN_HEADER 
SET ediSendFlag = 'Y' ,editTime=NOW()
WHERE organizationId = 'OJV_CML' 
AND warehouseId = 'CBT01'
 AND asnReference1 IN (
'0675235829',
'0675235827',
'0675235828'
) AND customerId='PPGTESTING'

