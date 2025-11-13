USE wms_cml;
DROP PROCEDURE IF EXISTS CML_UPD_SO_PLT_CDN;
DELIMITER $$
CREATE 
	DEFINER = 'wms_cml'@'localhost'
PROCEDURE CML_UPD_SO_PLT_CDN(IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_ContainerID varchar(30),
IN IN_LDLNo varchar(30),
IN IN_PLTCDN varchar(30),
INOUT OUT_returnCode varchar(1000))
ENDPROC:
  BEGIN
    DECLARE od_allocationId varchar(10);
    DECLARE od_orderNo varchar(10);
    DECLARE OUT_Return_Code varchar(1000);
    DECLARE OD_CURSORDONE int DEFAULT 0;
    DECLARE v_row_count int DEFAULT 0;
    DECLARE v_total_updates int DEFAULT 0;
    DECLARE v_failed_updates int DEFAULT 0;
    DECLARE v_error_message varchar(1000) DEFAULT '';
    
    -- Add exit handler for SQL exceptions
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        GET DIAGNOSTICS CONDITION 1
            v_error_message = MESSAGE_TEXT;
        SET OUT_returnCode = CONCAT('999 - SQL Error: ', v_error_message);
    END;
    
    DECLARE _GETLINEORDER CURSOR FOR
    SELECT
      ACT_ALLOCATION_DETAILS.allocationDetailsId
    FROM ACT_ALLOCATION_DETAILS
      LEFT JOIN DOC_ORDER_HEADER
        ON ACT_ALLOCATION_DETAILS.ORDERNO = DOC_ORDER_HEADER.ORDERNO
    WHERE ACT_ALLOCATION_DETAILS.organizationId = IN_organizationId
    AND ACT_ALLOCATION_DETAILS.warehouseId = IN_warehouseId
    AND ACT_ALLOCATION_DETAILS.pickToTraceId = IN_ContainerID 
    AND ACT_ALLOCATION_DETAILS.customerId='PPG'
    AND DOC_ORDER_HEADER.orderNo IN (SELECT
    dld.orderNo
  FROM DOC_LOADING_DETAILS dld
  WHERE dld.organizationId = 'OJV_CML'
  AND dld.warehouseId = 'CBT01'
  AND dld.ldlNo = IN_LDLNo);
  
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET OD_CURSORDONE = 1;
    
    -- Start transaction
    START TRANSACTION;
    
    OPEN _GETLINEORDER;
  GETLINEORDERLOOP:
    LOOP FETCH FROM _GETLINEORDER INTO
      od_allocationId;
      IF OD_CURSORDONE = 1 THEN
        SET OD_CURSORDONE = FALSE;
        LEAVE GETLINEORDERLOOP;
      END IF;
      
      BEGIN
        -- Store current row count before update
        SET v_row_count = 0;
        
        UPDATE ACT_ALLOCATION_DETAILS aad
        SET aad.udf05 = IN_PLTCDN,
            aad.editTime = NOW()
        WHERE aad.organizationId = IN_organizationId
        AND aad.allocationDetailsId = od_allocationId
        AND aad.warehouseId = IN_warehouseId 
        AND aad.customerId='PPG';
        
        -- Get the number of rows affected by the update
        SET v_row_count = ROW_COUNT();
        
        -- Increment total updates counter
        SET v_total_updates = v_total_updates + 1;
        
        -- Check if update was successful
        IF v_row_count = 0 THEN
            -- No rows were updated, increment failed counter
            SET v_failed_updates = v_failed_updates + 1;
            SET v_error_message = CONCAT(v_error_message, 'Failed to update allocationDetailsId: ', od_allocationId, '; ');
        ELSE
            -- Verify the update by checking the value
            SELECT COUNT(*) INTO v_row_count
            FROM ACT_ALLOCATION_DETAILS
            WHERE organizationId = IN_organizationId
            AND allocationDetailsId = od_allocationId
            AND warehouseId = IN_warehouseId
            AND customerId = 'PPG'
            AND udf05 = IN_PLTCDN;
            
            IF v_row_count = 0 THEN
                -- Update failed verification
                SET v_failed_updates = v_failed_updates + 1;
                SET v_error_message = CONCAT(v_error_message, 'Verification failed for allocationDetailsId: ', od_allocationId, '; ');
            END IF;
        END IF;
        
      END;
    END LOOP GETLINEORDERLOOP;
    CLOSE _GETLINEORDER;
    
    -- Check if all updates were successful
    IF v_failed_updates = 0 AND v_total_updates > 0 THEN
        -- All updates successful
        COMMIT;
        SET OUT_returnCode = CONCAT('000 - Success. Total records updated: ', v_total_updates);
    ELSEIF v_total_updates = 0 THEN
        -- No records found to update
        ROLLBACK;
        SET OUT_returnCode = '001 - No records found matching the criteria';
    ELSE
        -- Some updates failed
        ROLLBACK;
        SET OUT_returnCode = CONCAT('002 - Error: ', v_failed_updates, ' out of ', v_total_updates, 
                                   ' updates failed. Details: ', v_error_message);
    END IF;
    
  END
$$
DELIMITER ;