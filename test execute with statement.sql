USE WMS_FTEST;

SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT01';
SET @IN_USERID ='EDI';
SET @IN_Language = 'EN';
SET @IN_CustomerId = 'MAP';
set @IN_asnNo='MAPASN1309230001';
SET @OUT_returnCode = '';
CALL CML_ASNCLOSEBILLAKB(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId,@IN_asnNo,@OUT_returnCode);
SELECT
  @OUT_returnCode;
################################################################
USE WMS_FTEST;

SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT01';
SET @IN_USERID ='EDI';
SET @IN_Language = 'EN';
SET @IN_CustomerId = 'MAP';
set @IN_orderNo='MAP_ORDERNO000000108';
SET @OUT_returnCode = '';
CALL CML_SOCLOSEBILLAKB(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId,@IN_orderNo,@OUT_returnCode);
SELECT
  @OUT_returnCode;



DROP PROCEDURE IF EXISTS tes_execute;

DELIMITER $$

CREATE
PROCEDURE tes_execute ()
BEGIN
  
SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT01';
SET @IN_USERID ='EDI';
SET @IN_Language = 'EN';
SET @IN_CustomerId = 'MAP';
set @IN_asnNo='MAPASN1309230001';
SET @OUT_returnCode = '';

  -- SET @CMD = CONCAT("SELECT customerId, fulfillment_center_id, sku, qtyonHand, qtyallocated, qtyonHold, qtyavailable FROM `Z_InventoryBalance` WHERE StockDate = '",@Date,"' INTO OUTFILE '",@FOLDER,@PREFIX,@EXT,
  SET @CMD = CONCAT("CALL BILL_MOD229(",'"',@IN_organizationId,'"',",",'"', @IN_warehouseId,'"',",",'"', @IN_USERID,'"',",",'"', @IN_Language,'"',",",'"', @IN_CustomerId,'"',",",'"',@IN_asnNo,'"',")");
SELECT
  @OUT_returnCode;
  PREPARE statement FROM @CMD;

  EXECUTE statement;

  DEALLOCATE PREPARE statement;

END
$$

DELIMITER ;


CALL tes_execute ();

SELECT * FROM WMS_FTEST.BIL_TARIFF_DETAILS btd where btd.tariffId='BIL00388'

  SELECT btd.udf09 
  FROM BIL_TARIFF_HEADER bth INNER JOIN BIL_TARIFF_DETAILS btd
  ON bth.organizationId = btd.organizationId AND bth.warehouseId = btd.warehouseId
  AND bth.tariffId=btd.tariffId
  WHERE bth.tariffMasterId='BIL00053' 
  AND TIMESTAMPDIFF(SECOND, bth.effectiveFrom, NOW()) / (60 * 60 * 24) >= 0
  AND TIMESTAMPDIFF(SECOND, bth.effectiveTo, NOW()) / (60 * 60 * 24) <= 0
  AND btd.docType IN (SELECT
      dah.asnType
    FROM DOC_ASN_HEADER dah
    WHERE dah.asnNo = 'MAPASN1309230001');


CALL CML_BILLHOCBMSTD("OJV_CML","CBT01","EDI","EN","MAP","MAPASN1309230001","BIL00053")