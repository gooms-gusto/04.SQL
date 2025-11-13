USE wms_cml;


SELECT
  T1.organizationId,T2.warehouseId,T2.customerId,T1.orderNo,T1.lineTransaksi AS VCOUNTORDER,T2.lineTransaksi AS VCOUNTBILL
FROM (SELECT aad.organizationId,aad.warehouseId,aad.customerId,
    aad.orderNo,
    COUNT(aad.allocationDetailsId) AS lineTransaksi
  FROM ACT_ALLOCATION_DETAILS aad
    INNER JOIN DOC_ORDER_HEADER_UDF dohu
      ON aad.organizationId = dohu.organizationId
      AND aad.warehouseId = dohu.warehouseId
      AND aad.orderNo = dohu.orderNo
    INNER JOIN DOC_ORDER_HEADER doh
      ON aad.organizationId = doh.organizationId
      AND aad.warehouseId = doh.warehouseId
      AND aad.orderNo = doh.orderNo
  WHERE aad.organizationId = 'OJV_CML'
  AND (DATE_FORMAT(dohu.closeTime, '%Y-%m-%d') >= getBillFMDate(26)
  AND DATE_FORMAT(dohu.closeTime, '%Y-%m-%d') <= getBillTODate(26))
  AND aad.customerId IN ('MAP')
  AND aad.warehouseId IN ('CBT02')
  AND doh.soStatus = '99'
  GROUP BY aad.organizationId,
           aad.warehouseId,
           aad.customerId,
           aad.orderNo) T1 
RIGHT JOIN 
(SELECT bs.organizationId,bs.warehouseId,bs.customerId, bs.docNo,COUNT(bs.billingSummaryId) AS lineTransaksi FROM BIL_SUMMARY bs
WHERE bs.organizationId='OJV_CML' AND bs.warehouseId='CBT02' AND bs.customerId='MAP' AND bs.chargeCategory='OB'
AND DATE_FORMAT(billingFromDate,'%Y-%m-%d')>=getBillFMDate(26) AND
DATE_FORMAT(billingFromDate,'%Y-%m-%d')<=getBillTODate(26)
GROUP BY bs.organizationId,bs.warehouseId,bs.customerId,bs.docNo) T2 ON (T1.organizationId=T2.organizationId
AND T1.warehouseId=T2.warehouseId AND T1.customerId= T2.customerId AND T1.orderNo=T2.docNo)
WHERE T1.lineTransaksi <> T2.lineTransaksi;








 SELECT getBillFMDate(26),getBillTODate(26);









SELECT
  *
FROM DOC_ORDER_HEADER
WHERE DATE_FORMAT(Edittime, '%Y-%m-%d') >= getBillFMDate(26)
AND DATE_FORMAT(Edittime, '%Y-%m-%d') >= getBillTODate(26)
AND soStatus = '99'