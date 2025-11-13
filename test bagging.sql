SELECT * FROM DOC_TRANSFER_HEADER dth WHERE dth.tdocNo IN ('TRF240731001','TRF240731007');

SELECT * FROM DOC_TRANSFER_DETAILS dtd WHERE dtd.tdocNo='TRF240731001';

USE WMS_FTEST;

SET @IN_organizationId = 'OJV_CML';
SET @IN_warehouseId = 'CBT01';
SET @IN_TDOCNO = 'TRF240731001';
SET @IN_lineNO = 1;
SET @IN_user = 'EDI';
SET @IN_OUT='';
CALL ZSPLIT_BAGGING(@IN_organizationId, @IN_warehouseId, @IN_TDOCNO, @IN_lineNO, @IN_user,@IN_OUT);

SELECT * FROM SYS_IDSEQUENCE_ML sim si WHERE 

DESCRIBE DOC_TRANSFER_HEADER;
describe DOC_TRANSFER_DETAILS;

USE WMS_FTEST;

INSERT INTO DOC_TRANSFER_DETAILS
(
  organizationId
 ,warehouseId
 ,tdocNo
 ,tdocLineNo
 ,tdocLineStatus
 ,fmCustomerId
 ,fmSku
 ,fmLotNum
 ,fmLocation
 ,fmId
 ,fmQty
 ,fmQtyAllocated
 ,fmQtyOnHold
 ,fmQtyAvailable
 ,fmGrossWeight
 ,fmNetWeight
 ,fmCubic
 ,fmPrice
 ,toCustomerId
 ,toSku
 ,toLocation
 ,toId
 ,toQty
 ,toGrossWeight
 ,toNetWeight
 ,toCubic
 ,toPrice
 ,toLotAtt01
 ,toLotAtt02
 ,toLotAtt03
 ,toLotAtt04
 ,toLotAtt05
 ,toLotAtt06
 ,toLotAtt07
 ,toLotAtt08
 ,toLotAtt09
 ,toLotAtt10
 ,toLotAtt11
 ,toLotAtt12
 ,gainLossQty
 ,approveTime
 ,approveBy
 ,noteText
 ,udf01
 ,udf02
 ,udf03
 ,udf04
 ,udf05
 ,currentVersion
 ,oprSeqFlag
 ,addWho
 ,addTime
 ,editWho
 ,editTime
 ,toLotAtt13
 ,toLotAtt14
 ,toLotAtt15
 ,toLotAtt16
 ,toLotAtt17
 ,toLotAtt18
 ,toLotAtt19
 ,toLotAtt20
 ,toLotAtt21
 ,toLotAtt22
 ,toLotAtt23
 ,toLotAtt24
 ,sourceId
 ,reasonCode
 ,reason
 ,toMuId
)
VALUES
(
  '' -- organizationId - VARCHAR(20) NOT NULL
 ,'' -- warehouseId - VARCHAR(20) NOT NULL
 ,'' -- tdocNo - VARCHAR(20) NOT NULL
 ,0 -- tdocLineNo - INT(11) NOT NULL
 ,'' -- tdocLineStatus - VARCHAR(2) NOT NULL
 ,'' -- fmCustomerId - VARCHAR(30) NOT NULL
 ,'' -- fmSku - VARCHAR(50) NOT NULL
 ,'' -- fmLotNum - VARCHAR(10) NOT NULL
 ,'' -- fmLocation - VARCHAR(60)
 ,'' -- fmId - VARCHAR(30)
 ,0 -- fmQty - DECIMAL(18, 8)
 ,0 -- fmQtyAllocated - DECIMAL(18, 8)
 ,0 -- fmQtyOnHold - DECIMAL(18, 8)
 ,0 -- fmQtyAvailable - DECIMAL(18, 8)
 ,0 -- fmGrossWeight - DECIMAL(18, 8)
 ,0 -- fmNetWeight - DECIMAL(18, 8)
 ,0 -- fmCubic - DECIMAL(18, 8)
 ,0 -- fmPrice - DECIMAL(24, 8)
 ,'' -- toCustomerId - VARCHAR(30) NOT NULL
 ,'' -- toSku - VARCHAR(50) NOT NULL
 ,'' -- toLocation - VARCHAR(60)
 ,'' -- toId - VARCHAR(30)
 ,0 -- toQty - DECIMAL(18, 8)
 ,0 -- toGrossWeight - DECIMAL(18, 8)
 ,0 -- toNetWeight - DECIMAL(18, 8)
 ,0 -- toCubic - DECIMAL(18, 8)
 ,0 -- toPrice - DECIMAL(24, 8)
 ,'' -- toLotAtt01 - VARCHAR(20)
 ,'' -- toLotAtt02 - VARCHAR(20)
 ,'' -- toLotAtt03 - VARCHAR(20)
 ,'' -- toLotAtt04 - VARCHAR(100)
 ,'' -- toLotAtt05 - VARCHAR(100)
 ,'' -- toLotAtt06 - VARCHAR(100)
 ,'' -- toLotAtt07 - VARCHAR(100)
 ,'' -- toLotAtt08 - VARCHAR(100)
 ,'' -- toLotAtt09 - VARCHAR(100)
 ,'' -- toLotAtt10 - VARCHAR(100)
 ,'' -- toLotAtt11 - VARCHAR(100)
 ,'' -- toLotAtt12 - VARCHAR(100)
 ,0 -- gainLossQty - DECIMAL(18, 8)
 ,NOW() -- approveTime - TIMESTAMP
 ,'' -- approveBy - VARCHAR(35)
 ,'' -- noteText - MEDIUMTEXT
 ,'' -- udf01 - VARCHAR(500)
 ,'' -- udf02 - VARCHAR(500)
 ,'' -- udf03 - VARCHAR(500)
 ,'' -- udf04 - VARCHAR(500)
 ,'' -- udf05 - VARCHAR(500)
 ,0 -- currentVersion - INT(11) NOT NULL
 ,'' -- oprSeqFlag - VARCHAR(65) NOT NULL
 ,'' -- addWho - VARCHAR(40)
 ,NOW() -- addTime - TIMESTAMP
 ,'' -- editWho - VARCHAR(40)
 ,NOW() -- editTime - TIMESTAMP
 ,'' -- toLotAtt13 - VARCHAR(100)
 ,'' -- toLotAtt14 - VARCHAR(100)
 ,'' -- toLotAtt15 - VARCHAR(100)
 ,'' -- toLotAtt16 - VARCHAR(100)
 ,'' -- toLotAtt17 - VARCHAR(100)
 ,'' -- toLotAtt18 - VARCHAR(100)
 ,'' -- toLotAtt19 - VARCHAR(100)
 ,'' -- toLotAtt20 - VARCHAR(100)
 ,'' -- toLotAtt21 - VARCHAR(100)
 ,'' -- toLotAtt22 - VARCHAR(100)
 ,'' -- toLotAtt23 - VARCHAR(100)
 ,'' -- toLotAtt24 - VARCHAR(100)
 ,'' -- sourceId - VARCHAR(20)
 ,'' -- reasonCode - VARCHAR(15)
 ,'' -- reason - VARCHAR(100)
 ,'' -- toMuId - VARCHAR(30)
);