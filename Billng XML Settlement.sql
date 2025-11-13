SELECT A.BILLINGNO, A.WAREHOUSEID
  , CONCAT(BS.warehouseId, '/', BC.customerId, '/', DATE_FORMAT(A.billDateTO, '%Y-%m'), '/', BS.udf02, C.udf01) AS NoPI
FROM BIL_BILLING_HEADER A
  LEFT JOIN BIL_BILLING_DETAILS B
  ON A.billingNo = B.billingNo
    AND A.warehouseId = B.warehouseId
  LEFT JOIN BIL_SUMMARY BS
  ON BS.arNo = B.billingNo
    AND BS.arLineNo = B.billingLineNo
    AND BS.warehouseId = B.warehouseId
  LEFT JOIN BAS_CUSTOMER_MULTIWAREHOUSE BC
  ON BC.customerId = BS.customerId
    AND BC.warehouseId = BS.warehouseId
  LEFT JOIN BAS_CUSTOMER C ON C.customerId = BC.customerId
  LEFT JOIN BIL_INV_LOG L
  ON L.warehouseId = A.warehouseId
    AND L.billingNo = A.billingNo
WHERE BS.arNo <> '' 
AND A.udf01='SVT000032'
  AND B.billingAmount <> ''
  AND C.customerType = 'OW'
  AND A.status = '40'
  AND A.udf05 = 'N'
GROUP BY A.BILLINGNO, A.WAREHOUSEID, CONCAT(BS.warehouseId, '/', BC.customerId, '/', DATE_FORMAT(A.billDateTO, '%Y-%m'), '/', BS.udf02, C.udf01);

SELECT * FROM  BIL_BILLING_HEADER bbh  WHERE bbh.udf01='SVT000032';


SELECT * FROM BIL_BILLING_DETAILS WHERE billingNo='0000000032' AND warehouseId='SBYVTU'