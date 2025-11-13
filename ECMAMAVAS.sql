
SELECT trans.organizationId,trans.warehouseId,trans.customerId, trans.tdocNo,trans.tdocType,trans.qtyCSAll,bil.tariffLineNo,bil.tariffMasterId,bil.tariffId,btr.tariffClassNo,btr.classFrom,
 btr.classTo,btr.rate FROM
(SELECT dth.organizationId,dth.customerId, dth.warehouseId, dtd.tdocNo, SUM(dtd.fmQty / bp.qty) AS qtyCSAll, dth.tdocType, bsm.tariffMasterId
FROM DOC_TRANSFER_HEADER dth
     INNER JOIN
     DOC_TRANSFER_DETAILS dtd
     ON (dth.organizationId = dtd.organizationId AND
       dth.warehouseId = dtd.warehouseId AND
       dth.tdocNo = dtd.tdocNo)
     INNER JOIN
     Z_BAS_CUSTOMER_CUSTBILLING zbcc
     ON (dth.organizationId = zbcc.organizationId AND
       dth.warehouseId = zbcc.warehouseId AND
       dth.customerId = zbcc.customerId)
     INNER JOIN
     Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
     ON (zbcc.organizationId = zbccd.organizationId AND
       zbcc.lotatt01 = zbccd.idGroupSp)
     INNER JOIN
     BAS_SKU_MULTIWAREHOUSE bsm
     ON bsm.organizationId = dtd.organizationId AND
       bsm.warehouseId = dtd.warehouseId AND
       bsm.customerId = dtd.fmCustomerId AND
       bsm.SKU = dtd.fmSku
     INNER JOIN
     BAS_PACKAGE_DETAILS bp
     ON dth.organizationId = bp.organizationId AND
       bsm.packId = bp.packId AND
       dth.customerId = bp.customerId AND
       packUom = 'CS'
WHERE dth.organizationId = 'OJV_CML' AND
      dth.warehouseId = 'CBT02-B2C' AND
      dth.customerId = 'ECMAMA' AND
      dth.tdocNo = '001822'  AND
     zbcc.lotatt01 <> '' AND
     zbcc.active = 'Y' AND
     zbccd.active = 'Y' AND
     zbccd.spName = 'CML_BILLTRFBAGGINGSTD' AND
     dth.status = '99' AND
     dtd.tdocLineStatus = '99' AND
     DATE(dth.editTime) >= getBillFMDate(25)
GROUP BY bp.organizationId, bsm.warehouseId, dtd.tdocNo, bsm.tariffMasterId) trans
INNER JOIN (SELECT
            btd.organizationId,
            btd.warehouseId,
            bth.tariffMasterId,
            btd.tariffId,
            btd.tariffLineNo,
            btd.chargeCategory,
            btd.chargeType,
            btd.vasType,
            btd.udf01,
            btd.udf06
          FROM BIL_TARIFF_HEADER bth
            LEFT JOIN BIL_TARIFF_DETAILS btd
              ON btd.organizationId = bth.organizationId
              AND btd.tariffId = bth.tariffId
          WHERE btd.organizationId = 'OJV_CML'
          AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
          AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
          AND btd.chargeCategory = 'TD'
          AND btd.udf01 IN ('1700000008')
          AND btd.tariffLineNo > 100
          GROUP BY btd.organizationId,
                   btd.warehouseId,
                   btd.tariffId,
                   btd.chargeCategory,
                   btd.chargeType, btd.tariffLineNo,
                   btd.vasType,
                   btd.udf01,
                   btd.UDF06) bil 
                   ON bil.organizationId=trans.organizationId
                   AND bil.warehouseId = trans.warehouseId
                   AND bil.tariffMasterId = trans.tariffMasterId
                  AND bil.chargeType=trans.tdocType
  INNER JOIN  BIL_TARIFF_RATE btr 
  ON bil.organizationId=btr.organizationId
  AND bil.warehouseId=btr.warehouseId
  AND bil.tariffId=btr.tariffId 
  AND bil.tariffLineNo = btr.tariffLineNo
  WHERE trans.organizationId='OJV_CML'
  AND trans.warehouseId='CBT02-B2C'
  AND trans.customerId='ECMAMA'
  AND trans.qtyCSAll BETWEEN btr.classFrom AND btr.classTo;


-- SELECT * FROM BIL_TARIFF_RATE btr WHERE btr.organizationId='OJV_CML' AND btr.tariffId='BIL01081' AND btr.tariffLineNo='104';
 
 -- SELECT getBillFMDate(1);

 -- SELECT getBillTODate(30);
  