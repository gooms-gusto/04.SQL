SELECT * FROM DOC_ORDER_HEADER  aad WHERE aad.organizationId='OJV_CML' AND aad.warehouseId='CBT01'
AND aad.customerId='PPG'  AND aad.soStatus=99 AND aad.orderType='SO' ORDER BY aad.editTime DESC LIMIT 1;


SELECT aad.orderNo,aad.sku,aad.orderLineNo,aad.qty,
ZgetPPGPalletType(aad.organizationId,aad.warehouseId,aad.customerId,aad.orderNo,aad.allocationDetailsId) AS PALLET_TYPE
 FROM ACT_ALLOCATION_DETAILS aad WHERE aad.orderNo='SOPPG2406260025' AND aad.organizationId='OJV_CML' 
AND aad.warehouseId='CBT01' AND aad.customerId='PPG';


USE wms_cml;
SET @p_organizationId = 'OJV_CML';
SET @p_warehouseId = 'CBT01';
SET @p_customerId = 'PPG';
SET @p_orderNo = 'SOPPG2406260025';
SET @p_allocationDetail = '1486432';
SET @ResultValue = ZgetPPGPalletType(@p_organizationId, @p_warehouseId, @p_customerId, @p_orderNo, @p_allocationDetail);
SELECT
  @ResultValue;


SELECT
    dod.orderNo,
    doh.orderType,
    ald.SKU,
    bs.sku_group1,
    doh.consigneeId
  FROM ACT_ALLOCATION_DETAILS ald
    INNER JOIN DOC_ORDER_DETAILS dod
      ON ald.organizationId = dod.organizationId
      AND ald.warehouseId = dod.warehouseId
      AND ald.orderNo = dod.orderNo
      AND ald.orderLineNo = dod.orderLineNo
      AND ald.customerId = dod.customerId
      AND ald.SKU = dod.SKU
    INNER JOIN DOC_ORDER_HEADER doh
      ON ald.organizationId = doh.organizationId
      AND ald.warehouseId = doh.warehouseId
      AND ald.orderNo = doh.orderNo
      AND ald.customerId = doh.customerId
    INNER JOIN BAS_SKU bs
      ON ald.organizationId = bs.organizationId
      AND ald.SKU = bs.SKU
  WHERE ald.organizationId = 'OJV_CML'
  AND ald.warehouseId = 'CBT01'
  AND ald.customerId = 'PPG'
  AND ald.allocationDetailsId = '1515155';

SELECT * FROM ACT_TRANSACTION_LOG atl WHERE atl.organizationId='OJV_CML' AND atl.warehouseId='CBT01' AND atl.fmCustomerId='PPG'
AND atl.fmId='23102401530' AND   atl.transactionType='';

SELECT * FROM ACT_TRANSACTION_LOG atl WHERE atl.organizationId='OJV_CML' AND atl.warehouseId='CBT01' AND atl.fmCustomerId='PPG'
AND atl.docNo='ASNPPG2310240017' AND   atl.transactionType='';

SELECT aad.qty_each, aad.orderNo FROM ACT_ALLOCATION_DETAILS aad WHERE aad.traceId='23102401530' 
AND aad.organizationId='OJV_CML' AND aad.warehouseId='CBT01';

SELECT SUM(atl.fmQty_Each) FROM ACT_TRANSACTION_LOG atl WHERE atl.organizationId='OJV_CML'
AND atl.warehouseId='CBT01' AND atl.fmCustomerId='PPG'
AND atl.transactionType='PA' AND atl.fmId='23102401530';

SELECT COUNT(1) FROM (SELECT 'ABC' AS ITEM) A WHERE A.ITEM ='ABC';


SELECT * FROM BAS_SKU bs WHERE bs.organizationId='OJV_CML' AND bs.customerId='PPG' AND bs.sku='00045283';