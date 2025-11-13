SELECT * FROM wms_cml.DOC_TRANSFER_DETAILS dtd 
WHERE dtd.tdocNo='000237'AND dtd.warehouseId='SMG-SO' AND dtd.fmCustomerId='CERESSMG';

SELECT * FROM DOC_TRANSFER_HEADER dth WHERE dth.tdocNo='000237' AND dth.customerId='CERESSMG';

DELETE  FROM wms_cml.DOC_TRANSFER_DETAILS  
WHERE tdocNo='000237'AND warehouseId='SMG-SO' AND fmCustomerId='CERESSMG';


