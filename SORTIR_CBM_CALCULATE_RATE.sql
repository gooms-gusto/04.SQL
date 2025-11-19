SELECT  srt.organizationId,srt.warehouseId,srt.customerId,SUM(srt.qty) AS total_qty, SUM(srt.total_cbm) AS total_cbm,srt.stockDate,
bill.rate * SUM(srt.total_cbm) AS billing_amount
FROM (
SELECT ziba.organizationId, ziba.warehouseId, ziba.customerId,
ziba.sortirId, ziba.sku, SUM(ziba.qtyEach) AS qty, SUM(BS.`cube`) AS cbm_persku,
(SUM(ziba.qtyEach) * SUM(BS.`cube`)) AS total_cbm, ziba.stockDate
FROM Z_InventoryBalance_preASN ziba
     INNER JOIN
     Z_SORTIR_INBOUND_HEADER zsih
     ON ziba.organizationId = zsih.organizationId AND
       ziba.warehouseId = zsih.warehouseId AND
       ziba.sortirId = zsih.sortirId AND
       ziba.customerId = zsih.customerId
     INNER JOIN
     BAS_SKU BS
     ON ziba.organizationId = BS.organizationId AND
       ziba.customerId = BS.customerId AND
       ziba.sku = BS.sku
WHERE ziba.organizationId = 'OJV_CML' AND
      ziba.stockDate >= DATE(zsih.addTime) AND
      ziba.stockDate < DATE(IFNULL(zsih.completedTime, NOW()))
-- AND ziba.sortirId='STR0000001251108'
GROUP BY ziba.organizationId, ziba.warehouseId, ziba.customerId, 
ziba.sortirId, ziba.sku, ziba.stockDate) srt
INNER JOIN ( SELECT DISTINCT
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
          btd.udf05, -- sementara pengganti ratebase
          btr.ratePerUnit,
          btr.rate,
          btd.minAmount,
          btd.maxAmount,
          btr.udf02,-- minimum billing
          btr.udf03,-- chamber name
          IF(btd.UDF03 = '', 0, btd.UDF03) minQty,
          btd.UDF01 AS MaterialNo,
          btd.udf02 AS itemChargeCategory,
          btd.udf04 billMode,
          locationCategory,
         -- btd.UDF05,
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
        AND bsm.warehouseId = 'CBT02'
        AND bsm.customerId = 'MAP'
        AND btr.udf03 = 'LINC' -- for filter chamber name
        -- AND bth.tariffMasterId = od_tariffMasterId
        AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND btd.chargeCategory = 'IV'
        AND btr.rate > 0
		AND bth.tariffMasterId not in ('BIL00062PT')
        #AND IFNULL(DAY(bth.billingdate),0)!=0 
        ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo
) bill ON bill.organizationId=srt.organizationId
AND bill.warehouseId=srt.warehouseId
AND bill.customerId=srt.customerId
GROUP BY  srt.organizationId,srt.warehouseId,srt.customerId,srt.stockDate,bill.rate;



--       SELECT DISTINCT
--           bsm.organizationId,
--           bsm.warehouseId,
--           bsm.CUSTOMERID,
--           DAY(bth.billingdate) billingDate,
--           btr.tariffId,
--           btr.tariffLineNo,
--           btr.tariffClassNo,
--           btd.chargeCategory,
--           btd.chargeType,
--           btd.descrC,
--           btd.docType,
--           btd.udf05, -- sementara pengganti ratebase
--           btr.ratePerUnit,
--           btr.rate,
--           btd.minAmount,
--           btd.maxAmount,
--           btr.udf02,-- minimum billing
--           btr.udf03,-- chamber name
--           IF(btd.UDF03 = '', 0, btd.UDF03) minQty,
--           btd.UDF01 AS MaterialNo,
--           btd.udf02 AS itemChargeCategory,
--           btd.udf04 billMode,
--           locationCategory,
--           btd.UDF05,
--           btd.UDF06,
--           btd.UDF07,
--           btd.UDF08,
--           IFNULL(btd.incomeTaxRate, 0) IncomeTaxRate,
--           CASE WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1 ELSE IFNULL(btr.classfrom, 0) END,
--           IFNULL(classTo, 0),
--           bth.contractNo,
--           bth.tariffMasterId,
--           btr.cost,
--           btd.billingParty,
--           -- btd.billingTranCategory,
--           IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
--         FROM BAS_SKU_MULTIWAREHOUSE bsm
--           INNER JOIN BAS_CUSTOMER bc
--             ON bc.customerId = bsm.customerId
--             AND bc.organizationId = bsm.organizationId
--             AND bc.CustomerType = 'OW'
--           INNER JOIN BIL_TARIFF_HEADER bth
--             ON bth.organizationId = bsm.organizationId
--             AND bth.tariffMasterId = bsm.tariffMasterId
--           INNER JOIN BIL_TARIFF_DETAILS btd
--             ON btd.organizationId = bth.organizationId
--             AND btd.tariffId = bth.tariffId
--           INNER JOIN BIL_TARIFF_RATE btr
--             ON btr.organizationId = btd.organizationId
--             AND btr.tariffId = btd.tariffId
--             AND btr.tariffLineNo = btd.tariffLineNo
--         WHERE bsm.organizationId = 'OJV_CML'
--         AND bsm.warehouseId = 'CBT02'
--         AND bsm.customerId = 'MAP'
--         AND btr.udf03 = 'LINC' -- for filter chamber name
--         -- AND bth.tariffMasterId = od_tariffMasterId
--         AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
--         AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
--         AND btd.chargeCategory = 'IV'
--         AND btr.rate > 0
-- 		AND bth.tariffMasterId not in ('BIL00062PT')
--         #AND IFNULL(DAY(bth.billingdate),0)!=0 
--         ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
-- 
-- 