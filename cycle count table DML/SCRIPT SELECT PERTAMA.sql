           SELECT
  idDocumentDetailCycle AS @HIDE_IDDOCUMENTDETAILCYCLE@,
  idDocumentCycle AS @HIDE_IDDOCUMENTCYCLE@,
  countingSequence AS @HIDE_COUNTINGSEQUENCE@,
  location AS @LBL_LOCATION@,
  sku AS @LBL_SKU@,
  skuDescr AS @LBL_DESCRSKU@,
  qtyOnHand AS @LBL_QTY@,
  uom AS @LBL_UOM@,
  batch AS @LBL_BATCH@,
  expDate AS @LBL_EXPIRED@,
  traceId AS @LBL_TRACEID@ ,
  count1 AS @HIDE_COUNT1@,
  count2 AS @HIDE_COUNT2@,
  count3 AS @HIDE_COUNT3@,
  countFinal AS @HIDE_COUNTFINAL@,
  COUNTDIFFERENT AS @HIDE_COUNTDIFFERENT@,
  COUNTSTATUS AS @HIDE_COUNTSTATUS@ ,
  FINDINGFLAG AS @HIDE_FINDINGFLAG@,
  CUSTOMERID AS @LBL_CUSTOMERID@,
  UPPER(GROUPIDTASK) AS @LBL_GROUPIDTASK@,
UPPER(GROUPIDTASK) AS @HIDE_GROUPTASKID@,
  CASE 
        WHEN count1Status = 'N' AND count2Status = 'N' AND count3Status = 'N' THEN 'C1'
        WHEN count1Status = 'Y' AND count2Status = 'N' AND count3Status = 'N' THEN 'C2'
        WHEN count1Status = 'Y' AND count2Status = 'Y' AND count3Status = 'N' THEN 'C3'
        ELSE 'COMPLETED'
    END AS @LBL_COUNTING_POSITION@,
CASE 
        WHEN count1Status = 'N' AND count2Status = 'N' AND count3Status = 'N' THEN count1
        WHEN count1Status = 'Y' AND count2Status = 'N' AND count3Status = 'N' THEN count2
        WHEN count1Status = 'Y' AND count2Status = 'Y' AND count3Status = 'N' THEN count3
        ELSE '0'
    END AS @TXT_QTY_INPUT@
FROM Z_CYCLECOUNT_DETAIL WHERE ORGANIZATIONID='#ORGANIZATIONID#' AND WAREHOUSEID='#WAREHOUSEID#'
AND  IDDOCUMENTCYCLE= '@TXT_ID_DOCUMENT@' AND upper(groupIdTask)='@TXT_GROUPTASKID@';