USE wms_cml;

DROP PROCEDURE IF EXISTS CML_BILLSTORAGE_SAVEDAILY_STORAGETYPE;

DELIMITER $$

CREATE 
	DEFINER = 'sa'@'%'
PROCEDURE CML_BILLSTORAGE_SAVEDAILY_STORAGETYPE(IN IN_organizationId varchar(30),
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
            case when zib.customerId IN ('ECMAMA','ECMAMAB2C') THEN (
  case when substring(zib.locationId,1,10)= 'STAGEAC-01' and s.freightClass ='COOL-NON-FOOD' then 'AC'
  when substring(zib.locationId,1,10) = 'STAGEAC-03' and s.freightClass ='COOL-NON-FOOD' then 'AC'
  when substring(zib.locationId,1,10) = 'STAGEAC-05' and s.freightClass ='COOL-NON-FOOD' then 'AC'
  when substring(zib.locationId,1,10) = 'STAGEAC-07' and s.freightClass ='COOL-NON-FOOD' then 'AC'
  when zib.locationId like 'E08%' and s.freightClass='COOL-NON-FOOD' then 'AC'
  when zib.locationId like 'E09%' and s.freightClass='COOL-NON-FOOD' then 'AC'
  else 'AMBIENT'  end) else 'DRY' end as storage_type
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
  ORDER BY ls_storage.warehouseId,ls_storage.customerId, stockDate, ls_storage.storage_type;
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


INSERT INTO Z_BIL_AKUM_DAYS_STORAGE
(
  organizationId
 ,warehouseId
 ,customerId
 ,StockDate
 ,qty_cbm
 ,chargeType
 ,addWho
 ,addTime
 ,editWho
 ,editTime
 ,UDF01
)
VALUES
(
  'OJV_CML'
 ,v_warehouseId
 ,v_customerId
 ,v_stockDate -- StockDate - DATE
 ,v_qtyCharge -- qty_cbm - DECIMAL(18, 8)
 ,'STRG' -- chargeType - VARCHAR(10) NOT NULL
 ,'CUSTOMBILL' -- addWho - VARCHAR(100)
 ,NOW() -- addTime - DATETIME
 ,'CUSTOMBILL' -- editWho - VARCHAR(100)
 ,NOW() -- editTime - DATETIME
 ,v_storagetype -- UDF01 - VARCHAR(100)
);


  END LOOP;

  -- Close the cursor
  CLOSE my_cursor;

END
$$

DELIMITER ;