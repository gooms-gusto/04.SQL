USE WMS_FTEST;

DROP PROCEDURE IF EXISTS OJV_CML_SPUDF_Process1;

DELIMITER $$

CREATE
DEFINER = 'wms_ftest'@'%'
PROCEDURE OJV_CML_SPUDF_Process1 (IN `IN_warehouseId` varchar(20),
IN `IN_userId` varchar(20),
OUT `OUT_returnCode` varchar(1000))
ENDPROC:
  BEGIN
    DECLARE IN_organizationId varchar(100) DEFAULT 'OJV_CML';
    DECLARE r_arriveTime timestamp;
    DECLARE r_cutoff timestamp;
    DECLARE r_RNOW1 int;
    DECLARE r_RNOW2 int;
    DECLARE r_RNOW3 int;
    DECLARE r_tariffId varchar(100);
    DECLARE r_orderType varchar(100);
    DECLARE r_appointmentDate timestamp;
    DECLARE r_docNo varchar(100);
    DECLARE r_ARRIVALNO varchar(100);
    DECLARE r_docType varchar(100);
    DECLARE r_udf01 int;
    DECLARE r_arrivedata int;
    DECLARE r_latehour varchar(100);
    DECLARE IN_Language varchar(100);
    DECLARE R_BILLINGSUMMARYID varchar(100);
    DECLARE done int DEFAULT FALSE;
    DECLARE r_ttlrest int;
    DECLARE CUR_APP CURSOR FOR
    SELECT DISTINCT
      A.entranceTime,
      CAST(
      CONCAT(
      DATE(C.appointmentDate),
      ' ',
      C.startTime
      ) AS datetime
      ) AS appointmentTime,
      CASE WHEN D.docType = 'LOAD' THEN E.ldlNo WHEN D.docType = 'SO' THEN G.ORDERNO WHEN D.docType = 'ASN' THEN H.ASNNO ELSE D.docNo END AS docNo,
      CASE WHEN D.docType = 'LOAD' THEN F1.orderType WHEN D.docType = 'SO' THEN G.orderType WHEN D.docType = 'ASN' THEN I.asnType ELSE G.orderType END AS orderType,
      D.docType,
      A.ARRIVALNO
    FROM DOC_ARRIVAL_HEADER A
      LEFT JOIN DOC_ARRIVAL_DETAILS B
        ON A.organizationId = B.organizationId
        AND A.arrivalNo = B.arrivalno
      LEFT JOIN DOC_APPOINTMENT_HEADER C
        ON B.organizationId = C.organizationId
        AND B.appointmentno = C.appointmentNo
      LEFT JOIN DOC_APPOINTMENT_DETAILS D
        ON C.organizationId = D.organizationId
        AND C.appointmentNo = D.appointmentNo
      LEFT JOIN DOC_LOADING_HEADER E
        ON E.organizationId = D.organizationId
        AND E.warehouseId = A.warehouseId
        AND E.ldlNo = D.docNo
        AND D.docType = 'LOAD'
      LEFT JOIN DOC_WAVE_DETAILS F
        ON E.organizationId = F.organizationId
        AND E.warehouseId = F.warehouseId
        AND E.WAVENO = F.WAVENO
      LEFT JOIN DOC_WAVE_HEADER F1
        ON E.organizationId = F1.organizationId
        AND E.warehouseId = F1.warehouseId
        AND E.WAVENO = F1.WAVENO
      LEFT JOIN DOC_ORDER_HEADER G
        ON G.organizationId = D.organizationId
        AND G.warehouseId = A.warehouseId
        AND G.ORDERNO = D.docNo
        AND D.docType = 'SO'
      LEFT JOIN DOC_ASN_DETAILS H
        ON H.organizationId = D.organizationId
        AND H.warehouseId = A.warehouseId
        AND H.ASNNO = D.docNo
        AND D.docType = 'ASN'
      LEFT JOIN DOC_ASN_HEADER I
        ON H.organizationId = I.organizationId
        AND H.warehouseid = I.warehouseid
        AND H.asnNO = I.asnNo
        AND D.docType = 'ASN'
    WHERE A.organizationId = 'OJV_CML'
    AND A.warehouseId = IN_warehouseId
    AND A.udf01 <> 'Y'
    AND docNo IS NOT NULL
    AND A.arrivalStatus NOT IN ('00', '90', '99');
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN CUR_APP;
  read_loop:
    LOOP
      FETCH CUR_APP INTO r_arriveTime,
      r_appointmentDate,
      r_docNo,
      r_orderType,
      r_docType,
      r_ARRIVALNO;
      IF done THEN
        LEAVE read_loop;
      END IF;
      SELECT
        MAX(udf01),
        MAX(tariffId)
      FROM (SELECT
          D.udf01 AS udf01,
          D.tariffId AS tariffId
        FROM DOC_APPOINTMENT_DETAILS A
          LEFT JOIN DOC_ORDER_DETAILS B
            ON A.`organizationId` = B.`organizationId`
            AND A.`warehouseId` = B.`warehouseId`
            AND A.`docNo` = B.`orderNo`
          LEFT JOIN BAS_CUSTOMER_MULTIWAREHOUSE C
            ON C.`organizationId` = B.`organizationId`
            AND C.`warehouseId` = B.`warehouseId`
            AND C.`customerId` = B.`customerId`
            AND C.`customerType` = 'OW'
          LEFT JOIN BIL_TARIFF_HEADER D
            ON D.`organizationId` = C.`organizationId`
            AND D.tariffMasterId = C.tariffMasterId
        WHERE D.udf01 IS NOT NULL
        AND A.organizationId = IN_organizationId
        AND B.warehouseId = IN_warehouseId
        AND B.ORDERNO = r_docNo
        AND IFNULL(D.tariffId, '*') <> '*'
        AND TIMESTAMPDIFF(SECOND, D.effectiveFrom, NOW()) / (60 * 60 * 24) >= 0
        AND TIMESTAMPDIFF(SECOND, D.effectiveTo, NOW()) / (60 * 60 * 24) <= 0
        UNION
        SELECT
          D.udf01 AS udf01,
          D.tariffId AS tariffId
        FROM DOC_APPOINTMENT_DETAILS A
          LEFT JOIN DOC_ASN_DETAILS B
            ON A.organizationId = B.organizationId
            AND A.warehouseId = B.warehouseId
            AND A.docNo = B.asnNo
          LEFT JOIN BAS_CUSTOMER_MULTIWAREHOUSE C
            ON B.`organizationId` = C.`organizationId`
            AND B.`warehouseId` = C.`warehouseId`
            AND B.customerId = C.`customerId`
            AND C.customerType = 'OW'
          LEFT JOIN BIL_TARIFF_HEADER D
            ON D.`organizationId` = C.`organizationId`
            AND D.tariffMasterId = C.tariffMasterId
        WHERE D.udf01 IS NOT NULL
        AND A.organizationId = IN_organizationId
        AND B.warehouseId = IN_warehouseId
        AND B.asnNo = r_docNo
        AND IFNULL(D.tariffId, '*') <> '*'
        AND TIMESTAMPDIFF(SECOND, D.effectiveFrom, NOW()) / (60 * 60 * 24) >= 0
        AND TIMESTAMPDIFF(SECOND, D.effectiveTo, NOW()) / (60 * 60 * 24) <= 0
        UNION
        SELECT
          D.udf01 AS udf01,
          D.tariffId AS tariffId
        FROM DOC_APPOINTMENT_DETAILS A
          LEFT JOIN DOC_LOADING_HEADER E
            ON E.organizationId = A.organizationId
            AND E.warehouseId = A.warehouseId
            AND A.docNo = E.ldlNo
          LEFT JOIN DOC_WAVE_DETAILS F
            ON E.organizationId = F.organizationId
            AND E.warehouseId = F.warehouseId
            AND E.WAVENO = F.WAVENO
          LEFT JOIN DOC_ORDER_DETAILS B
            ON F.`organizationId` = B.`organizationId`
            AND F.`warehouseId` = B.`warehouseId`
            AND F.orderNo = B.orderNo
          LEFT JOIN BAS_CUSTOMER_MULTIWAREHOUSE C
            ON B.`organizationId` = C.`organizationId`
            AND B.`warehouseId` = C.`warehouseId`
            AND B.customerId = C.customerId
            AND C.`customerType` = 'OW'
          LEFT JOIN BIL_TARIFF_HEADER D
            ON D.`organizationId` = C.`organizationId`
            AND D.tariffMasterId = C.tariffMasterId
        WHERE D.udf01 IS NOT NULL
        AND A.organizationId = IN_organizationId
        AND B.warehouseId = IN_warehouseId
        AND E.ldlNo = r_docNo
        AND IFNULL(D.tariffId, '*') <> '*'
        AND TIMESTAMPDIFF(SECOND, D.effectiveFrom, NOW()) / (60 * 60 * 24) >= 0
        AND TIMESTAMPDIFF(SECOND, D.effectiveTo, NOW()) / (60 * 60 * 24) <= 0) BILLTARIFF INTO r_udf01,
      r_tariffId;
      SELECT
        EXTRACT(HOUR_MINUTE FROM r_arriveTime) INTO r_arrivedata;

      -- Update orderType to overtime 
      IF r_arrivedata > r_udf01
        AND r_udf01 <> 0 THEN
        IF r_docType = 'ASN'
          AND r_orderType <> 'CROSS' THEN
          UPDATE DOC_ASN_HEADER A
          SET A.asnType = 'OV'
          WHERE A.organizationId = IN_organizationId
          AND A.warehouseId = IN_warehouseId
          AND A.asnNo = r_docNo
          AND A.asnType <> 'CROSS'
          AND A.carrierId NOT IN ('LINC_EXP', '5000000027', 'JNE');
        END IF;
        IF r_docType = 'LOAD'
          AND IFNULL(r_orderType, '') <> 'CROSS' THEN
          UPDATE DOC_ORDER_HEADER A
          LEFT JOIN DOC_WAVE_DETAILS F
            ON A.organizationId = F.organizationId
            AND A.warehouseId = F.warehouseId
            AND A.WAVENO = F.WAVENO
          LEFT JOIN DOC_LOADING_HEADER E
            ON E.organizationId = F.organizationId
            AND E.warehouseId = F.warehouseId
            AND E.waveNo = F.waveNo
          SET A.orderType = 'OT'
          WHERE A.organizationId = IN_organizationId
          AND A.warehouseId = IN_warehouseId
          AND E.ldlNo = r_docNo
          AND IFNULL(r_orderType, '') <> 'CROSS'
          AND (A.carrierId NOT IN ('LINC_EXP', '5000000027', 'JNE')
          OR e.carrierId NOT IN ('LINC_EXP', '5000000027', 'JNE'));
        END IF;
        IF r_docType = 'SO'
          AND r_orderType = 'CROSS' THEN
          UPDATE DOC_ORDER_HEADER A
          SET A.ordertype = 'COT'
          WHERE A.organizationId = IN_organizationId
          AND A.warehouseId = IN_warehouseId
          AND A.orderno = r_docNo
          AND A.orderType <> 'CROSS';
        END IF;
        IF r_docType = 'SO'
          AND r_orderType <> 'CROSS' THEN
          UPDATE DOC_ORDER_HEADER A
          SET A.ordertype = 'OT'
          WHERE A.organizationId = IN_organizationId
          AND A.warehouseId = IN_warehouseId
          AND A.orderno = r_docNo
          AND A.orderType <> 'CROSS';
        END IF;
        IF r_docType = 'ASN'
          AND r_orderType = 'CROSS' THEN
          UPDATE DOC_ASN_HEADER A
          SET A.asnType = 'COT'
          WHERE A.organizationId = IN_organizationId
          AND A.warehouseId = IN_warehouseId
          AND A.asnNo = r_docNo
          AND A.asnType = 'CROSS';
        END IF;
        IF r_docType = 'LOAD'
          AND r_orderType = 'CROSS' THEN
          UPDATE DOC_ORDER_HEADER A
          LEFT JOIN DOC_WAVE_DETAILS F
            ON A.organizationId = F.organizationId
            AND A.warehouseId = F.warehouseId
            AND A.WAVENO = F.WAVENO
          LEFT JOIN DOC_LOADING_HEADER E
            ON E.organizationId = F.organizationId
            AND E.warehouseId = F.warehouseId
            AND E.waveNo = F.waveNo
          SET A.orderType = 'COT'
          WHERE A.organizationId = 'OJV_CML'
          AND A.warehouseId = IN_warehouseid
          AND E.ldlNo = r_docno
          AND A.orderType = 'CROSS';
        END IF;
        SET r_cutoff = CAST(
        CONCAT(
        CURDATE(),
        ' ',
        TIME_FORMAT(CONCAT(r_udf01, '00'), '%T')
        ) AS datetime
        );
        SET r_ttlrest = 0;
        IF (
          CAST('12:00:00' AS time) BETWEEN TIME_FORMAT(r_cutoff, "%T")
          AND TIME_FORMAT(r_arriveTime, "%T")
          )
          AND (
          CAST('18:00:00' AS time) BETWEEN TIME_FORMAT(r_cutoff, "%T")
          AND TIME_FORMAT(r_arriveTime, "%T")
          ) THEN
          SET r_ttlrest = 2;
        ELSE
          IF (
            CAST('12:00:00' AS time) BETWEEN TIME_FORMAT(r_cutoff, "%T")
            AND TIME_FORMAT(r_arriveTime, "%T")
            )
            OR (
            CAST('18:00:00' AS time) BETWEEN TIME_FORMAT(r_cutoff, "%T")
            AND TIME_FORMAT(r_arriveTime, "%T")
            ) THEN
            SET r_ttlrest = 1;
          ELSE
            SET r_ttlrest = 0;
          END IF;
        END IF;
        SELECT
          TIMESTAMPDIFF(HOUR, r_cutoff, r_arriveTime) + 1 - r_ttlrest INTO r_latehour;
        SET OUT_returnCode = 'NO_COMMIT';
        CALL SPCOM_GetIDSequence(IN_organizationId,
        IN_warehouseId,
        IN_Language,
        'BILLINGSUMMARYID',
        R_BILLINGSUMMARYID,
        OUT_returnCode);
        IF SUBSTRING(OUT_returnCode, 1, 3) <> '000' THEN
          ROLLBACK;
          LEAVE ENDPROC;
        END IF;
        IF r_docType = 'ASN' THEN
          SELECT
            COUNT(1) INTO r_RNOW1
          FROM DOC_ASN_HEADER A
            LEFT JOIN DOC_APPOINTMENT_DETAILS A1
              ON A.ORGANIZATIONID = A1.ORGANIZATIONID
              AND A.asnNo = A1.docNo
            LEFT JOIN BAS_CUSTOMER_MULTIWAREHOUSE B
              ON A.ORGANIZATIONID = B.ORGANIZATIONID
              AND A.CUSTOMERID = B.CUSTOMERID
              AND A.WAREHOUSEID = B.WAREHOUSEID
              AND B.CUSTOMERTYPE = 'OW'
            LEFT JOIN BIL_TARIFF_HEADER C
              ON B.ORGANIZATIONID = C.ORGANIZATIONID
              AND B.TARIFFID = C.TARIFFID
            LEFT JOIN BIL_TARIFF_DETAILS D
              ON C.ORGANIZATIONID = D.ORGANIZATIONID
              AND C.TARIFFID = D.TARIFFID
              AND D.CHARGECATEGORY = 'SP'
              AND D.CHARGETYPE = 'SF'
            LEFT JOIN BIL_TARIFF_RATE E
              ON D.ORGANIZATIONID = E.ORGANIZATIONID
              AND D.TARIFFID = E.TARIFFID
              AND D.TARIFFLINENO = E.TARIFFLINENO
          WHERE A.ORGANIZATIONID = IN_organizationId
          AND A.WAREHOUSEID = IN_warehouseId
          AND A.ASNNO = r_docNo
          AND D.CHARGETYPE IS NOT NULL;
          IF r_RNOW1 = 1 THEN
            INSERT INTO BIL_SUMMARY (ORGANIZATIONID,
            WAREHOUSEID,
            BILLINGSUMMARYID,
            BILLINGFROMDATE,
            BILLINGTODATE,
            CUSTOMERID,
            TARIFFID,
            CHARGECATEGORY,
            CHARGETYPE,
            DESCR,
            RATEBASE,
            qty,
            chargeRate,
            AMOUNT,
            BILLINGAMOUNT,
            ARNO,
            APNO,
            COST,
            DOCTYPE,
            DOCNO,
            BILLTO,
            ADDWHO,
            EDITWHO,
            ADDTIME,
            EDITTIME,
            UDF01,
            UDF02,
            UDF04)
              SELECT
                A.ORGANIZATIONID,
                A.WAREHOUSEID,
                R_BILLINGSUMMARYID,
                CURDATE(),
                CURDATE(),
                A.CUSTOMERID,
                B.TARIFFID,
                D.CHARGECATEGORY,
                D.CHARGETYPE,
                D.DESCRC,
                'HOUR',
                r_latehour,
                E.rate,
                r_latehour * E.RATE,
                r_latehour * E.RATE,
                '*',
                '*',
                0,
                'ASN',
                A.ASNNO,
                A.CUSTOMERID,
                'UDFTIMER',
                'UDFTIMER',
                NOW(),
                NOW(),
                D.UDF01,
                D.UDF02,
                D.UDF06
              FROM DOC_ASN_HEADER A
                LEFT JOIN BAS_CUSTOMER_MULTIWAREHOUSE B
                  ON A.ORGANIZATIONID = B.ORGANIZATIONID
                  AND A.CUSTOMERID = B.CUSTOMERID
                  AND A.WAREHOUSEID = B.WAREHOUSEID
                  AND B.CUSTOMERTYPE = 'OW'
                LEFT JOIN BIL_TARIFF_HEADER C
                  ON B.ORGANIZATIONID = C.ORGANIZATIONID
                  AND B.TARIFFID = C.TARIFFID
                LEFT JOIN BIL_TARIFF_DETAILS D
                  ON C.ORGANIZATIONID = D.ORGANIZATIONID
                  AND C.TARIFFID = D.TARIFFID
                  AND D.CHARGECATEGORY = 'SP'
                  AND D.CHARGETYPE = 'SF'
                LEFT JOIN BIL_TARIFF_RATE E
                  ON D.ORGANIZATIONID = E.ORGANIZATIONID
                  AND D.TARIFFID = E.TARIFFID
                  AND D.TARIFFLINENO = E.TARIFFLINENO
              WHERE A.ORGANIZATIONID = IN_organizationId
              AND A.WAREHOUSEID = IN_warehouseId
              AND A.ASNNO = r_docNo
              LIMIT 1;
          END IF;
        END IF;
        IF r_docType = 'SO' THEN
          SELECT
            COUNT(1) INTO r_RNOW2
          FROM DOC_ORDER_HEADER A
            LEFT JOIN BAS_CUSTOMER_MULTIWAREHOUSE B
              ON A.ORGANIZATIONID = B.ORGANIZATIONID
              AND A.CUSTOMERID = B.CUSTOMERID
              AND A.WAREHOUSEID = B.WAREHOUSEID
              AND B.CUSTOMERTYPE = 'OW'
            LEFT JOIN BIL_TARIFF_HEADER C
              ON B.ORGANIZATIONID = C.ORGANIZATIONID
              AND B.TARIFFID = C.TARIFFID
            LEFT JOIN BIL_TARIFF_DETAILS D
              ON C.ORGANIZATIONID = D.ORGANIZATIONID
              AND C.TARIFFID = D.TARIFFID
              AND D.CHARGECATEGORY = 'SP'
              AND D.CHARGETYPE = 'SF'
            LEFT JOIN BIL_TARIFF_RATE E
              ON D.ORGANIZATIONID = E.ORGANIZATIONID
              AND D.TARIFFID = E.TARIFFID
              AND D.TARIFFLINENO = E.TARIFFLINENO
          WHERE A.ORGANIZATIONID = IN_organizationId
          AND A.WAREHOUSEID = IN_warehouseId
          AND A.orderNo = r_docNo
          AND D.CHARGETYPE IS NOT NULL;
          IF r_RNOW2 = 1 THEN
            INSERT INTO BIL_SUMMARY (ORGANIZATIONID,
            WAREHOUSEID,
            BILLINGSUMMARYID,
            BILLINGFROMDATE,
            BILLINGTODATE,
            CUSTOMERID,
            TARIFFID,
            CHARGECATEGORY,
            CHARGETYPE,
            DESCR,
            RATEBASE,
            qty,
            chargeRate,
            AMOUNT,
            BILLINGAMOUNT,
            ARNO,
            APNO,
            COST,
            DOCTYPE,
            DOCNO,
            BILLTO,
            ADDWHO,
            EDITWHO,
            ADDTIME,
            EDITTIME,
            UDF01,
            UDF02,
            UDF04)
              SELECT
                A.ORGANIZATIONID,
                A.WAREHOUSEID,
                R_BILLINGSUMMARYID,
                CURDATE(),
                CURDATE(),
                A.CUSTOMERID,
                B.TARIFFID,
                D.CHARGECATEGORY,
                D.CHARGETYPE,
                D.DESCRC,
                'HOUR',
                r_latehour,
                E.rate,
                r_latehour * E.RATE,
                r_latehour * E.RATE,
                '*',
                '*',
                0,
                'SO',
                A.orderNo,
                A.CUSTOMERID,
                'UDFTIMER',
                'UDFTIMER',
                NOW(),
                NOW(),
                D.UDF01,
                D.UDF02,
                D.UDF06
              FROM DOC_ORDER_HEADER A
                LEFT JOIN DOC_APPOINTMENT_DETAILS A1
                  ON A.ORGANIZATIONID = A1.ORGANIZATIONID
                  AND A.orderNo = A1.docNo
                LEFT JOIN BAS_CUSTOMER_MULTIWAREHOUSE B
                  ON A.ORGANIZATIONID = B.ORGANIZATIONID
                  AND A.CUSTOMERID = B.CUSTOMERID
                  AND A.WAREHOUSEID = B.WAREHOUSEID
                  AND B.CUSTOMERTYPE = 'OW'
                LEFT JOIN BIL_TARIFF_HEADER C
                  ON B.ORGANIZATIONID = C.ORGANIZATIONID
                  AND B.TARIFFID = C.TARIFFID
                LEFT JOIN BIL_TARIFF_DETAILS D
                  ON C.ORGANIZATIONID = D.ORGANIZATIONID
                  AND C.TARIFFID = D.TARIFFID
                  AND D.CHARGECATEGORY = 'SP'
                  AND D.CHARGETYPE = 'SF'
                LEFT JOIN BIL_TARIFF_RATE E
                  ON D.ORGANIZATIONID = E.ORGANIZATIONID
                  AND D.TARIFFID = E.TARIFFID
                  AND D.TARIFFLINENO = E.TARIFFLINENO
              WHERE A.ORGANIZATIONID = IN_organizationId
              AND A.WAREHOUSEID = IN_warehouseId
              AND A.orderNo = r_docNo
              LIMIT 1;
          END IF;
        END IF;
        IF r_docType = 'LOAD' THEN
          SELECT
            COUNT(1) INTO r_RNOW3
          FROM DOC_LOADING_HEADER A
            LEFT JOIN DOC_APPOINTMENT_DETAILS A1
              ON A.organizationId = A1.organizationId
              AND A.ldlNo = A1.`docNo`
            LEFT JOIN DOC_WAVE_DETAILS F
              ON A.organizationId = F.organizationId
              AND A.warehouseId = F.warehouseId
              AND A.WAVENO = F.WAVENO
            LEFT JOIN DOC_ORDER_DETAILS B
              ON B.organizationId = F.organizationId
              AND B.warehouseId = F.warehouseId
              AND B.ORDERNO = F.ORDERNO
            LEFT JOIN BAS_CUSTOMER_MULTIWAREHOUSE B2
              ON B.`organizationId` = B2.organizationId
              AND B.`warehouseId` = B2.warehouseId
              AND B.customerId = B2.`customerId`
              AND B2.`customerType` = 'OW'
            LEFT JOIN BIL_TARIFF_HEADER C
              ON B2.ORGANIZATIONID = C.ORGANIZATIONID
              AND B2.TARIFFID = C.TARIFFID
            LEFT JOIN BIL_TARIFF_DETAILS D
              ON C.ORGANIZATIONID = D.ORGANIZATIONID
              AND C.TARIFFID = D.TARIFFID
              AND D.CHARGECATEGORY = 'SP'
              AND D.CHARGETYPE = 'SF'
            LEFT JOIN BIL_TARIFF_RATE E
              ON D.ORGANIZATIONID = E.ORGANIZATIONID
              AND D.TARIFFID = E.TARIFFID
              AND D.TARIFFLINENO = E.TARIFFLINENO
          WHERE A.ORGANIZATIONID = IN_organizationId
          AND A.WAREHOUSEID = IN_warehouseId
          AND A.ldlNo = r_docNo
          AND D.CHARGETYPE IS NOT NULL;
          IF r_RNOW3 >= 1 THEN
            INSERT INTO BIL_SUMMARY (ORGANIZATIONID,
            WAREHOUSEID,
            BILLINGSUMMARYID,
            BILLINGFROMDATE,
            BILLINGTODATE,
            CUSTOMERID,
            TARIFFID,
            CHARGECATEGORY,
            CHARGETYPE,
            DESCR,
            RATEBASE,
            qty,
            chargeRate,
            AMOUNT,
            BILLINGAMOUNT,
            ARNO,
            APNO,
            COST,
            DOCTYPE,
            DOCNO,
            BILLTO,
            ADDWHO,
            EDITWHO,
            ADDTIME,
            EDITTIME,
            UDF01,
            UDF02,
            UDF04)
              SELECT
                A.ORGANIZATIONID,
                A.WAREHOUSEID,
                R_BILLINGSUMMARYID,
                CURDATE(),
                CURDATE(),
                G.CUSTOMERID,
                B.TARIFFID,
                D.CHARGECATEGORY,
                D.CHARGETYPE,
                D.DESCRC,
                'HOUR',
                r_latehour,
                E.rate,
                r_latehour * E.RATE,
                r_latehour * E.RATE,
                '*',
                '*',
                0,
                'SO',
                A.ldlNo,
                G.CUSTOMERID,
                'UDFTIMER',
                'UDFTIMER',
                NOW(),
                NOW(),
                D.UDF01,
                D.UDF02,
                D.UDF06
              FROM DOC_LOADING_HEADER A
                LEFT JOIN DOC_APPOINTMENT_DETAILS A1
                  ON A.ORGANIZATIONID = A1.ORGANIZATIONID
                  AND A.ldlNo = A1.docNo
                LEFT JOIN DOC_WAVE_DETAILS F
                  ON A.`organizationId` = F.`organizationId`
                  AND A.`warehouseId` = F.`warehouseId`
                  AND A.waveNo = F.waveNo
                LEFT JOIN DOC_ORDER_DETAILS G
                  ON F.`organizationId` = G.`organizationId`
                  AND F.`warehouseId` = G.warehouseId
                  AND F.`orderNo` = G.orderNo
                LEFT JOIN BAS_CUSTOMER_MULTIWAREHOUSE B
                  ON A.ORGANIZATIONID = B.ORGANIZATIONID
                  AND G.CUSTOMERID = B.CUSTOMERID
                  AND A.WAREHOUSEID = B.WAREHOUSEID
                  AND B.CUSTOMERTYPE = 'OW'
                LEFT JOIN BIL_TARIFF_HEADER C
                  ON B.ORGANIZATIONID = C.ORGANIZATIONID
                  AND B.TARIFFID = C.TARIFFID
                LEFT JOIN BIL_TARIFF_DETAILS D
                  ON C.ORGANIZATIONID = D.ORGANIZATIONID
                  AND C.TARIFFID = D.TARIFFID
                  AND D.CHARGECATEGORY = 'SP'
                  AND D.CHARGETYPE = 'SF'
                LEFT JOIN BIL_TARIFF_RATE E
                  ON D.ORGANIZATIONID = E.ORGANIZATIONID
                  AND D.TARIFFID = E.TARIFFID
                  AND D.TARIFFLINENO = E.TARIFFLINENO
              WHERE A.ORGANIZATIONID = IN_organizationId
              AND A.WAREHOUSEID = IN_warehouseId
              AND A.ldlNo = r_docNo
              LIMIT 1;
          END IF;
        END IF;
      END IF;
      UPDATE DOC_ARRIVAL_HEADER A
      SET A.udf01 = 'Y'
      WHERE A.ORGANIZATIONID = IN_organizationId
      AND A.ARRIVALNO = r_ARRIVALNO
      AND A.arrivalStatus NOT IN ('00', '90', '99');
    END LOOP;
    CLOSE CUR_APP;
    SET OUT_returnCode := '000';
  END
$$

DELIMITER ;