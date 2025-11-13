USE wms_cml;

SELECT 
warehouseid,salesarea,
CASE WHEN MAX(divcode) IS NULL THEN '62' ELSE MAX(divcode) END  AS divcode,
sapcustomerid,
sum(billingamount) AS billingamount,YEAR(NOW()) AS YearPeriod, MONTH(NOW()) AS MonthPeriod
FROM ZV_BILLING_DATA
WHERE (DATE_FORMAT(DATE(billingfromdate),'%Y-%m-%d') >= getBillFMDate(26)
 AND DATE_FORMAT(DATE(billingfromdate),'%Y-%m-%d') <=  getBillTODate(26)) AND chargecategory <> 'IV'
  AND sapcustomerid NOT IN('3000000733','3000000735','3000016576','3000005193') AND (sapcustomerid NOT IN('8000000010') AND warehouseid NOT IN ('SBYMM'))
GROUP BY 
warehouseid,salesarea,sapcustomerid;


SELECT bc.udf02,
SUM(bs.billingAmount),bth.tariffMasterId
FROM BIL_SUMMARY bs INNER JOIN BAS_CUSTOMER bc
ON bs.organizationId = bc.organizationId
AND bs.customerId = bc.customerId
INNER JOIN BIL_TARIFF_HEADER bth ON bs.organizationId = bth.organizationId
AND bc.organizationId = bth.organizationId
AND bs.warehouseId = bth.warehouseId
AND bs.tariffId = bth.tariffId 
 WHERE bs.organizationId='OJV_CML' AND (DATE_FORMAT(date(bs.billingfromdate),'%Y-%m-%d') >= getBillFMDate(26)
 AND DATE_FORMAT(date(bs.billingfromdate),'%Y-%m-%d') <=  getBillTODate(26)) AND bs.chargecategory <> 'IV'
 AND bc.customerType='OW'
 AND bc.activeFlag='Y'
 AND bc.udf02 NOT IN ('8000000010')
 AND bs.warehouseid NOT IN ('SBYMM')
 GROUP BY 
bs.warehouseid,bc.udf02,bth.tariffMasterId;


SELECT * FROM BAS_CUSTOMER bc
WHERE bc.udf02 IN ('3000025561') AND bc.customerType='OW';


-- NON GROUP BY
SELECT bs.warehouseId,bc.udf02,
SUM(bs.billingAmount),bs.tariffId,bs.chargeType
FROM BIL_SUMMARY bs INNER JOIN BAS_CUSTOMER bc
ON bs.organizationId = bc.organizationId
AND bs.customerId = bc.customerId
LEFT JOIN BIL_TARIFF_HEADER bth ON bs.organizationId = bth.organizationId
AND bs.tariffId = bth.tariffId
LEFT JOIN BIL_TARIFF_MASTER btm ON bs.organizationId = btm.organizationId
AND bth.tariffMasterId=btm.tariffMasterId
 WHERE bs.organizationId='OJV_CML' AND (DATE_FORMAT(date(bs.billingfromdate),'%Y-%m-%d') >= getBillFMDate(26)
 AND DATE_FORMAT(date(bs.billingfromdate),'%Y-%m-%d') <=  getBillTODate(26)) AND bs.chargecategory <> 'IV'
 AND bc.customerType='OW'
 AND bc.activeFlag='Y'
--  AND bc.udf02='3000007550'
--  AND bs.warehouseid  IN ('SMG-TA')
  AND bc.udf02 NOT IN ('8000000010')
  AND bs.warehouseid NOT IN ('SBYMM','BASF02','BASF01')
 AND bs.customerId NOT LIKE 'IDC%'
 AND bs.customerId NOT LIKE 'PKT%'
 GROUP BY bs.warehouseid,bc.udf02,bs.tariffId,bs.chargeType;


-- GROUP BY
SELECT bs.warehouseId,
bw.udf02 AS salesarea,
btm.udf01 AS divcode,
bc.udf02 AS sapcustomerid,
SUM(bs.billingAmount) AS billingAmount,

CASE WHEN btm.udf02='25' THEN 
DATE_FORMAT(date(getBillTODate_MINONEDAY(26)),'%m')
ELSE
DATE_FORMAT(date(getBillTODate_MINONEDAY(26)),'%m') END AS MonthPeriod,
CASE WHEN btm.udf02='25' THEN 
DATE_FORMAT(date(getBillTODate_MINONEDAY(26)),'%Y')
ELSE
DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y')
END AS YearPeriod
FROM BIL_SUMMARY bs INNER JOIN BAS_CUSTOMER bc
ON bs.organizationId = bc.organizationId
AND bs.customerId = bc.customerId
LEFT JOIN BIL_TARIFF_HEADER bth ON bs.organizationId = bth.organizationId
AND bs.tariffId = bth.tariffId
LEFT JOIN BIL_TARIFF_MASTER btm ON bs.organizationId = btm.organizationId
AND bth.tariffMasterId=btm.tariffMasterId
LEFT JOIN BSM_WAREHOUSE bw ON bs.organizationId = bw.organizationId AND bs.warehouseId = bw.warehouseId
 WHERE bs.organizationId='OJV_CML' AND 
 CASE WHEN btm.udf02='25' THEN 
 (DATE_FORMAT(date(bs.billingfromdate),'%Y-%m-%d') >= getBillFMDate_MINONEDAY(26)
 AND DATE_FORMAT(date(bs.billingfromdate),'%Y-%m-%d') <=  getBillTODate_MINONEDAY(26))
 ELSE
 (DATE_FORMAT(date(bs.billingfromdate),'%Y-%m-%d') >=DATE_FORMAT(date(bs.billingfromdate),'%Y-%m-01')
 AND DATE_FORMAT(date(bs.billingfromdate),'%Y-%m-%d') <=  DATE_FORMAT(LAST_DAY(CURDATE()),'%Y-%m-%d'))
 END
 AND bs.chargecategory <> 'IV'
 AND bc.customerType='OW'
 AND bc.activeFlag='Y'
--  AND bc.udf02='3000007550'
--  AND bs.warehouseid  IN ('SMG-TA')
  AND bc.udf02 NOT IN ('8000000010')
  AND btm.udf02='25'
  AND bs.warehouseid NOT IN ('SBYMM','BASF02','BASF01')
 AND bs.customerId NOT LIKE 'IDC%'
 AND bs.customerId NOT LIKE 'PKT%'
 GROUP BY bs.warehouseid,bw.udf02,btm.udf01,bc.udf02;




USE wms_cml;

UPDATE BIL_TARIFF_MASTER SET udf02 = '01', editTime=NOW()
WHERE organizationId = 'OJV_CML' AND 
customerId  IN ('BASF01','BASF02','MDS','ARCHROMA');


 SELECT getBillTODate(26);
 SELECT DATE_ADD(CURDATE(),INTERVAL -1 DAY)

SELECT DATE_FORMAT(date(getBillTODate(26)),'%m')


SELECT getBillTODate_MINONEDAY(26),getBillFMDate_MINONEDAY(26)

