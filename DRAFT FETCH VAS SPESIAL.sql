SELECT
  dvh.organizationId,
  dvh.warehouseId,
  dvh.customerId,
  dvh.vasNo,
  dvh.editTime AS closeTime,
  dvs.vasType,
  dvh.kitReference1,
  dvh.kitReference2,
  dvh.kitReference3,
  dvh.kitReference4,
  dvh.kitReference5,
  dvd.sku,
  dvd.vasLineNo,
  dvf.chargeCategory,
  dvf.chargeType,
  dvf.rateQty1 AS qtycharge,
  dvf.chargeDate
FROM DOC_VAS_HEADER dvh
  INNER JOIN DOC_VAS_DETAILS dvd
    ON dvh.organizationId = dvd.organizationId
    AND dvh.warehouseId = dvd.warehouseId
    AND dvh.vasNo = dvd.vasNo
    AND dvh.customerId = dvd.customerId
  INNER JOIN DOC_VAS_SERVICE dvs
    ON dvh.organizationId = dvs.organizationId
    AND dvh.warehouseId = dvs.warehouseId
    AND dvh.vasNo = dvs.vasNo
  INNER JOIN DOC_VAS_FEE dvf
    ON dvh.organizationId = dvf.organizationId
    AND dvd.warehouseId = dvf.warehouseId
    AND dvh.vasNo = dvf.vasNo
  INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
    ON (dvh.organizationId = zbcc.organizationId
    AND dvh.warehouseId = zbcc.warehouseId
    AND dvh.customerId = zbcc.customerId)
  INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
    ON (zbcc.organizationId = zbccd.organizationId
    AND zbcc.lotatt01 = zbccd.idGroupSp)
  LEFT OUTER JOIN BAS_SKU_MULTIWAREHOUSE bsm
    ON bsm.organizationId = dvd.or
    AND bsm.warehouseId = dvd.warehouseId
    AND bsm.customerId = dvd.customerId
    AND bsm.SKU = dvd.Sku
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
    AND btd.chargeCategory = 'VA'
    AND btd.vasType <> ''
    AND btd.tariffLineNo <= 100
    AND btr.rate > 0
    GROUP BY btd.organizationId,
             btd.warehouseId,
             btd.tariffId,
             btr.rate,
             btd.chargeCategory,
             btd.chargeType,
             btd.vasType,
             btd.udf01,
             btd.UDF06) bil
    ON bil.organizationId = bsm.organizationId
    AND bil.warehouseId = bsm.warehouseId
    AND bil.tariffMasterId = bsm.tariffMasterId
    AND bil.vasType = dvs.vasType
    AND bil.chargeCategory = dvf.chargeCategory
    AND bil.chargeType = dvf.chargeType
WHERE dvh.organizationId = 'OJV_CML'
-- AND dvh.warehouseId='@warehouse' 
-- AND dvh.customerId='@customer'
AND zbcc.lotatt01 <> ''
AND zbcc.active = 'Y'
AND zbccd.active = 'Y'
AND zbccd.spName = 'CML_BILLVASSPECIALSTD'
AND dvh.vasStatus = '99'
AND DATE(dvh.editTime) >= getBillFMDate(25)
AND NOT EXISTS (SELECT
    1
  FROM BIL_SUMMARY bs
  WHERE bs.organizationId = 'OJV_CML'
  AND bs.warehouseId = dvh.warehouseId
  AND bs.customerId = dvh.customerId
  AND bs.docNo = dvh.vasNo
  AND bs.chargeCategory = 'VA'
  AND DATE(bs.addTime) >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
ORDER BY dvh.editTime ASC;
 
