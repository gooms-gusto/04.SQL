 SELECT DISTINCT
    bsm.organizationId,
    bsm.warehouseId,
    bsm.CUSTOMERID,
    DAY(bth.billingdate) billingDate,
    btr.tariffId,
    btr.tariffLineNo,
    btr.tariffClassNo,
    btd.chargeCategory,
    btd.chargeType,
    btd.descrC,
    btd.docType,
    btd.ratebase,
    btr.ratePerUnit,
    btr.rate,
    btd.minAmount,
    btd.maxAmount,
    IF(btd.UDF03 = '', 0, btd.UDF03) minQty,
    btd.UDF01 AS MaterialNo,
    btd.udf02 AS itemChargeCategory,
    btd.udf04 billMode,
    locationCategory,
    btd.UDF05,
    btd.UDF06,
    btd.UDF07,
    btd.UDF08,
    IFNULL(btd.incomeTaxRate, 0) IncomeTaxRate,
    CASE WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1 ELSE IFNULL(btr.classfrom, 0) END,
    IFNULL(classTo, 0),
    bth.contractNo,
    bth.tariffMasterId,
    btr.cost,
    btd.billingParty
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
    INNER JOIN BIL_TARIFF_RATE btr
      ON btr.organizationId = btd.organizationId
      AND btr.tariffId = btd.tariffId
      AND btr.tariffLineNo = btd.tariffLineNo
  WHERE bsm.organizationId = 'OJV_CML'
  AND bsm.warehouseId = 'CBT01'
  AND bsm.customerId LIKE 'MAP'
  AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  -- AND btd.chargeCategory = 'IV'
  AND btr.rate > 0
  #AND IFNULL(DAY(bth.billingdate),0)!=0 
  ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;