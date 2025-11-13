USE wms_cml;
SELECT 
cus.customerId,crm.OpportunityId FROM BAS_CUSTOMER cus LEFT OUTER JOIN (
SELECT bc.organizationId,bc.customerId,bcm.warehouseId,bc.udf02 AS sap_cust, bc.activeFlag,bch.OpportunityId
FROM 
BAS_CUSTOMER bc  
INNER JOIN BAS_CUSTOMER_MULTIWAREHOUSE bcm
ON bc.organizationId = bcm.organizationId AND bc.customerId = bcm.customerId AND bc.customerType = bcm.customerType
LEFT   JOIN BIL_CRM_HEADER bch ON bc.organizationId = bch.organizationId AND bcm.warehouseId = bch.warehouseId AND bch.CustomerId=bc.udf02
WHERE bc.customerType='OW' AND bc.activeFlag='Y'  
AND date(bch.effectiveFrom) <= date(NOW())
AND date(bch.effectiveTo) >= date(NOW())) crm ON cus.organizationId= crm.organizationId
AND cus.customerId=crm.customerId 
WHERE cus.customerType='OW' AND cus.activeFlag='Y';








SELECT bc.organizationId,bc.customerId,bcm.warehouseId,bc.udf02 AS sap_cust, bc.activeFlag,
( CASE 
FROM 
BAS_CUSTOMER bc  
LEFT JOIN BAS_CUSTOMER_MULTIWAREHOUSE bcm
ON bc.organizationId = bcm.organizationId AND bc.customerId = bcm.customerId AND bc.customerType = bcm.customerType





WHERE bc.customerType='OW' AND bc.activeFlag='Y'  




-- AND date(bch.effectiveFrom) <= date(NOW())
-- AND date(bch.effectiveTo) >= date(NOW())
















SELECT * FROM BIL_CRM_HEADER  bch WHERE bch.customerId='3000007662' AND 
date(bch.effectiveFrom) <= date(NOW())
AND date(bch.effectiveTo) >= date(NOW());

SELECT * FROM BIL_CRM_DETAILS   bch WHERE bch.OpportunityId='0062w00000PAQZtAAP'

USE wms_cml;

UPDATE BIL_CRM_HEADER   set 
warehouseId = 'CBT02'
 WHERE OpportunityId = '0062w00000PAQZtAAP' AND organizationId = 'OJV_CML';




