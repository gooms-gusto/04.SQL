USE WMS_FTEST;

DROP PROCEDURE IF EXISTS BILL_MOD229_REV01;

DELIMITER $$

CREATE
DEFINER = 'wms_ftest'@'%'
PROCEDURE BILL_MOD229_REV01 (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_asnNo varchar(30),
INOUT OUT_returnCode varchar(1000))
BEGIN
  ####################################################################
  ##变量定义
  DECLARE R_CURRENTDATE timestamp;
  DECLARE R_OPDATE varchar(10);
  DECLARE R_FMDATE varchar(10);
  DECLARE R_TODATE varchar(10);
  DECLARE R_BILLINGDAY integer;
  DECLARE R_BILLINGDATE varchar(10);
  DECLARE R_TARGETDATE varchar(10);
  DECLARE R_DAYOFMONTH int;
  DECLARE R_ORGANIZATIONID varchar(30);
  DECLARE R_WAREHOUSEID varchar(30);
  DECLARE R_CUSTOMERID varchar(30);
  DECLARE R_STOCKDATE varchar(10);
  DECLARE R_TARIFFID varchar(10);
  DECLARE R_TARIFFMASTERID varchar(20);
  DECLARE R_TARIFFLINENO int(11);
  DECLARE R_TARIFFCLASSNO int(11);
  DECLARE R_CHARGECATEGORY varchar(20);
  DECLARE R_CHARGETYPE varchar(20);
  DECLARE R_descrC varchar(50);
  DECLARE R_ratebase varchar(20);
  DECLARE R_docType varchar(20);
  DECLARE R_rateperunit decimal(24, 8);
  DECLARE R_rate decimal(24, 8);
  DECLARE R_minQty varchar(500);
  DECLARE R_minAmount decimal(24, 8);
  DECLARE R_maxAmount decimal(24, 8);
  DECLARE R_billQty decimal(24, 8);
  DECLARE R_Cost decimal(24, 8);
  DECLARE R_materialNo varchar(500);
  DECLARE R_itemChargeCategory varchar(500);
  DECLARE R_billMode varchar(500);
  DECLARE R_UDF06 varchar(500);
  DECLARE R_FINALAMOUNT decimal(24, 8);
  DECLARE R_billsummaryId varchar(30) DEFAULT '';
  DECLARE R_billsummaryNo varchar(30) DEFAULT '';
  DECLARE R_LOCATIONCAT char(2);
  DECLARE R_LOCATIONGROUP varchar(500);
  DECLARE R_INCOMETAX decimal(24, 8);
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLTO varchar(30);
  DECLARE R_NROW integer;
  DECLARE c_WAREHOUSEID varchar(30);
  DECLARE c_CUSTOMERID varchar(30);
  DECLARE c_chargecategory varchar(30);
  DECLARE c_charegetype varchar(30);
  DECLARE c_locationId varchar(60);
  DECLARE c_sku varchar(255);
  DECLARE c_qtyonHand int(11) DEFAULT NULL;
  DECLARE c_packkey varchar(255) binary DEFAULT NULL;
  DECLARE c_UOM varchar(255) binary DEFAULT NULL;
  DECLARE c_qtyallocated int(11) DEFAULT NULL;
  DECLARE c_qtyonHold int(11) DEFAULT NULL;
  DECLARE c_qtyavailable int(11) DEFAULT NULL;
  DECLARE c_qtyPicked int(11) DEFAULT NULL;
  DECLARE c_SKUDesc varchar(550) binary DEFAULT NULL;
  DECLARE c_stockDate date DEFAULT NULL;
  DECLARE c_Cub decimal(24, 8) DEFAULT NULL;
  DECLARE c_totalCub decimal(24, 8) DEFAULT NULL;
  DECLARE c_grossWeight decimal(18, 8) DEFAULT NULL;
  DECLARE c_netWeight decimal(18, 8) DEFAULT NULL;
  DECLARE c_freightClass varchar(255) binary DEFAULT NULL;
  DECLARE c_locationCategory varchar(10) DEFAULT '';
  DECLARE R_UDF08 varchar(500);
  DECLARE R_UDF07 varchar(500);
  DECLARE R_Days int(11) DEFAULT NULL;
  ####################################################################
	DECLARE od_organizationId varchar(255);
	DECLARE od_asnReference1 varchar(255);
	DECLARE od_asnReference3 varchar(255);
	DECLARE od_skuDescr1 varchar(255);
	DECLARE od_warehouseId varchar(255);
	DECLARE od_customerId varchar(255);
	DECLARE od_asnNo varchar(255);
	DECLARE od_asnLineNo varchar(255);
	DECLARE od_sku varchar(255);
	DECLARE od_qtyReceived varchar(255);
	DECLARE od_uom varchar(255);
	DECLARE od_qtyReceivedEach varchar(255);
	DECLARE od_qtyCharge varchar(255);
	DECLARE od_totalCube varchar(255);
	DECLARE od_addTime varchar(255);
	DECLARE od_editTime varchar(255);
	DECLARE od_transactionTime varchar(255);
	DECLARE od_lotNum varchar(255);
	DECLARE od_traceId varchar(255);
	DECLARE od_muid varchar(255);
	DECLARE od_toLocation varchar(255);
	DECLARE od_transactionId varchar(255);
	DECLARE od_docType varchar(255);
	DECLARE od_docTypeDescr varchar(255);
	DECLARE od_packId varchar(255);
	DECLARE od_QtyPerCases varchar(255);
	DECLARE od_QtyPerPallet varchar(255);
	DECLARE od_sku_group1 varchar(255);
	DECLARE od_grossWeight varchar(255);
	DECLARE od_cubeNya varchar(255);
	DECLARE od_tariffMasterId varchar(255);
	DECLARE od_zone varchar(255);
	DECLARE od_batch varchar(255);
	DECLARE od_lotAtt07 varchar(255);
	DECLARE od_RecType varchar(21);


  ####################################################################
  ##游标定义
  DECLARE inventory_done int DEFAULT FALSE;
  DECLARE tariff_done BOOLEAN DEFAULT FALSE;
  DECLARE order_done, attribute_done BOOLEAN DEFAULT FALSE;  
  
  DECLARE cur_orderno CURSOR FOR
   SELECT
              IFNULL(CAST(dah.organizationId AS char(255)), '') AS organizationId,
              IFNULL(CAST(dah.asnReference1 AS char(255)), '') AS asnReference1,
              IFNULL(CAST(dah.asnReference3 AS char(255)), '') AS asnReference3,
              IFNULL(CAST(dad.skuDescr AS char(255)), '') AS skuDescr1,
              IFNULL(CAST(atl.warehouseId AS char(255)), '') AS warehouseId,
              IFNULL(CAST(atl.tocustomerId AS char(255)), '') AS customerId,
              IFNULL(CAST(atl.docNo AS char(255)), '') AS asnNo,
              IFNULL(CAST(atl.docLineNo AS char(255)), 0) AS asnLineNo,
              IFNULL(CAST(atl.toSku AS char(255)), '') AS sku,
              IFNULL(CAST(atl.toQty AS char(255)), 0) AS qtyReceived,
              IFNULL(CAST(atl.toUom AS char(255)), '') AS uom,
              IFNULL(CAST(atl.toQty_Each AS char(255)), 0) AS qtyReceivedEach,
              IFNULL(CAST(SUM(atl.toQty_Each * bs.cube) AS char(255)), 0) AS qtyCharge,
              IFNULL(CAST(SUM(atl.toQty_Each * bs.cube) AS char(255)), 0) AS totalCube,
              CAST(DATE_FORMAT(atl.addTime, '%Y-%m-%d') AS char(255)) AS addTime,
              CAST(DATE_FORMAT(atl.editTime, '%Y-%m-%d') AS char(255)) AS editTime,
              CAST(DATE_FORMAT(atl.transactionTime, '%Y-%m-%d') AS char(255)) AS transactionTime,
              IFNULL(CAST(atl.tolotNum AS char(255)), '') AS lotNum,
              IFNULL(CAST(atl.toId AS char(255)), '') AS traceId,
              IFNULL(CAST(atl.tomuid AS char(255)), '') AS muid,
              IFNULL(CAST(atl.toLocation AS char(255)), '') AS toLocation,
              IFNULL(CAST(atl.transactionId AS char(255)), '') AS transactionId,
              IFNULL(CAST(t1.codeid AS char(255)), '') AS docType,
              IFNULL(CAST(t1.codeDescr AS char(255)), '') AS docTypeDescr,
              IFNULL(CAST(bpdCS.packId AS char(255)), '') AS packId,
              IFNULL(CAST(bpdCS.qty AS char(255)), 0) AS QtyPerCases,
              IFNULL(CAST(bpdPL.qty AS char(255)), 0) AS QtyPerPallet,
              IFNULL(CAST(bs.sku_group1 AS char(255)), '') AS sku_group1,
              IFNULL(CAST(bs.grossWeight AS char(255)), 0) AS grossWeight,
              IFNULL(CAST(bs.cube AS char(255)), 0) AS cubeNya,
              IFNULL(CAST(bsm.tariffMasterId AS char(255)), '') AS tariffMasterId,
              IFNULL(CAST(bz.zoneDescr AS char(255)), '') AS zone,
              IFNULL(CAST(ila.lotAtt04 AS char(255)), '') AS batch,
              IFNULL(CAST(ila.lotAtt07 AS char(255)), '') AS lotAtt07,
              CASE ila.lotAtt07 WHEN 'O' THEN 'Owner Pallet' WHEN 'R' THEN 'Rental Pallet' WHEN 'PP' THEN 'Rental Plastic Pallet' WHEN 'WP' THEN 'Rental Wooden Pallet' END AS RecType
            FROM ACT_TRANSACTION_LOG atl
              LEFT OUTER JOIN BAS_SKU bs
                ON bs.organizationId = atl.organizationId
                AND bs.customerId = atl.toCustomerId
                AND bs.SKU = atl.toSku
              LEFT OUTER JOIN BAS_SKU_MULTIWAREHOUSE bsm
                ON bsm.organizationId = atl.organizationId
                AND bsm.warehouseId = atl.warehouseId
                AND bsm.customerId = atl.tocustomerId
                AND bsm.SKU = atl.toSku
              LEFT OUTER JOIN DOC_ASN_HEADER dah
                ON dah.organizationId = atl.organizationId
                AND dah.warehouseId = atl.warehouseId
                AND dah.asnNo = atl.docNo
                AND dah.customerId = atl.fmCustomerId
              LEFT OUTER JOIN DOC_ASN_DETAILS dad
                ON dad.organizationId = atl.organizationId
                AND dad.warehouseId = atl.warehouseId
                AND dad.asnNo = atl.docNo
                AND dad.asnLineNo = atl.docLineNo
                AND dad.sku = atl.toSku
              LEFT OUTER JOIN INV_LOT_ATT ila
                ON ila.organizationId = atl.organizationId
                AND ila.SKU = atl.toSku
                AND ila.lotNum = atl.toLotNum
              LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdCS
                ON bpdCS.organizationId = bs.organizationId
                AND bpdCS.packId = bs.packId
                AND bpdCS.customerId = bs.customerId
                AND bpdCS.packUOM = 'CS'
              LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdPL
                ON bpdPL.organizationId = bs.organizationId
                AND bpdPL.packId = bs.packId
                AND bpdPL.customerId = bs.customerId
                AND bpdPL.packUOM = 'PL'
              LEFT JOIN BSM_CODE_ML t1
                ON t1.organizationId = atl.organizationId
                AND t1.codeType = 'ASN_TYP'
                AND dah.asnType = t1.codeId
                AND t1.languageId = 'en'
              LEFT JOIN BAS_LOCATION bl
                ON bl.organizationId = atl.organizationId
                AND bl.warehouseId = atl.warehouseId
                AND bl.locationId = atl.tolocation
              LEFT JOIN BAS_ZONE bz
                ON bz.organizationId = bl.organizationId
                AND bz.organizationId = bl.organizationId
                AND bz.warehouseId = bl.warehouseId
                AND bz.zoneId = bl.zoneId
                AND bz.zoneGroup = bl.zoneGroup
            WHERE atl.warehouseId = R_WAREHOUSEID
            AND dah.customerId = R_CUSTOMERID
            AND bsm.tariffMasterId NOT LIKE '%PIECES'
            AND atl.transactionType = 'IN'
            AND dah.asnType NOT IN ('PO')
            AND atl.STATUS IN ('80', '99')
            AND dah.asnStatus IN ('99')
            AND DATE_FORMAT(atl.addTime, '%Y-%m-%d') >= R_FMDATE
            AND DATE_FORMAT(atl.addTime, '%Y-%m-%d') <= R_TODATE
            AND bs.skuDescr1 NOT LIKE '%PALLET%'
            GROUP BY atl.docNo,
                     atl.docLineNo,
                     atl.toCustomerId,
                     atl.toSku,
                     atl.toQty,
                     atl.toQty_Each,
                     atl.toUom,
                     atl.addTime,
                     atl.transactionTime,
                     atl.toLotNum,
                     atl.toId,
                     atl.tomuid,
                     atl.toLocation,
                     atl.warehouseId,
                     atl.tocustomerId,
                     atl.transactionId,
                     atl.editTime,
                     dah.organizationId,
                     dah.asnNo,
                     dah.asnType,
                     dah.asnReference1,
                     dah.asnReference3,
                     dah.asnReference1,
                     dad.SkuDescr,
                     bsm.tariffMasterId,
                     bs.grossWeight,
                     bs.cube,
                     bs.sku_group1,
                     bz.zoneDescr,
                     bpdCS.packId,
                     bpdPL.packId,
                     bpdCS.qty,
                     bpdPL.qty,
                     ila.lotAtt04,
                     ila.lotAtt07,
                     t1.codeid;
					 DECLARE CONTINUE HANDLER FOR NOT FOUND SET order_done = TRUE;
	OPEN cur_orderno;
    cur_order_loop: LOOP
    FETCH FROM cur_orderno INTO od_organizationId,
od_asnReference1,od_asnReference3,od_skuDescr1,od_warehouseId,od_customerId,od_asnNo,od_asnLineNo,od_sku,od_qtyReceived,od_uom,od_qtyReceivedEach,od_qtyCharge,od_totalCube,od_addTime,od_editTime,od_transactionTime,od_lotNum,od_traceId,od_muid,od_toLocation,od_transactionId,od_docType,od_docTypeDescr,od_packId,od_QtyPerCases,od_QtyPerPallet,od_sku_group1,
od_grossWeight,od_cubeNya,od_tariffMasterId,od_zone,od_batch,od_lotAtt07,od_RecType;

	IF order_done THEN
        SET order_done = FALSE;
        LEAVE cur_order_loop;
    END IF;
  

        BLOCK2: BEGIN
   --   IF (od_tariffMasterId <> '') THEN

DECLARE cur_Tariff CURSOR FOR
  SELECT DISTINCT
    bsm.organizationId,bsm.warehouseId,bsm.CUSTOMERID,DAY(bth.billingdate) billingDate,btr.tariffId,btr.tariffLineNo,btr.tariffClassNo, btd.chargeCategory,btd.chargeType,btd.descrC,btd.docType,btd.ratebase,btr.ratePerUnit,btr.rate,btd.minAmount,
    btd.maxAmount,IF(btd.UDF03 = '', 0, btd.UDF03) minQty,btd.UDF01 AS MaterialNo,btd.udf02 AS itemChargeCategory,btd.udf04 billMode,locationCategory,btd.UDF05,btd.UDF06,btd.UDF07,btd.UDF08,
    IFNULL(btd.incomeTaxRate, 0) IncomeTaxRate,
    CASE WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1 ELSE IFNULL(btr.classfrom, 0) END,
    IFNULL(classTo, 0),
    bth.contractNo,
    bth.tariffMasterId,
    btr.cost,
    btd.billingParty
  FROM BAS_SKU_MULTIWAREHOUSE bsm
    INNER JOIN BAS_CUSTOMER bc
      ON bc.customerId = bsm.customerId
      AND bc.organizationId = bsm.organizationId
      AND bc.CustomerType = 'OW'
    INNER JOIN BIL_TARIFF_HEADER bth
      ON bth.organizationId = bsm.organizationId
      AND bth.tariffMasterId = bsm.tariffMasterId
    INNER JOIN BIL_TARIFF_DETAILS btd
      ON btd.organizationId = bth.organizationId
      AND btd.tariffId = bth.tariffId
    INNER JOIN BIL_TARIFF_RATE btr
      ON btr.organizationId = btd.organizationId
      AND btr.tariffId = btd.tariffId
      AND btr.tariffLineNo = btd.tariffLineNo
  WHERE bsm.organizationId = 'OJV_CML'
  AND bsm.warehouseId = 'CBT01'
  AND bsm.customerId LIKE 'MAP'
  AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  AND btd.chargeCategory = 'IB'
  AND btd.docType IN (SELECT
      dah.asnType
    FROM DOC_ASN_HEADER dah
    WHERE dah.asnNo = IN_asnNo)
  AND btr.rate > 0
  #AND IFNULL(DAY(bth.billingdate),0)!=0 
  ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = TRUE;
  
  SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd
    #
    OPEN cur_Tariff;
  getTariff:
    LOOP
      FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
      R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
      R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY;
      IF tariff_done THEN
        SET tariff_done = FALSE;
        LEAVE getTariff;
      END IF;
	  
	  IF (od_docType=R_docType) THEN
	  
	  
	  SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
      SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
      SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
      SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
      SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
      SET R_billsummaryId = '';
	  
	   IF EXISTS (SELECT
                  1
                FROM BIL_SUMMARY
                WHERE billingFromDate = R_BILLINGDATE
                AND BillingToDate = R_BILLINGDATE
                AND ChargeCategory = R_CHARGECATEGORY
                AND chargeType = R_CHARGETYPE
                AND CustomerID = R_CUSTOMERID
                AND billTo = R_BILLTO
                AND rateBase = R_rateBase
                AND arNo IN ('*')) THEN
				INSERT INTO BIL_SUMMARY_LOG
                SELECT
                  *
                FROM BIL_SUMMARY
                WHERE billingFromDate = R_BILLINGDATE
                AND BillingToDate = R_BILLINGDATE
                AND ChargeCategory = R_CHARGECATEGORY
                AND chargeType = R_CHARGETYPE
                AND CustomerID = R_CUSTOMERID
                AND billTo = R_BILLTO
                AND rateBase = R_rateBase
                AND arNo IN ('*');
              DELETE
                FROM BIL_SUMMARY
              WHERE billingFromDate = R_BILLINGDATE
                AND BillingToDate = R_BILLINGDATE
                AND ChargeCategory = R_CHARGECATEGORY
                AND chargeType = R_CHARGETYPE
                AND CustomerID = R_CUSTOMERID
                AND billTo = R_BILLTO
                AND rateBase = R_rateBase
                AND arNo IN ('*');
				END IF; -- EXIST BILLING SUMMARY
				
				INSERT INTO BIL_SUMMARY (organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate, customerId
            , sku, lotNum, traceId, tariffId, chargeCategory, chargeType, descr, rateBase, chargePerUnits
            , qty, uom, cubic, weight, chargeRate, amount, billingAmount, cost, amountPayable, amountPaid
            , confirmTime, confirmWho, docType, docNo, createTransactionid, notes, ediSendTime
            , billTo, settleTime, settleWho, followUp, invoiceType, paidTo, costConfirmFlag
            , costConfirmTime, costConfirmWho, costSettleFlag, costSettleTime, costSettleWho, incomeTaxRate
            , costTaxRate, incomeTax, cosTax, incomeWithoutTax, cosWithoutTax, costInvoiceType, noteText
            , udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag, addWho, ADDTIME, editWho, editTime, locationCategory
            , manual, docLineNo, arNo, arLineNo, apNo, apLineNo, ediSendFlag, ediErrorCode, ediErrorMessage, ediSendTime2, ediSendFlag2
            , ediErrorCode2, ediErrorMessage2, billingTranCategory, orderType, containerType, containerSize)
              SELECT
                od_organizationId,
                od_warehouseId,
                CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')),
                R_TODATE billingFromDate,
                R_TODATE billingToDate,
                od_customerId,
                od_sku,
                od_lotNum,
                od_traceId,
                R_TARIFFID,
                R_CHARGECATEGORY,
                R_chargetype,
                R_descrC,
                R_rateBase,
                R_rateperunit,
                od_qtyReceivedEach,
                od_uom,
                od_totalCube,
                od_grossWeight,
                R_rate,
                od_qtyCharge * R_rate / R_rateperunit,
                (od_qtyCharge * (R_rate / R_rateperunit)) + (od_qtyCharge * (R_rate / R_rateperunit)) * R_INCOMETAX,
                0,
                R_cost * od_qtyCharge,
                0,
                NOW() confirmTime,
                '' confirmWho,
                od_docTypeDescr,
                od_asnNo,
                '' createTransactionid,
                '' notes,
                NOW() ediSendTime,
                R_BILLTO billTo,
                NOW() settleTime,
                '' settleWho,
                '' followUp,
                '' invoiceType,
                '' paidTo,
                '' costConfirmFlag,
                NOW() costConfirmTime,
                '' costConfirmWho,
                '' costSettleFlag,
                NOW() costSettleTime,
                '' costSettleWho,
                0 incomeTaxRate,
                0 costTaxRate,
                R_INCOMETAX incomeTax,
                0 cosTax,
                od_qtyCharge * R_rate / R_rateperunit incomeWithoutTax,
                0 cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                R_materialNo AS udf01,
                R_itemChargeCategory AS udf02,
                R_UDF08 udf03,
                R_UDF06 udf04,
                R_UDF07 udf05,
                0 currentVersion,
                '2020' oprSeqFlag,
                IN_USERID addWho,
                NOW() ADDTIME,
                IN_USERID editWho,
                NOW() editTime,
                R_LOCATIONCAT locationCategory,
                '' manual,
                0 lineCount,
                '*' arNo,
                0 arLineNo,
                '*' apNo,
                0 apLineNo,
                'N' ediSendFlag,
                '' ediErrorCode,
                '' ediErrorMessage,
                NOW() ediSendTime2,
                'N' ediSendFlag2,
                '' ediErrorCode2,
                '' ediErrorMessage2,
                '' billingTranCategory,
                od_docType orderType,
                '' containerType,
                '' containerSize;
				
				

    END IF; -- END IF docType
  
  
	
		END LOOP getTariff;
    CLOSE cur_Tariff;


   --    END IF; --  END IF TARIFF ORDER KOSONG
         END;

 END LOOP cur_order_loop;
  CLOSE cur_orderno;
    SET OUT_returnCode = '000';
 END$$
 DELIMITER $$