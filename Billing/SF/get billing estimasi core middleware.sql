SELECT * FROM bt_estimasi_storage bes WHERE DATE(bes.addDate)=DATE(NOW()) ORDER BY bes.addDate DESC;

DELETE FROM bt_estimasi_storage WHERE DATE(addDate)=DATE(NOW()); 