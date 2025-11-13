
SELECT * from INV_LOT_LOC_ID illi WHERE illi.locationId  IN(
SELECT bl.locationId FROM BAS_LOCATION bl WHERE bl.locationUsage = 'NU' AND bl.warehouseId IN ('CBT01','CBT02')) AND illi.warehouseId IN ('CBT01','CBT02') AND illi.locationId NOT LIKE 'TML%' AND illi.qty> 0;


SELECT DISTINCT bpd.packUom FROM BAS_PACKAGE_DETAILS bpd;

SELECT DISTINCT bp.packId FROM BAS_PACKAGE_DETAILS bp;


SELECT * FROM BSM_CODE bc WHERE bc.codeType='RAT_BAS' and bc.activeFlag='Y';

SELECT * FROM BIL_TARIFF_HEADER bth WHERE bth.tariffMasterId='BIL00TEST01'

