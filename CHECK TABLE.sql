SELECT table_name
FROM information_schema.tables
WHERE table_schema = DATABASE();         ;



SELECT * FROM T_CERTIFICATE_DETAILS


SELECT table_name
FROM information_schema.tables
WHERE table_schema = DATABASE()  -- Replace with your database name if needed
  AND table_type = 'BASE TABLE'
  AND update_time >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);