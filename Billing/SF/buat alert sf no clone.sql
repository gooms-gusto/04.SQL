USE wms_cml;
SELECT * FROM BIL_CRM_DETAILS bcd WHERE bcd.OpportunityId='0062w00000PAPDXAA5';


-- SELECT bch.organizationId,bch.warehouseId,bch.OpportunityId,
-- bch.CustomerId FROM BIL_CRM_HEADER bch 
-- WHERE  bch.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d') 
-- AND bch.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
-- GROUP BY   bch.organizationId,bch.warehouseId,bch.OpportunityId


-- customer master active
SELECT bc.customerId,bc.udf02,bcm.warehouseId
FROM 
BAS_CUSTOMER bc
INNER JOIN BAS_CUSTOMER_MULTIWAREHOUSE bcm ON bc.organizationId = bcm.organizationId
AND bc.customerId = bcm.customerId
WHERE bc.customerType='OW' AND bc.customerId  NOT IN ('LINC-OM')
AND bc.activeFlag='Y';

-- check belum ada opty

SELECT CASE WHEN COUNT(bch.OpportunityId) > 0 THEN 'Y' ELSE 'N' END AS RESULT FROM
BIL_CRM_HEADER bch
WHERE bch.warehouseId='CBT02' AND bch.CustomerId=''
AND date(bch.effectiveFrom) <= DATE(NOW())
AND date(bch.effectiveTo) >= DATE(NOW());

SELECT 
-- *
 CASE WHEN COUNT(bth.tariffId) > 0 THEN 'Y' ELSE 'N' END AS RESULT 
FROM BIL_TARIFF_HEADER bth
INNER JOIN BIL_TARIFF_MASTER btm ON bth.organizationId = btm.organizationId
AND bth.tariffMasterId = btm.tariffMasterId
WHERE  date(bth.effectiveFrom) <= DATE(NOW())
AND date(bth.effectiveTo) >= DATE(NOW())
AND btm.customerId='CERESSBY' AND bth.warehouseId='SBYBDR'



UPDATE BIL_TARIFF_HEADER bth 
SET bth.warehouseId='CBT01', bth.editTime=NOW()
WHERE bth.tariffId='BIL00161';


UPDATE BIL_TARIFF_DETAILS btd
SET btd.warehouseId='CBT01', btd.editTime=NOW()
WHERE btd.tariffId='BIL00161';


SELECT * FROM BIL_TARIFF_DETAILS btd WHERE btd.tariffId='BIL00335'