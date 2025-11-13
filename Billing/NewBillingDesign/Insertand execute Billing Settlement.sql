
SELECT * from Z_CML_BILLINGSUMMARYID zcb

DELETE
  FROM  
   Z_CML_BILLINGSUMMARYID ;


USE wms_cml;

INSERT INTO Z_CML_BILLINGSUMMARYID
(
  organizationId
 ,warehouseId
 ,customerId
 ,billingSummaryId
)
SELECT 'OJV_CML','CBT01','LTL',billingSummaryId from BIL_SUMMARY where organizationId = 'OJV_CML' and warehouseId = 'CBT01' and customerId = 'LTL' and arNo = '*'
and tariffId in ('BIL00866','BIL00624','BIL00864','BIL00619') and billingFromDate between '2024-12-26' AND '2025-01-25';



USE wms_cml;

SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT01';
SET @IN_customerId = 'LTL';
SET @IN_USERID = 'WM_MARDIANSAH';
SET @OUT_Return_Code = '';
CALL CML_BILLSUMMARYPROCESS_MANUAL(@IN_organizationId, @IN_warehouseId, @IN_customerId, @IN_USERID, @OUT_Return_Code);
SELECT
  @OUT_Return_Code;