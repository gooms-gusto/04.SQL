SELECT DISTINCT
    bcm.organizationId,
    bcm.warehouseId,
    bcm.customerId,
    bcm.tariffMasterId,
    DAY(STR_TO_DATE(CONCAT(YEAR(NOW()), '-', MONTH(NOW()), '-', bth.udf02), '%Y-%m-%d')) AS billingDate,
    IFNULL(bth.tariffId, '*') AS tariffId,
    btd.tariffLineNo,
    btd.chargeCategory,
    btd.chargeType,
    btd.descrC,
    btd.ratebase,
    btd.incomeTaxRate,
    IF(btd.UDF03 = '', 0, btd.UDF03) AS fixAmount,
    btd.udf03,
    btd.minAmount,
    btd.UDF01 AS MaterialNo,
    btd.udf02 AS itemChargeCategory,
    
    -- Billing date handling (from sql2 logic)
    CASE 
        WHEN bth.udf02 = ' ' 
        THEN DAY(bth.billingDate) 
        ELSE bth.udf02 
    END AS udf02_processed,
    
    btd.UDF05,
    btd.UDF06 AS divisionCode,
    btd.UDF07,
    btd.UDF08,
    bth.contractNo,
    bc.CustomerType

FROM BAS_CUSTOMER_MULTIWAREHOUSE bcm
    
    -- Customer master data
    INNER JOIN BAS_CUSTOMER bc
        ON bc.customerId = bcm.customerId
        AND bc.organizationId = bcm.organizationId
        AND bc.CustomerType = 'OW'
    
    -- Tariff header (LEFT JOIN to accommodate both query patterns)
    LEFT JOIN BIL_TARIFF_HEADER bth
        ON bth.organizationId = bcm.organizationId
        AND bth.tariffMasterId = bcm.tariffMasterId
    
    -- Tariff details
    LEFT JOIN BIL_TARIFF_DETAILS btd
        ON btd.organizationId = bth.organizationId
        AND btd.tariffId = bth.tariffId

WHERE 
    bcm.organizationId = 'OJV_CML'
     
    -- Date range filtering
    AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
    AND (
        bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
        OR 
        bth.effectiveTo >= DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '%Y-%m-%d')
    )
    
    -- Charge category
    AND btd.chargeCategory = 'FX'

ORDER BY 
    bcm.organizationId, 
    bcm.customerId, 
    btd.chargeCategory, 
    btd.chargeType,
    btd.tariffLineNo;