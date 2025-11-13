


  SELECT
  DOC_PO_HEADER.warehouseId,
  DOC_PO_HEADER.poType,
  DOC_PO_HEADER.poStatus,
  DOC_PO_HEADER.customerId,
  DOC_PO_HEADER.poCreationTime,
  DOC_PO_HEADER.ediSendFlag,
  DOC_PO_HEADER.releaseStatus,
  DOC_PO_HEADER.totalCubic,
  DOC_PO_HEADER.totalCubic AS expr1,
  DOC_PO_HEADER.totalGrossWeight,
  DOC_PO_HEADER.totalNetWeight,
  DOC_PO_HEADER.totalPrice,
  DOC_PO_HEADER.totalLineCount,
  DOC_PO_HEADER.curLineNo,
  DOC_PO_HEADER.totalSkuCount,
  DOC_PO_HEADER.poNo
FROM wms_cml.DOC_PO_HEADER
WHERE DOC_PO_HEADER.warehouseId = 'CBT02'
AND DOC_PO_HEADER.poStatus = '00'
ORDER BY DOC_PO_HEADER.editTime DESC
LIMIT 1;


SELECT
  D.warehouseId,
  D.poLineNo,
  D.poLineStatus,
  D.customerId,
  D.sku,
  D.orderedQty,
  D.orderedQty_Each,
  D.packId,
  D.packUom,
  D.totalCubic,
  D.totalGrossWeight,
  D.totalNetWeight,
  D.totalPrice
FROM wms_cml.DOC_PO_DETAILS D
WHERE D.poNo = 'PO2109270007'



  SELECT
*
FROM wms_cml.DOC_PO_DETAILS D
WHERE D.poNo = 'PO2109270041'

  SELECT * FROM wms_cml.DOC_PO_HEADER D WHERE D.poNo='PO2109210003';


SELECT * FROM wms_cml.DOC_PO_DETAILS D WHERE D.poNo='PO2109210003';


  SELECT bs.sku,bs.packId,bs.cube,bs.defaultReceivingUom,bs.grossWeight,bs.netWeight,bs.price FROM wms_cml.BAS_SKU bs 
    WHERE bs.sku IN ('21134615',
'62039765',
'62039765',
'67262763',
'67378476',
'67470527',
'67681982',
'67997073',
'67997073',
'67997073',
'67999600',
'67999600',
'67999600',
'67999600',
'67999600',
'67999600',
'67999602',
'67999621',
'68283019',
'68431751',
'68431751'

);


 SELECT * FROM wms_cml.DOC_ASN_HEADER dah WHERE dah.poNo='PO2109210003';


SELECT * FROM wms_cml.DOC_ASN_DETAILS dad WHERE dad.asnNo='ASN210921005';



SELECT bl.locationId,bl.validationCode FROM wms_cml.BAS_LOCATION bl WHERE bl.warehouseId='CBT02';


  SELECT * FROM wms_cml.DOC_PO_DETAILS WHERE poNo IN (SELECT poNo FROM wms_cml.DOC_PO_HEADER  WHERE   AND warehouseId='CBT02' AND customerId='AGM'


    SELECT * FROM wms_cml.DOC_PO_HEADER  WHERE  warehouseId='CBT02' AND customerId='AGM' AND po


    SELECT COUNT(1) FROM wms_cml.inv_lot_att;


    SELECT * FROM BSM_USER 

      UPDATE BSM_USER
      set userId='LDRGENLADC-01'
        WHERE userId='SPV-KED'