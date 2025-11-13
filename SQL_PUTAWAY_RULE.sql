SELECT
        *
FROM
        RUL_PUTAWAY_DETAILS  h1
WHERE
        1                     = 1
        AND h1.organizationId = 'OJV_CML'
        AND h1.warehouseId   IN('SMG-SO')
        AND h1.putawayId  = 'CERESSMG'
              
        