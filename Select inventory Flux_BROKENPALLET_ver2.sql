SELECT 
AL.warehouseId AS WAREHOUSE_ID,
AL.customerId AS CUSTOMER_ID,
AL.sku AS SKU,AL.skuDescr1 AS SKU_DESCR,
-- AL.packId AS PACKEY,
AL.qtymaksimumperpalet AS MAKS_QTY_PERPALLET,
SUM( AL.qty_available_ea) AS QTY_IN_PALLET,
AL.locationId AS LOCATIONID,
-- AL.lotNum AS LOTNUM,
 AL.locationCategory AS LOCATION_CATEGORY,
 AL.lotAtt04 AS BATCH_SKU
-- AL.fmId AS TRACEID
FROM(

SELECT
  a.organizationId,
  a.warehouseId,
  a.customerId,
  a.sku,
  l13p.qty AS qtymaksimumperpalet,
  a.locationId,
  d.locationCategory,
  a.lotNum AS fmLotnum,
  a.traceId AS fmId,
  a.muid,
  a.qty AS qty_each,
  CASE WHEN a.cubic < 0 THEN 0 ELSE a.cubic END AS totalCubic,
  CASE WHEN a.grossWeight < 0 THEN 0 ELSE a.grossWeight END AS totalGrossWeight,
  CASE WHEN a.netWeight < 0 THEN 0 ELSE a.netWeight END AS totalNetWeight,
  a.qty - a.qtyAllocated  AS qty_available_ea,
  a.lotNum,
  bas_sku.skuDescr1,
  bas_sku.skuDescr2,
  ila.lotAtt01,
  ila.lotAtt02,
  ila.lotAtt03,
  ila.lotAtt04,
  ila.lotAtt05,
  ila.lotAtt06,
  ila.lotAtt07,
  ila.lotAtt08,
  ila.lotAtt09,
  ila.lotAtt10,
  ila.lotAtt11,
  ila.lotAtt12,
  ila.lotAtt13,
  a.addWho,l13p.qty as QTYPERPALLET,bas_sku.CUBE
FROM INV_LOT_LOC_ID a
  LEFT JOIN BAS_SKU bas_sku
    ON a.organizationId = bas_sku.organizationId
    AND bas_sku.customerId = a.customerId
    AND bas_sku.sku = a.sku
  LEFT JOIN BAS_CUSTOMER b
    ON a.organizationId = b.organizationId
    AND a.customerId = b.customerId
    AND b.customerType = 'OW'
  LEFT JOIN BAS_LOCATION d
    ON a.organizationId = d.organizationId
    AND a.warehouseId = d.warehouseId
    AND a.locationId = d.locationId
  LEFT JOIN INV_LOT_ATT ila
    ON a.organizationId = ila.organizationId
    AND a.lotNum = ila.lotNum
LEFT JOIN BAS_PACKAGE_DETAILS l13p
     ON bas_sku.organizationId = l13p.organizationId
     AND  bas_sku.customerId = l13p.customerId
    AND bas_sku.packId = l13p.packId
    AND l13p.packUom = 'PL'
WHERE a.organizationId = 'OJV_CML'
-- AND (
--  a.qty > 0
-- a.qtyRpIn > 0
-- OR a.qtyMvIn > 0
-- OR a.qtyPa > 0
-- )  
AND 1=1  
 -- AND bas_sku.lotId <> 'SERIALNO' 
-- AND d.mix_flag <> 'Y'
--    AND 
--         a.customerId  IN (
--            'MAP',
--           'PPG',
--          'LTL',
--         'YFI',
--        'ITOCHU'
--        'HPK',
--        'MDS',
--        'PLB-LTL',
--        'HPK',
--        'BCA',
--        'BCAFIN',
--        'DNN',
--         'GYVTL',
--         'RBFOOD'
--         )
AND a.warehouseid in ('CBT02','CBT01')) AL 
 -- WHERE AL.sku IN ('MZ320344')
--  AL.qtymaksimumperpalet <> AL.qty_available_ea AND  AL.qty_available_ea < (0.99 * AL.qtymaksimumperpalet)
 -- AND AL.sku IN ('02973D')
 -- AND AL.locationCategory IN ('SD','DD') 
-- AND AL.locationId IN('C07A005')
-- AND AL.qtymaksimumperpalet IS NULL
-- AND AL.locationId IN (
-- )
GROUP BY  AL.warehouseId,AL.customerId,AL.sku,AL.locationId, AL.lotAtt04
ORDER BY AL.warehouseId,AL.customerId,AL.sku,AL.locationId, AL.lotAtt04;


-- SELECT * FROM BAS_PACKAGE_DETAILS bpd WHERE bpd.packId='1/0/200/800-58X58X90'



-- SELECT bs.packId FROM BAS_SKU bs WHERE bs.sku
-- IN (
-- 'PALLET 1-MZ320344',
-- 'PALLET 1-MZ320346',
-- 'PALLET 1-MZ320349',
-- 'PALLET 1-MZ320357',
-- 'PALLET 2-ANTIRUST',
-- 'PALLET 2-CHASSIS',
-- 'PALLET 2-CLEANSOL',
-- 'PALLET 2-EPNOC',
-- 'PALLET 2-MOLYNOC',
-- 'PALLET 2-MTF OIL',
-- 'PALLET 2-NO LABEL',
-- 'PALLET 2-POWERNOC',
-- 'PALLET 2-TOYOTA',
-- 'PALLET 2-Y. INJECTOR CLEANER',
-- 'PALLET 3-E. CVT F',
-- 'PALLET 3-E. SL/CF',
-- 'PALLET 3-KTB',
-- 'PALLET 3-KTB ATF SP III',
-- 'PALLET 3-KTB SUPER GOLD',
-- 'PALLET 3-KTB SUPER PLUS',
-- 'PALLET 3-NISSAN',
-- 'PALLET 3-YAMALUBE')
-- 
--               




INSERT INTO BIL_CRM_HEADER (organizationId, warehouseId, OpportunityId, AgreementNo, CustomerId, effectiveFrom, effectiveTo, addWho, addTime, oprSeqFlag, currentVersion) VALUES
('OJV_CML', 'CBT01', '0060k00000G5fA0TRV', 'Contract-0000000011', '3000004464', '2023-07-28 00:00:00', '2023-12-31 00:00:00', 'EDI', '2023-08-23 00:00:38', '2016', 100);

USE WMS_FTEST;

INSERT INTO BIL_CRM_DETAILS (organizationId, warehouseid, OpportunityId, ProductCode, ProductDescr, rate, uom, addWho, addTime, oprSeqFlag, currentVersion) VALUES
('OJV_CML', 'CBT01', '0060k00000G5fA0TRV', '1700000045', 'Handling In', 1200000.00000000, 'PALLET', 'EDI', '2023-08-23 00:00:38', '2016', 100);

INSERT INTO BIL_CRM_DETAILS (organizationId, warehouseid, OpportunityId, ProductCode, ProductDescr, rate, uom, addWho, addTime, oprSeqFlag, currentVersion) VALUES
('OJV_CML', 'CBT01', '0060k00000G5fA0TRV', '1700000046', 'Handling Out', 2400000.00000000, 'PALLET', 'EDI', '2023-08-23 00:00:38', '2016', 100);



SELECT * FROM BIL_CRM_HEADER bch WHERE bch.OpportunityId ='0060k00000G5fA0TRV';


SELECT * FROM BIL_CRM_DETAILS bcd  WHERE bcd.OpportunityId ='0060k00000G5fA0TRV';

SELECT
        h1.opportunityID AS CODEID,
        h1.opportunityID AS CODETEXT
FROM
        BIL_CRM_HEADER h1
WHERE
        h1.organizationid     = 'OJV_CML'
        -- AND h1.customerid     = 'A'
ORDER BY
        h1.effectiveFrom DESC;


USE wms_cml;

UPDATE BIL_CRM_HEADER SET effectiveFrom = '2023-08-23 00:00:00'
WHERE organizationId = 'OJV_CML' AND warehouseId = 'CBT01' 
AND OpportunityId = '0060k00000G5fA0TRV';
