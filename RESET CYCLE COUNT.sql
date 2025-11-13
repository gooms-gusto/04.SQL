USE wms_cml;

SELECT
  zcd.idDocumentCycle,
  zcd.idDocumentDetailCycle,
  zcd.qtyOnHand,
  zcd.count1,
  zcd.count2,
  zcd.count3,
  zcd.countStatus,
  zcd.count1Status,
  zcd.count2Status,
  zcd.count3Status,
  zcd.udf01,
  zcd.countFinal,
  zcd.countDifferent
FROM Z_CYCLECOUNT_DETAIL zcd
WHERE zcd.idDocumentCycle = 'CY250625000000002'
AND zcd.groupIdTask = 'GROUP 1';


SELECT
  *
FROM Z_CYCLECOUNT_DETAIL
WHERE Z_CYCLECOUNT_DETAIL.ORGANIZATIONID = 'OJV_CML'
AND Z_CYCLECOUNT_DETAIL.WAREHOUSEID = 'CBT01'
AND UPPER(groupIdTask) = 'GROUP 1'
AND idDocumentCycle = 'CY250625000000002';

UPDATE Z_CYCLECOUNT_DETAIL
SET count1 = NULL,
    count2 = NULL,
    count3 = NULL,
    countDifferent = NULL,
    countFinal = NULL,
    udf01 = NULL,
    count1Status = 'N',
    count2Status = 'N',
    count3Status = 'N'
WHERE Z_CYCLECOUNT_DETAIL.ORGANIZATIONID = 'OJV_CML'
AND Z_CYCLECOUNT_DETAIL.WAREHOUSEID = 'CBT01'
AND UPPER(groupIdTask) = 'GROUP 1'
AND idDocumentCycle = 'CY250625000000002';


