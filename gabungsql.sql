 SELECT DISTINCT
    bsm.organizationId,
    bsm.warehouseId,
    bsm.CUSTOMERID,
    DAY(bth.billingdate) as R_BILLINGDAY,
    btr.tariffId AS R_TARIFFID,
    btr.tariffLineNo AS R_TARIFFLINENO,
    btr.tariffClassNo AS R_TARIFFCLASSNO,
    btd.chargeCategory,
    btd.chargeType,
    btd.descrC,
    btd.ratebase AS R_ratebase,
    btr.ratePerUnit AS R_ratePerUnit,
    btr.rate AS R_rate,
    btd.minAmount as R_minAmount,
    btd.maxAmount as R_maxAmount,
    IF(btd.UDF03 = '', 0, btd.UDF03) R_minQty,
    btd.UDF01 AS MaterialNo,
    btd.udf02 AS itemChargeCategory,
    btd.udf04 AS R_billMode,
    IFNULL(btd.incomeTaxRate, 0) as R_INCOMETAX,
    CASE WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1 ELSE IFNULL(btr.classfrom, 0) END as R_CLASSFROM,
    IFNULL(classTo, 0) AS R_CLASSTO,
    bth.contractNo,
    bth.tariffMasterId,
    btr.cost,
    btd.billingParty,
    STR_TO_DATE(CONCAT(CAST(EXTRACT(YEAR FROM DATE (CURRENT_DATE())) AS STRING), '-', CAST(EXTRACT(MONTH FROM DATE (CURRENT_DATE())) AS STRING), '-',  DAY(bth.billingdate)), '%Y-%m-%d') AS R_BILLINGDATE,
    FORMAT_DATE('%Y-%m-%d',DATE_ADD(DATE_ADD(STR_TO_DATE(CONCAT(CAST(EXTRACT(YEAR FROM DATE (CURRENT_DATE())) AS STRING), '-', CAST(EXTRACT(MONTH FROM DATE (CURRENT_DATE())) AS STRING), '-',  DAY(bth.billingdate))), INTERVAL -1 MONTH), INTERVAL -1 DAY)) AS R_OPDATE
    ,FORMAT_DATE('%Y-%m-%d',DATE_ADD(STR_TO_DATE(CONCAT(CAST(EXTRACT(YEAR FROM DATE (CURRENT_DATE())) AS STRING), '-', CAST(EXTRACT(MONTH FROM DATE (CURRENT_DATE())) AS STRING), '-',  DAY(bth.billingdate)), '%Y-%m-%d'), INTERVAL -1 MONTH)) AS R_FMDATE
    ,FORMAT_DATE('%Y-%m-%d',DATE_ADD(STR_TO_DATE(CONCAT(CAST(EXTRACT(YEAR FROM DATE (CURRENT_DATE())) AS STRING), '-', CAST(EXTRACT(MONTH FROM DATE (CURRENT_DATE())) AS STRING), '-',  DAY(bth.billingdate)), '%Y-%m-%d'), INTERVAL -1 DAY)) AS R_TODATE
  
    ,DATEDIFF(DATE_ADD(STR_TO_DATE(CONCAT(CAST(EXTRACT(YEAR FROM DATE (CURRENT_DATE())) AS STRING), '-', CAST(EXTRACT(MONTH FROM DATE (CURRENT_DATE())) AS STRING), '-',  CAST(EXTRACT(DAY FROM DATE (bth.billingdate)) AS STRING)), '%Y-%m-%d'), INTERVAL -1 DAY), FORMAT_DATE( '%Y-%m-%d',DATE_ADD(STR_TO_DATE(CONCAT(CAST(EXTRACT(YEAR FROM DATE (CURRENT_DATE())) AS STRING), '-', CAST(EXTRACT(MONTH FROM DATE (CURRENT_DATE())) AS STRING), '-',  DAY(bth.billingdate))), INTERVAL -1 MONTH), '%Y-%m-%d')) + 1 AS R_Days
    ,MAX(tbs.qtytrace) AS totaltraceid
  ,MAX(tbs.qtytrace) * btr.rate AS estimatecost
    FROM linc-bi.wms_cml.BAS_SKU_MULTIWAREHOUSE bsm
    INNER JOIN linc-bi.wms_cml.BAS_CUSTOMER bc
      ON bc.customerId = bsm.customerId
      AND bc.organizationId = bsm.organizationId
      AND bc.CustomerType = 'OW'
    INNER JOIN linc-bi.wms_cml.BIL_TARIFF_HEADER bth
      ON bth.organizationId = bsm.organizationId
      AND bth.tariffMasterId = bsm.tariffMasterId
    INNER JOIN linc-bi.wms_cml.BIL_TARIFF_DETAILS btd
      ON btd.organizationId = bth.organizationId
      AND btd.tariffId = bth.tariffId
    INNER JOIN linc-bi.wms_cml.BIL_TARIFF_RATE btr
      ON btr.organizationId = btd.organizationId
      AND btr.tariffId = btd.tariffId
      AND btr.tariffLineNo = btd.tariffLineNo
INNER JOIN (
    SELECT
                zib.organizationId,
                zib.warehouseId,
                zib.StockDate,
                zib.customerId,
                COUNT(DISTINCT zib.locationId) AS qtyloc,
                COUNT(DISTINCT zib.traceId) AS qtytrace,
                COUNT(DISTINCT zib.muid) AS qtymuid,
                SUM(zib.totalCube)
              FROM linc-bi.wms_cml.Z_InventoryBalance zib
                INNER JOIN linc-bi.wms_cml.INV_LOT_ATT ila
                  ON ila.organizationId = zib.organizationId
                  AND ila.lotNum = zib.LotNum
                INNER JOIN linc-bi.wms_cml.BAS_LOCATION bl
                  ON bl.organizationId = zib.organizationId
                  AND bl.warehouseId = zib.warehouseId
                  AND bl.locationId = zib.locationId
                INNER JOIN linc-bi.wms_cml.BAS_SKU_MULTIWAREHOUSE bsm
                  ON bsm.organizationId = zib.organizationId
                  AND bsm.warehouseId = zib.warehouseId
                  AND bsm.customerId = zib.customerId
                  AND bsm.SKU = zib.sku
      WHERE zib.customerId IN ('ITOCHU','YFI') 
      
   GROUP BY zib.organizationId,
                       zib.warehouseId,
                       zib.StockDate,
                       zib.customerId
  )tbs ON (tbs.organizationId=bsm.organizationId AND tbs.warehouseId=bsm.warehouseId AND tbs.customerId=bsm.customerId
  AND tbs.StockDate >= FORMAT_DATE( '%Y-%m-%d',DATE_ADD(PARSE_DATE('%Y-%m-%d',(CONCAT(CAST(EXTRACT(YEAR FROM DATE (CURRENT_DATE())) AS STRING), '-', CAST(EXTRACT(MONTH FROM DATE (CURRENT_DATE())) AS STRING), '-',  CAST(EXTRACT(DAY FROM DATE (bth.billingdate)) AS STRING)))), INTERVAL -1 MONTH))
  AND tbs.StockDate <= FORMAT_DATE( '%Y-%m-%d',DATE_ADD(PARSE_DATE('%Y-%m-%d',(CONCAT(CAST(EXTRACT(YEAR FROM DATE (CURRENT_DATE())) AS STRING), '-', CAST(EXTRACT(MONTH FROM DATE (CURRENT_DATE())) AS STRING), '-',   CAST(EXTRACT(DAY FROM DATE (bth.billingdate)) AS STRING)))), INTERVAL -1 DAY))
    )

  WHERE  bsm.warehouseId IN('CBT01')
 AND bsm.customerId IN('ITOCHU','YFI')
 -- AND bsm.customerId IN('API','ADS','PPG','MAP','GYVTL','LTL','HPK','ITOCHU','GCM','GYI','YFI','BCAFIN','BCA','RBFOOD','FFI','GMC','AGM','GYI','CERESSBY','NLDCSBY','JCISBY','GCMSBY','DNNSBY','HPKSBY','GMCSBY','AID_MDN','GCM_MDN','JJCHI_MDN','PT.ITT_MDN','NLDC','TRINITY','DKJ_SMG','PLB-LTL','ECCOSBY','TMB_SMG','SSISBY','UNZA','SOGOOD_SMG','WON_SMG','PPT_SMG','GMC_SMG','CERESSMG','GMC_SMG')
  AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
   AND btd.chargeCategory = 'IV'
  AND btr.rate > 0
  AND  btd.chargeType = 'ST'
  GROUP BY
  bsm.organizationId,
    bsm.warehouseId,
    bsm.CUSTOMERID,
  --  DAY(bth.billingdate) as R_BILLINGDAY,
    btr.tariffId ,
    btr.tariffLineNo ,
    btr.tariffClassNo ,
    btd.chargeCategory,
    btd.chargeType,
    btd.descrC,
    btd.ratebase ,
    btr.ratePerUnit,
    btr.rate ,
    btd.minAmount ,
    btd.maxAmount ,
    -- IF(btd.UDF03 = '', 0, btd.UDF03) R_minQty,
    btd.UDF01,
    btd.udf02 ,
    btd.udf04,
    locationCategory,
    btd.UDF05,
    btd.UDF06,
    btd.UDF07,
    btd.UDF08,
  --  IFNULL(btd.incomeTaxRate, 0) as R_INCOMETAX,
  --  CASE WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1 ELSE IFNULL(btr.classfrom, 0) END as R_CLASSFROM,
  --  IFNULL(classTo, 0) AS R_CLASSTO,
    bth.contractNo,
    bth.tariffMasterId,
    btr.cost,
    btd.billingParty
  ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;