USE WMS_FTEST;

SELECT
  bpd.qty
FROM BAS_SKU bs
  INNER JOIN BAS_SKU_MULTIWAREHOUSE bsm
    ON bs.organizationId = bsm.organizationId
    AND bs.customerId = bsm.customerId
    AND bs.SKU = bsm.SKU
  INNER JOIN BAS_PACKAGE bp
    ON bsm.organizationId = bp.organizationId
    AND bsm.PACKID = bp.PACKID
  INNER JOIN BAS_PACKAGE_DETAILS bpd
    ON bp.organizationId = bpd.organizationId
    AND bp.PACKID = bpd.PACKID
WHERE bsm.organizationId = 'OJV_CML'
AND bsm.warehouseId = 'CBT01'
AND bsm.customerId = 'PPG'
AND bsm.SKU = '00016344'
AND bpd.packUom = 'PL';


SELECT
  *
FROM DOC_APPOINTMENT_DETAILS dad
WHERE dad.warehouseId = 'CBT01'
AND dad.appointmentno = 'OUB200831001';





SELECT
  INVID.locationId,
  INVID.TRACEID,
  INVID.customerId,
  INVID.SKU,
  INVID.qty AS qtystock,
  INVID.muid,
  bpd.qty AS qtypallet,
  ((INVID.qty/bpd.qty) * 100) AS qtypercentage,
  bp.packId
FROM INV_LOT_LOC_ID INVID  -- Alias defined here
  INNER JOIN BAS_SKU bs
    ON (INVID.organizationId = bs.organizationId
    AND INVID.customerId = bs.customerId
    AND INVID.SKU = bs.SKU)
  INNER JOIN BAS_SKU_MULTIWAREHOUSE bsm
    ON (bs.organizationId = bsm.organizationId
    AND bs.customerId = bsm.customerId
    AND bs.SKU = bsm.SKU
    AND INVID.warehouseId = bsm.warehouseId)
  INNER JOIN BAS_PACKAGE bp
    ON bsm.organizationId = bp.organizationId
    AND bsm.PACKID = bp.PACKID
    AND bsm.customerId=bp.customerId
  INNER JOIN BAS_PACKAGE_DETAILS bpd
    ON bp.organizationId = bpd.organizationId
    AND bp.PACKID = bpd.PACKID
    AND bp.customerId=bpd.customerId
WHERE INVID.organizationId = 'OJV_CML'
AND INVID.warehouseId = 'CBT01'
AND bpd.packUom = 'PL'
AND INVID.locationId = 'A01A001B' AND INVID.qty > 0;

SELECT * FROM BAS_LOCATION bl WHERE bl.locationId='PFA-01-01';

SELECT
  locationId,SUM(qty)
FROM INV_LOT_LOC_ID
WHERE organizationId = 'OJV_CML'
AND warehouseId = 'CBT01'
-- AND locationId = 'A01A001B'
AND qty > 0
GROUP BY locationId
HAVING COUNT(DISTINCT TRACEID) > 1;


USE WMS_FTEST;

SET @p_organizationId = 'OJV_CML';
SET @p_warehouseId = 'CBT01';
SET @p_userId = 'UDFTIMER';
SET @p_languageId = 'en';
SET @p_location = 'PFA-01-01';
set @r_returnVal='';
SET @OUT_persentage = '';
CALL Z_CHECKOVERPALLETINLOC(@p_organizationId, @p_warehouseId, @p_userId, @p_languageId, @p_location,@r_returnVal, @OUT_returnCode);
SELECT
 @r_returnVal, @OUT_returnCode;








