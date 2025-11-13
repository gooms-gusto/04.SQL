	SELECT   zib.organizationId, zib.warehouseId,zib.StockDate,zib.customerId
									,COUNT(DISTINCT zib.locationId),COUNT(DISTINCT zib.traceId),COUNT(DISTINCT zib.muid),SUM(zib.totalCube)         
					FROM Z_InventoryBalance_Real zib      
					INNER JOIN INV_LOT_ATT ila ON ila.organizationId=zib.organizationId AND ila.lotNum=zib.LotNum
					INNER JOIN BAS_LOCATION bl ON bl.organizationId=zib.organizationId AND bl.warehouseId =zib.warehouseId AND bl.locationId =zib.locationId 
					INNER JOIN BAS_SKU_MULTIWAREHOUSE bsm 
									ON bsm.organizationId = zib.organizationId AND bsm.warehouseId=zib.warehouseId AND bsm.customerId = zib.customerId AND bsm.SKU=zib.sku
					#
					WHERE zib.organizationId='OJV_CML' 
					AND zib.warehouseId='CBT01' 
					AND zib.StockDate>='2022-07-29' AND zib.StockDate<='2022-08-28'     
					AND zib.customerId = 'MAP'
					AND (ila.lotAtt07='R' OR 'ST'<>'PL')
					AND bsm.tariffMasterId='BIL00053'
					AND (ISNULL('BS') OR 'BS'='' OR bl.locationCategory =  'BS')
					AND (ISNULL('') OR ''='' OR bl.udf05 =  '') 
					AND (ISNULL('') OR ''='' OR bl.locGroup1 =  '') 
					GROUP BY zib.organizationId,zib.warehouseId,zib.StockDate,zib.customerId;


  		SELECT DISTINCT bsm.organizationId,bsm.warehouseId, bsm.CUSTOMERID,DAY(bth.billingdate)  AS R_BILLINGDAY,  CURDATE() R_CURRENTDATE,
         STR_TO_DATE(CONCAT(YEAR( CURDATE()),'-',MONTH(CURDATE()),'-',DAY(bth.billingdate)), '%Y-%m-%d') R_BILLINGDATE,
        DATE_FORMAT(DATE_ADD(DATE_ADD(DAY(bth.billingdate) , INTERVAL -1 MONTH), INTERVAL -1 DAY), '%Y-%m-%d') R_OPDATE,
        DATE_FORMAT(DATE_ADD(bth.billingdate, INTERVAL -1 MONTH), '%Y-%m-%d') R_FMDATE,
         DATE_ADD(STR_TO_DATE(CONCAT(YEAR( CURDATE()),'-',MONTH(CURDATE()),'-',DAY(bth.billingdate)), '%Y-%m-%d'), INTERVAL -1 DAY) R_TODATE,
			btr.tariffId R_TARIFFID,
        btr.tariffLineNo R_TARIFFLINENO, 
        btr.tariffClassNo R_TARIFFCLASSNO,
        btd.chargeCategory R_CHARGECATEGORY,
        btd.chargeType R_CHARGETYPE, 
        btd.descrC R_descrC,
        btd.ratebase R_ratebase
			,btr.ratePerUnit R_ratePerUnit,
        btr.rate R_rate,
        btd.minAmount R_minAmount,
        btd.maxAmount R_maxAmount 
			,IF(btd.UDF03 = '', 0, btd.UDF03) R_minQty,
        btd.UDF01 AS R_materialNo,
        btd.udf02 AS R_itemChargeCategory,
        btd.udf04 R_billMode
			,locationCategory R_LOCATIONCAT, 
        btd.UDF05 R_LOCATIONGROUP,
        btd.UDF06 R_UDF06,
        btd.UDF07 R_UDF07,
        btd.UDF08 R_UDF08
			,IFNULL(btd.incomeTaxRate,0) R_INCOMETAX  , CASE WHEN chargeType = 'ES' THEN  IFNULL(btr.classfrom,0) - 1 ELSE IFNULL(btr.classfrom,0) END R_CLASSFROM
			,IFNULL(classTo,0) R_CLASSTO,
        bth.contractNo R_CONTRACTNO,
        bth.tariffMasterId R_TARIFFMASTERID,
        btr.cost R_Cost , 
        btd.billingParty R_BILLINGPARTY
		FROM BAS_SKU_MULTIWAREHOUSE bsm 
		INNER JOIN BAS_CUSTOMER bc ON bc.customerId=bsm.customerId AND bc.organizationId=bsm.organizationId AND bc.CustomerType='OW'
		INNER JOIN BIL_TARIFF_HEADER bth ON bth.organizationId=bsm.organizationId AND bth.tariffMasterId = bsm.tariffMasterId
		INNER JOIN BIL_TARIFF_DETAILS btd ON btd.organizationId=bth.organizationId  AND btd.tariffId =  bth.tariffId
		INNER JOIN BIL_TARIFF_RATE btr ON btr.organizationId = btd.organizationId  AND btr.tariffId=btd.tariffId AND btr.tariffLineNo=btd.tariffLineNo
		WHERE bsm.organizationId = 'OJV_CML'
		AND bsm.warehouseId = 'CBT01'
	  AND bsm.customerId LIKE 'MAP'
		AND bth.effectiveFrom<=DATE_FORMAT(CURDATE(), '%Y-%m-%d') 
		AND bth.effectiveTo>=DATE_FORMAT(CURDATE(), '%Y-%m-%d') 
		AND btd.chargeCategory='IV' 
		AND btr.rate > 0
		#AND IFNULL(DAY(bth.billingdate),0)!=0 
		ORDER BY bsm.organizationId,bsm.customerId , btr.tariffId,btr.tariffLineNo,btr.tariffClassNo;