USE wms_cml;

INSERT INTO Z_CML_BILLINGSUMMARYID
(
  organizationId
 ,warehouseId
 ,customerId
 ,billingSummaryId
)
SELECT
        h1.organizationId           ,
        h1.warehouseId,
        h1.customerId               ,
        h1.billingSummaryId        
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
LEFT JOIN DOC_TRANSFER_HEADER dth
ON
        dth.organizationId = h1.organizationId
        AND dth.customerId = h1.customerId
        AND dth.warehouseId = h1.warehouseId
        AND dth.tdocNo = h1.docNo
        AND dth.tdocType in ('TBD','TBD1','TBD2','TBD3','TBD4','TBD5','TBD6','TBD7','TBD8','TBD9','TBD10','TBD11','TBD12','TBD13','TBD14')
LEFT JOIN DOC_TRANSFER_DETAILS dtd
ON
         dtd.organizationId = dth.organizationId
         AND dtd.toCustomerId = dth.customerId
         AND dtd.warehouseId = dth.warehouseId
         AND dtd.tdocNo = dth.tdocNo

WHERE
        h1.organizationId       = 'OJV_CML'
        AND h1.warehouseId      = 'CBT02'
        AND h1.customerId=  'MAP'
        AND h1.chargeCategory IN ('OB')
        AND 1                   = 1
AND CONVERT(h1.billingFromDate, DATE) >=CONVERT('2024-12-26', DATE) 
AND CONVERT(h1.billingFromDate, DATE) <=CONVERT('2025-01-25', date);


SELECT * FROM Z_CML_BILLINGSUMMARYID;