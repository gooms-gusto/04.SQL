CREATE DEFINER=`wms_ftest`@`%` PROCEDURE `CML_SPSO_CLOSE_AF`(
  IN IN_organizationId VARCHAR (20),
  IN IN_Warehouse VARCHAR (20),
  IN IN_orderNo VARCHAR (100),
  IN IN_OrderSplit VARCHAR (120),
  IN IN_Userid VARCHAR (100),
  OUT OUT_Return_Code VARCHAR (1000)
)
END_PROC :
BEGIN
  DECLARE R_STATUS VARCHAR (20) ;
  DECLARE r_SoStatus VARCHAR (20) ;
  DECLARE R_NROW INTEGER ;
  DECLARE R_NROW2 INTEGER ;
  DECLARE V_udf01 VARCHAR (100) ;
  DECLARE V_udf02 VARCHAR (100) ;
  DECLARE R_CURRENTDATE TIMESTAMP ;
  DECLARE R_BILLINGSUMMARYID2 VARCHAR (100) ;
  DECLARE R_FMDATE VARCHAR (10) ;
  DECLARE R_TODATE VARCHAR (10) ;
  DECLARE r_lotAtt07 VARCHAR (10) ;
  DECLARE r_lotnum VARCHAR (10) ;
  DECLARE r_transactionId VARCHAR (100) ;
  DECLARE R_FMDATE_D DATE ;
  DECLARE R_TODATE_D DATE ;
  DECLARE R_BILLINGDATE INTEGER ;
  DECLARE R_BILLINGMONTH VARCHAR (10) ;
  DECLARE R_CUSTOMER VARCHAR (30) ;
  DECLARE R_tariffId VARCHAR (10) ;
  DECLARE R_tariffLineNo INTEGER ;
  DECLARE R_docType VARCHAR (15) ;
  DECLARE R_minAmount DECIMAL (24, 8) ;
  DECLARE R_maxAmount DECIMAL (24, 8) ;
  DECLARE R_chargeCategory VARCHAR (20) ;
  DECLARE R_chargeType VARCHAR (20) ;
  DECLARE IN_language VARCHAR (20) DEFAULT 'en' ;
  DECLARE R_tariffClassNo VARCHAR (15) ;
  DECLARE R_classFrom DECIMAL (24, 8) ;
  DECLARE R_classTo DECIMAL (24, 8) ;
  DECLARE R_rate DECIMAL (24, 8) ;
  --
  DECLARE R_cusAmount DECIMAL (24, 8) ;
  DECLARE R_QTY INTEGER ;
  -- 创建游标1 客户单据计费需求 
  DECLARE pallet_done INT DEFAULT FALSE ;
  DECLARE done INT DEFAULT FALSE ;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE ;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
  BEGIN
    GET DIAGNOSTICS CONDITION 1 @p1 = RETURNED_SQLSTATE,
    @p2 = MESSAGE_TEXT,
    @p3 = MYSQL_ERRNO,
    @p4 = TABLE_NAME,
    @p5 = COLUMN_NAME ;
    ROLLBACK ;
    SET OUT_Return_Code = CONCAT(
      '999#CML_SPSO_CLOSE_AF',
      IFNULL(@p1, ''),
      ',',
      IFNULL(@p2, ''),
      ',',
      IFNULL(@p3, ''),
      ',',
      IFNULL(@p4, ''),
      ',',
      IFNULL(@p5, '')
    ) ;
    SELECT 
      OUT_Return_Code AS error ;
  END ;
  BEGIN
    DECLARE CUR_PALLET CURSOR FOR 
    SELECT 
      a.tolotnum,
      c.lotAtt07,
      a.transactionid 
    FROM
      ACT_TRANSACTION_LOG a 
      INNER JOIN INV_LOT_ATT c 
        ON a.organizationId = c.organizationId 
        AND a.toLotNum = c.lotnum 
        AND a.tocustomerId = c.customerId 
        AND a.tosku = c.sku 
    WHERE a.organizationId = IN_ORGANIZATIONID 
      AND a.warehouseId = IN_Warehouse 
      AND a.docNo = IN_ORDERNO 
      AND a.transactionType = 'SO' 
      AND a.docType = 'SO' ;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET pallet_done = TRUE ;
    OPEN CUR_PALLET ;
    getPALLET :
    LOOP
      FETCH CUR_PALLET INTO r_lotnum,
      r_lotAtt07,
      r_transactionId ;
      IF pallet_done = TRUE 
      THEN LEAVE getPALLET ;
      END IF ;
      
      IF r_lotAtt07 = 'O' 
      THEN 
      UPDATE 
        ACT_TRANSACTION_LOG a 
      SET
        a.billingTranCategory = 'OP' 
      WHERE a.organizationId = IN_ORGANIZATIONID 
        AND a.warehouseId = IN_WAREHOUSE 
        AND a.docNo = IN_ORDERNO 
        AND a.tolotnum = r_lotnum 
        AND a.transactionId = r_transactionId 
        AND a.transactionType IN ('SO', 'KT', '99') 
        AND a.docType = 'SO' 
        AND a.status = '99' ;
      END IF ;
      IF r_lotAtt07 = 'R' 
      THEN 
      UPDATE 
        ACT_TRANSACTION_LOG a 
      SET
        a.billingTranCategory = 'RP' 
      WHERE a.organizationId = IN_ORGANIZATIONID 
        AND a.warehouseId = IN_WAREHOUSE 
        AND a.docNo = IN_ORDERNO 
        AND a.tolotnum = r_lotnum 
        AND a.docType = 'SO' 
        AND a.transactionId = r_transactionId 
        AND a.transactionType IN ('SO', 'KT', '99') 
        AND a.status = '99' ;
      END IF ;
       IF r_lotAtt07 = 'RPP' 
      THEN 
      UPDATE 
        ACT_TRANSACTION_LOG a 
      SET
        a.billingTranCategory = 'RP1' 
      WHERE a.organizationId = IN_ORGANIZATIONID 
        AND a.warehouseId = IN_WAREHOUSE 
        AND a.docNo = IN_ORDERNO 
        AND a.tolotnum = r_lotnum 
        AND a.docType = 'SO' 
        AND a.transactionId = r_transactionId 
        AND a.transactionType IN ('SO', 'KT', '99') 
        AND a.status = '99' ;
      END IF ;
       IF r_lotAtt07 = 'OPC' 
      THEN 
      UPDATE 
        ACT_TRANSACTION_LOG a 
      SET
        a.billingTranCategory = 'OPC' 
      WHERE a.organizationId = IN_ORGANIZATIONID 
        AND a.warehouseId = IN_WAREHOUSE 
        AND a.docNo = IN_ORDERNO 
        AND a.tolotnum = r_lotnum 
        AND a.docType = 'SO' 
        AND a.transactionId = r_transactionId 
        AND a.transactionType IN ('SO', 'KT', '99') 
        AND a.status = '99' ;
      END IF ;
        IF r_lotAtt07 = 'PP' 
      THEN 
      UPDATE 
        ACT_TRANSACTION_LOG a 
      SET
        a.billingTranCategory = 'RPP' 
      WHERE a.organizationId = IN_ORGANIZATIONID 
        AND a.warehouseId = IN_WAREHOUSE 
        AND a.docNo = IN_ORDERNO 
        AND a.tolotnum = r_lotnum 
        AND a.docType = 'SO' 
        AND a.transactionId = r_transactionId 
        AND a.transactionType IN ('SO', 'KT', '99') 
        AND a.status = '99' ;
      END IF ;
       IF r_lotAtt07 = 'WP' 
      THEN 
      UPDATE 
        ACT_TRANSACTION_LOG a 
      SET
        a.billingTranCategory = 'RWP' 
      WHERE a.organizationId = IN_ORGANIZATIONID 
        AND a.warehouseId = IN_WAREHOUSE 
        AND a.docNo = IN_ORDERNO 
        AND a.tolotnum = r_lotnum 
        AND a.docType = 'SO' 
        AND a.transactionId = r_transactionId 
        AND a.transactionType IN ('SO', 'KT', '99') 
        AND a.status = '99' ;
      END IF ;
    END LOOP getPALLET ;
    CLOSE CUR_PALLET ;
    COMMIT ;
  END ;
  
  SELECT 
    a.customerId INTO R_customer 
  FROM
    DOC_ORDER_DETAILS a 
  WHERE a.organizationId = 'OJV_CML' 
    AND a.warehouseId = IN_warehouse 
    AND a.orderNo = IN_OrderNo 
  LIMIT 1 ;
  SELECT 
    IFNULL(b.tariffId, '*') tariffId INTO R_tariffId 
  FROM
    BAS_CUSTOMER_MULTIWAREHOUSE a 
    LEFT JOIN BIL_TARIFF_HEADER b 
      ON a.organizationId = b.organizationId 
      AND a.tariffMasterId = b.tariffMasterId 
  WHERE IFNULL(b.tariffId, '*') <> '*' 
    AND a.organizationId = 'OJV_CML' 
    AND a.warehouseId = IN_warehouse 
    AND a.customerId = R_customer 
    AND TIMESTAMPDIFF(SECOND, b.effectiveFrom, NOW()) / (60 * 60 * 24) >= 0 
    AND TIMESTAMPDIFF(SECOND, b.effectiveTo, NOW()) / (60 * 60 * 24) <= 0 
  LIMIT 1 ;
  CALL SPCOM_GetIDSequence (
    IN_organizationId,
    IN_warehouse,
    IN_language,
    'BILLINGSUMMARYID',
    R_BILLINGSUMMARYID2,
    OUT_Return_Code
  ) ;
  IF SUBSTRING(OUT_Return_Code, 1, 3) <> '000' 
  THEN ROLLBACK ;
  LEAVE END_PROC ;
  END IF ;
  INSERT INTO BIL_SUMMARY (
    ORGANIZATIONID,
    WAREHOUSEID,
    BILLINGSUMMARYID,
    BILLINGFROMDATE,
    BILLINGTODATE,
    CUSTOMERID,
    TARIFFID,
    CHARGECATEGORY,
    CHARGETYPE,
    DESCR,
    DOCNO,
    DOCTYPE,
    RATEBASE,
    QTY,
    chargeRate,
    AMOUNT,
    BILLINGAMOUNT,
    ARNO,
    APNO,
    UDF01,
    UDF02,
    UDF04,
    COST,
    BILLTO,
    ADDWHO,
    EDITWHO,
    ADDTIME,
    EDITTIME
  ) 
  SELECT 
    H1.ORGANIZATIONID,
    H1.WAREHOUSEID,
    R_BILLINGSUMMARYID2,
    CURDATE(),
    CURDATE(),
    H1.CUSTOMERID,
    R_tariffid,
    D.CHARGECATEGORY,
    D.CHARGETYPE,
    D.DESCRC,
    H1.orderNo,
    'SO',
    'DO',
    '1',
    E.RATE,
    1 * E.RATE,
    1 * E.RATE,
    '*',
    '*',
    D.UDF01,
    D.UDF02,
    D.udf06,
    0,
    B.CUSTOMERID,
    'UDFTIMER',
    'UDFTIMER',
    NOW(),
    NOW() 
  FROM
    ACT_ALLOCATION_DETAILS H1 
    JOIN DOC_ORDER_HEADER H2 
      ON H1.ORGANIZATIONID = H2.ORGANIZATIONID 
      AND H1.WAREHOUSEID = H2.WAREHOUSEID 
      AND H1.CUSTOMERID = H2.CUSTOMERID 
      AND H1.ORDERNO = H2.ORDERNO 
    JOIN BAS_SKU_MULTIWAREHOUSE B 
      ON H1.ORGANIZATIONID = B.ORGANIZATIONID 
      AND H1.WAREHOUSEID = B.WAREHOUSEID 
      AND H1.CUSTOMERID = B.CUSTOMERID 
      AND H1.SKU = B.SKU 
    LEFT JOIN BIL_TARIFF_DETAILS D 
      ON B.ORGANIZATIONID = D.ORGANIZATIONID 
      AND D.CHARGECATEGORY = 'OB' 
      AND D.docType = H2.orderType 
      AND D.RATEBASE = 'DO' 
    LEFT JOIN BIL_TARIFF_RATE E 
      ON E.ORGANIZATIONID = D.ORGANIZATIONID 
      AND E.TARIFFID = D.TARIFFID 
      AND E.TARIFFLINENO = D.TARIFFLINENO 
  WHERE H1.ORGANIZATIONID = 'OJV_CML' 
    AND H1.warehouseId = IN_Warehouse 
    AND H1.orderNo = IN_orderNo 
    AND D.tariffid = R_tariffId 
    AND D.rateBase = 'DO' 
  GROUP BY H1.orderNo,
    B.customerId,
    D.chargeType,
    D.descrC,
    E.rate,
    D.udf01,
    D.udf02,
    D.udf06 ;
  SET OUT_return_Code = '000' ;
END