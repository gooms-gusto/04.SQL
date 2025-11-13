SELECT * FROM DOC_ASN_DETAILS  dah WHERE dah.warehouseId='CBT01' AND dah.asnNo='PPG_ASNNO00000000057';



  SELECT CONCAT('WMMBXY',',',
  'ITEM',',',
  doh.asnNo,',',
     po.expectedArriveTime1 ,',',
    doh.lastReceivingTime ,',',
  doh.asnReference1,',',
'WMMBXY',',',
'ITEM',',',
    dod.sku,',',
        '0002',',',
         '101',',',
         '150',',',
         dod.receivedQty,',',
dod.packUom,',',
dod.asnLineNo,',',
doh.asnNo,',','',
dod.lotAtt04)
  AS interface
FROM WMS_FTEST.DOC_ASN_HEADER doh
  INNER JOIN WMS_FTEST.DOC_ASN_DETAILS dod
    ON doh.warehouseId = dod.warehouseId
    AND doh.asnNo = dod.asnNo
    AND doh.customerId = dod.customerId
    inner join  WMS_FTEST.DOC_PO_HEADER po on (po.customerId=doh.customerId and po.poNo=doh.poNo)
  WHERE doh.customerId='PPG' 
  AND (doh.asnStatus='40' or doh.asnStatus='99') and 
doh.asnNo='PPG_ASNNO00000000057';