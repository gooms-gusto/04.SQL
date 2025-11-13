USE wms_cml;

INSERT INTO DOC_ORDER_HEADER (organizationId, warehouseId, orderNo, 
orderType, soStatus, orderTime, expectedShipmentTime1, expectedShipmentTime2,
 requiredDeliveryTime, customerId, soReference1, soReference2, soReference3,
 soReference4, soReference5, releaseStatus, priority, consigneeId, 
 consigneeName, consigneeAddress1, consigneeAddress2, consigneeAddress3, 
 consigneeAddress4, consigneeCity, consigneeProvince, consigneeCountry, 
 consigneeZip, consigneeContact, consigneeEmail, consigneeFax, consigneeTel1,
 consigneeTel2, billingId, billingName, billingAddress1, billingAddress2, 
 billingAddress3, billingAddress4, billingCity, billingProvince, billingCountry,
 billingZip, billingContact, billingEmail, billingFax, billingTel1, billingTel2,
 deliveryTerms, deliveryTermsDescr, paymentTerms, paymentTermsDescr, transportation,
 door, route, placeOfLoading, placeOfDischarge, placeOfDelivery, carrierId, 
 carrierName, carrierAddress1, carrierAddress3, carrierAddress2, carrierAddress4,
 carrierCity, carrierProvince, carrierCountry, carrierZip, carrierContact,
 carrierEmail, carrierFax, carrierTel1, carrierTel2, issuePartyId, issuePartyName,
 issuePartyAddress1, issuePartyAddress2, issuePartyAddress3, issuePartyAddress4, 
 issuePartyCity, issuePartyProvince, issuePartyCountry, issuePartyZip, 
 issuePartyContact, issuePartyEmail, issuePartyFax, issuePartyTel1, issuePartyTel2,
 hedi01, hedi02, hedi03, hedi04, hedi05, hedi06, hedi07, hedi08, hedi09, hedi10,
 ediSendFlag, ediSendTime1, ediSendTime2, ediSendTime3, ediSendTime4, ediSendTime5, 
 pickingPrintFlag, orderPrintFlag, rfGetTask, erpCancelFlag, singleMatch, 
 serialNoCatch, requireDeliveryNo, archiveFlag, ful_alc, channel, expressPrintFlag, 
 deliveryNotePrintFlag, weightingFlag, allowShipment, ediCarrierFlag, udfPrintFlag1, 
 udfPrintFlag2, udfPrintFlag3, lastShipmentTime, createSource, zoneGroup, 
 medicalXmlTime, followUp, userDefineA, userDefineB, invoicePrintFlag, invoiceNo, 
 invoiceTitle, invoiceType, invoiceItem, invoiceAmount, salesOrderno, putToLocation, 
 deliveryNo, allocationCount, waveNo, cartonGroup, cartonId, orderGroupNo, 
 transServiceLevel, orderHandleInstruction, totalCubic, totalGrossWeight, 
 totalNetWeight, totalPrice, totalLineCount, curLineNo, totalSkuCount, noteText,
 udf01, udf02, udf03, udf04, udf05, udf06, currentVersion, oprSeqFlag, addWho, 
 addTime, editWho, editTime, locGroup1List, locGroup2List, allowPartialShip,
 waveRule, consigneeDistrict, consigneeStreet, carrierDistrict, carrierStreet,
 billingDistrict, billingStreet, issuePartyDistrict, issuePartyStreet, parcelMark, 
 parcelConsolidation, stopStation, warehouseTransferFlag, shipmentCount, udf08, 
 erpCancelReason, ediSendTime, ediErrorCode, ediErrorMessage, ediSendFlag2, 
 ediErrorCode2, ediErrorMessage2, ediSendFlag3, ediErrorCode3, ediErrorMessage3,
 expressPlatform, udf09, udf10, udf07, ocpNo, vehicleNo, vehicleType, driver,
 hedi11, hedi12, hedi13, hedi14, hedi15, hedi16, hedi17, hedi18, hedi19, hedi20,
 splitFlag, reverseOrderNo, orderSource, shop, taskFlag, rpGroupId, totalQty)
VALUES(
  'OJV_CML', 'CBT02', 'SAMSOTEST387004', 'SO',
  '00', '2025-11-11 00:00:00', '2025-11-12 00:00:00', 
  NULL, NULL, 'PT.ABC', '073085TEST-4', '073085TEST-4', 
  'BANTI POWERINDO', NULL, NULL, 'Y', '3', '0001389981', 
  'AMALINDO INDONESIA', 'JL. RAYA BEKASI GG. AIRPUTIH',
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
  NULL, NULL, NULL, 0.00000000, 0.00000000, 'Y', NULL, 
  NULL, NULL, NULL, NULL, 'Y', 'N', 'N', 'N', 'N', 'N', NULL,
  'N', 'Y', '*', 'N', 'Y', 'N', 'Y', 'N', 'N', 'N', 'N', 
  '2025-11-11 21:50:20', 'EDI', NULL, NULL, NULL, NULL, NULL, 'N', NULL,
  NULL, NULL, NULL, NULL, NULL, NULL, '*', 1, '', NULL,
  NULL, NULL, NULL, NULL, 0.00000000, 0.00000000, 0.00000000, 0.00000000, 
  0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 212, 
  '20251111215019000179RA172031009090[A3001]', 'EDI',
  '2025-11-11 10:45:04', 'CHKMAP-01', '2025-11-11 21:50:21',
  NULL, NULL, 'Y', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
  NULL, NULL, NULL, NULL, NULL, 'N', 0, NULL, NULL, NOW(), 
  NULL, NULL, 'N', NULL, NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL, 
  NULL, NULL, NULL, NULL, 'SAL', NULL, NULL, NULL, NULL, NULL, NULL, NULL,
  NULL, NULL, 'N', NULL, NULL, NULL, 'N', '*', NULL);




USE wms_cml;

INSERT INTO DOC_ORDER_DETAILS (organizationId, warehouseId, orderNo, orderLineNo, customerId, sku, lineStatus, lotNum, lotAtt01, lotAtt02, lotAtt03, lotAtt04, lotAtt05, lotAtt06, lotAtt07, lotAtt08, lotAtt09, lotAtt10, lotAtt11, lotAtt12, pickZone, location, traceId, qtyOrdered, qtySoftAllocated, qtyAllocated, qtyPicked, qtyShipped, packId, packUom, qtyOrdered_each, qtySoftAllocated_each, qtyAllocated_each, qtyPicked_each, qtyShipped_each, rotationId, softAllocationRule, allocationRule, grossWeight, netWeight, cubic, price, dedi01, dedi02, dedi03, dedi04, dedi05, dedi06, dedi07, dedi08, dedi09, dedi10, dedi11, dedi12, dedi13, dedi14, dedi15, dedi16, dedi17, dedi18, dedi19, dedi20, alternativeSku, kitReferenceNo, orderLineReferenceNo, kitSku, erpCancelFlag, zoneGroup, locGroup1, locGroup2, commingleSku, ONESTEPALLOCATION, orderLotControl, fullCaseLotControl, pieceLotControl, referenceLineNo, salesOrderNo, salesOrderLineNo, qtyReleased, rule3Flag, pickInstruction, noteText, udf01, udf02, udf03, udf04, udf05, udf06, currentVersion, oprSeqFlag, addWho, addTime, editWho, editTime, lotAtt13, lotAtt14, lotAtt15, lotAtt16, lotAtt17, lotAtt18, lotAtt19, lotAtt20, lotAtt21, lotAtt22, lotAtt23, lotAtt24, freePickGift, allocationWhereSQL, refLineNo, originalSku) VALUES
('OJV_CML', 'CBT02', 'SAMSOTEST387004', 1, 'PT.ABC', '0000000000001519341466', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL, '*', 10.00000000, 0, 0, 0, 0, '1/0/1/20-40X24X59', 'EA', 10.00000000, 0, 0, 0, 0, 'PT.ABC', 'PACK_EA', 'ALLOC_CML', 35.00000000, 0.00000000, 0.56640000, 0.00000000, NULL, '1', '900001', NULL, NULL, NULL, '000000000000151934', '1466', 0.00000000, 0.00000000, '1CNU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL, 'Y', 'Y', 'N', 'N', 'N', NULL, NULL, NULL, 0.00000000, 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 118, '20251111210807000422RA172031009091[A3001]', 'EDI', '2025-11-11 10:45:04', 'CHKMAP-01', '2025-11-11 21:50:21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL);

INSERT INTO DOC_ORDER_DETAILS (organizationId, warehouseId, orderNo, orderLineNo, customerId, sku, lineStatus, lotNum, lotAtt01, lotAtt02, lotAtt03, lotAtt04, lotAtt05, lotAtt06, lotAtt07, lotAtt08, lotAtt09, lotAtt10, lotAtt11, lotAtt12, pickZone, location, traceId, qtyOrdered, qtySoftAllocated, qtyAllocated, qtyPicked, qtyShipped, packId, packUom, qtyOrdered_each, qtySoftAllocated_each, qtyAllocated_each, qtyPicked_each, qtyShipped_each, rotationId, softAllocationRule, allocationRule, grossWeight, netWeight, cubic, price, dedi01, dedi02, dedi03, dedi04, dedi05, dedi06, dedi07, dedi08, dedi09, dedi10, dedi11, dedi12, dedi13, dedi14, dedi15, dedi16, dedi17, dedi18, dedi19, dedi20, alternativeSku, kitReferenceNo, orderLineReferenceNo, kitSku, erpCancelFlag, zoneGroup, locGroup1, locGroup2, commingleSku, ONESTEPALLOCATION, orderLotControl, fullCaseLotControl, pieceLotControl, referenceLineNo, salesOrderNo, salesOrderLineNo, qtyReleased, rule3Flag, pickInstruction, noteText, udf01, udf02, udf03, udf04, udf05, udf06, currentVersion, oprSeqFlag, addWho, addTime, editWho, editTime, lotAtt13, lotAtt14, lotAtt15, lotAtt16, lotAtt17, lotAtt18, lotAtt19, lotAtt20, lotAtt21, lotAtt22, lotAtt23, lotAtt24, freePickGift, allocationWhereSQL, refLineNo, originalSku) VALUES
('OJV_CML', 'CBT02', 'SAMSOTEST387004', 2, 'PT.ABC', '0000000000001519341041', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL, '*', 50.00000000, 0, 0, 0, 0, '1/0/1/20-42X22X60', 'EA', 50.00000000, 0, 0, 0, 0, 'PT.ABC', 'PACK_EA', 'ALLOC_CML', 0.00000000, 0.00000000, 2.77200000, 0.00000000, NULL, '2', '900002', NULL, NULL, NULL, '000000000000151934', '1041', 0.00000000, 0.00000000, '1CNU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL, 'Y', 'Y', 'N', 'N', 'N', NULL, NULL, NULL, 0.00000000, 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 120, '20251111214502000162RA172031009090[A3001]', 'EDI', '2025-11-11 10:45:04', 'CHKMAP-01', '2025-11-11 21:50:21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL);

INSERT INTO DOC_ORDER_DETAILS (organizationId, warehouseId, orderNo, orderLineNo, customerId, sku, lineStatus, lotNum, lotAtt01, lotAtt02, lotAtt03, lotAtt04, lotAtt05, lotAtt06, lotAtt07, lotAtt08, lotAtt09, lotAtt10, lotAtt11, lotAtt12, pickZone, location, traceId, qtyOrdered, qtySoftAllocated, qtyAllocated, qtyPicked, qtyShipped, packId, packUom, qtyOrdered_each, qtySoftAllocated_each, qtyAllocated_each, qtyPicked_each, qtyShipped_each, rotationId, softAllocationRule, allocationRule, grossWeight, netWeight, cubic, price, dedi01, dedi02, dedi03, dedi04, dedi05, dedi06, dedi07, dedi08, dedi09, dedi10, dedi11, dedi12, dedi13, dedi14, dedi15, dedi16, dedi17, dedi18, dedi19, dedi20, alternativeSku, kitReferenceNo, orderLineReferenceNo, kitSku, erpCancelFlag, zoneGroup, locGroup1, locGroup2, commingleSku, ONESTEPALLOCATION, orderLotControl, fullCaseLotControl, pieceLotControl, referenceLineNo, salesOrderNo, salesOrderLineNo, qtyReleased, rule3Flag, pickInstruction, noteText, udf01, udf02, udf03, udf04, udf05, udf06, currentVersion, oprSeqFlag, addWho, addTime, editWho, editTime, lotAtt13, lotAtt14, lotAtt15, lotAtt16, lotAtt17, lotAtt18, lotAtt19, lotAtt20, lotAtt21, lotAtt22, lotAtt23, lotAtt24, freePickGift, allocationWhereSQL, refLineNo, originalSku) VALUES
('OJV_CML', 'CBT02', 'SAMSOTEST387004', 3, 'PT.ABC', '0000000000001499981041', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL, '*', 10.00000000, 0, 0, 0, 0, '1/0/1/20-39X26X58', 'EA', 10.00000000, 0, 0, 0, 0, 'PT.ABC', 'PACK_EA', 'ALLOC_CML', 36.80000000, 0.00000000, 0.58812000, 0.00000000, NULL, '3', '900003', NULL, NULL, NULL, '000000000000149998', '1041', 0.00000000, 0.00000000, '1INU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL, 'Y', 'Y', 'N', 'N', 'N', NULL, NULL, NULL, 0.00000000, 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 116, '20251111210807000422RA172031009091[A3001]', 'EDI', '2025-11-11 10:45:04', 'CHKMAP-01', '2025-11-11 21:50:21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL);

INSERT INTO DOC_ORDER_DETAILS (organizationId, warehouseId, orderNo, orderLineNo, customerId, sku, lineStatus, lotNum, lotAtt01, lotAtt02, lotAtt03, lotAtt04, lotAtt05, lotAtt06, lotAtt07, lotAtt08, lotAtt09, lotAtt10, lotAtt11, lotAtt12, pickZone, location, traceId, qtyOrdered, qtySoftAllocated, qtyAllocated, qtyPicked, qtyShipped, packId, packUom, qtyOrdered_each, qtySoftAllocated_each, qtyAllocated_each, qtyPicked_each, qtyShipped_each, rotationId, softAllocationRule, allocationRule, grossWeight, netWeight, cubic, price, dedi01, dedi02, dedi03, dedi04, dedi05, dedi06, dedi07, dedi08, dedi09, dedi10, dedi11, dedi12, dedi13, dedi14, dedi15, dedi16, dedi17, dedi18, dedi19, dedi20, alternativeSku, kitReferenceNo, orderLineReferenceNo, kitSku, erpCancelFlag, zoneGroup, locGroup1, locGroup2, commingleSku, ONESTEPALLOCATION, orderLotControl, fullCaseLotControl, pieceLotControl, referenceLineNo, salesOrderNo, salesOrderLineNo, qtyReleased, rule3Flag, pickInstruction, noteText, udf01, udf02, udf03, udf04, udf05, udf06, currentVersion, oprSeqFlag, addWho, addTime, editWho, editTime, lotAtt13, lotAtt14, lotAtt15, lotAtt16, lotAtt17, lotAtt18, lotAtt19, lotAtt20, lotAtt21, lotAtt22, lotAtt23, lotAtt24, freePickGift, allocationWhereSQL, refLineNo, originalSku) VALUES
('OJV_CML', 'CBT02', 'SAMSOTEST387004', 4, 'PT.ABC', '0000000000001499981635', '00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL, '*', 16.00000000, 0, 0, 0, 0, '1/0/1/20-39X26X58', 'EA', 16.00000000, 0, 0, 0, 0, 'PT.ABC', 'PACK_EA', 'ALLOC_CML', 58.88000000, 0.00000000, 0.94099200, 0.00000000, NULL, '4', '900004', NULL, NULL, NULL, '000000000000149998', '1635', 0.00000000, 0.00000000, '1INU', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL, 'Y', 'Y', 'N', 'N', 'N', NULL, NULL, NULL, 0.00000000, 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 118, '20251111210807000422RA172031009091[A3001]', 'EDI', '2025-11-11 10:45:04', 'CHKMAP-01', '2025-11-11 21:50:21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'N', NULL, NULL, NULL);

