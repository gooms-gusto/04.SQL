WITH RECURSIVE AllDates AS (
    SELECT get_billing_period_start(26) AS StockDate
    UNION ALL
    SELECT DATE_ADD(StockDate, INTERVAL 1 DAY)
    FROM AllDates
    WHERE StockDate < CURDATE()
),
AllChargeTypes AS (
    SELECT DISTINCT chargeType
    FROM Z_BIL_AKUM_DAYS_STORAGE
    WHERE organizationId = 'OJV_CML'
)
SELECT
    d.StockDate,
    c.chargeType,
    COUNT(zbads.StockDate) AS line_counts,
    -- Add the CASE statement here
    CASE
        WHEN COUNT(zbads.StockDate) < 40 THEN 'NEED ATTENTION'
        ELSE 'LOOKS NORMAL'
    END AS status
FROM
    AllDates d
CROSS JOIN
    AllChargeTypes c
LEFT JOIN
    Z_BIL_AKUM_DAYS_STORAGE zbads ON d.StockDate = zbads.StockDate
                                 AND c.chargeType = zbads.chargeType
                                 AND zbads.organizationId = 'OJV_CML'
GROUP BY
    d.StockDate, c.chargeType
ORDER BY
    d.StockDate, c.chargeType;