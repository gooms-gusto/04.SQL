/*
  @ Handling in API and ADS
  @ Author : Albert
  @ Created At : 2023-02-03 15:00:27

Modify  By AB
2023-02-22
convert by ANGGAR 
correction by AB 
update char by DA

*/
SELECT * FROM (
SELECT
  IFNULL(CAST(atl.warehouseId as char (255)),'') AS warehouseId,
  IFNULL(CAST(atl.tocustomerId as char (255)),'') AS customerId,
  IFNULL(CAST(atl.docNo as char (255)),'') AS asnNo,
  IFNULL(CAST(atl.docLineNo as char (255)),0) AS asnLineNo,
  IFNULL(CAST(t1.codeDescr as char (255)),'') AS asnType,
  IFNULL(CAST(dah.asnReference1 as char (255)),'') AS asnReference1,
  IFNULL(CAST(dah.asnReference3 as char (255)),'') AS asnReference3,
  IFNULL(CAST(dah.asnReference5 as char (255)),'') AS asnReference5,
  IFNULL(CAST(atl.toSKU as char (255)),'') AS SKU,
  IFNULL(CAST(bs.skuDescr1 as char (255)),'') AS skuDescr1,
  IFNULL(CAST(atl.toQty as char (255)), 0) AS qtyReceived,
  IFNULL(CAST(atl.toUom as char (255)),'') AS uom,
  IFNULL(CAST(atl.toQty_Each as char (255)),0) AS qtyReceivedEach,
		IFNULL(COUNT(dad.asnLineNo),0) AS qtyCharge,
/*CASE WHEN bsm.tariffMasterId = 'BIL00061'
  THEN
  IFNULL(CAST(SUM( atl.toQty_Each /  bpdPL.qty) as char (255)),0) 
  WHEN bsm.tariffMasterId = 'BIL00061FG'
  THEN
    IFNULL(CAST(SUM( (atl.toQty_Each * bs.grossWeight)/ bpdPL.qty) as char (255)),0) 
  END
  AS qtyCharge,*/
  CAST(DATE_FORMAT(atl.addTime,'%Y-%m-%d')  as char (255)) AS addTime,
  IFNULL(CAST(bpdCS.qty as char (255)),0) AS QtyPerCases,
  IFNULL(CAST(bpdPL.qty as char (255)),0) AS QtyPerPallet,
  CAST(DATE_FORMAT(atl.editTime,'%Y-%m-%d') as char (255)) AS editTime,
  IFNULL(CAST(bs.sku_group1 as char (255)),'') AS sku_group1,
  IFNULL(CAST(atl.tolotNum as char (255)),'') AS lotNum,
  IFNULL(CAST(atl.toId as char (255)),'') AS traceId,
  IFNULL(CAST(atl.tomuid as char (255)),'') AS muid,
  IFNULL(CAST(atl.toLocation as char (255)),'') AS toLocation,
  IFNULL(CAST(bl.locationCategory as char (255)),'') AS locationCategory,
	IFNULL(CAST(t2.codeDescr as char (255)),'') AS locCatDes,
  IFNULL(CAST(bpdCS.packId as char (255)),'') AS packId,
  IFNULL(CAST(bsm.tariffMasterId as char (255)),'') AS tariffMasterId,
  IFNULL(CAST(bs.grossWeight as char (255)),0) AS grossWeight,
  IFNULL(CAST(bs.cube as char (255)),0) AS cubeNya,
  IFNULL(CAST(bz.zoneDescr as char (255)),'') AS zone,
  IFNULL(CAST(SUM(atl.toQty_Each * bs.cube) as char (255)),0) AS totalCube,
  IFNULL(CAST(ila.lotAtt04 as char (255)),'') AS batch,
  CAST(DATE_FORMAT(atl.transactionTime,'%Y-%m-%d')  as char (255)) AS transactionTime,
  IFNULL(CAST(atl.transactionId  as char (255)),'') AS transactionId,
   case when dah.asntype IN ('TT','ITI') then 'LOOSE' else (case when dapph.udf05='' then 
	(case when dah.asnReference5='' then dah.asnReference3 else  dah.asnReference5 end)
	else  dapph.udf05 end) end as handlingType
	-- IFNULL(CAST(dapph.udf05 as char (255)),'')  AS handlingType  
  	FROM
  ACT_TRANSACTION_LOG atl
LEFT OUTER JOIN
  BAS_SKU bs
ON
  bs.organizationId = atl.organizationId
  AND bs.customerId = atl.toCustomerId
  AND bs.SKU = atl.toSku
LEFT OUTER JOIN
  BAS_SKU_MULTIWAREHOUSE bsm
ON
  bsm.organizationId = bs.organizationId
  AND bsm.warehouseId = atl.warehouseId
  AND bsm.customerId = bs.customerId
  AND bsm.SKU = bs.SKU
LEFT OUTER JOIN
  DOC_ASN_HEADER dah
ON
  dah.organizationId = atl.organizationId
  AND dah.warehouseId = atl.warehouseId
  AND dah.asnNo = atl.docNo
LEFT OUTER JOIN
  DOC_ASN_DETAILS dad
ON
  dad.organizationId = atl.organizationId
  AND   dad.warehouseId = atl.warehouseId
  AND dad.asnNo = atl.docNo
  AND dad.asnLineNo = atl.docLineNo
  AND dad.sku = atl.toSku
LEFT OUTER JOIN
  INV_LOT_ATT ila
ON
  ila.organizationId = atl.organizationId
  AND   ila.SKU = atl.toSku
  AND ila.lotNum = atl.toLotNum
LEFT OUTER JOIN
  BAS_PACKAGE_DETAILS bpdCS
ON
  bpdCS.organizationId = bs.organizationId
  AND   bpdCS.packId = bs.packId
  AND bpdCS.customerId = bs.customerId
  AND bpdCS.packUOM = 'CS'
LEFT OUTER JOIN
  BAS_PACKAGE_DETAILS bpdPL
ON
  bpdPL.organizationId = bs.organizationId
  AND   bpdPL.packId = bs.packId
  AND bpdPL.customerId = bs.customerId
  AND bpdPL.packUOM = 'PL'
LEFT JOIN
  BSM_CODE_ML t1
ON
  t1.organizationId = atl.organizationId
  AND t1.codeType = 'ASN_TYP'
  AND dah.asnType = t1.codeId
  AND t1.languageId = 'en'

LEFT JOIN BAS_LOCATION bl
ON
  bl.organizationId = atl.organizationId
  AND bl.warehouseId = atl.warehouseId
  AND bl.locationId = atl.tolocation

LEFT JOIN BAS_ZONE bz
ON

  bz.organizationId = bl.organizationId
  AND bz.warehouseId = bl.warehouseId
  AND bz.zoneId = bl.zoneId
  AND bz.zoneGroup = bl.zoneGroup

LEFT JOIN
  BSM_CODE_ML t2
ON
  t2.organizationId = atl.organizationId
  AND t2.codeType = 'LOC_CAT'
  AND bl.locationCategory = t2.codeId
  AND t2.languageId = 'en'
	

LEFT JOIN DOC_APPOINTMENT_DETAILS dappd
ON
  dappd.organizationId = dah.organizationId
  AND dappd.warehouseId = dah.warehouseId
  AND dappd.docNo = dah.asnNo
  
LEFT JOIN DOC_APPOINTMENT_HEADER dapph
ON 
  dapph.organizationId = dappd.organizationId
  AND dapph.warehouseId = dappd.warehouseId
  AND dapph.appointmentNo = dappd.appointmentNo

	
	WHERE
    atl.warehouseId ='CBT01'
  AND dah.customerId ='PT. SPI'
  AND atl.transactionType = 'PA'
  AND dah.asnType NOT IN ('FREE',
    'KT',
    'OT',
    'OV',
    'IU',
	 'RG')
  AND atl.status IN ( '99','80')
  AND dah.asnStatus = '99'
  AND bs.SkuDescr1 NOT LIKE '%PALLET%'
  AND atl.addTime >= '2023-08-01'
  AND atl.addTime <= '2023-08-15'
GROUP BY
  dah.asnNo,
  atl.docNo,
  atl.docLineNo,
  atl.toCustomerId,
  t1.codeDescr,
  atl.toQty,
  atl.toQty_Each,
  dah.asnType,
  atl.toSku,
  dah.asnReference1,
  dah.asnReference3,
  dah.asnReference5,
  ila.lotAtt04,
  atl.toUom,
  atl.addTime,
  atl.transactionTime,
  bsm.tariffMasterId,
  bs.SkuDescr1,
  bs.grossWeight,
  bs.cube,
  bs.sku_group1,
  atl.editTime,
  dah.asnReference1,
  bz.zoneDescr,
	bl.locationId,
	bl.locationCategory,
  atl.toLotNum,
  atl.toId,
  atl.tomuid,
  atl.toLocation,
  atl.warehouseId,
  atl.tocustomerId,
  atl.transactionId,
  bpdCS.packId,
  bpdPL.packId,
  bpdCS.qty,
  bpdPL.qty,
	t2.codeDescr,
  dapph.udf05 ) atl1
-- where locCatDes IN ( 'Cantilever Rack','Gas Cylinder Rack','Medium Duty Pallet Rack')
-- LIMIT $maxResults OFFSET $skip