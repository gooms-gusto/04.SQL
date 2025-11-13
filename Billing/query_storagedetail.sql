SELECT
  DATE_FORMAT(StockDate, '%Y-%m-%d') AS stockDate,
  zib.warehouseId AS warehouseId,
  sm.tariffMasterId,
  sm.tariffId,
  zib.customerId,
  zib.locationId,
  zib.locationCategory,
  lc.codeDescr AS locationCategoryDescr,
  zib.traceId,
  -- CASE WHEN zib.customerId = 'LTL' THEN s.sku_group1 ELSE zib.muid END AS muid, 
  s.sku_group1 AS muidLtl,
  zib.muid AS muid,
  zib.lotNum,
  s.packId,
  UOM,
  zib.sku,
  SKUDesc AS skuDesc,
  la.lotAtt09 AS poNum,
  CASE WHEN la.lotAtt07 = 'R' THEN 'Rental Pallet' WHEN la.lotAtt07 = 'O' THEN 'Own Pallet' ELSE '' END AS typePallet,
  qtyonHand,
  pd.qty AS qtyPerPallet,
  CASE zib.customerid WHEN 'ASP' THEN zib.cube ELSE (zib.cube / 1000000) END AS cbmsku,
  totalCube AS qtycbm,
  CASE WHEN LENGTH(zib.locationId) = 7 THEN SUBSTRING(zib.locationId, 1, 1) WHEN LENGTH(zib.locationId) = 8 THEN SUBSTRING(zib.locationId, 1, 1) WHEN sm.putawayRule = 'LTL09' THEN 'E' WHEN zib.sku IN ('000000001100012851', '000000001100010211', '000000001100000616', '000000001100013296', '000000001100008797', '000000001100012070', '000000001100012068', '000000001100012478', '000000001100012898', '000000001100014515') THEN 'G' WHEN sm.putawayRule IN ('LTL03', 'GMPA-NONDG', 'ICHIKOH-NONDG', 'ITOCHU-NONDG', 'PMM-NONDG', 'LTL06', 'LTL07') THEN 'G' WHEN sm.putawayRule IN ('LTL08', 'ITOCHU-DG', 'PMM-DG', 'LTL01', 'LTL02', 'SMT') THEN 'B' WHEN sm.putawayRule = 'LTL-BULK' THEN 'D' WHEN sm.putawayRule IN ('BAJ', 'PLB-LTL', 'ADF', 'CCDI', 'CTI') THEN 'A' WHEN sm.putawayRule IN ('GYI', 'DKJ') THEN 'J' WHEN sm.putawayRule = 'LTL04' THEN 'B' WHEN sm.putawayRule IN ('DNN', 'PMM', 'ITOCHU') THEN 'C' ELSE l.udf03 END AS chamber,
  sm.putawayRule,
  la.lotAtt04 AS batchNo,
  CASE WHEN zib.customerId = 'PLB-LTL' THEN la.lotAtt10 ELSE la.lotAtt09 END AS ExternalPo -- tl.docNo -- , dah.asnNo, 

FROM Z_InventoryBalance zib
  LEFT JOIN INV_LOT_ATT la
    ON la.organizationId = zib.organizationId
    AND la.customerId = zib.customerId
    AND la.sku = zib.sku
    AND la.lotNum = zib.lotNum
  LEFT JOIN BAS_LOCATION l
    ON l.organizationId = zib.organizationId
    AND l.locationId = zib.locationId
    AND zib.warehouseId = l.warehouseId
  LEFT JOIN BAS_SKU s
    ON s.organizationId = zib.organizationId
    AND s.customerId = zib.customerId
    AND s.sku = zib.sku
  LEFT JOIN BAS_SKU_MULTIWAREHOUSE sm
    ON sm.organizationId = zib.organizationId
    AND sm.customerId = zib.customerId
    AND sm.sku = zib.sku
    AND zib.warehouseId = sm.warehouseId
  LEFT JOIN BAS_PACKAGE_DETAILS pd
    ON s.organizationId = pd.organizationId
    AND s.customerId = pd.customerId
    AND s.packId = pd.packId
    AND packUom = 'PL'
  -- LEFT JOIN TSK_TASKLISTS tl ON tl.organizationId = zib.organizationId AND tl.warehouseId = zib.warehouseId AND tl.customerId = zib.customerId  AND tl.planToLotNum = zib.lotNum AND tl.sku = zib.sku AND tl.planToId = zib.traceId AND taskType='PA' AND taskProcess='99'
  -- LEFT JOIN DOC_ASN_HEADER dah ON tl.organizationId = dah.organizationId AND tl.warehouseId = dah.warehouseId AND tl.docNo = dah.asnNo 
  LEFT JOIN BSM_CODE_ML lc
    ON lc.organizationId = zib.organizationId
    AND zib.locationCategory = lc.codeid
    AND codeType = 'LOC_CAT'
    AND languageId = 'en'

WHERE zib.organizationId = 'OJV_CML'
AND zib.warehouseId = 'CBT02'
AND qtyonHand > 0
AND zib.locationId NOT IN ('LOST_CBT01', 'STG01', 'STG02', 'STG03', 'STG04', 'STG05', 'STG11', 'STG12', 'STG13', 'STG14', 'STG15', 'STG06', 'STG07', 'STG08', 'STG09', 'STG10', 'STG16', 'STG17', 'STG18', 'STG19', 'STG20', 'SORTATIONCBT01', 'SORTATIONCBT02', 'CROSSDOCK_01', 'CROSSDOCK_02', 'SORTATIONLADC01', 'SORTATIONBASF01', 'SORTATION')
AND zib.sku NOT IN (SELECT
    sku
  FROM BAS_SKU bs2
  WHERE organizationId = 'OJV_CML'
  AND customerId = 'AGM'
  AND sku LIKE '13%')
AND zib.customerId = 'AGM'
AND date (StockDate) BETWEEN '2021-10-06' AND '2021-10-06'
AND la.lotAtt09 LIKE '4503636509-9'
AND la.lotAtt09 NOT IN ('4503636509', '4503636509-1', '4503636509-10', '4503636509-11', '4503636509-2', '4503636509-3', '4503636509-5', '4503636509-6', '4503636509-7', '4503636509-8')
-- AND la.lotAtt04 NOT IN ('0000178', '0000030',
-- '0000031',
-- '0000033',
-- '0000054',
-- '0000057',
-- '0000073',
-- '0000079',
-- '0000082',
-- '0000087',
-- '0000089',
-- '0000090',
-- '0000091',
-- '0000092',
-- '0000095',
-- '0000125',
--   '0000165',
-- '0000169',
-- '0000173',
-- '0000175',
-- '0000180',
-- '0000128'
-- )
ORDER BY StockDate DESC, zib.customerId, SKUDesc, la.lotAtt04