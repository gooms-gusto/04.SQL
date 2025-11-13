USE wms_cml;
INSERT INTO BIL_TARIFF_HEADER (organizationId, warehouseId, tariffId, tariffDescr, effectiveFrom, effectiveTo, minAmount, maxAmount, confirmBy, confirmTime, cancelConfirmBy, cancelConfirmTime, noteText, udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag, addWho, addTime, editWho, editTime, invChgWithShipment, bilOutboundStock, contractNo, subContractNo, signOffDate, billingDate, settlementCycle, bank, bankAccountName, bankAccountNo, vat, billClassIO, billClassInv, discountStart, discountRate, billWithAsnType, billWithSoType, nextBillingDate, tariffMasterId, billClassIB, billClassOB, UDF06)
  VALUES ('OJV_CML', '*', 'BIL00310', 'PT. Hasa Prima Kimia', '	
2023-01-01 00:00:00', '	
2023-12-31 23:59:59', 1.00000000, 9999999999999.00000000, NULL, NULL, NULL, NULL,'',
 '1630', '', '', '', '', 102, '20221231140754000700RA172031009091[A3701]', 'WM_ANGGAR', 
'2022-12-13 13:59:57', 'WM_LAUREN', '2022-12-31 14:07:54', 'N', 'N', 'ADDM/022/HPK-LL/V1/12/22',
 NULL, '2022-12-14 00:00:00', '2023-01-26 00:00:00', 'MONTHS', '', '', '', '', 'TRAN', 'SKU', 
NULL, NULL, 'Y', 'Y', '2023-01-26 00:00:00', 'BIL00036', NULL, NULL, NULL);
