SELECT dvh.organizationId,
  dvh.warehouseId,
  dvh.customerId, 
  dvh.vasNo AS trans_no,
  zbccd.spName AS spName,
  dvh.editTime AS trans_time,dvs.vasType,dvf.chargeCategory,dvf.chargeType
FROM DOC_VAS_HEADER dvh
   LEFT JOIN DOC_VAS_DETAILS dvd
    ON dvh.organizationId = dvd.organizationId
    AND dvh.warehouseId = dvd.warehouseId
    AND dvh.vasNo = dvd.vasNo
    AND dvh.customerId = dvd.customerId
  LEFT JOIN DOC_VAS_SERVICE dvs
    ON dvh.organizationId = dvs.organizationId
    AND dvh.warehouseId = dvs.warehouseId
    AND dvh.vasNo = dvs.vasNo
  LEFT JOIN DOC_VAS_FEE dvf
    ON dvh.organizationId = dvf.organizationId
    AND dvd.warehouseId = dvf.warehouseId
    AND dvh.vasNo = dvf.vasNo
 LEFT JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
      ON (dvh.organizationId = zbcc.organizationId
      AND dvh.warehouseId = zbcc.warehouseId
      AND dvh.customerId = zbcc.customerId)
      LEFT JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
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
  AND  date(dvh.editTime) >=getBillFMDate(25)
 AND  NOT EXISTS (SELECT 1 FROM BIL_SUMMARY bs
WHERE  bs.organizationId='OJV_CML' AND bs.warehouseId=dvh.warehouseId AND  bs.customerId=dvh.customerId AND bs.docNo=dvh.vasNo AND
 bs.chargeCategory='VA' AND date(bs.addTime) >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH)) ORDER BY dvh.editTime ASC;

