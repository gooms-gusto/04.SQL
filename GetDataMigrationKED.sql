USE wms_cml;

-- OPEN PO
SELECT
  COUNT(1)
FROM wms_cml.DOC_PO_HEADER dph
WHERE dph.poStatus = '00'
AND dph.warehouseId = 'CBT02'
AND dph.customerId = 'DCH';

-- CLOSED PO

SELECT
  COUNT(1)
FROM wms_cml.DOC_PO_HEADER dph
WHERE dph.poStatus IN('99','40','30')
AND dph.warehouseId = 'CBT02'
AND dph.customerId = 'DCH';



    -- TOTAL LINE/PALLET
  SELECT
    COUNT(dad.poLineNo)
  FROM DOC_PO_HEADER  dph,
       DOC_PO_DETAILS dad
  WHERE dph.organizationId = dad.organizationId
  AND dph.warehouseId = dad.warehouseId
  AND dph.customerId = dad.customerId
  AND dph.poNo = dad.poNo
  AND dph.warehouseId = 'CBT02'
  AND dph.customerId='DCH' 
   AND dph.poStatus  NOT IN('99','40','30')

