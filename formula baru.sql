

  SELECT
                zib.organizationId,
                zib.warehouseId,
                zib.StockDate,
                zib.customerId,
                COUNT(DISTINCT zib.locationId),
                COUNT(DISTINCT zib.traceId) AS qtyTrace,
                COUNT(DISTINCT zib.muid),
                SUM(zib.totalCube),
                btr.tariffId AS R_TARIFFID,
                btd.ratebase AS R_ratebase,
                btr.ratePerUnit AS R_ratePerUnit,
                btr.rate AS R_rate,
                btd.minAmount as R_minAmount,
                btd.maxAmount as R_maxAmount,
                CASE WHEN btd.UDF03 = '' THEN 0 ELSE btd.UDF03 END R_minQty,
                btr.tariffClassNo AS R_TARIFFCLASSNO,
                btd.chargeCategory,
                btd.chargeType,
                CASE WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1 ELSE IFNULL(btr.classfrom, 0) END as R_CLASSFROM,
                IFNULL(btr.classTo, 0) AS R_CLASSTO,
                bth.contractNo,
                bth.tariffMasterId,
                btr.cost,
                btd.billingParty,
                DATE_FORMAT(DATE_ADD(DATE_ADD(CURDATE(),INTERVAL - DAY(CURDATE()) DAY),INTERVAL DAY(bth.billingdate) DAY),'%Y-%m-%d') AS CURRENT_FIRST_BILLINGDATE,
                DATE_FORMAT(DATE_ADD(STR_TO_DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-',  DAY(bth.billingdate)), '%Y-%m-%d'), INTERVAL -1 MONTH), '%Y-%m-%d') AS R_FMDATE,
                DATE_FORMAT(DATE_ADD(STR_TO_DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-',  DAY(bth.billingdate)), '%Y-%m-%d'), INTERVAL -1 DAY), '%Y-%m-%d') AS R_TODATE
                FROM Z_InventoryBalance zib
                INNER JOIN INV_LOT_ATT ila
                ON ila.organizationId = zib.organizationId
                AND ila.lotNum = zib.LotNum
                INNER JOIN BAS_LOCATION bl
                  ON bl.organizationId = zib.organizationId
                  AND bl.warehouseId = zib.warehouseId
                  AND bl.locationId = zib.locationId
                INNER JOIN BAS_SKU_MULTIWAREHOUSE bsm
                  ON bsm.organizationId = zib.organizationId
                  AND bsm.warehouseId = zib.warehouseId
                  AND bsm.customerId = zib.customerId
                  AND bsm.SKU = zib.sku
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
              WHERE zib.organizationId = 'OJV_CML'
              AND zib.warehouseId = 'CBT01'
              AND zib.StockDate >= '2023-03-26'
              AND zib.StockDate <= '2023-04-25'
              AND zib.customerId = 'ITOCHU'
              AND (ila.lotAtt07 = 'R'
              OR 'ST' <> 'PL')
              AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
              AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
              AND btd.chargeCategory = 'IV'
              AND btd.chargeType='ST'
              AND btr.rate > 0
              GROUP BY zib.organizationId,
                       zib.warehouseId,
                       zib.StockDate,
                       zib.customerId,
                       btr.tariffId,
                       btd.ratebase,
                       btr.ratePerUnit,
                       btr.rate,
                       btd.UDF03,
                       btd.minAmount,
                       btd.maxAmount,
                       btr.tariffClassNo,
                        btd.chargeCategory,
                        btd.chargeType,
    btr.classfrom,
    btr.classTo,
    btr.cost,
    btd.billingParty
  
