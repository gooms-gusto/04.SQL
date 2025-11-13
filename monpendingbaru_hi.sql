

  SELECT
      dah.organizationId,
      dah.warehouseId,
      dah.customerId,
      dah.asnNo AS trans_no,
      zbccd.spName,dah.asnType
    FROM DOC_ASN_HEADER dah 
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
        ON (dah.organizationId = zbcc.organizationId
        AND dah.warehouseId = zbcc.warehouseId
        AND dah.customerId = zbcc.customerId)
    INNER JOIN DOC_ASN_HEADER_UDF dahu 
    ON (dah.organizationId = dahu.organizationId AND dah.warehouseId = dahu.warehouseId AND dah.asnNo = dahu.asnNo)
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
        ON zbcc.organizationId = zbccd.organizationId
        AND zbcc.lotatt01 = zbccd.idGroupSp
    WHERE dah.organizationId = 'OJV_CML'
    AND dah.asnType NOT IN ('FREE', 'KT', 'TROF', 'TTG')
    --   doh.warehouseId='' AND
    AND dah.asnStatus = '99'
    AND zbcc.lotatt01 <> ''
    AND zbcc.active = 'Y'
    AND zbccd.active = 'Y'
    AND zbccd.spName = 'CML_BILLHISTD_TYPE2'
    AND dahu.closeTime >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    AND NOT EXISTS (SELECT
        1
      FROM BIL_SUMMARY bs
      WHERE bs.organizationId = 'OJV_CML'
      AND bs.docNo = dah.asnNo
      AND bs.warehouseId = dah.warehouseId
      AND bs.customerId = dah.customerId
      AND bs.chargeCategory = 'IB'
      AND bs.addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
    --  GROUP BY doh.organizationId,doh.warehouseId, doh.customerId,trans_no,zbccd.spName
    ORDER BY dah.editTime ASC;
