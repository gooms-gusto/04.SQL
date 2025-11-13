 SELECT
    IFNULL(CAST(dah.organizationId AS char(255)), '') AS organizationId,
    IFNULL(CAST(dah.asnReference1 AS char(255)), '') AS asnReference1,
    IFNULL(CAST(dah.asnReference3 AS char(255)), '') AS asnReference3,
    IFNULL(CAST(dad.skuDescr AS char(255)), '') AS skuDescr1,
    IFNULL(CAST(atl.warehouseId AS char(255)), '') AS warehouseId,
    IFNULL(CAST(atl.tocustomerId AS char(255)), '') AS customerId,
    IFNULL(CAST(atl.docNo AS char(255)), '') AS asnNo,
    IFNULL(CAST(atl.docLineNo AS char(255)), 0) AS asnLineNo,
    IFNULL(CAST(atl.toSku AS char(255)), '') AS sku,
    IFNULL(CAST(atl.toQty AS char(255)), 0) AS qtyReceived,
    IFNULL(CAST(atl.toUom AS char(255)), '') AS uom,
    IFNULL(CAST(atl.toQty_Each AS char(255)), 0) AS qtyReceivedEach,
    IFNULL(CAST(SUM(atl.toQty_Each / bpdEA.qty) AS char(255)), 0) AS qtyChargeEA,
    IFNULL(CAST(SUM(atl.toQty_Each / bpdCS.qty) AS char(255)), 0) AS qtyChargeCS,
    IFNULL(CAST(SUM(atl.toQty_Each / bpdIP.qty) AS char(255)), 0) AS qtyChargeIP,
    IFNULL(CAST(SUM(atl.toQty_Each / bpdPL.qty) AS char(255)), 0) AS qtyChargePL,
    IFNULL(CAST(SUM(atl.toQty_Each * bs.cube) AS char(255)), 0) AS qtyChargeCBM,  
    IFNULL(CAST(COUNT(atl.docNo) AS char(255)), 0) AS qtyChargeTotDO,
    IFNULL(CAST(COUNT(atl.docLineNo) AS char(255)), 0) AS qtyChargeTotLine,
    IFNULL(CAST(SUM( bs.cube) AS char(255)), 0) AS totalCube,
    CAST(DATE_FORMAT(atl.addTime, '%Y-%m-%d') AS char(255)) AS addTime,
    CAST(DATE_FORMAT(atl.editTime, '%Y-%m-%d') AS char(255)) AS editTime,
    CAST(DATE_FORMAT(atl.transactionTime, '%Y-%m-%d') AS char(255)) AS transactionTime,
    IFNULL(CAST(atl.tolotNum AS char(255)), '') AS lotNum,
    IFNULL(CAST(atl.toId AS char(255)), '') AS traceId,
    IFNULL(CAST(atl.tomuid AS char(255)), '') AS muid,
    IFNULL(CAST(atl.toLocation AS char(255)), '') AS toLocation,
    IFNULL(CAST(atl.transactionId AS char(255)), '') AS transactionId,
    IFNULL(CAST(t1.codeid AS char(255)), '') AS docType,
    IFNULL(CAST(t1.codeDescr AS char(255)), '') AS docTypeDescr,
    IFNULL(CAST(bpdCS.packId AS char(255)), '') AS packId,
    IFNULL(CAST(bpdCS.qty AS char(255)), 0) AS QtyPerCases,
    IFNULL(CAST(bpdPL.qty AS char(255)), 0) AS QtyPerPallet,
    IFNULL(CAST(bs.sku_group1 AS char(255)), '') AS sku_group1,
    IFNULL(CAST(bs.grossWeight AS char(255)), 0) AS grossWeight,
    IFNULL(CAST(bs.cube AS char(255)), 0) AS cubeNya,
    IFNULL(CAST(bsm.tariffMasterId AS char(255)), '') AS tariffMasterId,
    IFNULL(CAST(bz.zoneDescr AS char(255)), '') AS zone,
    IFNULL(CAST(ila.lotAtt04 AS char(255)), '') AS batch,
    IFNULL(CAST(ila.lotAtt07 AS char(10)), '') AS lotAtt07,
    IFNULL(CAST(BT.codeid AS char(255)), '') AS billtranctg,
    CASE ila.lotAtt07 WHEN 'O' THEN 'Owner Pallet' WHEN 'R' THEN 'Rental Pallet' WHEN 'PP' THEN 'Rental Plastic Pallet' WHEN 'WP' THEN 'Rental Wooden Pallet' END AS RecType
  FROM ACT_TRANSACTION_LOG atl
    LEFT OUTER JOIN BAS_SKU bs
      ON bs.organizationId = atl.organizationId
      AND bs.customerId = atl.toCustomerId
      AND bs.SKU = atl.toSku
    LEFT OUTER JOIN BAS_SKU_MULTIWAREHOUSE bsm
      ON bsm.organizationId = atl.organizationId
      AND bsm.warehouseId = atl.warehouseId
      AND bsm.customerId = atl.tocustomerId
      AND bsm.SKU = atl.toSku
    LEFT OUTER JOIN DOC_ASN_HEADER dah
      ON dah.organizationId = atl.organizationId
      AND dah.warehouseId = atl.warehouseId
      AND dah.asnNo = atl.docNo
      AND dah.customerId = atl.fmCustomerId
    LEFT OUTER JOIN DOC_ASN_DETAILS dad
      ON dad.organizationId = atl.organizationId
      AND dad.warehouseId = atl.warehouseId
      AND dad.asnNo = atl.docNo
      AND dad.asnLineNo = atl.docLineNo
      AND dad.sku = atl.toSku
    LEFT OUTER JOIN INV_LOT_ATT ila
      ON ila.organizationId = atl.organizationId
      AND ila.SKU = atl.toSku
      AND ila.lotNum = atl.toLotNum
    LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdEA
      ON bpdEA.organizationId = bs.organizationId
      AND bpdEA.packId = bs.packId
      AND bpdEA.customerId = bs.customerId
      AND bpdEA.packUOM = 'EA'
    LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdIP
      ON bpdIP.organizationId = bs.organizationId
      AND bpdIP.packId = bs.packId
      AND bpdIP.customerId = bs.customerId
      AND bpdIP.packUOM = 'IP'
    LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdCS
      ON bpdCS.organizationId = bs.organizationId
      AND bpdCS.packId = bs.packId
      AND bpdCS.customerId = bs.customerId
      AND bpdCS.packUOM = 'CS'
    LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdPL
      ON bpdPL.organizationId = bs.organizationId
      AND bpdPL.packId = bs.packId
      AND bpdPL.customerId = bs.customerId
      AND bpdPL.packUOM = 'PL'
    LEFT JOIN BSM_CODE_ML t1
      ON t1.organizationId = atl.organizationId
      AND t1.codeType = 'ASN_TYP'
      AND dah.asnType = t1.codeId
      AND t1.languageId = 'en'
    LEFT JOIN BSM_CODE BT
      ON BT.organizationId = atl.organizationId
      AND BT.codeType = 'BILLING_TRANSACTION_CATEGORY'
      AND BT.outerCode = ila.lotAtt07
    LEFT JOIN BAS_LOCATION bl
      ON bl.organizationId = atl.organizationId
      AND bl.warehouseId = atl.warehouseId
      AND bl.locationId = atl.tolocation
    LEFT JOIN BAS_ZONE bz
      ON bz.organizationId = bl.organizationId
      AND bz.organizationId = bl.organizationId
      AND bz.warehouseId = bl.warehouseId
      AND bz.zoneId = bl.zoneId
      AND bz.zoneGroup = bl.zoneGroup
  WHERE atl.warehouseId = 'CBT01'
  AND dah.customerId = 'HPK'
  AND dah.asnNo = 'HPK_ASNNO00000000009'
  AND bsm.tariffMasterId = 'BIL00036'
  AND atl.transactionType = 'IN'
  AND dah.asnType NOT IN ('FREE')
  AND atl.STATUS IN ('80', '99')
  AND dah.asnStatus IN ('99')
  GROUP BY atl.docNo,
           atl.docLineNo,
           atl.toCustomerId,
           atl.toSku,
           atl.toQty,
           atl.toQty_Each,
           atl.toUom,
           atl.addTime,
           atl.transactionTime,
           atl.toLotNum,
           atl.toId,
           atl.tomuid,
           atl.toLocation,
           atl.warehouseId,
           atl.tocustomerId,
           atl.transactionId,
           atl.editTime,
           dah.organizationId,
           dah.asnNo,
           dah.asnType,
           dah.asnReference1,
           dah.asnReference3,
           dah.asnReference1,
           dad.SkuDescr,
           bsm.tariffMasterId,
           bs.grossWeight,
           bs.cube,
           bs.sku_group1,
           bz.zoneDescr,
           bpdCS.packId,
           bpdPL.packId,
           bpdCS.qty,
           bpdPL.qty,
           ila.lotAtt04,
           ila.lotAtt07,
           t1.codeid,
           BT.codeid;