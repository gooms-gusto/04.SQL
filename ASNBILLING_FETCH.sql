SELECT 
    dah.organizationId,
    dah.warehouseId,
    dah.customerId,
    dah.asnNo as trans_no,
  zbccd.spName,
      dah.editTime AS trans_time
FROM 
    DOC_ASN_HEADER dah  INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
      ON (dah.organizationId = zbcc.organizationId
      AND dah.warehouseId = zbcc.warehouseId
      AND dah.customerId = zbcc.customerId)
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
      ON (zbcc.organizationId = zbccd.organizationId
      AND zbcc.lotatt01 =zbccd.idGroupSp)
WHERE dah.organizationId='OJV_CML' AND  
     -- dah.warehouseId='@warehouse' AND
    --  dah.customerId = '@customer' AND
      dah.asnStatus = '99'
      AND zbcc.lotatt01 <> ''
      AND zbcc.active='Y'
      AND zbccd.active='Y'
      AND zbccd.spName='CML_BILLHISTD'
    AND dah.editTime >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
      AND dah.asnType IN (
SELECT DISTINCT btd.docType
  FROM BAS_SKU_MULTIWAREHOUSE bsm
        INNER JOIN BAS_CUSTOMER bc
          ON bc.customerId = bsm.customerId
          AND bc.organizationId = bsm.organizationId
          AND bc.CustomerType = 'OW'
        INNER JOIN BIL_TARIFF_HEADER bth
          ON bth.organizationId = bsm.organizationId
          AND bth.tariffMasterId = bsm.tariffMasterId
        INNER JOIN BIL_TARIFF_DETAILS btd
          ON btd.organizationId = bth.organizationId
          AND btd.tariffId = bth.tariffId
          WHERE bsm.organizationId=dah.organizationId AND bc.customerId=dah.customerId AND bsm.warehouseId=dah.warehouseId
  AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND btd.chargeCategory = 'IB'
)
    AND NOT EXISTS (
        SELECT 1 
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId='OJV_CML' AND
            bs.docNo = dah.asnNo
            AND bs.warehouseId = dah.warehouseId
            AND bs.customerId = dah.customerId AND  bs.chargeCategory='IB'
            AND bs.addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH)
    )
ORDER BY 
    dah.editTime ASC;