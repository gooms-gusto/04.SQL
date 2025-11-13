USE wms_cml;


SELECT SKU,softAllocationRule,allocationRule,oneStepAllocation FROM wms_cml.BAS_SKU WHERE  customerId='API';



UPDATE BAS_SKU SET  softAllocationRule = 'STANDARD',editTime=NOW() WHERE  customerId='ADS';



