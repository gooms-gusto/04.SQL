SELECT *
FROM Z_InventoryBalance zib WHERE zib.organizationId='OJV_CML' AND zib.customerId='PPG' 
AND MONTH(zib.StockDate)=5 AND YEAR(zib.StockDate)=2025
INTO OUTFILE '/var/lib/mysql-files/Z_INVENTORY.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';


LOAD DATA INFILE '/var/lib/mysql-files/Z_INVENTORYBALANCE1.csv'
INTO TABLE `Z_InventoryBalance`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'




SELECT (*)
FROM Z_InventoryBalance zib WHERE zib.organizationId='OJV_CML' AND zib.customerId='PPG' 
AND MONTH(zib.StockDate)=5 AND YEAR(zib.StockDate)=2025;

CREATE TABLE Z_InventoryBalance_TEST
SELECT * FROM Z_InventoryBalance WHERE organizationId='OJV_CML' AND  1=2 ;

TRUNCATE Z_InventoryBalance_TEST;



select concat('SELECT * INTO OUTFILE ''/var/lib/mysql-files/',table_name,
'.csv'' FIELDS TERMINATED BY '','' ENCLOSED BY ''"'' LINES TERMINATED BY ''\n'' FROM wms_prod.',table_name,';') as sql_command 
INTO OUTFILE '/var/lib/mysql-files/wms_prod_data_export_to_csv_sml.sql' FIELDS TERMINATED BY ',' ENCLOSED BY '' 
LINES TERMINATED BY '\n' FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms_prod' AND
 table_type not in ('VIEW') AND table_rows < 5000000 order by table_rows asc;
 


SET @sql_script = "SELECT * FROM Z_InventoryBalance zib WHERE zib.organizationId='OJV_CML' AND zib.customerId='PPG'
AND MONTH(zib.StockDate)=5 AND YEAR(zib.StockDate)=2025
INTO OUTFILE '/var/lib/mysql-files/Z_INVENTORY.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '\"'
LINES TERMINATED BY '\\n';";

SELECT CASE  TABLE_NAME WHEN 'Z_InventoryBalance' THEN CONCAT(
    'SELECT * FROM ',TABLE_NAME,' zib WHERE zib.organizationId=\'OJV_CML\' AND zib.customerId=\'PPG\' AND',
    ' MONTH(zib.StockDate)=5 AND YEAR(zib.StockDate)=2025 INTO OUTFILE \'/var/lib/mysql-files/',UPPER(TABLE_NAME),'.csv\' FIELDS ',
    'TERMINATED BY \',\' ENCLOSED BY \'"\' ',
    'LINES TERMINATED BY \'\\n\';'
)  ELSE
 CONCAT(
    'SELECT * FROM ',TABLE_NAME,' tb   INTO OUTFILE \'/var/lib/mysql-files/',UPPER(TABLE_NAME),'.csv\' FIELDS ',
    'TERMINATED BY \',\' ENCLOSED BY \'"\' ',
    'LINES TERMINATED BY \'\\n\';'
) END
AS SQLCOMMAND INTO OUTFILE '/var/lib/mysql-files/wms_prod_data_export_to_csv_sml.sql' FIELDS TERMINATED BY ',' ENCLOSED BY '' LINES TERMINATED BY '\n'
FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'wms_cml' AND table_type not in ('VIEW') 
ORDER BY TABLE_NAME DESC ;


/*
     

LOAD DATA INFILE '/var/lib/mysql-files/Z_INVENTORYBALANCE1.csv'
INTO TABLE `Z_InventoryBalance`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'

scp  -P 22 /var/lib/mysql-files/Z_INVENTORYBALANCE1.csv itwms@172.31.9.87:/var/lib/mysql-files/
mysql -u root -p WMS_FTEST -A



*/


