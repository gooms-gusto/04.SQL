USE wms_cml;









USE wms_cml;

SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT01';
SET @IN_Language = 'en';
SET @IN_Sequence_Name = 'BILLINGSUMMARYID';
SET @OUT_ReturnNo = '';
SET @OUT_Return_Code ='';
CALL SPCOM_GetIDSequence_NEW(@IN_organizationId, @IN_warehouseId, @IN_Language, @IN_Sequence_Name, @OUT_ReturnNo, @OUT_Return_Code);
SELECT
  @OUT_ReturnNo,
  @OUT_Return_Code;



SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT02';
SET @IN_USERID = 'EDI';
SET @IN_Language = 'en';
SET @IN_CustomerId = 'MAP';
SET @IN_trans_no = 'SAMASN0002180';
SET @IN_tariffMaster = '00';
CALL CML_BILLHISTD(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @IN_tariffMaster);


SELECT * FROM BAS_MANPOWER bm WHERE bm.CustomerID='LTL'