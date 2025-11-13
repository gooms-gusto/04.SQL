       SELECT
    ROUTINE_NAME,
    LAST_ALTERED
FROM
    information_schema.routines
WHERE
    ROUTINE_SCHEMA = DATABASE() -- To check within the current database
    AND ROUTINE_TYPE = 'PROCEDURE' ORDER BY   LAST_ALTERED DESC;