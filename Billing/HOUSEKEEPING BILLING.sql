 USE wms_cml;
 
 
 SELECT bs.sku AS '@TXT_AREA_1@'
FROM BAS_SKU bs limit 1  ;



SELECT bpd.uomDescr
FROM BAS_SKU bs 
INNER JOIN
BAS_SKU_MULTIWAREHOUSE bsm ON bs.organizationId = bsm.organizationId
AND bs.customerId = bsm.customerId AND bs.sku = bsm.sku
INNER JOIN BAS_PACKAGE_DETAILS bpd ON bsm.organizationId = bpd.organizationId AND 
 bsm.packId = bpd.packId
 AND bs.organizationId ='#ORGANIZATIONID#' 
 AND bsm.warehouseId='#WAREHOUSEID#'
 AND bs.sku='@TXT_SKU_3@'
 AND bpd.packUom='EA';


SELECT * FROM Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd WHERE zbccd.idGroupSp IN ('STD','STDx');

SELECT * from Z_BAS_CUSTOMER_CUSTBILLING where active='Y' and lottable03='D' order by seqNo

SELECT bpd.uomDescr 
FROM BAS_SKU bs 
INNER JOIN
BAS_SKU_MULTIWAREHOUSE bsm ON bs.organizationId = bsm.organizationId
AND bs.customerId = bsm.customerId AND bs.sku = bsm.sku
INNER JOIN BAS_PACKAGE_DETAILS bpd ON bsm.organizationId = bpd.organizationId AND bsm.packId = bpd.packId AND
bs.organizationId ='#ORGANIZATIONID#' AND bsm.warehouseId='#WAREHOUSEID#' AND bs.sku='@TXT_SKU_3@' AND bpd.packUom='EA';



SELECT 
 *
FROM Z_BAS_CUSTOMER_CUSTBILLING_DETAILS where active='Y'  and idGroupSp IN ('ECMAMAB2C');



SELECT * FROM BIL_SUMMARY bs
WHERE bs.organizationId ='OJV_CML' AND bs.warehouseId='CBT02-B2C' AND bs.customerId='ECMAMAB2C'  AND
DATE(bs.billingFromDate) > '2025-07-25' AND DATE(bs.billingFromDate)   <= DATE(NOW());

/*DELETE FROM BIL_SUMMARY
WHERE organizationId ='OJV_CML' AND warehouseId='CBT02-B2C' AND customerId='ECMAMAB2C' AND arNo IS NULL AND
DATE(billingFromDate) > '2025-07-25' AND DATE(billingFromDate)   <= DATE(NOW()); 




*/


SHOW PROCESSLIST;



USE wms_cml;

SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT02';
SET @IN_USERID = 'CUSTOMBILL';
SET @IN_Language = 'en';
SET @IN_CustomerId = 'ECMAMAB2C';
SET @IN_trans_no = 'MMCSO2508020748';
SET @IN_tariffMaster = '';
CALL CML_BILLHISTD_TYPE2(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @IN_tariffMaster);