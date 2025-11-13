USE wms_cml;


  SET @rownr=0;
SELECT
  'CBT02' AS warehouseId,
  'FREE' AS POTYPE,
  '00' AS POSTATUS,
'AGM' AS CUSTOMERID,
  b.soReference1 AS 'POREFERENCE1',
     a.orderNo AS 'POREFERENCE2',
  'DNN-LADC01' AS 'SUPPLIERID',
  'TIRTA INVESTAMA ( Lemah Abang )' AS 'SUPPLIERNAME',
  'N' AS 'EDISENDFLAG',
  'Y' AS 'RELEASESTATUS',
  '0' AS totalCubic,
   '0' AS totalGrossWeight ,
   '0' AS totalNetWeight,
   '0' AS totalPrice,
   '0' AS totalLineCount,
   '0' AS curLineNo,
   'CBT02' AS warehouseId2,
    @rownr:=@rownr+1 AS poline,
  '00'  AS poLineStatus,
'AGM' AS CUSTOMERID,
 a.sku,
 SUM(a.qty_each) AS orderedQty,
SUM(a.qty_each) AS orderedQtyEach,
  d.packId,
  d.uomDescr,
  d.cube AS TOTALCUBIC,
  a.grossWeight,
  a.netWeight,
  a.price,
  DATE_FORMAT(e.lotAtt01, '%Y-%m-%d') AS ManufDate,
  e.lotAtt02 AS ExpDate,
  e.lotAtt03 AS WHDate,
 e.lotAtt04 AS Batch,
  'R' AS LOT7,
  'N'AS LOT8,
   e.lotAtt09 AS LOT9,
   e.lotAtt10,
  e.lotAtt16
FROM ACT_ALLOCATION_DETAILS a
  LEFT OUTER JOIN DOC_ORDER_HEADER b
    ON a.organizationId = b.organizationId
    AND a.warehouseId = b.warehouseId
    AND a.orderNo = b.orderNo
  LEFT OUTER JOIN BAS_SKU c
    ON a.organizationId = c.organizationId
    AND a.sku = c.sku
    AND a.customerId = c.customerId
  LEFT OUTER JOIN (SELECT
      *
    FROM BAS_PACKAGE_DETAILS
    WHERE packUom = 'EA') d
    ON a.organizationId = d.organizationId
    AND a.packId = d.packId
    AND a.customerId = d.customerId
  LEFT OUTER JOIN INV_LOT_ATT e
    ON a.organizationId = e.organizationId
    AND a.lotNum = e.lotNum
    AND a.customerId = e.customerId
    AND a.sku = e.sku
WHERE a.organizationId = 'OJV_CML'
AND a.warehouseId = 'LADC01'
AND a.orderNo = 'S000022171'
GROUP BY a.customerId,
         a.orderNo,
         b.soReference1,
         b.consigneeId,
         a.sku,
         c.skuDescr1,
   d.cube,
   a.grossWeight,
  a.netWeight,
  a.price,
         d.uomDescr,
         b.expectedShipmentTime1,
         d.packid,
         b.lastShipmentTime,
         e.lotAtt01,
         e.lotAtt02,
         e.lotAtt03,
         e.lotAtt04,
         e.lotAtt07,
         e.lotAtt08,
         e.lotAtt09,
         e.lotAtt10,
    e.lotAtt16
  ORDER BY poline



