/*
  @ Charge Category Storage by Storage Position
  @ Author : Albert
  @ Created At : 2023-02-07 19:49:15
*/

SELECT
DISTINCT
  IFNULL(zib.customerId,'')  AS customerId,
  IFNULL(zib.warehouseId,'')  AS warehouseId,
  IFNULL(zib.organizationId,'')  AS organizationId,
  IFNULL(zib.sku,'')  AS SKU,
  IFNULL(zib.SKUDesc,'')  AS SKUDescr,
  IFNULL(zib.UOM,'')  AS uom,
  SUM(IFNULL(zib.qtyonHand,0))  AS qtyonHand,
  IFNULL(bpdCS.qty,0)  AS QtyPerCases,
  IFNULL(bpdPL.qty,0)  AS QtyPerPallet,
  IFNULL(zib.muid,'')  AS muid,
  IFNULL(zib.traceId,'')  AS traceId,
  IFNULL(zib.lotNum,'')  AS lotNum,
  IFNULL(zib.packkey,'')  AS packkey,
  DATE_FORMAT(zib.StockDate,"%Y-%m-%d") as StockDate,
  IFNULL(zib.netWeight,0)  as netWeight,
  IFNULL(zib.grossWeight,0)  as grossWeight,
  IFNULL(zib.qtyPicked,0)  AS qtyPicked,
  IFNULL(zib.qtyavailable,0)  AS qtyavailable,
  IFNULL(zib.qtyallocated,0)  AS qtyallocated,
  IFNULL(bs.`cube`,0)  as cubeNya,
  IFNULL(bz.zoneDescr,'')  AS zone,
  IFNULL(SUM(bs.cube * zib.qtyonHand),0)  as totalCube,
  COUNT(IFNULL(zib.traceId,''))  AS qtyCharge,
  IFNULL(zib.locationId,'')  AS locationId,
  IFNULL(zib.locationCategory,'')  AS locationCategory,
  IFNULL(bs.sku_group6,'') AS skuGroup,
  IFNULL(ILA.lotAtt04,'')  AS batch,
  IFNULL(ILA.lotAtt07,'')  AS lotAtt07,
  CASE ILA.lotAtt07 WHEN 'O' THEN 'Owner Pallet' WHEN 'R' THEN 'Rental Pallet' when 'PP' then 'Rental Plastic Pallet'    when 'WP' then 'Rental Wooden Pallet' END AS RecType,
  IFNULL(zib.locGroup1,'')  AS locGroup1,
  IFNULL(zib.locGroup2,'')  AS locGroup2,
  IFNULL(bl.locationCategory,'')  AS locationCategory,
  CASE bl.locationCategory
  WHEN 'GA'
    THEN 'Gravity Rack (AC)'
  WHEN 'GR'
    THEN 'Gravity Rack (Dry)'
  END AS RackType
	
	FROM
  Z_InventoryBalance zib
  left join `BAS_SKU` as bs on bs.sku = zib.sku and bs.customerId = zib.customerId
  left join `INV_LOT_ATT` ILA on ILA.SKU = zib.SKU and ILA.lotnum = zib.lotnum and ILA.customerId = zib.customerId
  
LEFT JOIN BAS_PACKAGE_DETAILS bpdCS
ON
  bpdCS.packId = zib.packkey
  AND bpdCS.customerId = zib.customerId
  AND bpdCS.packUOM = 'CS'

LEFT JOIN BAS_LOCATION bl
ON
  bl.warehouseId = zib.warehouseId
  AND bl.locationId = zib.locationId

LEFT JOIN BAS_ZONE bz
ON
        bz.organizationId = zib.organizationId
        AND bz.warehouseId = zib.warehouseId
        AND bz.zoneId = bl.zoneId
        AND bz.zoneGroup = bl.zoneGroup

LEFT JOIN BAS_PACKAGE_DETAILS bpdPL
ON
  bpdPL.packId = zib.packkey
  AND bpdPL.customerId = zib.customerId
  AND bpdPL.packUOM = 'PL'
	
	WHERE  zib.customerId ='MAP' and zib.warehouseid='CBT01' AND
         zib.SKU not in ('FULLCARTON')
        AND zib.qtyOnHand > 0 
      --  AND bl.locationCategory IN('GR','GA')
        AND zib.StockDate BETWEEN '2023-04-26' AND '2023-05-25'
AND zib.locationId not in ('CONSWOR','LOST_CBT01','STG01','STG02','STG03','STG04','STG05','STG11','STG12','STG13','STG14','STG15','STG06','STG07','STG08','STG09','STG10','STG16','STG17','STG18','STG19','STG20','SORTATIONCBT01','CROSSDOCK_01','CROSSDOCK_02','SORTATIONLADC01','SORTATIONBASF01','SORTATION','SORTATIONCBT02','SORTATIONSMG-SO','SORTATION1','CYCLE-01S','LOST_CBT01','STO-01','STO-02','STO-03','STO-04','STO-05','WHAQC','WHCQC','WHCQC01','WHCQC03','WHCQC05','WHCQC09','WHCQC11','WHCQC13','WHCQC15','WHCQC17','WHCQC19','WHCQC21','WHCQC23','WHCQC25','WHCQC27','WHCQC29','WHCQC31','WHCQC33','WHCQC35','WHIQC','WORK_AREA') 

GROUP BY
  zib.organizationId,
  zib.warehouseId,
  zib.customerId,
  zib.sku,
  zib.traceId,
  zib.muid,
  zib.netWeight,
  zib.grossWeight,
  zib.UOM,
  zib.packkey,
  zib.stockDate,
  zib.SKUDesc,
  zib.locGroup1,
  zib.locGroup2,
  zib.StockDate,
  bl.locationCategory,
  zib.locationId,
  zib.qtyPicked,
  zib.qtyAvailable,
  bs.cube,
  bz.zoneDescr,
  bs.sku_Group6,
  zib.qtyAllocated,
  bpdCS.qty,
  bpdPL.qty,
  zib.locationCategory,
  zib.lotNum,
  ILA.lotAtt04,
  ILA.lotAtt07
ORDER BY StockDate DESC ;

-- SELECT DISTINCT(YEAR(StockDate)) FROM Z_InventoryBalance