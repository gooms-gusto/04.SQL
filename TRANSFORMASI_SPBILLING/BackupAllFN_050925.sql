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
-- Create function `currval`
--
CREATE
DEFINER = 'wms_cml'@'%'
FUNCTION currval (v_seq_name varchar(50))
RETURNS int(11)
BEGIN
  DECLARE VALUE integer;
  SET VALUE = 0;
  SELECT
    current_val INTO VALUE
  FROM sequence
  WHERE seq_name = v_seq_name;
  RETURN VALUE;
END
$$

--
-- Create function `nextval`
--
CREATE
DEFINER = 'wms_cml'@'%'
FUNCTION nextval (v_seq_name varchar(50))
RETURNS int(11)
BEGIN
  UPDATE sequence
  SET current_val = current_val + increment_val
  WHERE seq_name = v_seq_name;
  RETURN CURRVAL(v_seq_name);
END
$$

--
-- Create function `GETSYS_configuration`
--
CREATE
DEFINER = 'wms_cml'@'%'
FUNCTION GETSYS_configuration (IN_organizationId varchar(20),
IN_BranchID varchar(50),
IN_CustomerID varchar(50),
IN_OrderType varchar(50),
IN_ConfigID varchar(50))
RETURNS varchar(100) CHARSET utf8mb3 COLLATE utf8mb3_bin
BEGIN
  DECLARE v_result varchar(50);
  DECLARE v_error int;
  DECLARE v_defaultValue varchar(100);
  DECLARE v_BranchID varchar(20);
  DECLARE v_customerId varchar(30);
  DECLARE v_orderType varchar(20);
  DECLARE v_configValue varchar(100);
  DECLARE v_activeFlag char(1);

  DECLARE c_configValues CURSOR FOR
  SELECT
    a.defaultValue,
    b.branchid,
    b.customerId,
    b.orderType,
    b.configValue,
    b.activeFlag
  FROM BSM_CONFIG a
    LEFT JOIN BSM_CONFIG_RULES b
      ON a.organizationId = b.organizationId
      AND a.configId = b.configId
  WHERE a.organizationId = IN_organizationId
  AND a.configId = IN_ConfigID
  AND a.activeFlag = 'Y'
  ORDER BY b.configLineNo;


  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_error = 0;


  SET v_error = 1;

  OPEN c_configValues;
  FETCH c_configValues INTO v_defaultValue, v_BranchID, v_customerId, v_orderType, v_configValue, v_activeFlag;
    ENDLOOP:
  WHILE v_error = 1 DO
    IF v_activeFlag = 'Y'
      AND (IFNULL(IN_BranchID, '*') = v_BranchID
      OR v_BranchID = '*')
      AND (IFNULL(IN_CustomerID, '*') = v_customerId
      OR v_customerId = '*')
      AND (INSTR(v_orderType, IN_OrderType) > 0
      OR v_orderType = '*') THEN
      SET v_result = v_configValue;
      LEAVE ENDLOOP;
    END IF;
    FETCH c_configValues INTO v_defaultValue, v_BranchID, v_customerId, v_orderType, v_configValue, v_activeFlag;
  END WHILE;
  CLOSE c_configValues;

  IF IFNULL(v_result, '') = '' THEN
    SET v_result = v_defaultValue;
  END IF;

  RETURN v_result;
END
$$

--
-- Create function `getsys_configuration_D`
--
CREATE
DEFINER = 'wms_cml'@'%'
FUNCTION getsys_configuration_D (IN_organizationId varchar(20),
IN_WarehouseID varchar(50),
IN_CustomerID varchar(50),
IN_OrderType varchar(50),
IN_ConfigID varchar(50),
IN_DefaultValue varchar(100))
RETURNS varchar(100) CHARSET utf8mb3 COLLATE utf8mb3_bin
BEGIN
  DECLARE v_result varchar(100);

  SET v_result = GETSYS_configuration(IN_organizationId, IN_WarehouseID, IN_CustomerID,
  IN_OrderType, IN_ConfigID);

  IF IFNULL(v_result, '') = '' THEN
    SET v_result = IN_DefaultValue;
  END IF;
  RETURN v_result;
END
$$

--
-- Create function `ZgetPPGPalletType`
--
CREATE
DEFINER = 'sa'@'%'
FUNCTION ZgetPPGPalletType (p_organizationId varchar(10), p_warehouseId varchar(30), p_customerId varchar(30), p_orderNo varchar(30), p_allocationDetail varchar(20))
RETURNS varchar(50) CHARSET utf8mb3 COLLATE utf8mb3_bin
BEGIN
  DECLARE PLT_TYP varchar(50);
  DECLARE SO_TYP varchar(50);
  DECLARE SO_NO varchar(50);
  DECLARE COUNT_WOR int(11);
  DECLARE COUNT_PMC int(11);
  DECLARE OD_ORDERNO varchar(50);
  DECLARE OD_ORDERTYPE varchar(50);
  DECLARE OD_SKU varchar(50);
  DECLARE OD_SKUGROUP varchar(50);
  DECLARE OD_CONSIGNEEID varchar(50);
  DECLARE OD_TRACEID varchar(50);
  DECLARE OD_QTY_EA decimal(18, 8);
  DECLARE OD_QTY_EA_INBOUND decimal(18, 8);
  DECLARE OD_CURSORDONE boolean DEFAULT FALSE;
  DECLARE _GETLINEORDER CURSOR FOR
  SELECT
    dod.orderNo,
    doh.ordertype,
    ald.SKU,
    bs.sku_group1,
    doh.consigneeId,
    ald.TRACEID,
    ald.qty_Each
  FROM ACT_ALLOCATION_DETAILS ald
    INNER JOIN DOC_ORDER_DETAILS dod
      ON ald.organizationId = dod.organizationId
      AND ald.warehouseId = dod.warehouseId
      AND ald.orderNo = dod.orderNo
      AND ald.orderLineNo = dod.orderLineNo
      AND ald.customerId = dod.customerId
      AND ald.SKU = dod.SKU
    INNER JOIN DOC_ORDER_HEADER doh
      ON ald.organizationId = doh.organizationId
      AND ald.warehouseId = doh.warehouseId
      AND ald.orderNo = doh.orderNo
      AND ald.customerId = doh.customerId
    INNER JOIN BAS_SKU bs
      ON ald.organizationId = bs.organizationId
      AND ald.SKU = bs.SKU
  WHERE ald.organizationId = p_organizationId
  AND ald.warehouseId = p_warehouseId
  AND ald.customerId = p_customerId
  AND ald.allocationDetailsId = p_allocationDetail;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET OD_CURSORDONE = TRUE;
  OPEN _GETLINEORDER;
    GETLINEORDERLOOP:
  LOOP FETCH FROM _GETLINEORDER INTO OD_ORDERNO, OD_ORDERTYPE, OD_SKU, OD_SKUGROUP, OD_CONSIGNEEID, OD_TRACEID, OD_QTY_EA;
    IF OD_CURSORDONE THEN
      SET OD_CURSORDONE = FALSE;
      LEAVE GETLINEORDERLOOP;
    END IF;

    BEGIN
    -- SELECT OD_ORDERNO,OD_ORDERTYPE,OD_SKU,OD_SKUGROUP,OD_CONSIGNEEID;
    END;
  END LOOP GETLINEORDERLOOP;
  CLOSE _GETLINEORDER;

  -- logic if qty trace ID INBOUND same or not
  SELECT
    SUM(atl.fmQty_Each) INTO OD_QTY_EA_INBOUND
  FROM ACT_TRANSACTION_LOG atl
  WHERE atl.organizationId = p_organizationId
  AND atl.warehouseId = p_warehouseId
  AND atl.FMCustomerID = p_customerId
  AND atl.transactionType = 'PA'
  AND atl.fmId = OD_TRACEID;



  IF (OD_SKUGROUP NOT LIKE '%PMC%') THEN

    -- IF IBC TANK
    IF (OD_SKU = 'KR-E6461/ID/1000K') THEN
      SET PLT_TYP = 'PALLETIZE';
      RETURN PLT_TYP;
    END IF;
    SET PLT_TYP = 'LOOSE';
    RETURN PLT_TYP;
  ELSEIF (OD_SKUGROUP = 'PMC-RM-PKG') THEN
    SET PLT_TYP = 'LOOSE';
    RETURN PLT_TYP;
  ELSE -- IF PMC
    SET PLT_TYP = 'PALLETIZE';
    RETURN PLT_TYP;
  END IF;

  -- #if consignee singapore or vietnam
  IF (OD_CONSIGNEEID IN ('GSG909', 'GVN0921', 'PPG-HCM', 'PPG-SGP', 'PSG01', 'PUS82', 'PVN01', 'PVN02')) THEN
    IF (OD_QTY_EA_INBOUND = OD_QTY_EA) THEN
      SET PLT_TYP = 'PALLETIZE';
      RETURN PLT_TYP;
    ELSE
      SET PLT_TYP = 'LOOSE';
      RETURN PLT_TYP;
    END IF;

    SET PLT_TYP = 'PALLETIZE';
    RETURN PLT_TYP;
  END IF;
  IF (OD_SKU IN ('01056127', '00044893', '00088956', '00098095', '01043662', '01050380', '01164644', '01268008')) THEN
    SET PLT_TYP = 'LOOSE';
    RETURN PLT_TYP;
  END IF;

  IF (OD_ORDERTYPE = 'IT') THEN
    SET PLT_TYP = 'LOOSE';
    RETURN PLT_TYP;
  END IF;

  -- OTHER
  SET PLT_TYP = 'LOOSE';
  RETURN PLT_TYP;
END
$$

--
-- Create function `zcml_alert_message`
--
CREATE
DEFINER = 'mysql.sys'@'%'
FUNCTION zcml_alert_message (p_message text,
p_chat_id varchar(50))
RETURNS json
DETERMINISTIC
BEGIN
  DECLARE v_bot_token varchar(255);
  DECLARE v_chat_id varchar(50);
  DECLARE v_url varchar(500);
  DECLARE v_data json;
  DECLARE v_response text;
  DECLARE v_success boolean DEFAULT FALSE;

  -- Get bot configuration
  SELECT
    bot_token,
    COALESCE(p_chat_id, default_chat_id) INTO v_bot_token, v_chat_id
  FROM zcml_alert_config
  WHERE id = 1;

  -- Build URL
  SET v_url = CONCAT('https://api.telegram.org/bot', v_bot_token, '/sendMessage');

  -- Build JSON data
  SET v_data = JSON_OBJECT('chat_id', v_chat_id,
  'text', p_message,
  'parse_mode', 'HTML');

  -- Send message
  SET v_response = http_post(v_url, CAST(v_data AS char), 'Content-Type: application/json');

  -- Check if successful
  IF v_response NOT LIKE 'CURL error:%' THEN
    IF JSON_VALID(v_response)
      AND JSON_EXTRACT(v_response, '$.ok') = TRUE THEN
      SET v_success = TRUE;
    END IF;
  END IF;

  -- Return result
  RETURN JSON_OBJECT('success', v_success,
  'response', v_response);
END
$$

--
-- Create function `SPLIT_STR`
--
CREATE 
	DEFINER = 'wms_cml'@'%'
FUNCTION SPLIT_STR(
  x VARCHAR(255),
  delim VARCHAR(12),
  pos INT
)
  RETURNS VARCHAR(255) CHARSET utf8mb3 COLLATE utf8mb3_bin
RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos),
       LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1),
       delim, '')
$$

--
-- Create function `isnumeric`
--
CREATE
DEFINER = 'wms_cml'@'%'
FUNCTION isnumeric (In_S varchar(32))
RETURNS int(11)
BEGIN
  IF LENGTH(0 + In_S) <> LENGTH(In_S) THEN
    RETURN 0;
  ELSE
    RETURN 1;
  END IF;
END
$$

--
-- Create function `ISDATE`
--
CREATE
DEFINER = 'wms_cml'@'%'
FUNCTION ISDATE (In_Date varchar(32))
RETURNS int(11)
BEGIN
  IF (SELECT
        DATE_FORMAT(In_Date, '%Y%m%d')) IS NULL THEN
    RETURN 0;
  ELSE
    RETURN 1;
  END IF;
END
$$

--
-- Create function `Get_UDFA_Parameter`
--
CREATE
DEFINER = 'wms_cml'@'%'
FUNCTION Get_UDFA_Parameter (List varchar(2000), SplitOn nvarchar(60), num1 int)
RETURNS varchar(255) CHARSET utf8mb3 COLLATE utf8mb3_bin
BEGIN
  IF LENGTH(LIST) - LENGTH(REPLACE(LIST, SplitOn, '')) + 1 < num1 THEN
    RETURN '';
  ELSE
    RETURN SUBSTRING_INDEX (SUBSTRING_INDEX (LIST, SplitOn, num1), SplitOn, -1);
  END IF;
END
$$

--
-- Create function `GET_CHILD_BRANCHID`
--
CREATE
DEFINER = 'wms_cml'@'%'
FUNCTION GET_CHILD_BRANCHID (IN_organizationId varchar(20),
IN_branchid varchar(50))
RETURNS varchar(4000) CHARSET utf8mb3 COLLATE utf8mb3_bin
BEGIN
  DECLARE TEMP varchar(4000);
  DECLARE CHILD varchar(4000);
  SET CHILD = IN_BRANCHID;
  SET temp = '$';
  WHILE CHILD IS NOT NULL
  DO
    SET TEMP = CONCAT(TEMP, ',', CHILD);
    SELECT
      GROUP_CONCAT(BRANCHID)
    FROM BSM_BRANCH
    WHERE FIND_IN_SET(parentBranchId, CHILD) > 0
    AND ORGANIZATIONID = IN_ORGANIZATIONID INTO CHILD;
  END WHILE;

  SET TEMP = SUBSTR(TEMP, 3);
  RETURN TEMP;
END
$$

--
-- Create function `getPalletLoosePPG`
--
CREATE
DEFINER = 'it_denny'@'localhost'
FUNCTION getPalletLoosePPG (`R_ORDERNO` varchar(50),
`R_ORDERLINENO` int)
RETURNS varchar(50) CHARSET utf8mb3 COLLATE utf8mb3_bin
READS SQL DATA
BEGIN

  DECLARE R_PALLETTYPE varchar(10);
  DECLARE R_ORDERLINENO int;
  -- DECLARE R_PALLETTYPE2 VARCHAR(10);
  DECLARE done int DEFAULT FALSE;
  -- DECLARE R_BILLINGDATE varchar(10);
  DECLARE CUR_APP CURSOR FOR

  -- foreach CURSOR1 FOR

  -- RETURNS TABLE AS RETURN (

  SELECT
    CASE

      -- point 1 

      WHEN dov.orderNo != '' THEN 'LOOSE'



      -- point 2,3,6 

      WHEN sku.sku_group1 NOT IN ('PMC-FG', 'PMC-RM') OR
        sku.sku IN ('01056127''00044893', '00088956',

        '00098095',

        '01043662',

        '01050380',

        '01164644',

        '01268008',

        '00059989',

        '00091423',

        '01043679',

        '01261437',

        '01297349',

        '01054059',

        '01130162',

        '01063334',

        'KR-E6461/ID/1000K') THEN 'LOOSE'



      -- point 4,5,7 

      WHEN doh.orderType = 'IT' OR
        doh.consigneeId NOT IN ('GSG909', 'GVN0921',

        'PPG-HCM',

        'PPG-SGP',

        'PSG01',

        'PUS82',

        'PVN01',

        'PVN02') THEN 'LOOSE' ELSE 'PALLETIZED' END AS R_PALLETTYPE
  -- ,'TESDN' AS R_PALLETTYPE2

  FROM ACT_ALLOCATION_DETAILS h1

    LEFT JOIN DOC_ORDER_HEADER doh

      ON doh.organizationId = h1.organizationId

      AND doh.warehouseId = h1.warehouseId

      AND doh.orderNo = h1.orderNo

    LEFT JOIN BAS_SKU sku

      ON h1.organizationId = sku.organizationId

      AND h1.customerId = sku.customerId

      AND h1.sku = sku.sku

    LEFT JOIN DOC_ORDER_VAS dov

      ON h1.organizationId = dov.organizationId

      AND h1.warehouseId = dov.warehouseId

      AND h1.orderNo = dov.orderNo

  WHERE h1.organizationId = 'OJV_CML'
  AND h1.warehouseId = 'CBT01'

  AND h1.customerId = 'PPG'
  -- AND (cast(doh.editTime as date) > (now() + interval -(3) month)) 

  AND doh.orderNo = R_ORDERNO;

  -- )

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN CUR_APP;
    read_loop:
  LOOP
    FETCH CUR_APP INTO R_PALLETTYPE;
    IF done THEN
      LEAVE read_loop;
    END IF;
    RETURN R_PALLETTYPE

    --		WITH RESUME
    ;

  --    END foreach;

  END LOOP;
  CLOSE CUR_APP;

-- RETURN TABLE AS RETURN SELECT R_PALLETTYPE AS tesd;

-- RETURN R_PALLETTYPE;

END
$$

--
-- Create function `GetLocationSKUHeight`
--
CREATE
DEFINER = 'wms_cml'@'%'
FUNCTION GetLocationSKUHeight (v_QTY decimal(18, 8),
v_Qty3 decimal(18, 8),
v_Qty4 decimal(18, 8),
v_PLLength decimal(18, 8),
v_PLWidth decimal(18, 8),
v_PLHeight decimal(18, 8),
v_CSLength decimal(18, 8),
v_CSWidth decimal(18, 8),
v_CSHeight decimal(18, 8),
v_EALength decimal(18, 8),
v_EAWidth decimal(18, 8),
v_EAHeight decimal(18, 8),
r_LocationLength decimal(18, 8),
r_LocationWidth decimal(18, 8),
v_UOM varchar(10))
RETURNS decimal(18, 8)
BEGIN

  DECLARE v_EAArea decimal(18, 8);
  DECLARE v_CSArea decimal(18, 8);
  DECLARE v_PLArea decimal(18, 8);
  DECLARE v_SumHeight decimal(18, 8);
  DECLARE v_PLQTY decimal(18, 8);
  DECLARE v_CSQTY decimal(18, 8);
  DECLARE v_EAQTY decimal(18, 8);
  DECLARE v_LocationArea decimal(18, 8);
  DECLARE v_error int;
  DECLARE v_nrow int;
  DECLARE v_errormessage varchar(1000);
  DECLARE r_CurrentTime timestamp;
  SET v_error = 1;

  SET R_CurrentTime = NOW();
  SET v_LocationArea = r_LocationLength * r_LocationWidth;
  SET v_EAArea = v_EALength * v_EAWidth;
  SET v_CSArea = v_CSLength * v_CSWidth;
  SET v_PLArea = v_PLLength * v_PLWidth;
  IF v_LocationArea = 0 THEN
    SET v_SumHeight = 0;
    RETURN v_SumHeight;
  END IF;
  IF v_qty4 > 0 THEN
    SET v_PLQTY = FLOOR(v_qty / v_qty4);
  ELSE
    SET v_PLQTY = 0;
  END IF;
  SET v_CSQTY = v_QTY;
  IF v_qty3 > 0 THEN
    IF v_qty4 > 0 THEN
      SET v_CSQTY = v_CSQTY - v_QTY4 * v_PLQTY;
    END IF;
    SET v_CSQTY = FLOOR(v_CSQTY / v_QTY3);
  ELSE
    SET v_CSQTY = 0;
  END IF;
  SET v_EAQTY = v_QTY - v_PLQTY * v_qty4 - v_CSQTY * v_QTY3;

  IF (v_UOM = 'EA'
    OR v_Qty3 = 0
    AND (v_Qty4 = 0
    OR v_Qty < v_Qty4))
    AND v_EAArea > 0 THEN
    IF v_LocationArea < v_EAArea
      OR (v_LocationArea = 0
      OR v_EAArea = 0)
      OR NOT ((v_EALength <= r_LocationLength
      AND v_EAWidth <= r_LocationWidth)
      OR (v_EALength <= r_LocationWidth
      AND v_EAWidth <= r_LocationLength)) THEN
      SET v_SumHeight = 99999999;
    ELSE
      SET v_SumHeight = CEIL(v_QTY / FLOOR(v_LocationArea / v_EAArea)) * v_EAHeight;
    END IF;

  ELSEIF (v_UOM = 'CS'
    AND v_Qty3 > 0)
    AND v_CSArea > 0 THEN
    IF v_LocationArea < v_CSArea
      OR (v_LocationArea = 0
      OR v_CSArea = 0)
      OR NOT ((v_CSLength <= r_LocationLength
      AND v_CSWidth <= r_LocationWidth)
      OR (v_CSLength <= r_LocationWidth
      AND v_CSWidth <= r_LocationLength)) THEN
      SET v_SumHeight = 99999999;
    ELSE
      SET v_SumHeight = CEIL(CEIL(v_QTY / v_Qty3) / FLOOR(v_LocationArea / v_CSArea)) * v_CSHeight;
    END IF;

  ELSEIF (v_UOM = 'PL'
    AND v_Qty4 > 0)
    AND v_PLArea > 0 THEN
    IF v_LocationArea < v_PLArea
      OR v_LocationArea = 0
      OR v_PLArea = 0
      OR NOT ((v_PLLength <= r_LocationLength
      AND v_PLWidth <= r_LocationWidth)
      OR (v_PLLength <= r_LocationWidth
      AND v_PLWidth <= r_LocationLength)) THEN
      SET v_SumHeight = 99999999;
    ELSE
      SET v_SumHeight = CEIL(CEIL(v_QTY / v_Qty4) / FLOOR(v_LocationArea / v_PLArea)) * v_PLHeight;
    END IF;
  ELSEIF nvl(v_UOM, '*') <> 'EA' THEN

    IF v_PLQTY > 0 THEN
      IF v_LocationArea < v_PLArea
        OR (v_LocationArea = 0
        OR v_PLArea = 0)
        OR NOT ((v_PLLength <= r_LocationLength
        AND v_PLWidth <= r_LocationWidth)
        OR (v_PLLength <= r_LocationWidth
        AND v_PLWidth <= r_LocationLength)) THEN
        SET v_SumHeight = 99999999;
      ELSE
        IF v_PLArea > 0 THEN
          SET v_SumHeight = CEIL(v_PLQTY / FLOOR(v_LocationArea / v_PLArea)) * v_PLHeight;
        ELSEIF v_Qty3 > 0 THEN
          SET v_CSQTY = v_CSQTY + v_PLQTY * v_Qty4 / v_Qty3;
        END IF;
      END IF;
    END IF;

    IF v_CSQTY > 0 THEN
      IF v_LocationArea < v_CSArea
        OR (v_LocationArea = 0
        OR v_CSArea = 0)
        OR NOT ((v_CSLength <= r_LocationLength
        AND v_CSWidth <= r_LocationWidth)
        OR (v_CSLength <= r_LocationWidth
        AND v_CSWidth <= r_LocationLength)) THEN
        SET v_SumHeight = 99999999;
      ELSE
        IF v_CSArea > 0 THEN
          SET v_SumHeight = v_SumHeight + CEIL(v_CSQTY / FLOOR(v_LocationArea / v_CSArea)) * v_CSHeight;
        ELSE
          SET v_EAQTY = v_EAQTY + v_CSQTY * v_Qty3;
        END IF;
      END IF;
    END IF;

    IF v_EAQTY > 0 THEN
      IF v_LocationArea < v_EAArea
        OR (v_LocationArea = 0
        OR v_EAArea = 0)
        OR NOT ((v_EALength <= r_LocationLength
        AND v_EAWidth <= r_LocationWidth)
        OR (v_EALength <= r_LocationWidth
        AND v_EAWidth <= r_LocationLength)) THEN
        SET v_SumHeight = 99999999;
      ELSE
        SET v_SumHeight = v_SumHeight + CEIL(v_EAQTY / FLOOR(v_LocationArea / v_EAArea)) * v_EAHeight;
      END IF;
    END IF;
  END IF;
  RETURN v_SumHeight;
END
$$

--
-- Create function `getBillTODate_MINONEDAY`
--
CREATE
DEFINER = 'sa'@'%'
FUNCTION getBillTODate_MINONEDAY (R_BILLINGDAY int)
RETURNS varchar(10) CHARSET utf8mb3 COLLATE utf8mb3_bin
BEGIN
  DECLARE R_CURRENTDATE date;
  DECLARE R_BILLINGDATE date;
  -- DECLARE R_FMDATE varchar(10);
  DECLARE R_TODATE varchar(10);
  SET R_CURRENTDATE = DATE_ADD(CURDATE(), INTERVAL -1 DAY);
  SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');

  IF (R_CURRENTDATE < R_BILLINGDATE
    AND MONTH(R_CURRENTDATE) = MONTH(R_BILLINGDATE)) THEN
    SET R_BILLINGDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL 0 MONTH), '%Y-%m-%d');
  ELSE
    SET R_BILLINGDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL 1 MONTH), '%Y-%m-%d');
  END IF;


  SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);

  RETURN R_TODATE;
END
$$

--
-- Create function `getBillTODate`
--
CREATE
DEFINER = 'sa'@'%'
FUNCTION getBillTODate (R_BILLINGDAY int)
RETURNS varchar(10) CHARSET utf8mb3 COLLATE utf8mb3_bin
BEGIN
  DECLARE R_CURRENTDATE date;
  DECLARE R_BILLINGDATE date;
  -- DECLARE R_FMDATE varchar(10);
  DECLARE R_TODATE varchar(10);
  SET R_CURRENTDATE = CURDATE();
  SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');

  IF (R_CURRENTDATE < R_BILLINGDATE
    AND MONTH(R_CURRENTDATE) = MONTH(R_BILLINGDATE)) THEN
    SET R_BILLINGDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL 0 MONTH), '%Y-%m-%d');
  ELSE
    SET R_BILLINGDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL 1 MONTH), '%Y-%m-%d');
  END IF;


  SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY);

  RETURN R_TODATE;
END
$$

--
-- Create function `getBillFMDate_MINONEDAY`
--
CREATE
DEFINER = 'wms_cml'@'%'
FUNCTION getBillFMDate_MINONEDAY (R_BILLINGDAY int)
RETURNS varchar(10) CHARSET utf8mb3 COLLATE utf8mb3_bin
BEGIN
  DECLARE R_CURRENTDATE timestamp;
  -- DECLARE R_OPDATE varchar(10);
  DECLARE R_FMDATE varchar(10);
  -- DECLARE R_TODATE varchar(10);
  DECLARE R_BILLINGDATE varchar(10);
  SET R_CURRENTDATE = DATE_ADD(CURDATE(), INTERVAL -1 DAY);
  SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
  IF (R_CURRENTDATE < R_BILLINGDATE
    AND MONTH(R_CURRENTDATE) = MONTH(R_BILLINGDATE)) THEN
    SET R_BILLINGDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
  ELSE
    SET R_BILLINGDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL 0 MONTH), '%Y-%m-%d');
  END IF;

  -- SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
  SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL 0 MONTH), '%Y-%m-%d');
  RETURN R_FMDATE;
END
$$

--
-- Create function `getBillFMDate`
--
CREATE
DEFINER = 'wms_cml'@'%'
FUNCTION getBillFMDate (R_BILLINGDAY int)
RETURNS varchar(10) CHARSET utf8mb3 COLLATE utf8mb3_bin
BEGIN
  DECLARE R_CURRENTDATE timestamp;
  -- DECLARE R_OPDATE varchar(10);
  DECLARE R_FMDATE varchar(10);
  -- DECLARE R_TODATE varchar(10);
  DECLARE R_BILLINGDATE varchar(10);
  SET R_CURRENTDATE = CURDATE();
  SET R_BILLINGDATE = STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE), '-', MONTH(R_CURRENTDATE), '-', R_BILLINGDAY), '%Y-%m-%d');
  IF (R_CURRENTDATE < R_BILLINGDATE
    AND MONTH(R_CURRENTDATE) = MONTH(R_BILLINGDATE)) THEN
    SET R_BILLINGDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
  ELSE
    SET R_BILLINGDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL 0 MONTH), '%Y-%m-%d');
  END IF;

  -- SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
  SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL 0 MONTH), '%Y-%m-%d');
  RETURN R_FMDATE;
END
$$

--
-- Create function `generate_sequence_number`
--
CREATE
DEFINER = 'sa'@'%'
FUNCTION generate_sequence_number ()
RETURNS int(11)
BEGIN
  SET @row_num := IFNULL(@row_num, 0) + 1;
  RETURN @row_num;
END
$$

--
-- Create function `FN_CALCULATE_PALLET_DECIMAL`
--
CREATE
DEFINER = 'root'@'localhost'
FUNCTION FN_CALCULATE_PALLET_DECIMAL (p_organizationId varchar(20),
p_warehouseId varchar(20),
p_customerId varchar(30),
p_sku varchar(50),
p_qty_ea decimal(18, 8))
RETURNS decimal(18, 8)
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE v_packId varchar(50);
  DECLARE v_qty_pl decimal(18, 8) DEFAULT 0;
  DECLARE v_ea_per_pl decimal(18, 8) DEFAULT 0;

  -- Cari packId dari BAS_SKU_MULTIWAREHOUSE
  SELECT
    packId INTO v_packId
  FROM BAS_SKU_MULTIWAREHOUSE
  WHERE organizationId = p_organizationId
  AND warehouseId = p_warehouseId
  AND customerId = p_customerId
  AND sku = p_sku
  LIMIT 1;

  -- Jika packId tidak ditemukan, return 0
  IF v_packId IS NULL THEN
    RETURN 0;
  END IF;

  -- Ambil konversi EA per Pallet dari BAS_PACKAGE_DETAILS
  SELECT
    qty INTO v_ea_per_pl
  FROM BAS_PACKAGE_DETAILS
  WHERE organizationId = p_organizationId
  AND packId = v_packId
  AND customerId = p_customerId
  AND packUom = 'PL'
  LIMIT 1;

  -- Jika tidak ada konversi pallet, return 0
  IF v_ea_per_pl IS NULL
    OR v_ea_per_pl = 0 THEN
    RETURN 0;
  END IF;

  -- Hitung jumlah pallet dengan desimal
  SET v_qty_pl = p_qty_ea / v_ea_per_pl;

  RETURN v_qty_pl;
END
$$

--
-- Create function `FN_CALCULATE_PALLET`
--
CREATE
DEFINER = 'root'@'localhost'
FUNCTION FN_CALCULATE_PALLET (p_organizationId varchar(20),
p_warehouseId varchar(20),
p_customerId varchar(30),
p_sku varchar(50),
p_qty_ea decimal(18, 8))
RETURNS decimal(18, 8)
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE v_packId varchar(50);
  DECLARE v_qty_pl decimal(18, 8) DEFAULT 0;
  DECLARE v_ea_per_pl decimal(18, 8) DEFAULT 0;

  -- Cari packId dari BAS_SKU_MULTIWAREHOUSE
  SELECT
    packId INTO v_packId
  FROM BAS_SKU_MULTIWAREHOUSE
  WHERE organizationId = p_organizationId
  AND warehouseId = p_warehouseId
  AND customerId = p_customerId
  AND sku = p_sku
  LIMIT 1;

  -- Jika packId tidak ditemukan, return 0
  IF v_packId IS NULL THEN
    RETURN 0;
  END IF;

  -- Ambil konversi EA per Pallet dari BAS_PACKAGE_DETAILS
  SELECT
    qty INTO v_ea_per_pl
  FROM BAS_PACKAGE_DETAILS
  WHERE organizationId = p_organizationId
  AND packId = v_packId
  AND customerId = p_customerId
  AND packUom = 'PL'
  LIMIT 1;

  -- Jika tidak ada konversi pallet, return 0
  IF v_ea_per_pl IS NULL
    OR v_ea_per_pl = 0 THEN
    RETURN 0;
  END IF;

  -- Hitung jumlah pallet (dengan pembulatan ke bawah)
  SET v_qty_pl = CEIL(p_qty_ea / v_ea_per_pl);

  RETURN v_qty_pl;
END
$$

--
-- Create function `FNSPCOM_GetIDSequence`
--
CREATE
DEFINER = 'root'@'%'
FUNCTION FNSPCOM_GetIDSequence (IN_organizationId varchar(20),
IN_warehouseId varchar(20),
IN_Sequence_Name varchar(30))
RETURNS varchar(40) CHARSET utf8mb3 COLLATE utf8mb3_bin
BEGIN
  DECLARE OUT_ReturnNo varchar(40);
  DECLARE OUT_Return_Code varchar(1000);

  DECLARE r_ID_Sequence decimal(18, 0);
  DECLARE r_Max_ID_Sequence decimal(18, 0);
  DECLARE R_Length int;
  DECLARE r_Start_i int;
  DECLARE r_PreFix varchar(20);
  DECLARE r_LastDate varchar(8);
  DECLARE r_Date_Format varchar(10);
  DECLARE r_Date_Max varchar(10);
  DECLARE R_Date_Str varchar(8);
  DECLARE r_WarehouseID varchar(100);
  DECLARE r_MLT_WH char(1);
  DECLARE r_NO_Commit char(1);

  SET r_ID_Sequence = -1;
  SET R_Length = 0;
  IF OUT_Return_Code = '*_*'
    OR OUT_Return_Code = 'NO_COMMIT' THEN
    SET r_NO_Commit := 'N';
  ELSE
    SET r_NO_Commit := 'Y';
  END IF;


  IF GET_LOCK('my_procedure_lock', 10) THEN

    SELECT
      IDSEQUENCE,
      MaxIDSequence,
      LENGTH,
      PreFix,
      DATE_FORMAT(EditTime, '%Y%m%d'),
      DateFormat,
      Datemax,
      WareHouseID
    FROM SYS_IDSEQUENCE
    WHERE IDName = IN_Sequence_Name
    AND organizationId = IN_organizationId
    AND WareHouseID = IN_WarehouseID LIMIT 1 INTO r_ID_Sequence, r_Max_ID_Sequence, R_Length, r_PreFix, r_LastDate
    , r_Date_Format, r_Date_Max, r_WarehouseID;
    IF r_ID_Sequence = -1 THEN
      SELECT
        IDSequence,
        MaxIDSequence,
        LENGTH,
        PreFix,
        DATE_FORMAT(EditTime, '%Y%m%d'),
        DateFormat,
        Datemax,
        WareHouseID INTO r_ID_Sequence, r_Max_ID_Sequence, R_Length, r_PreFix, r_LastDate
      , r_Date_Format, r_Date_Max, r_WarehouseID
      FROM SYS_IDSEQUENCE
      WHERE IDName = IN_Sequence_Name
      AND organizationId = IN_organizationId
      AND WareHouseID = IN_WarehouseID LIMIT 1 FOR UPDATE;
    END IF;
    IF r_ID_Sequence = -1 THEN
      SET OUT_Return_Code = '100';



    END IF;
    IF r_Date_Format = 'YYYY'
      OR r_Date_Format = 'YY'
      OR r_Date_Format = 'YYYYMM'
      OR r_Date_Format = 'YYMM'
      OR r_Date_Format = 'YYYYMMDD'
      OR r_Date_Format = 'YYMMDD' THEN
      SET r_Date_Str = DATE_FORMAT(NOW(), '%Y%m%d');
      IF r_Date_Format = 'YYYY' THEN
        SET r_Date_Str = SUBSTRING(r_Date_Str, 1, 4);
      ELSEIF r_Date_Format = 'YY' THEN
        SET r_Date_Str = SUBSTRING(r_Date_Str, 3, 2);
      ELSEIF r_Date_Format = 'YYYYMM' THEN
        SET r_Date_Str = SUBSTRING(r_Date_Str, 1, 6);
      ELSEIF r_Date_Format = 'YYMM' THEN
        SET r_Date_Str = SUBSTRING(r_Date_Str, 3, 4);
      ELSEIF r_Date_Format = 'YYYYMMDD' THEN
        SET r_Date_Str = SUBSTRING(r_Date_Str, 1, 8);
      ELSEIF r_Date_Format = 'YYMMDD' THEN
        SET r_Date_Str = SUBSTRING(r_Date_Str, 3, 6);
      END IF;

      IF r_Date_Str = IFNULL(r_Date_Max, '') THEN
        SET r_ID_Sequence = IFNULL(r_ID_Sequence, 0) + 1;
      ELSE
        SET r_ID_Sequence = 1;
        UPDATE SYS_IDSEQUENCE
        SET Datemax = r_Date_Str
        WHERE IDName = IN_Sequence_Name
        AND organizationId = IN_organizationId
        AND WarehouseID = r_WarehouseID;
      END IF;
    ELSE
      SET r_ID_Sequence = r_ID_Sequence + 1;
      IF r_ID_Sequence > r_Max_ID_Sequence THEN
        SET r_ID_Sequence = 1;
      END IF;
    END IF;
    IF r_PreFix = 'YYMMDD'
      OR r_PreFix = 'YYYYMMDD' THEN
      IF r_PreFix = 'YYMMDD' THEN
        SET r_PreFix = to_CHar(NOW(), 'YYMMDD');
      ELSEIF r_PreFix = 'YYYYMMDD' THEN
        SET r_PreFix = to_CHar(NOW(), 'YYYYMMDD');
      END IF;
      IF NOT (r_PreFix = r_LastDate
        OR substrb(r_PreFix, 3, 6) = r_LastDate) THEN
        SET r_ID_Sequence = 1;
      END IF;
    END IF;
    SET OUT_ReturnNo = TRIM(r_ID_Sequence);

    SET r_Start_i = LENGTH(OUT_ReturnNo) + 1;
    WHILE (r_Start_i <= R_Length) DO

      SET OUT_ReturnNo = CONCAT('0', OUT_ReturnNo);
      SET r_Start_i = r_Start_i + 1;
    END WHILE;
    IF r_Date_Str IS NOT NULL THEN
      SET OUT_ReturnNo = CONCAT(TRIM(r_Date_Str), OUT_ReturnNo);
    END IF;
    IF r_PreFix IS NOT NULL THEN
      SET OUT_ReturnNo = CONCAT(RTRIM(r_PreFix), OUT_ReturnNo);
    END IF;

    UPDATE SYS_IDSEQUENCE
    SET IDSequence = r_ID_Sequence,
        EditTime = NOW(),
        Datemax = r_Date_Str
    WHERE IDName = IN_Sequence_Name
    AND organizationId = IN_organizationId
    AND WarehouseID = r_WarehouseID;

    SET OUT_Return_Code = CONCAT('000', RTRIM(OUT_ReturnNo));
    -- Release the lock after the logic is completed
    DO RELEASE_LOCK('my_procedure_lock');


  END IF;
  RETURN OUT_ReturnNo;
END
$$

--
-- Create function `encrypt_text`
--
CREATE
DEFINER = 'mysql.sys'@'%'
FUNCTION encrypt_text (plain_password varchar(255), secret_key varchar(32))
RETURNS varbinary(255)
DETERMINISTIC
BEGIN
  RETURN AES_ENCRYPT(plain_password, secret_key);
END
$$

--
-- Create function `decrypt_text`
--
CREATE
DEFINER = 'mysql.sys'@'%'
FUNCTION decrypt_text (encrypted_password varbinary(255), secret_key varchar(32))
RETURNS varchar(255) CHARSET utf8mb3 COLLATE utf8mb3_bin
DETERMINISTIC
BEGIN
  RETURN AES_DECRYPT(encrypted_password, secret_key);
END
$$

DELIMITER ;