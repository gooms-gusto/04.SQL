USE wms_cml;

DROP PROCEDURE IF EXISTS CML_BILLSUMMARYPROCESS_MANUAL;

DELIMITER $$

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
      SET OUT_returnCode = '999#计费流水获取异常';
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
      FROM BIL_SUMMARY bs INNER JOIN Z_CML_BILLINGSUMMARYID zcb ON bs.organizationId = zcb.organizationId AND bs.warehouseId = zcb.warehouseId
      AND bs.customerId = zcb.customerId AND bs.billingSummaryId = zcb.billingSummaryId
      WHERE bs.organizationId = IN_organizationId
      AND bs.warehouseId = IN_warehouseId
      AND bs.customerId=IN_customerId
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
        AND bs.billingSummaryId IN (SELECT zcb.billingSummaryId FROM Z_CML_BILLINGSUMMARYID zcb)
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
      
      DELETE FROM Z_CML_BILLINGSUMMARYID;


      COMMIT;
      set OUT_Return_Code=r_generateArno;
    END;
  END
$$

DELIMITER ;