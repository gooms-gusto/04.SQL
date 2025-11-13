CREATE FUNCTION smtp_send RETURNS STRING SONAME 'smtp_udf.so';

CREATE FUNCTION create_excel RETURNS STRING SONAME 'excel_udf_v2.so';
CREATE FUNCTION write_excel_data RETURNS INTEGER SONAME 'excel_udf_v2.so';
CREATE FUNCTION finalize_excel RETURNS STRING SONAME 'excel_udf_v2.so';
CREATE FUNCTION add_excel_sheet RETURNS STRING SONAME 'excel_udf_v2.so';
CREATE FUNCTION merge_excel_cells RETURNS INTEGER SONAME 'excel_udf_v2.so';

DROP FUNCTION IF EXISTS auto_seq;
DROP FUNCTION IF EXISTS seq_reset;
DROP FUNCTION IF EXISTS seq_current;

CREATE FUNCTION auto_seq RETURNS INTEGER SONAME 'auto_sequence.so';
CREATE FUNCTION seq_reset RETURNS INTEGER SONAME 'auto_sequence.so';
CREATE FUNCTION seq_current RETURNS INTEGER SONAME 'auto_sequence.so';

SHOW CREATE FUNCTION auto_seq;
SHOW CREATE FUNCTION seq_reset;
SHOW CREATE FUNCTION seq_current;
SELECT smtp_send(
    'smtp://smtp.office365.com:587',
    'System.InformationLinc@lincgrp.com',
    '5y51nf08:36!@#$',
    'System.InformationLinc@lincgrp.com',
    'm.ardiansah@lincgrp.com',
    'Test Subject',
    '<html><body><h1>kirim testing</h1></body></html>',
    '/var/lib/mysql-files/datayoutube.xlsx'
);


SELECT create_excel('/var/lib/mysql-files/datayoutube.xlsx', '#4472C4', 'performa_invoice');
SELECT write_excel_data(1, 0, '1234567.89', 'decimal', '#,##0.00', '#E7E6E6', '#000000');
SELECT write_excel_data(2,0,'HEADER','string',NULL,'#FF0000','#FFFFFF') AS header;
 SELECT write_excel_data(3,0,'Data1','string',NULL,'#FFFF00',NULL) AS d1;

 SELECT merge_excel_cells(4,0,5,3,'DESCRIPTION',NULL,'#0a0a0a','#f7f7f7') AS merge;
  SELECT merge_excel_cells(4,4,5,6,'CHARGE VALUE',NULL,'#0a0a0a','#f7f7f7') AS merge;
  SELECT  finalize_excel() AS done;


sql-- Numbering sederhana mulai dari 100
SELECT auto_seq(100) AS no, nama FROM tabel;

-- Invoice number dengan format
SELECT CONCAT('INV-', LPAD(auto_seq(1), 6, '0')) AS invoice_no;

-- Ranking dengan increment 10
SELECT auto_seq(1000, 10) AS kode, produk FROM inventory;

SELECT auto_seq();