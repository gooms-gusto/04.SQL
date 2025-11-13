USE WMS_FTEST;

DROP PROCEDURE IF EXISTS ZSPLIT_BAGGING;

DELIMITER $$

CREATE
DEFINER = 'root'@'localhost'
PROCEDURE ZSPLIT_BAGGING (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_TDOCNO varchar(30),
 IN IN_lineNO int,
 IN IN_user varchar(30),
INOUT OUT_Return_Code varchar(500))
ENDPROC:
  BEGIN
    DECLARE OD_CURSORDONE boolean DEFAULT FALSE;
    DECLARE od_firstQty decimal(18, 8);
    DECLARE od_lastQty decimal(18, 8);


    DECLARE odh_organizationId varchar(20);
    DECLARE odh_warehouseId varchar(20);
    DECLARE odh_tdocNo varchar(20);
     DECLARE vodh_tdocNo varchar(20);
    DECLARE odh_tdocType varchar(20);
    DECLARE odh_status varchar(2);
    DECLARE odh_customerId varchar(30);
    DECLARE odh_tdocCreationTime timestamp;
    DECLARE odh_transferTime timestamp;
    DECLARE odh_reasonCode varchar(15);
    DECLARE odh_reason varchar(100);
    DECLARE odh_userDefineA varchar(20);
    DECLARE odh_userDefineB varchar(20);
    DECLARE odh_source varchar(10);
    DECLARE odh_sourceNo varchar(20);
    DECLARE odh_approveTime timestamp;
    DECLARE odh_approveBy varchar(35);
    DECLARE odh_noteText mediumtext;
    DECLARE odh_udf01 varchar(500);
    DECLARE odh_udf02 varchar(500);
    DECLARE odh_udf03 varchar(500);
    DECLARE odh_udf04 varchar(500);
    DECLARE odh_udf05 varchar(500);
    DECLARE odh_currentVersion int(11);
    DECLARE odh_oprSeqFlag varchar(65);
    DECLARE odh_addWho varchar(40);
    DECLARE odh_addTime timestamp;
    DECLARE odh_editWho varchar(40);
    DECLARE odh_editTime timestamp;
    DECLARE odh_hedi01 varchar(200);
    DECLARE odh_hedi02 varchar(200);
    DECLARE odh_hedi03 varchar(200);
    DECLARE odh_hedi04 varchar(200);
    DECLARE odh_hedi05 varchar(200);
    DECLARE odh_hedi06 varchar(200);
    DECLARE odh_hedi07 varchar(200);
    DECLARE odh_hedi08 varchar(200);
    DECLARE odh_hedi09 decimal(18, 8);
    DECLARE odh_hedi10 decimal(18, 8);
    DECLARE odh_ediSendFlag char(1);
    DECLARE odh_ediSendTime timestamp;
    DECLARE odh_ediErrorCode varchar(50);
    DECLARE odh_ediErrorMessage text;
    DECLARE odh_ediSendTime2 timestamp;
    DECLARE odh_ediSendFlag2 char(1);
    DECLARE odh_ediErrorCode2 varchar(50);
    DECLARE odh_ediErrorMessage2 text;
    DECLARE odh_ediSendTime3 timestamp;
    DECLARE odh_ediSendFlag3 char(1);
    DECLARE odh_ediErrorCode3 varchar(50);
    DECLARE odh_ediErrorMessage3 text;
    DECLARE odh_listPrintFlag char(1);


    DECLARE odd_organizationId varchar(20);
    DECLARE odd_warehouseId varchar(20);
    DECLARE odd_tdocNo varchar(20);
    DECLARE odd_tdocLineNo int(11);
    DECLARE odd_tdocLineStatus varchar(2);
    DECLARE odd_fmCustomerId varchar(30);
    DECLARE odd_fmSku varchar(50);
    DECLARE odd_fmLotNum varchar(10);
    DECLARE odd_fmLocation varchar(60);
    DECLARE odd_fmId varchar(30);
    DECLARE odd_fmQty decimal(18, 8);
    DECLARE odd_fmQtyAllocated decimal(18, 8);
    DECLARE odd_fmQtyOnHold decimal(18, 8);
    DECLARE odd_fmQtyAvailable decimal(18, 8);
    DECLARE odd_fmGrossWeight decimal(18, 8);
    DECLARE odd_fmNetWeight decimal(18, 8);
    DECLARE odd_fmCubic decimal(18, 8);
    DECLARE odd_fmPrice decimal(24, 8);
    DECLARE odd_toCustomerId varchar(30);
    DECLARE odd_toSku varchar(50);
    DECLARE odd_toLocation varchar(60);
    DECLARE odd_toId varchar(30);
    DECLARE odd_toQty decimal(18, 8);
    DECLARE odd_toGrossWeight decimal(18, 8);
    DECLARE odd_toNetWeight decimal(18, 8);
    DECLARE odd_toCubic decimal(18, 8);
    DECLARE odd_toPrice decimal(24, 8);
    DECLARE odd_toLotAtt01 varchar(20);
    DECLARE odd_toLotAtt02 varchar(20);
    DECLARE odd_toLotAtt03 varchar(20);
    DECLARE odd_toLotAtt04 varchar(100);
    DECLARE odd_toLotAtt05 varchar(100);
    DECLARE odd_toLotAtt06 varchar(100);
    DECLARE odd_toLotAtt07 varchar(100);
    DECLARE odd_toLotAtt08 varchar(100);
    DECLARE odd_toLotAtt09 varchar(100);
    DECLARE odd_toLotAtt10 varchar(100);
    DECLARE odd_toLotAtt11 varchar(100);
    DECLARE odd_toLotAtt12 varchar(100);
    DECLARE odd_gainLossQty decimal(18, 8);
    DECLARE odd_approveTime timestamp;
    DECLARE odd_approveBy varchar(35);
    DECLARE odd_noteText mediumtext;
    DECLARE odd_udf01 varchar(500);
    DECLARE odd_udf02 varchar(500);
    DECLARE odd_udf03 varchar(500);
    DECLARE odd_udf04 varchar(500);
    DECLARE odd_udf05 varchar(500);
    DECLARE odd_currentVersion int(11);
    DECLARE odd_oprSeqFlag varchar(65);
    DECLARE odd_addWho varchar(40);
    DECLARE odd_addTime timestamp;
    DECLARE odd_editWho varchar(40);
    DECLARE odd_editTime timestamp;
    DECLARE odd_toLotAtt13 varchar(100);
    DECLARE odd_toLotAtt14 varchar(100);
    DECLARE odd_toLotAtt15 varchar(100);
    DECLARE odd_toLotAtt16 varchar(100);
    DECLARE odd_toLotAtt17 varchar(100);
    DECLARE odd_toLotAtt18 varchar(100);
    DECLARE odd_toLotAtt19 varchar(100);
    DECLARE odd_toLotAtt20 varchar(100);
    DECLARE odd_toLotAtt21 varchar(100);
    DECLARE odd_toLotAtt22 varchar(100);
    DECLARE odd_toLotAtt23 varchar(100);
    DECLARE odd_toLotAtt24 varchar(100);
    DECLARE odd_sourceId varchar(20);
    DECLARE odd_reasonCode varchar(15);
    DECLARE odd_reason varchar(100);
    DECLARE odd_toMuId varchar(30);


    DECLARE _GETLINEORDER CURSOR FOR
    SELECT
      dth.organizationId,
      dth.warehouseId,
      dth.tdocNo,
      dth.tdocType,
      dth.STATUS,
      dth.customerId,
      dth.tdocCreationTime,
      dth.transferTime,
      dth.reasonCode,
      dth.reason,
      dth.userDefineA,
      dth.userDefineB,
      dth.source,
      dth.sourceNo,
      dth.approveTime,
      dth.approveBy,
      dth.noteText,
      dth.udf01,
      dth.udf02,
      dth.udf03,
      dth.udf04,
      dth.udf05,
      dth.currentVersion,
      dth.oprSeqFlag,
      dth.addWho,
      dth.addTime,
      dth.editWho,
      dth.editTime,
      dth.HEDI01,
      dth.HEDI02,
      dth.HEDI03,
      dth.HEDI04,
      dth.HEDI05,
      dth.hedi06,
      dth.hedi07,
      dth.hedi08,
      dth.hedi09,
      dth.hedi10,
      dth.ediSendFlag,
      dth.EDISendTime,
      dth.ediErrorCode,
      dth.ediErrorMessage,
      dth.ediSendTime2,
      dth.ediSendFlag2,
      dth.ediErrorCode2,
      dth.ediErrorMessage2,
      dth.ediSendTime3,
      dth.ediSendFlag3,
      dth.ediErrorCode3,
      dth.ediErrorMessage3,
      dth.listPrintFlag,
      dtd.organizationId,
      dtd.warehouseId,
      dtd.tdocNo,
      dtd.tdocLineNo,
      dtd.tdocLineStatus,
      dtd.FMCustomerID,
      dtd.fmSku,
      dtd.fmLotNum,
      dtd.fmLocation,
      dtd.fmId,
      dtd.fmQty,
      dtd.fmQtyAllocated,
      dtd.fmQtyOnHold,
      dtd.fmQtyAvailable,
      dtd.fmGrossWeight,
      dtd.fmNetWeight,
      dtd.fmCubic,
      dtd.fmPrice,
      dtd.toCustomerId,
      dtd.toSku,
      dtd.toLocation,
      dtd.toId,
      dtd.TOQTY,
      dtd.toGrossWeight,
      dtd.toNetWeight,
      dtd.toCubic,
      dtd.toPrice,
      dtd.toLotatt01,
      dtd.toLotatt02,
      dtd.toLotatt03,
      dtd.toLotatt04,
      dtd.toLotatt05,
      dtd.toLotatt06,
      dtd.toLotatt07,
      dtd.toLotatt08,
      dtd.toLotatt09,
      dtd.toLotatt10,
      dtd.toLotatt11,
      dtd.toLotatt12,
      dtd.gainLossQty,
      dtd.approveTime,
      dtd.approveBy,
      dtd.noteText,
      dtd.udf01,
      dtd.udf02,
      dtd.udf03,
      dtd.udf04,
      dtd.udf05,
      dtd.currentVersion,
      dtd.oprSeqFlag,
      dtd.addWho,
      dtd.addTime,
      dtd.editWho,
      dtd.editTime,
      dtd.toLotatt13,
      dtd.toLotatt14,
      dtd.toLotatt15,
      dtd.toLotatt16,
      dtd.toLotatt17,
      dtd.toLotatt18,
      dtd.toLotatt19,
      dtd.toLotatt20,
      dtd.toLotatt21,
      dtd.toLotatt22,
      dtd.toLotatt23,
      dtd.toLotatt24,
      dtd.sourceId,
      dtd.reasonCode,
      dtd.reason,
      dtd.toMuid
    FROM DOC_TRANSFER_HEADER dth
      INNER JOIN DOC_TRANSFER_DETAILS dtd
        ON dth.organizationId = dtd.organizationId
        AND dth.warehouseId = dtd.warehouseId
        AND dth.tdocNo = dtd.tdocNo
    WHERE dth.organizationId = IN_organizationId
    AND dtd.warehouseId = IN_warehouseId
    AND dth.tdocNo = IN_TDOCNO
    AND dtd.tdocLineNo = IN_lineNO;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET OD_CURSORDONE = TRUE;
    OPEN _GETLINEORDER;
  GETLINEORDERLOOP:
    LOOP FETCH FROM _GETLINEORDER INTO
      odh_organizationId,
      odh_warehouseId,
      odh_tdocNo,
      odh_tdocType,
      odh_status,
      odh_customerId,
      odh_tdocCreationTime,
      odh_transferTime,
      odh_reasonCode,
      odh_reason,
      odh_userDefineA,
      odh_userDefineB,
      odh_source,
      odh_sourceNo,
      odh_approveTime,
      odh_approveBy,
      odh_noteText,
      odh_udf01,
      odh_udf02,
      odh_udf03,
      odh_udf04,
      odh_udf05,
      odh_currentVersion,
      odh_oprSeqFlag,
      odh_addWho,
      odh_addTime,
      odh_editWho,
      odh_editTime,
      odh_hedi01,
      odh_hedi02,
      odh_hedi03,
      odh_hedi04,
      odh_hedi05,
      odh_hedi06,
      odh_hedi07,
      odh_hedi08,
      odh_hedi09,
      odh_hedi10,
      odh_ediSendFlag,
      odh_ediSendTime,
      odh_ediErrorCode,
      odh_ediErrorMessage,
      odh_ediSendTime2,
      odh_ediSendFlag2,
      odh_ediErrorCode2,
      odh_ediErrorMessage2,
      odh_ediSendTime3,
      odh_ediSendFlag3,
      odh_ediErrorCode3,
      odh_ediErrorMessage3,
      odh_listPrintFlag,
      odd_organizationId,
      odd_warehouseId,
      odd_tdocNo,
      odd_tdocLineNo,
      odd_tdocLineStatus,
      odd_fmCustomerId,
      odd_fmSku,
      odd_fmLotNum,
      odd_fmLocation,
      odd_fmId,
      odd_fmQty,
      odd_fmQtyAllocated,
      odd_fmQtyOnHold,
      odd_fmQtyAvailable,
      odd_fmGrossWeight,
      odd_fmNetWeight,
      odd_fmCubic,
      odd_fmPrice,
      odd_toCustomerId,
      odd_toSku,
      odd_toLocation,
      odd_toId,
      odd_toQty,
      odd_toGrossWeight,
      odd_toNetWeight,
      odd_toCubic,
      odd_toPrice,
      odd_toLotAtt01,
      odd_toLotAtt02,
      odd_toLotAtt03,
      odd_toLotAtt04,
      odd_toLotAtt05,
      odd_toLotAtt06,
      odd_toLotAtt07,
      odd_toLotAtt08,
      odd_toLotAtt09,
      odd_toLotAtt10,
      odd_toLotAtt11,
      odd_toLotAtt12,
      odd_gainLossQty,
      odd_approveTime,
      odd_approveBy,
      odd_noteText,
      odd_udf01,
      odd_udf02,
      odd_udf03,
      odd_udf04,
      odd_udf05,
      odd_currentVersion,
      odd_oprSeqFlag,
      odd_addWho,
      odd_addTime,
      odd_editWho,
      odd_editTime,
      odd_toLotAtt13,
      odd_toLotAtt14,
      odd_toLotAtt15,
      odd_toLotAtt16,
      odd_toLotAtt17,
      odd_toLotAtt18,
      odd_toLotAtt19,
      odd_toLotAtt20,
      odd_toLotAtt21,
      odd_toLotAtt22,
      odd_toLotAtt23,
      odd_toLotAtt24,
      odd_sourceId,
      odd_reasonCode,
      odd_reason,
      odd_toMuId;


      IF OD_CURSORDONE THEN
        SET OD_CURSORDONE = FALSE;
        LEAVE GETLINEORDERLOOP;
      END IF;

      BEGIN

        IF (odd_udf01 > odd_fmQty) THEN
          SET OUT_Return_Code = '201';
          LEAVE ENDPROC;
        END IF;

        SET od_lastQty = odd_fmQty - odd_udf01;
        set od_firstQty=odd_udf01;
        CALL SPCOM_GetIDSequence_NEW(IN_organizationId,
        IN_warehouseId,'en',
        'TDOCNO',
        vodh_tdocNo,
        OUT_Return_Code);

        SELECT
          odd_udf01,
          odh_customerId,
          od_lastQty,
          vodh_tdocNo;


        IF (odd_udf01 > 0) THEN

          INSERT INTO DOC_TRANSFER_HEADER (organizationId,
          warehouseId,
          tdocNo,
          tdocType,
          STATUS,
          customerId,
          tdocCreationTime,
          transferTime,
          reasonCode,
          reason,
          userDefineA,
          userDefineB,
          source,
          sourceNo,
          approveTime,
          approveBy,
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
          editTime,
          HEDI01,
          HEDI02,
          HEDI03,
          HEDI04,
          HEDI05,
          hedi06,
          hedi07,
          hedi08,
          hedi09,
          hedi10,
          ediSendFlag,
          EDISendTime,
          ediErrorCode,
          ediErrorMessage,
          ediSendTime2,
          ediSendFlag2,
          ediErrorCode2,
          ediErrorMessage2,
          ediSendTime3,
          ediSendFlag3,
          ediErrorCode3,
          ediErrorMessage3,
          listPrintFlag)
            SELECT
              odh_organizationId,
              odh_warehouseId,
               vodh_tdocNo,
              odh_tdocType,
              odh_status,
              odh_customerId,
              odh_tdocCreationTime,
              odh_transferTime,
              odh_reasonCode,
              odh_reason,
              odh_userDefineA,
              odh_userDefineB,
              odh_source,
              odh_sourceNo,
              odh_approveTime,
              odh_approveBy,
              odh_noteText,
              odh_udf01,
              odh_udf02,
              odh_udf03,
              odh_udf04,
              odh_udf05,
              odh_currentVersion,
              odh_oprSeqFlag,
              IN_user odh_addWho,
              NOW() odh_addTime,
               IN_user odh_editWho,
              NOW() odh_editTime,
              odh_hedi01,
              odh_hedi02,
              odh_hedi03,
              odh_hedi04,
              odh_hedi05,
              odh_hedi06,
              odh_hedi07,
              odh_hedi08,
              odh_hedi09,
              odh_hedi10,
              odh_ediSendFlag,
              odh_ediSendTime,
              odh_ediErrorCode,
              odh_ediErrorMessage,
              odh_ediSendTime2,
              odh_ediSendFlag2,
              odh_ediErrorCode2,
              odh_ediErrorMessage2,
              odh_ediSendTime3,
              odh_ediSendFlag3,
              odh_ediErrorCode3,
              odh_ediErrorMessage3,
              odh_listPrintFlag;

INSERT INTO DOC_TRANSFER_DETAILS (organizationId, warehouseId, tdocNo, tdocLineNo, tdocLineStatus, fmCustomerId, fmSku, fmLotNum, fmLocation, fmId, fmQty, fmQtyAllocated, fmQtyOnHold, fmQtyAvailable, fmGrossWeight, fmNetWeight, fmCubic, fmPrice, toCustomerId, toSku, toLocation, toId, toQty, toGrossWeight, toNetWeight, toCubic, toPrice, toLotAtt01, toLotAtt02, toLotAtt03, toLotAtt04, toLotAtt05, toLotAtt06, toLotAtt07, toLotAtt08, toLotAtt09, toLotAtt10, toLotAtt11, toLotAtt12, gainLossQty, approveTime, approveBy, noteText, udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag, addWho, addTime, editWho, editTime, toLotAtt13, toLotAtt14, toLotAtt15, toLotAtt16, toLotAtt17, toLotAtt18, toLotAtt19, toLotAtt20, toLotAtt21, toLotAtt22, toLotAtt23, toLotAtt24, sourceId, reasonCode, reason, toMuId)
SELECT odd_organizationId,
odd_warehouseId,
vodh_tdocNo,
odd_tdocLineNo,
odd_tdocLineStatus,
odd_fmCustomerId,
odd_fmSku,
odd_fmLotNum,
odd_fmLocation,
odd_fmId,
odd_fmQty,
odd_fmQtyAllocated,
odd_fmQtyOnHold,
odd_fmQtyAvailable,
odd_fmGrossWeight,
odd_fmNetWeight,
odd_fmCubic,
odd_fmPrice,
odd_toCustomerId,
odd_toSku,
odd_toLocation,
odd_toId,
od_firstQty, -- qty split request
odd_toGrossWeight,
odd_toNetWeight,
odd_toCubic,
odd_toPrice,
odd_toLotAtt01,
odd_toLotAtt02,
odd_toLotAtt03,
odd_toLotAtt04,
odd_toLotAtt05,
odd_toLotAtt06,
odd_toLotAtt07,
odd_toLotAtt08,
odd_toLotAtt09,
odd_toLotAtt10,
odd_toLotAtt11,
odd_toLotAtt12,
odd_gainLossQty,
odd_approveTime,
odd_approveBy,
odd_noteText,
'' odd_udf01,
odd_udf02,
odd_udf03,
odd_udf04,
odd_udf05,
odd_currentVersion,
odd_oprSeqFlag,
IN_user odd_addWho,
NOW() odd_addTime,
IN_user odd_editWho,
NOW() odd_editTime,
odd_toLotAtt13,
odd_toLotAtt14,
odd_toLotAtt15,
odd_toLotAtt16,
odd_toLotAtt17,
odd_toLotAtt18,
odd_toLotAtt19,
odd_toLotAtt20,
odd_toLotAtt21,
odd_toLotAtt22,
odd_toLotAtt23,
odd_toLotAtt24,
odd_sourceId,
odd_reasonCode,
odd_reason,
odd_toMuId;



-- UPDATE LAST TRANSFER ORDER NO
UPDATE DOC_TRANSFER_DETAILS SET
 toQty = od_lastQty, udf01=NULL, editTime=NOW()
 WHERE organizationId = IN_organizationId AND warehouseId = IN_warehouseId 
 AND tdocNo = IN_TDOCNO AND tdocLineNo = IN_lineNO;

        END IF;

      -- SELECT OD_ORDERNO,OD_ORDERTYPE,OD_SKU,OD_SKUGROUP,OD_CONSIGNEEID;
      END;
    END LOOP GETLINEORDERLOOP;
    CLOSE _GETLINEORDER;

  END
$$

DELIMITER ;