USE WMS_FTEST;

DROP PROCEDURE IF EXISTS FLUX_SPUDF_Process6;

DELIMITER $$

CREATE
DEFINER = 'wms_ftest'@'%'
PROCEDURE FLUX_SPUDF_Process6 (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(20),
IN IN_DocNo varchar(3000),
IN IN_userId varchar(40),
OUT OUT_returnCode varchar(1000))
BEGIN
  CALL SPSYS_GetListByString(IN_DocNo, ',', 'DOCNO');
  UPDATE DOC_ORDER_HEADER A
  SET A.UDF01 = 'ZXXXXX12'
  WHERE A.organizationId = IN_organizationId
  AND A.warehouseId = IN_warehouseId
  AND EXISTS (SELECT
      1
    FROM TMP_CODE B
    WHERE A.ORDERNO = B.CODE
    AND B.CODEID = 'DOCNO');
  DELETE
    FROM TMP_CODE
  WHERE CODEID = 'DOCNO';
  SET OUT_returnCode := '000#失败';
END
$$

DELIMITER ;