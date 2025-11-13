USE wms_cml;
SELECT * FROM wms_cml.BAS_SKU  WHERE customerId='MAP';

SELECT * FROM wms_cml.DOC_ORDER_HEADER doh WHERE doh.customerId='MAP' AND doh.soReference1 IN ('0083943315','0083931759','0083931757','0083931731');


UPDATE wms_cml.DOC_ORDER_HEADER
set soStatus='63',editTime=NOW()
WHERE customerId='MAP' AND soReference1 IN ('0083943315','0083931759','0083931757','0083931731');
 
