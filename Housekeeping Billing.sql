USE wms_cml;

SET @InwarehouseId = 'KIMSTR';
SET @IncustomerId = 'ONDULINE';
CALL Z_DOUBLEBILLINGINTERNAL_HI(@InwarehouseId, @IncustomerId);


CALL Z_DOUBLEBILLINGINTERNAL_HO(@InwarehouseId, @IncustomerId);


CALL Z_PENDING_HI_INTERNAL(@InwarehouseId, @IncustomerId);


CALL Z_PENDING_HO_INTERNAL(@InwarehouseId, @IncustomerId);


