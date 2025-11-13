USE wms_cml;

-- MAP

INSERT INTO BIL_CRM_HEADER (organizationId, warehouseId, OpportunityId, AgreementNo, CustomerId, effectiveFrom, effectiveTo, addWho, addTime, oprSeqFlag, currentVersion) VALUES
('OJV_CML', 'CBT01', '0060k00000G5fA0MAP', 'Contract-0000000012', '3000007662', '2023-01-01 00:00:00', '2023-12-31 00:00:00', 'EDI', '2023-08-24 00:00:00', '2016', 100);


INSERT INTO BIL_CRM_DETAILS (organizationId, warehouseid, OpportunityId, ProductCode, ProductDescr, rate, uom, addWho, addTime, oprSeqFlag, currentVersion) VALUES
('OJV_CML', 'CBT01', '0060k00000G5fA0MAP', '1700000045', 'Handling In',  55400, 'Pieces', 'EDI', '2023-08-24 00:00:00', '2016', 100);


INSERT INTO BIL_CRM_DETAILS (organizationId, warehouseid, OpportunityId, ProductCode, ProductDescr, rate, uom, addWho, addTime, oprSeqFlag, currentVersion) VALUES
('OJV_CML', 'CBT01', '0060k00000G5fA0MAP', '8888888888', 'Handling In',  110800, 'Pieces', 'EDI', '2023-08-24 00:00:00', '2016', 100);



SELECT * FROM BIL_CRM_HEADER bch WHERE bch.OpportunityId='0060k00000G5fA0MAP';
SELECT * FROM BIL_CRM_DETAILS  bch WHERE bch.OpportunityId='0060k00000G5fA0MAP';



