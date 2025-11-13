SELECT http_post(
    'http://omahkudewe.asia:8765/webhook/8cb1febe-51dc-4398-9110-1cfc403545f1',    
(SELECT JSON_ARRAYAGG(
    JSON_OBJECT(
        'organizationId', organizationId,
        'warehouseId', warehouseId,
        'warehouseDescr', warehouseDescr,
        'activeFlag', activeFlag
    )
) AS json_result
FROM BSM_WAREHOUSE));


USE WMS_FTEST;
SELECT * FROM BSM_WAREHOUSE bw  ;


USE wms_cml;

SELECT  auto_sequence() AS row_num,
  organizationId,
  warehouseId,
  warehouseDescr,
  activeFlag,
  warehouseType,
  branchId,
  noteText,
  udf01,
  udf02,
  udf03,
  udf04,
  udf05,
  currentVersion,
  oprSeqFlag,
  addWho,
  addTime,
  editWho,
  editTime
FROM BSM_WAREHOUSE;



USE WMS_FTEST;

SELECT
  organizationId,
  warehouseId,
  warehouseDescr,
  activeFlag
FROM BSM_WAREHOUSE;