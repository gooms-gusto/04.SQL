SELECT dvh.organizationId,
  dvh.warehouseId,
  dvh.customerId, 
  dvh.vasNo AS trans_no,
  zbccd.spName AS spName,
  dvh.editTime AS trans_time
FROM DOC_VAS_HEADER dvh
 INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
      ON (dvh.organizationId = zbcc.organizationId
      AND dvh.warehouseId = zbcc.warehouseId
      AND dvh.customerId = zbcc.customerId)
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
      ON (zbcc.organizationId = zbccd.organizationId
      AND zbcc.lotatt01 =zbccd.idGroupSp)
WHERE dvh.organizationId='OJV_CML' 
  -- AND dvh.warehouseId='@warehouse' 
  -- AND dvh.customerId='@customer'
        AND zbcc.lotatt01 <> ''
      AND zbcc.active='Y'
      AND zbccd.active='Y'
  AND zbccd.spName='CML_BILLVASSPECIALSTD'
  AND dvh.vasStatus='99' 
  AND  date(dvh.editTime) >=DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
AND   NOT EXISTS (SELECT 1 FROM BIL_SUMMARY bs
WHERE  bs.organizationId='OJV_CML' AND bs.docNo=dvh.vasNo AND bs.customerId=dvh.customerId AND
 bs.chargeCategory='VA' AND date(bs.addTime) >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH)) ORDER BY dvh.editTime ASC; 



-- SELECT * FROM DOC_VAS_HEADER dvh ORDER BY dvh.addTime DESC LIMIT 100;
