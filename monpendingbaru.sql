

  SELECT
      doh.organizationId,
      doh.warehouseId,
      doh.customerId,
      doh.orderNo AS trans_no,
      zbccd.spName
    FROM DOC_ORDER_HEADER doh
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
        ON (doh.organizationId = zbcc.organizationId
        AND doh.warehouseId = zbcc.warehouseId
        AND doh.customerId = zbcc.customerId)
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
        ON zbcc.organizationId = zbccd.organizationId
        AND zbcc.lotatt01 = zbccd.idGroupSp
    WHERE doh.organizationId = 'OJV_CML'
    AND doh.orderType NOT IN ('FREE', 'KT', 'TROF', 'TTG')
    --   doh.warehouseId='' AND
    AND doh.soStatus = '99'
    AND zbcc.lotatt01 <> ''
    AND zbcc.active = 'Y'
    AND zbccd.active = 'Y'
    AND zbccd.spName = 'CML_BILLHOSTD_TYPE2'
    AND doh.orderTime >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    AND NOT EXISTS (SELECT
        1
      FROM BIL_SUMMARY bs
      WHERE bs.organizationId = 'OJV_CML'
      AND bs.docNo = doh.orderNo
      AND bs.warehouseId = doh.warehouseId
      AND bs.customerId = doh.customerId
      AND bs.chargeCategory = 'OB'
      AND bs.addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
    --  GROUP BY doh.organizationId,doh.warehouseId, doh.customerId,trans_no,zbccd.spName
    ORDER BY doh.orderTime ASC;

















 