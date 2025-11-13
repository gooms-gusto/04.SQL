DROP TRIGGER TRG_DETAIL_LOADINGLIST_UP;

DELIMITER $$

CREATE TRIGGER TRG_DETAIL_LOADINGLIST_UP
BEFORE UPDATE ON DOC_LOADING_HEADER
FOR EACH ROW
BEGIN

  
    DECLARE  vCount INT;
      SET NEW.editTime = NOW();

    IF (NEW.ldlStatus = '99' OR NEW.ldlStatus = '60') THEN

        SELECT COUNT(1) INTO vCount 
        FROM ACT_ALLOCATION_DETAILS aad
        INNER JOIN DOC_ORDER_HEADER doh ON (aad.organizationId = doh.organizationId AND aad.warehouseId = doh.warehouseId
        AND aad.customerId = doh.customerId AND aad.waveNo = doh.waveNo)
        WHERE aad.organizationId=NEW.organizationId AND aad.warehouseId=NEW.warehouseId
        AND (aad.udf05 IS NULL OR LENGTH(aad.udf05)=0)
        AND aad.waveNo=NEW.waveNo AND aad.customerId='PPG';

        IF (vCount > 0) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot change status: there is UDF05 Blank/Null';
        END IF;

    END IF;
    


    
END$$



