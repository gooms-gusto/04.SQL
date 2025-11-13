SELECT doh.soReference1,doh.udf05,doh.udf06,dod.sku,doh.orderNo,
act.qty_each  as qtyOrdered_each,
act.qtyShipped_eachas qtyShipped_each,
act.qtyOrdered_each - act.qtyShipped_each as pendingpick,
att.lotAtt04
FROM wms_cml.DOC_ORDER_HEADER doh
  INNER JOIN wms_cml.DOC_ORDER_DETAILS dod
    ON doh.warehouseId = dod.warehouseId
    AND doh.orderNo = dod.orderNo
    AND doh.customerId = dod.customerId
    INNER JOIN wms_cml.ACT_ALLOCATION_DETAILS act on (doh.orderno=act.orderno and doh.customerId=act.customerId and dod. orderLineNo=act.orderLineNo) 
    INNER JOIN  wms_cml.INV_LOT_ATT att on( act.lotnum=att.lotnum)
  WHERE doh.customerId='PPGTESTING'  
and doh.soReference1 in ('0675235844')
AND doh.soStatus='99'
group by doh.soReference1,act.orderlineno,doh.udf05,doh.udf06,dod.sku,doh.orderNo
 order by doh.orderNo 