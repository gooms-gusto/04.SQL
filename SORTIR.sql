SELECT * FROM wms_cml.Z_SORTIR_INBOUND_DETAILS;

SELECT sku,skuDescr1,alternate_sku1,alternate_sku2 FROM BAS_SKU 
where organizationId='OJV_CML'
AND customerId='MAP' AND alternate_sku1 <> '' limit 10;


SELECT 
    sku,
    skuDescr1
FROM BAS_SKU
WHERE organizationId = 'OJV_CML'
AND customerId = 'MAP'
AND activeFlag = 'Y'
AND (
    alternate_sku1 = '5414476034684'
    OR alternate_sku2 = '  '
    OR alternate_sku3 = '5414476034684'
    OR alternate_sku4 = '5414476034684'
    OR alternate_sku5 = '5414476034684'
);


SELECT COUNT(1) FROM Z_SORTIR_INBOUND_DETAILS zsid WHERE zsid.organizationId='OJV_CML'
AND zsid.warehouseId='CBT02' AND zsid.sortirId='' AND zsid.palletId='' AND (zsid.ean='' OR zsid.sku='' );

SELECT * FROM Z_SORTIR_INBOUND_DETAILS zsid WHERE zsid.organizationId='OJV_CML'
AND zsid.warehouseId='CBT02'  AND (zsid.ean='5414476034684C' OR zsid.sku='0000000000000101681505C' )


SELECT zsid.customerId,
zsid.sortirId,
zsid.sortirLineId,
zsid.palletId,
zsid.ean,
zsid.sku,
zsid.skuDescription,
zsid.qty
FROM Z_SORTIR_INBOUND_HEADER zsih
INNER JOIN Z_SORTIR_INBOUND_DETAILS zsid
ON zsih.organizationId = zsid.organizationId
AND zsih.warehouseId = zsid.warehouseId
AND zsih.sortirId = zsid.sortirId
AND zsih.customerId = zsid.customerId
WHERE zsid.organizationId='OJV_CML'
AND zsid.warehouseId='CBT01'
AND zsid.customerId='MAP'
AND zsid.sortirId ='STR0000028251021' AND zsih.status='00';


SELECT zsid.sortirId AS @LIST_VIEW@,
  zsid.palletId AS @LIST_VIEW@,
  zsid.ean AS @LIST_VIEW@,
  zsid.sku AS @LIST_VIEW@,
  zsid.skuDescription AS @LIST_VIEW@,
  zsid.customerId AS @LIST_VIEW@,
zsid.sortirLineId AS @LIST_VIEW@,
zsid.qty AS @LIST_VIEW@
FROM Z_SORTIR_INBOUND_HEADER zsih
INNER JOIN Z_SORTIR_INBOUND_DETAILS zsid
ON zsih.organizationId = zsid.organizationId
AND zsih.warehouseId = zsid.warehouseId
AND zsih.sortirId = zsid.sortirId
AND zsih.customerId = zsid.customerId
WHERE zsid.organizationId='OJV_CML'
AND zsid.warehouseId='#WAREHOUSEID#'
AND zsid.customerId='@HIDE_CUSTOMERID@'
AND zsid.sortirId ='@HIDE_SORTIRID@' AND zsih.status='00';



DROP TABLE Z_SORTIR_INBOUND