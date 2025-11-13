  INSERT INTO Z_InventoryBalance_preASN (
        organizationId,
        warehouseId,
        sortirId,
        sortirLineId,
        customerId,
        palletId,
        ean,
        qtyPallet,
        qtyEach,
        packey,
        sku,
        stockDate,
        status,
        stopCalculateDate,
        noteText,
        udf01,
        udf02,
        udf03,
        udf04,
        udf05,
        currentVersion,
        oprSeqFlag,
        addWho,
        addTime,
        editWho,
        editTime
    )
SELECT
  zsid.organizationId,
        zsid.warehouseId,
        zsid.sortirId,
        zsid.sortirLineId,
        zsid.customerId,
        zsid.palletId,
        zsid.ean,
        zsid.qty,
        (zsid.qty) as qtyEach,
        bsm.packId,
        zsid.sku,
        ADDDATE(DATE('2025-10-25'),INTERVAL 11 DAY) as stockDate,
        '00' as status,
        zsid.closeTime as stopCalculateDate,
        NULL as noteText,
        NULL as udf01,
        NULL as udf02,
        NULL as udf03,
        NULL as udf04,
        NULL as udf05,
        100 as currentVersion,
        2016 as oprSeqFlag,
        'UDFTIMER' as addWho,
        NOW() as addTime,
        NULL as editWho,
        NULL as editTime
  FROM Z_SORTIR_INBOUND_DETAILS zsid  
  INNER JOIN BAS_SKU bs ON zsid.organizationId = bs.organizationId
  AND zsid.customerId = bs.customerId
  AND zsid.sku = bs.sku
  LEFT OUTER JOIN BAS_SKU_MULTIWAREHOUSE bsm
  ON zsid.organizationId = bsm.organizationId
  AND zsid.customerId = bsm.customerId
  AND zsid.sku = bsm.sku
  AND zsid.warehouseId = bsm.warehouseId
  LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpd
  ON zsid.organizationId = bpd.organizationId
  AND bs.organizationId = bpd.organizationId
  AND bsm.packId = bpd.packId
  AND bpd.packUom='PL'
  WHERE zsid.organizationId='OJV_CML'
  AND bsm.warehouseId IN ('CBT02','JBK01')
  AND bpd.customerId='MAP'
  AND DATE(zsid.addTime) < DATE(NOW());



      SELECT * from Z_SORTIR_INBOUND_DETAILS zsid WHERE zsid.organizationId='OJV_CML'  AND zsid.sortirId='KED2510280048';


SELECT * FROM Z_SORTIR_INBOUND_DETAILS WHERE organizationId='OJV_CML' AND sortirId='KED2510280048'

SELECT * FROM Z_SORTIR_INBOUND_HEADER zsih
where organizationId='OJV_CML'
AND warehouseId='CBT02' and customerId='MAP' AND zsih.sortirId='KED2510280048'