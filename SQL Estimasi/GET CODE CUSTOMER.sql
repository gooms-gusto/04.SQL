SELECT bc.customerDescr1,bc.udf02 
FROM BAS_CUSTOMER bc 
WHERE bc.organizationId='OJV_CML' 
AND bc.activeFlag='Y' 
AND bc.customerType='OW';


