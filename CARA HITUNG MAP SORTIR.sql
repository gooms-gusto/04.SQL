

SELECT cbm.organizationId,cbm.warehouseId,cbm.customerId,SUM(qty),SUM(cbm.total_cbm) *cbm.rate, cbm.stockDate FROM
  (SELECT
  ziba.organizationId,
  ziba.warehouseId,
  ziba.customerId,
  ziba.sortirId,
  ziba.sku,
  ziba.qtyEach AS qty,
  IFNULL(BS.`cube`, 0) AS cbm_persku,
  ziba.qtyEach * IFNULL(BS.`cube`, 0) AS total_cbm,
  ziba.stockDate,
  btr.rate
FROM Z_InventoryBalance_preASN ziba
  INNER JOIN Z_SORTIR_INBOUND_HEADER zsih
    ON ziba.organizationId = zsih.organizationId
    AND ziba.warehouseId = zsih.warehouseId
    AND ziba.sortirId = zsih.sortirId
    AND ziba.customerId = zsih.customerId
  INNER JOIN BAS_SKU BS
    ON ziba.organizationId = BS.organizationId
    AND ziba.customerId = BS.customerId
    AND ziba.sku = BS.sku
  INNER JOIN BIL_TARIFF_MASTER btm
    ON ziba.organizationId = btm.organizationId
    AND ziba.customerId = btm.customerId
  INNER JOIN BIL_TARIFF_HEADER bth
    ON bth.organizationId = btm.organizationId
    AND bth.tariffMasterId = btm.tariffMasterId
    AND bth.warehouseId = zsih.warehouseId
  INNER JOIN BIL_TARIFF_DETAILS btd
    ON btd.organizationId = bth.organizationId
    AND btd.tariffId = bth.tariffId
  INNER JOIN BIL_TARIFF_RATE btr
    ON btr.organizationId = btd.organizationId
    AND btr.tariffId = btd.tariffId
    AND btr.tariffLineNo = btd.tariffLineNo
WHERE ziba.organizationId = 'OJV_CML'
AND ziba.warehouseId IN ('CBT02', 'JBK01')
-- AND ziba.customerId IN ('MAP')
AND ziba.stockDate >= DATE(zsih.addTime)
AND ziba.stockDate < DATE(IFNULL(zsih.completedTime, NOW()))
-- AND IFNULL(BS.`cube`,0) = 0;
AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
AND btd.chargeCategory = 'IV'
AND btr.rate > 0
AND bth.tariffMasterId NOT IN ('BIL00062PT')) cbm
GROUP BY cbm.organizationId,cbm.warehouseId,cbm.customerId,cbm.stockDate,cbm.rate
-- AND ziba.sortirId='STR0000001251108'
