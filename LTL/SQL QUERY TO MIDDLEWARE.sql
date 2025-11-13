SELECT * FROM customer c WHERE c.code LIKE '%LAI%';

SELECT * FROM DOC_ORDER_HEADER doh WHERE doh.idOrderHeader='969';

SELECT * FROM DOC_ORDER_DETAILS dod WHERE dod.idOrderHeader='969';

SELECT doh.idOrderHeader FROM DOC_ORDER_HEADER doh WHERE doh.customer_id IN (
SELECT customer_id FROM customer c WHERE c.code   LIKE '%LAI%');


SELECT * FROM DOC_ORDER_DETAILS doh WHERE doh.idOrderHeader IN (
SELECT doh.idOrderHeader FROM DOC_ORDER_HEADER doh WHERE doh.customer_id IN (
SELECT customer_id FROM customer c WHERE c.code   LIKE '%LAI%'))


USE dev_oms;

USE dev_oms;

SELECT
  idOrderDetail,
  idOrderHeader,
  interfaceStatus,
  interfaceTime,
  orderLineNo,
  sku,
  skuDescr1,
  uom,
  lotAtt01,
  lotAtt02,
  lotAtt03,
  lotAtt04,
  lotAtt05,
  lotAtt06,
  lotAtt07,
  lotAtt08,
  lotAtt09,
  lotAtt10,
  lotAtt11,
  lotAtt12,
  lotAtt13,
  lotAtt14,
  lotAtt15,
  lotAtt16,
  lotAtt17,
  lotAtt18,
  lotAtt19,
  lotAtt20,
  lotAtt21,
  lotAtt22,
  lotAtt23,
  lotAtt24,
  qtyOrdered,
  qtyShipped,
  price,
  userDefine1,
  userDefine2,
  userDefine3,
  userDefine4,
  userDefine5,
  userDefine6,
  userDefine7,
  noteText,
  addTime,
  editTime,
  dedi01,
  dedi02,
  dedi03,
  dedi04,
  dedi05,
  dedi06,
  dedi07,
  dedi08,
  dedi09,
  dedi10,
  dedi11,
  dedi12,
  dedi13,
  dedi14,
  dedi15,
  dedi16,
  dedi17,
  dedi18,
  dedi19,
  dedi20,
  location,
  batchNo,
  grossWeight,
  cbm
FROM DOC_ORDER_DETAILS;