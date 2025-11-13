SELECT * FROM bt_estimasi_storage bes WHERE bes.customerId='API';

DELETE FROM bt_estimasi_storage bes WHERE   DATE_FORMAT(bes.addDate,'%Y-%m-%d')= DATE_FORMAT(NOW(),'%Y-%m-%d');

SELECT * FROM bt_estimasi_storage bes WHERE DATE_FORMAT(bes.addDate,'%Y-%m-%d')= DATE_FORMAT(DATE_ADD(NOW(), INTERVAL - 1 DAY) ,'%Y-%m-%d');