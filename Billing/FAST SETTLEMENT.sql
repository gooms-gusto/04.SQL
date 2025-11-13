USE wms_cml;

SELECT COUNT(*) FROM BIL_SUMMARY bs WHERE bs.organizationId='OJV_CML' AND bs.warehouseId='CBT02';

SELECT COUNT(*) FROM BIL_SUMMARY bs WHERE bs.organizationId='OJV_CML' AND bs.warehouseId='CBT02';



SELECT *  FROM Z_CML_BILLINGSUMMARYID;
DELETE FROM Z_CML_BILLINGSUMMARYID;

INSERT INTO Z_CML_BILLINGSUMMARYID (organizationId, warehouseId, customerId, billingSummaryId)
SELECT bs.organizationId, bs.warehouseId,bs.customerId,bs.billingSummaryId FROM BIL_SUMMARY bs
WHERE bs.organizationId='OJV_CML' AND bs.warehouseId='CBT02-B2C' AND bs.customerId='ECMAMAB2C'  
AND bs.chargeCategory IN ('OB','IB')
AND date(bs.billingFromDate) >= '2025-09-26' 
AND date(bs.billingFromDate) <= '2025-10-25' AND bs.arNo = '*';


SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT02-B2C';
SET @IN_customerId = 'ECMAMAB2C';
SET @IN_USERID = 'UDFTIMER';
SET @OUT_Return_Code = '';
CALL CML_BILLSUMMARYPROCESS_MANUAL(@IN_organizationId, @IN_warehouseId, @IN_customerId, @IN_USERID, @OUT_Return_Code);
SELECT
  @OUT_Return_Code;



SELECT bs.organizationId, bs.warehouseId,bs.customerId,bs.billingSummaryId FROM BIL_SUMMARY bs
WHERE bs.organizationId='OJV_CML' AND bs.warehouseId='CBT02-B2C' AND bs.customerId='ECMAMAB2C' 
AND bs.chargeCategory='OB'
AND date(bs.billingFromDate) >= '2025-08-26' 
AND date(bs.billingFromDate) <= '2025-09-25' AND bs.arNo = '*';


SELECT bs.organizationId, bs.warehouseId,bs.customerId,bs.billingSummaryId FROM BIL_SUMMARY bs
WHERE bs.organizationId='OJV_CML' AND bs.warehouseId='CBT02-B2C' AND bs.customerId='ECMAMAB2C' 
AND bs.chargeCategory='OB'
AND date(bs.billingFromDate) >= '2025-08-26' 
AND date(bs.billingFromDate) <= '2025-09-25' AND bs.arNo = '*';



-- USE wms_cml;
-- 
-- UPDATE BIL_SUMMARY SET arNo = '*' 
-- WHERE organizationId = 'OJV_CML' AND warehouseId = 'CBT02' AND 
-- arNo='ARC250226000004'
-- AND date(billingFromDate) >= '2025-01-26' 
-- AND date(billingFromDate) <= '2025-02-25';



-- SHOW PROCESSLIST;


SELECT * FROM BIL_SUMMARY bs WHERE bs.organizationId='OJV_CML' AND bs.warehouseId='CBT02' AND bs.customerId='MAP' 
AND bs.chargeCategory='OB'
AND date(bs.billingFromDate) >= '2025-02-26' 
AND date(bs.billingFromDate) <= '2025-03-25'   LIMIT 1

 AND bs.arNo IS NULL