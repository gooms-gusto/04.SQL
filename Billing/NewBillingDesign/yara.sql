SELECT
        h1.organizationId           ,
        h1.billingSummaryId         ,
        h1.customerId               ,
        h1.sku                      ,
        h1.lotNum                   ,
        h1.traceId                  ,
        h1.tariffId                 ,
        h1.chargeCategory           ,
        h1.chargeType               ,
        h1.rateBase                 ,
        h1.chargePerUnits           ,
        h1.orderType                ,
        h1.containerType            ,
        h1.containerSize            ,
        h1.manual                   ,
        h1.arLineNo                 ,
        h1.apLineNo                 ,
        IFNULL(h1.arNo, '*') AS arNo,
        IFNULL(h1.apNo, '*') AS apNo,
        h1.qty                      ,
        h1.uom                      ,
        h1.cubic                    ,
        h1.weight                   ,
        h1.chargeRate               ,
        h1.amount                   ,
        h1.docType                  ,
        h1.docNo                    ,
        h1.createTransactionid      ,
        h1.notes                    ,
        h1.billTo                   ,
        h1.oprSeqFlag               ,
        h1.locationCategory         ,
        h1.incomeTax                ,
        h1.cosTax                   ,
        h1.incomeWithoutTax         ,
        h1.cosWithoutTax            ,
        h1.costInvoiceType          ,
        CASE WHEN IFNULL(h1.billingAmount, 0) = 0 THEN IFNULL(h1.amount, 0) ELSE IFNULL(
                        h1.billingAmount, 0) END AS billingAmount,
        CASE                            WHEN h1.docType = 'ASN' THEN b1.asnReference1 WHEN h1.docType = 'SO' THEN
                        b2.soReference1 WHEN h1.docType = 'VAS' THEN b3.kitReference1 END AS
        docReference1                           ,
        h1.followUp                             ,
        h1.invoiceType                          ,
        h1.billingFromDate                      ,
        h1.billingToDate                        ,
        h1.amountPayable                        ,
        h1.amountPaid                           ,
        h1.cost                                 ,
        h1.warehouseId                          ,
        h1.paidTo                               ,
        h1.incomeTaxRate                        ,
        h1.costTaxRate                          ,
        d.lotAtt01                              ,
        d.lotAtt02                              ,
        d.lotAtt03                              ,
        d.lotAtt04                              ,
        d.lotAtt05                              ,
        d.lotAtt06                              ,
        d.lotAtt07                              ,
        d.lotAtt08                              ,
        d.lotAtt09                              ,
        d.lotAtt10                              ,
        d.lotAtt11                              ,
        d.lotAtt12                              ,
        d.lotAtt13                              ,
        d.lotAtt14                              ,
        d.lotAtt15                              ,
        d.lotAtt16                              ,
        d.lotAtt17                              ,
        d.lotAtt18                              ,
        d.lotAtt19                              ,
        d.lotAtt20                              ,
        d.lotAtt21                              ,
        d.lotAtt22                              ,
        d.lotAtt23                              ,
        d.lotAtt24                              ,
        a1.customerDescr1 AS customerIdName     ,
        a2.customerDescr1 AS billtoName         ,
        a3.customerDescr1 AS paidtoName         ,
        b4.skuDescr1      AS skuDescrc          ,
        S2.codeDescr      AS rateBase_Name      ,
        S3.codeDescr      AS chargeCategory_Name,
        (
                CASE WHEN h1.chargeCategory = 'FX' THEN S1.codeDescr ELSE S4.codeDescr END) AS
        chargeType_Name                                    ,
        S5.codeDescr AS docType_Name                       ,
        S6.codeDescr AS locationCategoryName               ,
        b1.asnReference1                                   ,
        FORMAT(h1.amount, 6, '')        AS amountSep       ,
        FORMAT(h1.weight, 5, '')        AS weightSep       ,
        FORMAT(h1.chargeRate, 2, '')    AS chargeRateSep   ,
        FORMAT(h1.billingAmount, 5, '') AS billingAmountSep,
        S7.codeDescr                    AS palletType
FROM
        BIL_SUMMARY h1
LEFT JOIN BAS_CUSTOMER a1
ON
        h1.organizationId   = a1.organizationId
        AND h1.customerId   = a1.customerId
        AND a1.customerType = 'OW'
LEFT JOIN BAS_CUSTOMER a2
ON
        h1.organizationId   = a2.organizationId
        AND h1.billTo       = a2.customerId
        AND a2.customerType = 'BI'
LEFT JOIN BAS_CUSTOMER a3
ON
        h1.organizationId   = a3.organizationId
        AND h1.paidTo       = a3.customerId
        AND a3.customerType = 'BI'
LEFT JOIN BSM_CODE_ML S3
ON
        h1.organizationId     = S3.organizationId
        AND h1.chargeCategory = S3.codeId
        AND S3.codeType       = 'CHARGE_CATEGORY'
        AND S3.languageId     = 'en'
LEFT JOIN BSM_CODE_ML S4
ON
        h1.organizationId = S4.organizationId
        AND h1.chargeType = S4.codeId
        AND S4.codeType   = 'CHARGE_TYPE'
        AND S4.languageId = 'en'
LEFT JOIN BSM_CODE_ML S1
ON
        h1.organizationId     = S1.organizationId
        AND h1.chargeType     = S1.codeId
        AND S1.languageId     = 'en'
        AND h1.chargeCategory = 'FX'
        AND S1.codeType       = 'CHG_CAT_FIX'
LEFT JOIN BSM_CODE_ML S2
ON
        h1.organizationId = S2.organizationId
        AND h1.rateBase   = S2.codeId
        AND S2.codeType   = 'RAT_BAS'
        AND S2.languageId = 'en'
LEFT JOIN BSM_CODE_ML S5
ON
        h1.organizationId = S5.organizationId
        AND h1.docType    = S5.codeId
        AND S5.codeType   = 'DOC_TYP'
        AND S5.languageId = 'en'
LEFT JOIN BSM_CODE_ML S6
ON
        h1.organizationId       = S6.organizationId
        AND h1.locationCategory = S6.codeId
        AND S6.codeType         = 'LOC_CAT'
        AND S6.languageId       = 'en'
LEFT JOIN DOC_ASN_HEADER b1
ON
        h1.organizationId  = b1.organizationId
        AND h1.warehouseId = b1.warehouseId
        AND h1.docType     = 'ASN'
        AND h1.docNo       = b1.asnNo
LEFT JOIN DOC_ORDER_HEADER b2
ON
        h1.organizationId  = b2.organizationId
        AND h1.warehouseId = b2.warehouseId
        AND h1.docType     = 'SO'
        AND h1.docNo       = b2.orderNo
LEFT JOIN DOC_VAS_HEADER b3
ON
        h1.organizationId  = b3.organizationId
        AND h1.warehouseId = b3.warehouseId
        AND h1.docType     = 'VAS'
        AND h1.docNo       = b3.vasNo
LEFT JOIN BAS_SKU b4
ON
        h1.organizationId = b4.organizationId
        AND h1.sku        = b4.sku
        AND h1.customerId = b4.customerId
LEFT JOIN INV_LOT_ATT d
ON
        h1.organizationId = d.organizationId
        AND d.lotNum      = h1.lotNum
LEFT JOIN BSM_CODE_ML S7
ON
        1                     = 1
        AND h1.organizationId = S7.organizationId
        AND S7.languageId     = 'en'
        AND S7.codeType       = 'PLT_TYP'
        AND S7.codeId         = d.lotatt07
WHERE
        h1.organizationId   = 'OJV_CML'
        AND h1.warehouseId IN('BASF01', 'BASF02', 'BDG01', 'CBT01', 'CBT02', 'CBT02-B2C', 'KIMSTAR'
        , 'LADC01', 'LTL-SBY', 'MRD0', 'MRD01', 'MRD02', 'PAPAYA', 'PGD1', 'PGD2', 'PPY', 'SBYBDR',
        'SMARTSBY01', 'SMG-SO', 'SMG-TA', 'SMPR01')
        AND h1.warehouseId = 'CBT01'
        AND 1              = 1
        AND 1              = 1
        AND 1              = 1