USE wms_cml;

SET @InwarehouseId = 'MRD02';
SET @IncustomerId = 'BMM_JKT';
CALL Z_DOUBLEBILLINGINTERNAL(@InwarehouseId, @IncustomerId);



SELECT zbcc.warehouseId,zbcc.customerId
FROM Z_BAS_CUSTOMER_CUSTBILLING zbcc
WHERE zbcc.active='Y'