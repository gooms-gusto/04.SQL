SELECT dah.organizationId,
  dah.warehouseId,
  dah.customerId, 
  dah.tdocNo as trans_no,
  zbccd.spName,
  dah.editTime as trans_time
FROM DOC_TRANSFER_HEADER  dah 
  INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
      ON (dah.organizationId = zbcc.organizationId
      AND dah.warehouseId = zbcc.warehouseId
      AND dah.customerId = zbcc.customerId)
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
      ON (zbcc.organizationId = zbccd.organizationId
      AND zbcc.lotatt01 =zbccd.idGroupSp)
WHERE dah.organizationId='OJV_CML'
-- AND dah.warehouseId='@warehouse'
-- AND dah.customerId ='@customer'
AND dah.tdocType IN (
'TBD',
'TBD1',
'TBD10',
'TBD101',
'TBD11',
'TBD12',
'TBD13',
'TBD14',
'TBD2',
'TBD3',
'TBD4',
'TBD5',
'TBD6',
'TBD7',
'TBD8',
'TBD9'
)
    AND zbcc.lotatt01 <> ''
      AND zbcc.active='Y'
      AND zbccd.active='Y'
  AND zbccd.spName='CML_BILLTRFBAGGINGSTD'
AND dah.status IN ('99')
AND dah.editTime >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
 AND NOT EXISTS  (
 SELECT 1 FROM BIL_SUMMARY bs
 WHERE bs.organizationId='OJV_CML' AND bs.warehouseId=dah.warehouseId
  AND  bs.customerId=dah.customerId AND bs.docNo=dah.tdocNo
   AND bs.chargeCategory='TD' AND  
date(bs.addTime) >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
order BY dah.editTime ASC;