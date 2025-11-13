SELECT * FROM wms_ftest_arv2020.Z_InventoryBalance zib



SELECT
  COUNT(doh.ASNNO)AS ASN
FROM DOC_ASN_HEADER doh
WHERE DATE_FORMAT(doh.editTime, '%Y-%m-d%') BETWEEN '2022-01-01' AND '2022-12-31'
AND doh.warehouseId = 'SMG-TA'
AND doh.asnStatus > '90';



SELECT
  COUNT(DOD.ASNNO) AS ASNDETAIL
FROM DOC_ASN_DETAILS
DOD
  INNER JOIN DOC_ASN_HEADER  DOH
    ON DOD.organizationId = DOH.organizationId
    AND DOD.warehouseId = DOH.warehouseId
    AND DOD.customerId = DOH.customerId
    AND DOD.asnNo = DOH.asnNo
WHERE DATE_FORMAT(DOH.editTime, '%Y-%m-d%')
BETWEEN '2022-01-01' AND '2022-12-31'
AND DOH.warehouseId = 'SMG-TA'
AND DOH.asnStatus > '90';




SELECT
  COUNT(doh.orderNo) AS SO
FROM DOC_ORDER_HEADER doh
WHERE DATE_FORMAT(doh.editTime, '%Y-%m-d%') BETWEEN '2022-01-01' AND '2022-12-31'
AND doh.warehouseId = 'SMG-TA'
AND doh.soStatus > '90';




SELECT
  COUNT(DOD.orderNo) AS SODETAIL
FROM DOC_ORDER_DETAILS DOD
  INNER JOIN DOC_ORDER_HEADER DOH
    ON DOD.organizationId = DOH.organizationId
    AND DOD.warehouseId = DOH.warehouseId
    AND DOD.orderNo = DOH.orderNo
    AND DOD.customerId = DOH.customerId
WHERE DATE_FORMAT(DOH.editTime, '%Y-%m-d%') BETWEEN '2022-01-01' AND '2022-12-31'
AND DOH.warehouseId = 'SMG-TA'
AND DOH.soStatus > '90';



SELECT COUNT(*) FROM Z_InventoryBalance zib WHERE DATE_FORMAT(zib.editTime,'%Y')='2020' AND zib.warehouseId = 'CBT01';