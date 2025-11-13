SELECT CONCAT('WHSCON',',',
 'HEAD',',',
   doh.soReference1,',,10229,PIC,PGI,,,',
'WHSCON',',',
'ITEM',',',
  -- doh.udf03,','
 '0',',',
 -- doh.udf04,',',
     dod.sku,',',
     'ID02',',',
        '1',',',
  dod.qtyShipped_each,',',
  dod.qtyShipped_each,',',
 dod.qtyOrdered,',',
 dod.lotAtt04 ,',')
  AS interface
FROM WMS_FTEST.DOC_ORDER_HEADER doh
  INNER JOIN WMS_FTEST.DOC_ORDER_DETAILS dod
    ON doh.warehouseId = dod.warehouseId
    AND doh.orderNo = dod.orderNo
    AND doh.customerId = dod.customerId
  WHERE doh.customerId='PPG'  
and doh.soReference1 in ('TRIAL009')
AND doh.soStatus='99' order by doh.orderNo ASC;



SELECT 
FROM WMS_FTEST.DOC_ORDER_HEADER doh
  INNER JOIN WMS_FTEST.DOC_ORDER_DETAILS dod
    ON doh.warehouseId = dod.warehouseId
    AND doh.orderNo = dod.orderNo
    AND doh.customerId = dod.customerId
  WHERE doh.customerId='PPG'  
and doh.soReference1 in ('TRIAL009')
AND doh.soStatus='99' order by doh.orderNo ASC;


SELECT * FROM WMS_FTEST.DOC_ORDER_HEADER doh WHERE doh.soReference1 in ('TRIAL009') AND  doh.warehouseId='CBT01' AND doh.customerId='PPG'