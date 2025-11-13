SELECT * FROM BSM_CODE_ML bcm
WHERE bcm.organizationId='OJV_CML' 
AND bcm.languageId='en' 
AND bcm.codeType='CHARGE_CATEGORY';







SELECT * FROM BIL_CRM_HEADER bch WHERE bch.OpportunityId='00000OPTYDUMMYPTABC';

SELECT * FROM BIL_CRM_DETAILS bcd WHERE bcd.OpportunityId='00000OPTYDUMMYPTABC';


USE wms_cml;

INSERT INTO BIL_CRM_HEADER (organizationId, warehouseId, OpportunityId, AgreementNo, CustomerId, 
effectiveFrom, effectiveTo, addWho, addTime, oprSeqFlag, currentVersion) VALUES
('OJV_CML', 'CBT01', '00000OPTYDUMMYPTABC', 'LOADUMMYPTABC', '369696969696', '2025-01-01 00:00:00',
 '2025-12-31 00:00:00', 'EDI', NOW(), '2025', 100);


USE wms_cml;

INSERT INTO BIL_CRM_DETAILS (organizationId, warehouseid, OpportunityId, ProductCode, ProductDescr, rate, uom, addWho, addTime, oprSeqFlag, currentVersion) VALUES
('OJV_CML', 'CBT01', '00000OPTYDUMMYPTABC', '1700000037', '', 37000.00000000, 'PALLET', 'EDI', NOW(), '2025', 100);


INSERT INTO BIL_CRM_DETAILS (organizationId, warehouseid, OpportunityId, ProductCode, ProductDescr, rate, uom, addWho, addTime, oprSeqFlag, currentVersion) VALUES
('OJV_CML', 'CBT01', '00000OPTYDUMMYPTABC', '1700000045', '', 45000.00000000, 'PALLET', 'EDI', NOW(), '2025', 100);


INSERT INTO BIL_CRM_DETAILS (organizationId, warehouseid, OpportunityId, ProductCode, ProductDescr, rate, uom, addWho, addTime, oprSeqFlag, currentVersion) VALUES
('OJV_CML', 'CBT01', '00000OPTYDUMMYPTABC', '1700000046', '', 46000.00000000, 'PALLET', 'EDI', NOW(), '2025', 100);

INSERT INTO BIL_CRM_DETAILS (organizationId, warehouseid, OpportunityId, ProductCode, ProductDescr, rate, uom, addWho, addTime, oprSeqFlag, currentVersion) VALUES
('OJV_CML', 'CBT01', '00000OPTYDUMMYPTABC', '1700000145', '', 145000.00000000, 'PALLET', 'EDI', NOW(), '2025', 100);

INSERT INTO BIL_CRM_DETAILS (organizationId, warehouseid, OpportunityId, ProductCode, ProductDescr, rate, uom, addWho, addTime, oprSeqFlag, currentVersion) VALUES
('OJV_CML', 'CBT01', '00000OPTYDUMMYPTABC', '1700000147', '', 147000.00000000, 'PALLET', 'EDI', NOW(), '2025', 100);

INSERT INTO BIL_CRM_DETAILS (organizationId, warehouseid, OpportunityId, ProductCode, ProductDescr, rate, uom, addWho, addTime, oprSeqFlag, currentVersion) VALUES
('OJV_CML', 'CBT01', '00000OPTYDUMMYPTABC', '1700000008', '', 8000.00000000, 'PALLET', 'EDI', NOW(), '2025', 100);



SELECT auto_sequence();    

SHOW VARIABLES LIKE 'plugin_dir';

SELECT @@plugin_dir;



DECLARE response TEXT;
SET response = http_post(url, data, headers);

IF response NOT LIKE 'CURL error:%' THEN
    -- Success: process response
ELSE
    -- Error: handle failure
END IF;


SET @response = http_post('https://example.com/webhook', '{"data": "test"}');
SELECT @response;

SELECT 
    *
FROM mysql.func
ORDER BY name;


SELECT http_post(
    'https://api.telegram.org/bot6869985592:AAEbEI8666PDNck9RswIoDzBqXHZvlJ6uRw/sendMessage',
    '{"chat_id": "-4233728891", "text": "testing!"}',
    'Content-Type: application/json'
);

SELECT http_post(

CREATE TABLE IF NOT EXISTS zcml_alert_config (
    id INT PRIMARY KEY DEFAULT 1,
    bot_token VARCHAR(255) NOT NULL,
    default_chat_id VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


-- Insert your Telegram bot configuration
INSERT INTO zcml_alert_config (bot_token, default_chat_id) 
VALUES ('6869985592:AAEbEI8666PDNck9RswIoDzBqXHZvlJ6uRw', '-4233728891');

SELECT  zcml_alert_message('tessting aja','-4233728891');



DELIMITER $$

CREATE FUNCTION zcml_alert_message(
    p_message TEXT,
    p_chat_id VARCHAR(50)
) RETURNS json
DETERMINISTIC
BEGIN
    DECLARE v_bot_token VARCHAR(255);
    DECLARE v_chat_id VARCHAR(50);
    DECLARE v_url VARCHAR(500);
    DECLARE v_data JSON;
    DECLARE v_response TEXT;
    DECLARE v_success BOOLEAN DEFAULT FALSE;
    
    -- Get bot configuration
    SELECT bot_token, 
           COALESCE(p_chat_id, default_chat_id)
    INTO v_bot_token, v_chat_id
    FROM zcml_alert_config
    WHERE id = 1;
    
    -- Build URL
    SET v_url = CONCAT('https://api.telegram.org/bot', v_bot_token, '/sendMessage');
    
    -- Build JSON data
    SET v_data = JSON_OBJECT(
        'chat_id', v_chat_id,
        'text', p_message,
        'parse_mode', 'HTML'
    );
    
    -- Send message
    SET v_response = http_post(v_url, CAST(v_data AS CHAR), 'Content-Type: application/json');
    
    -- Check if successful
    IF v_response NOT LIKE 'CURL error:%' THEN
        IF JSON_VALID(v_response) AND JSON_EXTRACT(v_response, '$.ok') = true THEN
            SET v_success = TRUE;
        END IF;
    END IF;
    
    -- Return result
    RETURN JSON_OBJECT(
        'success', v_success,
        'response', v_response
    );
END$$