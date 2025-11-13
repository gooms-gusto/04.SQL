SELECT * FROM wms_cml.Z_EVENT_ERROR_LOG;


SELECT * FROM  Z_SP_BILLING_LOG ORDER BY addTime  DESC LIMIT 10;

SELECT * from Z_BAS_CUSTOMER_CUSTBILLING where active='Y'  order by seqNo

              
SELECT count(1) FROM  Z_SP_BILLING_LOG WHERE noTrans LIKE '%SAMSO000035486%'


SHOW PROCESSLIST;



SELECT * FROM Z_BAS_CUSTOMER_CUSTBILLING zbcc
INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
ON zbcc.organizationId = zbccd.organizationId
AND zbcc.lotatt01 = zbccd.idGroupSp
WHERE zbcc.organizationId = 'OJV_CML' AND zbccd.lottable03='O';


SELECT zbcc.organizationId,zbcc.warehouseId, zbcc.customerId FROM Z_BAS_CUSTOMER_CUSTBILLING zbcc
INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
ON zbcc.organizationId = zbccd.organizationId
AND zbcc.lotatt01 = zbccd.idGroupSp
WHERE zbcc.organizationId = 'OJV_CML' AND zbccd.lottable03='O'  AND   zbccd.lottable01='1700000049' AND zbccd.spName='CML_COUNT_RENT_PALLET_DAYS';


SELECT zbcc.organizationId,zbcc.warehouseId, zbcc.customerId,zbccd.spName FROM Z_BAS_CUSTOMER_CUSTBILLING zbcc
INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
ON zbcc.organizationId = zbccd.organizationId
AND zbcc.lotatt01 = zbccd.idGroupSp
WHERE zbcc.organizationId = 'OJV_CML' AND zbccd.lottable03='O'  AND   zbccd.lottable01='1700000037' AND zbccd.spName='CML_COUNT_STORAGE_DAYS';





SELECT * FROM Z_BAS_CUSTOMER_CUSTBILLING zbccd WHERE zbccd.customerId='MAP';



UPDATE Z_BAS_CUSTOMER_CUSTBILLING SET lotatt01 = 'PACKETTYPE5' 
WHERE organizationId = 'OJV_CML'
AND warehouseId = 'CBT01' AND customerId = 'ITOCHU';




SELECT  *  FROM Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd ;


SELECT  doh.orderNo as trans_no
FROM DOC_ORDER_HEADER doh 
WHERE doh.organizationId='OJV_CML'
AND doh.warehouseId='CBT02-B2C'
AND doh.customerId ='ECMAMA'
AND doh.orderType IN (
SELECT DISTINCT btd.docType
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
          WHERE bsm.organizationId=doh.organizationId AND bc.customerId=doh.customerId AND bsm.warehouseId=doh.warehouseId
  AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND btd.chargeCategory = 'OB'
)
AND doh.soStatus IN ('99')
AND DATE_FORMAT(doh.addTime,'%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH),'%Y-%m-%d')
 AND doh.orderNo NOT IN (
 SELECT DISTINCT(bs.docNo) FROM BIL_SUMMARY bs
 WHERE bs.organizationId='OJV_CML'
 AND bs.customerId='ECMAMA'
 AND bs.warehouseId='CBT02-B2C' AND bs.chargeCategory='OB' 
 AND  DATE_FORMAT(bs.addTime,'%Y-%m-%d') >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH),'%Y-%m-%d'))