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
        btd.ratebase, -- sementara pengganti ratebase
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
        btd.billingParty,
        -- btd.billingTranCategory,
        IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
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
     -- AND bsm.warehouseId = IN_warehouseId
    --  AND bsm.customerId = IN_CustomerId
    --  AND bth.tariffMasterId = od_tariffMasterId
      AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
     -- AND btd.chargeCategory = 'IB'
    --  AND btd.docType = od_docType
   --   AND btr.rate > 0
      AND bc.customerId='BCA'
      AND bc.tariffId='BIL00520'
      #AND IFNULL(DAY(bth.billingdate),0)!=0 
      ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;


SELECT * FROM BIL_TARIFF_HEADER bth  WHERE bth.tariffId='BIL00520';
SELECT * FROM BIL_TARIFF_DETAILS btd WHERE btd.tariffId='BIL00520';
SELECT * FROM BIL_TARIFF_RATE btr WHERE btr.tariffId='BIL00520';

SELECT bth.warehouseId AS WarehouseId,
 bw.udf02 AS salesarea,
 btd.udf06 AS divcode,
  bc.udf02 AS sapcustomerid ,
  btd.minAmount AS BillingAmount
-- btm.customerId,
-- bth.tariffMasterId,
-- btd.chargeCategory,
-- btd.descrC,btd.ratebase,
FROM BIL_TARIFF_HEADER bth INNER JOIN BIL_TARIFF_DETAILS btd
ON bth.organizationId = btd.organizationId AND bth.warehouseId = btd.warehouseId AND bth.tariffId = btd.tariffId
INNER JOIN BIL_TARIFF_MASTER btm ON bth.organizationId = btm.organizationId AND bth.tariffMasterId = btm.tariffMasterId
INNER JOIN BAS_CUSTOMER bc ON btm.organizationId = bc.organizationId AND btm.Customerid = bc.customerId
INNER JOIN BSM_WAREHOUSE bw ON bw.organizationId = bth.organizationId AND bw.warehouseId=bth.warehouseId
WHERE btd.organizationId='OJV_CML'   AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bc.customerType='OW'
      AND bc.activeFlag='Y'
      AND btd.chargeCategory='FX'