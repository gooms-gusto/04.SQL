SELECT locationId,validationCode FROM wms_cml.BAS_LOCATION WHERE locationId LIKE 'F%' AND warehouseId='CBT02';


  SELECT * FROM wms_cml.DOC_PO_HEADER  WHERE warehouseId='CBT02' AND poNo='PO2109210002';
  SELECT * FROM wms_cml.DOC_PO_DETAILS  WHERE warehouseId='CBT02' AND poNo='PO2109210002';


  SELECT sku,packId,reportUom,cube,grossWeight,netWeight,price FROM wms_cml.BAS_SKU   WHERE sku IN 
    ('1.008-057.0',
'1.098-300.0',
'1.198-103.0',
'1.258-509.0',
'1.280-115.0',
'1.428-530.0',
'1.428-569.0',
'1.428-569.0',
'1.513-160.0',
'1.513-300.0',
'1.600-005.0',
'1.601-685.0',
'1.602-117.0',
'1.667-224.0',
'8.621-612.0',
'9.753-056.0')



    


