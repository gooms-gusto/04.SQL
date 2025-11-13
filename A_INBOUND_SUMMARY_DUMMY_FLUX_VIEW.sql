-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Create view `A_INBOUND_SUMMARY_DUMMY_FLUX`
--
CREATE
DEFINER = 'sa'@'localhost'
VIEW A_INBOUND_SUMMARY_DUMMY_FLUX
AS
SELECT
  `A_INBOUND_SUMMARY_DUMMY`.`Jenis Dokumen PLB` AS `Jenis Dokumen PLB`,
  `A_INBOUND_SUMMARY_DUMMY`.`No. PO` AS `No. PO`,
  `A_INBOUND_SUMMARY_DUMMY`.`No. Dokumen Pabean` AS `No. Dokumen Pabean`,
  `A_INBOUND_SUMMARY_DUMMY`.`Tanggal Nopen` AS `Tanggal Nopen`,
  `A_INBOUND_SUMMARY_DUMMY`.`No. Bukti Penerimaan Barang` AS `No. Bukti Penerimaan Barang`,
  `A_INBOUND_SUMMARY_DUMMY`.`Tanggal Penerimaan Barang` AS `Tanggal Penerimaan Barang`,
  `A_INBOUND_SUMMARY_DUMMY`.`Pemasok` AS `Pemasok`,
  `A_INBOUND_SUMMARY_DUMMY`.`Kode Barang` AS `Kode Barang`,
  `A_INBOUND_SUMMARY_DUMMY`.`Nama Barang` AS `Nama Barang`,
  `A_INBOUND_SUMMARY_DUMMY`.`Jumlah` AS `Jumlah`,
  `A_INBOUND_SUMMARY_DUMMY`.`Satuan` AS `Satuan`,
  `A_INBOUND_SUMMARY_DUMMY`.`Pemilik` AS `Pemilik`,
  `A_INBOUND_SUMMARY_DUMMY`.`STORERKEY` AS `STORERKEY`,
  `A_INBOUND_SUMMARY_DUMMY`.`STATUS` AS `STATUS`,
  `A_INBOUND_SUMMARY_DUMMY`.`datereceived` AS `datereceived`
FROM `cmlwms_archivedb`.`A_INBOUND_SUMMARY_DUMMY`
UNION ALL
SELECT
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Jenis Dokumen PLB` AS `Jenis Dokumen PLB`,
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`No. PO` AS `No. PO`,
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`No. Dokumen Pabean` AS `No. Dokumen Pabean`,
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Tanggal Nopen` AS `Tanggal Nopen`,
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`No. Bukti Penerimaan Barang` AS `No. Bukti Penerimaan Barang`,
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Tanggal Penerimaan Barang` AS `Tanggal Penerimaan Barang`,
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Pemasok` AS `Pemasok`,
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Kode Barang` AS `Kode Barang`,
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Nama Barang` AS `Nama Barang`,
  SUM(ROUND(`ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Jumlah`, 0)) AS `Jumlah`,
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Satuan` AS `Satuan`,
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Pemilik` AS `Pemilik`,
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`STORERKEY` AS `STORERKEY`,
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`STATUS` AS `STATUS`,
  MAX(`ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`datereceived`) AS `datereceived`
FROM `wms_cml`.`ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`
GROUP BY `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Jenis Dokumen PLB`,
         `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`No. PO`,
         `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`No. Dokumen Pabean`,
         `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Tanggal Nopen`,
         `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`No. Bukti Penerimaan Barang`,
         `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Tanggal Penerimaan Barang`,
         `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Pemasok`,
         `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Kode Barang`,
         `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Nama Barang`,
         `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Satuan`,
         `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Pemilik`,
         `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`STORERKEY`,
         `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`STATUS`;