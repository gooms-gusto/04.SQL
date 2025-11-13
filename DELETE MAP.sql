SELECT * FROM BIL_SUMMARY bs WHERE bs.organizationId='OJV_CML'
AND bs.warehouseId='CBT02' AND bs.billingFromDate > getBillFMDate(25) AND bs.chargeCategory IN ('IB','OB')
AND bs.arNo='*';


SELECT * FROM BIL_SUMMARY bs WHERE bs.organizationId='OJV_CML'
AND bs.warehouseId='JBK01' AND bs.billingFromDate > getBillFMDate(25) AND bs.chargeCategory IN ('IB','OB')
AND bs.arNo='*';

