


SELECT DISTINCT
    IFNULL(CAST(dah.organizationId AS char(255)), '') AS organizationId,
    IFNULL(CAST(atl.warehouseId AS char(255)), '') AS warehouseId,
    IFNULL(CAST(atl.tocustomerId AS char(255)), '') AS customerId,
    IFNULL(CAST(atl.docNo AS char(255)), '') AS asnNo,
    IFNULL(CAST(atl.toSku AS char(255)), '') AS sku,
    IFNULL(CAST(bsm.tariffMasterId AS char(255)), '') AS tariffMasterId
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
  WHERE atl.warehouseId = 'CBT01'
  AND dah.customerId = 'MAP'
  AND dah.asnNo='MAPASN1309230001'
  -- AND bsm.tariffMasterId NOT LIKE '%PIECES'
  AND atl.transactionType = 'IN'
  AND dah.asnType NOT IN ('FREE')
  AND atl.STATUS IN ('80', '99')
  AND dah.asnStatus IN ('99')
  AND bs.skuDescr1 NOT LIKE '%PALLET%'
  