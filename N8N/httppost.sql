SELECT http_post(
    'http://omahkudewe.asia:8765/webhook/8cb1febe-51dc-4398-9110-1cfc403545f1',    
(SELECT JSON_OBJECT(
    'organization', organizationId,
    'data', JSON_ARRAYAGG(
        JSON_OBJECT(
            'customerId', customerId,
            'sku', sku
        )
    )
) AS json_result
FROM BAS_SKU
GROUP BY organizationId LIMIT 10));