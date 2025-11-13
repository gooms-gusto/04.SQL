SELECT * FROM DOC_ORDER_HEADER doh WHERE doh.orderNo='MAPSO000000244';

SELECT * FROM DOC_ORDER_DETAILS  doh WHERE doh.orderNo='MAPSO000000244';


  
SELECT doh.orderLineNo, doh.sku, doh.qtyOrdered_each * bs.cube,CONCAT('UPDATE DOC_ORDER_DETAILS SET edittime=NOW(), cubic =',doh.qtyOrdered_each * bs.cube,' WHERE organizationId =',CHAR(39),'OJV_CML',CHAR(39),' AND warehouseId = ',CHAR(39),'CBT01',CHAR(39),
  ' AND orderNo = ',CHAR(39),'MAPSO000000244',CHAR(39),' AND orderLineNo =',doh.orderLineNo,' AND customerId=',CHAR(39),'MAP',CHAR(39),';') AS SQLTEXT
  FROM  DOC_ORDER_DETAILS doh
  INNER JOIN BAS_SKU bs
  ON (doh.customerId = bs.customerId AND doh.sku = bs.sku)
 WHERE doh.orderNo='MAPSO000000244';





USE wms_cml;
UPDATE DOC_ORDER_DETAILS SET cubic = 0.00000000
 WHERE organizationId = 'OJV_CML' AND warehouseId = 'CBT01' AND orderNo = 'MAPSO000000244' AND orderLineNo = 1;

   