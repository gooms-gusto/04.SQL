SELECT
  dth.organizationId,
  dth.warehouseId,
  dth.customerId,
  dth.tdocNo,
  dth.editTime AS closeTime,
  dth.tdocType,
  dtd.toLotAtt04,
  dtd.toLotAtt05,
  dtd.toLotAtt06,
  dtd.toLotAtt08,
  dtd.fmSku,
  dtd.toSku,
  dtd.fmQty,
  dtd.toQty AS qtyChargeBilling,
  dtd.tdocLineNo,
  bsm.tariffMasterId,
  bil.tariffId,
  bil.chargeCategory,
  bil.chargeType,
  bil.rate,
  bcm.codeDescr,
  'QUANTITY' AS ratebase,
  0 cost,
  1 AS rateperunit,
  bil.udf01,
  bil.udf06,
  NULL incomeTaxRate
FROM DOC_TRANSFER_HEADER dth
  INNER JOIN DOC_TRANSFER_DETAILS dtd
    ON (dth.organizationId = dtd.organizationId
    AND dth.warehouseId = dtd.warehouseId
    AND dth.tdocNo = dtd.tdocNo)
  INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
    ON (dth.organizationId = zbcc.organizationId
    AND dth.warehouseId = zbcc.warehouseId
    AND dth.customerId = zbcc.customerId)
  INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
    ON (zbcc.organizationId = zbccd.organizationId
    AND zbcc.lotatt01 = zbccd.idGroupSp)
  INNER JOIN BAS_SKU_MULTIWAREHOUSE bsm
    ON bsm.organizationId = dtd.organizationId
    AND bsm.warehouseId = dtd.warehouseId
    AND bsm.customerId = dtd.fmCustomerId
    AND bsm.SKU = dtd.fmSku
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
    AND btd.chargeCategory = 'TD'
    AND btd.udf01 IN ('1700000008')
    AND btd.tariffLineNo > 100
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
    AND bil.chargeCategory = 'TD'
    AND bil.chargeType = dth.tdocType
  INNER JOIN BSM_CODE_ML bcm
    ON bcm.organizationId = bil.organizationId
    AND bcm.codeType = 'TRF_TYP'
    AND bcm.languageId = 'en'
    AND bcm.codeid = dth.tdocType
WHERE dth.organizationId = 'OJV_CML' -- IN_organizationId
-- AND dth.warehouseId=IN_warehouseId
-- AND dth.customerId=IN_CustomerId
-- AND dtd.vasNo=IN_trans_no
AND zbcc.lotatt01 <> ''
AND zbcc.active = 'Y'
AND zbccd.active = 'Y'
AND zbccd.spName = 'CML_BILLTRFBAGGINGSTD'
AND dth.status = '99' 
AND dtd.tdocLineStatus='99'
AND DATE(dth.editTime) >= getBillFMDate(25)
AND NOT EXISTS (SELECT
    1
  FROM BIL_SUMMARY bs
  WHERE bs.organizationId = 'OJV_CML'
  AND bs.warehouseId = dth.warehouseId
  AND bs.customerId = dth.customerId
  AND bs.docNo = dth.tdocNo
  AND bs.chargeCategory = 'TD'
  AND DATE(bs.addTime) >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
ORDER BY dth.editTime ASC;