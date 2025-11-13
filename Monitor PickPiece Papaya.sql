SELECT 
PICKPIECE.SKU,PICKPIECE.SKU_DESCRL, PICKPIECE.QTY_AVAILABLE_EA AS QTY_PICKPIECE, ORDERS.QTY_ORDER
FROM 
(
SELECT dod.SKU,SUM(dod.qtyOrdered_each) AS QTY_ORDER FROM DOC_ORDER_DETAILS dod
  WHERE dod.warehouseId='PAPAYA' AND dod.customerId='PAPAYA'
 AND dod.ADDTIME BETWEEN '2023-01-19 00:00:00' AND '2023-01-19 23:59:00'
  GROUP BY dod.SKU) ORDERS INNER JOIN 
	(
	SELECT
        a.SKU            AS SKU            ,
  bas_sku.SKUDESCR1                                                   AS SKU_DESCRL,
      --  a.LOCATIONID     AS LOCATION_ID    ,
        SUM(a.qty - a.qtyAllocated -(a.qtyOnHold + 0) - a.qtyRpOut - a.qtyMvOut) AS QTY_AVAILABLE_EA
FROM
        INV_LOT_LOC_ID a
LEFT  JOIN BAS_SKU bas_sku
ON
        a.organizationId       = bas_sku.organizationId
        AND bas_sku.customerId = a.customerId
        AND bas_sku.sku        = a.sku
WHERE
        a.organizationId = 'OJV_CML'
        AND
        (
                a.qty        > 0
                OR a.qtyRpIn > 0
                OR a.qtyMvIn > 0
                OR a.qtyPa   > 0
        )
  AND (a.qty - a.qtyAllocated -(a.qtyOnHold + 0) - a.qtyRpOut - a.qtyMvOut)> 0 
        AND a.warehouseId = 'PAPAYA'
        AND a.customerId IN('PAPAYA') AND a.locationId in (
				select fwdLoc from BAS_FORWARDING_LOC WHERE warehouseId='PAPAYA' AND customerId='PAPAYA')
  GROUP BY
        a.SKU    


	) PICKPIECE ON (ORDERS.SKU=PICKPIECE.SKU)
	WHERE ORDERS.SKU IN ('050200260')
	
	
	-- ======================================================================================================================
	
	SELECT dod.SKU,SUM(dod.qtyOrdered_each) AS QTY_ORDER FROM DOC_ORDER_DETAILS dod
  WHERE dod.warehouseId='PAPAYA' AND dod.customerId='PAPAYA'
 AND dod.ADDTIME BETWEEN '2023-01-19 00:00:00' AND '2023-01-19 23:59:00' AND dod.sku='050200260'
  GROUP BY dod.SKU
	
	
	SELECT dod.SKU,dod.qtyOrdered_each AS QTY_ORDER FROM DOC_ORDER_DETAILS dod
  WHERE dod.warehouseId='PAPAYA' AND dod.customerId='PAPAYA'
 AND dod.ADDTIME BETWEEN '2023-01-19 00:00:00' AND '2023-01-19 23:59:00' AND dod.SKU=NULL
 
 	-- ======================================================================================================================

SELECT
        a.SKU            AS SKU            ,
  bas_sku.SKUDESCR1                                                   AS SKU_DESCRL,
      --  a.LOCATIONID     AS LOCATION_ID    ,
        SUM(a.qty - a.qtyAllocated -(a.qtyOnHold + 0) - a.qtyRpOut - a.qtyMvOut) AS QTY_AVAILABLE_EA
FROM
        INV_LOT_LOC_ID a
LEFT JOIN BAS_SKU bas_sku
ON
        a.organizationId       = bas_sku.organizationId
        AND bas_sku.customerId = a.customerId
        AND bas_sku.sku        = a.sku
WHERE
        a.organizationId = 'OJV_CML'
        AND
        (
                a.qty        > 0
                OR a.qtyRpIn > 0
                OR a.qtyMvIn > 0
                OR a.qtyPa   > 0
        )
  AND (a.qty - a.qtyAllocated -(a.qtyOnHold + 0) - a.qtyRpOut - a.qtyMvOut)> 0 
        AND a.warehouseId = 'PAPAYA'
        AND a.customerId IN('PAPAYA') AND a.locationId in (
				select fwdLoc from BAS_FORWARDING_LOC WHERE warehouseId='PAPAYA' AND customerId='PAPAYA') 
  GROUP BY
        a.SKU    
