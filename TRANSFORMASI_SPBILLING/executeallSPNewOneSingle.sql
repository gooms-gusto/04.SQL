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
-- Create procedure `Z_SP_ProcessBillingCML_BILLVASSPECIALSTD`
--
CREATE
DEFINER = 'mysql.sys'@'%'
PROCEDURE Z_SP_ProcessBillingCML_BILLVASSPECIALSTD ()
    SP:
  BEGIN
    -- Deklarasi variabel untuk menyimpan data dari cursor
    DECLARE v_organizationId varchar(20);
    DECLARE v_warehouseId varchar(20);
    DECLARE v_customerId varchar(30);
    DECLARE v_trans_no varchar(20);
    DECLARE v_spName varchar(30);
    DECLARE v_flag int DEFAULT 0;
    -- Variabel untuk mengontrol loop
    DECLARE done int DEFAULT FALSE;



    -- Deklarasi cursor
    DECLARE billing_cursor CURSOR FOR

    SELECT
      dvh.organizationId,
      dvh.warehouseId,
      dvh.customerId,
      dvh.vasNo,
      zbccd.spName
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
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
        ON (dvh.organizationId = zbcc.organizationId
        AND dvh.warehouseId = zbcc.warehouseId
        AND dvh.customerId = zbcc.customerId)
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
        ON (zbcc.organizationId = zbccd.organizationId
        AND zbcc.lotatt01 = zbccd.idGroupSp)
      INNER JOIN BAS_SKU_MULTIWAREHOUSE bsm
        ON bsm.organizationId = dvd.organizationId
        AND bsm.warehouseId = dvd.warehouseId
        AND bsm.customerId = dvd.customerId
        AND bsm.SKU = dvd.sku
      INNER JOIN (SELECT
          btd.organizationId,
          btd.warehouseId,
          bth.tariffMasterId,
          btd.tariffId,
          btr.rate,
          btd.chargeCategory,
          btd.chargeType,
          btd.vasType,
          btd.udf01,
          btd.udf06
        FROM BIL_TARIFF_HEADER bth
          LEFT JOIN BIL_TARIFF_DETAILS btd
            ON btd.organizationId = bth.organizationId
            AND btd.tariffId = bth.tariffId
          LEFT JOIN BIL_TARIFF_RATE btr
            ON btr.organizationId = btd.organizationId
            AND btr.tariffId = btd.tariffId
            AND btr.tariffLineNo = btd.tariffLineNo
        WHERE btd.organizationId = 'OJV_CML'
        AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        AND btd.chargeCategory = 'VA'
        -- AND btd.vasType <> ''
        AND btd.tariffLineNo > 100
        AND btr.rate > 0
        GROUP BY btd.organizationId,
                 btd.warehouseId,
                 btd.tariffId,
                 btr.rate,
                 btd.chargeCategory,
                 btd.chargeType,
                 btd.vasType,
                 btd.udf01,
                 btd.UDF06) bil
        ON bil.organizationId = bsm.organizationId
        AND bil.warehouseId = bsm.warehouseId
        AND bil.tariffMasterId = bsm.tariffMasterId
        AND bil.vasType = dvs.vasType
        AND bil.chargeCategory = dvf.chargeCategory
        AND bil.chargeType = dvf.chargeType
    WHERE dvh.organizationId = 'OJV_CML'
    -- AND dvh.warehouseId='@warehouse' 
    -- AND dvh.customerId='@customer'
    AND zbcc.lotatt01 <> ''
    AND zbcc.active = 'Y'
    AND zbccd.active = 'Y'
    AND zbccd.spName = 'CML_BILLVASSPECIALSTD'
    AND dvh.vasStatus = '99'
    AND DATE(dvh.editTime) >= getBillFMDate(25)
    AND NOT EXISTS (SELECT
        1
      FROM BIL_SUMMARY bs
      WHERE bs.organizationId = 'OJV_CML'
      AND bs.warehouseId = dvh.warehouseId
      AND bs.customerId = dvh.customerId
      AND bs.docNo = dvh.vasNo
      AND bs.chargeCategory = 'VA'
      AND DATE(bs.addTime) >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
    ORDER BY dvh.editTime ASC;


    -- Handler untuk kondisi NOT FOUND
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Buka cursor
    OPEN billing_cursor;

      -- Loop untuk memproses setiap baris
      read_loop:
    LOOP
      -- Fetch data dari cursor
      FETCH billing_cursor INTO v_organizationId,
      v_warehouseId,
      v_customerId,
      v_trans_no,
      v_spName;

      -- Jika tidak ada data lagi, keluar dari loop
      IF done THEN

        LEAVE read_loop;
      END IF;




      SET @IN_organizationId = v_organizationId;
      SET @IN_warehouseId = v_warehouseId;
      SET @IN_USERID = 'CUSTOMBILL';
      SET @IN_Language = 'en';
      SET @IN_CustomerId = v_customerId;
      SET @IN_trans_no = v_trans_no;
      CALL CML_BILLVASSPECIALSTD_NW(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @p_success_flag, @p_message, @p_record_count);


    END LOOP;


    -- Tutup cursor
    CLOSE billing_cursor;



  END
  $$

--
-- Create procedure `Z_SP_ProcessBillingCML_BILLSOVASSTD`
--
CREATE
DEFINER = 'mysql.sys'@'%'
PROCEDURE Z_SP_ProcessBillingCML_BILLSOVASSTD ()
    SP:
  BEGIN
    -- Deklarasi variabel untuk menyimpan data dari cursor
    DECLARE v_organizationId varchar(20);
    DECLARE v_warehouseId varchar(20);
    DECLARE v_customerId varchar(30);
    DECLARE v_trans_no varchar(20);
    DECLARE v_spName varchar(30);
    DECLARE v_flag int DEFAULT 0;
    -- Variabel untuk mengontrol loop
    DECLARE done int DEFAULT FALSE;



    -- Deklarasi cursor
    DECLARE billing_cursor CURSOR FOR

    SELECT
      dov.organizationId,
      dov.warehouseId,
      doh.customerId,
      dov.orderNo,
      zbccd.spName
    FROM DOC_ORDER_VAS dov
      INNER JOIN DOC_ORDER_HEADER doh
        ON dov.organizationId = doh.organizationId
        AND dov.warehouseId = doh.warehouseId
        AND dov.orderNo = doh.orderNo
      INNER JOIN DOC_ORDER_HEADER_UDF dahu
        ON dov.organizationId = dahu.organizationId
        AND dov.warehouseId = dahu.warehouseId
        AND dov.orderNo = dahu.orderNo
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
        ON (dov.organizationId = zbcc.organizationId
        AND dov.warehouseId = zbcc.warehouseId
        AND doh.customerId = zbcc.customerId)
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
        ON (zbcc.organizationId = zbccd.organizationId
        AND zbcc.lotatt01 = zbccd.idGroupSp)
    WHERE dov.organizationId = 'OJV_CML'
    AND DATE(dahu.closeTime) >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    AND zbcc.lotatt01 <> ''
    AND zbcc.active = 'Y'
    AND zbccd.active = 'Y'
    AND doh.soStatus IN ('99')
    AND doh.orderType NOT IN ('FREE')
    AND zbccd.spName = 'CML_BILLSOVASSTD'
    AND NOT EXISTS (SELECT
        1
      FROM BIL_SUMMARY
      WHERE organizationId = doh.organizationId
      AND warehouseId = doh.warehouseId
      AND customerId = doh.customerId
      AND chargeCategory = 'VA'
      AND docNo = dov.orderNo
      AND addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH));


    -- Handler untuk kondisi NOT FOUND
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Buka cursor
    OPEN billing_cursor;

      -- Loop untuk memproses setiap baris
      read_loop:
    LOOP
      -- Fetch data dari cursor
      FETCH billing_cursor INTO v_organizationId,
      v_warehouseId,
      v_customerId,
      v_trans_no,
      v_spName;

      -- Jika tidak ada data lagi, keluar dari loop
      IF done THEN

        LEAVE read_loop;
      END IF;




      SET @IN_organizationId = 'OJV_CML';
      SET @IN_warehouseId = v_warehouseId;
      SET @IN_USERID = 'CUSTOMBILL';
      SET @IN_Language = 'en';
      SET @IN_CustomerId = v_customerId;
      SET @IN_trans_no = v_trans_no;
      CALL CML_BILLSOVASSTD_NW(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @p_success_flag, @p_message, @p_record_count);


    END LOOP;


    -- Tutup cursor
    CLOSE billing_cursor;



  END
  $$

--
-- Create procedure `Z_SP_ProcessBillingCML_BILLHOSTD_TYPE2`
--
CREATE
DEFINER = 'mysql.sys'@'%'
PROCEDURE Z_SP_ProcessBillingCML_BILLHOSTD_TYPE2 ()
    SP:
  BEGIN
    -- Deklarasi variabel untuk menyimpan data dari cursor
    DECLARE v_organizationId varchar(20);
    DECLARE v_warehouseId varchar(20);
    DECLARE v_customerId varchar(30);
    DECLARE v_trans_no varchar(20);
    DECLARE v_spName varchar(30);
    DECLARE v_flag int DEFAULT 0;
    -- Variabel untuk mengontrol loop
    DECLARE done int DEFAULT FALSE;



    -- Deklarasi cursor
    DECLARE billing_cursor CURSOR FOR

    SELECT
      doh.organizationId,
      doh.warehouseId,
      doh.customerId,
      doh.orderNo AS trans_no,
      zbccd.spName
    FROM DOC_ORDER_HEADER doh
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
        ON (doh.organizationId = zbcc.organizationId
        AND doh.warehouseId = zbcc.warehouseId
        AND doh.customerId = zbcc.customerId)
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
        ON zbcc.organizationId = zbccd.organizationId
        AND zbcc.lotatt01 = zbccd.idGroupSp
    WHERE doh.organizationId = 'OJV_CML'
    AND doh.orderType NOT IN ('FREE', 'KT', 'TROF', 'TTG')
    --   doh.warehouseId='' AND
    AND doh.soStatus = '99'
    AND zbcc.lotatt01 <> ''
    AND zbcc.active = 'Y'
    AND zbccd.active = 'Y'
    AND zbccd.spName = 'CML_BILLHOSTD_TYPE2'
    AND doh.orderTime >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    AND NOT EXISTS (SELECT
        1
      FROM BIL_SUMMARY bs
      WHERE bs.organizationId = 'OJV_CML'
      AND bs.docNo = doh.orderNo
      AND bs.warehouseId = doh.warehouseId
      AND bs.customerId = doh.customerId
      AND bs.chargeCategory = 'OB'
      AND bs.addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
    --  GROUP BY doh.organizationId,doh.warehouseId, doh.customerId,trans_no,zbccd.spName
    ORDER BY doh.orderTime ASC;



    -- Handler untuk kondisi NOT FOUND
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Buka cursor
    OPEN billing_cursor;

      -- Loop untuk memproses setiap baris
      read_loop:
    LOOP
      -- Fetch data dari cursor
      FETCH billing_cursor INTO v_organizationId,
      v_warehouseId,
      v_customerId,
      v_trans_no,
      v_spName;

      -- Jika tidak ada data lagi, keluar dari loop
      IF done THEN

        LEAVE read_loop;
      END IF;




      SET @IN_organizationId = 'OJV_CML';
      SET @IN_warehouseId = v_warehouseId;
      SET @IN_USERID = 'CUSTOMBILL';
      SET @IN_Language = 'en';
      SET @IN_CustomerId = v_customerId;
      SET @IN_trans_no = v_trans_no;
      CALL CML_BILLHOSTD_TYPE2_NW(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @p_success_flag, @p_message, @p_record_count);


    END LOOP;

    UPDATE Z_SP_BILLING_LOCK zsbl
    SET zsbl.flag = 0,
        zsbl.changeTime = NOW()
    WHERE zsbl.spName = 'CML_BILLHOSTD_TYPE2';
    -- Tutup cursor
    CLOSE billing_cursor;



  END
  $$

--
-- Create procedure `Z_SP_ProcessBillingCML_BILLHOSTD`
--
CREATE
DEFINER = 'mysql.sys'@'%'
PROCEDURE Z_SP_ProcessBillingCML_BILLHOSTD ()
    SP:
  BEGIN
    -- Deklarasi variabel untuk menyimpan data dari cursor
    DECLARE v_organizationId varchar(20);
    DECLARE v_warehouseId varchar(20);
    DECLARE v_customerId varchar(30);
    DECLARE v_trans_no varchar(20);
    DECLARE v_spName varchar(30);
    DECLARE v_flag int DEFAULT 0;
    -- Variabel untuk mengontrol loop
    DECLARE done int DEFAULT FALSE;



    -- Deklarasi cursor
    DECLARE billing_cursor CURSOR FOR

    SELECT
      doh.organizationId,
      doh.warehouseId,
      doh.customerId,
      doh.orderNo AS trans_no,
      zbccd.spName
    FROM DOC_ORDER_HEADER doh
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
        ON (doh.organizationId = zbcc.organizationId
        AND doh.warehouseId = zbcc.warehouseId
        AND doh.customerId = zbcc.customerId)
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
        ON zbcc.organizationId = zbccd.organizationId
        AND zbcc.lotatt01 = zbccd.idGroupSp
    WHERE doh.organizationId = 'OJV_CML'
    AND doh.orderType NOT IN ('FREE', 'KT', 'TROF', 'TTG')
    --   doh.warehouseId='' AND
    AND doh.soStatus = '99'
    AND zbcc.lotatt01 <> ''
    AND zbcc.active = 'Y'
    AND zbccd.active = 'Y'
    AND zbccd.spName = 'CML_BILLHOSTD'
    AND doh.orderTime >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    AND NOT EXISTS (SELECT
        1
      FROM BIL_SUMMARY bs
      WHERE bs.organizationId = 'OJV_CML'
      AND bs.docNo = doh.orderNo
      AND bs.warehouseId = doh.warehouseId
      AND bs.customerId = doh.customerId
      AND bs.chargeCategory = 'OB'
      AND bs.addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
    --  GROUP BY doh.organizationId,doh.warehouseId, doh.customerId,trans_no,zbccd.spName
    ORDER BY doh.orderTime ASC;



    -- Handler untuk kondisi NOT FOUND
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Buka cursor
    OPEN billing_cursor;

      -- Loop untuk memproses setiap baris
      read_loop:
    LOOP
      -- Fetch data dari cursor
      FETCH billing_cursor INTO v_organizationId,
      v_warehouseId,
      v_customerId,
      v_trans_no,
      v_spName;

      -- Jika tidak ada data lagi, keluar dari loop
      IF done THEN

        LEAVE read_loop;
      END IF;




      SET @IN_organizationId = 'OJV_CML';
      SET @IN_warehouseId = v_warehouseId;
      SET @IN_USERID = 'CUSTOMBILL';
      SET @IN_Language = 'en';
      SET @IN_CustomerId = v_customerId;
      SET @IN_trans_no = v_trans_no;
      CALL CML_BILLHOSTD_BETA(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @p_success_flag, @p_message, @p_record_count);


    END LOOP;

    UPDATE Z_SP_BILLING_LOCK zsbl
    SET zsbl.flag = 0,
        zsbl.changeTime = NOW()
    WHERE zsbl.spName = 'CML_BILLHOSTD';
    -- Tutup cursor
    CLOSE billing_cursor;



  END
  $$

--
-- Create procedure `Z_SP_ProcessBillingCML_BILLHISTD_TYPE2`
--
CREATE
DEFINER = 'mysql.sys'@'%'
PROCEDURE Z_SP_ProcessBillingCML_BILLHISTD_TYPE2 ()
    SP:
  BEGIN
    -- Deklarasi variabel untuk menyimpan data dari cursor
    DECLARE v_organizationId varchar(20);
    DECLARE v_warehouseId varchar(20);
    DECLARE v_customerId varchar(30);
    DECLARE v_trans_no varchar(20);
    DECLARE v_spName varchar(30);
    DECLARE v_flag int DEFAULT 0;
    -- Variabel untuk mengontrol loop
    DECLARE done int DEFAULT FALSE;



    -- Deklarasi cursor
    DECLARE billing_cursor CURSOR FOR

    SELECT
      dah.organizationId,
      dah.warehouseId,
      dah.customerId,
      dah.asnNo AS trans_no,
      zbccd.spName
    FROM DOC_ASN_HEADER dah
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
        ON (dah.organizationId = zbcc.organizationId
        AND dah.warehouseId = zbcc.warehouseId
        AND dah.customerId = zbcc.customerId)
      INNER JOIN DOC_ASN_HEADER_UDF dahu
        ON (dah.organizationId = dahu.organizationId
        AND dah.warehouseId = dahu.warehouseId
        AND dah.asnNo = dahu.asnNo)
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
        ON zbcc.organizationId = zbccd.organizationId
        AND zbcc.lotatt01 = zbccd.idGroupSp
    WHERE dah.organizationId = 'OJV_CML'
    AND dah.asnType NOT IN ('FREE', 'KT', 'TROF', 'TTG')
    --   doh.warehouseId='' AND
    AND dah.asnStatus = '99'
    AND zbcc.lotatt01 <> ''
    AND zbcc.active = 'Y'
    AND zbccd.active = 'Y'
    AND zbccd.spName = 'CML_BILLHISTD_TYPE2'
    AND dahu.closeTime >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    AND NOT EXISTS (SELECT
        1
      FROM BIL_SUMMARY bs
      WHERE bs.organizationId = 'OJV_CML'
      AND bs.docNo = dah.asnNo
      AND bs.warehouseId = dah.warehouseId
      AND bs.customerId = dah.customerId
      AND bs.chargeCategory = 'IB'
      AND bs.addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
    --  GROUP BY doh.organizationId,doh.warehouseId, doh.customerId,trans_no,zbccd.spName
    ORDER BY dah.editTime ASC;




    -- Handler untuk kondisi NOT FOUND
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Buka cursor
    OPEN billing_cursor;

      -- Loop untuk memproses setiap baris
      read_loop:
    LOOP
      -- Fetch data dari cursor
      FETCH billing_cursor INTO v_organizationId,
      v_warehouseId,
      v_customerId,
      v_trans_no,
      v_spName;

      -- Jika tidak ada data lagi, keluar dari loop
      IF done THEN

        LEAVE read_loop;
      END IF;




      SET @IN_organizationId = 'OJV_CML';
      SET @IN_warehouseId = v_warehouseId;
      SET @IN_USERID = 'CUSTOMBILL';
      SET @IN_Language = 'en';
      SET @IN_CustomerId = v_customerId;
      SET @IN_trans_no = v_trans_no;
      CALL CML_BILLHISTD_TYPE2_NW(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @p_success_flag, @p_message, @p_record_count);


    END LOOP;



    -- Tutup cursor
    CLOSE billing_cursor;



  END
  $$

--
-- Create procedure `Z_SP_ProcessBillingCML_BILLHISTD`
--
CREATE
DEFINER = 'mysql.sys'@'%'
PROCEDURE Z_SP_ProcessBillingCML_BILLHISTD ()
    SP:
  BEGIN
    -- Deklarasi variabel untuk menyimpan data dari cursor
    DECLARE v_organizationId varchar(20);
    DECLARE v_warehouseId varchar(20);
    DECLARE v_customerId varchar(30);
    DECLARE v_trans_no varchar(20);
    DECLARE v_spName varchar(30);
    DECLARE v_flag int DEFAULT 0;
    -- Variabel untuk mengontrol loop
    DECLARE done int DEFAULT FALSE;



    -- Deklarasi cursor
    DECLARE billing_cursor CURSOR FOR

    SELECT
      dah.organizationId,
      dah.warehouseId,
      dah.customerId,
      dah.asnNo AS trans_no,
      zbccd.spName
    FROM DOC_ASN_HEADER dah
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
        ON (dah.organizationId = zbcc.organizationId
        AND dah.warehouseId = zbcc.warehouseId
        AND dah.customerId = zbcc.customerId)
      INNER JOIN DOC_ASN_HEADER_UDF dahu
        ON (dah.organizationId = dahu.organizationId
        AND dah.warehouseId = dahu.warehouseId
        AND dah.asnNo = dahu.asnNo)
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
        ON zbcc.organizationId = zbccd.organizationId
        AND zbcc.lotatt01 = zbccd.idGroupSp
    WHERE dah.organizationId = 'OJV_CML'
    AND dah.asnType NOT IN ('FREE', 'KT', 'TROF', 'TTG')
    --   doh.warehouseId='' AND
    AND dah.asnStatus = '99'
    AND zbcc.lotatt01 <> ''
    AND zbcc.active = 'Y'
    AND zbccd.active = 'Y'
    AND zbccd.spName = 'CML_BILLHISTD'
    AND dahu.closeTime >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    AND NOT EXISTS (SELECT
        1
      FROM BIL_SUMMARY bs
      WHERE bs.organizationId = 'OJV_CML'
      AND bs.docNo = dah.asnNo
      AND bs.warehouseId = dah.warehouseId
      AND bs.customerId = dah.customerId
      AND bs.chargeCategory = 'IB'
      AND bs.addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH))
    --  GROUP BY doh.organizationId,doh.warehouseId, doh.customerId,trans_no,zbccd.spName
    ORDER BY dah.editTime ASC;




    -- Handler untuk kondisi NOT FOUND
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Buka cursor
    OPEN billing_cursor;

      -- Loop untuk memproses setiap baris
      read_loop:
    LOOP
      -- Fetch data dari cursor
      FETCH billing_cursor INTO v_organizationId,
      v_warehouseId,
      v_customerId,
      v_trans_no,
      v_spName;

      -- Jika tidak ada data lagi, keluar dari loop
      IF done THEN

        LEAVE read_loop;
      END IF;




      SET @IN_organizationId = 'OJV_CML';
      SET @IN_warehouseId = v_warehouseId;
      SET @IN_USERID = 'CUSTOMBILL';
      SET @IN_Language = 'en';
      SET @IN_CustomerId = v_customerId;
      SET @IN_trans_no = v_trans_no;
      CALL CML_BILLHISTD_BETA(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @p_success_flag, @p_message, @p_record_count);


    END LOOP;

    UPDATE Z_SP_BILLING_LOCK zsbl
    SET zsbl.flag = 0,
        zsbl.changeTime = NOW()
    WHERE zsbl.spName = 'CML_BILLHISTD';
    -- Tutup cursor
    CLOSE billing_cursor;



  END
  $$

--
-- Create procedure `Z_SP_ProcessBillingCML_BILLASNVASSTD`
--
CREATE
DEFINER = 'mysql.sys'@'%'
PROCEDURE Z_SP_ProcessBillingCML_BILLASNVASSTD ()
    SP:
  BEGIN
    -- Deklarasi variabel untuk menyimpan data dari cursor
    DECLARE v_organizationId varchar(20);
    DECLARE v_warehouseId varchar(20);
    DECLARE v_customerId varchar(30);
    DECLARE v_trans_no varchar(20);
    DECLARE v_spName varchar(30);
    DECLARE v_flag int DEFAULT 0;
    -- Variabel untuk mengontrol loop
    DECLARE done int DEFAULT FALSE;



    -- Deklarasi cursor
    DECLARE billing_cursor CURSOR FOR

    SELECT
      dav.organizationId,
      dav.warehouseId,
      dah.customerId,
      dav.asnNo,
      zbccd.spName
    FROM DOC_ASN_VAS dav
      INNER JOIN DOC_ASN_HEADER dah
        ON dav.organizationId = dah.organizationId
        AND dav.warehouseId = dah.warehouseId
        AND dav.asnNo = dah.asnNo
      INNER JOIN DOC_ASN_HEADER_UDF dahu
        ON dav.organizationId = dahu.organizationId
        AND dav.warehouseId = dahu.warehouseId
        AND dav.asnNo = dahu.asnNo
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING zbcc
        ON (dav.organizationId = zbcc.organizationId
        AND dav.warehouseId = zbcc.warehouseId
        AND dah.customerId = zbcc.customerId)
      INNER JOIN Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd
        ON (zbcc.organizationId = zbccd.organizationId
        AND zbcc.lotatt01 = zbccd.idGroupSp)
    WHERE dav.organizationId = 'OJV_CML'
    AND DATE(dahu.closeTime) >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    AND zbcc.lotatt01 <> ''
    AND zbcc.active = 'Y'
    AND zbccd.active = 'Y'
    AND dah.asnStatus IN ('99')
    AND dah.asnType NOT IN ('FREE')
    AND zbccd.spName = 'CML_BILLASNVASSTD'
    AND NOT EXISTS (SELECT
        1
      FROM BIL_SUMMARY
      WHERE organizationId = dah.organizationId
      AND warehouseId = dah.warehouseId
      AND customerId = dah.customerId
      AND chargeCategory = 'VA'
      AND docNo = dav.asnNo
      AND addTime >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH));


    -- Handler untuk kondisi NOT FOUND
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Buka cursor
    OPEN billing_cursor;

      -- Loop untuk memproses setiap baris
      read_loop:
    LOOP
      -- Fetch data dari cursor
      FETCH billing_cursor INTO v_organizationId,
      v_warehouseId,
      v_customerId,
      v_trans_no,
      v_spName;

      -- Jika tidak ada data lagi, keluar dari loop
      IF done THEN

        LEAVE read_loop;
      END IF;




      SET @IN_organizationId = 'OJV_CML';
      SET @IN_warehouseId = v_warehouseId;
      SET @IN_USERID = 'CUSTOMBILL';
      SET @IN_Language = 'en';
      SET @IN_CustomerId = v_customerId;
      SET @IN_trans_no = v_trans_no;
      CALL CML_BILLASNVASSTD_NW(@IN_organizationId, @IN_warehouseId, @IN_USERID, @IN_Language, @IN_CustomerId, @IN_trans_no, @p_success_flag, @p_message, @p_record_count);


    END LOOP;


    -- Tutup cursor
    CLOSE billing_cursor;



  END
  $$

DELIMITER ;