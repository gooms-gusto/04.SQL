                                             SELECT 
XY.ChargeCategory,XY.organizationId,XY.warehouseId,XY.customerId,XY.docNo,XY.cntLineDoc,XY.cnt_BList
FROM (
(SELECT HI.ChargeCategory,HI.organizationId,HI.warehouseId,HI.customerId,HI.docNo,HI.cntLineDoc,
BLIST.cnt_BList
FROM (SELECT 'Handling In' AS ChargeCategory,atl.organizationId,atl.warehouseId ,atl.fmcustomerId as customerId,atl.docNo as docNo,
count(atl.transactionId) cntLineDoc
FROM 
wms_cml.ACT_TRANSACTION_LOG atl 
LEFT OUTER JOIN 
wms_cml.DOC_ASN_HEADER dah ON 
atl.organizationId =dah.organizationId 
AND atl.warehouseId =dah.warehouseId 
AND atl.fmcustomerId =dah.customerId 
AND atl.docNo =dah.asnNo 
WHERE atl.organizationId ='OJV_CML'
-- AND (atl.warehouseId,atl.fmcustomerId) in (
-- SELECT warehouseId,customerId FROM wms_cml.Z_BAS_CUSTOMER_CUSTBILLING WHERE organizationId='OJV_CML' AND lotAtt01='STD' AND active='Y') 
AND atl.fmcustomerId in ('ADS',
'API',
'BZI_JKT',
'CAI_MDN',
'CAI_SBY',
'DPW_SBY',
'ECMAMA',
'GCM',
'GMC',
'HJA_JKT',
'HJA_SBY',
'HJA_SMG',
'ITOCHU',
'JCISBY',
'LAI_SMG',
'LAI_SMG',
'LAI_SMG_2',
'LSH_SBY',
'LTL',
'LTL',
'LTL_SMG',
'LTL_SMG',
'MAP',
'MAP',
'MAP',
'MAP',
'ONDULINE',
'PLB-LTL',
'PPG',
'SKU_SBY',
'TUMI',
'TUMI'
)
AND atl.status ='99'
AND atl.transactionType ='IN'
AND atl.addTime >='2025-07-26'
GROUP BY atl.organizationId,atl.warehouseId ,atl.fmcustomerId ,atl.docNo
) HI 
LEFT OUTER JOIN (
SELECT bs.organizationId,bs.warehouseId ,bs.customerId ,bs.docNo ,count(bs.billingSummaryId) cnt_BList
FROM wms_cml.BIL_SUMMARY bs 
WHERE bs.organizationId='OJV_CML'
AND bs.chargeCategory='IB'
AND bs.addTime >='2025-01-01'
GROUP BY 
bs.organizationId,bs.warehouseId ,bs.customerId ,bs.docNo
) BLIST ON 
HI.organizationId = BLIST.organizationId
AND HI.warehouseId = BLIST.warehouseId 
AND HI.customerId = BLIST.customerId 
AND HI.docNo =BLIST.docNo
)
UNION 
(SELECT HO.ChargeCategory,HO.organizationId,HO.warehouseId,HO.customerId,HO.docNo,HO.cntLineDoc,
BLIST.cnt_BList 
FROM (SELECT 'Handling Out' AS ChargeCategory,aad.organizationId,aad.warehouseId ,aad.customerId ,aad.orderNo as docNo,
count(aad.allocationDetailsId) cntLineDoc
FROM 
wms_cml.ACT_ALLOCATION_DETAILS aad 
LEFT OUTER JOIN 
wms_cml.DOC_ORDER_HEADER doh ON 
aad.organizationId =doh.organizationId 
AND aad.warehouseId =doh.warehouseId 
AND aad.customerId =doh.customerId 
AND aad.orderNo =doh.orderNo
AND doh.sostatus='99'
WHERE aad.organizationId ='OJV_CML'
-- AND (aad.warehouseId,aad.customerId) in (
-- SELECT warehouseId,customerId FROM wms_cml.Z_BAS_CUSTOMER_CUSTBILLING WHERE organizationId='OJV_CML' AND lotAtt01='STD' AND active='Y') 
AND aad.customerId in ('ADS',
'API',
'BZI_JKT',
'CAI_MDN',
'CAI_SBY',
'DPW_SBY',
'ECMAMA',
'GCM',
'GMC',
'HJA_JKT',
'HJA_SBY',
'HJA_SMG',
'ITOCHU',
'JCISBY',
'LAI_SMG',
'LAI_SMG',
'LAI_SMG_2',
'LSH_SBY',
'LTL',
'LTL',
'LTL_SMG',
'LTL_SMG',
'MAP',
'MAP',
'MAP',
'MAP',
'ONDULINE',
'PLB-LTL',
'PPG',
'SKU_SBY',
'TUMI',
'TUMI'
)
AND doh.lastShipmentTime >='2025-07-26'
GROUP BY aad.organizationId,aad.warehouseId ,aad.customerId ,aad.orderNo 
) HO 
LEFT OUTER JOIN (
SELECT bs.organizationId,bs.warehouseId ,bs.customerId ,bs.docNo ,count(bs.billingSummaryId) cnt_BList
FROM wms_cml.BIL_SUMMARY bs 
WHERE bs.organizationId='OJV_CML'
AND bs.chargeCategory='OB'
AND bs.addTime >='2025-01-01'
GROUP BY 
bs.organizationId,bs.warehouseId ,bs.customerId ,bs.docNo
) BLIST ON 
HO.organizationId = BLIST.organizationId
AND HO.warehouseId = BLIST.warehouseId 
AND HO.customerId = BLIST.customerId 
AND HO.docNo =BLIST.docNo
)
) XY
WHERE  XY.cntLineDoc<>XY.cnt_BList