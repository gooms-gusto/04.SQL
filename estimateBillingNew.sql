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
    locationCategory,
    btd.UDF05,
    btd.UDF06,
    btd.UDF07,
    btd.UDF08,
    IFNULL(btd.incomeTaxRate, 0) as R_INCOMETAX,
    CASE WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1 ELSE IFNULL(btr.classfrom, 0) END as R_CLASSFROM,
    IFNULL(classTo, 0) AS R_CLASSTO,
    bth.contractNo,
    bth.tariffMasterId,
    btr.cost,
    btd.billingParty,
    STR_TO_DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-',  DAY(bth.billingdate)), '%Y-%m-%d') AS R_BILLINGDATE,
    DATE_FORMAT(DATE_ADD(DATE_ADD(STR_TO_DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-',  DAY(bth.billingdate)), '%Y-%m-%d'), INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d') AS R_OPDATE
    ,DATE_FORMAT(DATE_ADD(STR_TO_DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-',  DAY(bth.billingdate)), '%Y-%m-%d'), INTERVAL -1 MONTH), '%Y-%m-%d') AS R_FMDATE
    ,DATE_FORMAT(DATE_ADD(STR_TO_DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-',  DAY(bth.billingdate)), '%Y-%m-%d'), INTERVAL -1 DAY), '%Y-%m-%d') AS R_TODATE
  
    ,DATEDIFF(DATE_ADD(STR_TO_DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-',  DAY(bth.billingdate)), '%Y-%m-%d'), INTERVAL -1 DAY), DATE_FORMAT(DATE_ADD(STR_TO_DATE(CONCAT(YEAR(CURDATE()), '-', MONTH(CURDATE()), '-',  DAY(bth.billingdate)), '%Y-%m-%d'), INTERVAL -1 MONTH), '%Y-%m-%d')) + 1 AS R_Days
    
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
  WHERE  bsm.warehouseId IN('BDG01','CBT01','CBT02','MRD01','PAPAYA','SMPR01', 'CBT02-B2C','BTSR01','PLBG01')
 AND bsm.customerId IN('ITOCHU')
 -- AND bsm.customerId IN('API','ADS','PPG','MAP','GYVTL','LTL','HPK','ITOCHU','GCM','GYI','YFI','BCAFIN','BCA','RBFOOD','FFI','GMC','AGM','GYI','CERESSBY','NLDCSBY','JCISBY','GCMSBY','DNNSBY','HPKSBY','GMCSBY','AID_MDN','GCM_MDN','JJCHI_MDN','PT.ITT_MDN','NLDC','TRINITY','DKJ_SMG','PLB-LTL','ECCOSBY','TMB_SMG','SSISBY','UNZA','SOGOOD_SMG','WON_SMG','PPT_SMG','GMC_SMG','CERESSMG','GMC_SMG')
  AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  AND btd.chargeCategory = 'IV'
  AND btr.rate > 0
  ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;


