SELECT
        h1.docType                                                                               ,
        h1.docNo                                                                                 ,
        h1.fmSku                                                                                 ,
        h1.fmQty                                                                                 ,
        h2.lotAtt04                                                                                      ,
        h2.lotAtt09
  -- ,h1.fmQty_Each
FROM
        ACT_TRANSACTION_LOG h1
LEFT JOIN BSM_CODE_ML l1
ON
        h1.organizationId      = l1.organizationId
        AND l1.languageId      = 'en'
        AND l1.codeType        = 'TRN_TYP'
        AND h1.transactionType = l1.codeId
LEFT JOIN BSM_CODE_ML l2
ON
        h1.organizationId = l2.organizationId
        AND l2.languageId = 'en'
        AND l2.codeType   = 'TRN_STS'
        AND h1.status     = l2.codeId
LEFT JOIN BSM_CODE_ML l3
ON
        h1.organizationId = l3.organizationId
        AND l3.languageId = 'en'
        AND l3.codeType   = 'DOC_TYP'
        AND h1.docType    = l3.codeId
LEFT JOIN INV_LOT_ATT h2
ON
        h1.organizationId   = h2.organizationId
        AND h1.fmCustomerId = h2.customerId
        AND h1.fmLotnum     = h2.lotNum
LEFT JOIN INV_LOT_ATT h4
ON
        h1.organizationId   = h4.organizationId
        AND h1.toCustomerId = h4.customerId
        AND h1.toLotnum     = h4.lotNum
LEFT JOIN BAS_SKU h3
ON
        h1.organizationId   = h3.organizationId
        AND h1.fmSku        = h3.sku
        AND h1.fmCustomerId = h3.customerId
WHERE
        1                     = 1
        AND h1.organizationId = 'OJV_CML'
        AND
        (
                h1.warehouseId   IN('BASF01', 'BASF02', 'CBT01', 'CBT02', 'LADC01', 'SMARTSBY01')
                OR h1.warehouseId = '*'
        )
        AND
        (
                h1.fmCustomerId IN('ADF', 'ADS', 'AGM', 'ANP', 'API', 'ASP', 'BAJ', 'BASF01',
                'BASF01_TEST', 'BASF02', 'BASF02PROD', 'BCA', 'BCAFIN', 'CCDI', 'CML', 'CTI', 'DCH'
                , 'DKJ', 'DKJ-SBY', 'DNN', 'EPFI', 'GBP', 'GCM', 'GMPA', 'GYI', 'HPK', 'ICHIKOH',
                'ITOCHU', 'JKPI', 'LINC-FA', 'LINC-OM', 'LTL', 'LTL SBY', 'LTL SMG', 'MAP',
                'PLB-LTL', 'PMM', 'SCI', 'SJI', 'SMARTSBY', 'SMT', 'TNS', 'UEI', 'YFI', 'ZAP')
                OR h1.fmCustomerId  = ''
                OR h1.fmCustomerId IS NULL
        )
        AND
        (
                h1.toCustomerId IN('ADF', 'ADS', 'AGM', 'ANP', 'API', 'ASP', 'BAJ', 'BASF01',
                'BASF01_TEST', 'BASF02', 'BASF02PROD', 'BCA', 'BCAFIN', 'CCDI', 'CML', 'CTI', 'DCH'
                , 'DKJ', 'DKJ-SBY', 'DNN', 'EPFI', 'GBP', 'GCM', 'GMPA', 'GYI', 'HPK', 'ICHIKOH',
                'ITOCHU', 'JKPI', 'LINC-FA', 'LINC-OM', 'LTL', 'LTL SBY', 'LTL SMG', 'MAP',
                'PLB-LTL', 'PMM', 'SCI', 'SJI', 'SMARTSBY', 'SMT', 'TNS', 'UEI', 'YFI', 'ZAP')
                OR h1.toCustomerId  = ''
                OR h1.toCustomerId IS NULL
        )
  AND h1.docNo IN ('SOAGM211008001',
'SOAGM211008002',
'SOAGM211008003') AND h1.transactionType='SO'; 




  