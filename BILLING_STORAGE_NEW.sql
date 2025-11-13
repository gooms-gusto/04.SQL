CREATE DEFINER = 'wms_ftest'@'%'
PROCEDURE WMS_FTEST.BILL_STORAGE_DETAIL_NEW(IN IN_organizationId   VARCHAR(30),
IN IN_warehouseId VARCHAR(30),
IN IN_USERID VARCHAR(30),
IN IN_Language    VARCHAR(30),
IN IN_CustomerId VARCHAR(30),
INOUT OUT_returnCode VARCHAR(1000)
)
BEGIN
	####################################################################
	##变量定义
	DECLARE R_CURRENTDATE   	TIMESTAMP ;
	DECLARE R_OPDATE VARCHAR(10);
	DECLARE R_FMDATE   		VARCHAR(10);
	DECLARE R_TODATE   		VARCHAR(10);
	DECLARE R_BILLINGDAY  		INTEGER;
	DECLARE R_BILLINGDATE 		VARCHAR(10);
	DECLARE R_TARGETDATE VARCHAR(10);
	DECLARE R_DAYOFMONTH INT;
	DECLARE R_ORGANIZATIONID VARCHAR(30);
	DECLARE R_WAREHOUSEID VARCHAR(30);
	DECLARE R_CUSTOMERID   		VARCHAR(30);
	DECLARE R_STOCKDATE 		VARCHAR(10);
	DECLARE R_TARIFFID VARCHAR(10);
	DECLARE R_TARIFFMASTERID VARCHAR(20);
	DECLARE R_TARIFFLINENO INT(11);
	DECLARE R_TARIFFCLASSNO INT(11);
	DECLARE R_CHARGECATEGORY VARCHAR(20);
	DECLARE R_CHARGETYPE VARCHAR(20);
	DECLARE R_descrC   		VARCHAR(50);
	DECLARE R_ratebase VARCHAR(20);
	DECLARE R_rateperunit 	DECIMAL(24,8);
	DECLARE R_rate 	DECIMAL(24,8);
	DECLARE R_minQty 	VARCHAR(500);
	DECLARE R_minAmount		DECIMAL(24,8);
	DECLARE R_maxAmount		DECIMAL(24,8);
	DECLARE R_billQty		DECIMAL(24,8);
	DECLARE R_Cost	DECIMAL(24,8);
	DECLARE R_materialNo VARCHAR(500);
	DECLARE R_itemChargeCategory VARCHAR(500);
	DECLARE R_billMode VARCHAR(500);	
	DECLARE R_UDF06  VARCHAR(500);	
	DECLARE R_FINALAMOUNT		DECIMAL(24,8);
	DECLARE R_billsummaryId VARCHAR(30) DEFAULT '';
	DECLARE R_billsummaryNo VARCHAR(30) DEFAULT '';
	DECLARE R_LOCATIONCAT CHAR(2);
	DECLARE R_LOCATIONGROUP VARCHAR(500);
	DECLARE R_INCOMETAX  	DECIMAL(24,8);
	DECLARE R_CLASSFROM  	DECIMAL(24,8);
	DECLARE R_CLASSTO  	DECIMAL(24,8);
	DECLARE R_CONTRACTNO VARCHAR(100);
	DECLARE R_BILLINGMONTH		VARCHAR(10);
	DECLARE R_BILLINGPARTY		VARCHAR(10);
	DECLARE R_BILLTO		VARCHAR(30);
	DECLARE R_NROW			INTEGER;
	DECLARE c_WAREHOUSEID VARCHAR(30);
	DECLARE c_CUSTOMERID   		VARCHAR(30);
	DECLARE c_chargecategory VARCHAR(30);
	DECLARE c_charegetype VARCHAR(30);
	DECLARE c_locationId VARCHAR(60);
	DECLARE c_sku VARCHAR(255);
	DECLARE c_qtyonHand INT(11) DEFAULT NULL;
	DECLARE c_packkey VARCHAR(255) BINARY DEFAULT NULL;
	DECLARE c_UOM VARCHAR(255) BINARY DEFAULT NULL;
	DECLARE c_qtyallocated INT(11) DEFAULT NULL;
	DECLARE c_qtyonHold INT(11) DEFAULT NULL;
	DECLARE c_qtyavailable INT(11) DEFAULT NULL;
	DECLARE c_qtyPicked INT(11) DEFAULT NULL;
	DECLARE c_SKUDesc VARCHAR(550) BINARY DEFAULT NULL;
	DECLARE c_stockDate DATE DEFAULT NULL;
	DECLARE c_Cub DECIMAL(24, 8) DEFAULT NULL;
	DECLARE c_totalCub DECIMAL(24, 8) DEFAULT NULL;
	DECLARE c_grossWeight DECIMAL(18, 8) DEFAULT NULL;
	DECLARE c_netWeight DECIMAL(18, 8) DEFAULT NULL;
	DECLARE c_freightClass VARCHAR(255) BINARY DEFAULT NULL;
	DECLARE c_locationCategory VARCHAR(10) DEFAULT '';
	DECLARE R_UDF08 VARCHAR(500);
	DECLARE R_UDF07 VARCHAR(500);
	DECLARE R_Days	INT(11) DEFAULT NULL;
	####################################################################
	##游标定义
	DECLARE   inventory_done INT DEFAULT FALSE;
	DECLARE   tariff_done INT DEFAULT FALSE;
	DECLARE cur_Tariff   CURSOR FOR
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
		WHERE bsm.organizationId = IN_organizationId
		AND bsm.warehouseId = IN_warehouseId
	  AND bsm.customerId LIKE IN_CustomerId
		AND bth.effectiveFrom<=DATE_FORMAT(CURDATE(), '%Y-%m-%d') 
		AND bth.effectiveTo>=DATE_FORMAT(CURDATE(), '%Y-%m-%d') 
		AND btd.chargeCategory='IV' 
		AND btr.rate > 0
		#AND IFNULL(DAY(bth.billingdate),0)!=0 
		ORDER BY bsm.organizationId,bsm.customerId , btr.tariffId,btr.tariffLineNo,btr.tariffClassNo;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET tariff_done = 1;
	####################################################################
	##程序主体
	BEGIN
	SET R_CURRENTDATE = CURDATE();##yyyy-mm-dd
	#
	OPEN cur_Tariff ;
	getTariff:LOOP
		FETCH cur_Tariff   INTO R_ORGANIZATIONID, R_WAREHOUSEID,R_CUSTOMERID ,R_BILLINGDAY ,R_TARIFFID,R_TARIFFLINENO , R_TARIFFCLASSNO,R_CHARGECATEGORY,R_CHARGETYPE, R_descrC,
			R_ratebase ,R_ratePerUnit,R_rate,R_minAmount,R_maxAmount,R_minQty,R_materialNo,R_itemChargeCategory,R_billMode,R_LOCATIONCAT,R_LOCATIONGROUP,R_UDF06,R_UDF07,R_UDF08,
			R_INCOMETAX, R_CLASSFROM, R_CLASSTO, R_CONTRACTNO,R_TARIFFMASTERID,R_Cost,R_BILLINGPARTY;
		IF tariff_done THEN
			SET tariff_done =FALSE;
			LEAVE getTariff;    
		END IF; 
		#
		SET R_BILLINGDATE =  STR_TO_DATE(CONCAT(YEAR(R_CURRENTDATE),'-',MONTH(R_CURRENTDATE),'-',R_BILLINGDAY), '%Y-%m-%d');
		SET R_OPDATE = DATE_FORMAT(DATE_ADD(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d');
		#SET R_FMDATE = DATE_FORMAT(R_BILLINGDATE, '%Y-%m-%d');
		#SET R_TODATE =DATE_FORMAT(R_BILLINGDATE, '%Y-%m-%d');
	
		SET R_FMDATE = DATE_FORMAT(DATE_ADD(R_BILLINGDATE, INTERVAL -1 MONTH), '%Y-%m-%d');
		SET R_TODATE = DATE_ADD(R_BILLINGDATE, INTERVAL -1 DAY); 
	
		SET R_Days	= DATEDIFF(R_TODATE,R_FMDATE) + 1;
		SET R_billsummaryId = '';
		#
		IF R_BILLINGPARTY = 'BI' THEN
			SET R_BILLTO = R_CustomerId ;
			SELECT  CUSTOMERID 
			INTO R_BILLTO
			FROM BAS_CUSTOMER
			WHERE refOwner = R_CustomerId AND CustomerType='BI'
			LIMIT 1;
		ELSE 
			SET R_BILLTO = R_CustomerId ;
		END IF;
		#
		IF (R_BILLINGDATE = R_CURRENTDATE) THEN 
		BEGIN
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
			DROP TEMPORARY TABLE IF EXISTS TMP_BIL_SUMMARY_INFO2;
			CREATE TEMPORARY TABLE  TMP_BIL_SUMMARY_INFO2 (  
				organizationId VARCHAR(20) , 
				warehouseId VARCHAR(20) , 
				customerId VARCHAR(30), 
				qtyonHand DECIMAL(24,8) DEFAULT 0
				);
			
			#当前费率需要处理的库存数据
			CASE WHEN R_billMode IN ('INTRACE','INPL','INLOC') THEN  
				BEGIN
					INSERT INTO TMP_BIL_SUMMARY_INFO1(organizationId,warehouseId,StockDate,customerId,qtyLoc,qtyTrace,qtyMuid,qtyCube)
					SELECT a.organizationId,  a.warehouseId,R_TODATE,a.customerId,COUNT(DISTINCT a.locationId),COUNT(DISTINCT a.traceId),COUNT(DISTINCT a.muid),SUM(a.totalCube) FROM(
					SELECT   zib.organizationId,  zib.warehouseId,zib.customerId,zib.locationId,zib.traceId,zib.muid,zib.totalCube
					FROM Z_InventoryBalance_Real zib      
					INNER JOIN INV_LOT_ATT ila ON ila.organizationId=zib.organizationId AND ila.lotNum=zib.LotNum
					INNER JOIN BAS_LOCATION bl ON bl.organizationId=zib.organizationId AND bl.warehouseId =zib.warehouseId AND bl.locationId =zib.locationId 
					INNER JOIN BAS_SKU_MULTIWAREHOUSE bsm 
									ON bsm.organizationId = zib.organizationId AND bsm.warehouseId=zib.warehouseId AND bsm.customerId = zib.customerId AND bsm.SKU=zib.sku
					#
					WHERE zib.organizationId=R_ORGANIZATIONID 
					AND zib.warehouseId=R_WAREHOUSEID 
					AND zib.StockDate=R_OPDATE       
					AND zib.customerId = R_CUSTOMERID 
					AND (ila.lotAtt07='R' OR R_CHARGETYPE<>'PL')
					AND bsm.tariffMasterId=R_TARIFFMASTERID
					AND (ISNULL(R_LOCATIONCAT) OR R_LOCATIONCAT='' OR bl.locationCategory =  R_LOCATIONCAT)
					AND (ISNULL(R_LOCATIONGROUP) OR R_LOCATIONGROUP='' OR bl.udf05 =  R_LOCATIONGROUP) 
					AND (ISNULL(R_UDF08) OR R_UDF08='' OR bl.locGroup1 =  R_UDF08) 
					##
				UNION ALL
					SELECT atl.organizationId,  atl.warehouseId,atl.toCustomerId customerId,atl.toLocation AS locationId,atl.toId traceId, atl.toMuid muid,atl.totalCubic
					FROM ACT_TRANSACTION_LOG atl 
					INNER JOIN INV_LOT_ATT ila ON ila.organizationId=atl.organizationId AND ila.lotNum=atl.toLotNum
					INNER JOIN BAS_LOCATION bl ON bl.organizationId=atl.organizationId AND bl.warehouseId=atl.toWarehouse AND bl.locationId=atl.toLocation
					INNER JOIN BAS_SKU bs ON bs.organizationId=atl.organizationId AND bs.customerId=atl.toCustomerId AND bs.sku=atl.toSku
					#
					WHERE atl.organizationId=R_ORGANIZATIONID 
					AND atl.warehouseId=R_WAREHOUSEID 
					AND atl.status='99' AND atl.transactionType='IN'    
					AND atl.transactionTime>=STR_TO_DATE(R_FMDATE, '%Y-%m-%d')
					AND ila.lotAtt03>=R_FMDATE  AND ila.lotAtt03<=R_TODATE 
					AND (ila.lotAtt07='R' OR R_CHARGETYPE<>'PL')
					AND (ISNULL(R_LOCATIONCAT) OR R_LOCATIONCAT='' OR bl.locationCategory =  R_LOCATIONCAT)
					AND (ISNULL(R_LOCATIONGROUP) OR R_LOCATIONGROUP='' OR bl.udf05 =  R_LOCATIONGROUP)
					AND (ISNULL(R_UDF08) OR R_UDF08='' OR bl.locGroup1 =  R_UDF08) 
					)a 
					GROUP BY a.organizationId,a.warehouseId,a.customerId
					;
					#
				END;
			ELSE 
				BEGIN
					INSERT INTO TMP_BIL_SUMMARY_INFO1(organizationId,warehouseId,StockDate,customerId,qtyLoc,qtyTrace,qtyMuid,qtyCube)
					SELECT   zib.organizationId,  zib.warehouseId,zib.StockDate,zib.customerId
									,COUNT(DISTINCT zib.locationId),COUNT(DISTINCT zib.traceId),COUNT(DISTINCT zib.muid),SUM(zib.totalCube)         
					FROM Z_InventoryBalance_Real zib      
					INNER JOIN INV_LOT_ATT ila ON ila.organizationId=zib.organizationId AND ila.lotNum=zib.LotNum
					INNER JOIN BAS_LOCATION bl ON bl.organizationId=zib.organizationId AND bl.warehouseId =zib.warehouseId AND bl.locationId =zib.locationId 
					INNER JOIN BAS_SKU_MULTIWAREHOUSE bsm 
									ON bsm.organizationId = zib.organizationId AND bsm.warehouseId=zib.warehouseId AND bsm.customerId = zib.customerId AND bsm.SKU=zib.sku
					#
					WHERE zib.organizationId=R_ORGANIZATIONID 
					AND zib.warehouseId=R_WAREHOUSEID 
					AND zib.StockDate>=R_FMDATE AND zib.StockDate<=R_TODATE     
					AND zib.customerId = R_CUSTOMERID 
					AND (ila.lotAtt07='R' OR R_CHARGETYPE<>'PL')
					AND bsm.tariffMasterId=R_TARIFFMASTERID
					AND (ISNULL(R_LOCATIONCAT) OR R_LOCATIONCAT='' OR bl.locationCategory =  R_LOCATIONCAT)
					AND (ISNULL(R_LOCATIONGROUP) OR R_LOCATIONGROUP='' OR bl.udf05 =  R_LOCATIONGROUP) 
					AND (ISNULL(R_UDF08) OR R_UDF08='' OR bl.locGroup1 =  R_UDF08) 
					GROUP BY zib.organizationId,zib.warehouseId,zib.StockDate,zib.customerId
					;
					#
				END;
			END CASE;
			
			#当前费率不同维度整理
			IF R_billMode IN ('MAXLOC','INLOC') THEN
				BEGIN
					INSERT INTO TMP_BIL_SUMMARY_INFO2(organizationId,warehouseId,customerId,qtyonHand)
					SELECT tb.organizationId,  tb.warehouseId, tb.customerId
								,MAX(IF(tb.qtyLoc>=R_CLASSTO,R_CLASSTO-R_CLASSFROM,IF(tb.qtyLoc-R_CLASSFROM<R_minQty,R_minQty,tb.qtyLoc-R_CLASSFROM)))
					FROM TMP_BIL_SUMMARY_INFO1 tb
					WHERE tb.qtyLoc > R_CLASSFROM
					GROUP BY tb.organizationId,  tb.warehouseId, tb.customerId;
				END;
			ELSEIF R_billMode IN ('MAXTRACE','INTRACE') THEN
				BEGIN
					INSERT INTO TMP_BIL_SUMMARY_INFO2(organizationId,warehouseId,customerId,qtyonHand)
					SELECT tb.organizationId,  tb.warehouseId, tb.customerId
								,MAX(IF(tb.qtyTrace>=R_CLASSTO,R_CLASSTO-R_CLASSFROM,IF(tb.qtyTrace-R_CLASSFROM<R_minQty,R_minQty,tb.qtyTrace-R_CLASSFROM)))
					FROM TMP_BIL_SUMMARY_INFO1 tb
					WHERE tb.qtyTrace > R_CLASSFROM
					GROUP BY tb.organizationId,  tb.warehouseId, tb.customerId;
				END;
			ELSEIF R_billMode IN ('MAXPL','INPL') THEN
				BEGIN
					INSERT INTO TMP_BIL_SUMMARY_INFO2(organizationId,warehouseId,customerId,qtyonHand)
					SELECT tb.organizationId,  tb.warehouseId, tb.customerId
								,MAX(IF(tb.qtyMuid>=R_CLASSTO,R_CLASSTO-R_CLASSFROM,IF(tb.qtyMuid-R_CLASSFROM<R_minQty,R_minQty,tb.qtyMuid-R_CLASSFROM)))
					FROM TMP_BIL_SUMMARY_INFO1 tb
					WHERE tb.qtyMuid > R_CLASSFROM
					GROUP BY tb.organizationId,  tb.warehouseId, tb.customerId;
				END;
			ELSEIF R_billMode IN ('MONTHLOC') THEN
				BEGIN
					INSERT INTO TMP_BIL_SUMMARY_INFO2(organizationId,warehouseId,customerId,qtyonHand)
					SELECT tb.organizationId,  tb.warehouseId, tb.customerId
								,SUM(IF(tb.qtyLoc>=R_CLASSTO,R_CLASSTO-R_CLASSFROM,IF(tb.qtyLoc-R_CLASSFROM<R_minQty,R_minQty,tb.qtyLoc-R_CLASSFROM)))/IF(R_UDF07='Y',R_Days,1)
					FROM TMP_BIL_SUMMARY_INFO1 tb
					WHERE tb.qtyLoc > R_CLASSFROM
					GROUP BY tb.organizationId,  tb.warehouseId, tb.customerId;
				END;
			ELSEIF R_billMode IN ('MONTHTRACE') THEN
				BEGIN
					INSERT INTO TMP_BIL_SUMMARY_INFO2(organizationId,warehouseId,customerId,qtyonHand)
					SELECT tb.organizationId,  tb.warehouseId, tb.customerId
								,SUM(IF(tb.qtyTrace>=R_CLASSTO,R_CLASSTO-R_CLASSFROM,IF(tb.qtyTrace-R_CLASSFROM<R_minQty,R_minQty,tb.qtyTrace-R_CLASSFROM)))/IF(R_UDF07='Y',R_Days,1)
					FROM TMP_BIL_SUMMARY_INFO1 tb
					WHERE tb.qtyTrace > R_CLASSFROM
					GROUP BY tb.organizationId,  tb.warehouseId, tb.customerId;
				END;
			ELSEIF R_billMode IN ('MONTHPL') THEN
				BEGIN
					INSERT INTO TMP_BIL_SUMMARY_INFO2(organizationId,warehouseId,customerId,qtyonHand)
					SELECT tb.organizationId,  tb.warehouseId, tb.customerId
								,SUM(IF(tb.qtyMuid>=R_CLASSTO,R_CLASSTO-R_CLASSFROM,IF(tb.qtyMuid-R_CLASSFROM<R_minQty,R_minQty,tb.qtyMuid-R_CLASSFROM)))/IF(R_UDF07='Y',R_Days,1)
					FROM TMP_BIL_SUMMARY_INFO1 tb
					WHERE tb.qtyMuid > R_CLASSFROM
					GROUP BY tb.organizationId,  tb.warehouseId, tb.customerId;
				END;
			ELSEIF R_billMode IN ('AVGCBM') THEN
				BEGIN
					INSERT INTO TMP_BIL_SUMMARY_INFO2(organizationId,warehouseId,customerId,qtyonHand)
					SELECT tb.organizationId,  tb.warehouseId, tb.customerId
								,SUM(IF(tb.qtyCube>=R_CLASSTO,R_CLASSTO-R_CLASSFROM,IF(tb.qtyCube-R_CLASSFROM<R_minQty,R_minQty,tb.qtyCube-R_CLASSFROM)))/R_Days
					FROM TMP_BIL_SUMMARY_INFO1 tb
					WHERE tb.qtyCube > R_CLASSFROM
					GROUP BY tb.organizationId,  tb.warehouseId, tb.customerId;
				END;
			ELSEIF R_billMode IN ('DAILYCBM') THEN
				BEGIN
					INSERT INTO TMP_BIL_SUMMARY_INFO2(organizationId,warehouseId,customerId,qtyonHand)
					SELECT tb.organizationId,  tb.warehouseId, tb.customerId
								,SUM(IF(tb.qtyCube>=R_CLASSTO,R_CLASSTO-R_CLASSFROM,IF(tb.qtyCube-R_CLASSFROM<R_minQty,R_minQty,tb.qtyCube-R_CLASSFROM)))
					FROM TMP_BIL_SUMMARY_INFO1 tb
					WHERE tb.qtyCube > R_CLASSFROM
					GROUP BY tb.organizationId,  tb.warehouseId, tb.customerId;
				END;
			ELSE
				SELECT CONCAT('Bill Mode : ' , R_billMode , ' not found.') AS Message;
			END IF;
			
			#费率生成
			IF EXISTS(SELECT 1 FROM TMP_BIL_SUMMARY_INFO2) THEN
				#
				IF EXISTS( SELECT 1 FROM BIL_SUMMARY WHERE billingFromDate=R_BILLINGDATE AND BillingToDate=R_BILLINGDATE 
					AND ChargeCategory=R_CHARGECATEGORY AND chargeType=R_CHARGETYPE
					AND CustomerID =R_CUSTOMERID 
					AND billTo =R_BILLTO 
					AND rateBase = R_rateBase
					AND arNo IN  ('*')) THEN 
					INSERT INTO BIL_SUMMARY_LOG
					SELECT * FROM BIL_SUMMARY WHERE billingFromDate=R_BILLINGDATE AND BillingToDate=R_BILLINGDATE 
					AND ChargeCategory=R_CHARGECATEGORY AND chargeType=R_CHARGETYPE
					AND CustomerID =R_CUSTOMERID 
					AND billTo =R_BILLTO 
					AND rateBase = R_rateBase
					AND arNo IN  ('*');
					DELETE FROM BIL_SUMMARY 
					WHERE billingFromDate=R_BILLINGDATE AND BillingToDate=R_BILLINGDATE 
					AND ChargeCategory=R_CHARGECATEGORY AND chargeType=R_CHARGETYPE
					AND CustomerID =R_CUSTOMERID 
					AND billTo =R_BILLTO 
					AND rateBase = R_rateBase
					AND arNo IN  ('*'); 
				END IF; 
				#
				IF (R_billsummaryId='') THEN
					SET @linenumber = 0 ;
					SET OUT_returnCode ='*_*';
					CALL SPCOM_GetIDSequence(R_ORGANIZATIONID,R_WAREHOUSEID,IN_Language,'BILLINGSUMMARYID',R_billsummaryId,OUT_returnCode);  
					IF SUBSTRING(OUT_returnCode,1,3)<>'000' THEN
						SET OUT_returnCode ='999#计费流水获取异常';
						LEAVE getTariff;
					END IF;
				END IF;
				#
				INSERT INTO BIL_SUMMARY
				(organizationId,warehouseId,billingSummaryId,billingFromDate,billingToDate, customerId
					,sku ,lotNum ,traceId ,tariffId ,chargeCategory ,chargeType ,descr ,rateBase ,chargePerUnits
					,qty ,uom,cubic ,weight ,chargeRate ,amount ,billingAmount ,cost ,amountPayable ,amountPaid
					,confirmTime ,confirmWho ,docType ,docNo ,createTransactionid ,notes ,ediSendTime
					,billTo ,settleTime ,settleWho,followUp ,invoiceType ,paidTo ,costConfirmFlag 
					,costConfirmTime ,costConfirmWho ,costSettleFlag ,costSettleTime ,costSettleWho ,incomeTaxRate 
					,costTaxRate ,incomeTax ,cosTax ,incomeWithoutTax ,cosWithoutTax ,costInvoiceType ,noteText 
					,udf01 ,udf02 ,udf03 ,udf04 ,udf05 ,currentVersion ,oprSeqFlag ,addWho ,ADDTIME ,editWho ,editTime ,locationCategory
					,manual ,docLineNo ,arNo ,arLineNo ,apNo ,apLineNo ,ediSendFlag ,ediErrorCode ,ediErrorMessage ,ediSendTime2 ,ediSendFlag2
					,ediErrorCode2 ,ediErrorMessage2 ,billingTranCategory ,orderType ,containerType ,containerSize
				)
				SELECT   bil.organizationId, bil.warehouseId , CONCAT(R_billsummaryId , '*' ,LPAD((@linenumber:=@linenumber + 1),3, '0'))
					,R_TODATE billingFromDate  , R_TODATE billingToDate , bil.customerId
					,'', '', '' ,R_TARIFFID, R_CHARGECATEGORY, R_chargetype, R_descrC,R_rateBase, R_rateperunit
					,qtyonHand,  'PL' uom,IF(R_billMode LIKE '%CBM',qtyonHand,0) cubic ,0 weight ,  R_rate, qtyonHand*R_rate/R_rateperunit,qtyonHand*R_rate/R_rateperunit + qtyonHand*R_rate/R_rateperunit*R_INCOMETAX , 0 ,R_cost*qtyonHand ,0
					,NOW() confirmTime ,'' confirmWho,'' docType,'' docNo,'' createTransactionid,'' notes , NOW() ediSendTime
					,R_BILLTO billTo,NOW() settleTime,'' settleWho,'' followUp,'' invoiceType ,'' paidTo ,'' costConfirmFlag
					,NOW() costConfirmTime,'' costConfirmWho,'' costSettleFlag,NOW() costSettleTime ,'' costSettleWho,0 incomeTaxRate
					,0 costTaxRate ,R_INCOMETAX incomeTax ,0 cosTax ,qtyonHand*R_rate/R_rateperunit incomeWithoutTax ,0 cosWithoutTax ,'' costInvoiceType,'' noteText,
					R_materialNo AS udf01 , R_itemChargeCategory AS udf02  ,R_UDF08 udf03,R_UDF06 udf04,R_UDF07 udf05 ,
					0 currentVersion,'2020' oprSeqFlag,IN_USERID addWho,NOW() ADDTIME ,IN_USERID editWho ,NOW() editTime
					,R_LOCATIONCAT locationCategory ,'' manual,0  lineCount ,'*' arNo ,0 arLineNo,'*' apNo
					,0 apLineNo ,'N' ediSendFlag ,'' ediErrorCode ,'' ediErrorMessage,NOW() ediSendTime2,'N' ediSendFlag2,'' ediErrorCode2 ,'' ediErrorMessage2
					,'' billingTranCategory ,'' orderType ,'' containerType,'' containerSize 
				FROM TMP_BIL_SUMMARY_INFO2 bil
				;
			
			END IF;     
			
			DROP TEMPORARY TABLE IF EXISTS TMP_BIL_SUMMARY_INFO1;
			DROP TEMPORARY TABLE IF EXISTS TMP_BIL_SUMMARY_INFO2;
		END;
		END IF;
	END LOOP getTariff;
	CLOSE cur_Tariff;
	SET OUT_returnCode ='000';
	END;
END