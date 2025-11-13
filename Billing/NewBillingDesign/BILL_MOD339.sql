USE WMS_FTEST;

DROP PROCEDURE IF EXISTS BILL_MOD339;

DELIMITER $$

CREATE
DEFINER = 'wms_ftest'@'%'
PROCEDURE BILL_MOD229 (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_orderNo varchar(30),
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
  ##游标定义
  DECLARE inventory_done int DEFAULT FALSE;
  DECLARE tariff_done int DEFAULT FALSE;
  DECLARE cur_Tariff CURSOR FOR

  SELECT DISTINCT
    bsm.organizationId,
    bsm.warehouseId,
    bsm.CUSTOMERID,
    DAY(bth.billingdate) billingDate,
    btr.tariffId,
    btr.tariffLineNo,
    btr.tariffClassNo,
    btd.chargeCategory,
    btd.chargeType,
    btd.descrC,
    btd.docType,
    btd.ratebase,
    btr.ratePerUnit,
    btr.rate,
    btd.minAmount,
    btd.maxAmount,
    IF(btd.UDF03 = '', 0, btd.UDF03) minQty,
    btd.UDF01 AS MaterialNo,
    btd.udf02 AS itemChargeCategory,
    btd.udf04 billMode,
    locationCategory,
    btd.UDF05,
    btd.UDF06,
    btd.UDF07,
    btd.UDF08,
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
  AND bsm.warehouseId = IN_warehouseId
  AND bsm.customerId = IN_CustomerId
  AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
 -- AND btd.chargeCategory = 'IB'
  AND btd.docType IN (SELECT
      dah.soType
    FROM DOC_ORDER_HEADER dah
    WHERE dah.orderNo = IN_orderNo)
  AND btr.rate > 0
  #AND IFNULL(DAY(bth.billingdate),0)!=0 
  ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;
  ####################################################################
  ##程序主体
  BEGIN
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
      #
      SET @enabled = TRUE;



      SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
      SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');


      SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
      SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);

      SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
      SET R_billsummaryId = '';

      IF (R_TARIFFID <> '') THEN
      BEGIN

        DROP TEMPORARY TABLE IF EXISTS TMP_BIL_SUMMARY_INFO_HO;
        DROP TABLE IF EXISTS TMP_BIL_SUMMARY_INFO_HO;




        IF R_ratebase = 'CUBIC' THEN
        BEGIN

         CREATE TEMPORARY TABLE TMP_BIL_SUMMARY_INFO_HO (
		  organizationId varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  orderNo varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  soReference1 varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  soReference3 varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  docType varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  docTypeDescr varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  soStatus varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  warehouseId varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  customerId varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  orderLineNo varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  SKU varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  ShipmentTime varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
		  qty varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  qty_each varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  qtyShipped_each varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  uom varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  qtyCharge varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  totalCube varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  editTime varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  lotNum varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  traceId varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  pickToTraceId varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  dropId varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  location varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  pickToLocation varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  allocationDetailsId varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  skuDescr1 varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  grossWeight varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  cubeNya varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  tariffMasterId varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  QtyPerCases varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  QtyPerPallet varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  zone varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  orderType varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  batch varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  lotAtt07 varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
		  RecType varchar(21) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL
		)




          CALL debug_msg(@enabled, R_docType);
          INSERT INTO TMP_BIL_SUMMARY_INFO_HO
          SELECT 
	IFNULL (CAST(doh.organizationId as char), '' )  AS organizationId,
	IFNULL (CAST(doh.orderNo as char), '' )  AS orderNo,
	IFNULL (CAST(doh.soReference1 as char(255)), '' )  AS soReference1,
	IFNULL (CAST(doh.soReference3 as char(255)), '' )  AS soReference3,
  IFNULL (CAST(t1.codeType as char(255)), '' )  AS docType,
  IFNULL (CAST(t1.codeDescr as char(255)), '' )  AS docTypeDescr,
	IFNULL (CAST(doh.soStatus as char(255)), '' )  AS soStatus,
	IFNULL (CAST(doh.warehouseId as char(255)), '' )  AS warehouseId,
	IFNULL (CAST(aad.customerId as char(255)), '' )  AS customerId,
	IFNULL (CAST(aad.orderLineNo as char(255)), 0 )  AS orderLineNo,
	IFNULL (CAST(aad.SKU as char(255)), '' )  AS SKU,
	CAST(DATE_FORMAT(aad.shipmentTime,'%Y-%m-%d') as char(255))  AS ShipmentTime,
	IFNULL (CAST(aad.qty as char(255)), 0 )  AS qty,
	IFNULL (CAST(aad.qty_each as char(255)), 0 )  AS qty_each,
	IFNULL (CAST(aad.qtyShipped_each as char(255)), 0 )  AS qtyShipped_each,
	IFNULL (CAST(aad.uom as char(255)), '' )  AS uom,
	IFNULL (CAST((SUM( aad.qtyShipped_each * bs.cube)) as char(255)), 0 )  AS qtyCharge,
	IFNULL (CAST((SUM( aad.qtyShipped_each * bs.cube)) as char(255)), 0 )  AS totalCube,
	IFNULL (CAST(aad.editTime as char(255)), '' )  AS editTime,
	IFNULL (CAST(aad.lotNum as char(255)), '' )  AS lotNum,
	IFNULL (CAST(aad.traceId as char(255)), '' )  AS traceId,
	IFNULL (CAST(aad.pickToTraceId as char(255)), '' )  AS pickToTraceId,
	IFNULL (CAST(aad.dropId as char(255)), '' )  AS dropId,
	IFNULL (CAST(aad.location as char(255)), '' )  AS location,
	IFNULL (CAST(aad.pickToLocation as char(255)), '' )  AS pickToLocation,
	IFNULL (CAST(aad.allocationDetailsId as char(255)), '' )  AS allocationDetailsId,
	IFNULL (CAST(bs.skuDescr1 as char(255)), '' )  AS skuDescr1,
	IFNULL (CAST(bs.grossWeight as char(255)), 0 )  AS grossWeight,
	IFNULL (CAST(bs.cube as char(255)), 0 )  AS cubeNya,
	IFNULL (CAST(bsm.tariffMasterId as char(255)), '' )  AS tariffMasterId,
	IFNULL (CAST(bpd.qty as char(255)), 0 )  AS QtyPerCases,
	IFNULL (CAST(bpd1.qty as char(255)), 0 )  AS QtyPerPallet,
	IFNULL (CAST(bz.zoneDescr as char(255)), '' )  AS zone,
	IFNULL (CAST(ila.lotAtt04 as char(255)), '' )  AS batch,
	IFNULL (CAST(ila.lotAtt07 as char(255)), '' )  AS lotAtt07,
	CASE ila.lotAtt07 WHEN 'O' THEN 'Owner Pallet' WHEN 'R' THEN 'Rental Pallet' when 'PP' then 'Rental Plastic Pallet' when 'WP' then 'Rental Wooden Pallet' END AS RecType
	
	from ACT_ALLOCATION_DETAILS aad
	
	left outer join DOC_ORDER_HEADER doh
	ON
	doh.organizationId = aad.organizationId
	AND doh.customerId = aad.customerId
	AND doh.orderNo = aad.orderNo
	left outer join BAS_SKU bs
	ON
	bs.organizationId = aad.organizationId
	AND bs.SKU= aad.SKU
	AND bs.customerId = aad.customerId
	left outer join BAS_SKU_MULTIWAREHOUSE bsm
	ON
	bsm.organizationId = bs.organizationId
	AND bsm.SKU = bs.SKU 
	AND bsm.customerId = bs.customerId
	AND bsm.warehouseId = aad.warehouseId
	
	left outer join INV_LOT_ATT ila
	ON
	ila.organizationId = aad.organizationId
	AND ila.SKU = aad.SKU
	AND ila.lotnum = aad.lotnum
	AND ila.customerId = aad.customerId
	left join BAS_PACKAGE_DETAILS bpd
	ON
	bpd.organizationId = bs.organizationId
	AND bpd.packId = bs.packId
	AND bpd.customerId = bs.customerId
	AND bpd.packUom ='CS'
	left join BAS_PACKAGE_DETAILS bpd1
	ON
	bpd1.organizationId = bs.organizationId
	AND bpd1.packId = bs.packId
	AND bpd1.customerId = bs.customerId
	AND bpd1.packUom ='PL'
	LEFT JOIN
	  BSM_CODE_ML t1
	ON
	  t1.organizationId = aad.organizationId
	  AND t1.codeType = 'SO_TYP'
	  AND t1.codeId = doh.orderType 
	  AND t1.languageId = 'en'
	
	LEFT JOIN BAS_LOCATION bl
	ON
	  bl.organizationId = aad.organizationId
	  AND bl.warehouseId = aad.warehouseId
	  AND bl.locationId = aad.location
	
	LEFT JOIN BAS_ZONE bz
	ON
	  bz.organizationId = bl.organizationId
	  AND bz.warehouseId = bl.warehouseId
	  AND bz.zoneId = bl.zoneId
	  AND bz.zoneGroup = bl.zoneGroup
		
	where
aad.customerId=IN_CustomerId
and aad.warehouseId =IN_warehouseId
and bsm.tariffMasterId NOT LIKE '%PIECES'
AND DATE_FORMAT(aad.shipmentTime,'%Y-%m-%d') >= '2023-09-10'
AND DATE_FORMAT(aad.shipmentTime,'%Y-%m-%d') <= '2023-09-12'
AND aad.Status in ( '99','80')
AND bs.skuDescr1 NOT LIKE '%PALLET%'
AND doh.orderType NOT IN('FREE', 'KT','OT')
	
GROUP BY
doh.organizationId,
doh.orderNo,
doh.soReference1,
doh.soReference3,
t1.codeid,
doh.soStatus,
doh.orderType,
doh.warehouseId,
aad.orderLineNo,
aad.traceId,
aad.pickToTraceId,
aad.dropId,
aad.customerId,
aad.location,
aad.pickToLocation,
aad.shipmentTime,
aad.allocationDetailsId,
aad.SKU,
aad.qty,
aad.qty_each,
aad.qtyShipped_each,
aad.uom,
aad.editTime,
aad.lotNum,
bsm.tariffMasterId,
bs.skuDescr1,
bs.grossWeight,
bs.cube,
bpd.qty,
bpd1.qty,
t1.codeDescr,
bz.zoneDescr,
ila.lotAtt04,
ila.lotAtt07

		   
		  
          IF EXISTS (SELECT
                1
              FROM TMP_BIL_SUMMARY_INFO2) THEN
          BEGIN
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
            END IF;
            #
            IF (R_billsummaryId = '') THEN
              SET @linenumber = 0;
              SET OUT_returnCode = '*_*';
              CALL SPCOM_GetIDSequence(R_ORGANIZATIONID, R_WAREHOUSEID, IN_Language, 'BILLINGSUMMARYID', R_billsummaryId, OUT_returnCode);
              IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
                SET OUT_returnCode = '999#计费流水获取异常';
                LEAVE getTariff;
              END IF;
            END IF;
            #

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
                bil.organizationId,
                bil.warehouseId,
                CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')),
                R_TODATE billingFromDate,
                R_TODATE billingToDate,
                bil.customerId,
                bil.sku,
                bil.lotNum,
                bil.traceId,
                R_TARIFFID,
                R_CHARGECATEGORY,
                R_chargetype,
                R_descrC,
                R_rateBase,
                R_rateperunit,
                bil.qtyReceivedEach,
                bil.uom,
                bil.totalCube,
                bil.grossWeight,
                R_rate,
                bil.qtyCharge * R_rate / R_rateperunit,
                (bil.qtyCharge * (R_rate / R_rateperunit)) + (bil.qtyCharge * (R_rate / R_rateperunit)) * R_INCOMETAX,
                0,
                R_cost * bil.qtyCharge,
                0,
                NOW() confirmTime,
                '' confirmWho,
                bil.docTypeDescr,
                bil.orderNo,
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
                bil.qtyCharge * R_rate / R_rateperunit incomeWithoutTax,
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
                bil.docType orderType,
                '' containerType,
                '' containerSize
              FROM TMP_BIL_SUMMARY_INFO2 bil
            ;




          END;
          END IF;


        END; -- END BEGIN SO SO
        END IF; -- END IF SO

        DROP TEMPORARY TABLE IF EXISTS TMP_BIL_SUMMARY_INFO1;
        DROP TEMPORARY TABLE IF EXISTS TMP_BIL_SUMMARY_INFO2;
      END;
      END IF;
    END LOOP getTariff;
    CLOSE cur_Tariff;
    SET OUT_returnCode = '000';
  END;
END
$$

DELIMITER ;