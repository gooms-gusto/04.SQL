 SELECT
        dav.organizationId,
        dav.warehouseId,
        dah.customerId,
        dav.asnNo,
        dahu.closeTime,
        dad.sku,
        dav.vasType,
        dav.vasQty AS qtyChargeBilling,
        dav.asnLineNo AS lineNo,
        bsm.tariffMasterId,
        bil.tariffId,
        bcm.codeDescr,
        bil.chargeCategory,bil.chargeType,
        bil.rate,
        'QUANTITY' AS ratebase,
        0 cost,
        1 AS rateperunit,
        bil.udf01,
        bil.udf06,NULL incomeTaxRate
      FROM DOC_ASN_VAS dav
        INNER JOIN DOC_ASN_HEADER dah
          ON dav.organizationId = dah.organizationId
          AND dav.warehouseId = dah.warehouseId
          AND dav.asnNo = dah.asnNo
        INNER JOIN DOC_ASN_DETAILS dad
          ON dav.organizationId = dad.organizationId
          AND dav.warehouseId = dad.warehouseId
          AND dav.asnNo = dad.asnNo
          AND dav.asnLineNo = dad.asnLineNo
        LEFT OUTER JOIN BAS_SKU_MULTIWAREHOUSE bsm
          ON bsm.organizationId = dah.organizationId
          AND bsm.warehouseId = dah.warehouseId
          AND bsm.customerId = dah.customerId
          AND bsm.SKU = dad.Sku
        INNER JOIN (SELECT
            btd.organizationId,
            btd.warehouseId,
            bth.tariffMasterId,
            btd.tariffId,
            btr.rate,
            btd.chargeCategory,
            btd.chargeType,
            btd.vasType,
            btd.udf01,
            btd.udf06
          FROM BIL_TARIFF_HEADER bth
            LEFT JOIN BIL_TARIFF_DETAILS btd
              ON btd.organizationId = bth.organizationId
              AND btd.tariffId = bth.tariffId
            LEFT JOIN BIL_TARIFF_RATE btr
              ON btr.organizationId = btd.organizationId
              AND btr.tariffId = btd.tariffId
              AND btr.tariffLineNo = btd.tariffLineNo
          WHERE btd.organizationId = 'OJV_CML'
          AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
          AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
          AND btd.chargeCategory = 'VA' AND btd.vasType <> '' AND  btd.tariffLineNo <= 100
          AND btr.rate > 0
          GROUP BY btd.organizationId,
                   btd.warehouseId,
                   btd.tariffId,
                   btr.rate,
                   btd.chargeCategory,btd.chargeType,
                   btd.vasType,
                   btd.udf01,
                   btd.udf06) bil
          ON bil.organizationId = bsm.organizationId
          AND bil.warehouseId = bsm.warehouseId
          AND bil.tariffMasterId = bsm.tariffMasterId
          AND bil.vasType = dav.vasType
        INNER JOIN BSM_CODE_ML bcm
          ON dav.organizationId = bcm.organizationId
          AND bcm.codeType = 'VAS_TYP'
          AND bcm.codeid = dav.vasType
        INNER JOIN DOC_ASN_HEADER_UDF dahu
          ON dav.organizationId = dahu.organizationId
          AND dav.warehouseId = dahu.warehouseId
          AND dav.asnNo = dahu.asnNo
        INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
          ON (dav.organizationId = zbcc.organizationId
          AND dav.warehouseId = zbcc.warehouseId
          AND dah.customerId = zbcc.customerId)
        INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
          ON (zbcc.organizationId = zbccd.organizationId
          AND zbcc.lotatt01 = zbccd.idGroupSp)
      WHERE dav.organizationId = 'OJV_CML'
      AND dav.warehouseId = 'CBT01'
      AND dah.customerId = 'LTL'
      AND DATE(dahu.closeTime) >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
      AND zbcc.lotatt01 <> ''
      AND zbcc.active = 'Y'
      AND zbccd.active = 'Y'
      AND dah.asnStatus IN ('99')
      AND dah.asnType NOT IN ('FREE')
      AND zbccd.spName = 'CML_BILLASNVASSTD'
      AND dah.asnNo = 'P000018672';