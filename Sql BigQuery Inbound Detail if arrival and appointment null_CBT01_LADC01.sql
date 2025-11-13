SELECT 	a.organizationId, a.warehouseId, a.customerId,  a.asnNo, a.asnReference1, dad.appointmentno, dah.arrivalNo, a.asnType, c2.asnTypeName, a.asnStatus, c1.asnStatusName,
				atl.toSku, s.skuDescr1, atl.toLotNum, atl.toLocation, atl.toId, atl.toUom, atl.toQty, atl.toQty_Each, 
                CAST(atl.transactionTime AS TIMESTAMP) AS transactionTime,
				lla.lotAtt01 AS prodDate, lla.lotAtt02 AS expDate, lla.lotAtt03 AS receiptDate, lla.lotAtt04 AS batchNo, lla.lotAtt07 AS palletType, 
				lla.lotAtt08 AS whetherDamaged, lla.lotAtt09 AS poNo, lla.lotAtt10 AS InforLotNumber,
				a.supplierId, a.supplierName, dah.vehicleType, dah.driver, dah.vehicleNo, dah.dockNo AS dockNo, 
			 CAST(a.asnCreationTime AS TIMESTAMP) AS asnCreationTime, 
				 CAST(a.expectedArriveTime1 AS TIMESTAMP) AS expectedArriveTime1, 
				 CAST(dah.appointmentStartTime AS TIMESTAMP) AS appointmentStartTime, 
				 CAST(dah.appointmentEndTime AS TIMESTAMP) AS appointmentEndTime, 
				 CAST(dah.arriveTime AS TIMESTAMP) AS arriveTime, 
				 CAST(dah.entranceTime AS TIMESTAMP) AS entranceTime,
				 CAST(dah.startTime AS TIMESTAMP) AS startUnloadTime, 
				 CAST(dah.endTime AS TIMESTAMP) AS endUnloadTime,
				 CAST(dah.leaveTime AS TIMESTAMP) AS leaveTime		
FROM 	wms_cml.DOC_ASN_HEADER a
LEFT JOIN wms_cml.ACT_TRANSACTION_LOG atl ON a.organizationId = atl.organizationId AND a.warehouseId = atl.warehouseId AND a.asnNo=atl.docNo AND transactionType='IN' AND atl.docType='ASN'
LEFT JOIN wms_cml.INV_LOT_ATT lla ON lla.organizationId = atl.organizationId AND lla.lotNum = atl.toLotNum AND lla.sku = atl.toSku
LEFT JOIN wms_cml.BAS_SKU s ON s.organizationId = s.organizationId AND s.customerId = atl.toCustomerId AND s.sku = atl.toSku
LEFT JOIN wms_cml.DOC_APPOINTMENT_DETAILS ad ON a.organizationId = ad.organizationId AND a.warehouseId = ad.warehouseId AND a.asnNo=ad.poNo AND ad.docType IN ('ASN','PO')
LEFT JOIN wms_cml.DOC_APPOINTMENT_HEADER ah ON a.organizationId = ah.organizationId AND a.warehouseId = ah.warehouseId AND ad.appointmentNo = ah.appointmentNo
LEFT JOIN wms_cml.DOC_ARRIVAL_DETAILS dad ON a.organizationId = dad.organizationId AND a.warehouseId = dad.warehouseId AND dad.appointmentNo = ah.appointmentNo AND LEFT(dad.appointmentno,3) ='INB'
LEFT JOIN wms_cml.DOC_ARRIVAL_HEADER dah ON a.organizationId = dah.organizationId AND a.warehouseId = dah.warehouseId AND dah.arrivalno = dad.arrivalno AND appointmentType='PO'
INNER JOIN
(
	SELECT codeId, codeDescr as asnStatusName from wms_cml.BSM_CODE_ML 
	WHERE codeType='ASN_STS' AND languageId='en'
)
c1 on c1.codeId = a.asnStatus
INNER JOIN
(
	SELECT codeId, codeDescr as asnTypeName from wms_cml.BSM_CODE_ML 
	WHERE codeType='ASN_TYP' AND languageId='en'
)
c2 on c2.codeId = a.asnType
WHERE 1=1 AND a.organizationId='OJV_CML' AND a.warehouseId IN('CBT01','LADC01') AND dah.arrivalNo is null and dad.appointmentNo is null
ORDER BY a.customerId, a.asnCreationTime