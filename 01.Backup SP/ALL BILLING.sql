--
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

DELIMITER $$

--
-- Create procedure `CML_BILL_MIN_CHARGE`
--
CREATE
DEFINER = 'it.ari'@'%'
PROCEDURE CML_BILL_MIN_CHARGE (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30))
ENDPROC:
  BEGIN
    -- Declare variables to hold cursor data
    DECLARE done int DEFAULT 0;
    DECLARE tariff_done int DEFAULT 0;
    DECLARE days_done int DEFAULT 0;
    DECLARE v_organizationId varchar(255);
    DECLARE v_warehouseId varchar(20);
    DECLARE v_customerId varchar(20);
    DECLARE v_qty_charge varchar(20);
    DECLARE v_type_handling varchar(20);
    /*  DECLARE v_qty_TraceId decimal(24, 8);
      DECLARE v_qty_MUID decimal(24, 8);
      DECLARE v_max_TraceId decimal(24, 8);
      DECLARE v_avg_TraceId decimal(24, 8);
      DECLARE v_max_MUID decimal(24, 8);
      DECLARE v_avg_MUID decimal(24, 8);
      DECLARE v_max_qty decimal(24, 8);
      DECLARE v_avg_qty decimal(24, 8);
      DECLARE v_qty decimal(24, 8);
      DECLARE v_max_qty_cbm decimal(24, 8);
      DECLARE v_avg_qty_cbm decimal(24, 8);
      DECLARE v_qty_cbm decimal(24, 8);
      DECLARE v_chargeType varchar(255);
      DECLARE v_countDays varchar(255);
      DECLARE v_storageType varchar(255);*/
    -- Declare for Billing
    DECLARE R_CURRENTDATE timestamp;
    DECLARE R_OPDATE varchar(10);
    DECLARE R_FMDATE varchar(10);
    DECLARE R_TODATE varchar(10);
    DECLARE R_BILLINGDAY int;
    DECLARE R_BILLINGDATE varchar(10);
    DECLARE R_Days int(11);
    DECLARE R_TARGETDATE varchar(10);
    DECLARE R_DAYOFMONTH int(11);
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
    DECLARE R_rate_udf03 varchar(50);
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
    DECLARE R_UDF03 varchar(500);
    DECLARE R_UDF06 varchar(500);
    DECLARE R_UDF07 varchar(500);
    DECLARE R_UDF08 varchar(500);
    DECLARE R_qtyMinimumContract decimal(24, 8);
    DECLARE R_chamberName varchar(500);
    DECLARE R_FINALAMOUNT decimal(24, 6);
    DECLARE R_billsummaryId varchar(30) DEFAULT '';
    DECLARE R_billsummaryNo varchar(30) DEFAULT '';
    DECLARE R_LOCATIONCAT char(2);
    DECLARE R_LOCATIONGROUP varchar(500);
    DECLARE R_INCOMETAX decimal(24, 8);
    DECLARE R_RESULTQTYCHARGE decimal(24, 6);  -- add for calculation
    DECLARE R_CLASSFROM decimal(24, 6);
    DECLARE R_CLASSTO decimal(24, 6);
    DECLARE R_CONTRACTNO varchar(100);
    DECLARE R_BILLINGMONTH varchar(10);
    DECLARE R_BILLINGPARTY varchar(10);
    DECLARE R_BILLINGTRANCATEGORY varchar(10);
    DECLARE R_BILLTO varchar(30);
    DECLARE R_NROW integer;
    DECLARE OUT_returnCode varchar(1000);


    -- Declare the cursor
    DECLARE my_cursor CURSOR FOR
    SELECT
      bl1.organizationId,
      bl1.warehouseId,
      bl1.customerId,
      SUM(bl1.qty) AS qtyCharge,
      bl1.type_handling
    FROM (SELECT
        bl.organizationId,
        bl.customerId,
        bl.warehouseId,
        bl.chargeCategory,
        bpd.uomDescr,
        CASE WHEN bpd.customerId = 'ONDULINE' THEN (
              CASE WHEN bpd.uomDescr = 'EA' AND
                  bl.chargeCategory IN ('IB', 'OB') THEN 'PALLET' WHEN bpd.uomDescr = 'PCS' AND
                  bl.chargeCategory = 'IB' THEN 'PALLET' ELSE 'QUANTITY' END) ELSE 'QUANTITY' END AS type_handling,
        CASE WHEN bpd.customerId = 'ONDULINE' THEN SUM(bl.cubic) ELSE SUM(bl.billingAmount / bl.chargeRate) END AS qty
      FROM BIL_SUMMARY bl
        LEFT JOIN BAS_SKU_MULTIWAREHOUSE bsm
          ON bsm.organizationId = bl.organizationId
          AND bsm.customerId = bl.customerId
          AND bsm.warehouseId = bl.warehouseId
          AND bsm.sku = bl.sku
        LEFT JOIN BAS_PACKAGE_DETAILS bpd
          ON bpd.organizationId = bsm.organizationId
          AND bpd.packId = bsm.packId
          AND bpd.customerId = bsm.customerId
          AND bpd.packUom = 'EA'
        LEFT JOIN BAS_PACKAGE_DETAILS bpd1
          ON bpd1.organizationId = bsm.organizationId
          AND bpd1.packId = bsm.packId
          AND bpd1.customerId = bsm.customerId
          AND bpd1.uomDescr = 'CS'
        LEFT JOIN BAS_PACKAGE_DETAILS bpd2
          ON bpd2.organizationId = bsm.organizationId
          AND bpd2.packId = bsm.packId
          AND bpd2.customerId = bsm.customerId
          AND bpd2.uomDescr = 'PL'
      WHERE bl.organizationId = IN_organizationId
      AND bl.warehouseId = IN_warehouseId
      AND bl.customerId = IN_CustomerId -- and bl.billingFromDate between '2025-04-26' and '2025-05-25'
      AND bl.chargeCategory IN ('IB', 'OB')
      AND bl.billingFromDate BETWEEN DATE_FORMAT(DATE_ADD(DATE_ADD(CURRENT_DATE(), INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d') AND DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY) -- '2025-03-26' and '2025-04-25'
      GROUP BY bl.organizationId,
               bl.customerId,
               bl.warehouseId,
               bl.chargeCategory,
               bpd.customerId,
               bpd.packUom,
               bpd.uomDescr) bl1
    WHERE bl1.organizationId = IN_organizationId
    AND bl1.warehouseId = IN_warehouseId
    AND bl1.customerId = IN_CustomerId
    GROUP BY bl1.organizationId,
             bl1.customerId,
             bl1.warehouseId,
             bl1.type_handling;
    -- and bl1.type_handling = 'PALLET'
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Open the cursor
    OPEN my_cursor;

  -- Loop through the results
  read_loop:
    LOOP
      -- Fetch the values into variables
      FETCH my_cursor INTO v_organizationId, v_warehouseId, v_customerId, v_qty_charge, v_type_handling;

      -- Exit the loop if no more rows
      IF done = 1 THEN

        LEAVE read_loop;
      END IF;

      IF NOT EXISTS (SELECT
            1
          FROM BIL_SUMMARY bs
          WHERE bs.organizationId = v_organizationId
          AND bs.warehouseId = v_warehouseId
          AND bs.customerId = v_customerId
          AND bs.billingFromDate BETWEEN DATE_FORMAT(DATE_ADD(DATE_ADD(CURRENT_DATE(), INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d') AND DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)
          --        AND bs.billingFromDate>= IN_datefrom
          --        AND bs.billingFromDate<= IN_dateto
          -- DATE(DATE_ADD(CURDATE(), INTERVAL -1 MONTH))
          -- AND DATE(bs.billingFromDate) = v_stockDate
          -- AND bs.descr = v_workingArea
          AND bs.chargeCategory = 'MC'
          AND bs.chargeType = 'MCB'
          AND bs.notes = v_type_handling
          AND bs.arNo IN ('*')) THEN


      BLOCK2:
        BEGIN
          DECLARE cur_Tariff CURSOR FOR
          SELECT DISTINCT
            bcm.organizationId,
            bcm.warehouseId,
            bcm.CUSTOMERID,
            DATE_FORMAT(DATE(DATE_ADD(bth.billingdate, INTERVAL -1 DAY)), '%d') AS billingDate,
            btr.tariffId,
            btr.tariffLineNo,
            btr.tariffClassNo,
            btd.chargeCategory,
            btd.chargeType,
            btd.descrC,
            btd.docType,
            btd.udf05, -- sementara pengganti ratebase
            btr.ratePerUnit,
            btr.rate,
            btd.minAmount,
            btd.maxAmount,
            -- if (btr.udf02 = '',0,btr,udf02) as minQty,-- minimum billing
            btr.udf03,-- chamber name
            IF(btr.UDF02 = '', 0, btr.UDF02) AS minQty,
            btd.UDF01 AS MaterialNo,
            btd.udf02 AS itemChargeCategory,
            btd.udf04 AS billMode,
            btd.locationCategory,
            btd.UDF05,
            btd.UDF06,
            btd.UDF07,
            btd.UDF08,
            IFNULL(btd.incomeTaxRate, 0) IncomeTaxRate,
            CASE WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1 ELSE IFNULL(btr.classfrom, 0) END,
            IFNULL(btr.classTo, 0),
            bth.contractNo,
            bth.tariffMasterId,
            btr.cost,
            IF(btr.udf03 = '', 0, btr.udf03) AS storageType,
            btd.billingParty,
            -- btd.billingTranCategory,
            IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
          FROM BAS_CUSTOMER_MULTIWAREHOUSE bcm
            INNER JOIN BAS_CUSTOMER bc
              ON bc.customerId = bcm.customerId
              AND bc.organizationId = bcm.organizationId
              AND bc.CustomerType = 'OW'
            INNER JOIN BIL_TARIFF_HEADER bth
              ON bth.organizationId = bcm.organizationId
              AND bth.tariffMasterId = bcm.tariffMasterId
            INNER JOIN BIL_TARIFF_DETAILS btd
              ON btd.organizationId = bth.organizationId
              AND btd.tariffId = bth.tariffId
            INNER JOIN BIL_TARIFF_RATE btr
              ON btr.organizationId = btd.organizationId
              AND btr.tariffId = btd.tariffId
              AND btr.tariffLineNo = btd.tariffLineNo
            LEFT JOIN BSM_CODE_ML bm
              ON bm.organizationId = btd.organizationId
              AND bm.codeId = btd.chargeCategory
              AND bm.codeType = 'CHARGE_CATEGORY'
              AND bm.languageId = 'en'

          WHERE bcm.organizationId = v_organizationId
          AND bcm.warehouseId = v_warehouseId
          AND bcm.customerId = v_customerId
          AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
          AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
          AND btd.chargeCategory = 'MC'
          AND btd.chargeType = 'MCB'
          AND btr.rate > 0
          AND btr.udf03 = v_type_handling
          /*        AND case when bcm.customerId in ('ECMAMA','ECMAMAB2C','MAPCLUB') then (btr.udf03 = v_storageType)
                  else (btr.udf03 ='') end*/
          #AND IFNULL(DAY(bth.billingdate),0)!=0 
          ORDER BY bcm.organizationId, bcm.warehouseId, bcm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo, btr.rate, btr.udf03;


          DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;

          SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd


          #
          OPEN cur_Tariff;
        getTariff:
          LOOP
            FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
            R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount,/*R_qtyMinimumContract,*/ R_chamberName, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
            R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_rate_udf03, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;

            /*SELECT
                      'look->',
                      tariff_done,
                      R_RESULTQTYCHARGE,
                        v_qty_TraceId,
                        v_qty_MUID,
                        v_max_TraceId,
                        v_avg_TraceId,
                        v_max_MUID,
                        v_avg_MUID,
            			v_qty,
                        v_max_qty,
                        v_avg_qty,
                        v_chargeType,
                        R_minAmount,
                        R_rate,
                        R_ratePerUnit;*/
            --  SELECT 'DEBUG->',R_CUSTOMERID,v_warehouseId,v_customerId;


            IF tariff_done = 1 THEN
              SET tariff_done = 0;
              LEAVE getTariff;
            END IF;

            -- SELECT R_CUSTOMERID,R_WAREHOUSEID;
            -- SELECT tariff_done;


            IF (LTRIM(RTRIM(R_WAREHOUSEID)) = LTRIM(RTRIM(v_warehouseId)))
              AND (LTRIM(RTRIM(R_CUSTOMERID)) = LTRIM(RTRIM(v_customerId))) THEN

              -- CALCULATION
              -- UOM
              -- PALLET
              -- CUBIC
              -- M2
              -- CASE
              -- IP
              -- PIECES
              -- KG
              -- LITER
              -- DO
              -- HOUR
              -- MONTH


              --           SELECT  'check=>',R_ratebase,R_TARIFFID;
              SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
              SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
              SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
              SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
              SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
              SET R_billsummaryId = '';

              /*IF (R_billMode = 'CUBIC') THEN
               IF(v_max_TraceId > sum(R_minAmount/(R_rate/R_ratePerUnit)) THEN
                  SET R_RESULTQTYCHARGE = v_max_TraceId;
                ELSE
                  SET R_RESULTQTYCHARGE = R_minAmount;
                END IF;*/

              SELECT
                'TRAP',
                R_rate,
                R_billMode,
                R_rate_udf03,
                v_type_handling,
                R_minAmount,
                R_rate,
                R_ratePerUnit;
              IF (R_ratebase = 'CUBIC') THEN
                IF (v_qty_charge > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = 0;
                ELSE
                  SET R_RESULTQTYCHARGE = (R_minQty - v_qty_charge);
                END IF;
              ELSEIF (R_ratebase = 'QUANTITY') THEN
                IF (v_qty_charge > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = 0;
                ELSE
                  SET R_RESULTQTYCHARGE = (R_minQty - v_qty_charge);
                END IF;
              ELSEIF (R_ratebase = 'PALLET') THEN
                IF (v_qty_charge > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = 0;
                ELSE
                  SET R_RESULTQTYCHARGE = (R_minQty - v_qty_charge);
                END IF;
              ELSEIF (R_ratebase = 'CASE') THEN
                IF (v_qty_charge > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = 0;
                ELSE
                  SET R_RESULTQTYCHARGE = (R_minQty - v_qty_charge);
                END IF;
              ELSEIF (R_ratebase = 'ORDERNO') THEN
                IF (v_qty_charge > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = 0;
                ELSE
                  SET R_RESULTQTYCHARGE = (R_minQty - v_qty_charge);
                END IF;
              ELSEIF (R_ratebase = 'MT') THEN
                IF (v_qty_charge > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = 0;
                ELSE
                  SET R_RESULTQTYCHARGE = (R_minQty - v_qty_charge);
                END IF;
              ELSEIF (R_ratebase = 'KG') THEN
                IF (v_qty_charge > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = 0;
                ELSE
                  SET R_RESULTQTYCHARGE = (R_minQty - v_qty_charge);
                END IF;
              /*           ELSEIF (R_billMode = 'MONTHLOC') THEN
                          IF (v_qty_MUID > R_minQty) THEN
                            SET R_RESULTQTYCHARGE = v_qty_MUID;
                          ELSE
                            SET R_RESULTQTYCHARGE = R_minQty;
                          END IF;
                         ELSEIF (R_billMode = 'MONTHPL') THEN
                          IF (v_qty_MUID > R_minQty) THEN
                            SET R_RESULTQTYCHARGE = v_qty_MUID;
                          ELSE
                            SET R_RESULTQTYCHARGE = R_minQty;
                          END IF;
                         ELSEIF (R_billMode = 'MONTHQTY') THEN
                          IF (v_qty > R_minQty) THEN
                            SET R_RESULTQTYCHARGE = v_qty;
                          ELSE
                            SET R_RESULTQTYCHARGE = R_minQty;
                          END IF;
                         ELSEIF (R_billMode = 'MAXCBM') THEN
                          IF (v_max_qty_cbm > R_minQty) then
                            SET R_RESULTQTYCHARGE = v_max_qty_cbm;
                          ELSE
                            SET R_RESULTQTYCHARGE = R_minQty;
                          END IF;
                         ELSEIF (R_billMode = 'MAXPL') and v_customerId in ('NIA_SBY','SKU_SBY') THEN
                          IF (v_max_MUID > R_minQty) then
                            SET R_RESULTQTYCHARGE = (v_max_MUID * v_countDays);
                          ELSE
                            SET R_RESULTQTYCHARGE = (R_minQty * v_countDays);
                          END IF;*/
              END IF;


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
                  AND chargeRate = R_rate
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
                  AND chargeRate = R_rate
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
                  AND chargeRate = R_rate
                  AND arNo IN ('*');
              END IF; -- EXIST BILLING SUMMARY

              #
              IF (R_billsummaryId = '') THEN
                SET @linenumber = 0;
                SET OUT_returnCode = '';
                CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);

                IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
                  SET OUT_returnCode = '999#????????';
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
                  v_organizationId,
                  v_warehouseId,
                  CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')),
                  R_BILLINGDATE,
                  R_BILLINGDATE,
                  v_customerId,
                  '',
                  '',
                  '',
                  R_TARIFFID,
                  R_CHARGECATEGORY,
                  R_chargetype,
                  R_descrC,
                  -- '',
                  R_rateBase,
                  R_rateperunit,
                  R_RESULTQTYCHARGE,
                  '',
                  0,
                  0,
                  R_rate,
                  R_RESULTQTYCHARGE * R_rate / R_rateperunit,
                  (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
                  0,
                  R_cost * R_RESULTQTYCHARGE,
                  0,
                  NOW() confirmTime,
                  '' confirmWho,
                  '',
                  '',
                  '' createTransactionid,
                  R_rate_udf03 AS notes,
                  NOW() ediSendTime,
                  v_customerId AS billTo,
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
                  R_RESULTQTYCHARGE * R_rate / R_rateperunit incomeWithoutTax,
                  0 cosWithoutTax,
                  '' costInvoiceType,
                  '' noteText,
                  R_materialNo AS udf01,
                  R_itemChargeCategory AS udf02,
                  0 udf03,
                  R_UDF06 udf04,
                  '' udf05,
                  0 currentVersion,
                  '2020' oprSeqFlag,
                  'CUSTOMBILL' addWho,
                  NOW() ADDTIME,
                  'CUSTOMBILL' editWho,
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
                  '' orderType,
                  '' containerType,
                  '' containerSize;

            END IF; -- END IF docType

          END LOOP getTariff;
          CLOSE cur_Tariff;

        END;
      ELSE
        ITERATE read_loop;
      END IF;

    END LOOP;

    -- Close the cursor
    CLOSE my_cursor;

  END
  $$

--
-- Create procedure `CML_BILLVASSPECIALSTD`
--
CREATE
DEFINER = 'sa'@'%'
PROCEDURE CML_BILLVASSPECIALSTD (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_trans_no varchar(30),
IN IN_tariffMaster varchar(30))
BEGIN


  ####################################################################
  ##????
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
  DECLARE R_VASTYPE varchar(20);
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
  DECLARE R_RESULTQTYCHARGE decimal(24, 8);  -- add for calculation
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
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
  DECLARE od_soReference1 varchar(255);
  DECLARE od_skuDescr1 varchar(255);
  DECLARE od_warehouseId varchar(255);
  DECLARE od_customerId varchar(255);
  DECLARE od_vasNo varchar(255);
  DECLARE od_vasLineNo varchar(255);
  DECLARE od_sku varchar(255);
  DECLARE od_qtyReceived varchar(255);
  DECLARE od_uom varchar(255);
  DECLARE od_qtyReceivedEach varchar(255);
  DECLARE od_totalCube varchar(255);
  DECLARE od_vasType varchar(255);
  DECLARE od_chargeCategory varchar(255);
  DECLARE od_chargeType varchar(255);
  DECLARE od_qtyCharge varchar(255);
  DECLARE od_closetime datetime;
  DECLARE OUT_returnCode varchar(1000);

  ####################################################################
  ##????
  DECLARE inventory_done int DEFAULT 0;
  DECLARE tariff_done int DEFAULT 0;
  DECLARE order_done,
          attribute_done int DEFAULT 0;



  DECLARE cur_orderno CURSOR FOR
  SELECT
    dvh.organizationId,
    dvh.warehouseId,
    dvd.customerId,
    dvh.vasNo,
    dvd.vasLineNo,
    dvd.sku,
    dvs.vasType,
    dvf.chargeCategory,
    dvf.chargeType,
    dvf.rateQty1 AS qtycharge,
    dvf.chargeDate
  FROM DOC_VAS_HEADER dvh
    INNER JOIN DOC_VAS_DETAILS dvd
      ON dvh.organizationId = dvd.organizationId
      AND dvh.warehouseId = dvd.warehouseId
      AND dvh.vasNo = dvd.vasNo
      AND dvh.customerId = dvd.customerId
    INNER JOIN DOC_VAS_SERVICE dvs
      ON dvh.organizationId = dvs.organizationId
      AND dvh.warehouseId = dvs.warehouseId
      AND dvh.vasNo = dvs.vasNo
    INNER JOIN DOC_VAS_FEE dvf
      ON dvh.organizationId = dvf.organizationId
      AND dvd.warehouseId = dvf.warehouseId
      AND dvh.vasNo = dvf.vasNo
  WHERE dvh.organizationId = IN_organizationId
  AND dvh.customerId = IN_CustomerId
  AND dvh.warehouseId = IN_warehouseId
  AND dvh.vasNo = IN_trans_no;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET order_done = 1;
  OPEN cur_orderno;
cur_order_loop:
  LOOP
    FETCH FROM cur_orderno INTO od_organizationId,
    od_warehouseId,
    od_customerId,
    od_vasNo,
    od_vasLineNo,
    od_sku,
    od_vasType,
    od_chargeCategory,
    od_chargeType,
    od_qtyCharge,
    od_closetime;

    IF order_done = 1 THEN

      SET order_done = 0;
      LEAVE cur_order_loop;
    END IF;


  BLOCK2:
    BEGIN

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
        btd.vasType,
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
        btd.billingParty,
        -- btd.billingTranCategory,
        IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
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
      AND bth.tariffMasterId = IN_tariffMaster
      AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND btd.chargeCategory = 'VA'
      AND btd.chargeType = od_chargeType /*AB update chargeType 2024-10-28*/
      AND btd.vasType = od_vasType /*AB update detail vasType 2025-06-04*/
      AND btd.udf01 IN ('1700000145', '1700000008', '1700000147')
      AND btr.rate > 0
      AND btd.tariffLineNo > 100
      #AND IFNULL(DAY(bth.billingdate),0)!=0 
      ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;

      SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd
      #
      OPEN cur_Tariff;
    getTariff:
      LOOP
        FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_VASTYPE, R_descrC, R_docType,
        R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
        R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;
        IF tariff_done THEN
          SET tariff_done = FALSE;
          LEAVE getTariff;
        END IF;


        SELECT
          UPPER(R_CHARGECATEGORY),
          UPPER(R_CHARGETYPE),
          UPPER(R_VASTYPE),
          UPPER(od_chargeCategory),
          UPPER(od_chargeType),
          UPPER(od_vasType);

        IF (UPPER(R_CHARGETYPE) = UPPER(od_chargeType))
          AND (UPPER(R_CHARGECATEGORY) = UPPER(od_chargeCategory))
          AND (UPPER(R_VASTYPE) = UPPER(od_vasType)) THEN /*update detail vasType AB '2025-06-04*/
          -- CALCULATION
          -- UOM
          -- PALLET
          -- CUBIC
          -- M2
          -- CASE
          -- IP
          -- PIECES
          -- KG
          -- LITER
          -- DO
          -- HOUR
          -- MONTH



          SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
          SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
          SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
          SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
          SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
          SET R_billsummaryId = '';


          SET R_RESULTQTYCHARGE = od_qtyCharge;






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
          #
          IF (R_billsummaryId = '') THEN
            SET @linenumber = 0;
            SET OUT_returnCode = '*_*';
            CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);
            IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
              SET OUT_returnCode = '999#????????';
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
              od_organizationId,
              od_warehouseId,
              CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')),
              DATE_FORMAT(od_closetime, '%Y-%m-%d'),
              DATE_FORMAT(od_closetime, '%Y-%m-%d'),
              od_customerId,
              od_sku,
              '',
              '',
              R_TARIFFID,
              R_CHARGECATEGORY,
              R_chargetype,
              R_descrC,
              R_rateBase,
              R_rateperunit,
              od_qtyCharge,
              od_uom,
              '0',
              '0',
              R_rate,
              R_RESULTQTYCHARGE * R_rate / R_rateperunit,
              (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
              0,
              R_cost * R_RESULTQTYCHARGE,
              0,
              NULL confirmTime,
              '' confirmWho,
              'VAS' dockType,
              od_vasNo,
              '' createTransactionid,
              R_CHARGETYPE notes,
              NULL ediSendTime,
              R_BILLTO billTo,
              NULL settleTime,
              '' settleWho,
              '' followUp,
              '' invoiceType,
              '' paidTo,
              '' costConfirmFlag,
              NULL costConfirmTime,
              '' costConfirmWho,
              '' costSettleFlag,
              NULL costSettleTime,
              '' costSettleWho,
              NULL incomeTaxRate,
              0 costTaxRate,
              NULL incomeTax,
              0 cosTax,
              NULL incomeWithoutTax,
              NULL cosWithoutTax,
              '' costInvoiceType,
              '' noteText,
              R_materialNo AS udf01,
              R_itemChargeCategory AS udf02,
              R_UDF08 udf03,
              R_UDF06 udf04,
              NULL udf05,
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
              NULL ediSendTime2,
              'N' ediSendFlag2,
              '' ediErrorCode2,
              '' ediErrorMessage2,
              '' billingTranCategory,
              '' orderType,
              '' containerType,
              '' containerSize;

        END IF; -- END IF docType

      END LOOP getTariff;
      CLOSE cur_Tariff;


    --  END IF; 
    --  END IF TARIFF ORDER KOSONG
    END;




  END LOOP cur_order_loop;
  CLOSE cur_orderno;
  SET OUT_returnCode = '000';
END
$$

--
-- Create procedure `CML_BILLTRFBAGGINGSTD`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLTRFBAGGINGSTD (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_trans_no varchar(30),
IN IN_tariffMaster varchar(30))
ENDPROC:
  BEGIN
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
    DECLARE R_RESULTQTYCHARGE decimal(24, 8);  -- add for calculation
    DECLARE R_CLASSFROM decimal(24, 8);
    DECLARE R_CLASSTO decimal(24, 8);
    DECLARE R_CONTRACTNO varchar(100);
    DECLARE R_BILLINGMONTH varchar(10);
    DECLARE R_BILLINGPARTY varchar(10);
    DECLARE R_BILLINGTRANCATEGORY varchar(10);
    DECLARE R_BILLTO varchar(30);
    DECLARE R_NROW integer;
    DECLARE R_UDF08 varchar(500);
    DECLARE R_UDF07 varchar(500);
    DECLARE R_Days int(11) DEFAULT NULL;
    DECLARE OD_CURSORDONE boolean DEFAULT FALSE;
    DECLARE odh_organizationId varchar(20);
    DECLARE odh_warehouseId varchar(20);
    DECLARE odh_tdocNo varchar(20);
    DECLARE vodh_tdocNo varchar(20);
    DECLARE od_tdocType varchar(20);
    DECLARE od_status varchar(2);
    DECLARE od_customerId varchar(30);
    DECLARE od_organizationId varchar(20);
    DECLARE od_warehouseId varchar(20);
    DECLARE od_tdocNo varchar(20);
    DECLARE od_tdocLineNo int(11);
    DECLARE od_tdocLineStatus varchar(2);
    DECLARE od_fmCustomerId varchar(30);
    DECLARE od_fmSku varchar(50);
    DECLARE od_fmQty decimal(18, 8);
    DECLARE od_toCustomerId varchar(30);
    DECLARE od_toSku varchar(50);
    DECLARE od_toLotAtt04 varchar(30);/*AB additional information to billing list 11/11/24*/
    DECLARE od_toLotAtt05 varchar(30);/*AB additional information to billing list 11/11/24*/
    DECLARE od_toLotAtt06 varchar(30);/*AB additional information to billing list 11/11/24*/
    DECLARE od_toLotAtt08 varchar(30);/*AB additional information to billing list 11/11/24*/
    DECLARE od_codeDescr varchar(50);/*AB additional information to billing list 11/11/24*/
    DECLARE od_toQty decimal(18, 8);
    DECLARE od_closedtime timestamp;
    DECLARE OUT_Return_Code varchar(1000);
    DECLARE tariff_done int DEFAULT 0;
    DECLARE _GETLINEORDER CURSOR FOR
    SELECT
      dth.organizationId,
      dth.warehouseId,
      dth.customerId,
      dth.tdocNo,
      dth.tdocType,
      dtd.tdocLineNo,
      dtd.toSku,
      dtd.toLotAtt04,/*AB additional information to billing list 11/11/24*/
      dtd.toLotAtt05,/*AB additional information to billing list 11/11/24*/
      dtd.toLotAtt06,/*AB additional information to billing list 11/11/24*/
      dtd.toLotAtt08,/*AB additional information to billing list 11/11/24*/
      dtd.fmSku,
      dtd.fmQty,
      dtd.toQty,
      bcm.codeDescr,/*AB additional information to billing list 11/11/24*/
      dth.editTime
    FROM DOC_TRANSFER_HEADER dth
      INNER JOIN DOC_TRANSFER_DETAILS dtd
        ON dth.organizationId = dtd.organizationId
        AND dth.warehouseId = dtd.warehouseId
        AND dth.tdocNo = dtd.tdocNo
      LEFT JOIN BSM_CODE_ML bcm
        ON bcm.organizationId = dth.organizationId
        AND bcm.codeId = dth.tdocType
        AND bcm.codeType = 'TRF_TYP'
        AND bcm.languageId = 'en'
    WHERE dth.organizationId = IN_organizationId
    AND dtd.warehouseId = IN_warehouseId
    AND dth.tdocNo = IN_trans_no
    AND dth.customerId = IN_CustomerId
    AND dth.status = '99'
    AND dtd.tdocLineStatus = '99';
    -- AND dth.tdocType = 'BG';
    -- AND dtd.tdocLineNo = IN_lineNO;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET OD_CURSORDONE = TRUE;
    OPEN _GETLINEORDER;
  GETLINEORDERLOOP:
    LOOP FETCH FROM _GETLINEORDER INTO od_organizationId,
      od_warehouseId,
      od_customerId,
      od_tdocNo,
      od_tdocType,
      od_tdocLineNo,
      od_toSku,
      od_toLotAtt04,
      od_toLotAtt05,
      od_toLotAtt06,
      od_toLotAtt08,
      od_fmSku,
      od_fmQty,
      od_toQty,
      od_codeDescr,
      od_closedtime;


      IF OD_CURSORDONE THEN
        SET OD_CURSORDONE = FALSE;
        LEAVE GETLINEORDERLOOP;
      END IF;

      BEGIN

        IF (od_tdocType IS NULL) THEN
          SET OUT_Return_Code = '201';
          LEAVE ENDPROC;
        END IF;


      /*       SELECT
                btm.tariffMasterId INTO IN_tariffMaster
              FROM BIL_TARIFF_MASTER btm
              WHERE btm.organizationId = IN_organizationId
              AND btm.customerId = IN_CustomerId;*/

      --         CALL SPCOM_GetIDSequence_NEW(IN_organizationId,
      --         IN_warehouseId,'en',
      --         'TDOCNO',
      --         vodh_tdocNo,
      --         OUT_Return_Code);

      BLOCK2:
        BEGIN
          DECLARE cur_Tariff CURSOR FOR
          SELECT DISTINCT
            bsm.organizationId,
            bsm.warehouseId,
            bsm.CUSTOMERID,
            bsm.tariffMasterId,
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
            btd.billingParty,
            -- btd.billingTranCategory,
            IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
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
          -- AND bth.tariffMasterId = IN_tariffMasterId
          AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
          AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
          AND btd.chargeCategory = 'TD'
          AND btd.chargeType = od_tdocType
          -- AND btd.vasType = 'BG'
          AND btd.udf01 IN ('1700000008')
          AND btr.rate > 0
          AND btd.tariffLineNo > 100
          #AND IFNULL(DAY(bth.billingdate),0)!=0 
          ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;

          SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd
          #
          OPEN cur_Tariff;
        getTariff:
          LOOP
            FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_TARIFFMASTERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
            R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
            R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;
            IF tariff_done THEN
              SET tariff_done = FALSE;
              LEAVE getTariff;
            END IF;
            SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
            SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
            SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
            SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
            SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
            SET R_billsummaryId = '';


            SET R_RESULTQTYCHARGE = od_toQty;
            SET R_CHARGETYPE = od_tdocType;

            SELECT
              od_tdocType,
              od_tdocLineNo,
              od_tdocNo,
              od_toLotAtt04,
              od_toLotAtt05,
              od_toLotAtt06,
              od_toLotAtt08,
              od_codeDescr,
              R_RESULTQTYCHARGE;

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
            #
            IF (R_billsummaryId = '') THEN
              SET @linenumber = 0;
              SET OUT_Return_Code = '*_*';
              CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_Return_Code);
              IF SUBSTRING(OUT_Return_Code, 1, 3) <> '000' THEN
                SET OUT_Return_Code = '999#????????';
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
                od_organizationId,
                od_warehouseId,
                CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')),
                DATE_FORMAT(od_closedtime, '%Y-%m-%d'),
                DATE_FORMAT(od_closedtime, '%Y-%m-%d'),
                od_customerId,
                od_toSku,
                '',
                '',
                R_TARIFFID,
                R_CHARGECATEGORY,
                R_chargetype,
                R_descrC,
                R_rateBase,
                R_rateperunit,
                od_toQty,
                '',
                '0',
                '0',
                R_rate,
                R_RESULTQTYCHARGE * R_rate / R_rateperunit,
                (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
                0,
                R_rate * R_RESULTQTYCHARGE,
                0,
                NULL confirmTime,
                '' confirmWho,
                od_tdocType,
                od_tdocNo,
                '' createTransactionid,
                od_toLotAtt06 notes,
                NULL ediSendTime,
                R_BILLTO,
                NULL settleTime,
                '' settleWho,
                '' followUp,
                '' invoiceType,
                '' paidTo,
                '' costConfirmFlag,
                NULL costConfirmTime,
                '' costConfirmWho,
                '' costSettleFlag,
                NULL costSettleTime,
                '' costSettleWho,
                NULL incomeTaxRate,
                0 costTaxRate,
                NULL incomeTax,
                0 cosTax,
                NULL incomeWithoutTax,
                NULL cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                R_materialNo AS udf01,
                R_itemChargeCategory AS udf02,
                R_UDF08 udf03,
                R_UDF06 udf04,
                NULL udf05,
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
                NULL ediSendTime2,
                'N' ediSendFlag2,
                '' ediErrorCode2,
                '' ediErrorMessage2,
                '' billingTranCategory,
                od_tdocType orderType,
                '' containerType,
                '' containerSize;



          END LOOP getTariff;
          CLOSE cur_Tariff;






        END;
      END;
    END LOOP GETLINEORDERLOOP;
    CLOSE _GETLINEORDER;

  END
  $$

--
-- Create procedure `CML_BILLSUMMARYPROCESS_MANUAL`
--
CREATE
DEFINER = 'sa'@'localhost'
PROCEDURE CML_BILLSUMMARYPROCESS_MANUAL (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_customerId varchar(30),
IN IN_USERID varchar(30),
INOUT OUT_Return_Code varchar(500))
ENDPROC:
  BEGIN
    DECLARE delimiterChar longtext;
    DECLARE inputString longtext;
    DECLARE OUT_returnCode varchar(1000);
    DECLARE r_generateArno char(15);
    DECLARE r_totalbillingAmount decimal(24, 8);


    SET r_totalbillingAmount = 0;


    -- GENERATE ARNUMBER
    SET OUT_returnCode = '*_*';
    SET @linenumber = 0;
    CALL SPCOM_GetIDSequence_NEW(IN_organizationId, '*', 'en', 'BILLINGARC', r_generateArno, OUT_returnCode);
    IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
      SET OUT_returnCode = '999#????????';
    --   LEAVE cur_billingsm_loop;
    END IF;
    SET @linenumber = 0;

    BEGIN


      DECLARE r_organizationId varchar(20);
      DECLARE r_warehouseId varchar(20);
      DECLARE r_billingSummaryId varchar(30);
      DECLARE r_billingFromDate varchar(30);
      DECLARE r_billingToDate varchar(30);
      DECLARE r_customerId varchar(30);

      DECLARE r_chargeCategory varchar(20);
      DECLARE r_chargeType varchar(20);

      DECLARE r_amount decimal(24, 8);
      DECLARE r_billingAmount decimal(24, 8);





      DECLARE inventory_done int DEFAULT 0;
      DECLARE tariff_done int DEFAULT 0;
      DECLARE billing_sm_done,
              attribute_done int DEFAULT 0;




      DECLARE cur_billingsm CURSOR FOR
      SELECT
        bs.organizationId,
        bs.warehouseId,
        -- billingSummaryId,
        NOW() AS billingFromDate,
        NOW() AS billingToDate,
        bs.customerId,
        bs.chargeCategory,
        bs.chargeType,
        SUM(bs.billingAmount) AS total_billingAmount
      FROM BIL_SUMMARY bs
        INNER JOIN Z_CML_BILLINGSUMMARYID zcb
          ON bs.organizationId = zcb.organizationId
          AND bs.warehouseId = zcb.warehouseId
          AND bs.customerId = zcb.customerId
          AND bs.billingSummaryId = zcb.billingSummaryId
      WHERE bs.organizationId = IN_organizationId
      AND bs.warehouseId = IN_warehouseId
      AND bs.customerId = IN_customerId
      AND (bs.arNo = '*'
      OR bs.arNo IS NULL
      OR bs.arNo = '') -- ADD VALIDASI ONLY BILLING WITH NO AR
      GROUP BY organizationId,
               warehouseId,
               customerId,
               chargeCategory,
               chargeType;

      DECLARE CONTINUE HANDLER FOR NOT FOUND SET billing_sm_done = 1;
      OPEN cur_billingsm;
    cur_billingsm_loop:
      LOOP
        FETCH FROM cur_billingsm INTO r_organizationId,
        r_warehouseId, r_billingFromDate, r_billingToDate, r_customerId, r_chargeCategory, r_chargeType, r_billingAmount;

        IF billing_sm_done = 1 THEN
          SET billing_sm_done = 0;
          LEAVE cur_billingsm_loop;
        END IF;


        SET r_totalbillingAmount = r_totalbillingAmount + r_billingAmount;

        -- INSERT DETAIL
        INSERT INTO BIL_BILLING_DETAILS (organizationId, warehouseId, billingNo, billingLineNo, chargeCategory,
        chargeType, billingAmount, noteText, udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag,
        addWho, addTime, editWho, editTime)
          SELECT
            r_organizationId,
            r_warehouseId,
            r_generateArno,
            -- NULL,
            (@linenumber := @linenumber + 1),
            r_chargeCategory,
            r_chargeType,
            r_billingAmount,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            100,
            '20230925105523000711RA172031009087[A3702]',
            IN_USERID,
            NOW(),
            IN_USERID,
            NOW();



        -- UPDATE AR NO
        UPDATE BIL_SUMMARY bs
        SET bs.arNo = r_generateArno,
            bs.arLineNo = @linenumber
        WHERE bs.organizationId = IN_organizationId
        AND bs.billingSummaryId IN (SELECT
            zcb.billingSummaryId
          FROM Z_CML_BILLINGSUMMARYID zcb)
        AND (bs.arNo = '*'
        OR bs.arNo IS NULL
        OR bs.arNo = '')

        AND bs.warehouseId = r_warehouseId
        AND bs.customerId = r_customerId
        AND bs.chargeCategory = r_chargeCategory
        AND bs.chargeType = r_chargeType;

      END LOOP cur_billingsm_loop;
      CLOSE cur_billingsm;
      -- SET OUT_returnCode = '000';



      -- INSERT HEADER
      INSERT INTO BIL_BILLING_HEADER (organizationId, warehouseId, billingNo, STATUS, billTo, customerId, billingDate, billDateFM, billDateTO,
      totalAmount, discountStart, discountRate, totalBillingAmount, actualAmount, noteText, udf01, udf02, udf03, udf04, udf05, currentVersion,
      oprSeqFlag, addWho, addTime, editWho, editTime, billingType, minAmount, maxAmount)
        SELECT
          r_organizationId,
          r_warehouseId,
          r_generateArno,
          '00',
          r_customerId,
          r_customerId,
          NOW(),
          NOW(),
          NOW(),
          r_totalbillingAmount,
          0,
          0,
          NULL AS totalBillingAmount,
          NULL AS actualAmount,
          NULL AS noteText,
          NULL AS udf01,
          NULL AS udf02,
          NULL AS udf03,
          NULL AS udf04,
          'N' AS udf05,
          100 AS currentVersion,
          '20230925105523000711RA172031009087[A3702]' AS oprSeqFlag,
          IN_USERID AS addWho,
          NOW() AS addTime,
          IN_USERID AS editWho,
          NOW() AS editTime,
          'AR',
          NULL,
          NULL;



      -- Clear Temporary

      DELETE
        FROM Z_CML_BILLINGSUMMARYID;


      COMMIT;
      SET OUT_Return_Code = r_generateArno;
    END;
  END
  $$

--
-- Create procedure `CML_BILLSUMMARYPROCESS`
--
CREATE
DEFINER = 'sa'@'localhost'
PROCEDURE CML_BILLSUMMARYPROCESS (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_BillingSummaryID longtext)
ENDPROC:
  BEGIN
    DECLARE delimiterChar longtext;
    DECLARE inputString longtext;
    DECLARE OUT_returnCode varchar(1000);
    DECLARE r_generateArno char(15);
    DECLARE r_totalbillingAmount decimal(24, 8);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
      GET DIAGNOSTICS CONDITION 1
      @p1 = RETURNED_SQLSTATE, @p2 = MESSAGE_TEXT, @p3 = MYSQL_ERRNO, @p4 = TABLE_NAME, @p5 = COLUMN_NAME;
      ROLLBACK;
      SET OUT_returnCode = CONCAT('999#CML_BILLSUMMARYPROCESS', IFNULL(@p1, ''), IFNULL(@p2, ''), IFNULL(@p3, ''), IFNULL(@p4, ''), IFNULL(@p5, ''));
    END;

    DROP TEMPORARY TABLE IF EXISTS temp_bilsummaryId;
    CREATE TEMPORARY TABLE temp_bilsummaryId (
      vals longtext
    );


    SET r_totalbillingAmount = 0;
    SET delimiterChar = ',';
    SET inputString = IN_BillingSummaryID;
    WHILE LOCATE(delimiterChar, inputString) > 1 DO
      INSERT INTO temp_bilsummaryId
        SELECT
          SUBSTRING_INDEX (inputString, delimiterChar, 1);
      SET inputString = REPLACE(inputString, (SELECT
          LEFT(inputString, LOCATE(delimiterChar, inputString))), '');
    END WHILE;
    INSERT INTO temp_bilsummaryId (vals)
      VALUES (inputString);

    -- GENERATE ARNUMBER
    SET OUT_returnCode = '*_*';
    SET @linenumber = 0;
    CALL SPCOM_GetIDSequence_NEW(IN_organizationId, '*', IN_Language, 'BILLINGARC', r_generateArno, OUT_returnCode);
    IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
      SET OUT_returnCode = '999#????????';
    --   LEAVE cur_billingsm_loop;
    END IF;
    SET @linenumber = 0;

    BEGIN


      DECLARE r_organizationId varchar(20);
      DECLARE r_warehouseId varchar(20);
      DECLARE r_billingSummaryId varchar(30);
      DECLARE r_billingFromDate varchar(30);
      DECLARE r_billingToDate varchar(30);
      DECLARE r_customerId varchar(30);

      DECLARE r_chargeCategory varchar(20);
      DECLARE r_chargeType varchar(20);

      DECLARE r_amount decimal(24, 8);
      DECLARE r_billingAmount decimal(24, 8);





      DECLARE inventory_done int DEFAULT 0;
      DECLARE tariff_done int DEFAULT 0;
      DECLARE billing_sm_done,
              attribute_done int DEFAULT 0;


      DECLARE cur_billingsm CURSOR FOR
      SELECT
        organizationId,
        warehouseId,
        -- billingSummaryId,
        NOW() AS billingFromDate,
        NOW() AS billingToDate,
        customerId,
        chargeCategory,
        chargeType,
        SUM(
        CASE WHEN billingAmount IS NULL OR
            billingAmount = 0 THEN COALESCE(amount, 0) ELSE billingAmount END
        ) AS total_billingAmount
      FROM BIL_SUMMARY bs
      WHERE bs.organizationId = IN_organizationId
      AND bs.warehouseId = IN_warehouseId
      AND (bs.arNo = '*'
      OR bs.arNo IS NULL
      OR bs.arNo = '') -- ADD VALIDASI ONLY BILLING WITH NO AR
      AND bs.billingSummaryId IN (SELECT
          vals
        FROM temp_bilsummaryId)
      GROUP BY organizationId,
               warehouseId,
               customerId,
               chargeCategory,
               chargeType;

      DECLARE CONTINUE HANDLER FOR NOT FOUND SET billing_sm_done = 1;

      OPEN cur_billingsm;
    cur_billingsm_loop:
      LOOP
        FETCH FROM cur_billingsm INTO r_organizationId,
        r_warehouseId, r_billingFromDate, r_billingToDate, r_customerId, r_chargeCategory, r_chargeType, r_billingAmount;


        IF billing_sm_done = 1 THEN
          SET billing_sm_done = 0;
          LEAVE cur_billingsm_loop;
        END IF;

        SET r_totalbillingAmount = r_totalbillingAmount + r_billingAmount;

        -- INSERT DETAIL
        INSERT INTO BIL_BILLING_DETAILS (organizationId, warehouseId, billingNo, billingLineNo, chargeCategory,
        chargeType, billingAmount, noteText, udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag,
        addWho, addTime, editWho, editTime)
          SELECT
            r_organizationId,
            r_warehouseId,
            r_generateArno,
            -- NULL,
            (@linenumber := @linenumber + 1),
            r_chargeCategory,
            r_chargeType,
            r_billingAmount,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            100,
            '20230925105523000711RA172031009087[A3702]',
            IN_USERID,
            NOW(),
            IN_USERID,
            NOW();



        -- UPDATE AR NO
        UPDATE BIL_SUMMARY bs
        SET bs.arNo = r_generateArno,
            bs.arLineNo = @linenumber
        WHERE bs.organizationId = IN_organizationId
        AND bs.billingSummaryId IN (SELECT
            vals
          FROM temp_bilsummaryId)
        AND (bs.arNo = '*'
        OR bs.arNo IS NULL
        OR bs.arNo = '')

        AND bs.warehouseId = r_warehouseId
        AND bs.customerId = r_customerId
        AND bs.chargeCategory = r_chargeCategory
        AND bs.chargeType = r_chargeType;

      END LOOP cur_billingsm_loop;
      CLOSE cur_billingsm;
      -- SET OUT_returnCode = '000';



      -- INSERT HEADER
      INSERT INTO BIL_BILLING_HEADER (organizationId, warehouseId, billingNo, STATUS, billTo, customerId, billingDate, billDateFM, billDateTO,
      totalAmount, discountStart, discountRate, totalBillingAmount, actualAmount, noteText, udf01, udf02, udf03, udf04, udf05, currentVersion,
      oprSeqFlag, addWho, addTime, editWho, editTime, billingType, minAmount, maxAmount)
        SELECT
          r_organizationId,
          r_warehouseId,
          r_generateArno,
          '00',
          r_customerId,
          r_customerId,
          NOW(),
          NOW(),
          NOW(),
          r_totalbillingAmount,
          0,
          0,
          NULL AS totalBillingAmount,
          NULL AS actualAmount,
          NULL AS noteText,
          NULL AS udf01,
          NULL AS udf02,
          NULL AS udf03,
          NULL AS udf04,
          'N' AS udf05,
          100 AS currentVersion,
          '20230925105523000711RA172031009087[A3702]' AS oprSeqFlag,
          IN_USERID AS addWho,
          NOW() AS addTime,
          IN_USERID AS editWho,
          NOW() AS editTime,
          'AR',
          NULL,
          NULL;







      DROP TEMPORARY TABLE IF EXISTS temp_bilsummaryId;
      COMMIT;
    END;
  END
  $$

--
-- Create procedure `CML_BILLSTORAGE_SAVEDAILY_STORAGEPCS`
--
CREATE
DEFINER = 'sa'@'%'
PROCEDURE CML_BILLSTORAGE_SAVEDAILY_STORAGEPCS (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_userId varchar(30),
IN IN_language varchar(30),
IN IN_customerId varchar(30))
BEGIN
  -- Declare variables to hold cursor data
  DECLARE done int DEFAULT 0;
  DECLARE tariff_done int DEFAULT 0;
  DECLARE v_stockDate date;
  DECLARE v_customerId varchar(20);
  DECLARE v_warehouseId varchar(20);
  DECLARE v_skuGroup1 varchar(255);
  DECLARE v_qtyCharge decimal(18, 4);
  DECLARE v_storagetype varchar(100);
  DECLARE OUT_returnCode varchar(1000);


  -- Declare the cursor
  DECLARE my_cursor CURSOR FOR

  SELECT
    DATE_FORMAT(ls_storage.stockdate, '%Y-%m-%d') AS stockDate,
    ls_storage.warehouseid,
    ls_storage.customerid,
    ls_storage.storage_type,
    SUM(ls_storage.qtyonhand)
  FROM (SELECT
      DATE_FORMAT(stockDate, '%Y-%m-%d') AS stockdate,
      zib.customerId,
      zib.warehouseId AS warehouseid,
      CASE zib.customerId WHEN 'MAP' THEN (
            CASE WHEN la.lotatt04 = 'SET' THEN 0 ELSE (s.cube * zib.qtyonHand) END
            ) WHEN 'ONDULINE' THEN s.cube * zib.qtyonHand ELSE totalcube END AS qtycbm,
      zib.qtyonHand AS qtyonhand,

      CASE WHEN zib.customerId IN ('ECMAMA', 'ECMAMAB2C') THEN (
            CASE WHEN SUBSTRING(zib.locationId, 1, 10) = 'STAGEAC-01' AND
                s.freightClass = 'COOL-NON-FOOD' THEN 'AC' WHEN SUBSTRING(zib.locationId, 1, 10) = 'STAGEAC-03' AND
                s.freightClass = 'COOL-NON-FOOD' THEN 'AC' WHEN SUBSTRING(zib.locationId, 1, 10) = 'STAGEAC-05' AND
                s.freightClass = 'COOL-NON-FOOD' THEN 'AC' WHEN SUBSTRING(zib.locationId, 1, 10) = 'STAGEAC-07' AND
                s.freightClass = 'COOL-NON-FOOD' THEN 'AC' WHEN zib.locationId LIKE 'E08%' AND
                s.freightClass = 'COOL-NON-FOOD' THEN 'AC' WHEN zib.locationId LIKE 'E09%' AND
                s.freightClass = 'COOL-NON-FOOD' THEN 'AC' ELSE 'AMBIENT' END) ELSE 'DRY' END AS storage_type
    FROM Z_InventoryBalance zib
      LEFT JOIN INV_LOT_ATT la
        ON la.organizationId = zib.organizationId
        AND la.customerId = zib.customerId
        AND la.sku = zib.sku
        AND la.lotNum = zib.lotNum
      LEFT JOIN BAS_LOCATION l
        ON l.organizationId = zib.organizationId
        AND l.locationId = zib.locationId
        AND l.warehouseId = zib.warehouseId
      LEFT JOIN BAS_SKU s
        ON s.organizationId = zib.organizationId
        AND s.customerId = zib.customerId
        AND s.sku = zib.sku
    WHERE zib.organizationId = 'OJV_CML'
    --       AND DATE(zib.StockDate) >= '2025-04-26'
    --       AND DATE(zib.StockDate) <= '2025-05-20'
    -- AND zib.warehouseId IN ('LADC01')
    --  AND zib.warehouseId IN ('CBT02', 'CBT03', 'LADC01','CBT02-B2C')
    AND DATE(zib.StockDate) = DATE(DATE_ADD(NOW(), INTERVAL -1 DAY))
    AND zib.customerId = IN_customerId
    AND qtyonHand > 0
    AND zib.locationId NOT IN ('CONSWOR', 'LOST_CBT01', 'STG01', 'STG02', 'STG03', 'STG04', 'STG05', 'STG11', 'STG12', 'STG13', 'STG14', 'STG15', 'STG06', 'STG07', 'STG08', 'STG09', 'STG10', 'STG16', 'STG17', 'STG18', 'STG19', 'STG20', 'SORTATIONCBT01', 'CROSSDOCK_01', 'CROSSDOCK_02', 'SORTATIONLADC01', 'SORTATIONBASF01', 'SORTATIONCBT02', 'SORTATIONCBT03', 'SORTATION', 'SORTATIONMRD02', 'SORTATIONSMG-SO', 'SORTATION1', 'CYCLE-01S', 'LOST_CBT01', 'STO-01', 'STO-02', 'STO-03', 'STO-04', 'STO-05', 'WHAQC', 'WHCQC', 'WHCQC01', 'WHCQC03', 'WHCQC05', 'WHCQC09', 'WHCQC11', 'WHCQC13', 'WHCQC15', 'WHCQC17', 'WHCQC19', 'WHCQC21', 'WHCQC23', 'WHCQC25', 'WHCQC27', 'WHCQC29', 'WHCQC31', 'WHCQC33', 'WHCQC35', 'WHIQC', 'WORK_AREA', 'B04A065', 'B04A066', 'B04B065', 'B04B065')
    AND zib.sku NOT IN (SELECT
        sku
      FROM BAS_SKU bs2
      WHERE organizationId = zib.organizationId
      AND customerId = 'LTL'
      AND sku LIKE '13%'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU bs2
      WHERE organizationid = zib.organizationId
      AND customerid = 'SMARTSBY'
      AND sku = 'PALLET'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU
      WHERE organizationid = zib.organizationId
      AND customerid IN ('ECMAMA', 'ECMAMAB2C')
      AND sku LIKE '%TEST%'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU
      WHERE organizationid = zib.organizationId
      AND customerid IN ('MAP')
      AND sku IN ('DEMO TABLE AT', 'DEMO TABLE SAM', 'HOT STAMP'))
    ORDER BY zib.customerId) ls_storage
  GROUP BY ls_storage.warehouseId,
           ls_storage.customerId,
           ls_storage.StockDate,
           ls_storage.storage_type
  ORDER BY ls_storage.warehouseId, ls_storage.customerId, stockDate, ls_storage.storage_type;
  -- Declare a handler for NOT FOUND condition
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  -- Open the cursor
  OPEN my_cursor;

-- Loop through the results
read_loop:
  LOOP
    -- Fetch the values into variables
    FETCH my_cursor INTO v_stockDate, v_warehouseId, v_customerId, v_storagetype, v_qtyCharge;



    IF done = 1 THEN
      LEAVE read_loop;
    END IF;


    INSERT INTO Z_BIL_AKUM_DAYS_STORAGE (organizationId
    , warehouseId
    , customerId
    , StockDate
    , qty
    , chargeType
    , addWho
    , addTime
    , editWho
    , editTime
    , UDF01)
      VALUES ('OJV_CML', v_warehouseId, v_customerId, v_stockDate -- StockDate - DATE
      , v_qtyCharge -- qty_cbm - DECIMAL(18, 8)
      , 'STRG' -- chargeType - VARCHAR(10) NOT NULL
      , 'CUSTOMBILL' -- addWho - VARCHAR(100)
      , NOW() -- addTime - DATETIME
      , 'CUSTOMBILL' -- editWho - VARCHAR(100)
      , NOW() -- editTime - DATETIME
      , v_storagetype -- UDF01 - VARCHAR(100)
      );


  END LOOP;

  -- Close the cursor
  CLOSE my_cursor;

END
$$

--
-- Create procedure `CML_BILLSTORAGE_SAVEDAILY_STORAGECBM`
--
CREATE
DEFINER = 'sa'@'%'
PROCEDURE CML_BILLSTORAGE_SAVEDAILY_STORAGECBM (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_userId varchar(30),
IN IN_language varchar(30),
IN IN_customerId varchar(30))
BEGIN
  -- Declare variables to hold cursor data
  DECLARE done int DEFAULT 0;
  DECLARE tariff_done int DEFAULT 0;
  DECLARE v_stockDate date;
  DECLARE v_customerId varchar(20);
  DECLARE v_warehouseId varchar(20);
  DECLARE v_skuGroup1 varchar(255);
  DECLARE v_qtyCharge decimal(18, 4);
  DECLARE v_storagetype varchar(100);
  DECLARE OUT_returnCode varchar(1000);


  -- Declare the cursor
  DECLARE my_cursor CURSOR FOR

  SELECT
    DATE_FORMAT(ls_storage.stockdate, '%Y-%m-%d') AS stockDate,
    ls_storage.warehouseid,
    ls_storage.customerid,
    ls_storage.storage_type,
    SUM(ls_storage.qtycbm) AS qtycbm
  FROM (SELECT
      DATE_FORMAT(stockDate, '%Y-%m-%d') AS stockdate,
      zib.customerId,
      zib.warehouseId AS warehouseid,
      CASE zib.customerId WHEN 'MAP' THEN (
            CASE WHEN la.lotatt04 = 'SET' THEN 0 ELSE (s.cube * zib.qtyonHand) END
            ) WHEN 'ONDULINE' THEN s.cube * zib.qtyonHand ELSE totalcube END AS qtycbm,
      CASE WHEN zib.customerId IN ('ECMAMA', 'ECMAMAB2C') THEN (
            CASE WHEN SUBSTRING(zib.locationId, 1, 10) = 'STAGEAC-01' AND
                s.freightClass = 'COOL-NON-FOOD' THEN 'AC' WHEN SUBSTRING(zib.locationId, 1, 10) = 'STAGEAC-03' AND
                s.freightClass = 'COOL-NON-FOOD' THEN 'AC' WHEN SUBSTRING(zib.locationId, 1, 10) = 'STAGEAC-05' AND
                s.freightClass = 'COOL-NON-FOOD' THEN 'AC' WHEN SUBSTRING(zib.locationId, 1, 10) = 'STAGEAC-07' AND
                s.freightClass = 'COOL-NON-FOOD' THEN 'AC' WHEN zib.locationId LIKE 'E08%' AND
                s.freightClass = 'COOL-NON-FOOD' THEN 'AC' WHEN zib.locationId LIKE 'E09%' AND
                s.freightClass = 'COOL-NON-FOOD' THEN 'AC' ELSE 'AMBIENT' END) ELSE 'DRY' END AS storage_type
    FROM Z_InventoryBalance zib
      LEFT JOIN INV_LOT_ATT la
        ON la.organizationId = zib.organizationId
        AND la.customerId = zib.customerId
        AND la.sku = zib.sku
        AND la.lotNum = zib.lotNum
      LEFT JOIN BAS_LOCATION l
        ON l.organizationId = zib.organizationId
        AND l.locationId = zib.locationId
        AND l.warehouseId = zib.warehouseId
      LEFT JOIN BAS_SKU s
        ON s.organizationId = zib.organizationId
        AND s.customerId = zib.customerId
        AND s.sku = zib.sku
    WHERE zib.organizationId = IN_organizationId
    --   AND DATE(zib.StockDate) >= '2025-04-26'
    --   AND DATE(zib.StockDate) <= '2025-05-18'
    -- AND zib.warehouseId IN ('LADC01')
    --  AND zib.warehouseId IN ('CBT02', 'CBT03', 'LADC01','CBT02-B2C')
    AND DATE(zib.StockDate) = DATE(DATE_ADD(NOW(), INTERVAL -1 DAY))
    AND zib.customerId = IN_CustomerId
    AND qtyonHand > 0
    AND zib.locationId NOT IN ('CONSWOR', 'LOST_CBT01', 'STG01', 'STG02', 'STG03', 'STG04', 'STG05', 'STG11', 'STG12', 'STG13', 'STG14', 'STG15', 'STG06', 'STG07', 'STG08', 'STG09', 'STG10', 'STG16', 'STG17', 'STG18', 'STG19', 'STG20', 'SORTATIONCBT01', 'CROSSDOCK_01', 'CROSSDOCK_02', 'SORTATIONLADC01', 'SORTATIONBASF01', 'SORTATIONCBT02', 'SORTATIONCBT03', 'SORTATION', 'SORTATIONMRD02', 'SORTATIONSMG-SO', 'SORTATION1', 'CYCLE-01S', 'LOST_CBT01', 'STO-01', 'STO-02', 'STO-03', 'STO-04', 'STO-05', 'WHAQC', 'WHCQC', 'WHCQC01', 'WHCQC03', 'WHCQC05', 'WHCQC09', 'WHCQC11', 'WHCQC13', 'WHCQC15', 'WHCQC17', 'WHCQC19', 'WHCQC21', 'WHCQC23', 'WHCQC25', 'WHCQC27', 'WHCQC29', 'WHCQC31', 'WHCQC33', 'WHCQC35', 'WHIQC', 'WORK_AREA', 'B04A065', 'B04A066', 'B04B065', 'B04B065')
    AND zib.sku NOT IN (SELECT
        sku
      FROM BAS_SKU bs2
      WHERE organizationId = zib.organizationId
      AND customerId = 'LTL'
      AND sku LIKE '13%'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU bs2
      WHERE organizationid = zib.organizationId
      AND customerid = 'SMARTSBY'
      AND sku = 'PALLET'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU
      WHERE organizationid = zib.organizationId
      AND customerid IN ('ECMAMA', 'ECMAMAB2C')
      AND sku LIKE '%TEST%'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU
      WHERE organizationid = zib.organizationId
      AND customerid IN ('MAP')
      AND sku IN ('DEMO TABLE AT', 'DEMO TABLE SAM', 'HOT STAMP'))
    ORDER BY zib.customerId) ls_storage
  GROUP BY ls_storage.warehouseId,
           ls_storage.customerId,
           ls_storage.StockDate,
           ls_storage.storage_type
  ORDER BY ls_storage.warehouseId, ls_storage.customerId, stockDate, ls_storage.storage_type;
  -- Declare a handler for NOT FOUND condition
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  -- Open the cursor
  OPEN my_cursor;

-- Loop through the results
read_loop:
  LOOP
    -- Fetch the values into variables
    FETCH my_cursor INTO v_stockDate, v_warehouseId, v_customerId, v_storagetype, v_qtyCharge;



    IF done = 1 THEN
      LEAVE read_loop;
    END IF;


    INSERT INTO Z_BIL_AKUM_DAYS_STORAGE (organizationId
    , warehouseId
    , customerId
    , StockDate
    , qty_cbm
    , chargeType
    , addWho
    , addTime
    , editWho
    , editTime
    , UDF01)
      VALUES ('OJV_CML', v_warehouseId, v_customerId, v_stockDate -- StockDate - DATE
      , v_qtyCharge -- qty_cbm - DECIMAL(18, 8)
      , 'STRG' -- chargeType - VARCHAR(10) NOT NULL
      , 'CUSTOMBILL' -- addWho - VARCHAR(100)
      , NOW() -- addTime - DATETIME
      , 'CUSTOMBILL' -- editWho - VARCHAR(100)
      , NOW() -- editTime - DATETIME
      , v_storagetype -- UDF01 - VARCHAR(100)
      );


  END LOOP;

  -- Close the cursor
  CLOSE my_cursor;

END
$$

--
-- Create procedure `CML_BILLSTORAGE_R_BILL_MODE_SPLIT`
--
CREATE
DEFINER = 'it.ari'@'%'
PROCEDURE CML_BILLSTORAGE_R_BILL_MODE_SPLIT (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30))
BEGIN
  -- Declare variables to hold cursor data
  DECLARE done int DEFAULT 0;
  DECLARE tariff_done int DEFAULT 0;
  DECLARE days_done int DEFAULT 0;
  DECLARE v_organizationId varchar(255);
  DECLARE v_warehouseId varchar(20);
  DECLARE v_customerId varchar(20);
  DECLARE v_qty_TraceId decimal(24, 8);
  DECLARE v_qty_MUID decimal(24, 8);
  DECLARE v_max_TraceId decimal(24, 8);
  DECLARE v_avg_TraceId decimal(24, 8);
  DECLARE v_max_MUID decimal(24, 8);
  DECLARE v_avg_MUID decimal(24, 8);
  DECLARE v_max_qty decimal(24, 8);
  DECLARE v_avg_qty decimal(24, 8);
  DECLARE v_qty decimal(24, 8);
  DECLARE v_max_qty_cbm decimal(24, 8);
  DECLARE v_avg_qty_cbm decimal(24, 8);
  DECLARE v_qty_cbm decimal(24, 8);
  DECLARE v_chargeType varchar(255);
  DECLARE v_countDays varchar(255);
  DECLARE v_storageType varchar(255);
  -- Declare for Billing
  DECLARE R_CURRENTDATE timestamp;
  DECLARE R_OPDATE varchar(10);
  DECLARE R_FMDATE varchar(10);
  DECLARE R_TODATE varchar(10);
  DECLARE R_BILLINGDAY int;
  DECLARE R_BILLINGDATE varchar(10);
  DECLARE R_Days int(11);
  DECLARE R_TARGETDATE varchar(10);
  DECLARE R_DAYOFMONTH int(11);
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
  DECLARE R_rate_udf03 varchar(50);
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
  DECLARE R_UDF03 varchar(500);
  DECLARE R_UDF06 varchar(500);
  DECLARE R_UDF07 varchar(500);
  DECLARE R_UDF08 varchar(500);
  DECLARE R_qtyMinimumContract decimal(24, 8);
  DECLARE R_chamberName varchar(500);
  DECLARE R_FINALAMOUNT decimal(24, 6);
  DECLARE R_billsummaryId varchar(30) DEFAULT '';
  DECLARE R_billsummaryNo varchar(30) DEFAULT '';
  DECLARE R_LOCATIONCAT char(2);
  DECLARE R_LOCATIONGROUP varchar(500);
  DECLARE R_INCOMETAX decimal(24, 8);
  DECLARE R_RESULTQTYCHARGE decimal(24, 6);
  DECLARE R_CLASSFROM decimal(24, 6);
  DECLARE R_CLASSTO decimal(24, 6);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
  DECLARE R_BILLTO varchar(30);
  DECLARE R_NROW integer;
  DECLARE OUT_returnCode varchar(1000);

  -- Variables for split logic -- add akbar
  DECLARE v_split_qty decimal(24, 8);
  DECLARE v_remaining_qty decimal(24, 8);
  DECLARE v_split_counter int DEFAULT 1;
  DECLARE v_max_split_qty decimal(24, 8) DEFAULT 1200; -- Maximum qty per split, ini bisa diubah ubah sesuai kebutuhan

  -- Declare the cursor
  DECLARE my_cursor CURSOR FOR
  SELECT
    zib.organizationId,
    zib.warehouseId,
    zib.customerId,
    SUM(zib.qty_TraceId) AS sum_traceId,
    SUM(zib.qty_MUID) AS sum_MUID,
    MAX(zib.qty_TraceId) AS max_TraceId,
    AVG(zib.qty_TraceId) AS avg_TraceId,
    MAX(zib.qty_MUID) AS max_MUID,
    AVG(zib.qty_MUID) AS avg_MUID,
    SUM(zib.qty) AS sum_qty,
    MAX(zib.qty) AS max_qty,
    AVG(zib.qty) AS avg_qty,
    SUM(zib.qty_cbm) AS sum_cbm,
    MAX(zib.qty_cbm) AS max_qty_cbm,
    AVG(zib.qty_cbm) AS avg_qty_cbm,
    zib.udf01,
    SUM(zib.udf02),
    zib.chargeType
  FROM Z_BIL_AKUM_DAYS_STORAGE zib
  WHERE zib.organizationId = IN_organizationId
  AND zib.customerId = IN_CustomerId
  AND zib.StockDate BETWEEN DATE_FORMAT(DATE_ADD(DATE_ADD(CURRENT_DATE(), INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d') AND DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)
  AND zib.warehouseId = IN_warehouseId
  AND zib.chargeType = 'STRG'
  GROUP BY zib.organizationId,
           zib.warehouseId,
           zib.customerId,
           zib.udf01,
           zib.chargeType
  ORDER BY zib.organizationId, zib.warehouseId, zib.customerId, zib.chargeType;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  -- Open the cursor
  OPEN my_cursor;

-- Loop
read_loop:
  LOOP
    -- Fetch
    FETCH my_cursor INTO v_organizationId, v_warehouseId, v_customerId, v_qty_TraceId, v_qty_MUID, v_max_TraceId, v_avg_TraceId, v_max_MUID, v_avg_MUID, v_qty, v_max_qty, v_avg_qty, v_qty_cbm, v_max_qty_cbm, v_avg_qty_cbm, v_storageType, v_countDays, v_chargeType;

    -- Exit the loop if no more rows
    IF done = 1 THEN
      LEAVE read_loop;
    END IF;

    IF NOT EXISTS (SELECT
          1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = v_organizationId
        AND bs.warehouseId = v_warehouseId
        AND bs.customerId = v_customerId
        AND bs.billingFromDate BETWEEN DATE_FORMAT(DATE_ADD(DATE_ADD(CURRENT_DATE(), INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d') AND DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)
        AND bs.chargeCategory = 'IV'
        AND bs.chargeType = 'ST'
        AND bs.notes = v_storageType
        AND bs.arNo IN ('*')) THEN

    BLOCK2:
      BEGIN
        DECLARE cur_Tariff CURSOR FOR
        SELECT DISTINCT
          bcm.organizationId,
          bcm.warehouseId,
          bcm.CUSTOMERID,
          DATE_FORMAT(DATE(DATE_ADD(bth.billingdate, INTERVAL -1 DAY)), '%d') AS billingDate,
          btr.tariffId,
          btr.tariffLineNo,
          btr.tariffClassNo,
          btd.chargeCategory,
          btd.chargeType,
          btd.descrC,
          btd.docType,
          btd.udf05, -- sementara pengganti ratebase
          btr.ratePerUnit,
          btr.rate,
          btd.minAmount,
          btd.maxAmount,
          btr.udf03,-- chamber name
          IF(btr.UDF02 = '', 0, btr.UDF02) AS minQty,
          btd.UDF01 AS MaterialNo,
          btd.udf02 AS itemChargeCategory,
          btd.udf04 AS billMode,
          btd.locationCategory,
          btd.UDF05,
          btd.UDF06,
          btd.UDF07,
          btd.UDF08,
          IFNULL(btd.incomeTaxRate, 0) IncomeTaxRate,
          CASE WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1 ELSE IFNULL(btr.classfrom, 0) END,
          IFNULL(btr.classTo, 0),
          bth.contractNo,
          bth.tariffMasterId,
          btr.cost,
          IF(btr.udf03 = '', 0, btr.udf03) AS storageType,
          btd.billingParty,
          IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
        FROM BAS_CUSTOMER_MULTIWAREHOUSE bcm
          INNER JOIN BAS_CUSTOMER bc
            ON bc.customerId = bcm.customerId
            AND bc.organizationId = bcm.organizationId
            AND bc.CustomerType = 'OW'
          INNER JOIN BIL_TARIFF_HEADER bth
            ON bth.organizationId = bcm.organizationId
            AND bth.tariffMasterId = bcm.tariffMasterId
          INNER JOIN BIL_TARIFF_DETAILS btd
            ON btd.organizationId = bth.organizationId
            AND btd.tariffId = bth.tariffId
          INNER JOIN BIL_TARIFF_RATE btr
            ON btr.organizationId = btd.organizationId
            AND btr.tariffId = btd.tariffId
            AND btr.tariffLineNo = btd.tariffLineNo
          LEFT JOIN BSM_CODE_ML bm
            ON bm.organizationId = btd.organizationId
            AND bm.codeId = btd.udf04
            AND bm.codeType = 'SP_TRACEID'
            AND bm.languageId = 'en'

        WHERE bcm.organizationId = v_organizationId
        AND bcm.warehouseId = v_warehouseId
        AND bcm.customerId = v_customerId
        AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND btd.chargeCategory = 'IV'
        AND btd.chargeType = 'ST'
        AND btr.rate > 0
        AND CASE WHEN bcm.customerId IN ('ECMAMA', 'ECMAMAB2C', 'MAPCLUB', 'CERESSMG', 'NLDC', 'NLDCSBY', 'CERESSBY', 'PT.ITT_MDN', 'PPG', 'DNN_MDN') THEN (btr.udf03 = v_storageType) ELSE (btr.udf03 = '') END
        ORDER BY bcm.organizationId, bcm.warehouseId, bcm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo, btr.rate, btr.udf03;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;

        SET R_CURRENTDATE = CURDATE();

        OPEN cur_Tariff;
      getTariff:
        LOOP
          FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
          R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_chamberName, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
          R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_rate_udf03, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;

          IF tariff_done = 1 THEN
            SET tariff_done = 0;
            LEAVE getTariff;
          END IF;

          IF (LTRIM(RTRIM(R_WAREHOUSEID)) = LTRIM(RTRIM(v_warehouseId)))
            AND (LTRIM(RTRIM(R_CUSTOMERID)) = LTRIM(RTRIM(v_customerId))) THEN

            -- CALCULATION LOGIC (sama seperti sebelumnya)
            SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
            SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
            SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
            SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
            SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
            SET R_billsummaryId = '';

            -- [CALCULATION LOGIC - same as original code for all billMode cases]
            IF (R_billMode = 'MAXTRACE') THEN
              IF v_customerId IN ('LTL')
                AND v_warehouseId IN ('CBT01') THEN
                IF (v_max_TraceId > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = (v_max_TraceId - R_minQty);
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              ELSEIF v_customerId IN ('PPG')
                AND R_rate_udf03 = 'NON WH-C' THEN
                IF (v_max_TraceId > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = v_max_TraceId;
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              ELSEIF v_customerId IN ('DNN_MDN')
                AND v_warehouseId IN ('KIMSTR')
                AND R_TARIFFMASTERID = 'BIL00085' THEN
                IF ((v_max_TraceId * 1.44) > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = (v_max_TraceId * 1.44);
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              ELSEIF v_customerId NOT IN ('LTL', 'PPG', 'DNN_MDN') THEN
                IF (v_max_TraceId > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = v_max_TraceId;
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              END IF;
            ELSEIF (R_billMode = 'MAXPL') THEN
              IF v_customerId IN ('NIA_SBY', 'SKU_SBY')
                AND v_warehouseId IN ('SBYKK') THEN
                IF (v_max_MUID > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = (v_max_MUID * v_countDays);
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              ELSEIF v_customerId IN ('API')
                AND v_warehouseId IN ('CBT02') THEN
                IF ((((v_max_MUID * 1.44) / 2) + ((((v_max_MUID * 1.44) / 2) / 6.5) * 3.5)) > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = (((v_max_MUID * 1.44) / 2) + ((((v_max_MUID * 1.44) / 2) / 6.5) * 3.5));
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              ELSEIF v_customerId NOT IN ('NIA_SBY', 'SKU_SBY', 'API') THEN
                IF (v_max_MUID > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = v_max_MUID;
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              END IF;
            ELSEIF (R_billMode = 'MAXQTY') THEN
              IF v_customerId IN ('PT.ITT_MDN')
                AND v_warehouseid = 'KIMSTR'
                AND v_storageType = 'REGULER' THEN
                IF ((v_max_qty / 1000) > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = (v_max_qty / 1000);
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              ELSEIF v_customerId IN ('PT.ITT_MDN')
                AND v_warehouseid = 'KIMSTR'
                AND v_storageType = 'EXCESS' THEN
                IF ((v_max_qty / 1000) > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = 1;
                ELSE
                  SET R_RESULTQTYCHARGE = 1;
                END IF;
              ELSEIF v_customerId NOT IN ('PT.ITT_MDN') THEN
                IF (v_max_qty > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = v_max_qty;
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              END IF;
            ELSEIF (R_billMode = 'AVGTRACE') THEN
              IF v_customerId IN ('PPG')
                AND R_rate_udf03 IN ('WH-C') THEN
                IF (v_avg_TraceId > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = v_avg_TraceId;
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              ELSEIF v_customerId NOT IN ('PPG')
                AND R_rate_udf03 NOT IN ('WH-C') THEN
                IF (v_avg_TraceId > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = v_avg_TraceId;
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              END IF;
            ELSEIF (R_billMode = 'AVGLOC') THEN
              IF (v_avg_TraceId > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_avg_TraceId;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            ELSEIF (R_billMode = 'AVGPL') THEN
              IF (v_avg_MUID > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_avg_MUID;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            ELSEIF (R_billMode = 'AVGQTY') THEN
              IF (v_avg_qty > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_avg_qty;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            ELSEIF (R_billMode = 'MONTHTRACE') THEN
              IF (v_qty_TraceId > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_qty_TraceId;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            ELSEIF (R_billMode = 'MONTHLOC') THEN
              IF (v_qty_MUID > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_qty_MUID;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            ELSEIF (R_billMode = 'MONTHPL') THEN
              IF (v_qty_MUID > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_qty_MUID;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            ELSEIF (R_billMode = 'MONTHQTY') THEN
              IF (v_qty > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_qty;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            ELSEIF (R_billMode = 'MAXCBM') THEN
              IF (v_max_qty_cbm > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_max_qty_cbm;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            ELSEIF (R_billMode = 'INTRACE') THEN
              IF (v_qty_TraceId > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_qty_TraceId;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            END IF;


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
                AND chargeRate = R_rate
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
                AND chargeRate = R_rate
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
                AND chargeRate = R_rate
                AND arNo IN ('*');
            END IF;

            -- Get billing summary ID
            IF (R_billsummaryId = '') THEN
              SET @linenumber = 0;
              SET OUT_returnCode = '';
              CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);

              IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
                SET OUT_returnCode = '999#????????';
                LEAVE getTariff;
              END IF;
            END IF;

            -- ==================== mulai split ====================

            SET v_remaining_qty = R_RESULTQTYCHARGE;
            SET v_split_counter = 1;

          -- Split loop: lakukan loop insert jika lebih dari 1200
          split_loop:
            LOOP
              -- metu nek qty ne 0
              IF v_remaining_qty <= 0 THEN
                LEAVE split_loop;
              END IF;

              -- di split jika lebih dari maximum 1200
              IF v_remaining_qty > v_max_split_qty THEN
                SET v_split_qty = v_max_split_qty;
              ELSE
                SET v_split_qty = v_remaining_qty;
              END IF;

              -- Mulai insert split record
              INSERT INTO BIL_SUMMARY (organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate, customerId,
              sku, lotNum, traceId, tariffId, chargeCategory, chargeType, descr, rateBase, chargePerUnits,
              qty, uom, cubic, weight, chargeRate, amount, billingAmount, cost, amountPayable, amountPaid,
              confirmTime, confirmWho, docType, docNo, createTransactionid, notes, ediSendTime,
              billTo, settleTime, settleWho, followUp, invoiceType, paidTo, costConfirmFlag,
              costConfirmTime, costConfirmWho, costSettleFlag, costSettleTime, costSettleWho, incomeTaxRate,
              costTaxRate, incomeTax, cosTax, incomeWithoutTax, cosWithoutTax, costInvoiceType, noteText,
              udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag, addWho, ADDTIME, editWho, editTime, locationCategory,
              manual, docLineNo, arNo, arLineNo, apNo, apLineNo, ediSendFlag, ediErrorCode, ediErrorMessage, ediSendTime2, ediSendFlag2,
              ediErrorCode2, ediErrorMessage2, billingTranCategory, orderType, containerType, containerSize)
                VALUES (v_organizationId, v_warehouseId, CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')), R_BILLINGDATE, R_BILLINGDATE, v_customerId, '', '', '', R_TARIFFID, R_CHARGECATEGORY, R_chargetype, CONCAT(R_descrC, ' - Split ', v_split_counter), R_rateBase, R_rateperunit, v_split_qty, -- Use split quantity instead of total
                '', 0, 0, R_rate, (v_split_qty * R_rate) / R_rateperunit, (v_split_qty * (R_rate / R_rateperunit)), 0, R_cost * v_split_qty, 0, NOW(), '', '', '', '', R_rate_udf03, NOW(), v_customerId, NOW(), '', '', '', '', '', NOW(), '', '', NOW(), '', 0, 0, R_INCOMETAX, 0, v_split_qty * R_rate / R_rateperunit, 0, '', '', R_materialNo, R_itemChargeCategory, 0, R_UDF06, '', 0, '2020', 'CUSTOMBILL', NOW(), 'CUSTOMBILL', NOW(), R_LOCATIONCAT, '', 0, '*', 0, '*', 0, 'N', '', '', NOW(), 'N', '', '', '', '', '', '');

              -- Update sisa qty
              SET v_remaining_qty = v_remaining_qty - v_split_qty;
              SET v_split_counter = v_split_counter + 1;

            END LOOP split_loop;


          END IF;
        END LOOP getTariff;
        CLOSE cur_Tariff;

      END;
    ELSE
      ITERATE read_loop;
    END IF;

  END LOOP;

  -- Close the cursor
  CLOSE my_cursor;

END
$$

--
-- Create procedure `CML_BILLSTORAGE_R_BILL_MODE`
--
CREATE
DEFINER = 'it.ari'@'%'
PROCEDURE CML_BILLSTORAGE_R_BILL_MODE (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30))
BEGIN
  -- Declare variables to hold cursor data
  DECLARE done int DEFAULT 0;
  DECLARE tariff_done int DEFAULT 0;
  DECLARE days_done int DEFAULT 0;
  DECLARE v_organizationId varchar(255);
  DECLARE v_warehouseId varchar(20);
  DECLARE v_customerId varchar(20);
  DECLARE v_qty_TraceId decimal(24, 8);
  DECLARE v_qty_MUID decimal(24, 8);
  DECLARE v_max_TraceId decimal(24, 8);
  DECLARE v_avg_TraceId decimal(24, 8);
  DECLARE v_max_MUID decimal(24, 8);
  DECLARE v_avg_MUID decimal(24, 8);
  DECLARE v_max_qty decimal(24, 8);
  DECLARE v_avg_qty decimal(24, 8);
  DECLARE v_qty decimal(24, 8);
  DECLARE v_max_qty_cbm decimal(24, 8);
  DECLARE v_avg_qty_cbm decimal(24, 8);
  DECLARE v_qty_cbm decimal(24, 8);
  DECLARE v_chargeType varchar(255);
  DECLARE v_countDays varchar(255);
  DECLARE v_storageType varchar(255);
  -- Declare for Billing
  DECLARE R_CURRENTDATE timestamp;
  DECLARE R_OPDATE varchar(10);
  DECLARE R_FMDATE varchar(10);
  DECLARE R_TODATE varchar(10);
  DECLARE R_BILLINGDAY int;
  DECLARE R_BILLINGDATE varchar(10);
  DECLARE R_Days int(11);
  DECLARE R_TARGETDATE varchar(10);
  DECLARE R_DAYOFMONTH int(11);
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
  DECLARE R_rate_udf03 varchar(50);
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
  DECLARE R_UDF03 varchar(500);
  DECLARE R_UDF06 varchar(500);
  DECLARE R_UDF07 varchar(500);
  DECLARE R_UDF08 varchar(500);
  DECLARE R_qtyMinimumContract decimal(24, 8);
  DECLARE R_chamberName varchar(500);
  DECLARE R_FINALAMOUNT decimal(24, 6);
  DECLARE R_billsummaryId varchar(30) DEFAULT '';
  DECLARE R_billsummaryNo varchar(30) DEFAULT '';
  DECLARE R_LOCATIONCAT char(2);
  DECLARE R_LOCATIONGROUP varchar(500);
  DECLARE R_INCOMETAX decimal(24, 8);
  DECLARE R_RESULTQTYCHARGE decimal(24, 6);  -- add for calculation
  DECLARE R_CLASSFROM decimal(24, 6);
  DECLARE R_CLASSTO decimal(24, 6);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
  DECLARE R_BILLTO varchar(30);
  DECLARE R_NROW integer;
  DECLARE OUT_returnCode varchar(1000);


  -- Declare the cursor
  DECLARE my_cursor CURSOR FOR
  SELECT
    zib.organizationId,
    zib.warehouseId,
    zib.customerId,
    SUM(zib.qty_TraceId) AS sum_traceId,
    SUM(zib.qty_MUID) AS sum_MUID,
    MAX(zib.qty_TraceId) AS max_TraceId,
    AVG(zib.qty_TraceId) AS avg_TraceId,
    MAX(zib.qty_MUID) AS max_MUID,
    AVG(zib.qty_MUID) AS avg_MUID,
    SUM(zib.qty) AS sum_qty,
    MAX(zib.qty) AS max_qty,
    AVG(zib.qty) AS avg_qty,
    SUM(zib.qty_cbm) AS sum_cbm,
    MAX(zib.qty_cbm) AS max_qty_cbm,
    AVG(zib.qty_cbm) AS avg_qty_cbm,
    zib.udf01,
    SUM(zib.udf02),
    zib.chargeType
  FROM Z_BIL_AKUM_DAYS_STORAGE zib
  WHERE zib.organizationId = IN_organizationId
  AND zib.customerId = IN_CustomerId
  AND zib.StockDate BETWEEN DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL -1 MONTH), '%Y-%m-%d') AND DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)
  --  AND zib.StockDate >= '2025-05-26'
  --  AND zib.StockDate <= '2025-06-25'
  AND zib.warehouseId = IN_warehouseId
  AND zib.chargeType = 'STRG'
  GROUP BY zib.organizationId,
           zib.warehouseId,
           zib.customerId,
           zib.udf01,
           zib.chargeType
  ORDER BY zib.organizationId, zib.warehouseId, zib.customerId, zib.chargeType;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  -- Open the cursor
  OPEN my_cursor;

-- Loop through the results
read_loop:
  LOOP
    -- Fetch the values into variables
    FETCH my_cursor INTO v_organizationId, v_warehouseId, v_customerId, v_qty_TraceId, v_qty_MUID, v_max_TraceId, v_avg_TraceId, v_max_MUID, v_avg_MUID, v_qty, v_max_qty, v_avg_qty, v_qty_cbm, v_max_qty_cbm, v_avg_qty_cbm, v_storageType, v_countDays, v_chargeType;




    -- Exit the loop if no more rows
    IF done = 1 THEN

      LEAVE read_loop;
    END IF;




    IF NOT EXISTS (SELECT
          1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = v_organizationId
        AND bs.warehouseId = v_warehouseId
        AND bs.customerId = v_customerId
        AND bs.billingFromDate BETWEEN DATE_FORMAT(DATE_ADD(DATE_ADD(CURRENT_DATE(), INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d') AND DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)
        --        AND bs.billingFromDate>= IN_datefrom
        --        AND bs.billingFromDate<= IN_dateto
        -- DATE(DATE_ADD(CURDATE(), INTERVAL -1 MONTH))
        -- AND DATE(bs.billingFromDate) = v_stockDate
        -- AND bs.descr = v_workingArea
        AND bs.chargeCategory = 'IV'
        AND bs.chargeType = 'ST'
        AND bs.notes = v_storageType
        AND bs.arNo IN ('*')) THEN


    BLOCK2:
      BEGIN
        DECLARE cur_Tariff CURSOR FOR
        SELECT DISTINCT
          bcm.organizationId,
          bcm.warehouseId,
          bcm.CUSTOMERID,
          DATE_FORMAT(DATE(DATE_ADD(bth.billingdate, INTERVAL -1 DAY)), '%d') AS billingDate,
          btr.tariffId,
          btr.tariffLineNo,
          btr.tariffClassNo,
          btd.chargeCategory,
          btd.chargeType,
          btd.descrC,
          btd.docType,
          btd.udf05, -- sementara pengganti ratebase
          btr.ratePerUnit,
          btr.rate,
          btd.minAmount,
          btd.maxAmount,
          -- if (btr.udf02 = '',0,btr,udf02) as minQty,-- minimum billing
          btr.udf03,-- chamber name
          IF(btr.UDF02 = '', 0, btr.UDF02) AS minQty,
          btd.UDF01 AS MaterialNo,
          btd.udf02 AS itemChargeCategory,
          btd.udf04 AS billMode,
          btd.locationCategory,
          btd.UDF05,
          btd.UDF06,
          btd.UDF07,
          btd.UDF08,
          IFNULL(btd.incomeTaxRate, 0) IncomeTaxRate,
          CASE WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1 ELSE IFNULL(btr.classfrom, 0) END,
          IFNULL(btr.classTo, 0),
          bth.contractNo,
          bth.tariffMasterId,
          btr.cost,
          IF(btr.udf03 = '', 0, btr.udf03) AS storageType,
          btd.billingParty,
          -- btd.billingTranCategory,
          IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
        FROM BAS_CUSTOMER_MULTIWAREHOUSE bcm
          INNER JOIN BAS_CUSTOMER bc
            ON bc.customerId = bcm.customerId
            AND bc.organizationId = bcm.organizationId
            AND bc.CustomerType = 'OW'
          INNER JOIN BIL_TARIFF_HEADER bth
            ON bth.organizationId = bcm.organizationId
            AND bth.tariffMasterId = bcm.tariffMasterId
          INNER JOIN BIL_TARIFF_DETAILS btd
            ON btd.organizationId = bth.organizationId
            AND btd.tariffId = bth.tariffId
          INNER JOIN BIL_TARIFF_RATE btr
            ON btr.organizationId = btd.organizationId
            AND btr.tariffId = btd.tariffId
            AND btr.tariffLineNo = btd.tariffLineNo
          LEFT JOIN BSM_CODE_ML bm
            ON bm.organizationId = btd.organizationId
            AND bm.codeId = btd.udf04
            AND bm.codeType = 'SP_TRACEID'
            AND bm.languageId = 'en'

        WHERE bcm.organizationId = v_organizationId
        AND bcm.warehouseId = v_warehouseId
        AND bcm.customerId = v_customerId
        AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND btd.chargeCategory = 'IV'
        AND btd.chargeType = 'ST'
        AND btr.rate > 0
        AND CASE WHEN bcm.customerId IN ('ECMAMA', 'ECMAMAB2C', 'MAPCLUB', 'CERESSMG', 'NLDC', 'NLDCSBY', 'CERESSBY', 'PT.ITT_MDN', 'PPG', 'DNN_MDN', 'MAP') THEN (btr.udf03 = v_storageType) ELSE (btr.udf03 = '') END
        #AND IFNULL(DAY(bth.billingdate),0)!=0 
        ORDER BY bcm.organizationId, bcm.warehouseId, bcm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo, btr.rate, btr.udf03;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;

        SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd


        #
        OPEN cur_Tariff;
      getTariff:
        LOOP
          FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
          R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount,/*R_qtyMinimumContract,*/ R_chamberName, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
          R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_rate_udf03, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;

          /*SELECT
                    'look->',
                    tariff_done,
                    R_RESULTQTYCHARGE,
                      v_qty_TraceId,
                      v_qty_MUID,
                      v_max_TraceId,
                      v_avg_TraceId,
                      v_max_MUID,
                      v_avg_MUID,
          			v_qty,
                      v_max_qty,
                      v_avg_qty,
                      v_chargeType,
                      R_minAmount,
                      R_rate,
                      R_ratePerUnit;*/
          --  SELECT 'DEBUG->',R_CUSTOMERID,v_warehouseId,v_customerId;


          IF tariff_done = 1 THEN
            SET tariff_done = 0;
            LEAVE getTariff;
          END IF;

          -- SELECT R_CUSTOMERID,R_WAREHOUSEID;
          -- SELECT tariff_done;


          IF (LTRIM(RTRIM(R_WAREHOUSEID)) = LTRIM(RTRIM(v_warehouseId)))
            AND (LTRIM(RTRIM(R_CUSTOMERID)) = LTRIM(RTRIM(v_customerId))) THEN

            -- CALCULATION
            -- UOM
            -- PALLET
            -- CUBIC
            -- M2
            -- CASE
            -- IP
            -- PIECES
            -- KG
            -- LITER
            -- DO
            -- HOUR
            -- MONTH


            --           SELECT  'check=>',R_ratebase,R_TARIFFID;
            SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
            SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
            SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
            SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
            SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
            SET R_billsummaryId = '';

            /*IF (R_billMode = 'CUBIC') THEN
             IF(v_max_TraceId > sum(R_minAmount/(R_rate/R_ratePerUnit)) THEN
                SET R_RESULTQTYCHARGE = v_max_TraceId;
              ELSE
                SET R_RESULTQTYCHARGE = R_minAmount;
              END IF;*/


            IF (R_billMode = 'MAXTRACE') THEN
              IF v_customerId IN ('LTL')
                AND v_warehouseId IN ('CBT01') THEN
                IF (v_max_TraceId > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = (v_max_TraceId - R_minQty);
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              ELSEIF v_customerId IN ('PPG')
                AND R_rate_udf03 = 'NON WH-C' THEN
                IF (v_max_TraceId > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = v_max_TraceId;
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              ELSEIF v_customerId IN ('DNN_MDN')
                AND v_warehouseId IN ('KIMSTR')
                AND R_TARIFFMASTERID = 'BIL00085' THEN
                IF ((v_max_TraceId * 1.44) > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = (v_max_TraceId * 1.44);
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              ELSEIF v_customerId NOT IN ('LTL', 'PPG', 'DNN_MDN') THEN
                IF (v_max_TraceId > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = v_max_TraceId;
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              END IF;
            ELSEIF (R_billMode = 'MAXPL') THEN
              IF v_customerId IN ('NIA_SBY', 'SKU_SBY')
                AND v_warehouseId IN ('SBYKK') THEN
                IF (v_max_MUID > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = (v_max_MUID * v_countDays);
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              ELSEIF v_customerId IN ('API')
                AND v_warehouseId IN ('CBT02') THEN
                IF ((((v_max_MUID * 1.44) / 2) + ((((v_max_MUID * 1.44) / 2) / 6.5) * 3.5)) > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = (((v_max_MUID * 1.44) / 2) + ((((v_max_MUID * 1.44) / 2) / 6.5) * 3.5));
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              ELSEIF v_customerId NOT IN ('NIA_SBY', 'SKU_SBY', 'API') THEN
                IF (v_max_MUID > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = v_max_MUID;
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              END IF;
            /*            ELSEIF (R_billMode = 'MAXPL') and v_customerId in ('NIA_SBY','SKU_SBY') THEN
                          IF (v_max_MUID > R_minQty) then
                            SET R_RESULTQTYCHARGE = (v_max_MUID * v_countDays);
                          ELSE
                            SET R_RESULTQTYCHARGE = (R_minQty * v_countDays);
                          END IF;           
             */
            ELSEIF (R_billMode = 'MAXQTY') THEN
              IF v_customerId IN ('PT.ITT_MDN')
                AND v_warehouseid = 'KIMSTR'
                AND v_storageType = 'REGULER' THEN
                IF ((v_max_qty / 1000) > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = (v_max_qty / 1000);
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              ELSEIF v_customerId IN ('PT.ITT_MDN')
                AND v_warehouseid = 'KIMSTR'
                AND v_storageType = 'EXCESS' THEN
                IF ((v_max_qty / 1000) > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = 1;
                ELSE
                  SET R_RESULTQTYCHARGE = 1;
                END IF;
              ELSEIF v_customerId NOT IN ('PT.ITT_MDN') THEN
                IF (v_max_qty > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = v_max_qty;
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              END IF;
            /*             ELSEIF (R_billMode = 'MAXQTY') and v_customerId in ('PT.ITT_MDN')  and v_storageType = 'EXCESS' THEN
                          IF ((v_max_qty/1000) > R_minQty) then
                            SET R_RESULTQTYCHARGE = 1;
                          ELSE
                            SET R_RESULTQTYCHARGE = 1;
                          END IF;           
                         ELSEIF (R_billMode = 'MAXQTY') and v_customerId in ('PT.ITT_MDN')  and v_storageType = 'REGULER' THEN
                          IF ((v_max_qty/1000) > R_minQty) then
                            SET R_RESULTQTYCHARGE = (v_max_qty/1000);
                          ELSE
                            SET R_RESULTQTYCHARGE = R_minQty;
                          END IF;           
            */
            ELSEIF (R_billMode = 'AVGTRACE') THEN
              IF v_customerId IN ('PPG')
                AND R_rate_udf03 IN ('WH-C') THEN
                IF (v_avg_TraceId > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = v_avg_TraceId;
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              ELSEIF v_customerId NOT IN ('PPG')
                AND R_rate_udf03 NOT IN ('WH-C') THEN
                IF (v_avg_TraceId > R_minQty) THEN
                  SET R_RESULTQTYCHARGE = v_avg_TraceId;
                ELSE
                  SET R_RESULTQTYCHARGE = R_minQty;
                END IF;
              END IF;
            ELSEIF (R_billMode = 'AVGLOC') THEN
              IF (v_avg_TraceId > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_avg_TraceId;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            ELSEIF (R_billMode = 'AVGPL') THEN
              IF (v_avg_MUID > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_avg_MUID;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            ELSEIF (R_billMode = 'AVGQTY') THEN
              IF (v_avg_qty > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_avg_qty;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            ELSEIF (R_billMode = 'MONTHTRACE') THEN
              IF (v_qty_TraceId > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_qty_TraceId;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            ELSEIF (R_billMode = 'MONTHLOC') THEN
              IF (v_qty_MUID > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_qty_MUID;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            ELSEIF (R_billMode = 'MONTHPL') THEN
              IF (v_qty_MUID > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_qty_MUID;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            ELSEIF (R_billMode = 'MONTHQTY') THEN
              IF (v_qty > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_qty;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            ELSEIF (R_billMode = 'MAXCBM') THEN
              IF (v_max_qty_cbm > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_max_qty_cbm;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            ELSEIF (R_billMode = 'INTRACE') THEN
              IF (v_qty_TraceId > R_minQty) THEN
                SET R_RESULTQTYCHARGE = v_qty_TraceId;
              ELSE
                SET R_RESULTQTYCHARGE = R_minQty;
              END IF;
            END IF;
            SELECT
              'TRAP',
              R_rate,
              R_billMode,
              R_rate_udf03,
              v_storageType,
              R_minAmount,
              R_rate,
              R_ratePerUnit,
              R_RESULTQTYCHARGE;

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
                AND chargeRate = R_rate
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
                AND chargeRate = R_rate
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
                AND chargeRate = R_rate
                AND arNo IN ('*');
            END IF; -- EXIST BILLING SUMMARY

            #
            IF (R_billsummaryId = '') THEN
              SET @linenumber = 0;
              SET OUT_returnCode = '';
              CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);

              IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
                SET OUT_returnCode = '999#????????';
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
                v_organizationId,
                v_warehouseId,
                CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')),
                R_BILLINGDATE,
                R_BILLINGDATE,
                v_customerId,
                '',
                '',
                '',
                R_TARIFFID,
                R_CHARGECATEGORY,
                R_chargetype,
                R_descrC,
                -- '',
                R_rateBase,
                R_rateperunit,
                R_RESULTQTYCHARGE,
                '',
                0,
                0,
                R_rate,
                (R_RESULTQTYCHARGE * R_rate) / R_rateperunit,
                (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)),
                0,
                R_cost * R_RESULTQTYCHARGE,
                0,
                NOW() confirmTime,
                '' confirmWho,
                '',
                '',
                '' createTransactionid,
                R_rate_udf03 AS notes,
                NOW() ediSendTime,
                v_customerId AS billTo,
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
                R_RESULTQTYCHARGE * R_rate / R_rateperunit incomeWithoutTax,
                0 cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                R_materialNo AS udf01,
                R_itemChargeCategory AS udf02,
                0 udf03,
                R_UDF06 udf04,
                '' udf05,
                0 currentVersion,
                '2020' oprSeqFlag,
                'CUSTOMBILL' addWho,
                NOW() ADDTIME,
                'CUSTOMBILL' editWho,
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
                '' orderType,
                '' containerType,
                '' containerSize;

          END IF; -- END IF docType

        END LOOP getTariff;
        CLOSE cur_Tariff;

      END;
    ELSE
      ITERATE read_loop;
    END IF;

  END LOOP;

  -- Close the cursor
  CLOSE my_cursor;

END
$$

--
-- Create procedure `CML_BILLSTORAGE_MONTH_CBM`
--
CREATE
DEFINER = 'sa'@'%'
PROCEDURE CML_BILLSTORAGE_MONTH_CBM (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_userId varchar(30),
IN IN_language varchar(30),
IN IN_customerId varchar(30))
BEGIN
  -- Declare variables to hold cursor data
  DECLARE done int DEFAULT 0;
  DECLARE tariff_done int DEFAULT 0;
  DECLARE v_stockDate date;
  DECLARE v_customerId varchar(20);
  DECLARE v_warehouseId varchar(20);
  DECLARE v_skuGroup1 varchar(255);
  DECLARE v_qtyCharge decimal(18, 4);
  DECLARE v_storagetype varchar(100);


  -- Declare for Billing
  DECLARE R_CURRENTDATE timestamp;
  DECLARE R_OPDATE varchar(10);
  DECLARE R_FMDATE varchar(10);
  DECLARE R_TODATE varchar(10);
  DECLARE R_BILLINGDAY integer;
  DECLARE R_BILLINGDATE varchar(10);
  DECLARE R_Days int;
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
  DECLARE R_UDF03 varchar(500);
  DECLARE R_UDF06 varchar(500);
  DECLARE R_UDF07 varchar(500);
  DECLARE R_UDF08 varchar(500);
  DECLARE R_qtyMinimumContract decimal(24, 8);
  DECLARE R_customInformation varchar(500);
  DECLARE R_FINALAMOUNT decimal(24, 8);
  DECLARE R_billsummaryId varchar(30) DEFAULT '';
  DECLARE R_billsummaryNo varchar(30) DEFAULT '';
  DECLARE R_LOCATIONCAT char(2);
  DECLARE R_LOCATIONGROUP varchar(500);
  DECLARE R_INCOMETAX decimal(24, 8);
  DECLARE R_RESULTQTYCHARGE decimal(24, 8);  -- add for calculation
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
  DECLARE R_BILLTO varchar(30);
  DECLARE R_NROW integer;
  DECLARE OUT_returnCode varchar(1000);


  -- Declare the cursor
  DECLARE my_cursor CURSOR FOR

  SELECT
    zbads.warehouseId,
    zbads.customerId,
    MAX(zbads.qty_cbm) AS qty_charge,
    zbads.UDF01 AS storage_type,
    DATE(DATE_ADD(NOW(), INTERVAL -1 DAY)) AS stockdate   -- stock date generate must H-1 26 end of month
  FROM Z_BIL_AKUM_DAYS_STORAGE zbads
  WHERE zbads.organizationId = IN_organizationId
  AND zbads.chargeType = 'STRG'
  AND zbads.customerId = IN_CustomerId
  AND DATE(zbads.StockDate) >= '2025-04-26'
  AND DATE(zbads.StockDate) <= '2025-05-18'
  GROUP BY zbads.warehouseId,
           zbads.customerId,
           zbads.UDF01;

  -- Declare a handler for NOT FOUND condition
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  -- Open the cursor
  OPEN my_cursor;

-- Loop through the results
read_loop:
  LOOP
    -- Fetch the values into variables
    FETCH my_cursor INTO v_warehouseId, v_customerId, v_qtyCharge, v_storagetype, v_stockDate;

    SELECT
      v_warehouseId,
      v_customerId,
      v_qtyCharge,
      v_storagetype,
      v_stockDate;

    IF done = 1 THEN
      LEAVE read_loop;
    END IF;

    IF NOT EXISTS (SELECT
          1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = IN_organizationId
        AND bs.warehouseId = v_warehouseId
        AND bs.customerId = v_customerId
        -- AND DATE(bs.billingFromDate) = DATE(DATE_ADD(CURDATE(), INTERVAL -1 DAY))
        AND DATE(bs.billingFromDate) = DATE(NOW())
        AND bs.descr = v_storagetype
        AND bs.chargeCategory = 'IV') THEN



    BLOCK2:
      BEGIN
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
          btd.udf05, -- sementara pengganti ratebase
          btr.ratePerUnit,
          btr.rate,
          btd.minAmount,
          btd.maxAmount,
          btr.udf02,-- minimum billing
          btr.udf03,-- chamber name  / storage type
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
          btd.billingParty,
          -- btd.billingTranCategory,
          IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
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
        AND bsm.warehouseId = v_warehouseId
        AND bsm.customerId = v_customerId
        AND btr.udf03 = v_storagetype -- for filter chamber name /custom information
        -- AND bth.tariffMasterId = od_tariffMasterId
        AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND btd.chargeCategory = 'IV'
        AND btr.rate > 0
        #AND IFNULL(DAY(bth.billingdate),0)!=0 
        ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;


        SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd

        #
        OPEN cur_Tariff;
      getTariff:
        LOOP
          FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
          R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_qtyMinimumContract, R_customInformation, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
          R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;


          IF tariff_done = 1 THEN
            SET tariff_done = 0;
            LEAVE getTariff;
          END IF;



          SELECT
            R_WAREHOUSEID,
            v_warehouseId,
            R_CUSTOMERID,
            v_customerId,
            R_customInformation,
            v_storagetype;

          IF (LTRIM(RTRIM(R_WAREHOUSEID)) = LTRIM(RTRIM(v_warehouseId)))
            AND (LTRIM(RTRIM(R_CUSTOMERID)) = LTRIM(RTRIM(v_customerId)))
            AND (LTRIM(RTRIM(R_customInformation)) = LTRIM(RTRIM(v_storagetype))) THEN



            --           SELECT  'check=>',R_ratebase,R_TARIFFID;
            SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
            SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
            SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
            SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
            SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
            SET R_billsummaryId = '';



            IF (v_qtyCharge > R_qtyMinimumContract) THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSE
              SET R_RESULTQTYCHARGE = R_qtyMinimumContract;
            END IF;






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
            #
            IF (R_billsummaryId = '') THEN
              SET @linenumber = 0;
              SET OUT_returnCode = '';
              CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);

              IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
                SET OUT_returnCode = '999#????????';
                LEAVE getTariff;
              END IF;
            END IF;
            #
            SELECT
              R_RESULTQTYCHARGE * R_rate,
              v_storagetype;


          --             INSERT INTO BIL_SUMMARY (organizationId, warehouseId, billingSummaryId, billingFromDate, billingToDate, customerId
          --             , sku, lotNum, traceId, tariffId, chargeCategory, chargeType, descr, rateBase, chargePerUnits
          --             , qty, uom, cubic, weight, chargeRate, amount, billingAmount, cost, amountPayable, amountPaid
          --             , confirmTime, confirmWho, docType, docNo, createTransactionid, notes, ediSendTime
          --             , billTo, settleTime, settleWho, followUp, invoiceType, paidTo, costConfirmFlag
          --             , costConfirmTime, costConfirmWho, costSettleFlag, costSettleTime, costSettleWho, incomeTaxRate
          --             , costTaxRate, incomeTax, cosTax, incomeWithoutTax, cosWithoutTax, costInvoiceType, noteText
          --             , udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag, addWho, ADDTIME, editWho, editTime, locationCategory
          --             , manual, docLineNo, arNo, arLineNo, apNo, apLineNo, ediSendFlag, ediErrorCode, ediErrorMessage, ediSendTime2, ediSendFlag2
          --             , ediErrorCode2, ediErrorMessage2, billingTranCategory, orderType, containerType, containerSize)
          --               SELECT
          --                 IN_organizationId,
          --                 v_warehouseId,
          --                 CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')),
          --                 DATE_FORMAT(v_stockDate, '%Y-%m-%d'),
          --                 DATE_FORMAT(v_stockDate, '%Y-%m-%d'),
          --                 v_customerId,
          --                 '',
          --                 '',
          --                 '',
          --                 R_TARIFFID,
          --                 R_CHARGECATEGORY,
          --                 R_chargetype,
          --                 -- R_descrC,
          --                 CONCAT(v_storagetype),
          --                 R_rateBase,
          --                 R_rateperunit,
          --                 R_RESULTQTYCHARGE,
          --                 '',
          --                 0,
          --                 0,
          --                 R_rate,
          --                 R_RESULTQTYCHARGE * R_rate / R_rateperunit,
          --                 (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
          --                 0,
          --                 R_cost * R_RESULTQTYCHARGE,
          --                 0,
          --                 NOW() confirmTime,
          --                 '' confirmWho,
          --                 '',
          --                 '',
          --                 '' createTransactionid,
          --                 '' notes,
          --                 NOW() ediSendTime,
          --                 v_customerId AS billTo,
          --                 NOW() settleTime,
          --                 '' settleWho,
          --                 '' followUp,
          --                 '' invoiceType,
          --                 '' paidTo,
          --                 '' costConfirmFlag,
          --                 NOW() costConfirmTime,
          --                 '' costConfirmWho,
          --                 '' costSettleFlag,
          --                 NOW() costSettleTime,
          --                 '' costSettleWho,
          --                 0 incomeTaxRate,
          --                 0 costTaxRate,
          --                 R_INCOMETAX incomeTax,
          --                 0 cosTax,
          --                 R_RESULTQTYCHARGE * R_rate / R_rateperunit incomeWithoutTax,
          --                 0 cosWithoutTax,
          --                 '' costInvoiceType,
          --                 '' noteText,
          --                 R_materialNo AS udf01,
          --                 R_itemChargeCategory AS udf02,
          --                 0 udf03,
          --                 R_UDF06 udf04,
          --                 '' udf05,
          --                 0 currentVersion,
          --                 '2020' oprSeqFlag,
          --                 IN_USERID addWho,
          --                 NOW() ADDTIME,
          --                 IN_USERID editWho,
          --                 NOW() editTime,
          --                 R_LOCATIONCAT locationCategory,
          --                 '' manual,
          --                 0 lineCount,
          --                 '*' arNo,
          --                 0 arLineNo,
          --                 '*' apNo,
          --                 0 apLineNo,
          --                 'N' ediSendFlag,
          --                 '' ediErrorCode,
          --                 '' ediErrorMessage,
          --                 NOW() ediSendTime2,
          --                 'N' ediSendFlag2,
          --                 '' ediErrorCode2,
          --                 '' ediErrorMessage2,
          --                 '' billingTranCategory,
          --                 '' orderType,
          --                 '' containerType,
          --                 '' containerSize;
          -- 
          END IF; -- END IF docType

        END LOOP getTariff;
        CLOSE cur_Tariff;



      END;
    ELSE
      ITERATE read_loop;
    END IF;



  END LOOP;

  -- Close the cursor
  CLOSE my_cursor;

END
$$

--
-- Create procedure `CML_BILLSTORAGE_DAILY_PER_SKUGROUP`
--
CREATE
DEFINER = 'sa'@'%'
PROCEDURE CML_BILLSTORAGE_DAILY_PER_SKUGROUP (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_trans_no varchar(30),
IN IN_tariffMaster varchar(30))
BEGIN
  -- Declare variables to hold cursor data
  DECLARE done int DEFAULT FALSE;
  DECLARE tariff_done int DEFAULT FALSE;
  DECLARE v_stockDate date;
  DECLARE v_customerId varchar(20);
  DECLARE v_warehouseId varchar(20);
  DECLARE v_skuGroup1 varchar(255);
  DECLARE v_qtyCharge decimal(18, 4);

  -- Declare for Billing
  DECLARE R_CURRENTDATE timestamp;
  DECLARE R_OPDATE varchar(10);
  DECLARE R_FMDATE varchar(10);
  DECLARE R_TODATE varchar(10);
  DECLARE R_BILLINGDAY integer;
  DECLARE R_BILLINGDATE varchar(10);
  DECLARE R_Days int;
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
  DECLARE R_UDF07 varchar(500);
  DECLARE R_UDF08 varchar(500);
  DECLARE R_FINALAMOUNT decimal(24, 8);
  DECLARE R_billsummaryId varchar(30) DEFAULT '';
  DECLARE R_billsummaryNo varchar(30) DEFAULT '';
  DECLARE R_LOCATIONCAT char(2);
  DECLARE R_LOCATIONGROUP varchar(500);
  DECLARE R_INCOMETAX decimal(24, 8);
  DECLARE R_RESULTQTYCHARGE decimal(24, 8);  -- add for calculation
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
  DECLARE R_BILLTO varchar(30);
  DECLARE R_NROW integer;
  DECLARE OUT_returnCode varchar(1000);


  -- Declare the cursor
  DECLARE my_cursor CURSOR FOR
  SELECT
    DATE_FORMAT(zib.StockDate, '%Y-%m-%d') AS stockDate,
    zib.customerId,
    zib.warehouseId AS warehouseId,
    s.sku_group1 AS skugroup1,
    SUM(CASE WHEN zib.customerId = 'MDS' THEN (CASE WHEN pd2.uomdescr = 'KG' THEN zib.qtyonHand ELSE zib.qtyonHand * s.sku_group6 END) ELSE zib.qtyonHand END) AS qtyCharge
  FROM Z_InventoryBalance zib
    LEFT JOIN INV_LOT_ATT la
      ON la.organizationId = zib.organizationId
      AND la.customerId = zib.customerId
      AND la.sku = zib.sku
      AND la.lotNum = zib.lotNum
    LEFT OUTER JOIN (SELECT
        *
      FROM BSM_CODE_ML
      WHERE codetype = 'OWNER_LTL'
      AND languageid = 'en') la1
      ON la.organizationId = la1.organizationId
      AND la.lotatt11 = la1.codeid
    LEFT JOIN BAS_LOCATION l
      ON l.organizationId = zib.organizationId
      AND l.locationId = zib.locationId
      AND l.warehouseId = zib.warehouseId
    LEFT JOIN BAS_SKU s
      ON s.organizationId = zib.organizationId
      AND s.customerId = zib.customerId
      AND s.sku = zib.sku
    LEFT JOIN BAS_SKU_MULTIWAREHOUSE sm
      ON sm.organizationId = zib.organizationId
      AND sm.customerId = zib.customerId
      AND sm.sku = zib.sku
      AND sm.warehouseId = zib.warehouseId
    LEFT JOIN BAS_PACKAGE_DETAILS pd
      ON sm.organizationId = pd.organizationId
      AND sm.customerId = pd.customerId
      AND sm.packId = pd.packId
      AND pd.packUom = 'PL'
    LEFT JOIN BAS_PACKAGE_DETAILS pd1
      ON sm.organizationId = pd1.organizationId
      AND sm.customerId = pd1.customerId
      AND sm.packId = pd1.packId
      AND pd1.packUom = 'CS'
    LEFT JOIN BAS_PACKAGE_DETAILS pd2
      ON sm.organizationId = pd2.organizationId
      AND sm.customerId = pd2.customerId
      AND sm.packId = pd2.packId
      AND pd2.packUom = 'EA'
    LEFT JOIN BSM_CODE_ML lc
      ON lc.organizationId = zib.organizationId
      AND zib.locationCategory = lc.codeid
      AND lc.codeType = 'LOC_CAT'
      AND lc.languageId = 'en'
    LEFT JOIN BSM_CODE_ML lc1
      ON lc1.organizationId = la.organizationId
      AND la.lotAtt07 = lc1.codeid
      AND lc1.codeType = 'PLT_TYP'
      AND lc1.languageId = 'en'
    LEFT JOIN BSM_CODE_ML lc2
      ON lc2.organizationId = la.organizationId
      AND la.lotAtt08 = lc2.codeid
      AND lc2.codeType = 'DMG_FLG'
      AND lc2.languageId = 'en'
  WHERE zib.organizationId = IN_organizationId
  AND zib.warehouseId = IN_warehouseId
  AND zib.customerId = IN_CustomerId
  -- AND DATE(zib.StockDate) = DATE(DATE_ADD(NOW(), INTERVAL -1 DAY))
  AND DATE(zib.StockDate) > '2025-01-20'
  AND DATE(zib.StockDate) < '2025-01-22'
  AND qtyonHand > 0
  AND zib.locationId NOT IN ('CONSWOR', 'LOST_CBT01', 'STG01', 'STG02', 'STG03', 'STG04', 'STG05', 'STG11', 'STG12', 'STG13', 'STG14', 'STG15', 'STG06', 'STG07', 'STG08', 'STG09', 'STG10', 'STG16', 'STG17', 'STG18', 'STG19', 'STG20',/* 'SORTATIONCBT01', */ 'CROSSDOCK_01', 'CROSSDOCK_02', 'SORTATIONLADC01', 'SORTATIONBASF01', 'SORTATIONCBT02', 'SORTATIONCBT03', 'SORTATION', 'SORTATIONMRD02', 'SORTATIONSMG-SO', 'SORTATION1', 'CYCLE-01S', 'LOST_CBT01', 'STO-01', 'STO-02', 'STO-03', 'STO-04', 'STO-05', 'WHAQC', 'WHCQC', 'WHCQC01', 'WHCQC03', 'WHCQC05', 'WHCQC09', 'WHCQC11', 'WHCQC13', 'WHCQC15', 'WHCQC17', 'WHCQC19', 'WHCQC21', 'WHCQC23', 'WHCQC25', 'WHCQC27', 'WHCQC29', 'WHCQC31', 'WHCQC33', 'WHCQC35', 'WHIQC', 'WORK_AREA', 'B04A065', 'B04A066', 'B04B065', 'B04B065')
  AND zib.sku NOT IN (SELECT
      sku
    FROM BAS_SKU bs2
    WHERE organizationId = zib.organizationId
    AND customerId = 'LTL'
    AND sku LIKE '13%'
    UNION ALL
    SELECT
      sku
    FROM BAS_SKU bs2
    WHERE organizationid = zib.organizationId
    AND customerid = 'SMARTSBY'
    AND sku = 'PALLET'
    UNION ALL
    SELECT
      sku
    FROM BAS_SKU
    WHERE organizationid = zib.organizationId
    AND customerid IN ('ECMAMA', 'ECMAMAB2C')
    AND sku LIKE '%TEST%'
    UNION ALL
    SELECT
      sku
    FROM BAS_SKU
    WHERE organizationid = zib.organizationId
    AND customerid IN ('MAP')
    AND sku IN ('DEMO TABLE AT', 'DEMO TABLE SAM', 'HOT STAMP'))
  GROUP BY zib.warehouseId,
           s.sku_group1,
           zib.StockDate,
           zib.customerId
  ORDER BY zib.customerId;

  -- Declare a handler for NOT FOUND condition
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  -- Open the cursor
  OPEN my_cursor;

-- Loop through the results
read_loop:
  LOOP
    -- Fetch the values into variables
    FETCH my_cursor INTO v_stockDate, v_customerId, v_warehouseId, v_skuGroup1, v_qtyCharge;

    -- Exit the loop if no more rows
    IF done THEN
      LEAVE read_loop;
    END IF;

    IF NOT EXISTS (SELECT
          1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = IN_organizationId
        AND bs.warehouseId = IN_warehouseId
        AND DATE(bs.billingFromDate) = DATE(DATE_ADD(CURDATE(), INTERVAL -1 DAY))
        AND bs.descr = v_skuGroup1
        AND bs.chargeCategory = 'IV') THEN

    BLOCK2:
      BEGIN



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
          btd.udf05, -- sementara pengganti ratebase
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
          btd.billingParty,
          -- btd.billingTranCategory,
          IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
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
        -- AND bth.tariffMasterId = od_tariffMasterId
        AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND btd.chargeCategory = 'IV'
        AND btd.udf08 = v_skuGroup1
        AND btr.rate > 0
        #AND IFNULL(DAY(bth.billingdate),0)!=0 
        ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;

        SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd
        #
        OPEN cur_Tariff;
      getTariff:
        LOOP
          FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
          R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
          R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;
          IF tariff_done THEN
            SET tariff_done = FALSE;
            LEAVE getTariff;
          END IF;





          IF (LTRIM(RTRIM(R_UDF08)) = LTRIM(RTRIM(v_skuGroup1))) THEN
            -- CALCULATION
            -- UOM
            -- PALLET
            -- CUBIC
            -- M2
            -- CASE
            -- IP
            -- PIECES
            -- KG
            -- LITER
            -- DO
            -- HOUR
            -- MONTH


            --           SELECT  'check=>',R_ratebase,R_TARIFFID;
            SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
            SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
            SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
            SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
            SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
            SET R_billsummaryId = '';


            IF (R_ratebase = 'CUBIC') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'M2') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'IP') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'KG') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'LITER') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'DO') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'PALLET') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'CASE') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'QUANTITY') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'NETWEIGHT') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'GW') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            /*additional nettweight grossweight*/
            ELSEIF (R_ratebase = 'MT') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            END IF;



            --           SELECT 'check 2=>',R_RESULTQTYCHARGE;

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
            #
            IF (R_billsummaryId = '') THEN
              SET @linenumber = 0;
              SET OUT_returnCode = '';
              CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);

              IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
                SET OUT_returnCode = '999#????????';
                LEAVE getTariff;
              END IF;
            END IF;
            #
            SELECT
              R_billsummaryId;

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
                IN_organizationId,
                IN_warehouseId,
                CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')),
                DATE_FORMAT(v_stockDate, '%Y-%m-%d'),
                DATE_FORMAT(v_stockDate, '%Y-%m-%d'),
                v_customerId,
                '',
                '',
                '',
                R_TARIFFID,
                R_CHARGECATEGORY,
                R_chargetype,
                -- R_descrC,
                v_skuGroup1,
                R_rateBase,
                R_rateperunit,
                v_qtyCharge,
                '',
                0,
                0,
                R_rate,
                R_RESULTQTYCHARGE * R_rate / R_rateperunit,
                (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
                0,
                R_cost * R_RESULTQTYCHARGE,
                0,
                NOW() confirmTime,
                '' confirmWho,
                '',
                '',
                '' createTransactionid,
                '' notes,
                NOW() ediSendTime,
                v_customerId AS billTo,
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
                R_RESULTQTYCHARGE * R_rate / R_rateperunit incomeWithoutTax,
                0 cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                R_materialNo AS udf01,
                R_itemChargeCategory AS udf02,
                0 udf03,
                R_UDF06 udf04,
                '' udf05,
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
                '' orderType,
                '' containerType,
                '' containerSize;

          END IF; -- END IF docType

        END LOOP getTariff;
        CLOSE cur_Tariff;






      END;

    END IF;



  END LOOP;

  -- Close the cursor
  CLOSE my_cursor;

END
$$

--
-- Create procedure `CML_BILLSTORAGE_DAILY_CBM_DATE`
--
CREATE
DEFINER = 'sa'@'%'
PROCEDURE CML_BILLSTORAGE_DAILY_CBM_DATE (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_trans_no varchar(30),
IN IN_tariffMaster varchar(30),
IN IN_datefrom varchar(30),
IN IN_dateto varchar(30))
BEGIN
  -- Declare variables to hold cursor data
  DECLARE done int DEFAULT 0;
  DECLARE tariff_done int DEFAULT 0;
  DECLARE v_stockDate date;
  DECLARE v_customerId varchar(20);
  DECLARE v_warehouseId varchar(20);
  DECLARE v_skuGroup1 varchar(255);
  DECLARE v_workingArea varchar(255);
  DECLARE v_qtyCharge decimal(18, 4);

  -- Declare for Billing
  DECLARE R_CURRENTDATE timestamp;
  DECLARE R_OPDATE varchar(10);
  DECLARE R_FMDATE varchar(10);
  DECLARE R_TODATE varchar(10);
  DECLARE R_BILLINGDAY integer;
  DECLARE R_BILLINGDATE varchar(10);
  DECLARE R_Days int;
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
  DECLARE R_UDF03 varchar(500);
  DECLARE R_UDF06 varchar(500);
  DECLARE R_UDF07 varchar(500);
  DECLARE R_UDF08 varchar(500);
  DECLARE R_qtyMinimumContract decimal(24, 8);
  DECLARE R_chamberName varchar(500);
  DECLARE R_FINALAMOUNT decimal(24, 8);
  DECLARE R_billsummaryId varchar(30) DEFAULT '';
  DECLARE R_billsummaryNo varchar(30) DEFAULT '';
  DECLARE R_LOCATIONCAT char(2);
  DECLARE R_LOCATIONGROUP varchar(500);
  DECLARE R_INCOMETAX decimal(24, 8);
  DECLARE R_RESULTQTYCHARGE decimal(24, 8);  -- add for calculation
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
  DECLARE R_BILLTO varchar(30);
  DECLARE R_NROW integer;
  DECLARE OUT_returnCode varchar(1000);


  -- Declare the cursor
  DECLARE my_cursor CURSOR FOR
  SELECT
    DATE_FORMAT(ls_storage.stockdate, '%Y-%m-%d') AS stockDate,
    ls_storage.warehouseid,
    ls_storage.customerid,
    ls_storage.workingArea,
    SUM(ls_storage.qtycbm) AS qtycbm
  FROM (SELECT
      DATE_FORMAT(stockDate, '%Y-%m-%d') AS stockdate,
      zib.warehouseId AS warehouseid,
      sm.tariffMasterId AS tariffmasterid,
      CASE WHEN zib.customerId = 'LTL' THEN la1.codeDescr ELSE sm.tariffId END AS tariffid,
      CASE WHEN zib.customerId = 'XXX' THEN 'SAMSONITE' ELSE zib.customerId END AS customerid,
      zib.locationId AS locationid,
      zib.locationCategory AS locationcategory,
      lc.codeDescr AS locationcategorydescr,
      zib.TRACEID AS traceid,
      s.sku_group1 AS muidltl,
      zib.muid AS muid,
      zib.lotNum AS lotnum,
      s.PACKID AS packid,
      CASE WHEN zib.customerId = 'MDS' THEN 'KG' ELSE zib.UOM END AS uom,
      CASE WHEN zib.warehouseId = 'CBT02' THEN 'LINC' WHEN zib.warehouseId = 'CBT03' AND
          /*l.workingArea = 'WHTMLA' THEN 'WHTMLA' WHEN zib.warehouseId = 'CBT03' AND
          l.workingArea = 'WHTMLB' THEN 'WHTMLB' WHEN zib.warehouseId = 'CBT03' AND*/
          l.workingArea = 'WHTMLC' THEN 'WHTMLC+D' WHEN zib.warehouseId = 'CBT03' AND
          l.workingArea = 'WHTMLD' THEN 'WHTMLC+D' WHEN zib.warehouseId = 'CBT03' AND
          l.workingArea = 'WHTMLE' THEN 'WHTMLE+G' WHEN zib.warehouseId = 'CBT03' AND
          l.workingArea = 'WHTMLG' THEN 'WHTMLE+G' WHEN zib.warehouseId = 'JBK01' AND
          l.locationId LIKE 'A%' THEN 'A' WHEN zib.warehouseId = 'JBK01' AND
          l.locationId LIKE 'RCV%' THEN 'A' ELSE l.workingArea END AS workingArea,
      /*before updatel.workingArea = 'WHTMLA' THEN 'WHTMLA' WHEN zib.warehouseId = 'CBT03' AND
      l.workingArea = 'WHTMLB' THEN 'WHTMLB' WHEN zib.warehouseId = 'CBT03' AND
      l.workingArea = 'WHTMLC' THEN 'WHTMLC+D' WHEN zib.warehouseId = 'CBT03' AND
      l.workingArea = 'WHTMLD' THEN 'WHTMLC+D' WHEN zib.warehouseId = 'CBT03' AND
      l.workingArea = 'WHTML3' THEN 'WHTMLE' ELSE l.workingArea END AS workingArea,
       * AB 24/12/30
       */
      zib.SKU AS sku,
      skuDesc AS skudesc,
      la.lotatt09 AS ponum,
      lc1.codeDescr AS typepallet,
      CASE WHEN zib.customerId = 'MDS' THEN (
            CASE WHEN pd2.uomDescr = 'KG' THEN zib.qtyonHand ELSE zib.qtyonHand * s.sku_group6 END
            ) ELSE zib.qtyonHand END AS qtyonhand,
      pd.qty AS qtyperpallet,
      CASE zib.customerId WHEN 'ASP' THEN zib.cube WHEN 'MAP' THEN s.cube WHEN 'ONDULINE' THEN s.cube WHEN 'SST_JKT' THEN s.cube WHEN 'CPI_JKT' THEN s.cube ELSE s.cube / 1000000 END AS cbmsku,
      CASE zib.customerId WHEN 'MAP' THEN (
            CASE WHEN la.lotatt04 = 'SET' THEN 0 ELSE (s.cube * zib.qtyonHand) END
            ) WHEN 'ONDULINE' THEN s.cube * zib.qtyonHand ELSE totalcube END AS qtycbm,
      CASE WHEN LENGTH(zib.locationId) = 7 THEN SUBSTRING(zib.locationId, 1, 1) WHEN LENGTH(zib.locationId) = 8 THEN SUBSTRING(zib.locationId, 1, 1) WHEN SUBSTRING(zib.locationId, 1, 3) = 'TML' AND
          zib.customerId <> 'LTL' THEN SUBSTRING(zib.locationId, 4, 1) WHEN sm.putawayRule = 'LTL09' THEN 'E' WHEN zib.SKU IN ('000000001100012851', '000000001100010211', '000000001100000616', '000000001100013296', '000000001100008797', '000000001100012070', '000000001100012068', '000000001100012478', '000000001100012898', '000000001100014515') THEN 'G' WHEN sm.putawayRule IN ('LTL03', 'GMPA-NONDG', 'ICHIKOH-NONDG', 'ITOCHU-NONDG', 'PMM-NONDG', 'LTL06', 'LTL07') THEN 'G' WHEN sm.putawayRule IN ('LTL08', 'ITOCHU-DG', 'PMM-DG', 'LTL01', 'LTL02', 'SMT') THEN 'B' WHEN sm.putawayRule = 'LTL-BULK' THEN 'D' WHEN sm.putawayRule IN ('BAJ', 'PLB-LTL', 'ADF', 'CCDI', 'CTI') THEN 'A' WHEN sm.putawayRule IN ('GYI', 'DKJ') THEN 'J' WHEN sm.putawayRule = 'LTL04' THEN 'B' WHEN sm.putawayRule IN ('DNN', 'PMM', 'ITOCHU') THEN 'C' ELSE l.udf03 END AS chamber,
      sm.putawayRule AS putawayrule,
      la.lotatt04 AS batchno,
      la.lotatt02 AS expiredate,
      la.lotatt03 AS whdate,
      CASE WHEN zib.customerId = 'ECCOSBY' THEN (
            CASE WHEN SUBSTRING(zib.locationId, 3, 1) = 'I' THEN 'ECCO2' ELSE 'ECCO' END
            ) ELSE SUBSTRING(zib.locationId, 1, 1) END AS area,
      CASE WHEN zib.customerId = 'PLB-LTL' THEN la.lotatt10 ELSE la.lotatt09 END AS externalpo,
      lc2.codeDescr AS whetherdamaged,
      CEILING(qtyonHand / pd.qty) AS palletused,
      CASE WHEN zib.customerId = 'RBFOOD' THEN pd1.qty ELSE s.NETWEIGHT END AS netweight
    FROM Z_InventoryBalance zib
      LEFT JOIN INV_LOT_ATT la
        ON la.organizationId = zib.organizationId
        AND la.customerId = zib.customerId
        AND la.sku = zib.sku
        AND la.lotNum = zib.lotNum
      LEFT OUTER JOIN (SELECT
          *
        FROM BSM_CODE_ML
        WHERE codetype = 'OWNER_LTL'
        AND languageid = 'en') la1
        ON la.organizationId = la1.organizationId
        AND la.lotatt11 = la1.codeid
      LEFT JOIN BAS_LOCATION l
        ON l.organizationId = zib.organizationId
        AND l.locationId = zib.locationId
        AND l.warehouseId = zib.warehouseId
      LEFT JOIN BAS_SKU s
        ON s.organizationId = zib.organizationId
        AND s.customerId = zib.customerId
        AND s.sku = zib.sku
      LEFT JOIN BAS_SKU_MULTIWAREHOUSE sm
        ON sm.organizationId = zib.organizationId
        AND sm.customerId = zib.customerId
        AND sm.sku = zib.sku
        AND sm.warehouseId = zib.warehouseId
      LEFT JOIN BAS_PACKAGE_DETAILS pd
        ON sm.organizationId = pd.organizationId
        AND sm.customerId = pd.customerId
        AND sm.packId = pd.packId
        AND pd.packUom = 'PL'
      LEFT JOIN BAS_PACKAGE_DETAILS pd1
        ON sm.organizationId = pd1.organizationId
        AND sm.customerId = pd1.customerId
        AND sm.packId = pd1.packId
        AND pd1.packUom = 'CS'
      LEFT JOIN BAS_PACKAGE_DETAILS pd2
        ON sm.organizationId = pd2.organizationId
        AND sm.customerId = pd2.customerId
        AND sm.packId = pd2.packId
        AND pd2.packUom = 'EA'
      LEFT JOIN BSM_CODE_ML lc
        ON lc.organizationId = zib.organizationId
        AND zib.locationCategory = lc.codeid
        AND lc.codeType = 'LOC_CAT'
        AND lc.languageId = 'en'
      LEFT JOIN BSM_CODE_ML lc1
        ON lc1.organizationId = la.organizationId
        AND la.lotAtt07 = lc1.codeid
        AND lc1.codeType = 'PLT_TYP'
        AND lc1.languageId = 'en'
      LEFT JOIN BSM_CODE_ML lc2
        ON lc2.organizationId = la.organizationId
        AND la.lotAtt08 = lc2.codeid
        AND lc2.codeType = 'DMG_FLG'
        AND lc2.languageId = 'en'
    WHERE zib.organizationId = IN_organizationId
    AND DATE(zib.StockDate) >= IN_datefrom
    AND DATE(zib.StockDate) <= IN_dateto
    -- AND zib.warehouseId IN ('LADC01')
    AND zib.warehouseId IN ('CBT02', 'CBT03', 'LADC01', 'JBK01')
    -- AND DATE(zib.StockDate) = DATE(DATE_ADD(NOW(), INTERVAL -1 DAY))

    AND zib.customerId = IN_CustomerId
    AND zib.qtyonHand > 0
    AND zib.locationId NOT IN ('CONSWOR', 'LOST_CBT01', 'STG01', 'STG02', 'STG03', 'STG04', 'STG05', 'STG11', 'STG12', 'STG13', 'STG14', 'STG15', 'STG06', 'STG07', 'STG08', 'STG09', 'STG10', 'STG16', 'STG17', 'STG18', 'STG19', 'STG20', 'SORTATIONCBT01', 'CROSSDOCK_01', 'CROSSDOCK_02', 'SORTATIONLADC01', 'SORTATIONBASF01', 'SORTATIONCBT02', 'SORTATIONCBT03', 'SORTATION', 'SORTATIONMRD02', 'SORTATIONSMG-SO', 'SORTATION1', 'CYCLE-01S', 'LOST_CBT01', 'STO-01', 'STO-02', 'STO-03', 'STO-04', 'STO-05', 'WHAQC', 'WHCQC', 'WHCQC01', 'WHCQC03', 'WHCQC05', 'WHCQC09', 'WHCQC11', 'WHCQC13', 'WHCQC15', 'WHCQC17', 'WHCQC19', 'WHCQC21', 'WHCQC23', 'WHCQC25', 'WHCQC27', 'WHCQC29', 'WHCQC31', 'WHCQC33', 'WHCQC35', 'WHIQC', 'WORK_AREA', 'B04A065', 'B04A066', 'B04B065', 'B04B065')
    AND zib.sku NOT IN (SELECT
        sku
      FROM BAS_SKU bs2
      WHERE organizationId = zib.organizationId
      AND customerId = 'LTL'
      AND sku LIKE '13%'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU bs2
      WHERE organizationid = zib.organizationId
      AND customerid = 'SMARTSBY'
      AND sku = 'PALLET'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU
      WHERE organizationid = zib.organizationId
      AND customerid IN ('ECMAMA', 'ECMAMAB2C')
      AND sku LIKE '%TEST%'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU
      WHERE organizationid = zib.organizationId
      AND customerid IN ('MAP')
      AND sku IN ('DEMO TABLE AT', 'DEMO TABLE SAM', 'HOT STAMP'))
    ORDER BY zib.customerId) ls_storage
  GROUP BY ls_storage.warehouseId,
           ls_storage.customerId,
           ls_storage.StockDate,
           ls_storage.workingArea
  ORDER BY ls_storage.customerId, stockDate, ls_storage.workingArea;
  --   UNION ALL
  --   SELECT
  --     DATE(DATE_ADD(NOW(), INTERVAL -1 DAY)) AS stockDate,
  --     bth.warehouseId,
  --     btm.customerId,
  --     btr.udf03 AS workingArea,
  --     0 AS qtycbm
  --   FROM BIL_TARIFF_HEADER bth
  --     INNER JOIN BIL_TARIFF_DETAILS btd
  --       ON bth.organizationId = btd.organizationId
  --       AND bth.warehouseId = btd.warehouseId
  --       AND bth.tariffId = btd.tariffId
  --     INNER JOIN BIL_TARIFF_RATE btr
  --       ON bth.organizationId = btr.organizationId
  --       AND bth.warehouseId = btr.warehouseId
  --       AND bth.tariffId = btr.tariffId
  --       AND btd.tariffLineNo = btr.tariffLineNo
  --     INNER JOIN BIL_TARIFF_MASTER btm
  --       ON bth.organizationId = btm.organizationId
  --       AND bth.tariffMasterId = btm.tariffMasterId
  --   WHERE bth.organizationId = IN_organizationId
  --   AND btd.warehouseId IN ('CBT02', 'CBT03', 'LADC01')
  --   AND btm.Customerid = IN_CustomerId
  --   AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  --   AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  --   AND btd.chargeCategory = 'IV'
  --   AND btr.rate > 0
  --   AND btr.udf03 NOT IN (SELECT DISTINCT
  --       CASE WHEN bl.warehouseId = 'CBT02' THEN 'LINC' ELSE bl.workingArea END AS workingArea
  --     FROM Z_InventoryBalance lc
  --       INNER JOIN BAS_LOCATION bl
  --         ON lc.organizationId = bl.organizationId
  --         AND lc.warehouseId = bl.warehouseId
  --         AND lc.locationId = bl.locationId
  --     WHERE lc.organizationId = IN_organizationId
  --     AND DATE(lc.StockDate) = DATE(DATE_ADD(NOW(), INTERVAL -1 DAY))
  --     AND bl.warehouseId IN ('CBT02', 'CBT03', 'LADC01')
  --     AND lc.customerId = IN_CustomerId
  --     AND lc.qtyavailable > 0)
  --   ORDER BY stockDate ASC;

  -- Declare a handler for NOT FOUND condition
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  -- Open the cursor
  OPEN my_cursor;

-- Loop through the results
read_loop:
  LOOP
    -- Fetch the values into variables
    FETCH my_cursor INTO v_stockDate, v_warehouseId, v_customerId, v_workingArea, v_qtyCharge;


    -- SELECT 'debug =>',v_workingArea;


    -- Exit the loop if no more rows
    IF done = 1 THEN
      LEAVE read_loop;
    END IF;

    IF NOT EXISTS (SELECT
          1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = IN_organizationId
        AND bs.warehouseId = v_warehouseId
        AND bs.customerId = v_customerId
        -- AND DATE(bs.billingFromDate) = DATE(DATE_ADD(CURDATE(), INTERVAL -1 DAY))
        AND DATE(bs.billingFromDate) = v_stockDate
        AND bs.descr = v_workingArea
        AND bs.chargeCategory = 'IV') THEN


    BLOCK2:
      BEGIN
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
          btd.udf05, -- sementara pengganti ratebase
          btr.ratePerUnit,
          btr.rate,
          btd.minAmount,
          btd.maxAmount,
          btr.udf02,-- minimum billing
          btr.udf03,-- chamber name
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
          btd.billingParty,
          -- btd.billingTranCategory,
          IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
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
        AND bsm.warehouseId = v_warehouseId
        AND bsm.customerId = v_customerId
        AND btr.udf03 = v_workingArea -- for filter chamber name
        -- AND bth.tariffMasterId = od_tariffMasterId
        AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND btd.chargeCategory = 'IV'
        AND btr.rate > 0
        AND bth.tariffMasterId NOT IN ('BIL00062PT')
        #AND IFNULL(DAY(bth.billingdate),0)!=0 
        ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;
        SELECT
          'look->',
          tariff_done;
        SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd

        #
        OPEN cur_Tariff;
      getTariff:
        LOOP
          FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
          R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_qtyMinimumContract, R_chamberName, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
          R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;

          --  SELECT 'DEBUG->',R_CUSTOMERID,v_warehouseId,v_customerId;
          IF tariff_done = 1 THEN
            SET tariff_done = 0;
            LEAVE getTariff;
          END IF;

          -- SELECT R_CUSTOMERID,R_WAREHOUSEID;
          -- SELECT tariff_done;



          IF (LTRIM(RTRIM(R_WAREHOUSEID)) = LTRIM(RTRIM(v_warehouseId)))
            AND (LTRIM(RTRIM(R_CUSTOMERID)) = LTRIM(RTRIM(v_customerId)))
            AND (LTRIM(RTRIM(R_chamberName)) = LTRIM(RTRIM(v_workingArea))) THEN
            -- CALCULATION
            -- UOM
            -- PALLET
            -- CUBIC
            -- M2
            -- CASE
            -- IP
            -- PIECES
            -- KG
            -- LITER
            -- DO
            -- HOUR
            -- MONTH


            --           SELECT  'check=>',R_ratebase,R_TARIFFID;
            SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
            SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
            SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
            SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
            SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
            SET R_billsummaryId = '';


            IF (R_ratebase = 'CUBIC') THEN
              IF (v_qtyCharge > R_qtyMinimumContract) THEN
                SET R_RESULTQTYCHARGE = v_qtyCharge;
              ELSE
                SET R_RESULTQTYCHARGE = R_qtyMinimumContract;
              END IF;
            ELSEIF (R_ratebase = 'M2') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'IP') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'KG') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'LITER') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'DO') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'PALLET') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'CASE') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'QUANTITY') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'NETWEIGHT') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'GW') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            /*additional nettweight grossweight*/
            ELSEIF (R_ratebase = 'MT') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            END IF;

            SELECT
              'DEBUG=>',
              v_customerId,
              R_CUSTOMERID,
              R_WAREHOUSEID,
              v_warehouseId,
              R_RESULTQTYCHARGE;

            --           SELECT 'check 2=>',R_RESULTQTYCHARGE;

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
            #
            IF (R_billsummaryId = '') THEN
              SET @linenumber = 0;
              SET OUT_returnCode = '';
              CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);

              IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
                SET OUT_returnCode = '999#????????';
                LEAVE getTariff;
              END IF;
            END IF;
            #
            SELECT
              R_billsummaryId;

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
                IN_organizationId,
                v_warehouseId,
                CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')),
                DATE_FORMAT(v_stockDate, '%Y-%m-%d'),
                DATE_FORMAT(v_stockDate, '%Y-%m-%d'),
                v_customerId,
                '',
                '',
                '',
                R_TARIFFID,
                R_CHARGECATEGORY,
                R_chargetype,
                -- R_descrC,
                CONCAT(v_workingArea),
                R_rateBase,
                R_rateperunit,
                R_RESULTQTYCHARGE,
                '',
                0,
                0,
                R_rate,
                R_RESULTQTYCHARGE * R_rate / R_rateperunit,
                (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
                0,
                R_cost * R_RESULTQTYCHARGE,
                0,
                NOW() confirmTime,
                '' confirmWho,
                '',
                '',
                '' createTransactionid,
                '' notes,
                NOW() ediSendTime,
                v_customerId AS billTo,
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
                R_RESULTQTYCHARGE * R_rate / R_rateperunit incomeWithoutTax,
                0 cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                R_materialNo AS udf01,
                R_itemChargeCategory AS udf02,
                0 udf03,
                R_UDF06 udf04,
                '' udf05,
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
                '' orderType,
                '' containerType,
                '' containerSize;

          END IF; -- END IF docType

        END LOOP getTariff;
        CLOSE cur_Tariff;






      END;
    ELSE
      ITERATE read_loop;
    END IF;



  END LOOP;

  -- Close the cursor
  CLOSE my_cursor;

END
$$

--
-- Create procedure `CML_BILLSTORAGE_DAILY_CBM_BAK`
--
CREATE
DEFINER = 'sa'@'%'
PROCEDURE CML_BILLSTORAGE_DAILY_CBM_BAK (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_trans_no varchar(30),
IN IN_tariffMaster varchar(30))
BEGIN
  -- Declare variables to hold cursor data
  DECLARE done int DEFAULT 0;
  DECLARE tariff_done int DEFAULT 0;
  DECLARE v_stockDate date;
  DECLARE v_customerId varchar(20);
  DECLARE v_warehouseId varchar(20);
  DECLARE v_skuGroup1 varchar(255);
  DECLARE v_workingArea varchar(255);
  DECLARE v_qtyCharge decimal(18, 4);

  -- Declare for Billing
  DECLARE R_CURRENTDATE timestamp;
  DECLARE R_OPDATE varchar(10);
  DECLARE R_FMDATE varchar(10);
  DECLARE R_TODATE varchar(10);
  DECLARE R_BILLINGDAY integer;
  DECLARE R_BILLINGDATE varchar(10);
  DECLARE R_Days int;
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
  DECLARE R_UDF03 varchar(500);
  DECLARE R_UDF06 varchar(500);
  DECLARE R_UDF07 varchar(500);
  DECLARE R_UDF08 varchar(500);
  DECLARE R_qtyMinimumContract decimal(24, 8);
  DECLARE R_chamberName varchar(500);
  DECLARE R_FINALAMOUNT decimal(24, 8);
  DECLARE R_billsummaryId varchar(30) DEFAULT '';
  DECLARE R_billsummaryNo varchar(30) DEFAULT '';
  DECLARE R_LOCATIONCAT char(2);
  DECLARE R_LOCATIONGROUP varchar(500);
  DECLARE R_INCOMETAX decimal(24, 8);
  DECLARE R_RESULTQTYCHARGE decimal(24, 8);  -- add for calculation
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
  DECLARE R_BILLTO varchar(30);
  DECLARE R_NROW integer;
  DECLARE OUT_returnCode varchar(1000);


  -- Declare the cursor
  DECLARE my_cursor CURSOR FOR
  SELECT
    DATE_FORMAT(ls_storage.stockdate, '%Y-%m-%d') AS stockDate,
    ls_storage.warehouseid,
    ls_storage.customerid,
    ls_storage.workingArea,
    SUM(ls_storage.qtycbm) AS qtycbm
  FROM (SELECT
      DATE_FORMAT(stockDate, '%Y-%m-%d') AS stockdate,
      zib.warehouseId AS warehouseid,
      sm.tariffMasterId AS tariffmasterid,
      CASE WHEN zib.customerId = 'LTL' THEN la1.codeDescr ELSE sm.tariffId END AS tariffid,
      CASE WHEN zib.customerId = 'XXX' THEN 'SAMSONITE' ELSE zib.customerId END AS customerid,
      zib.locationId AS locationid,
      zib.locationCategory AS locationcategory,
      lc.codeDescr AS locationcategorydescr,
      zib.TRACEID AS traceid,
      s.sku_group1 AS muidltl,
      zib.muid AS muid,
      zib.lotNum AS lotnum,
      s.PACKID AS packid,
      CASE WHEN zib.customerId = 'MDS' THEN 'KG' ELSE zib.UOM END AS uom,
      CASE WHEN zib.warehouseId = 'CBT02' THEN 'LINC' WHEN zib.warehouseId = 'CBT03' AND
          /*l.workingArea = 'WHTMLA' THEN 'WHTMLA' WHEN zib.warehouseId = 'CBT03' AND
          l.workingArea = 'WHTMLB' THEN 'WHTMLB' WHEN zib.warehouseId = 'CBT03' AND*/
          l.workingArea = 'WHTMLC' THEN 'WHTMLC+D' WHEN zib.warehouseId = 'CBT03' AND
          l.workingArea = 'WHTMLD' THEN 'WHTMLC+D' WHEN zib.warehouseId = 'CBT03' AND
          l.workingArea = 'WHTMLE' THEN 'WHTMLE+G' WHEN zib.warehouseId = 'CBT03' AND
          l.workingArea = 'WHTMLG' THEN 'WHTMLE+G' ELSE l.workingArea END AS workingArea,
      /*before updatel.workingArea = 'WHTMLA' THEN 'WHTMLA' WHEN zib.warehouseId = 'CBT03' AND
      l.workingArea = 'WHTMLB' THEN 'WHTMLB' WHEN zib.warehouseId = 'CBT03' AND
      l.workingArea = 'WHTMLC' THEN 'WHTMLC+D' WHEN zib.warehouseId = 'CBT03' AND
      l.workingArea = 'WHTMLD' THEN 'WHTMLC+D' WHEN zib.warehouseId = 'CBT03' AND
      l.workingArea = 'WHTML3' THEN 'WHTMLE' ELSE l.workingArea END AS workingArea,
       * AB 24/12/30
       */
      zib.SKU AS sku,
      skuDesc AS skudesc,
      la.lotatt09 AS ponum,
      lc1.codeDescr AS typepallet,
      CASE WHEN zib.customerId = 'MDS' THEN (
            CASE WHEN pd2.uomDescr = 'KG' THEN zib.qtyonHand ELSE zib.qtyonHand * s.sku_group6 END
            ) ELSE zib.qtyonHand END AS qtyonhand,
      pd.qty AS qtyperpallet,
      CASE zib.customerId WHEN 'ASP' THEN zib.cube WHEN 'MAP' THEN s.cube WHEN 'ONDULINE' THEN s.cube WHEN 'SST_JKT' THEN s.cube WHEN 'CPI_JKT' THEN s.cube ELSE s.cube / 1000000 END AS cbmsku,
      CASE zib.customerId WHEN 'MAP' THEN (
            CASE WHEN la.lotatt04 = 'SET' THEN 0 ELSE (s.cube * zib.qtyonHand) END
            ) WHEN 'ONDULINE' THEN s.cube * zib.qtyonHand ELSE totalcube END AS qtycbm,
      CASE WHEN LENGTH(zib.locationId) = 7 THEN SUBSTRING(zib.locationId, 1, 1) WHEN LENGTH(zib.locationId) = 8 THEN SUBSTRING(zib.locationId, 1, 1) WHEN SUBSTRING(zib.locationId, 1, 3) = 'TML' AND
          zib.customerId <> 'LTL' THEN SUBSTRING(zib.locationId, 4, 1) WHEN sm.putawayRule = 'LTL09' THEN 'E' WHEN zib.SKU IN ('000000001100012851', '000000001100010211', '000000001100000616', '000000001100013296', '000000001100008797', '000000001100012070', '000000001100012068', '000000001100012478', '000000001100012898', '000000001100014515') THEN 'G' WHEN sm.putawayRule IN ('LTL03', 'GMPA-NONDG', 'ICHIKOH-NONDG', 'ITOCHU-NONDG', 'PMM-NONDG', 'LTL06', 'LTL07') THEN 'G' WHEN sm.putawayRule IN ('LTL08', 'ITOCHU-DG', 'PMM-DG', 'LTL01', 'LTL02', 'SMT') THEN 'B' WHEN sm.putawayRule = 'LTL-BULK' THEN 'D' WHEN sm.putawayRule IN ('BAJ', 'PLB-LTL', 'ADF', 'CCDI', 'CTI') THEN 'A' WHEN sm.putawayRule IN ('GYI', 'DKJ') THEN 'J' WHEN sm.putawayRule = 'LTL04' THEN 'B' WHEN sm.putawayRule IN ('DNN', 'PMM', 'ITOCHU') THEN 'C' ELSE l.udf03 END AS chamber,
      sm.putawayRule AS putawayrule,
      la.lotatt04 AS batchno,
      la.lotatt02 AS expiredate,
      la.lotatt03 AS whdate,
      CASE WHEN zib.customerId = 'ECCOSBY' THEN (
            CASE WHEN SUBSTRING(zib.locationId, 3, 1) = 'I' THEN 'ECCO2' ELSE 'ECCO' END
            ) ELSE SUBSTRING(zib.locationId, 1, 1) END AS area,
      CASE WHEN zib.customerId = 'PLB-LTL' THEN la.lotatt10 ELSE la.lotatt09 END AS externalpo,
      lc2.codeDescr AS whetherdamaged,
      CEILING(qtyonHand / pd.qty) AS palletused,
      CASE WHEN zib.customerId = 'RBFOOD' THEN pd1.qty ELSE s.NETWEIGHT END AS netweight
    FROM Z_InventoryBalance zib
      LEFT JOIN INV_LOT_ATT la
        ON la.organizationId = zib.organizationId
        AND la.customerId = zib.customerId
        AND la.sku = zib.sku
        AND la.lotNum = zib.lotNum
      LEFT OUTER JOIN (SELECT
          *
        FROM BSM_CODE_ML
        WHERE codetype = 'OWNER_LTL'
        AND languageid = 'en') la1
        ON la.organizationId = la1.organizationId
        AND la.lotatt11 = la1.codeid
      LEFT JOIN BAS_LOCATION l
        ON l.organizationId = zib.organizationId
        AND l.locationId = zib.locationId
        AND l.warehouseId = zib.warehouseId
      LEFT JOIN BAS_SKU s
        ON s.organizationId = zib.organizationId
        AND s.customerId = zib.customerId
        AND s.sku = zib.sku
      LEFT JOIN BAS_SKU_MULTIWAREHOUSE sm
        ON sm.organizationId = zib.organizationId
        AND sm.customerId = zib.customerId
        AND sm.sku = zib.sku
        AND sm.warehouseId = zib.warehouseId
      LEFT JOIN BAS_PACKAGE_DETAILS pd
        ON sm.organizationId = pd.organizationId
        AND sm.customerId = pd.customerId
        AND sm.packId = pd.packId
        AND pd.packUom = 'PL'
      LEFT JOIN BAS_PACKAGE_DETAILS pd1
        ON sm.organizationId = pd1.organizationId
        AND sm.customerId = pd1.customerId
        AND sm.packId = pd1.packId
        AND pd1.packUom = 'CS'
      LEFT JOIN BAS_PACKAGE_DETAILS pd2
        ON sm.organizationId = pd2.organizationId
        AND sm.customerId = pd2.customerId
        AND sm.packId = pd2.packId
        AND pd2.packUom = 'EA'
      LEFT JOIN BSM_CODE_ML lc
        ON lc.organizationId = zib.organizationId
        AND zib.locationCategory = lc.codeid
        AND lc.codeType = 'LOC_CAT'
        AND lc.languageId = 'en'
      LEFT JOIN BSM_CODE_ML lc1
        ON lc1.organizationId = la.organizationId
        AND la.lotAtt07 = lc1.codeid
        AND lc1.codeType = 'PLT_TYP'
        AND lc1.languageId = 'en'
      LEFT JOIN BSM_CODE_ML lc2
        ON lc2.organizationId = la.organizationId
        AND la.lotAtt08 = lc2.codeid
        AND lc2.codeType = 'DMG_FLG'
        AND lc2.languageId = 'en'
    WHERE zib.organizationId = IN_organizationId
    --  AND DATE(zib.StockDate) > '2025-01-26'
    --  AND DATE(zib.StockDate) < '2025-01-28'
    -- AND zib.warehouseId IN ('LADC01')
    AND zib.warehouseId IN ('CBT02', 'CBT03', 'LADC01')
    AND DATE(zib.StockDate) = DATE(DATE_ADD(NOW(), INTERVAL -1 DAY))

    AND zib.customerId = IN_CustomerId
    AND qtyonHand > 0
    AND zib.locationId NOT IN ('CONSWOR', 'LOST_CBT01', 'STG01', 'STG02', 'STG03', 'STG04', 'STG05', 'STG11', 'STG12', 'STG13', 'STG14', 'STG15', 'STG06', 'STG07', 'STG08', 'STG09', 'STG10', 'STG16', 'STG17', 'STG18', 'STG19', 'STG20', 'SORTATIONCBT01', 'CROSSDOCK_01', 'CROSSDOCK_02', 'SORTATIONLADC01', 'SORTATIONBASF01', 'SORTATIONCBT02', 'SORTATIONCBT03', 'SORTATION', 'SORTATIONMRD02', 'SORTATIONSMG-SO', 'SORTATION1', 'CYCLE-01S', 'LOST_CBT01', 'STO-01', 'STO-02', 'STO-03', 'STO-04', 'STO-05', 'WHAQC', 'WHCQC', 'WHCQC01', 'WHCQC03', 'WHCQC05', 'WHCQC09', 'WHCQC11', 'WHCQC13', 'WHCQC15', 'WHCQC17', 'WHCQC19', 'WHCQC21', 'WHCQC23', 'WHCQC25', 'WHCQC27', 'WHCQC29', 'WHCQC31', 'WHCQC33', 'WHCQC35', 'WHIQC', 'WORK_AREA', 'B04A065', 'B04A066', 'B04B065', 'B04B065')
    AND zib.sku NOT IN (SELECT
        sku
      FROM BAS_SKU bs2
      WHERE organizationId = zib.organizationId
      AND customerId = 'LTL'
      AND sku LIKE '13%'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU bs2
      WHERE organizationid = zib.organizationId
      AND customerid = 'SMARTSBY'
      AND sku = 'PALLET'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU
      WHERE organizationid = zib.organizationId
      AND customerid IN ('ECMAMA', 'ECMAMAB2C')
      AND sku LIKE '%TEST%'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU
      WHERE organizationid = zib.organizationId
      AND customerid IN ('MAP')
      AND sku IN ('DEMO TABLE AT', 'DEMO TABLE SAM', 'HOT STAMP'))
    ORDER BY zib.customerId) ls_storage
  GROUP BY ls_storage.warehouseId,
           ls_storage.customerId,
           ls_storage.StockDate,
           ls_storage.workingArea
  ORDER BY ls_storage.customerId, stockDate, ls_storage.workingArea;
  --   UNION ALL
  --   SELECT
  --     DATE(DATE_ADD(NOW(), INTERVAL -1 DAY)) AS stockDate,
  --     bth.warehouseId,
  --     btm.customerId,
  --     btr.udf03 AS workingArea,
  --     0 AS qtycbm
  --   FROM BIL_TARIFF_HEADER bth
  --     INNER JOIN BIL_TARIFF_DETAILS btd
  --       ON bth.organizationId = btd.organizationId
  --       AND bth.warehouseId = btd.warehouseId
  --       AND bth.tariffId = btd.tariffId
  --     INNER JOIN BIL_TARIFF_RATE btr
  --       ON bth.organizationId = btr.organizationId
  --       AND bth.warehouseId = btr.warehouseId
  --       AND bth.tariffId = btr.tariffId
  --       AND btd.tariffLineNo = btr.tariffLineNo
  --     INNER JOIN BIL_TARIFF_MASTER btm
  --       ON bth.organizationId = btm.organizationId
  --       AND bth.tariffMasterId = btm.tariffMasterId
  --   WHERE bth.organizationId = IN_organizationId
  --   AND btd.warehouseId IN ('CBT02', 'CBT03', 'LADC01')
  --   AND btm.Customerid = IN_CustomerId
  --   AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  --   AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  --   AND btd.chargeCategory = 'IV'
  --   AND btr.rate > 0
  --   AND btr.udf03 NOT IN (SELECT DISTINCT
  --       CASE WHEN bl.warehouseId = 'CBT02' THEN 'LINC' ELSE bl.workingArea END AS workingArea
  --     FROM Z_InventoryBalance lc
  --       INNER JOIN BAS_LOCATION bl
  --         ON lc.organizationId = bl.organizationId
  --         AND lc.warehouseId = bl.warehouseId
  --         AND lc.locationId = bl.locationId
  --     WHERE lc.organizationId = IN_organizationId
  --     AND DATE(lc.StockDate) = DATE(DATE_ADD(NOW(), INTERVAL -1 DAY))
  --     AND bl.warehouseId IN ('CBT02', 'CBT03', 'LADC01')
  --     AND lc.customerId = IN_CustomerId
  --     AND lc.qtyavailable > 0)
  --   ORDER BY stockDate ASC;

  -- Declare a handler for NOT FOUND condition
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  -- Open the cursor
  OPEN my_cursor;

-- Loop through the results
read_loop:
  LOOP
    -- Fetch the values into variables
    FETCH my_cursor INTO v_stockDate, v_warehouseId, v_customerId, v_workingArea, v_qtyCharge;


    -- SELECT 'debug =>',v_workingArea;


    -- Exit the loop if no more rows
    IF done = 1 THEN
      LEAVE read_loop;
    END IF;

    IF NOT EXISTS (SELECT
          1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = IN_organizationId
        AND bs.warehouseId = v_warehouseId
        AND bs.customerId = v_customerId
        -- AND DATE(bs.billingFromDate) = DATE(DATE_ADD(CURDATE(), INTERVAL -1 DAY))
        AND DATE(bs.billingFromDate) = v_stockDate
        AND bs.descr = v_workingArea
        AND bs.chargeCategory = 'IV') THEN


    BLOCK2:
      BEGIN
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
          btd.udf05, -- sementara pengganti ratebase
          btr.ratePerUnit,
          btr.rate,
          btd.minAmount,
          btd.maxAmount,
          btr.udf02,-- minimum billing
          btr.udf03,-- chamber name
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
          btd.billingParty,
          -- btd.billingTranCategory,
          IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
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
        AND bsm.warehouseId = v_warehouseId
        AND bsm.customerId = v_customerId
        AND btr.udf03 = v_workingArea -- for filter chamber name
        -- AND bth.tariffMasterId = od_tariffMasterId
        AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND btd.chargeCategory = 'IV'
        AND btr.rate > 0
        #AND IFNULL(DAY(bth.billingdate),0)!=0 
        ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;
        SELECT
          'look->',
          tariff_done;
        SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd

        #
        OPEN cur_Tariff;
      getTariff:
        LOOP
          FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
          R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_qtyMinimumContract, R_chamberName, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
          R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;

          --  SELECT 'DEBUG->',R_CUSTOMERID,v_warehouseId,v_customerId;
          IF tariff_done = 1 THEN
            SET tariff_done = 0;
            LEAVE getTariff;
          END IF;

          -- SELECT R_CUSTOMERID,R_WAREHOUSEID;
          -- SELECT tariff_done;



          IF (LTRIM(RTRIM(R_WAREHOUSEID)) = LTRIM(RTRIM(v_warehouseId)))
            AND (LTRIM(RTRIM(R_CUSTOMERID)) = LTRIM(RTRIM(v_customerId)))
            AND (LTRIM(RTRIM(R_chamberName)) = LTRIM(RTRIM(v_workingArea))) THEN
            -- CALCULATION
            -- UOM
            -- PALLET
            -- CUBIC
            -- M2
            -- CASE
            -- IP
            -- PIECES
            -- KG
            -- LITER
            -- DO
            -- HOUR
            -- MONTH


            --           SELECT  'check=>',R_ratebase,R_TARIFFID;
            SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
            SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
            SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
            SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
            SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
            SET R_billsummaryId = '';


            IF (R_ratebase = 'CUBIC') THEN
              IF (v_qtyCharge > R_qtyMinimumContract) THEN
                SET R_RESULTQTYCHARGE = v_qtyCharge;
              ELSE
                SET R_RESULTQTYCHARGE = R_qtyMinimumContract;
              END IF;
            ELSEIF (R_ratebase = 'M2') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'IP') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'KG') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'LITER') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'DO') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'PALLET') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'CASE') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'QUANTITY') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'NETWEIGHT') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'GW') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            /*additional nettweight grossweight*/
            ELSEIF (R_ratebase = 'MT') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            END IF;

            SELECT
              'DEBUG=>',
              v_customerId,
              R_CUSTOMERID,
              R_WAREHOUSEID,
              v_warehouseId,
              R_RESULTQTYCHARGE;

            --           SELECT 'check 2=>',R_RESULTQTYCHARGE;

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
            #
            IF (R_billsummaryId = '') THEN
              SET @linenumber = 0;
              SET OUT_returnCode = '';
              CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);

              IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
                SET OUT_returnCode = '999#????????';
                LEAVE getTariff;
              END IF;
            END IF;
            #
            SELECT
              R_billsummaryId;

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
                IN_organizationId,
                v_warehouseId,
                CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')),
                DATE_FORMAT(v_stockDate, '%Y-%m-%d'),
                DATE_FORMAT(v_stockDate, '%Y-%m-%d'),
                v_customerId,
                '',
                '',
                '',
                R_TARIFFID,
                R_CHARGECATEGORY,
                R_chargetype,
                -- R_descrC,
                CONCAT(v_workingArea),
                R_rateBase,
                R_rateperunit,
                R_RESULTQTYCHARGE,
                '',
                0,
                0,
                R_rate,
                R_RESULTQTYCHARGE * R_rate / R_rateperunit,
                (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
                0,
                R_cost * R_RESULTQTYCHARGE,
                0,
                NOW() confirmTime,
                '' confirmWho,
                '',
                '',
                '' createTransactionid,
                '' notes,
                NOW() ediSendTime,
                v_customerId AS billTo,
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
                R_RESULTQTYCHARGE * R_rate / R_rateperunit incomeWithoutTax,
                0 cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                R_materialNo AS udf01,
                R_itemChargeCategory AS udf02,
                0 udf03,
                R_UDF06 udf04,
                '' udf05,
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
                '' orderType,
                '' containerType,
                '' containerSize;

          END IF; -- END IF docType

        END LOOP getTariff;
        CLOSE cur_Tariff;






      END;
    ELSE
      ITERATE read_loop;
    END IF;



  END LOOP;

  -- Close the cursor
  CLOSE my_cursor;

END
$$

--
-- Create procedure `CML_BILLSTORAGE_DAILY_CBM`
--
CREATE
DEFINER = 'sa'@'%'
PROCEDURE CML_BILLSTORAGE_DAILY_CBM (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_trans_no varchar(30),
IN IN_tariffMaster varchar(30))
BEGIN
  -- Declare variables to hold cursor data
  DECLARE done int DEFAULT 0;
  DECLARE tariff_done int DEFAULT 0;
  DECLARE v_stockDate date;
  DECLARE v_customerId varchar(20);
  DECLARE v_warehouseId varchar(20);
  DECLARE v_skuGroup1 varchar(255);
  DECLARE v_workingArea varchar(255);
  DECLARE v_qtyCharge decimal(18, 4);

  -- Declare for Billing
  DECLARE R_CURRENTDATE timestamp;
  DECLARE R_OPDATE varchar(10);
  DECLARE R_FMDATE varchar(10);
  DECLARE R_TODATE varchar(10);
  DECLARE R_BILLINGDAY integer;
  DECLARE R_BILLINGDATE varchar(10);
  DECLARE R_Days int;
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
  DECLARE R_UDF03 varchar(500);
  DECLARE R_UDF06 varchar(500);
  DECLARE R_UDF07 varchar(500);
  DECLARE R_UDF08 varchar(500);
  DECLARE R_qtyMinimumContract decimal(24, 8);
  DECLARE R_chamberName varchar(500);
  DECLARE R_FINALAMOUNT decimal(24, 8);
  DECLARE R_billsummaryId varchar(30) DEFAULT '';
  DECLARE R_billsummaryNo varchar(30) DEFAULT '';
  DECLARE R_LOCATIONCAT char(2);
  DECLARE R_LOCATIONGROUP varchar(500);
  DECLARE R_INCOMETAX decimal(24, 8);
  DECLARE R_RESULTQTYCHARGE decimal(24, 8);  -- add for calculation
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
  DECLARE R_BILLTO varchar(30);
  DECLARE R_NROW integer;
  DECLARE OUT_returnCode varchar(1000);


  -- Declare the cursor
  DECLARE my_cursor CURSOR FOR
  SELECT
    DATE_FORMAT(ls_storage.stockdate, '%Y-%m-%d') AS stockDate,
    ls_storage.warehouseid,
    ls_storage.customerid,
    ls_storage.workingArea,
    SUM(ls_storage.qtycbm) AS qtycbm
  FROM (SELECT
      DATE_FORMAT(stockDate, '%Y-%m-%d') AS stockdate,
      zib.warehouseId AS warehouseid,
      sm.tariffMasterId AS tariffmasterid,
      CASE WHEN zib.customerId = 'LTL' THEN la1.codeDescr ELSE sm.tariffId END AS tariffid,
      CASE WHEN zib.customerId = 'XXX' THEN 'SAMSONITE' ELSE zib.customerId END AS customerid,
      zib.locationId AS locationid,
      zib.locationCategory AS locationcategory,
      lc.codeDescr AS locationcategorydescr,
      zib.TRACEID AS traceid,
      s.sku_group1 AS muidltl,
      zib.muid AS muid,
      zib.lotNum AS lotnum,
      s.PACKID AS packid,
      CASE WHEN zib.customerId = 'MDS' THEN 'KG' ELSE zib.UOM END AS uom,
      CASE WHEN zib.warehouseId = 'CBT02' THEN 'LINC' WHEN zib.warehouseId = 'CBT03' AND
          /*l.workingArea = 'WHTMLA' THEN 'WHTMLA' WHEN zib.warehouseId = 'CBT03' AND
          l.workingArea = 'WHTMLB' THEN 'WHTMLB' WHEN zib.warehouseId = 'CBT03' AND*/
          l.workingArea = 'WHTMLC' THEN 'WHTMLC+D' WHEN zib.warehouseId = 'CBT03' AND
          l.workingArea = 'WHTMLD' THEN 'WHTMLC+D' WHEN zib.warehouseId = 'CBT03' AND
          l.workingArea = 'WHTMLE' THEN 'WHTMLE+G' WHEN zib.warehouseId = 'CBT03' AND
          l.workingArea = 'WHTMLG' THEN 'WHTMLE+G' WHEN zib.warehouseId = 'JBK01' AND
          l.locationId LIKE 'A%' THEN 'A' WHEN zib.warehouseId = 'JBK01' AND
          l.locationId LIKE 'RCV%' THEN 'A' ELSE l.workingArea END AS workingArea, /*AB 22/07/25 add rcv1 to working area A*/
      /*before updatel.workingArea = 'WHTMLA' THEN 'WHTMLA' WHEN zib.warehouseId = 'CBT03' AND
      l.workingArea = 'WHTMLB' THEN 'WHTMLB' WHEN zib.warehouseId = 'CBT03' AND
      l.workingArea = 'WHTMLC' THEN 'WHTMLC+D' WHEN zib.warehouseId = 'CBT03' AND
      l.workingArea = 'WHTMLD' THEN 'WHTMLC+D' WHEN zib.warehouseId = 'CBT03' AND
      l.workingArea = 'WHTML3' THEN 'WHTMLE' ELSE l.workingArea END AS workingArea,
       * AB 24/12/30
       */
      zib.SKU AS sku,
      skuDesc AS skudesc,
      la.lotatt09 AS ponum,
      lc1.codeDescr AS typepallet,
      CASE WHEN zib.customerId = 'MDS' THEN (
            CASE WHEN pd2.uomDescr = 'KG' THEN zib.qtyonHand ELSE zib.qtyonHand * s.sku_group6 END
            ) ELSE zib.qtyonHand END AS qtyonhand,
      pd.qty AS qtyperpallet,
      CASE zib.customerId WHEN 'ASP' THEN zib.cube WHEN 'MAP' THEN s.cube WHEN 'ONDULINE' THEN s.cube WHEN 'SST_JKT' THEN s.cube WHEN 'CPI_JKT' THEN s.cube ELSE s.cube / 1000000 END AS cbmsku,
      CASE zib.customerId WHEN 'MAP' THEN (
            CASE WHEN la.lotatt04 = 'SET' THEN 0 ELSE (s.cube * zib.qtyonHand) END
            ) WHEN 'ONDULINE' THEN s.cube * zib.qtyonHand ELSE totalcube END AS qtycbm,
      CASE WHEN LENGTH(zib.locationId) = 7 THEN SUBSTRING(zib.locationId, 1, 1) WHEN LENGTH(zib.locationId) = 8 THEN SUBSTRING(zib.locationId, 1, 1) WHEN SUBSTRING(zib.locationId, 1, 3) = 'TML' AND
          zib.customerId <> 'LTL' THEN SUBSTRING(zib.locationId, 4, 1) WHEN sm.putawayRule = 'LTL09' THEN 'E' WHEN zib.SKU IN ('000000001100012851', '000000001100010211', '000000001100000616', '000000001100013296', '000000001100008797', '000000001100012070', '000000001100012068', '000000001100012478', '000000001100012898', '000000001100014515') THEN 'G' WHEN sm.putawayRule IN ('LTL03', 'GMPA-NONDG', 'ICHIKOH-NONDG', 'ITOCHU-NONDG', 'PMM-NONDG', 'LTL06', 'LTL07') THEN 'G' WHEN sm.putawayRule IN ('LTL08', 'ITOCHU-DG', 'PMM-DG', 'LTL01', 'LTL02', 'SMT') THEN 'B' WHEN sm.putawayRule = 'LTL-BULK' THEN 'D' WHEN sm.putawayRule IN ('BAJ', 'PLB-LTL', 'ADF', 'CCDI', 'CTI') THEN 'A' WHEN sm.putawayRule IN ('GYI', 'DKJ') THEN 'J' WHEN sm.putawayRule = 'LTL04' THEN 'B' WHEN sm.putawayRule IN ('DNN', 'PMM', 'ITOCHU') THEN 'C' ELSE l.udf03 END AS chamber,
      sm.putawayRule AS putawayrule,
      la.lotatt04 AS batchno,
      la.lotatt02 AS expiredate,
      la.lotatt03 AS whdate,
      CASE WHEN zib.customerId = 'ECCOSBY' THEN (
            CASE WHEN SUBSTRING(zib.locationId, 3, 1) = 'I' THEN 'ECCO2' ELSE 'ECCO' END
            ) ELSE SUBSTRING(zib.locationId, 1, 1) END AS area,
      CASE WHEN zib.customerId = 'PLB-LTL' THEN la.lotatt10 ELSE la.lotatt09 END AS externalpo,
      lc2.codeDescr AS whetherdamaged,
      CEILING(qtyonHand / pd.qty) AS palletused,
      CASE WHEN zib.customerId = 'RBFOOD' THEN pd1.qty ELSE s.NETWEIGHT END AS netweight
    FROM Z_InventoryBalance zib
      LEFT JOIN INV_LOT_ATT la
        ON la.organizationId = zib.organizationId
        AND la.customerId = zib.customerId
        AND la.sku = zib.sku
        AND la.lotNum = zib.lotNum
      LEFT OUTER JOIN (SELECT
          *
        FROM BSM_CODE_ML
        WHERE codetype = 'OWNER_LTL'
        AND languageid = 'en') la1
        ON la.organizationId = la1.organizationId
        AND la.lotatt11 = la1.codeid
      LEFT JOIN BAS_LOCATION l
        ON l.organizationId = zib.organizationId
        AND l.locationId = zib.locationId
        AND l.warehouseId = zib.warehouseId
      LEFT JOIN BAS_SKU s
        ON s.organizationId = zib.organizationId
        AND s.customerId = zib.customerId
        AND s.sku = zib.sku
      LEFT JOIN BAS_SKU_MULTIWAREHOUSE sm
        ON sm.organizationId = zib.organizationId
        AND sm.customerId = zib.customerId
        AND sm.sku = zib.sku
        AND sm.warehouseId = zib.warehouseId
      LEFT JOIN BAS_PACKAGE_DETAILS pd
        ON sm.organizationId = pd.organizationId
        AND sm.customerId = pd.customerId
        AND sm.packId = pd.packId
        AND pd.packUom = 'PL'
      LEFT JOIN BAS_PACKAGE_DETAILS pd1
        ON sm.organizationId = pd1.organizationId
        AND sm.customerId = pd1.customerId
        AND sm.packId = pd1.packId
        AND pd1.packUom = 'CS'
      LEFT JOIN BAS_PACKAGE_DETAILS pd2
        ON sm.organizationId = pd2.organizationId
        AND sm.customerId = pd2.customerId
        AND sm.packId = pd2.packId
        AND pd2.packUom = 'EA'
      LEFT JOIN BSM_CODE_ML lc
        ON lc.organizationId = zib.organizationId
        AND zib.locationCategory = lc.codeid
        AND lc.codeType = 'LOC_CAT'
        AND lc.languageId = 'en'
      LEFT JOIN BSM_CODE_ML lc1
        ON lc1.organizationId = la.organizationId
        AND la.lotAtt07 = lc1.codeid
        AND lc1.codeType = 'PLT_TYP'
        AND lc1.languageId = 'en'
      LEFT JOIN BSM_CODE_ML lc2
        ON lc2.organizationId = la.organizationId
        AND la.lotAtt08 = lc2.codeid
        AND lc2.codeType = 'DMG_FLG'
        AND lc2.languageId = 'en'
    WHERE zib.organizationId = IN_organizationId
    --  AND DATE(zib.StockDate) > '2025-01-26'
    --  AND DATE(zib.StockDate) < '2025-01-28'
    -- AND zib.warehouseId IN ('LADC01')
    AND zib.warehouseId IN ('CBT02', 'CBT03', 'LADC01', 'JBK01')
    AND DATE(zib.StockDate) = DATE(DATE_ADD(NOW(), INTERVAL -1 DAY))

    AND zib.customerId = IN_CustomerId
    AND qtyonHand > 0
    AND zib.locationId NOT IN ('CONSWOR', 'LOST_CBT01', 'STG01', 'STG02', 'STG03', 'STG04', 'STG05', 'STG11', 'STG12', 'STG13', 'STG14', 'STG15', 'STG06', 'STG07', 'STG08', 'STG09', 'STG10', 'STG16', 'STG17', 'STG18', 'STG19', 'STG20', 'SORTATIONCBT01', 'CROSSDOCK_01', 'CROSSDOCK_02', 'SORTATIONLADC01', 'SORTATIONBASF01', 'SORTATIONCBT02', 'SORTATIONCBT03', 'SORTATION', 'SORTATIONMRD02', 'SORTATIONSMG-SO', 'SORTATION1', 'CYCLE-01S', 'LOST_CBT01', 'STO-01', 'STO-02', 'STO-03', 'STO-04', 'STO-05', 'WHAQC', 'WHCQC', 'WHCQC01', 'WHCQC03', 'WHCQC05', 'WHCQC09', 'WHCQC11', 'WHCQC13', 'WHCQC15', 'WHCQC17', 'WHCQC19', 'WHCQC21', 'WHCQC23', 'WHCQC25', 'WHCQC27', 'WHCQC29', 'WHCQC31', 'WHCQC33', 'WHCQC35', 'WHIQC', 'WORK_AREA', 'B04A065', 'B04A066', 'B04B065', 'B04B065')
    AND zib.sku NOT IN (SELECT
        sku
      FROM BAS_SKU bs2
      WHERE organizationId = zib.organizationId
      AND customerId = 'LTL'
      AND sku LIKE '13%'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU bs2
      WHERE organizationid = zib.organizationId
      AND customerid = 'SMARTSBY'
      AND sku = 'PALLET'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU
      WHERE organizationid = zib.organizationId
      AND customerid IN ('ECMAMA', 'ECMAMAB2C')
      AND sku LIKE '%TEST%'
      UNION ALL
      SELECT
        sku
      FROM BAS_SKU
      WHERE organizationid = zib.organizationId
      AND customerid IN ('MAP')
      AND sku IN ('DEMO TABLE AT', 'DEMO TABLE SAM', 'HOT STAMP'))
    ORDER BY zib.customerId) ls_storage
  GROUP BY ls_storage.warehouseId,
           ls_storage.customerId,
           ls_storage.StockDate,
           ls_storage.workingArea
  ORDER BY ls_storage.customerId, stockDate, ls_storage.workingArea;
  --   UNION ALL
  --   SELECT
  --     DATE(DATE_ADD(NOW(), INTERVAL -1 DAY)) AS stockDate,
  --     bth.warehouseId,
  --     btm.customerId,
  --     btr.udf03 AS workingArea,
  --     0 AS qtycbm
  --   FROM BIL_TARIFF_HEADER bth
  --     INNER JOIN BIL_TARIFF_DETAILS btd
  --       ON bth.organizationId = btd.organizationId
  --       AND bth.warehouseId = btd.warehouseId
  --       AND bth.tariffId = btd.tariffId
  --     INNER JOIN BIL_TARIFF_RATE btr
  --       ON bth.organizationId = btr.organizationId
  --       AND bth.warehouseId = btr.warehouseId
  --       AND bth.tariffId = btr.tariffId
  --       AND btd.tariffLineNo = btr.tariffLineNo
  --     INNER JOIN BIL_TARIFF_MASTER btm
  --       ON bth.organizationId = btm.organizationId
  --       AND bth.tariffMasterId = btm.tariffMasterId
  --   WHERE bth.organizationId = IN_organizationId
  --   AND btd.warehouseId IN ('CBT02', 'CBT03', 'LADC01')
  --   AND btm.Customerid = IN_CustomerId
  --   AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  --   AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  --   AND btd.chargeCategory = 'IV'
  --   AND btr.rate > 0
  --   AND btr.udf03 NOT IN (SELECT DISTINCT
  --       CASE WHEN bl.warehouseId = 'CBT02' THEN 'LINC' ELSE bl.workingArea END AS workingArea
  --     FROM Z_InventoryBalance lc
  --       INNER JOIN BAS_LOCATION bl
  --         ON lc.organizationId = bl.organizationId
  --         AND lc.warehouseId = bl.warehouseId
  --         AND lc.locationId = bl.locationId
  --     WHERE lc.organizationId = IN_organizationId
  --     AND DATE(lc.StockDate) = DATE(DATE_ADD(NOW(), INTERVAL -1 DAY))
  --     AND bl.warehouseId IN ('CBT02', 'CBT03', 'LADC01')
  --     AND lc.customerId = IN_CustomerId
  --     AND lc.qtyavailable > 0)
  --   ORDER BY stockDate ASC;

  -- Declare a handler for NOT FOUND condition
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  -- Open the cursor
  OPEN my_cursor;

-- Loop through the results
read_loop:
  LOOP
    -- Fetch the values into variables
    FETCH my_cursor INTO v_stockDate, v_warehouseId, v_customerId, v_workingArea, v_qtyCharge;


    -- SELECT 'debug =>',v_workingArea;


    -- Exit the loop if no more rows
    IF done = 1 THEN
      LEAVE read_loop;
    END IF;

    IF NOT EXISTS (SELECT
          1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = IN_organizationId
        AND bs.warehouseId = v_warehouseId
        AND bs.customerId = v_customerId
        -- AND DATE(bs.billingFromDate) = DATE(DATE_ADD(CURDATE(), INTERVAL -1 DAY))
        AND DATE(bs.billingFromDate) = v_stockDate
        AND bs.descr = v_workingArea
        AND bs.chargeCategory = 'IV') THEN


    BLOCK2:
      BEGIN
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
          btd.udf05, -- sementara pengganti ratebase
          btr.ratePerUnit,
          btr.rate,
          btd.minAmount,
          btd.maxAmount,
          btr.udf02,-- minimum billing
          btr.udf03,-- chamber name
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
          btd.billingParty,
          -- btd.billingTranCategory,
          IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
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
        AND bsm.warehouseId = v_warehouseId
        AND bsm.customerId = v_customerId
        AND btr.udf03 = v_workingArea -- for filter chamber name
        -- AND bth.tariffMasterId = od_tariffMasterId
        AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND btd.chargeCategory = 'IV'
        AND btr.rate > 0
        AND bth.tariffMasterId NOT IN ('BIL00062PT')
        #AND IFNULL(DAY(bth.billingdate),0)!=0 
        ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;
        SELECT
          'look->',
          tariff_done;
        SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd

        #
        OPEN cur_Tariff;
      getTariff:
        LOOP
          FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
          R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_qtyMinimumContract, R_chamberName, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
          R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;

          --  SELECT 'DEBUG->',R_CUSTOMERID,v_warehouseId,v_customerId;
          IF tariff_done = 1 THEN
            SET tariff_done = 0;
            LEAVE getTariff;
          END IF;

          -- SELECT R_CUSTOMERID,R_WAREHOUSEID;
          -- SELECT tariff_done;



          IF (LTRIM(RTRIM(R_WAREHOUSEID)) = LTRIM(RTRIM(v_warehouseId)))
            AND (LTRIM(RTRIM(R_CUSTOMERID)) = LTRIM(RTRIM(v_customerId)))
            AND (LTRIM(RTRIM(R_chamberName)) = LTRIM(RTRIM(v_workingArea))) THEN
            -- CALCULATION
            -- UOM
            -- PALLET
            -- CUBIC
            -- M2
            -- CASE
            -- IP
            -- PIECES
            -- KG
            -- LITER
            -- DO
            -- HOUR
            -- MONTH


            --           SELECT  'check=>',R_ratebase,R_TARIFFID;
            SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
            SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
            SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
            SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
            SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
            SET R_billsummaryId = '';


            IF (R_ratebase = 'CUBIC') THEN
              IF (v_qtyCharge > R_qtyMinimumContract) THEN
                SET R_RESULTQTYCHARGE = v_qtyCharge;
              ELSE
                SET R_RESULTQTYCHARGE = R_qtyMinimumContract;
              END IF;
            ELSEIF (R_ratebase = 'M2') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'IP') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'KG') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'LITER') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'DO') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'PALLET') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'CASE') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'QUANTITY') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'NETWEIGHT') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            ELSEIF (R_ratebase = 'GW') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            /*additional nettweight grossweight*/
            ELSEIF (R_ratebase = 'MT') THEN
              SET R_RESULTQTYCHARGE = v_qtyCharge;
            END IF;

            SELECT
              'DEBUG=>',
              v_customerId,
              R_CUSTOMERID,
              R_WAREHOUSEID,
              v_warehouseId,
              R_RESULTQTYCHARGE;

            --           SELECT 'check 2=>',R_RESULTQTYCHARGE;

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
            #
            IF (R_billsummaryId = '') THEN
              SET @linenumber = 0;
              SET OUT_returnCode = '';
              CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);

              IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
                SET OUT_returnCode = '999#????????';
                LEAVE getTariff;
              END IF;
            END IF;
            #
            SELECT
              R_billsummaryId;

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
                IN_organizationId,
                v_warehouseId,
                CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')),
                DATE_FORMAT(v_stockDate, '%Y-%m-%d'),
                DATE_FORMAT(v_stockDate, '%Y-%m-%d'),
                v_customerId,
                '',
                '',
                '',
                R_TARIFFID,
                R_CHARGECATEGORY,
                R_chargetype,
                -- R_descrC,
                CONCAT(v_workingArea),
                R_rateBase,
                R_rateperunit,
                R_RESULTQTYCHARGE,
                '',
                0,
                0,
                R_rate,
                R_RESULTQTYCHARGE * R_rate / R_rateperunit,
                (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
                0,
                R_cost * R_RESULTQTYCHARGE,
                0,
                NOW() confirmTime,
                '' confirmWho,
                '',
                '',
                '' createTransactionid,
                '' notes,
                NOW() ediSendTime,
                v_customerId AS billTo,
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
                R_RESULTQTYCHARGE * R_rate / R_rateperunit incomeWithoutTax,
                0 cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                R_materialNo AS udf01,
                R_itemChargeCategory AS udf02,
                0 udf03,
                R_UDF06 udf04,
                '' udf05,
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
                '' orderType,
                '' containerType,
                '' containerSize;

          END IF; -- END IF docType

        END LOOP getTariff;
        CLOSE cur_Tariff;






      END;
    ELSE
      ITERATE read_loop;
    END IF;



  END LOOP;

  -- Close the cursor
  CLOSE my_cursor;

END
$$

--
-- Create procedure `CML_BILLSOVASSTD`
--
CREATE
DEFINER = 'sa'@'%'
PROCEDURE CML_BILLSOVASSTD (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_trans_no varchar(30),
IN IN_tariffMaster varchar(30))
BEGIN


  ####################################################################
  ##????
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
  DECLARE R_RESULTQTYCHARGE decimal(24, 8);  -- add for calculation
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
  DECLARE R_BILLTO varchar(30);
  DECLARE R_VASTYPE varchar(30);
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
  DECLARE od_soReference1 varchar(255);
  DECLARE od_skuDescr1 varchar(255);
  DECLARE od_warehouseId varchar(255);
  DECLARE od_customerId varchar(255);
  DECLARE od_soNo varchar(255);
  DECLARE od_soLineNo varchar(255);
  DECLARE od_sku varchar(255);
  DECLARE od_qtyReceived varchar(255);
  DECLARE od_uom varchar(255);
  DECLARE od_qtyReceivedEach varchar(255);
  DECLARE od_totalCube varchar(255);
  DECLARE od_vasType varchar(255);
  DECLARE od_qtyCharge varchar(255);
  DECLARE od_tarifMaster varchar(255);
  DECLARE OUT_returnCode varchar(1000);

  ####################################################################
  ##????
  DECLARE inventory_done int DEFAULT 0;
  DECLARE tariff_done int DEFAULT 0;
  DECLARE order_done,
          attribute_done int DEFAULT 0;



  DECLARE cur_orderno CURSOR FOR
  SELECT
    IFNULL(CAST(doh.organizationId AS char(255)), '') AS organizationId,
    IFNULL(CAST(doh.warehouseId AS char(255)), '') AS warehouseId,
    IFNULL(CAST(doh.customerId AS char(255)), '') AS customerId,
    IFNULL(CAST(doh.orderNo AS char(255)), '') AS orderNo,
    IFNULL(CAST(doh.soReference1 AS char(255)), '') AS soReference1,
    -- IFNULL(CAST(dod.sku AS char(255)), '') AS sku,
    -- IFNULL(CAST(bs.skuDescr1 AS char(255)), '') AS skuDescr1,
    vsdo.orderLineNo AS orderlineNo,
    IFNULL(CAST(vsdo.vasType AS char(255)), '') AS vasType,
    IFNULL(CAST(vsdo.vasqty AS char(255)), '') AS qtyCharge,
    IFNULL(CAST(vsdo.packUom AS char(255)), '') AS packUom,
    IFNULL(CAST(bsm.tariffMasterId AS char(255)), '') AS tarifMaster
  FROM DOC_ORDER_HEADER doh
    LEFT OUTER JOIN DOC_ORDER_VAS vsdo
      ON doh.organizationId = vsdo.organizationId
      AND doh.warehouseId = vsdo.warehouseId
      AND doh.orderNo = vsdo.orderNo
    LEFT OUTER JOIN DOC_ORDER_DETAILS dod
      ON dod.organizationId = vsdo.organizationId
      AND dod.warehouseId = vsdo.warehouseId
      AND dod.orderNo = vsdo.orderNo
      AND dod.orderLineNo = vsdo.orderLineNo
    LEFT OUTER JOIN BAS_SKU bs
      ON bs.organizationId = dod.organizationId
      AND bs.customerId = dod.customerId
      AND bs.SKU = dod.sku
    LEFT OUTER JOIN BAS_SKU_MULTIWAREHOUSE bsm
      ON bsm.organizationId = doh.organizationId
      AND bsm.warehouseId = doh.warehouseId
      AND bsm.customerId = doh.customerId
      AND bsm.SKU = dod.Sku
  WHERE vsdo.warehouseId = IN_warehouseId
  AND doh.customerId = IN_CustomerId
  AND doh.orderNo = IN_trans_no
  -- AND bsm.tariffMasterId = 'BIL00418'
  AND doh.orderType NOT IN ('FREE')
  AND doh.soStatus IN ('99')
  GROUP BY doh.organizationId,
           doh.warehouseId,
           doh.customerId,
           doh.orderNo,
           doh.soReference1,
           dod.sku,
           bs.skuDescr1,
           vsdo.orderLineNo,
           vsdo.vasType,
           vsdo.vasqty,
           vsdo.packUom,
           bsm.tariffMasterId;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET order_done = 1;
  OPEN cur_orderno;
cur_order_loop:
  LOOP
    FETCH FROM cur_orderno INTO od_organizationId,
    od_warehouseId,
    od_customerId,
    od_soNo,
    od_soReference1,
    /*od_sku,
    od_skuDescr1,*/
    od_soLineNo,
    od_vasType,
    od_qtyCharge,
    od_uom,
    od_tarifMaster;

    IF order_done = 1 THEN

      SET order_done = 0;
      LEAVE cur_order_loop;
    END IF;
  --     SELECT
  --       CONCAT('** DEBUG:', od_asnNo) AS debug;


  BLOCK2:
    BEGIN
      --  IF (od_tariffMasterId <> '') THEN

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
        btd.billingParty,
        IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory,
        btd.vasType
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
      AND bth.tariffMasterId = od_tarifMaster
      AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND btd.chargeCategory = 'VA'
      AND btd.tariffLineNo <= 100
      AND btd.vasType = od_vasType
      --       AND btd.docType IN (SELECT
      --           dah.asnType
      --         FROM DOC_ASN_HEADER dah
      --         WHERE dah.asnNo = IN_asnNo)
      AND btr.rate > 0
      #AND IFNULL(DAY(bth.billingdate),0)!=0
      ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;

      SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd
      #
      OPEN cur_Tariff;
    getTariff:
      LOOP
        FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
        R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
        R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY, R_BILLINGTRANCATEGORY, R_VASTYPE;
        IF tariff_done THEN
          SET tariff_done = FALSE;
          LEAVE getTariff;
        END IF;


        IF (UPPER(R_VASTYPE) = UPPER(od_vasType)) THEN
          -- CALCULATION
          -- UOM
          -- PALLET
          -- CUBIC
          -- M2
          -- CASE
          -- IP
          -- PIECES
          -- KG
          -- LITER
          -- DO
          -- HOUR
          -- MONTH



          SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
          SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
          SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
          SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
          SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
          SET R_billsummaryId = '';


          SET R_RESULTQTYCHARGE = od_qtyCharge; /*update ini saja, sebelumnya od_qtyCharge = R_RESULTCHARGE*/

          SELECT
            'check===>',
            UPPER(R_CHARGETYPE),
            UPPER(od_vasType),
            od_tarifMaster,
            R_docType,
            R_RESULTQTYCHARGE,
            od_qtyCharge,
            R_VASTYPE;

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
          #
          IF (R_billsummaryId = '') THEN
            SET @linenumber = 0;
            SET OUT_returnCode = '';
            CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);
            IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
              SET OUT_returnCode = '999#????????';
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
              od_organizationId,
              od_warehouseId,
              CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')),
              CURDATE(),
              CURDATE(),
              od_customerId,
              '', -- od_sku,
              '',
              '',
              R_TARIFFID,
              R_CHARGECATEGORY,
              R_chargetype,
              R_descrC,
              R_rateBase,
              R_rateperunit,
              od_qtyCharge,
              od_uom,
              '0',
              '0',
              R_rate,
              R_RESULTQTYCHARGE * R_rate / R_rateperunit,
              (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
              0,
              R_cost * R_RESULTQTYCHARGE,
              0,
              NULL confirmTime,
              '' confirmWho,
              'SO' dockType,
              od_soNo,
              '' createTransactionid,
              R_CHARGETYPE notes,
              NULL ediSendTime,
              R_BILLTO billTo,
              NULL settleTime,
              '' settleWho,
              '' followUp,
              '' invoiceType,
              '' paidTo,
              '' costConfirmFlag,
              NULL costConfirmTime,
              '' costConfirmWho,
              '' costSettleFlag,
              NULL costSettleTime,
              '' costSettleWho,
              NULL incomeTaxRate,
              0 costTaxRate,
              NULL incomeTax,
              0 cosTax,
              NULL incomeWithoutTax,
              NULL cosWithoutTax,
              '' costInvoiceType,
              '' noteText,
              R_materialNo AS udf01,
              R_itemChargeCategory AS udf02,
              R_UDF08 udf03,
              R_UDF06 udf04,
              NULL udf05,
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
              NULL ediSendTime2,
              'N' ediSendFlag2,
              '' ediErrorCode2,
              '' ediErrorMessage2,
              '' billingTranCategory,
              '' orderType,
              '' containerType,
              '' containerSize;

        END IF; -- END IF docType

      END LOOP getTariff;
      CLOSE cur_Tariff;


    --  END IF; 
    --  END IF TARIFF ORDER KOSONG
    END;




  END LOOP cur_order_loop;
  CLOSE cur_orderno;
  SET OUT_returnCode = '000';
END
$$

--
-- Create procedure `CML_BILLRENTPALLET_R_BILL_MODE`
--
CREATE
DEFINER = 'it.ari'@'%'
PROCEDURE CML_BILLRENTPALLET_R_BILL_MODE (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30))
BEGIN
  -- Declare variables to hold cursor data
  DECLARE done int DEFAULT 0;
  DECLARE tariff_done int DEFAULT 0;
  DECLARE days_done int DEFAULT 0;
  DECLARE v_organizationId varchar(255);
  DECLARE v_warehouseId varchar(20);
  DECLARE v_customerId varchar(20);
  DECLARE v_qty_TraceId decimal(24, 8);
  DECLARE v_qty_MUID decimal(24, 8);
  DECLARE v_max_TraceId decimal(24, 8);
  DECLARE v_avg_TraceId decimal(24, 8);
  DECLARE v_max_MUID decimal(24, 8);
  DECLARE v_avg_MUID decimal(24, 8);
  DECLARE v_max_qty decimal(24, 8);
  DECLARE v_avg_qty decimal(24, 8);
  DECLARE v_qty decimal(24, 8);
  DECLARE v_max_qty_cbm decimal(24, 8);
  DECLARE v_avg_qty_cbm decimal(24, 8);
  DECLARE v_qty_cbm decimal(24, 8);
  DECLARE v_chargeType varchar(255);
  DECLARE v_storageType varchar(255);
  -- Declare for Billing
  DECLARE R_CURRENTDATE timestamp;
  DECLARE R_OPDATE varchar(10);
  DECLARE R_FMDATE varchar(10);
  DECLARE R_TODATE varchar(10);
  DECLARE R_BILLINGDAY int;
  DECLARE R_BILLINGDATE varchar(10);
  DECLARE R_Days int(11);
  DECLARE R_TARGETDATE varchar(10);
  DECLARE R_DAYOFMONTH int(11);
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
  DECLARE R_rate_udf03 varchar(50);
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
  DECLARE R_UDF03 varchar(500);
  DECLARE R_UDF06 varchar(500);
  DECLARE R_UDF07 varchar(500);
  DECLARE R_UDF08 varchar(500);
  DECLARE R_qtyMinimumContract decimal(24, 8);
  DECLARE R_chamberName varchar(500);
  DECLARE R_FINALAMOUNT decimal(24, 6);
  DECLARE R_billsummaryId varchar(30) DEFAULT '';
  DECLARE R_billsummaryNo varchar(30) DEFAULT '';
  DECLARE R_LOCATIONCAT char(2);
  DECLARE R_LOCATIONGROUP varchar(500);
  DECLARE R_INCOMETAX decimal(24, 8);
  DECLARE R_RESULTQTYCHARGE decimal(24, 6);  -- add for calculation
  DECLARE R_CLASSFROM decimal(24, 6);
  DECLARE R_CLASSTO decimal(24, 6);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
  DECLARE R_BILLTO varchar(30);
  DECLARE R_NROW integer;
  DECLARE OUT_returnCode varchar(1000);


  -- Declare the cursor
  DECLARE my_cursor CURSOR FOR
  SELECT
    zib.organizationId,
    zib.warehouseId,
    zib.customerId,
    SUM(zib.qty_TraceId),
    SUM(zib.qty_MUID),
    MAX(zib.qty_TraceId) AS max_TraceId,
    AVG(zib.qty_TraceId) AS avg_TraceId,
    MAX(zib.qty_MUID) AS max_MUID,
    AVG(zib.qty_MUID) AS avg_MUID,
    SUM(zib.qty),
    MAX(zib.qty) AS max_qty,
    AVG(zib.qty) AS avg_qty,
    SUM(zib.qty_cbm),
    MAX(zib.qty_cbm) AS max_qty_cbm,
    AVG(zib.qty_cbm) AS avg_qty_cbm,
    zib.udf01,
    zib.chargeType
  FROM Z_BIL_AKUM_DAYS_STORAGE zib
  WHERE zib.organizationId = IN_organizationId
  AND zib.customerId = IN_CustomerId
  AND zib.StockDate BETWEEN DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL -1 MONTH), '%Y-%m-%d') AND DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)
  -- AND zib.StockDate >= IN_datefrom
  -- AND zib.StockDate <= IN_dateto
  AND zib.warehouseId = IN_warehouseId
  AND zib.chargeType = 'RP'
  GROUP BY zib.organizationId,
           zib.warehouseId,
           zib.customerId,
           zib.udf01,
           zib.chargeType
  ORDER BY zib.organizationId, zib.warehouseId, zib.customerId, zib.chargeType;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

  -- Open the cursor
  OPEN my_cursor;

-- Loop through the results
read_loop:
  LOOP
    -- Fetch the values into variables
    FETCH my_cursor INTO v_organizationId, v_warehouseId, v_customerId, v_qty_TraceId, v_qty_MUID, v_max_TraceId, v_avg_TraceId, v_max_MUID, v_avg_MUID, v_qty, v_max_qty, v_avg_qty, v_qty_cbm, v_max_qty_cbm, v_avg_qty_cbm, v_storageType, v_chargeType;




    -- Exit the loop if no more rows
    IF done = 1 THEN

      LEAVE read_loop;
    END IF;




    IF NOT EXISTS (SELECT
          1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = v_organizationId
        AND bs.warehouseId = v_warehouseId
        AND bs.customerId = v_customerId
        AND bs.billingFromDate BETWEEN DATE_FORMAT(DATE_ADD(DATE_ADD(CURRENT_DATE(), INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d') AND DATE_ADD(CURRENT_DATE(), INTERVAL -1 DAY)
        --        AND bs.billingFromDate>= IN_datefrom
        --        AND bs.billingFromDate<= IN_dateto
        -- DATE(DATE_ADD(CURDATE(), INTERVAL -1 MONTH))
        -- AND DATE(bs.billingFromDate) = v_stockDate
        -- AND bs.descr = v_workingArea
        AND bs.chargeCategory = 'IV'
        AND bs.chargeType = 'PL'
        AND bs.arNo IN ('*')) THEN


    BLOCK2:
      BEGIN
        DECLARE cur_Tariff CURSOR FOR
        SELECT DISTINCT
          bcm.organizationId,
          bcm.warehouseId,
          bcm.CUSTOMERID,
          DATE_FORMAT(DATE(DATE_ADD(bth.billingdate, INTERVAL -1 DAY)), '%d') AS billingDate,
          btr.tariffId,
          btr.tariffLineNo,
          btr.tariffClassNo,
          btd.chargeCategory,
          btd.chargeType,
          btd.descrC,
          btd.docType,
          btd.udf05, -- sementara pengganti ratebase
          btr.ratePerUnit,
          btr.rate,
          btd.minAmount,
          btd.maxAmount,
          -- btr.udf02,-- minimum billing
          btr.udf03,-- chamber name
          IF(btd.UDF03 = '', 0, btd.UDF03) AS minQty,
          btd.UDF01 AS MaterialNo,
          btd.udf02 AS itemChargeCategory,
          btd.udf04 AS billMode,
          btd.locationCategory,
          btd.UDF05,
          btd.UDF06,
          btd.UDF07,
          btd.UDF08,
          IFNULL(btd.incomeTaxRate, 0) IncomeTaxRate,
          CASE WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1 ELSE IFNULL(btr.classfrom, 0) END,
          IFNULL(btr.classTo, 0),
          bth.contractNo,
          bth.tariffMasterId,
          btr.cost,
          IF(btr.udf03 = '', 0, btr.udf03) AS storageType,
          btd.billingParty,
          -- btd.billingTranCategory,
          IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
        FROM BAS_CUSTOMER_MULTIWAREHOUSE bcm
          INNER JOIN BAS_CUSTOMER bc
            ON bc.customerId = bcm.customerId
            AND bc.organizationId = bcm.organizationId
            AND bc.CustomerType = 'OW'
          INNER JOIN BIL_TARIFF_HEADER bth
            ON bth.organizationId = bcm.organizationId
            AND bth.tariffMasterId = bcm.tariffMasterId
          INNER JOIN BIL_TARIFF_DETAILS btd
            ON btd.organizationId = bth.organizationId
            AND btd.tariffId = bth.tariffId
          INNER JOIN BIL_TARIFF_RATE btr
            ON btr.organizationId = btd.organizationId
            AND btr.tariffId = btd.tariffId
            AND btr.tariffLineNo = btd.tariffLineNo
          LEFT JOIN BSM_CODE_ML bm
            ON bm.organizationId = btd.organizationId
            AND bm.codeId = btd.udf04
            AND bm.codeType = 'SP_TRACEID'
            AND bm.languageId = 'en'

        WHERE bcm.organizationId = v_organizationId
        AND bcm.warehouseId = v_warehouseId
        AND bcm.customerId = v_customerId
        AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND btd.chargeCategory = 'IV'
        AND btd.chargeType = 'PL'
        AND btr.rate > 0
        AND CASE WHEN bcm.customerId IN ('ECMAMA', 'ECMAMAB2C', 'LTL') THEN (btr.udf03 = v_storageType) ELSE (btr.udf03 = '') END
        #AND IFNULL(DAY(bth.billingdate),0)!=0 
        ORDER BY bcm.organizationId, bcm.warehouseId, bcm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;

        SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd


        #
        OPEN cur_Tariff;
      getTariff:
        LOOP
          FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
          R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount,/*R_qtyMinimumContract,*/ R_chamberName, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
          R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_rate_udf03, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;

          /*SELECT
                    'look->',
                    tariff_done,
                    R_RESULTQTYCHARGE,
                      v_qty_TraceId,
                      v_qty_MUID,
                      v_max_TraceId,
                      v_avg_TraceId,
                      v_max_MUID,
                      v_avg_MUID,
          			v_qty,
                      v_max_qty,
                      v_avg_qty,
                      v_chargeType,
                      R_minAmount,
                      R_rate,
                      R_ratePerUnit;*/
          --  SELECT 'DEBUG->',R_CUSTOMERID,v_warehouseId,v_customerId;


          IF tariff_done = 1 THEN
            SET tariff_done = 0;
            LEAVE getTariff;
          END IF;

          -- SELECT R_CUSTOMERID,R_WAREHOUSEID;
          -- SELECT tariff_done;


          IF (LTRIM(RTRIM(R_WAREHOUSEID)) = LTRIM(RTRIM(v_warehouseId)))
            AND (LTRIM(RTRIM(R_CUSTOMERID)) = LTRIM(RTRIM(v_customerId))) THEN

            -- CALCULATION
            -- UOM
            -- PALLET
            -- CUBIC
            -- M2
            -- CASE
            -- IP
            -- PIECES
            -- KG
            -- LITER
            -- DO
            -- HOUR
            -- MONTH


            --           SELECT  'check=>',R_ratebase,R_TARIFFID;
            SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
            SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
            SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
            SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
            SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
            SET R_billsummaryId = '';

            /*IF (R_billMode = 'CUBIC') THEN
             IF(v_max_TraceId > sum(R_minAmount/(R_rate/R_ratePerUnit)) THEN
                SET R_RESULTQTYCHARGE = v_max_TraceId;
              ELSE
                SET R_RESULTQTYCHARGE = R_minAmount;
              END IF;*/

            SELECT
              'TRAP',
              R_rate,
              R_billMode;
            IF (R_billMode = 'MAXTRACE') THEN
              SET R_RESULTQTYCHARGE = v_max_TraceId;
            ELSEIF (R_billMode = 'MAXPL') THEN
              SET R_RESULTQTYCHARGE = v_max_MUID;
            ELSEIF (R_billMode = 'MAXQTY') THEN
              SET R_RESULTQTYCHARGE = v_max_qty;
            ELSEIF (R_billMode = 'AVGLOC') THEN
              SET R_RESULTQTYCHARGE = v_avg_TraceId;
            ELSEIF (R_billMode = 'AVGPL') THEN
              SET R_RESULTQTYCHARGE = v_avg_MUID;
            ELSEIF (R_billMode = 'AVGQTY') THEN
              SET R_RESULTQTYCHARGE = v_avg_qty;
            ELSEIF (R_billMode = 'MONTHTRACE') THEN
              SET R_RESULTQTYCHARGE = v_qty_TraceId;
            ELSEIF (R_billMode = 'MONTHLOC') THEN
              SET R_RESULTQTYCHARGE = v_qty_MUID;
            ELSEIF (R_billMode = 'MONTHPL') THEN
              SET R_RESULTQTYCHARGE = v_qty_MUID;
            ELSEIF (R_billMode = 'MONTHQTY') THEN
              SET R_RESULTQTYCHARGE = v_qty;
            ELSEIF (R_billMode = 'MAXCBM') THEN
              SET R_RESULTQTYCHARGE = v_max_qty_cbm;
            ELSEIF (R_billMode = 'INTRACE') THEN
              SET R_RESULTQTYCHARGE = v_qty_TraceId;
            END IF;


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

            #
            IF (R_billsummaryId = '') THEN
              SET @linenumber = 0;
              SET OUT_returnCode = '';
              CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);

              IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
                SET OUT_returnCode = '999#????????';
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
                v_organizationId,
                v_warehouseId,
                CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')),
                R_BILLINGDATE,
                R_BILLINGDATE,
                v_customerId,
                '',
                '',
                '',
                R_TARIFFID,
                R_CHARGECATEGORY,
                R_chargetype,
                R_descrC,
                --               '',
                R_rateBase,
                R_rateperunit,
                R_RESULTQTYCHARGE,
                '',
                0,
                0,
                R_rate,
                R_RESULTQTYCHARGE * R_rate / R_rateperunit,
                (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
                0,
                R_cost * R_RESULTQTYCHARGE,
                0,
                NOW() confirmTime,
                '' confirmWho,
                '',
                '',
                '' createTransactionid,
                '' notes,
                NOW() ediSendTime,
                v_customerId AS billTo,
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
                R_RESULTQTYCHARGE * R_rate / R_rateperunit incomeWithoutTax,
                0 cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                R_materialNo AS udf01,
                R_itemChargeCategory AS udf02,
                0 udf03,
                R_UDF06 udf04,
                '' udf05,
                0 currentVersion,
                '2020' oprSeqFlag,
                'CUSTOMBILL' addWho,
                NOW() ADDTIME,
                'CUSTOMBILL' editWho,
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
                '' orderType,
                '' containerType,
                '' containerSize;

          END IF; -- END IF docType

        END LOOP getTariff;
        CLOSE cur_Tariff;

      END;
    ELSE
      ITERATE read_loop;
    END IF;

  END LOOP;

  -- Close the cursor
  CLOSE my_cursor;

END
$$

--
-- Create procedure `CML_BILLHOSTD_TYPE2`
--
CREATE
DEFINER = 'it.ari'@'%'
PROCEDURE CML_BILLHOSTD_TYPE2 (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_trans_no varchar(30),
IN IN_tariffMaster varchar(30))
BEGIN
  ####################################################################
  ##????
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
  DECLARE R_RESULTQTYCHARGE decimal(24, 8);  -- add for calculation
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
  DECLARE R_BILLTO varchar(30);
  DECLARE R_NROW integer;
  DECLARE R_PALLETCNT varchar(30);
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
  DECLARE od_organizationId varchar(20);
  DECLARE od_orderNo varchar(20);
  DECLARE od_soReference1 varchar(255);
  DECLARE od_soReference3 varchar(255);
  DECLARE od_orderType varchar(255);
  DECLARE od_docType varchar(255);
  DECLARE od_docTypeDescr varchar(255);
  DECLARE od_soStatus varchar(255);
  DECLARE od_warehouseId varchar(255);
  DECLARE od_customerId varchar(255);
  DECLARE od_orderLineNo varchar(255);
  DECLARE od_SKU varchar(255);
  DECLARE od_ShipmentTime varchar(255);
  DECLARE od_qty varchar(255);
  DECLARE od_qty_each varchar(255);
  DECLARE od_qtyShipped_each varchar(255);
  DECLARE od_uom varchar(255);
  DECLARE od_qtyCharge varchar(255);
  DECLARE od_totalCube varchar(255);
  DECLARE od_editTime varchar(255);
  DECLARE od_lotNum varchar(255);
  DECLARE od_traceId varchar(255);
  DECLARE od_pickToTraceId varchar(255);
  DECLARE od_dropId varchar(255);
  DECLARE od_location varchar(255);
  DECLARE od_pickToLocation varchar(255);
  DECLARE od_line_transaction varchar(255);
  DECLARE od_skuDescr1 varchar(255);
  DECLARE od_grossWeight varchar(255);
  DECLARE od_cubeNya varchar(255);
  DECLARE od_tariffMasterId varchar(255);
  DECLARE od_QtyPerCases varchar(255);
  DECLARE od_QtyPerPallet varchar(255);
  DECLARE od_zone varchar(255);
  DECLARE od_batch varchar(255);
  DECLARE od_lotAtt07 varchar(255);
  DECLARE od_RecType varchar(21);
  DECLARE od_Billtranctg varchar(21);
  DECLARE OUT_returnCode varchar(1000);
  ####################################################################
  DECLARE od_qtyChargeEA varchar(255);
  DECLARE od_qtyChargeCS varchar(255);
  DECLARE od_qtyChargeIP varchar(255);
  DECLARE od_qtyChargePL varchar(255);
  DECLARE od_qtyChargeCBM varchar(255);
  DECLARE od_qtyChargeDropId varchar(255);
  DECLARE od_qtyChargeTotDO varchar(255);
  DECLARE od_qtyChargeTotLine varchar(255);
  DECLARE od_qtyChargeNettWeight varchar(255);/*additional nettweight Gross Weight ABYuhuu*/
  DECLARE od_qtyChargeGrossWeight varchar(255);
  DECLARE od_qtyChargeMetricTon varchar(255);
  DECLARE od_closetimetransaction datetime; /*additional close transaction by AKBAR */
  ####################################################################
  DECLARE sum_organizationId varchar(20);
  DECLARE sum_warehouseId varchar(20);
  DECLARE sum_customerId varchar(20);
  DECLARE sum_orderNo varchar(20);
  DECLARE sum_orderType varchar(255);
  DECLARE sum_soReference1 varchar(255);
  DECLARE sum_soReference3 varchar(255);
  DECLARE sum_tariffMasterId varchar(255);
  DECLARE sum_qtyChargeEA varchar(255);
  DECLARE sum_qtyChargeCS varchar(255);
  DECLARE sum_qtyChargeIP varchar(255);
  DECLARE sum_qtyChargePL varchar(255);
  DECLARE sum_qtyChargeCBM varchar(255);
  DECLARE sum_qtyChargeTotDO varchar(255);
  DECLARE sum_qtyChargeTotLine varchar(255);
  DECLARE sum_qtyChargeNettWeight varchar(255);/*additional nettweight Gross Weight ABYuhuu*/
  DECLARE sum_qtyChargeGrossWeight varchar(255);
  DECLARE sum_qtyChargeMetricTon varchar(255);
  ####################################################################

  ##????
  DECLARE inventory_done int DEFAULT FALSE;
  DECLARE tariff_done,
          tariff2_done int DEFAULT FALSE;
  DECLARE order_done,
          attribute_done boolean DEFAULT FALSE;
  DECLARE cur_orderno CURSOR FOR
  SELECT
    sumso.organizationId,
    sumso.warehouseId,
    sumso.customerId,
    sumso.orderNo,
    sumso.orderType,
    SUM(sumso.qtyChargeEA) AS qtyChargeEA,
    SUM(sumso.qtyChargeCS) AS qtyChargeCS,
    SUM(sumso.qtyChargeIP) AS qtyChargeIP,
    SUM(sumso.qtyChargePL) AS qtyChargePL,
    SUM(sumso.qtyChargeCBM) AS qtyChargeCBM,
    COUNT(sumso.qtyChargeDropId) AS qtyChargeDropId,
    COUNT(sumso.qtyChargeTotDO) AS qtyChargeTotDO,
    SUM(sumso.qtyChargeTotLine) AS qtyChargeTotLine,
    SUM(sumso.qtyChargeNettWeight) AS qtyChargeNettWeight,
    SUM(sumso.qtyChargeGrossWeight) AS qtyChargeGrossWeight,
    SUM(sumso.qtyChargeMetricTon) AS qtyChargeMetricTon,
    sumso.closeTime
  FROM (SELECT
      IFNULL(CAST(doh.organizationId AS char), '') AS organizationId,
      IFNULL(CAST(doh.orderNo AS char), '') AS orderNo,
      IFNULL(CAST(doh.orderType AS char(255)), '') AS orderType,
      IFNULL(CAST(doh.warehouseId AS char(255)), '') AS warehouseId,
      IFNULL(CAST(aad.customerId AS char(255)), '') AS customerId,
      IFNULL(CAST(SUM(aad.qty) AS char(255)), 0) AS qty,
      IFNULL(CAST(SUM(aad.qty_each) AS char(255)), 0) AS qty_each,
      IFNULL(CAST(SUM(aad.qtyShipped_each) AS char(255)), 0) AS qtyShipped_each,
      IFNULL(CAST(SUM(aad.qtyShipped_each / bpdEA.qty) AS char(255)), 0) AS qtyChargeEA,
      IFNULL(CAST(CEIL(SUM(aad.qtyShipped_each / bpdCS.qty)) AS char(255)), 0) AS qtyChargeCS,
      IFNULL(CAST(CEIL(SUM(aad.qtyShipped_each / bpdIP.qty)) AS char(255)), 0) AS qtyChargeIP,
      IFNULL(CAST(CEIL(SUM(aad.qtyShipped_each / bpdPL.qty)) AS char(255)), 0) AS qtyChargePL,
      IFNULL(CAST(SUM(aad.qtyShipped_each * bs.cube) AS char(255)), 0) AS qtyChargeCBM,
      IFNULL(CAST(COUNT(DISTINCT aad.dropId) AS char(255)), 0) AS qtyChargeDropId,
      IFNULL(CAST(COUNT(DISTINCT doh.orderNo) AS char(255)), 0) AS qtyChargeTotDO,
      IFNULL(CAST(COUNT(DISTINCT aad.orderLineNo) AS char(255)), 0) AS qtyChargeTotLine,
      IFNULL(CAST(SUM(aad.qtyShipped_each * bs.cube) AS char(255)), 0) AS totalCube,
      IFNULL(CAST(SUM(aad.qtyShipped_each * bs.grossWeight) AS char(255)), 0) AS qtyChargeGrossWeight,
      IFNULL(CAST(SUM(bs.cube) AS char(255)), 0) AS cubeNya,
      IFNULL(CAST(SUM(aad.qtyShipped_each * bs.netWeight) AS char(255)), 0) AS qtyChargeNettWeight,
      CASE WHEN aad.customerId LIKE '%ABC%' THEN IFNULL(CAST(SUM((aad.qtyShipped_Each * bpdCS.qty) / 1000) AS char(255)), 0) ELSE IFNULL(CAST(SUM(aad.qtyShipped_Each / 1000) AS char(255)), 0) END AS qtyChargeMetricTon,
      df.closeTime
    /*additional nettweight Gross Weight ABYuhuu*/
    FROM ACT_ALLOCATION_DETAILS aad
      LEFT OUTER JOIN DOC_ORDER_HEADER doh
        ON doh.organizationId = aad.organizationId
        AND doh.customerId = aad.customerId
        AND doh.orderNo = aad.orderNo
      LEFT JOIN DOC_ORDER_HEADER_UDF df
        ON (doh.organizationId = df.organizationId)
        AND doh.warehouseId = df.warehouseId
        AND doh.orderNo = df.orderNo
      LEFT OUTER JOIN BAS_SKU bs
        ON bs.organizationId = aad.organizationId
        AND bs.SKU = aad.SKU
        AND bs.customerId = aad.customerId
      LEFT OUTER JOIN BAS_SKU_MULTIWAREHOUSE bsm
        ON bsm.organizationId = bs.organizationId
        AND bsm.SKU = bs.SKU
        AND bsm.customerId = bs.customerId
        AND bsm.warehouseId = aad.warehouseId
      /*      LEFT OUTER JOIN INV_LOT_ATT ila
              ON ila.organizationId = aad.organizationId
              AND ila.SKU = aad.SKU
              AND ila.lotnum = aad.lotnum
              AND ila.customerId = aad.customerId*/
      LEFT JOIN BAS_PACKAGE_DETAILS bpdEA
        ON bpdEA.organizationId = bs.organizationId
        AND bpdEA.packId = bs.packId
        AND bpdEA.customerId = bs.customerId
        AND bpdEA.packUom = 'EA'
      LEFT JOIN BAS_PACKAGE_DETAILS bpdIP
        ON bpdIP.organizationId = bs.organizationId
        AND bpdIP.packId = bs.packId
        AND bpdIP.customerId = bs.customerId
        AND bpdIP.packUom = 'IP'
      LEFT JOIN BAS_PACKAGE_DETAILS bpdCS
        ON bpdCS.organizationId = bs.organizationId
        AND bpdCS.packId = bs.packId
        AND bpdCS.customerId = bs.customerId
        AND bpdCS.packUom = 'CS'
      LEFT JOIN BAS_PACKAGE_DETAILS bpdPL
        ON bpdPL.organizationId = bs.organizationId
        AND bpdPL.packId = bs.packId
        AND bpdPL.customerId = bs.customerId
        AND bpdPL.packUom = 'PL'
      LEFT JOIN BSM_CODE_ML t1
        ON t1.organizationId = aad.organizationId
        AND t1.codeType = 'SO_TYP'
        AND t1.codeId = doh.orderType
        AND t1.languageId = 'en'
      LEFT JOIN BAS_LOCATION bl
        ON bl.organizationId = aad.organizationId
        AND bl.warehouseId = aad.warehouseId
        AND bl.locationId = aad.location
      LEFT JOIN BAS_ZONE bz
        ON bz.organizationId = bl.organizationId
        AND bz.warehouseId = bl.warehouseId
        AND bz.zoneId = bl.zoneId
        AND bz.zoneGroup = bl.zoneGroup
    WHERE aad.organizationId = IN_organizationId
    AND aad.customerId = IN_CustomerId
    AND aad.warehouseId = IN_warehouseId
    AND doh.orderNo = IN_trans_no
    AND aad.Status IN ('99', '80')
    AND bs.skuDescr1 NOT LIKE '%PALLET%'
    AND aad.sku NOT IN (SELECT
        sku
      FROM Z_SKUNOTBILLING zsnb
      WHERE organizationId = aad.organizationId
      AND customerId = aad.customerId)
    /* AND aad.sku NOT IN ('DEMOTABLEAT',
        'DEMOTABLESAM',
        'HOTSTAMP',
        'COLLATERAL-COLLECTABLESTICKER',
        'HELLOBASTC',
        'MAMALOVSTC',
        'MAMANOUSTC',
        'MAMAPCK02',
        'STCMCBMS-TH',
        'BUMILTSTC2',
        'COLLATERAL-STICKERPINK',
        'PRINCTSTC3',
        'PRINCTSTC3',
        'PINKBOX03P',
        'YFI001',
        'MAMASTT',
        'TAP-COMBOX',
        'MAMABOXPINK',
        'MAMABOX01',
        'MAMABOX02',
        'BIGBOX5',
        'COLLATERAL-PIZZABOX',
        'MAMABOX01',
        'MAMABOX02',
        'MEDIUMBOX4',
        'SMALLBOX',
        'GRTGCRD',
        'BUNBUNSTC01',
        'BUNBUNSTC02',
        'CONGRATSTC1',
        'MAMAMWTH',
        'STCABS-MY',
        'STCABS-TH',
        'STCANTCOLIC-BIG-TH',
        'STCANTCOLIC-SMALL-TH',
        'STCAPCN',
        'STCGFW-VN', -- add 26-05-25  akbar
        'STCAPRCMMY',
        'STCAPRCMY',
        'STCAPRCTH',
        'STCAPRCTH-DIR',
        'STCAPRCTH-NIG',
        'STCAPRCTH-NUT',
        'STCAPRMMY',
        'STCAPRMTH',
        'STCAPRMTH-DIR',
        'STCAPRMTH-NIG',
        'STCAPRMTH-NUT',
        'STCBFS-PH',
        'STCBHABMY',
        'STCBHABTH',
        'STCBHABWPH',
        'STCBHABWTH',
        'STCBPOMSC',
        'STCDC-TH',
        'STCDCIC-TH',
        'STCDCPH',
        'STCDCW-TH',
        'STCDPFMPH',
        'STCDPFMPH-TH',
        'STCDSDTH',
        'STCEBPTH',
        'STCFWID',
        'STCGBSID',
        'STCGBSMY',
        'STCGBSTH',
        'STCGFW-MY',
        'STCGFWPH',
        'STCGFWTH',
        'STCHPSEATCR',
        'STCINCMY',
        'STCKTP-PH',
        'STCKTPBGTH',
        'STCKTPBID',
        'STCKTPEN',
        'STCKTPSID',
        'STCKTPSTH',
        'STCMCDNFC-ID',
        'STCMCDNFC-MY',
        'STCMCDNFC-PH',
        'STCMCDNFC-SG',
        'STCMCDNFC-TH',
        'STCMCDSD-EN',
        'STCMCDSD-MY',
        'STCMCDSD-SG',
        'STCMCDSD-TH',
        'STCMCHVL-MY',
        'STCMCHVL-PH',
        'STCMCHVL-SG',
        'STCMCHVL-TH',
        'STCMCHVLTH',
        'STCMCMBP-TH',
        'STCMCPH',
        'STCMCSHS-MY',
        'STCMCSHS-PH',
        'STCMCSHS-SG',
        'STCMCSHS-TH',
        'STCMCSVL-ID',
        'STCMCSVL-MY',
        'STCMCTH',
        'STCMCWBP-TH',
        'STCMHG-PH',
        'STCMOSPL-SG',
        'STCMSMY',
        'STCMSTH',
        'STCMWPH',
        'STCMWSG',
        'STCMWTH',
        'STCNCPH',
        'STCNCSG',
        'STCNCTH',
        'STCREVIMSK-TH',
        'STCRFW-MY',
        'STCRFW-TH',
        'STCRMOMY',
        'STCRMOPH',
        'STCRMOTH',
        'STCSMRPH',
        'STCSOOTHMSK-TH',
        'STCSPL-PH',
        'STCSPL-SG',
        'STCTC-TH',
        'STCTCA-TH',
        'STCTCI-TH',
        'STCTCID',
        'STCTCMY',
        'STCTCPH',
        'STCTCSG',
        'STCTO',
        'STCTO-ID',
        'STCTO-PH',
        'STCTPPH',
        'STCTPSG',
        'STCTPTH',
        'STCTSA-TH',
        'STCTSI-TH',
        'STCTSMY',
        'STCTSPH',
        'STCTSSG',
        'STCTTH',
        'STCCAS-ID',
        'STCHIPSEATMI',
        'AMLBL-TH',
        'CFBC-TH',
        'STCABIZNEDR150',
        'STCABIZNEDR250',
        'STCAL-TH-L/XL',
        'STCAL-TH-S/M',
        'STCAPCI-TH',
        'STCAPMI-TH',
        'STCAWN-TH',
        'STCCAS-ID',
        'STCEBPIZNEDR',
        'STCMBPIZNEDR',
        'STCMCSVL-TH',
        'STCMTPID',
        'STCNCMU',
        'STCOLIVE-TH',
        'STCTBRIZNEDR',
        'STDCDR-TH',
        'GRCRDT3',
        'PINKBOX03P',
        'TAP-COMBOX',
        'MAMABOXPINK',
        'STCABS-VN',
        'STCDPFM-VN',
        'STCKTPS-VN',
        'STCMCDSD-VN',
        'STCMCHVL-VN',
        'STCMCSHS-VN',
        'STCRC-VN',
        'STCABSIG-VN',
        'STCABSMNF-VN',
        'STCAPMNF-VN',
        'STCAPSIG-VN',
        'STCTPIG-VN',
        'STCTPMNF-VN',
        'STCACP-VN',
        'STCAMP-VN',
        'STCAPL-VN',
        'STCBNS-VN',
        'STCFBTPTH',
        'STCGS-VN',
        'STCHVLIGT-VN',
        'STCHVLMNF-VN',
        'STCINC-VN',
        'STCMITPTH',
        'STCMT-VN',
        'STCNFC-VN',
        'STCRFW-VN',
        'STCSMC-VN',
        'STCSMS-VN',
        'STCTMTH',
    	'SMALL BOX',
    	'STCBSBCCREAMXXLVN',
    'STCFHRCPINKVN',
    'STCFHRCYELLOWVN',
    'STCFRSTBRSHVN',
    'STCFRSTBRSPNKVN',
    'STCHCBLUEVN',
    'STCHGGINGBLUVN',
    'STCHGGINGPNKVN',
    'STCHGGINGWHTVN',
    'STCHIPSEATTRQSVN',
    'STCMNBCREAMLVN',
    'STCMNBCREAMMVN',
    'STCMNBLACKXLVN',
    'STCNANOCRSTS/MVN',
    'STCPAACCREAM3XLVN',
    'STCPACBLACK3XLVN',
    'STCPACCREAMLVN',
    'STCPREGBELTCVN',
    'STCPREGBELTVN',
    'STCSPBMBLACKVN',
    'STCSPBXLBLACKVN',
    'STCWBPADVN','STCMACAV','STCMCBBLCK','STCMCBCRM'
    ) 
    */
    /*AB-update sku take out base on handing out ls-11-09-24*/
    AND doh.orderType NOT IN ('FREE', 'KT', 'TROF', 'TTG') /*AB-update so type base on handing out ls-11-09-24*/

    GROUP BY doh.organizationId,
             doh.orderNo,
             doh.orderType,
             doh.warehouseId,
             aad.dropId,
             aad.customerId,
             df.closeTime) sumso
  GROUP BY organizationId,
           warehouseId,
           customerId,
           orderType,
           closeTime,
           orderNo;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET order_done = TRUE;
  OPEN cur_orderno;
cur_order_loop:
  LOOP
    FETCH FROM cur_orderno INTO od_organizationId,
    od_warehouseId,
    od_customerId,
    od_orderNo,
    od_orderType,
    -- od_soReference1,
    -- od_soReference3,
    --   od_tariffMasterId,
    od_qtyChargeEA,
    od_qtyChargeCS,
    od_qtyChargeIP,
    od_qtyChargePL,
    od_qtyChargeCBM,
    od_qtyChargeDropId,
    od_qtyChargeTotDO,
    od_qtyChargeTotLine,
    od_qtyChargeNettWeight,
    od_qtyChargeGrossWeight,
    od_qtyChargeMetricTon,
    od_closetimetransaction;
    /*additional close transaction by AKBAR */

    IF order_done THEN
      SET order_done = FALSE;
      LEAVE cur_order_loop;
    END IF;
    IF NOT EXISTS (SELECT
          1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = od_organizationId
        AND bs.warehouseId = od_warehouseId
        AND bs.docNo = od_orderNo
        AND bs.chargeCategory = 'OB') THEN

    BLOCK2:
      BEGIN

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
          -- btd.udf05,
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
          btd.billingParty,
          IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
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
        --        AND bth.tariffMasterId = od_tariffMasterId
        AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND btd.chargeCategory = 'OB'
        AND btd.docType = od_orderType
        -- AND btr.rate > 0
        #AND IFNULL(DAY(bth.billingdate),0)!=0 
        ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = TRUE;
        ####################################################################


        SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd
        #
        OPEN cur_Tariff;
      getTariff:
        LOOP
          FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
          R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
          R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;
          IF tariff_done THEN
            SET tariff_done = FALSE;
            LEAVE getTariff;
          END IF;


          -- ADDING AKBAR RULE => JIKA BILLING CATEGORY TIDAK DI SETUP DI BILING SETUP, SKIP VALIDASI 07.03.2024

          /* IF R_BILLINGTRANCATEGORY IS NULL
             OR R_BILLINGTRANCATEGORY = '' THEN
             SET R_BILLINGTRANCATEGORY = od_Billtranctg;
           END IF;*/

          IF (RTRIM(LTRIM(od_orderType)) = RTRIM(LTRIM(R_docType))) THEN
            -- AND (RTRIM(LTRIM(od_Billtranctg)) = RTRIM(LTRIM(R_BILLINGTRANCATEGORY))) THEN

            SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
            SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');


            SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
            SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);

            SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
            SET R_billsummaryId = '';


            IF (R_ratebase = 'CUBIC') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeCBM;
            ELSEIF (R_ratebase = 'M2') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeEA;
            ELSEIF (R_ratebase = 'IP') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeIP;
            ELSEIF (R_ratebase = 'KG') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeEA;
            ELSEIF (R_ratebase = 'LITER') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeEA;
            ELSEIF (R_ratebase = 'QUANTITY') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeEA;
            ELSEIF (R_ratebase = 'DO') THEN
              SET R_RESULTQTYCHARGE = CEILING(od_qtyChargeEA / R_CLASSTO);
            ELSEIF (R_ratebase = 'PALLET') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargePL;
            ELSEIF (R_ratebase = 'NETWEIGHT') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeNettWeight;
            ELSEIF (R_ratebase = 'GW') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeGrossWeight; /*additional nettweight Gross Weight ABYuhuu*/
            ELSEIF (R_ratebase = 'DID') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeDropId; /*additional nettweight Gross Weight ABYuhuu*/
            ELSEIF (R_ratebase = 'DID1') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeDropId; /*additional nettweight Gross Weight ABYuhuu*/
            ELSEIF (R_ratebase = 'MT') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeMetricTon;
            END IF;

            SELECT
              ' check=> ',
              od_qtyChargeEA,
              R_CLASSTO,
              R_RESULTQTYCHARGE,
              R_TARIFFID,
              R_ratebase;


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
              CALL SPCOM_GetIDSequence_NEW('OJV_CML', '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);
              IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
                SET OUT_returnCode = '999#????????';
                LEAVE getTariff;
              END IF;
            END IF;

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
                DATE_FORMAT(od_closetimetransaction, '%Y-%m-%d'),
                DATE_FORMAT(od_closetimetransaction, '%Y-%m-%d'),
                od_customerId,
                '' sku,
                '' lotNum,
                '' traceId,
                R_TARIFFID,
                R_CHARGECATEGORY,
                R_chargetype,
                R_descrC,
                R_rateBase,
                R_rateperunit,
                R_RESULTQTYCHARGE qtyShipped_each,
                '' uom,
                od_totalCube totalCube,
                0 grossWeight,
                R_rate,
                R_RESULTQTYCHARGE * R_rate / R_rateperunit,
                (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
                0,
                R_cost * R_RESULTQTYCHARGE,
                0,
                NOW() confirmTime,
                '' confirmWho,
                'SO',
                od_orderNo,
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
                R_RESULTQTYCHARGE * R_rate / R_rateperunit incomeWithoutTax,
                0 cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                R_materialNo AS udf01,
                R_itemChargeCategory AS udf02,
                R_UDF08 udf03,
                R_UDF06 udf04,
                '' udf05,
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
                od_orderType orderType,
                '' containerType,
                '' containerSize;

          END IF; -- END IF docType



        END LOOP getTariff;
        CLOSE cur_Tariff;
      END;
    END IF;
  END LOOP cur_order_loop;
  CLOSE cur_orderno;
  SET OUT_returnCode = '000';
END
$$

--
-- Create procedure `CML_BILLHOSTD`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLHOSTD (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_trans_no varchar(30),
IN IN_tariffMaster varchar(30))
BEGIN
  ####################################################################
  ##????
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
  DECLARE R_RESULTQTYCHARGE decimal(24, 8);  -- add for calculation
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
  DECLARE R_BILLTO varchar(30);
  DECLARE R_NROW integer;
  DECLARE R_PALLETCNT varchar(30);
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
  DECLARE od_organizationId varchar(20);
  DECLARE od_orderNo varchar(20);
  DECLARE od_soReference1 varchar(255);
  DECLARE od_soReference3 varchar(255);
  DECLARE od_orderType varchar(255);
  DECLARE od_docType varchar(255);
  DECLARE od_docTypeDescr varchar(255);
  DECLARE od_soStatus varchar(255);
  DECLARE od_warehouseId varchar(255);
  DECLARE od_customerId varchar(255);
  DECLARE od_orderLineNo varchar(255);
  DECLARE od_SKU varchar(255);
  DECLARE od_ShipmentTime varchar(255);
  DECLARE od_qty varchar(255);
  DECLARE od_qty_each varchar(255);
  DECLARE od_qtyShipped_each varchar(255);
  DECLARE od_uom varchar(255);
  DECLARE od_qtyCharge varchar(255);
  DECLARE od_totalCube varchar(255);
  DECLARE od_editTime varchar(255);
  DECLARE od_lotNum varchar(255);
  DECLARE od_traceId varchar(255);
  DECLARE od_pickToTraceId varchar(255);
  DECLARE od_dropId varchar(255);
  DECLARE od_location varchar(255);
  DECLARE od_pickToLocation varchar(255);
  DECLARE od_allocationDetailsId varchar(255);
  DECLARE od_skuDescr1 varchar(255);
  DECLARE od_grossWeight varchar(255);
  DECLARE od_cubeNya varchar(255);
  DECLARE od_tariffMasterId varchar(255);
  DECLARE od_QtyPerCases varchar(255);
  DECLARE od_QtyPerPallet varchar(255);
  DECLARE od_zone varchar(255);
  DECLARE od_batch varchar(255);
  DECLARE od_lotAtt07 varchar(255);
  DECLARE od_RecType varchar(21);
  DECLARE od_Billtranctg varchar(21);
  DECLARE OUT_returnCode varchar(1000);
  ####################################################################
  DECLARE od_qtyChargeEA varchar(255);
  DECLARE od_qtyChargeCS varchar(255);
  DECLARE od_qtyChargeIP varchar(255);
  DECLARE od_qtyChargePL varchar(255);
  DECLARE od_qtyChargeCBM varchar(255);
  DECLARE od_qtyChargeTotDO varchar(255);
  DECLARE od_qtyChargeTotLine varchar(255);
  DECLARE od_qtyChargeNettWeight varchar(255);/*additional nettweight Gross Weight ABYuhuu*/
  DECLARE od_qtyChargeGrossWeight varchar(255);
  DECLARE od_qtyChargeMetricTon varchar(255);
  DECLARE od_closetimetransaction datetime; /*additional close transaction by AKBAR */
  DECLARE od_line_transaction varchar(255); /*additional line id unique transaction 02.07.2024 */
  ####################################################################

  ##????
  DECLARE inventory_done int DEFAULT FALSE;
  DECLARE tariff_done int DEFAULT FALSE;
  DECLARE order_done,
          attribute_done boolean DEFAULT FALSE;
  DECLARE cur_orderno CURSOR FOR
  SELECT
    IFNULL(CAST(doh.organizationId AS char), '') AS organizationId,
    IFNULL(CAST(doh.orderNo AS char), '') AS orderNo,
    IFNULL(CAST(doh.soReference1 AS char(255)), '') AS soReference1,
    IFNULL(CAST(doh.soReference3 AS char(255)), '') AS soReference3,
    IFNULL(CAST(doh.orderType AS char(255)), '') AS orderType,
    IFNULL(CAST(t1.codeType AS char(255)), '') AS docType,
    IFNULL(CAST(t1.codeDescr AS char(255)), '') AS docTypeDescr,
    IFNULL(CAST(doh.soStatus AS char(255)), '') AS soStatus,
    IFNULL(CAST(doh.warehouseId AS char(255)), '') AS warehouseId,
    IFNULL(CAST(aad.customerId AS char(255)), '') AS customerId,
    IFNULL(CAST(aad.orderLineNo AS char(255)), 0) AS orderLineNo,
    IFNULL(CAST(aad.SKU AS char(255)), '') AS SKU,
    CAST(DATE_FORMAT(aad.shipmentTime, '%Y-%m-%d') AS char(255)) AS ShipmentTime,
    IFNULL(CAST(aad.qty AS char(255)), 0) AS qty,
    IFNULL(CAST(aad.qty_each AS char(255)), 0) AS qty_each,
    IFNULL(CAST(aad.qtyShipped_each AS char(255)), 0) AS qtyShipped_each,
    IFNULL(CAST(aad.uom AS char(255)), '') AS uom,
    CASE WHEN aad.customerId IN ('MAP') AND
        ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
        bsm.tariffMasterId LIKE '%PIECE%' THEN IFNULL(CAST(SUM(aad.qtyShipped_each / bpdEA.qty) AS char(255)), 0) ELSE IFNULL(CAST(SUM(aad.qtyShipped_each / bpdEA.qty) AS char(255)), 0) END AS qtyChargeEA,
    IFNULL(CAST(CEIL(SUM(aad.qtyShipped_each / bpdCS.qty)) AS char(255)), 0) AS qtyChargeCS,
    IFNULL(CAST(CEIL(SUM(aad.qtyShipped_each / bpdIP.qty)) AS char(255)), 1) AS qtyChargeIP,
    IFNULL(CAST(CEIL(SUM(aad.qtyShipped_each / bpdPL.qty)) AS char(255)), 0) AS qtyChargePL,
    CASE WHEN aad.customerId IN ('MAP') AND
        ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
        bsm.tariffMasterId NOT LIKE '%PIECE%' THEN IFNULL(CAST(SUM(aad.qtyShipped_each * bs.cube) AS char(255)), 0) ELSE IFNULL(CAST(SUM(aad.qtyShipped_each * bs.cube) AS char(255)), 0) END AS qtyChargeCBM,
    IFNULL(CAST(COUNT(doh.orderNo) AS char(255)), 0) AS qtyChargeTotDO,
    IFNULL(CAST(COUNT(aad.orderLineNo) AS char(255)), 0) AS qtyChargeTotLine,
    IFNULL(CAST((SUM(aad.qtyShipped_each * bs.cube)) AS char(255)), 0) AS totalCube,
    IFNULL(CAST(aad.editTime AS char(255)), '') AS editTime,
    IFNULL(CAST(aad.lotNum AS char(255)), '') AS lotNum,
    IFNULL(CAST(aad.traceId AS char(255)), '') AS traceId,
    IFNULL(CAST(aad.pickToTraceId AS char(255)), '') AS pickToTraceId,
    IFNULL(CAST(aad.dropId AS char(255)), '') AS dropId,
    IFNULL(CAST(aad.location AS char(255)), '') AS location,
    IFNULL(CAST(aad.pickToLocation AS char(255)), '') AS pickToLocation,
    IFNULL(CAST(aad.allocationDetailsId AS char(255)), '') AS allocationDetailsId,
    IFNULL(CAST(bs.skuDescr1 AS char(255)), '') AS skuDescr1,
    IFNULL(CAST(bs.grossWeight AS char(255)), 0) AS grossWeight,
    IFNULL(CAST(bs.cube AS char(255)), 0) AS cubeNya,
    IFNULL(CAST(bsm.tariffMasterId AS char(255)), '') AS tariffMasterId,
    IFNULL(CAST(bpdCS.qty AS char(255)), 0) AS QtyPerCases,
    IFNULL(CAST(bpdPL.qty AS char(255)), 0) AS QtyPerPallet,
    IFNULL(CAST(bz.zoneDescr AS char(255)), '') AS zone,
    IFNULL(CAST(ila.lotAtt04 AS char(255)), '') AS batch,
    IFNULL(CAST(ila.lotAtt07 AS char(255)), '') AS lotAtt07,
    IFNULL(CAST(BT.codeid AS char(255)), '') AS billtranctg,
    IFNULL(CAST(SUM(aad.qtyShipped_each * bs.netWeight) AS char(255)), 0) AS qtyChargeNettWeight,
    CASE WHEN bpdEA.uomdescr IN ('G', 'GRAM', 'Gram') THEN IFNULL(CAST(SUM(aad.qtyShipped_each / 1000) AS char(255)), 0) WHEN bpdEA.uomdescr IN ('MT', 'Metric Ton', 'METRIC TON') THEN IFNULL(CAST(SUM(aad.qtyShipped_each * 1000) AS char(255)), 0) ELSE IFNULL(CAST(SUM(aad.qtyShipped_each * bs.grossWeight) AS char(255)), 0) END AS qtyChargeGrossWeight,
    CASE WHEN aad.customerId LIKE '%ABC%' THEN IFNULL(CAST(SUM((aad.qtyShipped_Each * bpdCS.qty) / 1000) AS char(255)), 0) ELSE IFNULL(CAST(SUM(aad.qtyShipped_Each / 1000) AS char(255)), 0) END AS qtyChargeMetricTon,
    df.closeTime,
    aad.allocationDetailsId AS line_trans -- add transaction line
  /*additional nettweight Gross Weight ABYuhuu*/
  FROM ACT_ALLOCATION_DETAILS aad
    LEFT OUTER JOIN DOC_ORDER_HEADER doh
      ON doh.organizationId = aad.organizationId
      AND doh.customerId = aad.customerId
      AND doh.orderNo = aad.orderNo
    LEFT JOIN DOC_ORDER_HEADER_UDF df
      ON (doh.organizationId = df.organizationId)
      AND doh.warehouseId = df.warehouseId
      AND doh.orderNo = df.orderNo
    LEFT OUTER JOIN BAS_SKU bs
      ON bs.organizationId = aad.organizationId
      AND bs.SKU = aad.SKU
      AND bs.customerId = aad.customerId
    LEFT OUTER JOIN BAS_SKU_MULTIWAREHOUSE bsm
      ON bsm.organizationId = bs.organizationId
      AND bsm.SKU = bs.SKU
      AND bsm.customerId = bs.customerId
      AND bsm.warehouseId = aad.warehouseId
    LEFT OUTER JOIN INV_LOT_ATT ila
      ON ila.organizationId = aad.organizationId
      AND ila.SKU = aad.SKU
      AND ila.lotnum = aad.lotnum
      AND ila.customerId = aad.customerId
    LEFT JOIN BAS_PACKAGE_DETAILS bpdEA
      ON bpdEA.organizationId = bs.organizationId
      AND bpdEA.packId = bs.packId
      AND bpdEA.customerId = bs.customerId
      AND bpdEA.packUom = 'EA'
    LEFT JOIN BAS_PACKAGE_DETAILS bpdIP
      ON bpdIP.organizationId = bs.organizationId
      AND bpdIP.packId = bs.packId
      AND bpdIP.customerId = bs.customerId
      AND bpdIP.packUom = 'IP'
    LEFT JOIN BAS_PACKAGE_DETAILS bpdCS
      ON bpdCS.organizationId = bs.organizationId
      AND bpdCS.packId = bs.packId
      AND bpdCS.customerId = bs.customerId
      AND bpdCS.packUom = 'CS'
    LEFT JOIN BAS_PACKAGE_DETAILS bpdPL
      ON bpdPL.organizationId = bs.organizationId
      AND bpdPL.packId = bs.packId
      AND bpdPL.customerId = bs.customerId
      AND bpdPL.packUom = 'PL'
    LEFT JOIN BSM_CODE_ML t1
      ON t1.organizationId = aad.organizationId
      AND t1.codeType = 'SO_TYP'
      AND t1.codeId = doh.orderType
      AND t1.languageId = 'en'
    LEFT JOIN BSM_CODE BT
      ON BT.organizationId = aad.organizationId
      AND BT.codeType = 'BILLING_TRANSACTION_CATEGORY'
      AND BT.outerCode = ila.lotAtt07
    LEFT JOIN BAS_LOCATION bl
      ON bl.organizationId = aad.organizationId
      AND bl.warehouseId = aad.warehouseId
      AND bl.locationId = aad.location
    LEFT JOIN BAS_ZONE bz
      ON bz.organizationId = bl.organizationId
      AND bz.warehouseId = bl.warehouseId
      AND bz.zoneId = bl.zoneId
      AND bz.zoneGroup = bl.zoneGroup
  WHERE aad.organizationId = IN_organizationId
  AND aad.customerId = IN_CustomerId
  AND aad.warehouseId = IN_warehouseId
  AND doh.orderNo = IN_trans_no
  -- AND bsm.tariffMasterId = IN_tariffMaster
  -- AND DATE_FORMAT(aad.shipmentTime, '%Y-%m-%d') >= '2023-09-10'
  --  AND DATE_FORMAT(aad.shipmentTime, '%Y-%m-%d') <= '2023-09-12'
  AND aad.Status IN ('99', '80')
  AND bs.skuDescr1 NOT LIKE '%PALLET%'
  AND aad.sku NOT IN (SELECT
      sku
    FROM Z_SKUNOTBILLING zsnb
    WHERE organizationId = aad.organizationId
    AND customerId = aad.customerId)
  /*  AND aad.sku NOT IN ('DEMOTABLEAT',
    'DEMOTABLESAM',
    'HOTSTAMP',
    'COLLATERAL-COLLECTABLESTICKER',
    'HELLOBASTC',
    'MAMALOVSTC',
    'MAMANOUSTC',
    'MAMAPCK02',
    'STCMCBMS-TH',
    'BUMILTSTC2',
    'COLLATERAL-STICKERPINK',
    'PRINCTSTC3',
    'PRINCTSTC3',
    'PINKBOX03P',
    'YFI001',
    'MAMASTT',
    'TAP-COMBOX',
    'MAMABOXPINK',
    'MAMABOX01',
    'MAMABOX02',
    'BIGBOX5',
    'COLLATERAL-PIZZABOX',
    'MAMABOX01',
    'MAMABOX02',
    'MEDIUMBOX4',
    'SMALLBOX',
    'GRTGCRD',
    'BUNBUNSTC01',
    'BUNBUNSTC02',
    'CONGRATSTC1',
    'MAMAMWTH',
    'STCABS-MY',
    'STCABS-TH',
    'STCANTCOLIC-BIG-TH',
    'STCANTCOLIC-SMALL-TH',
    'STCAPCN',
    'STCAPRCMMY',
    'STCAPRCMY',
    'STCAPRCTH',
    'STCAPRCTH-DIR',
    'STCAPRCTH-NIG',
    'STCAPRCTH-NUT',
    'STCAPRMMY',
    'STCAPRMTH',
    'STCAPRMTH-DIR',
    'STCAPRMTH-NIG',
    'STCAPRMTH-NUT',
    'STCBFS-PH',
    'STCBHABMY',
    'STCBHABTH',
    'STCBHABWPH',
    'STCBHABWTH',
    'STCBPOMSC',
    'STCDC-TH',
    'STCDCIC-TH',
    'STCDCPH',
    'STCDCW-TH',
    'STCDPFMPH',
     'STCGFW-VN', -- add 26-05-25  akbar
    'STCDPFMPH-TH',
    'STCDSDTH',
    'STCEBPTH',
    'STCFWID',
    'STCGBSID',
    'STCGBSMY',
    'STCGBSTH',
    'STCGFW-MY',
    'STCGFWPH',
    'STCGFWTH',
    'STCHPSEATCR',
    'STCINCMY',
    'STCKTP-PH',
    'STCKTPBGTH',
    'STCKTPBID',
    'STCKTPEN',
    'STCKTPSID',
    'STCKTPSTH',
    'STCMCDNFC-ID',
    'STCMCDNFC-MY',
    'STCMCDNFC-PH',
    'STCMCDNFC-SG',
    'STCMCDNFC-TH',
    'STCMCDSD-EN',
    'STCMCDSD-MY',
    'STCMCDSD-SG',
    'STCMCDSD-TH',
    'STCMCHVL-MY',
    'STCMCHVL-PH',
    'STCMCHVL-SG',
    'STCMCHVL-TH',
    'STCMCHVLTH',
    'STCMCMBP-TH',
    'STCMCPH',
    'STCMCSHS-MY',
    'STCMCSHS-PH',
    'STCMCSHS-SG',
    'STCMCSHS-TH',
    'STCMCSVL-ID',
    'STCMCSVL-MY',
    'STCMCTH',
    'STCMCWBP-TH',
    'STCMHG-PH',
    'STCMOSPL-SG',
    'STCMSMY',
    'STCMSTH',
    'STCMWPH',
    'STCMWSG',
    'STCMWTH',
    'STCNCPH',
    'STCNCSG',
    'STCNCTH',
    'STCREVIMSK-TH',
    'STCRFW-MY',
    'STCRFW-TH',
    'STCRMOMY',
    'STCRMOPH',
    'STCRMOTH',
    'STCSMRPH',
    'STCSOOTHMSK-TH',
    'STCSPL-PH',
    'STCSPL-SG',
    'STCTC-TH',
    'STCTCA-TH',
    'STCTCI-TH',
    'STCTCID',
    'STCTCMY',
    'STCTCPH',
    'STCTCSG',
    'STCTO',
    'STCTO-ID',
    'STCTO-PH',
    'STCTPPH',
    'STCTPSG',
    'STCTPTH',
    'STCTSA-TH',
    'STCTSI-TH',
    'STCTSMY',
    'STCTSPH',
    'STCTSSG',
    'STCTTH',
    'STCCAS-ID',
    'STCHIPSEATMI',
    'AMLBL-TH',
    'CFBC-TH',
    'STCABIZNEDR150',
    'STCABIZNEDR250',
    'STCAL-TH-L/XL',
    'STCAL-TH-S/M',
    'STCAPCI-TH',
    'STCAPMI-TH',
    'STCAWN-TH',
    'STCCAS-ID',
    'STCEBPIZNEDR',
    'STCMBPIZNEDR',
    'STCMCSVL-TH',
    'STCMTPID',
    'STCNCMU',
    'STCOLIVE-TH',
    'STCTBRIZNEDR',
    'STDCDR-TH',
    'GRCRDT3',
    'PINKBOX03P',
    'TAP-COMBOX',
    'MAMABOXPINK',
    'STCABS-VN',
    'STCDPFM-VN',
    'STCKTPS-VN',
    'STCMCDSD-VN',
    'STCMCHVL-VN',
    'STCMCSHS-VN',
    'STCRC-VN',
    'STCABSIG-VN',
    'STCABSMNF-VN',
    'STCAPMNF-VN',
    'STCAPSIG-VN',
    'STCTPIG-VN',
    'STCTPMNF-VN',
    'STCACP-VN',
    'STCAMP-VN',
    'STCAPL-VN',
    'STCBNS-VN',
    'STCFBTPTH',
    'STCGS-VN',
    'STCHVLIGT-VN',
    'STCHVLMNF-VN',
    'STCINC-VN',
    'STCMITPTH',
    'STCMT-VN',
    'STCNFC-VN',
    'STCRFW-VN',
    'STCSMC-VN',
    'STCSMS-VN',
    'STCTMTH',
    'STCBSBCCREAMXXLVN',
  'STCFHRCPINKVN',
  'STCFHRCYELLOWVN',
  'STCFRSTBRSHVN',
  'STCFRSTBRSPNKVN',
  'STCHCBLUEVN',
  'STCHGGINGBLUVN',
  'STCHGGINGPNKVN',
  'STCHGGINGWHTVN',
  'STCHIPSEATTRQSVN',
  'STCMNBCREAMLVN',
  'STCMNBCREAMMVN',
  'STCMNBLACKXLVN',
  'STCNANOCRSTS/MVN',
  'STCPAACCREAM3XLVN',
  'STCPACBLACK3XLVN',
  'STCPACCREAMLVN',
  'STCPREGBELTCVN',
  'STCPREGBELTVN',
  'STCSPBMBLACKVN',
  'STCSPBXLBLACKVN',
  'STCWBPADVN','STCMACAV','STCMCBBLCK','STCMCBCRM'
  )
  */
  /*AB-update sku take out base on handing out ls-11-09-24 update 2 12/11/24*/
  AND doh.orderType NOT IN ('FREE', 'KT', 'TROF', 'TTG') /*AB-update so type base on handing out ls-11-09-24*/
  AND COALESCE(ila.lotAtt04, '') NOT IN ('SET') /*AL validate batch*/
  GROUP BY doh.organizationId,
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
           t1.codeDescr,
           bz.zoneDescr,
           ila.lotAtt04,
           ila.lotAtt07,
           BT.codeid;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET order_done = TRUE;
  OPEN cur_orderno;
cur_order_loop:
  LOOP
    FETCH FROM cur_orderno INTO od_organizationId,
    od_orderNo,
    od_soReference1,
    od_soReference3,
    od_orderType,
    od_docType,
    od_docTypeDescr, od_soStatus, od_warehouseId,
    od_customerId, od_orderLineNo, od_SKU, od_ShipmentTime, od_qty,
    od_qty_each, od_qtyShipped_each, od_uom,
    od_qtyChargeEA,
    od_qtyChargeCS,
    od_qtyChargeIP,
    od_qtyChargePL,
    od_qtyChargeCBM,
    od_qtyChargeTotDO,
    od_qtyChargeTotLine,
    od_totalCube,
    od_editTime, od_lotNum, od_traceId, od_pickToTraceId, od_dropId,
    od_location, od_pickToLocation, od_allocationDetailsId, od_skuDescr1,
    od_grossWeight, od_cubeNya, od_tariffMasterId, od_QtyPerCases,
    od_QtyPerPallet, od_zone, od_batch, od_lotAtt07, od_Billtranctg, od_qtyChargeNettWeight, od_qtyChargeGrossWeight, od_qtyChargeMetricTon,/*additional nettweight Gross Weight ABYuhuu*/
    od_closetimetransaction, /*additional close transaction by AKBAR */
    od_line_transaction;-- line transaction
    IF order_done THEN
      SET order_done = FALSE;
      LEAVE cur_order_loop;
    END IF;

    IF NOT EXISTS (SELECT
          1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = od_organizationId
        AND bs.warehouseId = od_warehouseId
        AND bs.docNo = od_orderNo
        AND bs.udf03 = od_line_transaction
        AND bs.chargeCategory = 'OB') THEN


    BLOCK2:
      BEGIN
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
          -- btd.udf05,
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
          btd.billingParty,
          IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
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
        AND bth.tariffMasterId = od_tariffMasterId
        AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND btd.chargeCategory = 'OB'
        AND btd.docType = od_orderType
        AND btr.rate > 0
        #AND IFNULL(DAY(bth.billingdate),0)!=0 
        ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = TRUE;
        ####################################################################


        SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd
        #
        OPEN cur_Tariff;
      getTariff:
        LOOP
          FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
          R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
          R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;
          IF tariff_done THEN
            SET tariff_done = FALSE;
            LEAVE getTariff;
          END IF;


          -- ADDING AKBAR RULE => JIKA BILLING CATEGORY TIDAK DI SETUP DI BILING SETUP, SKIP VALIDASI 07.03.2024

          IF R_BILLINGTRANCATEGORY IS NULL
            OR R_BILLINGTRANCATEGORY = '' THEN
            SET R_BILLINGTRANCATEGORY = od_Billtranctg;
          END IF;

          SELECT
            R_BILLINGDAY;

          IF R_BILLINGDAY = 31 THEN
            SET R_BILLINGDAY = DAY(LAST_DAY(CURDATE()));
          END IF;

          SELECT
            od_orderType,
            R_docType,
            od_Billtranctg,
            R_BILLINGTRANCATEGORY,
            R_ratebase;
          IF (RTRIM(LTRIM(od_orderType)) = RTRIM(LTRIM(R_docType)))
            AND (RTRIM(LTRIM(od_Billtranctg)) = RTRIM(LTRIM(R_BILLINGTRANCATEGORY))) THEN

            --           SELECT
            --             od_orderType,
            --             R_docType,
            --             od_Billtranctg,
            --             R_BILLINGTRANCATEGORY,
            --             R_RESULTQTYCHARGE,
            --             R_ratebase;


            -- CALCULATION
            -- UOM
            -- PALLET
            -- CUBIC
            -- M2
            -- CASE
            -- IP
            -- PIECES
            -- KG
            -- LITER
            -- DO
            -- HOUR
            -- MONTH
            SELECT
              R_BILLINGDAY;


            SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
            SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');


            SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
            SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);

            SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
            SET R_billsummaryId = '';

            IF (R_ratebase = 'CUBIC') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeCBM;
            ELSEIF (R_ratebase = 'M2') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeEA;
            ELSEIF (R_ratebase = 'IP') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeIP;
            ELSEIF (R_ratebase = 'KG') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeEA;
            ELSEIF (R_ratebase = 'LITER') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeEA;
            ELSEIF (R_ratebase = 'QUANTITY') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeEA;
            ELSEIF (R_ratebase = 'DO') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeTotDO;
            ELSEIF (R_ratebase = 'PALLET') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargePL;
            ELSEIF (R_ratebase = 'CASE') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeCS;
            ELSEIF (R_ratebase = 'NETWEIGHT') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeNettWeight;
            ELSEIF (R_ratebase = 'GW') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeGrossWeight; /*additional nettweight Gross Weight ABYuhuu*/
            ELSEIF (R_ratebase = 'MT') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeMetricTon;/*additional metric ton 29042024*/
            --             IF (R_PALLETCNT = 'N') THEN
            --               SET R_RESULTQTYCHARGE = od_qtyCharge;
            --             ELSEIF (R_PALLETCNT = 'Y') THEN
            --               SET R_RESULTQTYCHARGE = od_qtyCharge;
            --             ELSEIF (R_PALLETCNT = 'X') THEN
            --               SET R_RESULTQTYCHARGE = od_qtyCharge;
            --             END IF;
            END IF;


            SELECT
              'check=>',
              R_RESULTQTYCHARGE,
              R_TARIFFID;


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
              CALL SPCOM_GetIDSequence_NEW('OJV_CML', '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);
              IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
                SET OUT_returnCode = '999#????????';
                LEAVE getTariff;
              END IF;
            END IF;

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
                DATE_FORMAT(od_closetimetransaction, '%Y-%m-%d'),
                DATE_FORMAT(od_closetimetransaction, '%Y-%m-%d'),
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
                od_qtyShipped_each,
                od_uom,
                od_totalCube,
                od_grossWeight,
                R_rate,
                R_RESULTQTYCHARGE * R_rate / R_rateperunit,
                (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
                0,
                R_cost * R_RESULTQTYCHARGE,
                0,
                NOW() confirmTime,
                '' confirmWho,
                'SO',
                od_orderNo,
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
                R_RESULTQTYCHARGE * R_rate / R_rateperunit incomeWithoutTax,
                0 cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                R_materialNo AS udf01,
                R_itemChargeCategory AS udf02,
                -- R_UDF08 udf03,
                od_line_transaction udf03,
                R_UDF06 udf04,
                '' udf05,
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
                od_orderType orderType,
                '' containerType,
                '' containerSize;

          END IF; -- END IF docType



        END LOOP getTariff;
        CLOSE cur_Tariff;


      --  END IF; 
      --  END IF TARIFF ORDER KOSONG
      END;
    END IF; -- END IF JIKA LINE DI BILSUMMARY SUDAH ADA ( AVOID DOUBLE)
  END LOOP cur_order_loop;
  CLOSE cur_orderno;
  SET OUT_returnCode = '000';
END
$$

--
-- Create procedure `CML_BILLHISTD_TYPE2`
--
CREATE
DEFINER = 'it.ari'@'%'
PROCEDURE CML_BILLHISTD_TYPE2 (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_trans_no varchar(30))
BEGIN
  ####################################################################
  ##????
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
  DECLARE R_RESULTQTYCHARGE decimal(24, 8);  -- add for calculation
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
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
  DECLARE od_warehouseId varchar(255);
  DECLARE od_customerId varchar(255);
  DECLARE od_asnNo varchar(255);
  DECLARE od_qtyReceived varchar(255);
  DECLARE od_qtyReceivedEach varchar(255);
  DECLARE od_docType varchar(255);
  DECLARE od_docTypeDescr varchar(255);
  DECLARE od_QtyPerCases varchar(255);
  DECLARE od_QtyPerPallet varchar(255);
  DECLARE OUT_returnCode varchar(1000);
  DECLARE od_qtyChargeEA varchar(255);
  DECLARE od_qtyChargeCS varchar(255);
  DECLARE od_qtyChargeIP varchar(255);
  DECLARE od_qtyChargePL varchar(255);
  DECLARE od_qtyChargeCBM varchar(255);
  DECLARE od_qtyChargeTotDO varchar(255);
  DECLARE od_qtyChargeDropId varchar(255);
  DECLARE od_qtyChargeTotLine varchar(255);
  DECLARE od_qtyChargeNettWeight varchar(255); /*additional nettweight NettWeight by IT-ARI BUDIMAN 06.03.2024*/
  DECLARE od_qtyChargeGrossWeight varchar(255);/*additional nettweight grossweight by IT-ARI BUDIMAN 06.03.2024*/
  DECLARE od_qtyChargeMetricTon varchar(255);/*additional MetricTon by IT-ARI BUDIMAN 22.03.2024*/
  DECLARE od_closetimetransaction timestamp; /*additional close transaction by AKBAR */
  ####################################################################
  ##????
  DECLARE inventory_done int DEFAULT 0;
  DECLARE tariff_done int DEFAULT 0;
  DECLARE order_done,
          attribute_done int DEFAULT 0;

  DECLARE cur_orderno CURSOR FOR

  SELECT
    sumasn.organizationId,
    sumasn.warehouseId,
    sumasn.customerId,
    sumasn.asnNo,
    sumasn.docType,
    sumasn.asnReference1,
    sumasn.asnReference3,
    SUM(sumasn.qtyChargeEA) AS qtyChargeEA,
    SUM(sumasn.qtyChargeCS) AS qtyChargeCS,
    SUM(sumasn.qtyChargeIP) AS qtyChargeIP,
    SUM(sumasn.qtyChargePL) AS qtyChargePL,
    SUM(sumasn.qtyChargeCBM) AS qtyChargeCBM,
    COUNT(sumasn.qtyChargeDropId) AS qtyChargeDropId,
    COUNT(sumasn.qtyChargeTotDO) AS qtyChargeTotDO,
    SUM(sumasn.qtyChargeTotLine) AS qtyChargeTotLine,
    SUM(sumasn.qtyChargeNettWeight) AS qtyChargeNettWeight,
    SUM(sumasn.qtyChargeGrossWeight) AS qtyChargeGrossWeight,
    SUM(sumasn.qtyChargeMetricTon) AS qtyChargeMetricTon,
    sumasn.closeTime
  FROM (SELECT DISTINCT
      IFNULL(CAST(dah.organizationId AS char(255)), '') AS organizationId,
      IFNULL(CAST(dah.asnReference1 AS char(255)), '') AS asnReference1,
      IFNULL(CAST(dah.asnReference3 AS char(255)), '') AS asnReference3,
      IFNULL(CAST(atl.warehouseId AS char(255)), '') AS warehouseId,
      IFNULL(CAST(atl.docNo AS char(255)), '') AS asnNo,
      IFNULL(CAST(atl.tocustomerId AS char(255)), '') AS customerId,
      IFNULL(CAST(COUNT(atl.docLineNo) AS char(255)), 0) AS qtyChargeTotLine,
      IFNULL(CAST(SUM(atl.toQty) AS char(255)), 0) AS qtyReceived,
      IFNULL(CAST(SUM(atl.toQty_Each) AS char(255)), 0) AS qtyReceivedEach,
      IFNULL(CAST(SUM(atl.toQty_Each / bpdEA.qty) AS char(255)), 0) AS qtyChargeEA,
      IFNULL(CAST(CEIL(SUM(atl.toQty_Each / bpdCS.qty)) AS char(255)), 0) AS qtyChargeCS,
      IFNULL(CAST(CEIL(SUM(atl.toQty_Each / bpdIP.qty)) AS char(255)), 0) AS qtyChargeIP,
      IFNULL(CAST(CEIL(SUM(atl.toQty_Each / bpdPL.qty)) AS char(255)), 0) AS qtyChargePL,
      IFNULL(CAST(SUM(atl.toQty_Each * bs.cube) AS char(255)), 0) AS qtyChargeCBM,
      IFNULL(CAST(atl.docNo AS char(255)), 0) AS qtyChargeTotDO,
      IFNULL(CAST(SUM(bs.cube) AS char(255)), 0) AS totalCube,
      IFNULL(CAST(atl.tomuid AS char(255)), '') AS qtyChargeDropId,
      IFNULL(CAST(t1.codeid AS char(255)), '') AS docType,
      IFNULL(CAST(t1.codeDescr AS char(255)), '') AS docTypeDescr,
      IFNULL(CAST(SUM(atl.toQty_Each * bs.netWeight) AS char(255)), 0) AS qtyChargeNettWeight,/*additional nettweight grossweight*/
      CASE WHEN bpdEA.uomdescr IN ('G', 'GRAM', 'Gram') THEN IFNULL(CAST(SUM(atl.toQty_Each / 1000) AS char(255)), 0) WHEN bpdEA.uomdescr IN ('MT', 'Metric Ton', 'METRIC TON') THEN IFNULL(CAST(SUM(atl.toQty_Each * 1000) AS char(255)), 0) ELSE IFNULL(CAST(SUM(atl.toQty_Each * bs.grossWeight) AS char(255)), 0) END AS qtyChargeGrossWeight,
      CASE WHEN atl.tocustomerId LIKE '%ABC%' THEN IFNULL(CAST(SUM((atl.toQty_Each * bpdCS.qty) / 1000) AS char(255)), 0) ELSE IFNULL(CAST(SUM(atl.toQty_Each / 1000) AS char(255)), 0) END AS qtyChargeMetricTon,
      daf.closeTime
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
      LEFT JOIN DOC_ASN_HEADER_UDF daf
        ON dah.organizationId = daf.organizationId
        AND dah.warehouseId = daf.warehouseId
        AND dah.asnNo = daf.asnNo
      LEFT OUTER JOIN DOC_ASN_DETAILS dad
        ON dad.organizationId = atl.organizationId
        AND dad.warehouseId = atl.warehouseId
        AND dad.asnNo = atl.docNo
        AND dad.asnLineNo = atl.docLineNo
        AND dad.sku = atl.toSku
      LEFT OUTER JOIN INV_LOT_ATT ila
        ON ila.organizationId = atl.organizationId
        AND ila.customerId = atl.toCustomerId
        AND ila.SKU = atl.toSku
        AND ila.lotNum = atl.toLotNum
      LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdEA
        ON bpdEA.organizationId = bs.organizationId
        AND bpdEA.packId = bs.packId
        AND bpdEA.customerId = bs.customerId
        AND bpdEA.packUOM = 'EA'
      LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdIP
        ON bpdIP.organizationId = bs.organizationId
        AND bpdIP.packId = bs.packId
        AND bpdIP.customerId = bs.customerId
        AND bpdIP.packUOM = 'IP'
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
      LEFT JOIN BSM_CODE BT
        ON BT.organizationId = atl.organizationId
        AND BT.codeType = 'BILLING_TRANSACTION_CATEGORY'
        AND BT.outerCode = ila.lotAtt07
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
    WHERE atl.organizationId = IN_organizationId
    AND atl.warehouseId = IN_warehouseId
    AND dah.customerId = IN_CustomerId
    AND dah.asnNo = IN_trans_no
    AND COALESCE(ila.lotAtt04, '') NOT IN ('SET') /*AL validate batch*/
    # AND bsm.tariffMasterId = IN_tariffMaster
    AND atl.transactionType = 'IN'
    AND dah.asnType NOT IN ('FREE', 'IU', 'TTG')
    AND dad.skuDescr NOT LIKE '%PALLET%'
    AND atl.toSku NOT IN (SELECT
        sku
      FROM Z_SKUNOTBILLING zsnb
      WHERE organizationId = atl.organizationId
      AND customerId = atl.toCustomerId)
    /*    AND atl.toSku NOT IN ('YFI001', 'DEMO TABLE AT', 'DEMO TABLE SAM', 'HOT STAMP', 'COLLATERAL-COLLECTABLE STICKER', 'HELLOBASTC', 'MAMALOVSTC', 'MAMANOUSTC', 'MAMAPCK02',
        'MAMASTT', 'STCMCBMS-TH', 'BUMILTSTC2', 'COLLATERAL-STICKERPINK', 'PRINCTSTC3',
        'MAMABOX01',
        'MAMABOX02',
        'MAMABOXPINK',
        'PINKBOX03P',
        'BIGBOX5',
        'COLLATERAL-PIZZABOX',
        'MAMABOX01',
        'MAMABOX02',
        'MAMABOXPINK',
        'MEDIUMBOX4',
        'PINKBOX03P',
        'SMALL BOX',
        'TAP-COMBOX',
        'GRTGCRD',
        'BUNBUNSTC01',
        'BUNBUNSTC02',
        'CONGRATSTC1',
        'MAMAMWTH',
        'STCABS-MY',
        'STCABS-TH',
        'STCANTCOLIC-BIG-TH',
        'STCANTCOLIC-SMALL-TH',
        'STCAPCN',
        'STCAPRCMMY',
        'STCAPRCMY',
        'STCAPRCTH',
        'STCAPRCTH-DIR',
        'STCAPRCTH-NIG',
        'STCAPRCTH-NUT',
        'STCAPRMMY',
        'STCAPRMTH',
        'STCAPRMTH-DIR',
        'STCAPRMTH-NIG',
        'STCAPRMTH-NUT',
        'STCBFS-PH',
        'STCBHABMY',
        'STCBHABTH',
        'STCBHABWPH',
        'STCBHABWTH',
        'STCBPOMSC',
        'STCDC-TH',
        'STCDCIC-TH',
        'STCDCPH',
        'STCDCW-TH',
        'STCDPFMPH',
        'STCDPFMPH-TH',
        'STCDSDTH',
        'STCEBPTH',
        'STCFWID',
            'STCGFW-VN', -- add 26-05-25  akbar
        'STCGBSID',
        'STCGBSMY',
        'STCGBSTH',
        'STCGFW-MY',
        'STCGFWPH',
        'STCGFWTH',
        'STCHPSEATCR',
        'STCINCMY',
        'STCKTP-PH',
        'STCKTPBGTH',
        'STCKTPBID',
        'STCKTPEN',
        'STCKTPSID',
        'STCKTPSTH',
        'STCMCDNFC-ID',
        'STCMCDNFC-MY',
        'STCMCDNFC-PH',
        'STCMCDNFC-SG',
        'STCMCDNFC-TH',
        'STCMCDSD-EN',
        'STCMCDSD-MY',
        'STCMCDSD-SG',
        'STCMCDSD-TH',
        'STCMCHVL-MY',
        'STCMCHVL-PH',
        'STCMCHVL-SG',
        'STCMCHVL-TH',
        'STCMCHVLTH',
        'STCMCMBP-TH',
        'STCMCPH',
        'STCMCSHS-MY',
        'STCMCSHS-PH',
        'STCMCSHS-SG',
        'STCMCSHS-TH',
        'STCMCSVL-ID',
        'STCMCSVL-MY',
        'STCMCTH',
        'STCMCWBP-TH',
        'STCMHG-PH',
        'STCMOSPL-SG',
        'STCMSMY',
        'STCMSTH',
        'STCMWPH',
        'STCMWSG',
        'STCMWTH',
        'STCNCPH',
        'STCNCSG',
        'STCNCTH',
        'STCREVIMSK-TH',
        'STCRFW-MY',
        'STCRFW-TH',
        'STCRMOMY',
        'STCRMOPH',
        'STCRMOTH',
        'STCSMRPH',
        'STCSOOTHMSK-TH',
        'STCSPL-PH',
        'STCSPL-SG',
        'STCTC-TH',
        'STCTCA-TH',
        'STCTCI-TH',
        'STCTCID',
        'STCTCMY',
        'STCTCPH',
        'STCTCSG',
        'STCTO',
        'STCTO-ID',
        'STCTO-PH',
        'STCTPPH',
        'STCTPSG',
        'STCTPTH',
        'STCTSA-TH',
        'STCTSI-TH',
        'STCTSMY',
        'STCTSPH',
        'STCTSSG',
        'STCTTH',
        'STCHIPSEATMI',
        'STCBSBCCREAMXXLVN',
    'STCFHRCPINKVN',
    'STCFHRCYELLOWVN',
    'STCFRSTBRSHVN',
    'STCFRSTBRSPNKVN',
    'STCHCBLUEVN',
    'STCHGGINGBLUVN',
    'STCHGGINGPNKVN',
    'STCHGGINGWHTVN',
    'STCHIPSEATTRQSVN',
    'STCMNBCREAMLVN',
    'STCMNBCREAMMVN',
    'STCMNBLACKXLVN',
    'STCNANOCRSTS/MVN',
    'STCPAACCREAM3XLVN',
    'STCPACBLACK3XLVN',
    'STCPACCREAMLVN',
    'STCPREGBELTCVN',
    'STCPREGBELTVN',
    'STCSPBMBLACKVN',
    'STCSPBXLBLACKVN',
    'STCWBPADVN','STCMACAV','STCMCBBLCK','STCMCBCRM'
    )
    */
    AND atl.STATUS IN ('80', '99')
    AND dah.asnStatus IN ('99')
    GROUP BY atl.docNo,
             atl.docLineNo,
             atl.toCustomerId,
             atl.warehouseId,
             atl.tocustomerId,
             atl.toMuId,
             dah.organizationId,
             dah.asnNo,
             dah.asnType,
             dah.asnReference1,
             dah.asnReference3,
             t1.codeid,
             BT.codeid) sumasn
  GROUP BY sumasn.organizationId,
           sumasn.warehouseId,
           sumasn.customerId,
           sumasn.asnNo,
           sumasn.docType,
           sumasn.asnReference1,
           sumasn.asnReference3,
           sumasn.closeTime;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET order_done = 1;
  OPEN cur_orderno;
cur_order_loop:
  LOOP
    FETCH FROM cur_orderno INTO od_organizationId,
    od_warehouseId,
    od_customerId,
    od_asnNo,
    od_docType,
    od_asnReference1,
    od_asnReference3,
    od_qtyChargeEA,
    od_qtyChargeCS,
    od_qtyChargeIP,
    od_qtyChargePL,
    od_qtyChargeCBM,
    od_qtyChargeTotDO,
    od_qtyChargeDropId,
    od_qtyChargeTotLine,
    od_qtyChargeNettWeight,
    od_qtyChargeGrossWeight,
    od_qtyChargeMetricTon,
    od_closetimetransaction;/*additional nettweight grossweight metric ton*/

    IF order_done = 1 THEN

      SET order_done = 0;
      LEAVE cur_order_loop;
    END IF;



    IF NOT EXISTS (SELECT
          1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = od_organizationId
        AND bs.warehouseId = od_warehouseId
        AND bs.docNo = od_asnNo
        AND bs.chargeCategory = 'IB') THEN

    BLOCK2:
      BEGIN



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
          btd.udf05, -- sementara pengganti ratebase
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
          btd.billingParty,
          -- btd.billingTranCategory,
          IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
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
        AND btd.chargeCategory = 'IB'
        AND btd.docType = od_docType
        AND btr.rate > 0
        #AND IFNULL(DAY(bth.billingdate),0)!=0 
        ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;

        SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd
        #
        OPEN cur_Tariff;
      getTariff:
        LOOP
          FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
          R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
          R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;
          IF tariff_done THEN
            SET tariff_done = FALSE;
            LEAVE getTariff;
          END IF;


          SELECT
            od_docType,
            R_docType,
            -- od_Billtranctg,
            R_BILLINGTRANCATEGORY;

          -- ADDING AKBAR RULE => JIKA BILLING CATEGORY TIDAK DI SETUP DI BILING SETUP, SKIP VALIDASI 07.03.2024

          IF R_BILLINGTRANCATEGORY IS NULL
            OR R_BILLINGTRANCATEGORY = '' THEN
            SET R_BILLINGTRANCATEGORY = '';
          END IF;

          IF (LTRIM(RTRIM(od_docType)) = LTRIM(RTRIM(R_docType))) THEN
            --  AND (LTRIM(RTRIM(od_Billtranctg)) = LTRIM(RTRIM(R_BILLINGTRANCATEGORY))) THEN
            -- CALCULATION
            -- UOM
            -- PALLET
            -- CUBIC
            -- M2
            -- CASE
            -- IP
            -- PIECES
            -- KG
            -- LITER
            -- DO
            -- HOUR
            -- MONTH


            --           SELECT  'check=>',R_ratebase,R_TARIFFID;
            SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
            SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
            SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
            SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
            SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
            SET R_billsummaryId = '';


            IF (R_ratebase = 'CUBIC') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeCBM;
            ELSEIF (R_ratebase = 'M2') THEN
              SET R_RESULTQTYCHARGE = 0;
            ELSEIF (R_ratebase = 'IP') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeIP;
            ELSEIF (R_ratebase = 'KG') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeEA;
            ELSEIF (R_ratebase = 'LITER') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeEA;
            ELSEIF (R_ratebase = 'DO') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeTotDO;
            ELSEIF (R_ratebase = 'PALLET') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargePL;
            ELSEIF (R_ratebase = 'CASE') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeCS;
            ELSEIF (R_ratebase = 'QUANTITY') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeEA;
            ELSEIF (R_ratebase = 'NETWEIGHT') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeNettWeight;
            ELSEIF (R_ratebase = 'GW') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeGrossWeight;
            /*additional nettweight grossweight*/
            ELSEIF (R_ratebase = 'DID') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeDropId;
            ELSEIF (R_ratebase = 'DID1') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeDropId;
            ELSEIF (R_ratebase = 'MT') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeMetricTon;
            END IF;



            --           SELECT 'check 2=>',R_RESULTQTYCHARGE;

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
            #
            IF (R_billsummaryId = '') THEN
              SET @linenumber = 0;
              SET OUT_returnCode = '';
              CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);

              IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
                SET OUT_returnCode = '999#????????';
                LEAVE getTariff;
              END IF;
            END IF;
            #
            SELECT
              R_billsummaryId;

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
                DATE_FORMAT(od_closetimetransaction, '%Y-%m-%d'),
                DATE_FORMAT(od_closetimetransaction, '%Y-%m-%d'),
                od_customerId,
                '' SKU,
                '' lotNum,
                '' traceId,
                R_TARIFFID,
                R_CHARGECATEGORY,
                R_chargetype,
                R_descrC,
                R_rateBase,
                R_rateperunit,
                R_RESULTQTYCHARGE,
                '' uom,
                od_qtyChargeCBM,
                od_qtyChargeGrossWeight,
                R_rate,
                R_RESULTQTYCHARGE * R_rate / R_rateperunit,
                (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
                0,
                R_cost * R_RESULTQTYCHARGE,
                0,
                NOW() confirmTime,
                '' confirmWho,
                od_docType,
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
                R_RESULTQTYCHARGE * R_rate / R_rateperunit incomeWithoutTax,
                0 cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                R_materialNo AS udf01,
                R_itemChargeCategory AS udf02,
                '' udf03,
                R_UDF06 udf04,
                '' udf05,
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






      END;

    END IF; -- END IF JIKA LINE DI BILSUMMARY SUDAH ADA ( AVOID DOUBLE)


  END LOOP cur_order_loop;
  CLOSE cur_orderno;
  SET OUT_returnCode = '000';
END
$$

--
-- Create procedure `CML_BILLHISTD`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLHISTD (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_trans_no varchar(30),
IN IN_tariffMaster varchar(30))
BEGIN


  ####################################################################
  ##????
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
  DECLARE R_RESULTQTYCHARGE decimal(24, 8);  -- add for calculation
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
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
  DECLARE od_Billtranctg varchar(21);
  DECLARE OUT_returnCode varchar(1000);
  DECLARE od_qtyChargeEA varchar(255);
  DECLARE od_qtyChargeCS varchar(255);
  DECLARE od_qtyChargeIP varchar(255);
  DECLARE od_qtyChargePL varchar(255);
  DECLARE od_qtyChargeCBM varchar(255);
  DECLARE od_qtyChargeTotDO varchar(255);
  DECLARE od_qtyChargeTotLine varchar(255);
  DECLARE od_qtyChargeNettWeight varchar(255); /*additional nettweight NettWeight by IT-ARI BUDIMAN 06.03.2024*/
  DECLARE od_qtyChargeGrossWeight varchar(255);/*additional nettweight grossweight by IT-ARI BUDIMAN 06.03.2024*/
  DECLARE od_qtyChargeMetricTon varchar(255);/*additional MetricTon by IT-ARI BUDIMAN 22.03.2024*/
  DECLARE od_closetimetransaction timestamp; /*additional close transaction by AKBAR */
  DECLARE od_line_transaction varchar(255); /*additional line id unique transaction 02.07.2024 */
  ####################################################################
  ##????
  DECLARE inventory_done int DEFAULT 0;
  DECLARE tariff_done int DEFAULT 0;
  DECLARE order_done,
          attribute_done int DEFAULT 0;



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
    CASE WHEN atl.tocustomerId IN ('MAP') AND
        ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
        bsm.tariffMasterId LIKE '%PIECE%' THEN IFNULL(CAST(SUM(atl.toQty_Each / bpdEA.qty) AS char(255)), 0) ELSE IFNULL(CAST(SUM(atl.toQty_Each / bpdEA.qty) AS char(255)), 0) END AS qtyChargeEA,
    IFNULL(CAST(CEIL(SUM(atl.toQty_Each / bpdCS.qty)) AS char(255)), 0) AS qtyChargeCS,
    IFNULL(CAST(CEIL(SUM(atl.toQty_Each / bpdIP.qty)) AS char(255)), 0) AS qtyChargeIP,
    IFNULL(CAST(CEIL(SUM(atl.toQty_Each / bpdPL.qty)) AS char(255)), 0) AS qtyChargePL,
    CASE WHEN atl.tocustomerId IN ('MAP') AND
        ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') AND
        bsm.tariffMasterId NOT LIKE '%PIECE%' THEN IFNULL(CAST(SUM(atl.toQty_Each * bs.cube) AS char(255)), 0) ELSE IFNULL(CAST(SUM(atl.toQty_Each * bs.cube) AS char(255)), 0) END AS qtyChargeCBM,
    IFNULL(CAST(COUNT(atl.docNo) AS char(255)), 0) AS qtyChargeTotDO,
    IFNULL(CAST(COUNT(atl.docLineNo) AS char(255)), 0) AS qtyChargeTotLine,
    IFNULL(CAST(SUM(bs.cube) AS char(255)), 0) AS totalCube,
    CAST(DATE_FORMAT(atl.addTime, '%Y-%m-%d') AS char(255)) AS addTime,
    CAST(DATE_FORMAT(atl.editTime, '%Y-%m-%d') AS char(255)) AS editTime,
    CAST(DATE_FORMAT(atl.transactionTime, '%Y-%m-%d') AS char(255)) AS transactionTime,
    IFNULL(CAST(atl.tolotNum AS char(255)), '') AS lotNum,
    IFNULL(CAST(atl.toId AS char(255)), '') AS traceId,
    IFNULL(CAST(atl.tomuid AS char(255)), '') AS muid,
    IFNULL(CAST(atl.toLocation AS char(255)), '') AS toLocation,
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
    IFNULL(CAST(ila.lotAtt07 AS char(10)), '') AS lotAtt07,
    IFNULL(CAST(BT.codeid AS char(255)), '') AS billtranctg,
    IFNULL(CAST(SUM(atl.toQty_Each * bs.netWeight) AS char(255)), 0) AS qtyChargeNettWeight,/*additional nettweight grossweight*/
    CASE WHEN bpdEA.uomdescr IN ('G', 'GRAM', 'Gram') THEN IFNULL(CAST(SUM(atl.toQty_Each / 1000) AS char(255)), 0) WHEN bpdEA.uomdescr IN ('MT', 'Metric Ton', 'METRIC TON') THEN IFNULL(CAST(SUM(atl.toQty_Each * 1000) AS char(255)), 0) ELSE IFNULL(CAST(SUM(atl.toQty_Each * bs.grossWeight) AS char(255)), 0) END AS qtyChargeGrossWeight,
    CASE WHEN atl.tocustomerId LIKE '%ABC%' THEN IFNULL(CAST(SUM((atl.toQty_Each * bpdCS.qty) / 1000) AS char(255)), 0) ELSE IFNULL(CAST(SUM(atl.toQty_Each / 1000) AS char(255)), 0) END AS qtyChargeMetricTon,
    daf.closeTime,
    atl.transactionId -- add transaction line
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
    LEFT JOIN DOC_ASN_HEADER_UDF daf
      ON dah.organizationId = daf.organizationId
      AND dah.warehouseId = daf.warehouseId
      AND dah.asnNo = daf.asnNo
    LEFT OUTER JOIN DOC_ASN_DETAILS dad
      ON dad.organizationId = atl.organizationId
      AND dad.warehouseId = atl.warehouseId
      AND dad.asnNo = atl.docNo
      AND dad.asnLineNo = atl.docLineNo
      AND dad.sku = atl.toSku
    LEFT OUTER JOIN INV_LOT_ATT ila
      ON ila.organizationId = atl.organizationId
      AND ila.customerId = atl.toCustomerId
      AND ila.SKU = atl.toSku
      AND ila.lotNum = atl.toLotNum
    LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdEA
      ON bpdEA.organizationId = bs.organizationId
      AND bpdEA.packId = bs.packId
      AND bpdEA.customerId = bs.customerId
      AND bpdEA.packUOM = 'EA'
    LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdIP
      ON bpdIP.organizationId = bs.organizationId
      AND bpdIP.packId = bs.packId
      AND bpdIP.customerId = bs.customerId
      AND bpdIP.packUOM = 'IP'
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
    LEFT JOIN BSM_CODE BT
      ON BT.organizationId = atl.organizationId
      AND BT.codeType = 'BILLING_TRANSACTION_CATEGORY'
      AND BT.outerCode = ila.lotAtt07
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
  WHERE atl.organizationId = IN_organizationId
  AND atl.warehouseId = IN_warehouseId
  AND dah.customerId = IN_CustomerId
  AND dah.asnNo = IN_trans_no
  AND COALESCE(ila.lotAtt04, '') NOT IN ('SET') /*AL validate batch*/
  # AND bsm.tariffMasterId = IN_tariffMaster
  AND atl.transactionType = 'IN'
  AND dah.asnType NOT IN ('FREE', 'IU', 'TTG')
  AND dad.skuDescr NOT LIKE '%PALLET%'
  AND atl.toSku NOT IN (SELECT
      sku
    FROM Z_SKUNOTBILLING zsnb
    WHERE organizationId = atl.organizationId
    AND customerId = atl.toCustomerId)
  /*  AND atl.toSku NOT IN ('DEMOTABLEAT',
    'DEMOTABLESAM',
    'HOTSTAMP',
    'COLLATERAL-COLLECTABLESTICKER',
    'HELLOBASTC',
    'MAMALOVSTC',
    'MAMANOUSTC',
    'MAMAPCK02',
    'STCMCBMS-TH',
    'BUMILTSTC2',
    'COLLATERAL-STICKERPINK',
    'PRINCTSTC3',
    'PRINCTSTC3',
    'PINKBOX03P',
    'YFI001',
    'MAMASTT',
    'TAP-COMBOX',
    'MAMABOXPINK',
    'MAMABOX01',
    'MAMABOX02',
    'BIGBOX5',
    'COLLATERAL-PIZZABOX',
    'MAMABOX01',
    'MAMABOX02',
    'MEDIUMBOX4',
    'SMALLBOX',
    'GRTGCRD',
    'BUNBUNSTC01',
    'BUNBUNSTC02',
    'CONGRATSTC1',
    'MAMAMWTH',
    'STCABS-MY',
    'STCABS-TH',
    'STCANTCOLIC-BIG-TH',
    'STCANTCOLIC-SMALL-TH',
    'STCAPCN',
    'STCAPRCMMY',
    'STCAPRCMY',
    'STCAPRCTH',
    'STCAPRCTH-DIR',
    'STCAPRCTH-NIG',
    'STCAPRCTH-NUT',
    'STCAPRMMY',
    'STCAPRMTH',
    'STCAPRMTH-DIR',
    'STCAPRMTH-NIG',
    'STCAPRMTH-NUT',
    'STCBFS-PH',
    'STCGFW-VN', -- add 26-05-25  akbar
    'STCBHABMY',
    'STCBHABTH',
    'STCBHABWPH',
    'STCBHABWTH',
    'STCBPOMSC',
    'STCDC-TH',
    'STCDCIC-TH',
    'STCDCPH',
    'STCDCW-TH',
    'STCDPFMPH',
    'STCDPFMPH-TH',
    'STCDSDTH',
    'STCEBPTH',
    'STCFWID',
    'STCGBSID',
    'STCGBSMY',
    'STCGBSTH',
    'STCGFW-MY',
    'STCGFWPH',
    'STCGFWTH',
    'STCHPSEATCR',
    'STCINCMY',
    'STCKTP-PH',
    'STCKTPBGTH',
    'STCKTPBID',
    'STCKTPEN',
    'STCKTPSID',
    'STCKTPSTH',
    'STCMCDNFC-ID',
    'STCMCDNFC-MY',
    'STCMCDNFC-PH',
    'STCMCDNFC-SG',
    'STCMCDNFC-TH',
    'STCMCDSD-EN',
    'STCMCDSD-MY',
    'STCMCDSD-SG',
    'STCMCDSD-TH',
    'STCMCHVL-MY',
    'STCMCHVL-PH',
    'STCMCHVL-SG',
    'STCMCHVL-TH',
    'STCMCHVLTH',
    'STCMCMBP-TH',
    'STCMCPH',
    'STCMCSHS-MY',
    'STCMCSHS-PH',
    'STCMCSHS-SG',
    'STCMCSHS-TH',
    'STCMCSVL-ID',
    'STCMCSVL-MY',
    'STCMCTH',
    'STCMCWBP-TH',
    'STCMHG-PH',
    'STCMOSPL-SG',
    'STCMSMY',
    'STCMSTH',
    'STCMWPH',
    'STCMWSG',
    'STCMWTH',
    'STCNCPH',
    'STCNCSG',
    'STCNCTH',
    'STCREVIMSK-TH',
    'STCRFW-MY',
    'STCRFW-TH',
    'STCRMOMY',
    'STCRMOPH',
    'STCRMOTH',
    'STCSMRPH',
    'STCSOOTHMSK-TH',
    'STCSPL-PH',
    'STCSPL-SG',
    'STCTC-TH',
    'STCTCA-TH',
    'STCTCI-TH',
    'STCTCID',
    'STCTCMY',
    'STCTCPH',
    'STCTCSG',
    'STCTO',
    'STCTO-ID',
    'STCTO-PH',
    'STCTPPH',
    'STCTPSG',
    'STCTPTH',
    'STCTSA-TH',
    'STCTSI-TH',
    'STCTSMY',
    'STCTSPH',
    'STCTSSG',
    'STCTTH',
    'STCCAS-ID',
    'STCHIPSEATMI',
    'AMLBL-TH',
    'CFBC-TH',
    'STCABIZNEDR150',
    'STCABIZNEDR250',
    'STCAL-TH-L/XL',
    'STCAL-TH-S/M',
    'STCAPCI-TH',
    'STCAPMI-TH',
    'STCAWN-TH',
    'STCCAS-ID',
    'STCEBPIZNEDR',
    'STCMBPIZNEDR',
    'STCMCSVL-TH',
    'STCMTPID',
    'STCNCMU',
    'STCOLIVE-TH',
    'STCTBRIZNEDR',
    'STDCDR-TH',
    'GRCRDT3',
    'PINKBOX03P',
    'TAP-COMBOX',
    'MAMABOXPINK',
    'STCABS-VN',
    'STCDPFM-VN',
    'STCKTPS-VN',
    'STCMCDSD-VN',
    'STCMCHVL-VN',
    'STCMCSHS-VN',
    'STCRC-VN',
    'STCABSIG-VN',
    'STCABSMNF-VN',
    'STCAPMNF-VN',
    'STCAPSIG-VN',
    'STCTPIG-VN',
    'STCTPMNF-VN',
    'STCACP-VN',
    'STCAMP-VN',
    'STCAPL-VN',
    'STCBNS-VN',
    'STCFBTPTH',
    'STCGS-VN',
    'STCHVLIGT-VN',
    'STCHVLMNF-VN',
    'STCINC-VN',
    'STCMITPTH',
    'STCMT-VN',
    'STCNFC-VN',
    'STCRFW-VN',
    'STCSMC-VN',
    'STCSMS-VN',
    'STCTMTH',
    'STCBSBCCREAMXXLVN',
  'STCFHRCPINKVN', 
  'STCFHRCYELLOWVN',
  'STCFRSTBRSHVN',
  'STCFRSTBRSPNKVN',
  'STCHCBLUEVN',
  'STCHGGINGBLUVN',
  'STCHGGINGPNKVN',
  'STCHGGINGWHTVN',
  'STCHIPSEATTRQSVN',
  'STCMNBCREAMLVN',
  'STCMNBCREAMMVN',
  'STCMNBLACKXLVN',
  'STCNANOCRSTS/MVN',
  'STCPAACCREAM3XLVN',
  'STCPACBLACK3XLVN',
  'STCPACCREAMLVN',
  'STCPREGBELTCVN',
  'STCPREGBELTVN',
  'STCSPBMBLACKVN',
  'STCSPBXLBLACKVN',
  'STCWBPADVN','STCMACAV','STCMCBBLCK','STCMCBCRM'
  )
  */ AND atl.STATUS IN ('80', '99')
  AND dah.asnStatus IN ('99')
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
           t1.codeid,
           BT.codeid;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET order_done = 1;
  OPEN cur_orderno;
cur_order_loop:
  LOOP
    FETCH FROM cur_orderno INTO od_organizationId,
    od_asnReference1, od_asnReference3, od_skuDescr1, od_warehouseId,
    od_customerId, od_asnNo, od_asnLineNo, od_sku, od_qtyReceived, od_uom,
    od_qtyReceivedEach,
    od_qtyChargeEA,
    od_qtyChargeCS,
    od_qtyChargeIP,
    od_qtyChargePL,
    od_qtyChargeCBM,
    od_qtyChargeTotDO,
    od_qtyChargeTotLine,
    od_totalCube, od_addTime, od_editTime,
    od_transactionTime, od_lotNum, od_traceId, od_muid, od_toLocation,
    od_docType, od_docTypeDescr, od_packId, od_QtyPerCases, od_QtyPerPallet, od_sku_group1,
    od_grossWeight, od_cubeNya, od_tariffMasterId, od_zone, od_batch, od_lotAtt07, od_Billtranctg,
    od_qtyChargeNettWeight, od_qtyChargeGrossWeight, od_qtyChargeMetricTon, od_closetimetransaction, od_line_transaction;/*additional nettweight grossweight metric ton*/

    IF order_done = 1 THEN

      SET order_done = 0;
      LEAVE cur_order_loop;
    END IF;



    IF NOT EXISTS (SELECT
          1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = od_organizationId
        AND bs.warehouseId = od_warehouseId
        AND bs.docNo = od_asnNo
        AND bs.udf03 = od_line_transaction
        AND bs.chargeCategory = 'IB') THEN

    BLOCK2:
      BEGIN



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
          btd.udf05, -- sementara pengganti ratebase
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
          btd.billingParty,
          -- btd.billingTranCategory,
          IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory
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
        AND bth.tariffMasterId = od_tariffMasterId
        AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND btd.chargeCategory = 'IB'
        AND btd.docType = od_docType
        AND btr.rate > 0
        #AND IFNULL(DAY(bth.billingdate),0)!=0 
        ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;

        SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd
        #
        OPEN cur_Tariff;
      getTariff:
        LOOP
          FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
          R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
          R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY, R_BILLINGTRANCATEGORY;
          IF tariff_done THEN
            SET tariff_done = FALSE;
            LEAVE getTariff;
          END IF;


          SELECT
            od_docType,
            R_docType,
            od_Billtranctg,
            R_BILLINGTRANCATEGORY,
            R_ratebase;


          IF (R_BILLINGDAY) = 31 THEN
            SET R_BILLINGDAY = DAY(LAST_DAY(CURDATE()));
          END IF;

          -- ADDING AKBAR RULE => JIKA BILLING CATEGORY TIDAK DI SETUP DI BILING SETUP, SKIP VALIDASI 07.03.2024

          IF R_BILLINGTRANCATEGORY IS NULL
            OR R_BILLINGTRANCATEGORY = '' THEN
            SET R_BILLINGTRANCATEGORY = od_Billtranctg;
          END IF;

          IF (LTRIM(RTRIM(od_docType)) = LTRIM(RTRIM(R_docType)))
            AND (LTRIM(RTRIM(od_Billtranctg)) = LTRIM(RTRIM(R_BILLINGTRANCATEGORY))) THEN
            -- CALCULATION
            -- UOM
            -- PALLET
            -- CUBIC
            -- M2
            -- CASE
            -- IP
            -- PIECES
            -- KG
            -- LITER
            -- DO
            -- HOUR
            -- MONTH


            --           SELECT  'check=>',R_ratebase,R_TARIFFID;


            SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
            SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
            SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
            SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
            SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
            SET R_billsummaryId = '';


            IF (R_ratebase = 'CUBIC') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeCBM;
            ELSEIF (R_ratebase = 'M2') THEN
              SET R_RESULTQTYCHARGE = 0;
            ELSEIF (R_ratebase = 'IP') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeIP;
            ELSEIF (R_ratebase = 'KG') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeEA;
            ELSEIF (R_ratebase = 'LITER') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeEA;
            ELSEIF (R_ratebase = 'DO') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeTotDO;
            ELSEIF (R_ratebase = 'PALLET') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargePL;
            ELSEIF (R_ratebase = 'CASE') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeCS;
            ELSEIF (R_ratebase = 'QUANTITY') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeEA;
            ELSEIF (R_ratebase = 'NETWEIGHT') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeNettWeight;
            ELSEIF (R_ratebase = 'GW') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeGrossWeight;
            /*additional nettweight grossweight*/
            ELSEIF (R_ratebase = 'MT') THEN
              SET R_RESULTQTYCHARGE = od_qtyChargeMetricTon;
            END IF;



            --           SELECT 'check 2=>',R_RESULTQTYCHARGE;

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
            #
            IF (R_billsummaryId = '') THEN
              SET @linenumber = 0;
              SET OUT_returnCode = '';
              CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);

              IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
                SET OUT_returnCode = '999#????????';
                LEAVE getTariff;
              END IF;
            END IF;
            #
            SELECT
              R_billsummaryId;

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
                DATE_FORMAT(od_closetimetransaction, '%Y-%m-%d'),
                DATE_FORMAT(od_closetimetransaction, '%Y-%m-%d'),
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
                R_RESULTQTYCHARGE * R_rate / R_rateperunit,
                (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
                0,
                R_cost * R_RESULTQTYCHARGE,
                0,
                NOW() confirmTime,
                '' confirmWho,
                od_docType,
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
                R_RESULTQTYCHARGE * R_rate / R_rateperunit incomeWithoutTax,
                0 cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                R_materialNo AS udf01,
                R_itemChargeCategory AS udf02,
                od_line_transaction udf03,
                R_UDF06 udf04,
                '' udf05,
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






      END;

    END IF; -- END IF JIKA LINE DI BILSUMMARY SUDAH ADA ( AVOID DOUBLE)


  END LOOP cur_order_loop;
  CLOSE cur_orderno;
  SET OUT_returnCode = '000';
END
$$

--
-- Create procedure `CML_BILLFIXSTD`
--
CREATE
DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLFIXSTD ()
BEGIN


  ####################################################################
  ##????
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
  DECLARE R_fixAmmount decimal(24, 8);
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
  DECLARE R_RESULTQTYCHARGE decimal(24, 8);  -- add for calculation
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
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
  DECLARE od_Billtranctg varchar(21);
  DECLARE OUT_returnCode varchar(1000);
  DECLARE od_qtyChargeEA varchar(255);
  DECLARE od_qtyChargeCS varchar(255);
  DECLARE od_qtyChargeIP varchar(255);
  DECLARE od_qtyChargePL varchar(255);
  DECLARE od_qtyChargeCBM varchar(255);
  DECLARE od_qtyChargeTotDO varchar(255);
  DECLARE od_qtyChargeTotLine varchar(255);
  DECLARE od_qtyChargeNettWeight varchar(255); /*additional nettweight NettWeight by IT-ARI BUDIMAN 06.03.2024*/
  DECLARE od_qtyChargeGrossWeight varchar(255);/*additional nettweight grossweight by IT-ARI BUDIMAN 06.03.2024*/
  DECLARE od_qtyChargeMetricTon varchar(255);/*additional MetricTon by IT-ARI BUDIMAN 22.03.2024*/
  DECLARE od_closetimetransaction timestamp; /*additional close transaction by AKBAR */
  DECLARE od_line_transaction varchar(255); /*additional line id unique transaction 02.07.2024 */
  ####################################################################
  ##????
  DECLARE inventory_done int DEFAULT 0;
  DECLARE tariff_done int DEFAULT 0;
  DECLARE order_done,
          attribute_done int DEFAULT 0;



  DECLARE cur_orderno CURSOR FOR
  -- --        SELECT DISTINCT bth.warehouseId, bc.customerId, btm.tariffMasterId
  -- --         FROM BIL_TARIFF_HEADER bth 
  -- --         INNER JOIN BIL_TARIFF_DETAILS btd ON bth.organizationId = btd.organizationId AND bth.warehouseId = btd.warehouseId AND bth.tariffId = btd.tariffId
  -- --         INNER JOIN BIL_TARIFF_MASTER btm ON bth.organizationId = btm.organizationId AND bth.tariffMasterId = btm.tariffMasterId
  -- --         INNER JOIN BAS_CUSTOMER bc ON btm.organizationId = bc.organizationId AND btm.Customerid = bc.customerId
  -- --         INNER JOIN BSM_WAREHOUSE bw ON bw.organizationId = bth.organizationId AND bw.warehouseId = bth.warehouseId
  -- --         WHERE btd.organizationId = 'OJV_CML'
  -- --         AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  -- --         AND bth.effectiveTo >= DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '%Y-%m-%d')
  -- --         AND bc.customerType = 'OW'
  -- --         AND bc.activeFlag = 'Y'
  -- --         AND btd.chargeCategory = 'FX';


  SELECT
  DISTINCT
    bcm.warehouseId,
    bcm.customerId,
    bth.tariffMasterId
  FROM BAS_CUSTOMER_MULTIWAREHOUSE bcm
    INNER JOIN BAS_CUSTOMER bc
      ON bc.customerId = bcm.customerId
      AND bc.organizationId = bcm.organizationId
      AND bc.CustomerType = 'OW'
    INNER JOIN BIL_TARIFF_HEADER bth
      ON bth.organizationId = bcm.organizationId
      AND bth.tariffMasterId = bcm.tariffMasterId
    INNER JOIN BIL_TARIFF_MASTER btm
      ON bcm.organizationId = btm.organizationId
      AND bth.tariffMasterId = btm.tariffMasterId
      AND bc.customerId = btm.customerId
    INNER JOIN BIL_TARIFF_DETAILS btd
      ON btd.organizationId = bth.organizationId
      AND btd.tariffId = bth.tariffId
  WHERE bcm.organizationId = 'OJV_CML'
  --   AND bth.tariffMasterId = od_tariffMasterId 
  AND bc.activeFlag = 'Y'
  AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
  AND btd.chargeCategory = 'FX'
  ORDER BY bcm.warehouseId;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET order_done = 1;
  OPEN cur_orderno;
cur_order_loop:
  LOOP
    FETCH FROM cur_orderno INTO od_warehouseId,
    od_customerId, od_tariffMasterId;

    IF order_done = 1 THEN

      SET order_done = 0;
      LEAVE cur_order_loop;
    END IF;



    IF NOT EXISTS (SELECT
          1
        FROM BIL_SUMMARY bs
        WHERE bs.organizationId = od_organizationId
        AND bs.warehouseId = od_warehouseId
        AND bs.customerId = od_customerId
        AND DATE(bs.billingFromDate) > CONCAT(YEAR(NOW()), '-', MONTH(NOW()), '-19')
        AND bs.chargeCategory = 'FX') THEN

    --  SELECT od_tariffMasterId;
    BLOCK2:
      BEGIN



        DECLARE cur_Tariff CURSOR FOR

        SELECT DISTINCT
          bcm.organizationId,
          bcm.warehouseId,
          bcm.customerId,
          DAY(STR_TO_DATE(CONCAT(YEAR(NOW()), '-', MONTH(NOW()), '-', bth.udf02), '%Y-%m-%d')) billingDate, -- change akbar 27-12-24 , correction fix date
          btd.tariffId,
          btd.tariffLineNo,
          btd.chargeCategory,
          btd.chargeType,
          btd.descrC,
          btd.ratebase,
          IF(btd.minAmount = '', 0, btd.minAmount) AS fixAmount,
          btd.minAmount,
          btd.UDF01 AS MaterialNo,
          btd.udf02 AS itemChargeCategory,
          btd.UDF05,
          btm.udf01 AS divisionCode,
          btd.UDF07,
          btd.UDF08,
          bth.contractNo,
          bth.tariffMasterId
        FROM BAS_CUSTOMER_MULTIWAREHOUSE bcm
          INNER JOIN BAS_CUSTOMER bc
            ON bc.customerId = bcm.customerId
            AND bc.organizationId = bcm.organizationId
            AND bc.CustomerType = 'OW'
          INNER JOIN BIL_TARIFF_HEADER bth
            ON bth.organizationId = bcm.organizationId
            AND bth.tariffMasterId = bcm.tariffMasterId
          INNER JOIN BIL_TARIFF_MASTER btm
            ON bcm.organizationId = btm.organizationId
            AND bth.tariffMasterId = btm.tariffMasterId
            AND bc.customerId = btm.customerId
          INNER JOIN BIL_TARIFF_DETAILS btd
            ON btd.organizationId = bth.organizationId
            AND btd.tariffId = bth.tariffId
        WHERE bcm.organizationId = 'OJV_CML'
        AND bth.tariffMasterId = od_tariffMasterId
        AND bcm.Customerid = od_customerId
        AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND btd.chargeCategory = 'FX'
        ORDER BY bcm.organizationId, bcm.customerId, btd.chargeCategory, btd.chargeType;

        DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;

        SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd
        #
        OPEN cur_Tariff;
      getTariff:
        LOOP
          FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC,
          R_ratebase, R_fixAmmount, R_minAmount, R_materialNo, R_itemChargeCategory, R_billMode, R_UDF06, R_UDF07, R_UDF08, R_CONTRACTNO, R_TARIFFMASTERID;
          IF tariff_done THEN
            SET tariff_done = FALSE;
            LEAVE getTariff;
          END IF;


          SELECT
            od_customerId;




          IF (1 = 1) THEN

            SET R_CURRENTDATE = NOW();

            SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', DAY(R_CURRENTDATE)), '%Y-%m-%d');

            SET R_billsummaryId = '';



            SET R_RESULTQTYCHARGE = R_fixAmmount;




            IF (R_billsummaryId = '') THEN
              SET @linenumber = 0;
              SET OUT_returnCode = '';
              CALL SPCOM_GetIDSequence_NEW('OJV_CML', '*', 'en', 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);

              IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
                SET OUT_returnCode = '999#????????';
                LEAVE getTariff;
              END IF;



            END IF;



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
                'OJV_CML',
                od_warehouseId,
                CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')),
                DATE_FORMAT(R_CURRENTDATE, '%Y-%m-%d'),
                DATE_FORMAT(R_CURRENTDATE, '%Y-%m-%d'),
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
                R_RESULTQTYCHARGE,
                R_RESULTQTYCHARGE,
                0,
                R_cost * R_RESULTQTYCHARGE,
                0,
                NOW() confirmTime,
                '' confirmWho,
                od_docType,
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
                R_RESULTQTYCHARGE * R_rate / R_rateperunit incomeWithoutTax,
                0 cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                R_materialNo AS udf01,
                R_itemChargeCategory AS udf02,
                od_line_transaction udf03,
                R_UDF06 udf04,
                '' udf05,
                0 currentVersion,
                '2020' oprSeqFlag,
                'CUSTOMBILL' addWho,
                NOW() ADDTIME,
                'CUSTOMBILL' editWho,
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






      END;

    END IF; -- END IF JIKA LINE DI BILSUMMARY SUDAH ADA ( AVOID DOUBLE)


  END LOOP cur_order_loop;
  CLOSE cur_orderno;
  SET OUT_returnCode = '000';
END
$$

--
-- Create procedure `CML_BILLFIXCHG`
--
CREATE
DEFINER = 'root'@'%'
PROCEDURE CML_BILLFIXCHG (IN IN_organizationId varchar(30),/*AB 06/12/24*/
IN IN_warehouseId varchar(30),
IN IN_CustomerId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_tariffMaster varchar(30))
BEGIN
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
  DECLARE R_fixAmount decimal(24, 8);
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
  DECLARE R_RESULTQTYCHARGE decimal(24, 8);  -- add for calculation
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
  DECLARE R_BILLTO varchar(30);
  DECLARE R_NROW integer;
  DECLARE R_PALLETCNT varchar(30);
  DECLARE R_UDF08 varchar(500);
  DECLARE R_UDF05 varchar(500);
  DECLARE R_UDF07 varchar(500);
  DECLARE R_Days int(11) DEFAULT NULL;
  DECLARE OUT_returnCode varchar(1000);
  ####################################################################
  DECLARE od_organizationId varchar(20);
  DECLARE od_warehouseId varchar(255);
  DECLARE od_customerId varchar(255);
  DECLARE od_tariffMasterId varchar(255);
  DECLARE od_tariffId varchar(50);
  DECLARE od_chargeType varchar(255);
  DECLARE od_fixAmount varchar(255);
  DECLARE od_incomeTaxRate varchar(20);
  DECLARE od_ratebase varchar(255);
  DECLARE od_udf02 varchar(255);
  DECLARE od_tariffLineNo varchar(255);
  DECLARE tariff_done int DEFAULT FALSE;
  DECLARE bil_done,
          attribute_done boolean DEFAULT FALSE;
  DECLARE cur_bilno CURSOR FOR
  SELECT DISTINCT
    c1.organizationId,
    c1.warehouseId,
    c1.customerId,
    c1.tariffMasterId,
    IFNULL(b.tariffId, '*'),
    a.chargeType,
    -- a.fixAmount, /*chage from minAmount to fixAmount AB 24/04/25*/    ==> tidak ada kolom fixAmount    error 1 Unknown column 'a.fixAmount' in 'field list' SQL2.sql 20 1 
    a.udf03, -- back to udf03 AKB 25/04/2025
    a.incomeTaxRate,
    a.rateBase,
    CASE WHEN b.udf02 = ' ' THEN DAY(b.billingDate) ELSE b.udf02 END AS udf02,
    a.tariffLineNo
  FROM BAS_CUSTOMER_MULTIWAREHOUSE c1
    LEFT JOIN BIL_TARIFF_HEADER b
      ON b.organizationId = c1.organizationId
      AND b.tariffMasterId = c1.tariffMasterId
    LEFT JOIN BIL_TARIFF_DETAILS a
      ON a.organizationId = b.organizationId
      AND a.tariffId = b.tariffId
  WHERE IFNULL(b.tariffId, '*') <> '*'
  AND c1.organizationId = IN_organizationId
  AND c1.customerId = IN_CustomerId
  AND c1.warehouseId = IN_warehouseId
  AND a.chargeCategory = 'FX';
  /*  AND TIMESTAMPDIFF(SECOND, b.effectiveFrom, NOW()) / (60 * 60 * 24) >= 0
    AND TIMESTAMPDIFF(SECOND, b.effectiveTo, NOW()) / (60 * 60 * 24) <= 0;*/
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET bil_done = TRUE;
  OPEN cur_bilno;
cur_bil_loop:
  LOOP
    FETCH FROM cur_bilno INTO od_organizationId,
    od_warehouseId,
    od_customerId,
    od_tariffMasterId,
    od_tariffId,
    od_chargeType,
    od_fixAmount,
    od_incomeTaxRate,
    od_ratebase,
    od_udf02,
    od_tariffLineNo;

    SELECT
      od_organizationId;
    IF bil_done THEN
      SET bil_done = FALSE;
      LEAVE cur_bil_loop;
    END IF;
  BLOCK2:
    BEGIN
      DECLARE cur_Tariff CURSOR FOR
      SELECT DISTINCT
        bcm.organizationId,
        bcm.warehouseId,
        bcm.customerId,
        DAY(STR_TO_DATE(CONCAT(YEAR(NOW()), '-', MONTH(NOW()), '-', bth.udf02), '%Y-%m-%d')) billingDate, -- change akbar 27-12-24 , correction fix date
        btd.tariffId,
        btd.tariffLineNo,
        btd.chargeCategory,
        btd.chargeType,
        btd.descrC,
        btd.ratebase,
        IF(btd.UDF03 = '', 0, btd.UDF03) AS fixAmount,
        btd.minAmount,
        btd.UDF01 AS MaterialNo,
        btd.udf02 AS itemChargeCategory,
        btd.UDF05,
        btd.UDF06 AS divisionCode,
        btd.UDF07,
        btd.UDF08,
        bth.contractNo,
        bth.tariffMasterId
      FROM BAS_CUSTOMER_MULTIWAREHOUSE bcm
        INNER JOIN BAS_CUSTOMER bc
          ON bc.customerId = bcm.customerId
          AND bc.organizationId = bcm.organizationId
          AND bc.CustomerType = 'OW'
        INNER JOIN BIL_TARIFF_HEADER bth
          ON bth.organizationId = bcm.organizationId
          AND bth.tariffMasterId = bcm.tariffMasterId
        INNER JOIN BIL_TARIFF_DETAILS btd
          ON btd.organizationId = bth.organizationId
          AND btd.tariffId = bth.tariffId
      WHERE bcm.organizationId = 'OJV_CML'
      AND bcm.warehouseId = IN_warehouseId
      AND bcm.customerId = IN_CustomerId
      AND bth.tariffMasterId = od_tariffMasterId
      AND bth.tariffId = od_tariffId
      AND btd.tariffLineNo = od_tariffLineNo
      AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND btd.chargeCategory = 'FX'
      ORDER BY bcm.organizationId, bcm.customerId, btd.chargeCategory, btd.chargeType;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = TRUE;
      ####################################################################
      SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd
      #
      OPEN cur_Tariff;
    getTariff:
      LOOP
        FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC,
        R_ratebase, R_fixAmount, R_minAmount, R_materialNo, R_itemChargeCategory, R_UDF05, R_UDF06, R_UDF07, R_UDF08, R_CONTRACTNO, R_TARIFFMASTERID;
        IF tariff_done THEN
          SET tariff_done = FALSE;
          LEAVE getTariff;
        END IF;
        SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
        SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
        SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
        SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH);
        SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
        SET R_billsummaryId = '';
        --  Di remark karena gk ada fungsi -- AKB 28.4.25
        --         SELECT R_ratebase;
        --         IF (R_ratebase = 'DAY') THEN
        --           SET R_RESULTQTYCHARGE = od_fixAmount;
        --         ELSEIF (R_ratebase = 'MONTH') THEN
        --           SET R_RESULTQTYCHARGE = od_fixAmount;

        --        END IF;
        SELECT
          'check=>',
          R_RESULTQTYCHARGE,
          R_TARIFFID;
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
          SELECT
            '1';
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
          CALL SPCOM_GetIDSequence_NEW('OJV_CML', '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);
          IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
            SET OUT_returnCode = '999#????????';
            LEAVE getTariff;
          END IF;
        END IF;

        -- debug 
        IF R_BILLINGDATE IS NULL THEN
          SELECT
            od_warehouseId,
            od_customerId,
            od_tariffMasterId;
        END IF;

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
            R_BILLINGDATE,
            R_BILLINGDATE,
            od_customerId,
            '' sku,
            '' lotNum,
            '' traceId,
            R_TARIFFID,
            R_CHARGECATEGORY,
            R_chargetype,
            R_descrC,
            R_rateBase,
            1,
            1,
            '' uom,
            0 cubic,
            0 grossWeight,
            od_fixAmount,
            od_fixAmount,
            od_fixAmount,
            0,
            R_RESULTQTYCHARGE,
            0,
            NOW() confirmTime,
            '' confirmWho,
            'FX',
            '' docNo,
            '' createTransactionid,
            '' notes,
            NOW() ediSendTime,
            od_customerId billTo,
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
            R_RESULTQTYCHARGE * R_rateperunit incomeWithoutTax,
            0 cosWithoutTax,
            '' costInvoiceType,
            '' noteText,
            R_materialNo AS udf01,
            R_itemChargeCategory AS udf02,
            '' udf03,
            R_UDF06 udf04,
            '' udf05,
            0 currentVersion,
            '2020' oprSeqFlag,
            IN_USERID addWho,
            NOW() ADDTIME,
            IN_USERID editWho,
            NOW() editTime,
            '' locationCategory,
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
            '' orderType,
            '' containerType,
            '' containerSize;
      END LOOP getTariff;
      CLOSE cur_Tariff;
    END;
  END LOOP cur_bil_loop;
  CLOSE cur_bilno;
  SET OUT_returnCode = '000';
END
$$

--
-- Create procedure `CML_BILLASNVASSTD`
--
CREATE
DEFINER = 'sa'@'%'
PROCEDURE CML_BILLASNVASSTD (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_trans_no varchar(30),
IN IN_tariffMaster varchar(30))
BEGIN


  #####################################################################
  ##????
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
  DECLARE R_RESULTQTYCHARGE decimal(24, 8);  -- add for calculation
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLINGTRANCATEGORY varchar(10);
  DECLARE R_BILLTO varchar(30);
  DECLARE R_VASTYPE varchar(30);
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
  DECLARE od_skuDescr1 varchar(255);
  DECLARE od_warehouseId varchar(255);
  DECLARE od_customerId varchar(255);
  DECLARE od_asnNo varchar(255);
  DECLARE od_asnLineNo varchar(255);
  DECLARE od_sku varchar(255);
  DECLARE od_qtyReceived varchar(255);
  DECLARE od_uom varchar(255);
  DECLARE od_qtyReceivedEach varchar(255);
  DECLARE od_totalCube varchar(255);
  DECLARE od_vasType varchar(255);
  DECLARE od_qtyCharge varchar(255);
  DECLARE od_tarifMaster varchar(255);
  DECLARE OUT_returnCode varchar(1000);
  DECLARE od_closetime timestamp;

  ####################################################################
  ##????
  DECLARE inventory_done int DEFAULT 0;
  DECLARE tariff_done int DEFAULT 0;
  DECLARE order_done,
          attribute_done int DEFAULT 0;



  DECLARE cur_orderno CURSOR FOR
  SELECT
    IFNULL(CAST(dah.organizationId AS char(255)), '') AS organizationId,
    IFNULL(CAST(dah.warehouseId AS char(255)), '') AS warehouseId,
    IFNULL(CAST(dah.customerId AS char(255)), '') AS customerId,
    IFNULL(CAST(dah.asnNo AS char(255)), '') AS asnNo,
    IFNULL(CAST(dah.asnReference1 AS char(255)), '') AS asnReference1,
    IFNULL(CAST(dad.sku AS char(255)), '') AS sku,
    IFNULL(CAST(bs.skuDescr1 AS char(255)), '') AS skuDescr1,
    vsasn.asnLineNo AS asnLineNo,
    IFNULL(CAST(vsasn.vasType AS char(255)), '') AS vasType,
    IFNULL(CAST(vsasn.vasqty AS char(255)), '') AS qtyCharge,
    IFNULL(CAST(vsasn.packUom AS char(255)), '') AS packUom,
    IFNULL(CAST(bsm.tariffMasterId AS char(255)), '') AS tarifMaster,
    dahu.closeTime
  FROM DOC_ASN_HEADER dah
    LEFT OUTER JOIN DOC_ASN_VAS vsasn
      ON dah.organizationId = vsasn.organizationId
      AND dah.warehouseId = vsasn.warehouseId
      AND dah.asnNo = vsasn.asnNo
    LEFT OUTER JOIN DOC_ASN_DETAILS dad
      ON dad.organizationId = vsasn.organizationId
      AND dad.warehouseId = vsasn.warehouseId
      AND dad.asnNo = vsasn.asnNo
      AND dad.asnLineNo = vsasn.asnLineNo
    LEFT OUTER JOIN BAS_SKU bs
      ON bs.organizationId = dad.organizationId
      AND bs.customerId = dad.customerId
      AND bs.SKU = dad.sku
    LEFT OUTER JOIN BAS_SKU_MULTIWAREHOUSE bsm
      ON bsm.organizationId = dah.organizationId
      AND bsm.warehouseId = dah.warehouseId
      AND bsm.customerId = dah.customerId
      AND bsm.SKU = dad.Sku
    LEFT JOIN DOC_ASN_HEADER_UDF dahu
      ON dah.organizationId = dahu.organizationId
      AND dah.warehouseId = dahu.warehouseId
      AND dah.asnNo = dahu.asnNo
  WHERE vsasn.warehouseId = IN_warehouseId
  AND dah.customerId = IN_CustomerId
  AND dah.asnNo = IN_trans_no
  -- AND bsm.tariffMasterId = 'BIL00418'
  AND dah.asnType NOT IN ('FREE')
  AND dah.asnStatus IN ('99')
  GROUP BY dah.organizationId,
           dah.warehouseId,
           dah.asnNo,
           dah.asnReference1,
           dad.sku,
           bs.skuDescr1,
           vsasn.asnLineNo,
           vsasn.vasType,
           vsasn.packUom;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET order_done = 1;
  OPEN cur_orderno;
cur_order_loop:
  LOOP
    FETCH FROM cur_orderno INTO od_organizationId,
    od_warehouseId,
    od_customerId,
    od_asnNo,
    od_asnReference1,
    od_sku,
    od_skuDescr1,
    od_asnLineNo,
    od_vasType,
    od_qtyCharge,
    od_uom,
    od_tarifMaster, od_closetime;

    IF order_done = 1 THEN

      SET order_done = 0;
      LEAVE cur_order_loop;
    END IF;

    SELECT
      CONCAT('** DEBUG:', od_asnNo, od_vasType, od_tarifMaster) AS debug;

  BLOCK2:
    BEGIN
      --  IF (od_tariffMasterId <> '') THEN

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
        btd.billingParty,
        -- btd.billingTranCategory,
        IFNULL(CAST(btd.billingTranCategory AS char(10)), '') AS billingTranCategory,
        btd.vasType
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
      AND bth.tariffMasterId = od_tarifMaster
      AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND btd.chargeCategory = 'VA'
      AND btd.tariffLineNo <= 100
      --       AND btd.docType IN (SELECT
      --           dah.asnType
      --         FROM DOC_ASN_HEADER dah
      --         WHERE dah.asnNo = IN_trans_no)
      AND btr.rate > 0
      AND btd.vasType = od_vasType
      #AND IFNULL(DAY(bth.billingdate),0)!=0 
      ORDER BY bsm.organizationId, bsm.customerId, btr.tariffId, btr.tariffLineNo, btr.tariffClassNo;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;

      SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd
      #
      OPEN cur_Tariff;
    getTariff:
      LOOP
        FETCH cur_Tariff INTO R_ORGANIZATIONID, R_WAREHOUSEID, R_CUSTOMERID, R_BILLINGDAY, R_TARIFFID, R_TARIFFLINENO, R_TARIFFCLASSNO, R_CHARGECATEGORY, R_CHARGETYPE, R_descrC, R_docType,
        R_ratebase, R_ratePerUnit, R_rate, R_minAmount, R_maxAmount, R_minQty, R_materialNo, R_itemChargeCategory, R_billMode, R_LOCATIONCAT, R_LOCATIONGROUP, R_UDF06, R_UDF07, R_UDF08,
        R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO, R_TARIFFMASTERID, R_Cost, R_BILLINGPARTY, R_BILLINGTRANCATEGORY, R_VASTYPE;
        IF tariff_done THEN
          SET tariff_done = FALSE;
          LEAVE getTariff;
        END IF;


        SELECT
          UPPER(R_VASTYPE),
          UPPER(od_vasType),
          R_docType;

        IF (UPPER(R_VASTYPE) = UPPER(od_vasType)) THEN
          -- CALCULATION
          -- UOM
          -- PALLET
          -- CUBIC
          -- M2
          -- CASE
          -- IP
          -- PIECES
          -- KG
          -- LITER
          -- DO
          -- HOUR
          -- MONTH



          SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
          SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
          SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
          SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);
          SET R_Days = DATEDIFF(R_TODATE, R_FMDATE) + 1;
          SET R_billsummaryId = '';


          SET R_RESULTQTYCHARGE = od_qtyCharge;






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
          #
          IF (R_billsummaryId = '') THEN
            SET @linenumber = 0;
            SET OUT_returnCode = '*_*';
            CALL SPCOM_GetIDSequence_NEW(R_ORGANIZATIONID, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);
            IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
              SET OUT_returnCode = '999#????????';
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
              od_organizationId,
              od_warehouseId,
              CONCAT(R_billsummaryId, '*', LPAD((@linenumber := @linenumber + 1), 3, '0')),
              DATE_FORMAT(od_closetime, '%Y-%m-%d'),
              DATE_FORMAT(od_closetime, '%Y-%m-%d'),
              od_customerId,
              od_sku,
              '',
              '',
              R_TARIFFID,
              R_CHARGECATEGORY,
              R_chargetype,
              R_descrC,
              R_rateBase,
              R_rateperunit,
              od_qtyCharge,
              od_uom,
              '0',
              '0',
              R_rate,
              R_RESULTQTYCHARGE * R_rate / R_rateperunit,
              (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) + (R_RESULTQTYCHARGE * (R_rate / R_rateperunit)) * R_INCOMETAX,
              0,
              R_cost * R_RESULTQTYCHARGE,
              0,
              NULL confirmTime,
              '' confirmWho,
              'ASN' dockType,
              od_asnNo,
              '' createTransactionid,
              R_CHARGETYPE notes,
              NULL ediSendTime,
              R_BILLTO billTo,
              NULL settleTime,
              '' settleWho,
              '' followUp,
              '' invoiceType,
              '' paidTo,
              '' costConfirmFlag,
              NULL costConfirmTime,
              '' costConfirmWho,
              '' costSettleFlag,
              NULL costSettleTime,
              '' costSettleWho,
              NULL incomeTaxRate,
              0 costTaxRate,
              NULL incomeTax,
              0 cosTax,
              NULL incomeWithoutTax,
              NULL cosWithoutTax,
              '' costInvoiceType,
              '' noteText,
              R_materialNo AS udf01,
              R_itemChargeCategory AS udf02,
              R_UDF08 udf03,
              R_UDF06 udf04,
              NULL udf05,
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
              NULL ediSendTime2,
              'N' ediSendFlag2,
              '' ediErrorCode2,
              '' ediErrorMessage2,
              '' billingTranCategory,
              '' orderType,
              '' containerType,
              '' containerSize;

        END IF; -- END IF docType

      END LOOP getTariff;
      CLOSE cur_Tariff;


    --  END IF; 
    --  END IF TARIFF ORDER KOSONG
    END;




  END LOOP cur_order_loop;
  CLOSE cur_orderno;
  SET OUT_returnCode = '000';
END
$$

DELIMITER ;