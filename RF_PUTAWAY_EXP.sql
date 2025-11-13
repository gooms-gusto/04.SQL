SELECT CASE WHEN  MIN(date(INV_LOT_ATT.lotAtt02)) <
(SELECT  date(ila.lotAtt02) FROM INV_LOT_LOC_ID illi INNER JOIN INV_LOT_ATT ila ON (illi.organizationId = ila.organizationId AND illi.lotNum = ila.lotNum AND illi.customerId = ila.customerId
AND illi.sku = ila.sku) WHERE illi.warehouseId='#WAREHOUSEID#' AND illi.traceId='@TXT_TID_1@' AND illi.qty > 0) THEN 'UP LOC' ELSE 'DOWN LOC' END AS @TXT_SUGGESTBACKDATELOC@
  FROM INV_LOT_LOC_ID 
  INNER JOIN  INV_LOT_ATT  ON (INV_LOT_ATT.organizationId=INV_LOT_ATT.organizationId AND INV_LOT_LOC_ID.customerId=INV_LOT_ATT.customerId
  AND INV_LOT_LOC_ID.sku=INV_LOT_ATT.sku AND INV_LOT_LOC_ID.lotNum = INV_LOT_ATT.lotNum)
  WHERE INV_LOT_LOC_ID.SKU='@HIDE_SKU@'  AND locationId NOT LIKE 'SORTATION%' AND
  INV_LOT_LOC_ID.qty  > 0  AND INV_LOT_LOC_ID.customerId IN (SELECT DISTINCT customerId
  FROM INV_LOT_LOC_ID WHERE traceId ='@TXT_TID_1@')