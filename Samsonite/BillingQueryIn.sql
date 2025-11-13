SELECT
  a.organizationId,
  C.tariffMasterId,
  C.tariffid,
  clot.lotAtt04,
  a.fmcustomerId AS customerId,
  d.codeDescr AS OrderType,
  CASE clot.lotAtt07 WHEN 'O' THEN 'Owner Pallet' WHEN 'R' THEN 'Rental Pallet' WHEN 'PP' THEN 'Rental Plastic Pallet' WHEN 'WP' THEN 'Rental Wooden Pallet' END AS RecType,
  DATE_FORMAT(a.addtime, '%Y-%m-%d %T') AS billingFromDate,
  DATE_FORMAT(e.appointmentStartTime, '%Y-%m-%d %T') AS EntranceTime,
  DATE_FORMAT(e.appointmentEndTime, '%Y-%m-%d %T') AS LeaveTime,
  e.vehicleNo,
  a.docNo,
  g.poReference1,
  a.fmsku AS sku,
  b.skuDescr1,
  CASE WHEN a.fmcustomerId = 'LTL' AND
      g.hedi08 <> '' THEN m.ProfitCntr ELSE b.sku_group1 END AS MU,
  CASE a.fmcustomerId WHEN 'ZAP' THEN (CASE WHEN n.qty > 0 THEN a.fmQty_Each / n.qty ELSE a.fmQty_Each END) ELSE a.fmQty_Each END AS Qty_EA,
  CASE a.fmcustomerId WHEN 'ZAP' THEN (CASE WHEN n.qty > 0 THEN n.uomdescr ELSE h.uomdescr END) ELSE h.uomdescr END AS UOM_EA,
  CASE WHEN a.fmcustomerid IN ('API', 'ADS') THEN (CASE WHEN h.uomdescr = 'KG' THEN a.fmQty_Each WHEN h.uomdescr = 'LT' THEN a.fmQty_Each ELSE (a.fmQty_Each * b.sku_group6) END) ELSE (a.fmQty_Each / n.qty) END AS Qty_CS,
  CASE WHEN a.fmcustomerid IN ('API', 'ADS') THEN 'LT' ELSE n.uomdescr END AS UOM_CS,
  CASE a.fmcustomerId WHEN 'ZAP' THEN (CASE WHEN n.qty > 0 THEN i.qty / n.qty ELSE i.qty END) ELSE i.qty END AS QtyPerpallet,
  a.toid AS traceId,
  a.tomuid AS MUID,
  a.warehouseId,
  SUBSTRING(l.toLocation, 1, 1) AS Area,
  k.putawayDescr,
  a.fmlocation,
  clot.lotAtt04,
  CASE WHEN a.fmcustomerId = 'MAP' THEN b.cube ELSE (CASE h.cube WHEN 0 THEN n.cube ELSE h.cube END) END AS CBMSKU,
  CEIL(a.fmQty_Each / i.qty) AS palletUsed,
  CASE WHEN a.fmcustomerId = 'MAP' THEN (CASE WHEN clot.lotAtt04 = 'SET' THEN 0 ELSE (b.cube * a.fmQty_Each) END) ELSE (CASE a.fmcustomerId WHEN 'ZAP' THEN (CASE WHEN n.qty > 0 THEN a.fmQty_Each / n.qty ELSE a.fmQty_Each END) WHEN 'YFI' THEN a.fmQty_Each / n.qty WHEN 'UEI' THEN a.fmQty_Each / n.qty ELSE a.fmQty_Each END) * (CASE h.cube WHEN 0 THEN n.cube ELSE h.cube END) END AS QtyCBM,
  E.rate AS ChargeRate,
	case when C.tariffMasterId='BIL00062' THEN (case when clot.lotAtt04='SET' then 0 else (b.cube*a.fmQty_Each *  E.rate ) end) 
	when C.tariffMasterId='BIL00062PIECES' THEN (case when clot.lotAtt04='SET' then 0 else (a.fmQty_Each *  E.rate ) end) ELSE 0 END as BillingAmmount,
  ' ' AS CHARGE_VALUE,
  ' ' AS WRAPPING,
  ' ' AS CEK_DOT,
  ' ' AS OVERTIME_CHARGE,
  ' ' AS STANDYBY_FEE,
  e.CarrierName,
  f.udf02 AS MatdocSAP,
  CASE WHEN a.tocustomerid = 'MAP' THEN b.sku_group3 ELSE '' END AS SKU_GROUP3,
  d1.codedescr AS ASNSTATUS
FROM (SELECT
    *
  FROM ACT_TRANSACTION_LOG
  WHERE transactionType = 'IN'
  AND status = '99') a
  LEFT OUTER JOIN BAS_SKU b
    ON a.organizationId = b.organizationId
    AND a.fmcustomerId = b.customerId
    AND a.fmsku = b.sku
  LEFT OUTER JOIN INV_LOT_ATT clot
    ON a.organizationId = clot.organizationId
    AND a.fmcustomerId = clot.customerId
    AND a.fmlotnum = clot.lotNum
  LEFT OUTER JOIN DOC_ASN_HEADER f
    ON a.organizationId = f.organizationId
    AND a.warehouseId = f.warehouseId
    AND a.docNo = f.asnNo
  LEFT OUTER JOIN (SELECT
      *
    FROM BSM_CODE_ML bcm
    WHERE codeType = 'ASN_TYP'
    AND languageId = 'en') d
    ON a.organizationId = d.organizationId
    AND f.asntype = d.codeid
  LEFT OUTER JOIN (SELECT
      *
    FROM BSM_CODE_ML bcm
    WHERE codeType = 'ASN_STS'
    AND languageId = 'en') d1
    ON f.organizationId = d1.organizationId
    AND f.asnstatus = d1.codeid
  LEFT OUTER JOIN ZCBT01_RECEIPT_TRUCK2 e
    ON a.organizationId = e.organizationId
    AND a.warehouseId = e.warehouseId
    AND a.docNo = e.docNo
  LEFT OUTER JOIN DOC_PO_HEADER g
    ON a.organizationId = g.organizationId
    AND a.warehouseId = g.warehouseId
    AND f.poNo = g.poNo
  LEFT OUTER JOIN (SELECT
      *
    FROM BAS_PACKAGE_DETAILS
    WHERE packUom = 'EA') h
    ON a.organizationId = h.organizationId
    AND b.packId = h.packId
    AND a.fmcustomerId = h.customerid
  LEFT OUTER JOIN (SELECT
      *
    FROM BAS_PACKAGE_DETAILS
    WHERE packUom = 'PL') i
    ON a.organizationId = i.organizationId
    AND b.packId = i.packId
    AND a.fmcustomerId = i.customerid
  LEFT OUTER JOIN (SELECT
      *
    FROM BAS_PACKAGE_DETAILS
    WHERE packUom = 'CS') n
    ON a.organizationId = n.organizationId
    AND b.packId = n.packId
    AND a.fmcustomerId = n.customerid
  LEFT OUTER JOIN BAS_SKU_MULTIWAREHOUSE j
    ON a.organizationId = j.organizationId
    AND a.warehouseId = j.warehouseId
    AND a.fmsku = j.sku
    AND a.fmcustomerId = j.customerId
	LEFT JOIN BIL_TARIFF_HEADER C
												 ON C.ORGANIZATIONID = j.ORGANIZATIONID 
												 AND C.tariffMasterId=j.tariffMasterId
												 LEFT JOIN BIL_TARIFF_DETAILS D 
      ON D.ORGANIZATIONID = C.ORGANIZATIONID 
      AND D.tariffId =C.tariffId
     AND D.CHARGECATEGORY = 'IB' 
     AND D.docType=f.asnType
  --   AND D.RATEBASE = 'CUBIC' OR D.RATEBASE = 'QUANTITY'
    LEFT JOIN BIL_TARIFF_RATE E 
      ON E.ORGANIZATIONID = D.ORGANIZATIONID 
      AND E.TARIFFID = D.TARIFFID 
      AND E.TARIFFLINENO = D.TARIFFLINENO
  LEFT OUTER JOIN RUL_PUTAWAY_HEADER k
    ON a.organizationId = k.organizationId
    AND a.warehouseId = k.warehouseId
    AND k.putawayId = j.putawayRule
  LEFT OUTER JOIN (SELECT
      organizationId,
      warehouseId,
      docNo,
      fmId,
      MAX(toLocation) AS toLocation
    FROM ACT_TRANSACTION_LOG
    WHERE transactionType = 'PA'
    AND status = '99'
    GROUP BY organizationId,
             warehouseId,
             docNo,
             fmId) l
    ON a.organizationId = l.organizationId
    AND a.warehouseId = l.warehouseId
    AND a.docNo = l.docNo
    AND a.toid = l.fmId
  LEFT OUTER JOIN cmlwms_archivedb.MUIDMAPPING m
    ON a.organizationId = m.organizationId
    AND a.warehouseId = m.warehouseId
    AND g.hedi08 = m.B00
WHERE 1 = 1
AND a.organizationId = 'OJV_CML'
AND a.warehouseId = 'CBT01'
  AND f.asnNo IN ('MAPASN0000022')
AND f.asnType NOT IN ('FREE', 'IU')
AND b.skuDescr1 NOT LIKE '%PALLET%'
-- AND j.tariffMasterId = '${tariffMasterId}'
AND a.fmcustomerId = 'MAP'
-- AND CONVERT(a.addtime, date) >= '${billingFromDateFM}'
-- AND CONVERT(a.addtime, date) <= '${billingFromDateTO}'