DROP TEMPORARY TABLE IF EXISTS TMP_BIL_SUMMARY_INFO1;
			CREATE TEMPORARY TABLE  TMP_BIL_SUMMARY_INFO1 (  
				organizationId VARCHAR(20) , 
				warehouseId VARCHAR(20) , 
				StockDate DATE DEFAULT NULL, 
				customerId VARCHAR(30), 
				qtyMuid INT(11) DEFAULT 0,
				qtyTrace INT(11) DEFAULT 0,
				qtyLoc INT(11) DEFAULT 0,
				qtyCube DECIMAL(24,8) DEFAULT 0
				);

TRUNCATE TMP_BIL_SUMMARY_INFO1;

      	DROP TEMPORARY TABLE IF EXISTS TMP_BIL_SUMMARY_INFO2;
			CREATE TEMPORARY TABLE  TMP_BIL_SUMMARY_INFO2 (  
				organizationId VARCHAR(20) , 
				warehouseId VARCHAR(20) , 
				customerId VARCHAR(30), 
				qtyonHand DECIMAL(24,8) DEFAULT 0
				);

-- TRACE ID
	INSERT INTO TMP_BIL_SUMMARY_INFO2(organizationId,warehouseId,customerId,qtyonHand)
					SELECT tb.organizationId,  tb.warehouseId, tb.customerId
								,SUM(IF(tb.qtyTrace>=R_CLASSTO,R_CLASSTO-R_CLASSFROM,IF(tb.qtyTrace-R_CLASSFROM<R_minQty,R_minQty,tb.qtyTrace-R_CLASSFROM)))/IF('N'='Y',R_Days,1)
					FROM TMP_BIL_SUMMARY_INFO1 tb
					WHERE tb.qtyTrace > R_CLASSFROM
					GROUP BY tb.organizationId,  tb.warehouseId, tb.customerId;

  -- MONTH PL
  			SELECT tb.organizationId,  tb.warehouseId, tb.customerId
								,SUM(IF(tb.qtyMuid>=R_CLASSTO,R_CLASSTO-R_CLASSFROM,IF(tb.qtyMuid-R_CLASSFROM<R_minQty,R_minQty,tb.qtyMuid-R_CLASSFROM)))/IF(R_UDF07='Y',R_Days,1)
					FROM TMP_BIL_SUMMARY_INFO1 tb
					WHERE tb.qtyMuid > R_CLASSFROM
					GROUP BY tb.organizationId,  tb.warehouseId, tb.customerId;


--       -- MUID
-- 	SELECT tb.organizationId,  tb.warehouseId, tb.customerId
-- 								,SUM(IF(tb.qtyMuid>=9999999.00000,9999999.00000-0.00000,IF(tb.qtyMuid-0.00000<0,0,tb.qtyMuid-0.00000)))/IF('N'='Y',31,1)
-- 					FROM TMP_BIL_SUMMARY_INFO1 tb
-- 					WHERE tb.qtyMuid > 0.00000
-- 					GROUP BY tb.organizationId,  tb.warehouseId, tb.customerId;


INSERT INTO TMP_BIL_SUMMARY_INFO1(organizationId,warehouseId,StockDate,customerId,qtyLoc,qtyTrace,qtyMuid,qtyCube)
          SELECT   zib.organizationId,  zib.warehouseId,zib.StockDate,zib.customerId
                  ,COUNT(DISTINCT zib.locationId),COUNT(DISTINCT zib.traceId),COUNT(DISTINCT zib.muid),SUM(zib.totalCube)         
          FROM Z_InventoryBalance_Real zib      
          INNER JOIN INV_LOT_ATT ila ON ila.organizationId=zib.organizationId AND ila.lotNum=zib.LotNum
          INNER JOIN BAS_LOCATION bl ON bl.organizationId=zib.organizationId AND bl.warehouseId =zib.warehouseId AND bl.locationId =zib.locationId 
          INNER JOIN BAS_SKU_MULTIWAREHOUSE bsm 
                  ON bsm.organizationId = zib.organizationId AND bsm.warehouseId=zib.warehouseId AND bsm.customerId = zib.customerId AND bsm.SKU=zib.sku
          #
          WHERE zib.organizationId= 'OJV_CML'
          AND zib.warehouseId= 'CBT01' 
          AND zib.StockDate>= DATE_FORMAT(DATE_ADD('2022-09-19', INTERVAL -1 MONTH), '%Y-%m-%d' )
          AND zib.StockDate<= DATE_ADD(DATE_FORMAT('2022-09-17',  '%Y-%m-%d'),INTERVAL -1 DAY )     
          AND zib.customerId = 'ITOCHU' 
          AND (ila.lotAtt07='R' OR 'ST'<>'PL')
          AND bsm.tariffMasterId='BIL01006'
          AND (ISNULL('BS') OR 'BS'='' OR bl.locationCategory =  'BS')
          AND (ISNULL('') OR ''='' OR bl.udf05 =  '') 
          AND (ISNULL('') OR ''='' OR bl.locGroup1 =  '') 
          GROUP BY zib.organizationId,zib.warehouseId,zib.StockDate,zib.customerId;




SELECT DISTINCT bsm.organizationId,bsm.warehouseId, bsm.CUSTOMERID,DAY(bth.billingdate) billingDate
			,btr.tariffId , btr.tariffLineNo , btr.tariffClassNo , btd.chargeCategory , btd.chargeType, btd.descrC,btd.ratebase
			,btr.ratePerUnit , btr.rate, btd.minAmount , btd.maxAmount 
			,IF(btd.UDF03 = '', 0, btd.UDF03) minQty, btd.UDF01 AS MaterialNo, btd.udf02 AS itemChargeCategory, btd.udf04 billMode
			,locationCategory, btd.UDF05,btd.UDF06 ,btd.UDF07 ,btd.UDF08
			,IFNULL(btd.incomeTaxRate,0) IncomeTaxRate  , CASE WHEN chargeType = 'ES' THEN  IFNULL(btr.classfrom,0) - 1 ELSE IFNULL(btr.classfrom,0) END 
			,IFNULL(classTo,0),bth.contractNo , bth.tariffMasterId , btr.cost , btd.billingParty
		FROM BAS_SKU_MULTIWAREHOUSE bsm 
		INNER JOIN BAS_CUSTOMER bc ON bc.customerId=bsm.customerId AND bc.organizationId=bsm.organizationId AND bc.CustomerType='OW'
		INNER JOIN BIL_TARIFF_HEADER bth ON bth.organizationId=bsm.organizationId AND bth.tariffMasterId = bsm.tariffMasterId
		INNER JOIN BIL_TARIFF_DETAILS btd ON btd.organizationId=bth.organizationId  AND btd.tariffId =  bth.tariffId
		INNER JOIN BIL_TARIFF_RATE btr ON btr.organizationId = btd.organizationId  AND btr.tariffId=btd.tariffId AND btr.tariffLineNo=btd.tariffLineNo
		WHERE bsm.organizationId = 'OJV_CML'
		AND bsm.warehouseId = 'CBT02'
	  AND bsm.customerId LIKE 'ADS'
		AND bth.effectiveFrom<=DATE_FORMAT('2021-12-01', '%Y-%m-%d') 
		AND bth.effectiveTo>=DATE_FORMAT('2022-12-01', '%Y-%m-%d') 
		AND btd.chargeCategory='IV' 
		AND btr.rate > 0
		#AND IFNULL(DAY(bth.billingdate),0)!=0 
		ORDER BY bsm.organizationId,bsm.customerId , btr.tariffId,btr.tariffLineNo,btr.tariffClassNo;