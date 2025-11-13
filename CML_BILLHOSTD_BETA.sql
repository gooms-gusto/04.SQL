USE wms_cml;

DROP PROCEDURE IF EXISTS CML_BILLHOSTD_BETA;

DELIMITER $$

CREATE 
	DEFINER = 'root'@'localhost'
PROCEDURE CML_BILLHOSTD_BETA(IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_trans_no varchar(30),
IN IN_tariffMaster varchar(30),
OUT p_success_flag CHAR(1),
OUT p_message VARCHAR(1000),
OUT p_record_count INT)
BEGIN
  ####################################################################

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

  ##游标定义
  DECLARE inventory_done int DEFAULT FALSE;
  DECLARE tariff_done int DEFAULT FALSE;


  DECLARE order_done,
          attribute_done boolean DEFAULT FALSE;




            IF (R_billsummaryId = '') THEN
              SET @linenumber = 0;
              SET OUT_returnCode = '*_*';
              CALL SPCOM_GetIDSequence_NEW(IN_organizationId, '*', IN_Language, 'BILLINGSUMMARYIDCUST', R_billsummaryId, OUT_returnCode);
             
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
SELECT fch.organizationId organizationId,
fch.warehouseId warehouseId,
CONCAT(R_billsummaryId,'*',LPAD(auto_sequence(), 3, '0')) billingSummaryId,
 DATE_FORMAT(fch.ShipmentTime, '%Y-%m-%d') billingFromDate,
DATE_FORMAT(fch.ShipmentTime, '%Y-%m-%d') billingToDate,
fch.customerId customerId,
fch.sku sku,
fch.lotNum lotNum,
fch.traceId traceId,
fch.tariffId tariffId,
fch.chargeCategory chargeCategory,
fch.chargeType chargeType,
fch.descrC descr,
fch.ratebase rateBase,
fch.ratePerUnit chargePerUnits,
fch.qtyChargeBilling qty,
fch.uom uom,
fch.totalCube cubic,
fch.grossWeight weight,
fch.rate chargeRate,
fch.qtyChargeBilling * fch.rate/fch.ratePerUnit amount,
(fch.qtyChargeBilling * (fch.rate / fch.ratePerUnit)) + (fch.qtyChargeBilling*(fch.rate/fch.ratePerUnit)) * 0 billingAmount,
fch.cost cost,
fch.cost * fch.qtyChargeBilling amountPayable,
0 amountPaid,
NOW() confirmTime,
'' confirmWho,
'SO' docType,
fch.orderNo docNo,
'' createTransactionid,
'' notes,
      NOW() ediSendTime,
                '' billTo,
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
                fch.IncomeTaxRate incomeTax,
                0 cosTax,
                fch.qtyChargeBilling * fch.rate / fch.ratePerUnit incomeWithoutTax,
                0 cosWithoutTax,
                '' costInvoiceType,
                '' noteText,
                fch.udf01 AS udf01,
                fch.udf02 AS udf02,
                fch.allocationDetailsId udf03,
                fch.udf06 udf04,
                '' udf05,
                0 currentVersion,
                '2020' oprSeqFlag,
                'CUSTOMBILL' addWho,
                NOW() ADDTIME,
                'CUSTOMBILL' editWho,
                NOW() editTime,
                fch.locationCategory locationCategory,
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
                fch.orderType orderType,
                '' containerType,
                '' containerSize
FROM (
SELECT
    doh.organizationId,
    doh.warehouseId,
    aad.customerId,
    doh.orderNo,
    doh.soReference1,
    doh.soReference3,
    doh.orderType,
    t1.codeType AS docType,
    aad.orderLineNo,
    aad.SKU,
    DATE_FORMAT(aad.shipmentTime, '%Y-%m-%d') AS ShipmentTime,
    aad.qty,
    aad.qty_each,
    aad.qtyShipped_each,
    aad.uom,    
    -- Special quantity calculation for MAP customer with specific lot attributes
    CASE 
        WHEN aad.customerId = 'MAP' 
            AND ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') 
            AND bsm.tariffMasterId LIKE '%PIECE%' 
        THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
        ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
    END AS qtyChargeEA,
    
    CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdCS.qty, 0))) AS qtyChargeCS,
    COALESCE(CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdIP.qty, 0))), 1) AS qtyChargeIP,
    CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdPL.qty, 0))) AS qtyChargePL,
    SUM(aad.qtyShipped_each * bs.cube) AS qtyChargeCBM,
    COUNT(DISTINCT doh.orderNo) AS qtyChargeTotDO,
    COUNT(DISTINCT aad.orderLineNo) AS qtyChargeTotLine,
    SUM(aad.qtyShipped_each * bs.cube) AS totalCube,
    
    aad.editTime,
    aad.lotNum,
    aad.traceId,
    aad.pickToTraceId,
    aad.dropId,
    aad.location,
    aad.pickToLocation,
    aad.allocationDetailsId,
    bs.skuDescr1,
    bs.grossWeight,
    bs.cube AS cubeNya,
    bsm.tariffMasterId,
    bpdCS.qty AS QtyPerCases,
    bpdPL.qty AS QtyPerPallet,
    bz.zoneDescr AS zone,
    ila.lotAtt04 AS batch,
    IFNULL(ila.lotAtt07, '') AS lotAtt07,
    IFNULL(BT.codeid, '') AS billtranctg,
    SUM(aad.qtyShipped_each * bs.netWeight) AS qtyChargeNettWeight,
    
    -- Gross weight calculation with unit conversion
    CASE 
        WHEN bpdEA.uomDescr IN ('G', 'GRAM', 'Gram') 
        THEN SUM(aad.qtyShipped_each / 1000) 
        WHEN bpdEA.uomDescr IN ('MT', 'Metric Ton', 'METRIC TON') 
        THEN SUM(aad.qtyShipped_each * 1000) 
        ELSE SUM(aad.qtyShipped_each * bs.grossWeight) 
    END AS qtyChargeGrossWeight,
    
    -- Metric ton calculation based on customer
    CASE 
        WHEN aad.customerId LIKE '%ABC%' 
        THEN SUM((aad.qtyShipped_each * bpdCS.qty) / 1000) 
        WHEN aad.customerId IN ('ADASBY', 'CAI_MDN', 'CAI_SBY') 
        THEN IFNULL(CAST(SUM((aad.qtyShipped_each * bs.netweight) / 1000) AS CHAR(255)), 0) 
        ELSE SUM(aad.qtyShipped_each / 1000) 
    END AS qtyChargeMetricTon,
    
    df.closeTime,
    -- Complex billing quantity calculation based on rate base
    CASE 
        WHEN btd.ratebase = 'CUBIC' 
        THEN SUM(aad.qtyShipped_each * bs.cube)
        
        WHEN btd.ratebase = 'M2' 
        THEN CASE 
            WHEN aad.customerId = 'MAP' 
                AND ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') 
                AND bsm.tariffMasterId LIKE '%PIECE%' 
            THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
            ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
        END
        
        WHEN btd.ratebase = 'IP' 
        THEN COALESCE(CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdIP.qty, 0))), 1)
        
        WHEN btd.ratebase = 'KG' 
        THEN CASE 
            WHEN aad.customerId = 'MAP' 
                AND ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') 
                AND bsm.tariffMasterId LIKE '%PIECE%' 
            THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
            ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
        END
        
        WHEN btd.ratebase = 'LITER' 
        THEN CASE 
            WHEN aad.customerId = 'MAP' 
                AND ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') 
                AND bsm.tariffMasterId LIKE '%PIECE%' 
            THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
            ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
        END
        
        WHEN btd.ratebase = 'QUANTITY' 
        THEN CASE 
            WHEN aad.customerId = 'MAP' 
                AND ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') 
                AND bsm.tariffMasterId LIKE '%PIECE%' 
            THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
            ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
        END
        
        WHEN btd.ratebase = 'DO' 
        THEN COUNT(DISTINCT doh.orderNo)
        
        WHEN btd.ratebase = 'PALLET' 
        THEN CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdPL.qty, 0)))
        
        WHEN btd.ratebase = 'CASE' 
        THEN CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdCS.qty, 0)))
        
        WHEN btd.ratebase = 'NETWEIGHT' 
        THEN SUM(aad.qtyShipped_each * bs.netWeight)
        
        WHEN btd.ratebase = 'GW' 
        THEN CASE 
            WHEN bpdEA.uomDescr IN ('G', 'GRAM', 'Gram') 
            THEN SUM(aad.qtyShipped_each / 1000) 
            WHEN bpdEA.uomDescr IN ('MT', 'Metric Ton', 'METRIC TON') 
            THEN SUM(aad.qtyShipped_each * 1000) 
            ELSE SUM(aad.qtyShipped_each * bs.grossWeight) 
        END
        
        WHEN btd.ratebase = 'MT' 
        THEN CASE 
            WHEN aad.customerId LIKE '%ABC%' 
            THEN SUM((aad.qtyShipped_each * bpdCS.qty) / 1000) 
            WHEN aad.customerId IN ('ADASBY', 'CAI_MDN', 'CAI_SBY') 
            THEN IFNULL(CAST(SUM((aad.qtyShipped_each * bs.netweight) / 1000) AS CHAR(255)), 0) 
            ELSE SUM(aad.qtyShipped_each / 1000) 
        END
        
        ELSE 0 
    END AS qtyChargeBilling,
    btr.rate,
    btd.ratebase, btr.tariffId,
          btr.tariffLineNo,
          btr.tariffClassNo,
          btd.chargeCategory,
          btd.chargeType,btd.descrC,btr.ratePerUnit,
           btd.minAmount,
          btd.maxAmount,
          IF(btd.UDF03 = '', 0, btd.UDF03) minQty,
          btd.UDF01,
          btd.udf02,
          btd.udf04,
          btd.UDF05,
          btd.UDF06,
          btd.UDF07,
          btd.UDF08,
          IFNULL(btd.incomeTaxRate, 0) IncomeTaxRate,
          CASE WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1 ELSE IFNULL(btr.classfrom, 0) END,
          IFNULL(classTo, 0),
          bth.contractNo,
          btr.cost,
          btd.billingParty,bl.locationCategory
FROM ACT_ALLOCATION_DETAILS aad

    -- Main order header join
    INNER JOIN DOC_ORDER_HEADER doh
        ON doh.organizationId = aad.organizationId
        AND doh.customerId = aad.customerId
        AND doh.orderNo = aad.orderNo
        AND doh.orderType NOT IN ('FREE', 'KT', 'TROF', 'TTG')

    -- Order header UDF for close time
    LEFT JOIN DOC_ORDER_HEADER_UDF df
        ON doh.organizationId = df.organizationId
        AND doh.warehouseId = df.warehouseId
        AND doh.orderNo = df.orderNo

    -- SKU master data
    INNER JOIN BAS_SKU bs
        ON bs.organizationId = aad.organizationId
        AND bs.SKU = aad.SKU
        AND bs.customerId = aad.customerId
        AND bs.skuDescr1 NOT LIKE '%PALLET%'

    -- SKU multiwarehouse data
    INNER JOIN BAS_SKU_MULTIWAREHOUSE bsm
        ON bsm.organizationId = bs.organizationId
        AND bsm.SKU = bs.SKU
        AND bsm.customerId = bs.customerId
        AND bsm.warehouseId = aad.warehouseId

    -- Inventory lot attributes
    LEFT JOIN INV_LOT_ATT ila
        ON ila.organizationId = aad.organizationId
        AND ila.SKU = aad.SKU
        AND ila.lotnum = aad.lotnum
        AND ila.customerId = aad.customerId
        AND (ila.lotAtt04 IS NULL OR ila.lotAtt04 != 'SET')

    -- Package details for different UOMs
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

    -- Code master for order type description
    LEFT JOIN BSM_CODE_ML t1
        ON t1.organizationId = 'OJV_CML'
        AND t1.codeType = 'SO_TYP'
        AND t1.codeId = doh.orderType
        AND t1.languageId = 'en'

    -- Billing transaction category
    LEFT JOIN BSM_CODE BT
        ON BT.organizationId = 'OJV_CML'
        AND BT.codeType = 'BILLING_TRANSACTION_CATEGORY'
        AND BT.outerCode = ila.lotAtt07

    -- Location and zone data
    LEFT JOIN BAS_LOCATION bl
        ON bl.organizationId = aad.organizationId
        AND bl.warehouseId = aad.warehouseId
        AND bl.locationId = aad.location

    LEFT JOIN BAS_ZONE bz
        ON bz.organizationId = bl.organizationId
        AND bz.warehouseId = bl.warehouseId
        AND bz.zoneId = bl.zoneId
        AND bz.zoneGroup = bl.zoneGroup

    -- Billing tariff data
    LEFT JOIN BIL_TARIFF_HEADER bth
        ON bth.organizationId = bsm.organizationId
        AND bth.tariffMasterId = bsm.tariffMasterId

    LEFT JOIN BIL_TARIFF_DETAILS btd
        ON btd.organizationId = bth.organizationId
        AND btd.tariffId = bth.tariffId
        AND btd.docType = doh.orderType

    LEFT JOIN BIL_TARIFF_RATE btr
        ON btr.organizationId = btd.organizationId
        AND btr.tariffId = btd.tariffId
        AND btr.tariffLineNo = btd.tariffLineNo

WHERE 
    aad.organizationId = IN_organizationId
    AND aad.customerId = IN_CustomerId
    AND aad.warehouseId = IN_warehouseId
    AND aad.orderNo = IN_trans_no
    AND aad.Status IN ('99', '80')
    AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
    AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
    AND btd.chargeCategory = 'OB'
    AND (CASE 
        WHEN btd.billingTranCategory IS NULL THEN BT.codeid 
        WHEN btd.billingTranCategory = '' THEN BT.codeid 
        ELSE btd.billingTranCategory 
    END) = BT.codeid
    AND btr.rate > 0
    AND NOT EXISTS (
        SELECT 1
        FROM Z_SKUNOTBILLING zsnb
        WHERE zsnb.organizationId = 'OJV_CML'
            AND zsnb.customerId = aad.customerId
            AND zsnb.sku = aad.sku
    )

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
    t1.codeDescr,
    bz.zoneDescr,
    ila.lotAtt04,
    ila.lotAtt07,
    BT.codeid,
    df.closeTime,
    bs.netWeight,
    bpdEA.qty,
    bpdEA.uomDescr,
    bpdCS.qty,
    bpdIP.qty,
    bpdPL.qty,
    btr.rate,
    btd.ratebase,btr.tariffId,
          btr.tariffLineNo,
          btr.tariffClassNo,
          btd.chargeCategory,
          btd.chargeType,btd.descrC,btr.ratePerUnit,
           btd.minAmount,
          btd.maxAmount,
          btd.UDF03,
          btd.UDF01,
          btd.udf02 ,
          btd.udf04,
          btd.UDF05,
          btd.UDF06,
          btd.UDF07,
          btd.UDF08,
btd.incomeTaxRate,
          bth.contractNo,
          bth.tariffMasterId,
          btr.cost,bl.locationCategory) fch;




END
$$

DELIMITER ;