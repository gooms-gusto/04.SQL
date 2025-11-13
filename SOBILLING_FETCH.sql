    SELECT 
    doh.organizationId,
    doh.warehouseId,
    doh.customerId,
    doh.orderNo as trans_no, 
      zbccd.spName,
      doh.orderTime AS trans_time
FROM 
    DOC_ORDER_HEADER doh INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
      ON (doh.organizationId = zbcc.organizationId
      AND doh.warehouseId = zbcc.warehouseId
      AND doh.customerId = zbcc.customerId)
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
      ON zbcc.organizationId = zbccd.organizationId
      AND zbcc.lotatt01 =zbccd.idGroupSp
WHERE doh.organizationId='OJV_CML' AND  
   --   doh.warehouseId='' AND
    --  doh.customerId = '' AND
      doh.soStatus = '99'
      AND zbcc.lotatt01 <> ''
      AND zbcc.active='Y'
      AND zbccd.active='Y'
      AND zbccd.spName='CML_BILLHOSTD'
    AND doh.orderTime >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
      AND doh.orderType IN (
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
          ON (btd.organizationId = bth.organizationId
          AND btd.tariffId = bth.tariffId)
          WHERE bsm.organizationId=doh.organizationId AND bc.customerId=doh.customerId AND bsm.warehouseId=doh.warehouseId
  AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND btd.chargeCategory = 'OB'
)
    AND NOT EXISTS (
        SELECT 1 
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId='OJV_CML' AND
            bs.docNo = doh.orderNo
            AND bs.warehouseId = doh.warehouseId
            AND bs.customerId = doh.customerId AND  bs.chargeCategory='OB'
            AND bs.addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH)
    )
ORDER BY 
    doh.orderTime ASC;