CREATE TRIGGER TRG_CHECK_DUPLICATE_SO_REF01
BEFORE INSERT ON DOC_ORDER_HEADER
FOR EACH ROW FOLLOWS TRG_GENERATE_CARTONGROUP
BEGIN
    DECLARE duplicate int;
DECLARE actived int;
    SELECT COUNT(*) INTO duplicate FROM DOC_ORDER_HEADER  WHERE soReference1 = NEW.soReference1 AND customerId=NEW.customerId AND NEW.warehouseId=NEW.warehouseId;
   
   SELECT
       COUNT(1) INTO actived
    FROM
        BSM_CONFIG_RULES h1
      WHERE
        1                     = 1
        AND h1.organizationId = NEW.organizationId AND h1.configId='REF_CHK_SO' 
        AND h1.customerId=NEW.customerId AND h1.warehouseId= NEW.warehouseId AND h1.configValue='Y';
   IF duplicate > 0 AND actived <> 0 THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Duplicate insert key soReference1';
    END IF;
END