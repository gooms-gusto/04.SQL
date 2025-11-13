--
-- Simple ID Generator with Custom Function
-- Format: PREFIX + SEQUENCE + DATE (YYMMDD)
--

SET NAMES 'utf8';
USE wms_cml;

-- Create sequence counter table
CREATE TABLE IF NOT EXISTS Z_ID_SEQUENCE_COUNTER (
    organizationId VARCHAR(20) NOT NULL,
    warehouseId VARCHAR(20) NOT NULL,
    idSequenceName VARCHAR(50) NOT NULL,
    currentSequence BIGINT NOT NULL DEFAULT 0,
    lastResetDate DATE,
    createdDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modifiedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (organizationId, warehouseId, idSequenceName),
    INDEX idx_sequence_name (idSequenceName)
) ENGINE=InnoDB;

DELIMITER $$

-- Create the simple ID generator function
CREATE FUNCTION Z_FN_GenerateID(
    p_organizationId VARCHAR(20),
    p_warehouseId VARCHAR(20),
    p_prefix VARCHAR(10),
    p_idSequenceName VARCHAR(50)
)
RETURNS VARCHAR(50)
NOT DETERMINISTIC
MODIFIES SQL DATA
READS SQL DATA
SQL SECURITY INVOKER
COMMENT 'Generate ID with format: PREFIX + SEQUENCE + YYMMDD'
BEGIN
    DECLARE v_sequence BIGINT DEFAULT 0;
    DECLARE v_current_date DATE;
    DECLARE v_date_suffix VARCHAR(6);
    DECLARE v_formatted_id VARCHAR(50);
    DECLARE v_sequence_str VARCHAR(10);
    
    -- Get current date
    SET v_current_date = CURDATE();
    SET v_date_suffix = DATE_FORMAT(v_current_date, '%y%m%d');
    
    -- Insert or update sequence counter
    INSERT INTO Z_ID_SEQUENCE_COUNTER 
        (organizationId, warehouseId, idSequenceName, currentSequence, lastResetDate)
    VALUES 
        (p_organizationId, p_warehouseId, p_idSequenceName, 1, v_current_date)
    ON DUPLICATE KEY UPDATE
        currentSequence = CASE 
            WHEN lastResetDate < v_current_date THEN 1
            ELSE currentSequence + 1
        END,
        lastResetDate = v_current_date,
        modifiedDate = CURRENT_TIMESTAMP;
    
    -- Get the current sequence value
    SELECT currentSequence INTO v_sequence
    FROM Z_ID_SEQUENCE_COUNTER
    WHERE organizationId = p_organizationId
      AND warehouseId = p_warehouseId
      AND idSequenceName = p_idSequenceName;
    
    -- Format sequence number with leading zeros (7 digits)
    SET v_sequence_str = LPAD(v_sequence, 7, '0');
    
    -- Combine: PREFIX + SEQUENCE + DATE
    SET v_formatted_id = CONCAT(p_prefix, v_sequence_str, v_date_suffix);
    
    RETURN v_formatted_id;
END$$

-- Create a read-only function to preview the next ID without incrementing
CREATE FUNCTION FN_PreviewNextID(
    p_organizationId VARCHAR(20),
    p_warehouseId VARCHAR(20),
    p_prefix VARCHAR(10),
    p_idSequenceName VARCHAR(50)
)
RETURNS VARCHAR(50)
DETERMINISTIC
READS SQL DATA
COMMENT 'Preview next ID without incrementing counter'
BEGIN
    DECLARE v_sequence BIGINT DEFAULT 0;
    DECLARE v_current_date DATE;
    DECLARE v_date_suffix VARCHAR(6);
    DECLARE v_formatted_id VARCHAR(50);
    DECLARE v_sequence_str VARCHAR(10);
    DECLARE v_last_reset_date DATE;
    
    -- Get current date
    SET v_current_date = CURDATE();
    SET v_date_suffix = DATE_FORMAT(v_current_date, '%y%m%d');
    
    -- Get current sequence value
    SELECT currentSequence, lastResetDate 
    INTO v_sequence, v_last_reset_date
    FROM Z_ID_SEQUENCE_COUNTER
    WHERE organizationId = p_organizationId
      AND warehouseId = p_warehouseId
      AND idSequenceName = p_idSequenceName;
    
    -- If no record found or date changed, sequence would be 1
    IF v_sequence IS NULL OR v_last_reset_date < v_current_date THEN
        SET v_sequence = 1;
    ELSE
        SET v_sequence = v_sequence + 1;
    END IF;
    
    -- Format sequence number with leading zeros (7 digits)
    SET v_sequence_str = LPAD(v_sequence, 7, '0');
    
    -- Combine: PREFIX + SEQUENCE + DATE
    SET v_formatted_id = CONCAT(p_prefix, v_sequence_str, v_date_suffix);
    
    RETURN v_formatted_id;
END$$

-- Create a procedure to reset sequence counter
CREATE PROCEDURE SP_ResetSequenceCounter(
    IN p_organizationId VARCHAR(20),
    IN p_warehouseId VARCHAR(20),
    IN p_idSequenceName VARCHAR(50)
)
COMMENT 'Reset sequence counter to 0'
BEGIN
    UPDATE Z_ID_SEQUENCE_COUNTER
    SET currentSequence = 0,
        lastResetDate = CURDATE(),
        modifiedDate = CURRENT_TIMESTAMP
    WHERE organizationId = p_organizationId
      AND warehouseId = p_warehouseId
      AND idSequenceName = p_idSequenceName;
      
    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sequence not found';
    END IF;
END$$

-- Create a function to get current sequence info
CREATE FUNCTION FN_GetSequenceInfo(
    p_organizationId VARCHAR(20),
    p_warehouseId VARCHAR(20),
    p_idSequenceName VARCHAR(50)
)
RETURNS JSON
DETERMINISTIC
READS SQL DATA
COMMENT 'Get sequence information as JSON'
BEGIN
    DECLARE v_result JSON;
    
    SELECT JSON_OBJECT(
        'organizationId', organizationId,
        'warehouseId', warehouseId,
        'idSequenceName', idSequenceName,
        'currentSequence', currentSequence,
        'lastResetDate', DATE_FORMAT(lastResetDate, '%Y-%m-%d'),
        'createdDate', DATE_FORMAT(createdDate, '%Y-%m-%d %H:%i:%s'),
        'modifiedDate', DATE_FORMAT(modifiedDate, '%Y-%m-%d %H:%i:%s')
    ) INTO v_result
    FROM Z_ID_SEQUENCE_COUNTER
    WHERE organizationId = p_organizationId
      AND warehouseId = p_warehouseId
      AND idSequenceName = p_idSequenceName;
    
    RETURN IFNULL(v_result, JSON_OBJECT('error', 'Sequence not found'));
END$$

DELIMITER ;

-- =====================================================
-- USAGE EXAMPLES
-- =====================================================

-- 1. Generate a new ID (your example)
-- SELECT Z_FN_GenerateID('OJV_CML', '*', 'STR', 'sortir') AS generated_id;
-- Result: STR0000001251021 (assuming it's the first ID on 2025-10-21)

-- 2. Generate multiple IDs in a SELECT statement
-- SELECT 
--     customer_name,
--     Z_FN_GenerateID('OJV_CML', 'WH001', 'ORD', 'order') AS order_id,
--     NOW() AS order_date
-- FROM customers
-- WHERE status = 'ACTIVE';

-- 3. Use in INSERT statement
-- INSERT INTO transactions (transaction_id, customer_id, amount)
-- VALUES (Z_FN_GenerateID('OJV_CML', '*', 'TRX', 'transaction'), 'CUST001', 1000.00);

-- 4. Preview next ID without incrementing
-- SELECT FN_PreviewNextID('OJV_CML', '*', 'STR', 'sortir') AS next_id;

-- 5. Get sequence information
-- SELECT FN_GetSequenceInfo('OJV_CML', '*', 'sortir') AS sequence_info;

-- 6. View all sequences
-- SELECT 
--     organizationId,
--     warehouseId,
--     idSequenceName,
--     currentSequence,
--     lastResetDate,
--     modifiedDate
-- FROM Z_ID_SEQUENCE_COUNTER
-- ORDER BY modifiedDate DESC;

-- 7. Reset a sequence (be careful!)
-- CALL SP_ResetSequenceCounter('OJV_CML', '*', 'sortir');

-- =====================================================
-- TEST DATA AND EXAMPLES
-- =====================================================

-- Insert some test sequences
INSERT INTO Z_ID_SEQUENCE_COUNTER (organizationId, warehouseId, idSequenceName, currentSequence, lastResetDate)
VALUES 
    ('OJV_CML', '*', 'sortir', 0, CURDATE()),
    ('OJV_CML', 'WH001', 'order', 0, CURDATE()),
    ('OJV_CML', 'WH001', 'invoice', 0, CURDATE())
ON DUPLICATE KEY UPDATE currentSequence = currentSequence;

-- Test the function with your example
SELECT Z_FN_GenerateID('OJV_CML', '*', 'STR', 'sortir') AS test_id;

-- Generate multiple IDs to see the sequence increment
SELECT 
    Z_FN_GenerateID('OJV_CML', '*', 'STRCBT01', 'sortir') AS id1


SELECT * FROM Z_ID_SEQUENCE_COUNTER