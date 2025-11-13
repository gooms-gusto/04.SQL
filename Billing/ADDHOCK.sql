USE wms_cml;

SELECT * FROM BIL_SUMMARY bs WHERE YEAR(bs.addTime)='2024' AND MONTH(bs.addTime)='10' AND bs.organizationId='OJV_CML' ORDER BY bs.billingSummaryId DESC


SELECT * FROM BIL_SUMMARY bs WHERE YEAR(bs.addTime)='2024' 
AND bs.organizationId='OJV_CML' AND bs.customerId='ARCHROMA' AND bs.warehouseId='CBT03';

SELECT * FROM SYS_IDSEQUENCE_ML sim WHERE sim.warehouseId='CBT03' AND sim.organizationId='OJV_CML' AND sim.idName='BILLINGSUMMARYID';


SELECT * FROM SYS_IDSEQUENCE sim WHERE sim.warehouseId='CBT03' AND sim.organizationId='OJV_CML' AND sim.idName='BILLINGSUMMARYID';

  sio WHERE  sim.organizationId='OJV_CML' AND sim.idName='BILLINGSUMMARYID';

INSERT INTO BIL_SUMMARY (organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate, customerId, sku, lotNum, traceId, tariffId, chargeCategory, chargeType, descr, rateBase, chargePerUnits, qty, uom, cubic, weight, chargeRate, amount, billingAmount, cost, amountPayable, amountPaid, confirmTime, confirmWho, docType, docNo, createTransactionid, notes, ediSendTime, billTo, settleTime, settleWho, followUp, invoiceType, paidTo, costConfirmFlag, costConfirmTime, costConfirmWho, costSettleFlag, costSettleTime, costSettleWho, incomeTaxRate, costTaxRate, incomeTax, cosTax, incomeWithoutTax, cosWithoutTax, costInvoiceType, noteText, udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag, addWho, addTime, editWho, editTime, locationCategory, manual, docLineNo, arNo, arLineNo, apNo, apLineNo, ediSendFlag, ediErrorCode, ediErrorMessage, ediSendTime2, ediSendFlag2, ediErrorCode2, ediErrorMessage2, billingTranCategory, orderType, containerType, containerSize) VALUES
('OJV_CML', 'CBT03', 'INV000128', '2024-10-31', '2024-10-31', 'ARCHROMA', NULL, NULL, NULL, 'BIL00800', 'EH', 'EH', 'ManPowerCost', 'MONTH', 1, 1, NULL, NULL, NULL, 63477157.00000, 63477157.00000, 63477157.00000, 0.00000000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'CBT03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1700000033', 'X', NULL, '62', NULL, 100, '2016', 'UDFTIMER', '2024-10-31 14:15:00', 'UDFTIMER', '2024-09-26 07:00:00', NULL, NULL, NULL, '*', NULL, '*', NULL, 'N', NULL, NULL, NULL, 'N', NULL, NULL, NULL, NULL, NULL, NULL);

USE wms_cml;

INSERT INTO BIL_SUMMARY (organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate, customerId, sku, lotNum, traceId, tariffId, chargeCategory, chargeType, descr, rateBase, chargePerUnits, qty, uom, cubic, weight, chargeRate, amount, billingAmount, cost, amountPayable, amountPaid, confirmTime, confirmWho, docType, docNo, createTransactionid, notes, ediSendTime, billTo, settleTime, settleWho, followUp, invoiceType, paidTo, costConfirmFlag, costConfirmTime, costConfirmWho, costSettleFlag, costSettleTime, costSettleWho, incomeTaxRate, costTaxRate, incomeTax, cosTax, incomeWithoutTax, cosWithoutTax, costInvoiceType, noteText, udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag, addWho, addTime, editWho, editTime, locationCategory, manual, docLineNo, arNo, arLineNo, apNo, apLineNo, ediSendFlag, ediErrorCode, ediErrorMessage, ediSendTime2, ediSendFlag2, ediErrorCode2, ediErrorMessage2, billingTranCategory, orderType, containerType, containerSize) VALUES
('OJV_CML', 'CBT03', 'INV000129', '2024-10-31', '2024-10-31', 'ARCHROMA', '', '', '', 'BIL00800', 'FX', 'MI', 'MHE', 'MONTH', 1.000, 1.00000000, '', NULL, NULL, 35000000.00000000, 35000000.00000000, 35000000.00000000, 0.00000000, 0.00000000, NULL, NULL, '', '', '', NULL, NULL, NULL, 'CBT03', NULL, '', '', NULL, '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '', '1700000033', 'X', '', '62', '', 101, '20241101143901000228RA172031009091[A3702]', 'UDFTIMER', '2024-10-31 14:16:00', 'UDFTIMER', '2024-11-01 14:16:00', '', '', NULL, '*', NULL, '*', NULL, 'N', NULL, NULL, NULL, 'N', NULL, NULL, NULL, '', '', '');

SHOW PROCESSLIST