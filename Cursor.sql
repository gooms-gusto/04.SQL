DELIMITER $$     

CREATE PROCEDURE BulkMultiwarehouseSKU ()
BEGIN
	DECLARE finished INTEGER DEFAULT 0;
	DECLARE SKUNAME varchar(100);

	-- declare cursor for employee email
	DEClARE curEmail 
		CURSOR FOR 
			SELECT DISTINCT(sku) AS sku  FROM BAS_SKU WHERE customerId='API' AND SKU NOT IN('','NOSKU');

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

	OPEN curEmail;

	getEmail: LOOP
		FETCH curEmail INTO SKUNAME;
	
    INSERT INTO BAS_SKU_MULTIWAREHOUSE(organizationId, customerId, sku, warehouseId, tariffId, invChgWithShipment, laborRateBase, laborRate, putawayRule, qtyMin, qtyMax, replenishRule, cycleGroup, csCycleClass, eaCycleClass, lastCycleCount, noteText, udf01, udf02, udf03, udf04, udf05, currentVersion, oprSeqFlag, addWho, addTime, editWho, editTime, packId, defaultSupplierId, billingRate, putawayLocation, reportUom, reserveCode, templateName, tariffMasterId) VALUES('OJV_CML', 'API', SKUNAME, 'CBT02', '', 'N', NULL, NULL, 'API', 0.000, 99999999.000, '', NULL, '', '', NULL, x'', '', '', '', '', '', 102, '20211104160602000588RA172031009091[A1035]', 'WM_MARDIANSAH', '2021-11-04 13:44:09', 'WM_MARDIANSAH', '2021-11-04 16:06:02', '', '', 0.00000000, '', 'EA', 'IN', NULL, 'BIL00055');
	END LOOP getEmail;
	CLOSE curEmail;

END$$
DELIMITER ;


call BulkMultiwarehouseSKU;


USE wms_cml;

DROP PROCEDURE BulkMultiwarehouseSKU;

