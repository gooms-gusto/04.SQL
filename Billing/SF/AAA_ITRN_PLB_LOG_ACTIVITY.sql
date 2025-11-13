-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Create view `AAA_ITRN_PLB_LOG_ACTIVITY`
--
CREATE
DEFINER = 'sa'@'localhost'
VIEW AAA_ITRN_PLB_LOG_ACTIVITY
AS
SELECT
  `AAA_ITRN_LTL_DUMMY`.`Editwho` AS `User Proses`,
  `AAA_ITRN_LTL_DUMMY`.`Tanggal Transaksi` AS `Tanggal Transaksi`,
  `AAA_ITRN_LTL_DUMMY`.`Tipe Transaksi` AS `Tipe Transaksi`,
  `AAA_ITRN_LTL_DUMMY`.`No. PO` AS `No. PO`,
  `AAA_ITRN_LTL_DUMMY`.`NO. DO` AS `NO. DO`,
  `AAA_ITRN_LTL_DUMMY`.`Kode Barang` AS `Kode Barang`,
  ROUND(`AAA_ITRN_LTL_DUMMY`.`Jumlah`, 0) AS `Jumlah`,
  `AAA_ITRN_LTL_DUMMY`.`EDITDATE` AS `EDITDATE`,
  `AAA_ITRN_LTL_DUMMY`.`Edittime` AS `Edittime1`
FROM `cmlwms_archivedb`.`AAA_ITRN_LTL_DUMMY`
UNION ALL
SELECT
  `ZCBT001_A2502_PLBLTL_MUTASI`.`Editwho` AS `User Proses`,
  `ZCBT001_A2502_PLBLTL_MUTASI`.`Tanggal Transaksi` AS `Tanggal Transaksi`,
  `ZCBT001_A2502_PLBLTL_MUTASI`.`Tipe Transaksi` AS `Tipe Transaksi`,
  `ZCBT001_A2502_PLBLTL_MUTASI`.`No. PO` AS `No. PO`,
  `ZCBT001_A2502_PLBLTL_MUTASI`.`No. DO` AS `NO. DO`,
  `ZCBT001_A2502_PLBLTL_MUTASI`.`Kode Barang` AS `Kode Barang`,
  ROUND(`ZCBT001_A2502_PLBLTL_MUTASI`.`Jumlah`, 0) AS `Jumlah`,
  `ZCBT001_A2502_PLBLTL_MUTASI`.`EDITDATE` AS `EDITDATE`,
  `ZCBT001_A2502_PLBLTL_MUTASI`.`Edittime` AS `Edittime1`
FROM `wms_cml`.`ZCBT001_A2502_PLBLTL_MUTASI`;