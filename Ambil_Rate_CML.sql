SELECT
     --   h1.organizationId                                  ,
        BAC.warehouseId           AS WAREHOUSE_ID                          ,
        BAC.customerId AS CUSTOMER_ID,
  UPPER(BC.customerDescr1) AS CUSTOMER_DESCR,
  bth.contractNo AS CONTRACT_NO,
  bth.effectiveFrom AS EFFECTIVE_FROM,
  bth.effectiveTo AS EFFECTIVE_TO,
        bth.tariffId            AS TARIFF_ID                            ,
        bth.tariffMasterId AS TARIFFMASTERID,
    --    h1.tariffLineNo  AS TARIF_LINE_NO                                  ,
      --  h1.oprSeqFlag                                      ,
       --   t2.codeDescr AS CHARGECATEGORY_NAME                ,
        UPPER(t3.codeDescr) AS CHARGETYPE_NAME                    ,
        UPPER(t4.codeDescr) AS RATEBASE_NAME                      ,
      --  h1.locationCategory                                ,
     --   h1.chargeType                                      ,
   --     h1.minAmount                                       ,
   --     h1.maxAmount                                       ,
     --   h1.freeAmount                                      ,
CONCAT('Rp.', FORMAT(btr.rate,2))   AS RATE,
     --   h1.replaceWith1                                    ,
    --    h1.replaceWith2                                    ,
    --    h1.vasType                                         ,
        h1.docType               AS DOC_TYPE                          ,
    --    h1.billingParty                                    ,
     --   h1.paymentParty                                    ,
     --   h1.namedBilllingParty                              ,
     --   h1.namedPaymentParty                               ,
    --    h1.incomeTaxRate                                   ,
     --   h1.costTaxRate                                     ,
      --  h1.cubicBase                                       ,
   --     h1.InventoryAgingFM                                ,
      --  h1.InventoryAgingTO                                ,
      --  h1.BillingTranCategory                             ,

    --    t5.codeDescr AS REPLACEWITH1_NAME                  ,
     --   t6.codeDescr AS REPLACEWITH2_NAME                  ,
    --    t7.codeDescr AS VASTYPE_NAME                       ,
    --    t8.codeDescr AS CUBICBASE_NAME                     ,
    --    h1.noteText                                        ,
        h1.udf01            AS MATERIALCODE_SAP                               
     --   h1.udf02                                           ,
      --  h1.udf03                                           ,
    --    h1.udf04                                           ,
    --    h1.udf05                                           ,
    --    h1.currentVersion                                  ,
   --     h1.addWho                                          ,
   --     h1.editWho                                         ,
    --    DATE_FORMAT(h1.addTime, '%Y-%m-%d %T')  AS addTime ,
    --    DATE_FORMAT(h1.editTime, '%Y-%m-%d %T') AS editTime,
    --    h1.udf07                                           ,
    --    h1.udf08                                           ,
    --    h1.udf06
FROM
        BIL_TARIFF_DETAILS h1
LEFT JOIN BSM_CODE_ML t2
ON
        h1.chargeCategory     = t2.codeId
        AND h1.organizationId = t2.organizationId
        AND t2.codeType       = 'CHARGE_CATEGORY'
        AND t2.languageId     = 'en'
  LEFT OUTER JOIN BIL_TARIFF_HEADER bth ON
  h1.organizationId=bth.organizationId AND
  h1.warehouseId=bth.warehouseId AND
  h1.tariffId=bth.tariffId 
  LEFT OUTER JOIN BIL_TARIFF_RATE btr ON
  h1.organizationId=btr.organizationId AND
  h1.warehouseId=btr.warehouseId AND
  h1.tariffId=btr.tariffId AND
 h1.tariffLineNo=btr.tariffLineNo
  LEFT OUTER JOIN BAS_CUSTOMER_MULTIWAREHOUSE BAC ON
  bth.organizationId=BAC.organizationId AND
  -- bth.warehouseId = BAC.warehouseId AND
  bth.tariffMasterId=BAC.tariffMasterId
  LEFT OUTER JOIN BAS_CUSTOMER BC ON
  BC.organizationId=BAC.organizationId AND
  BC.customerId=BAC.customerId AND
  BC.customerType='OW'
LEFT JOIN BSM_CODE_ML t3
ON
        h1.chargeType         = t3.codeId
        AND h1.organizationId = t3.organizationId
        AND t3.codeType       = 'CHARGE_TYPE'
        AND t3.languageId     = 'en'
LEFT JOIN BSM_CODE_ML t4
ON
        h1.ratebase           = t4.codeId
        AND h1.organizationId = t4.organizationId
        AND t4.codeType       = 'RAT_BAS'
        AND t4.languageId     = 'en'
LEFT JOIN BSM_CODE_ML t5
ON
        h1.replaceWith1       = t5.codeId
        AND h1.organizationId = t5.organizationId
        AND t5.codeType       = 'CHARGE_TYPE'
        AND t5.languageId     = 'en'
LEFT JOIN BSM_CODE_ML t6
ON
        h1.replaceWith2       = t6.codeId
        AND h1.organizationId = t6.organizationId
        AND t6.codeType       = 'CHARGE_TYPE'
        AND t6.languageId     = 'en'
LEFT JOIN BSM_CODE_ML t7
ON
        h1.vasType            = t7.codeId
        AND h1.organizationId = t7.organizationId
        AND t7.codeType       = 'VAS_TYP'
        AND t7.languageId     = 'en'
LEFT JOIN BSM_CODE_ML t8
ON
        h1.cubicBase          = t8.codeId
        AND h1.organizationId = t8.organizationId
        AND t8.codeType       = 'UOM'
        AND t8.languageId     = 'en'
WHERE
        1                      = 1
        AND h1.tariffLineNo    < 100
        AND h1.organizationId  = 'OJV_CML'
       -- AND h1.warehouseId     =
--  AND h1.tariffId='BIL00133'
        AND h1.chargeCategory <> 'FX'
  -- AND  BAC.warehouseId='CBT01'
  AND    BAC.customerId='DKJ_MDN'

  AND BC.activeFlag='Y' AND bth.effectiveTo > NOW() ORDER BY BAC.customerId,BAC.warehouseId