SELECT DISTINCT
  zib.customerId AS customerId,
  zib.warehouseId AS warehouseId,
  /* Get domicile based on warehouseId */
  CASE
  WHEN zib.warehouseId IN('BDG01','CBT01','CBT02','MRD01','PAPAYA','SMPR01', 'CBT02-B2C','BTSR01','PLBG01')
    THEN 'JAKARTA'
  WHEN zib.warehouseId IN('KIMSTR','TRKM5')
    THEN 'MEDAN'
  WHEN zib.warehouseId IN('SBYBDR','SBYKK','SBYMM','SBYVTU','SMARTSBY01')
    THEN 'SURABAYA'
  WHEN zib.warehouseId IN('SMG-SO','SMG-TA')
    THEN 'SEMARANG'
  END AS domisili,
  CASE WHEN AC.lotAtt07 IN('O','OPC')
  THEN
    'Own Pallet'
  WHEN AC.lotAtt07 IN('PP','R','RPP','WP')
  THEN
    'Rental Pallet'
  END AS palletType,
  CASE WHEN zib.customerId = 'API'AND AC.lotAtt07 IN('O','OPC')
  THEN
    60000
  WHEN zib.customerId = 'ADS'AND AC.lotAtt07 IN('O','OPC')
  THEN
    59000
  WHEN zib.customerId = 'MAP'AND AC.lotAtt07 IN('O','OPC')
  THEN
    2240
  WHEN zib.customerId = 'PPG' AND AC.lotAtt07 IN('O','OPC')
  THEN
    57000
  WHEN zib.customerId = 'GYVTL' AND AC.lotAtt07 IN('WP')
  THEN
    8000
  WHEN zib.customerId = 'GYVTL' AND AC.lotAtt07 IN('PP')
  THEN
    16000
  WHEN zib.customerId NOT IN('API','ADS','GYVTL','MAP','PPG')
  THEN
    AB.rate
  END AS rate,
  MAX(zib.traceCount) AS maxCount, --Get Maximum Count of Pallet of the Current Period
  -- CASE WHEN zib.customerId = 'API'AND AC.lotAtt07 IN('O','OPC')
  -- THEN
  --   CAST(
  --     CEILING(
  --       (((zib.traceCount* 1.44)/2) + (((zib.traceCount* 1.44)/2)/6.5*0.35*10))*1000000/1000000
  --     ) * 60000 AS STRING
  --   )
  -- WHEN zib.customerId = 'ADS'AND AC.lotAtt07 IN('O','OPC')
  -- THEN
  --   CAST(
  --     (zib.traceCount * 1.44)*59000 AS STRING
  --   )
  -- WHEN zib.customerId = 'MAP'AND AC.lotAtt07 IN('O','OPC')
  -- THEN
  --   CAST(
  --     IFNULL(
  --       SUM(bs.cube * zib.qtyonHand),0
  --     )*2240 AS STRING
  --   )
  -- WHEN zib.customerId = 'PPG' AND AC.lotAtt07 IN('O','OPC')
  -- THEN
  --   CAST(
  --     zib.traceCount*57000 AS STRING
  --   )
  -- WHEN zib.customerId = 'GYVTL' AND AC.lotAtt07 IN('WP')
  -- THEN
  --   CAST(
  --     MAX(zib.traceCount) * 8000 AS STRING
  --   )
  -- WHEN zib.customerId = 'GYVTL' AND AC.lotAtt07 IN('PP')
  -- THEN
  --   CAST(
  --     MAX(zib.traceCount) * 16000 AS STRING
  --   )
  -- WHEN zib.customerId NOT IN('API','ADS','GYVTL','MAP','PPG')
  -- THEN
  --   AB.rate
  -- END AS qtyCharged
  
FROM
  (
    SELECT
      COUNT(DISTINCT zib.traceId) AS traceCount,
      zib.customerId,
      zib.warehouseId,
      zib.sku,
      zib.StockDate,
      zib.qtyonHand,
      zib.lotNum
    FROM
      linc-bi.wms_cml.Z_InventoryBalance zib
    GROUP BY
      zib.customerId,
      zib.warehouseId,
      zib.sku,
      zib.StockDate,
      zib.lotNum,
      zib.qtyonHand
  )zib

LEFT JOIN linc-bi.wms_cml.BAS_SKU bs
ON
  bs.sku = zib.sku
  AND bs.customerId = zib.customerId

LEFT JOIN 
  (SELECT DISTINCT
  bsm.customerId,
  bsm.warehouseId,
  bsm.tariffId
FROM
  linc-bi.wms_cml.BAS_SKU_MULTIWAREHOUSE bsm) AA
ON
  AA.customerId = zib.customerId
  AND AA.warehouseId = zib.warehouseId

LEFT JOIN(
  SELECT DISTINCT
    bth.tariffMasterId AS tariffMasterId,
    btm.customerId AS customerId,
    bth.tariffId AS tariffId,
    btd.chargeCategory AS chargeCategory,
    btd.chargeType AS chargeType,
    bth.effectiveTo AS effectiveTo,
    btd.udf04 AS udf04,
    btr.rate AS rate

  FROM
    linc-bi.wms_cml.BIL_TARIFF_MASTER btm
  LEFT JOIN linc-bi.wms_cml.BAS_CUSTOMER bc
  ON
    bc.customerId = btm.customerId
  LEFT JOIN linc-bi.wms_cml.BIL_TARIFF_HEADER bth
  ON
    bth.tariffMasterId = btm.tariffMasterId
    
  LEFT JOIN linc-bi.wms_cml.BIL_TARIFF_DETAILS btd
  ON
    btd.tariffId = bth.tariffId
  
  LEFT JOIN linc-bi.wms_cml.BIL_TARIFF_RATE btr
  ON
    btr.tariffId = btd.tariffId
    AND btr.tariffLineNo = btd.tariffLineNo

  

  WHERE
  -- 'API','ADS','PPG','MAP','GYVTL' terpisah
    bc.customerId IN('API','ADS','PPG','MAP','GYVTL','LTL','HPK','ITOCHU','GCM','GYI','YFI','BCAFIN','BCA','RBFOOD','FFI','GMC','AGM','GYI','CERESSBY','NLDCSBY','JCISBY','GCMSBY','DNNSBY','HPKSBY','GMCSBY','AID_MDN','GCM_MDN','JJCHI_MDN','PT.ITT_MDN','NLDC','TRINITY','DKJ_SMG','PLB-LTL','ECCOSBY','TMB_SMG','SSISBY','UNZA','SOGOOD_SMG','WON_SMG','PPT_SMG','GMC_SMG','CERESSMG','GMC_SMG')
    AND bc.customerType = 'OW'
    AND btd.chargeCategory = 'IV'
    AND btd.chargeType IN('ST','PL')
  ORDER BY
    bth.effectiveTo DESC
) AB
ON
  AB.customerId = zib.customerId

INNER JOIN (
    SELECT DISTINCT
  illi.customerId,
  illi.warehouseId,
  illi.lotNum,
  illi.sku,
  ila.lotAtt07
FROM
  linc-bi.wms_cml.INV_LOT_LOC_ID illi

LEFT JOIN linc-bi.wms_cml.INV_LOT_ATT ila
ON
  ila.customerId = illi.customerId
  AND ila.lotNum = illi.lotNum

WHERE
  -- 'API','ADS','PPG','MAP','GYVTL' terpisah
    illi.customerId IN('API','ADS','PPG','MAP','GYVTL','LTL','HPK','ITOCHU','GCM','GYI','YFI','BCAFIN','BCA','RBFOOD','FFI','GMC','AGM','GYI','CERESSBY','NLDCSBY','JCISBY','GCMSBY','DNNSBY','HPKSBY','GMCSBY','AID_MDN','GCM_MDN','JJCHI_MDN','PT.ITT_MDN','NLDC','TRINITY','DKJ_SMG','PLB-LTL','ECCOSBY','TMB_SMG','SSISBY','UNZA','SOGOOD_SMG','WON_SMG','PPT_SMG','GMC_SMG','CERESSMG','GMC_SMG')
GROUP BY
  illi.customerId,
  illi.warehouseId,
  illi.lotNum,
  illi.sku,
  ila.lotAtt07
  ) AC
  ON
    AC.customerId = zib.customerId
    AND AC.warehouseId = zib.warehouseId

WHERE
  zib.StockDate BETWEEN CAST(FORMAT_DATE('%Y-%m-', DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)) || '26' AS DATE) AND CAST(FORMAT_DATE('%Y-%m-', CURRENT_DATE()) || '25' AS DATE)
  AND
  -- 'API','ADS','PPG','MAP','GYVTL' terpisah
    zib.customerId IN('API','ADS','PPG','MAP','GYVTL','LTL','HPK','ITOCHU','GCM','GYI','YFI','BCAFIN','BCA','RBFOOD','FFI','GMC','AGM','GYI','CERESSBY','NLDCSBY','JCISBY','GCMSBY','DNNSBY','HPKSBY','GMCSBY','AID_MDN','GCM_MDN','JJCHI_MDN','PT.ITT_MDN','NLDC','TRINITY','DKJ_SMG','PLB-LTL','ECCOSBY','TMB_SMG','SSISBY','UNZA','SOGOOD_SMG','WON_SMG','PPT_SMG','GMC_SMG','CERESSMG','GMC_SMG')
    AND AB.chargeCategory = 'IV'
    AND AB.chargeType IN('ST','PL')
    AND AB.effectiveTo > '2023-04-30'
    AND AC.lotNum = zib.lotNum
    AND AC.lotAtt07 IN('O','OPC','PP','R','RPP','WP')

  GROUP BY
    zib.customerId,
    zib.warehouseId,
    AB.rate,
    AC.lotAtt07