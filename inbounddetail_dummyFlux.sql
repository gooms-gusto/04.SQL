-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Create view `a_inbounddetail_dummyFlux`
--
CREATE
DEFINER = 'sa'@'localhost'
VIEW a_inbounddetail_dummyFlux
AS
SELECT
  `a_inbounddetail_dummy`.`Jenis Dokumen PLB` AS `Jenis Dokumen PLB`,
  `a_inbounddetail_dummy`.`No. PO` AS `No. PO`,
  `a_inbounddetail_dummy`.`No. Dokumen Pabean` AS `No. Dokumen Pabean`,
  `a_inbounddetail_dummy`.`Tanggal Nopen` AS `Tanggal Nopen`,
  `a_inbounddetail_dummy`.`No. Bukti Penerimaan Barang` AS `No. Bukti Penerimaan Barang`,
  `a_inbounddetail_dummy`.`Tanggal Penerimaan Barang` AS `Tanggal Penerimaan Barang`,
  `a_inbounddetail_dummy`.`Pemasok` AS `Pemasok`,
  `a_inbounddetail_dummy`.`Kode Barang` AS `Kode Barang`,
  `a_inbounddetail_dummy`.`Nama Barang` AS `Nama Barang`,
  ROUND(`a_inbounddetail_dummy`.`Jumlah`, 0) AS `Jumlah`,
  `a_inbounddetail_dummy`.`Satuan` AS `Satuan`,
  `a_inbounddetail_dummy`.`Pemilik` AS `Pemilik`,
  `a_inbounddetail_dummy`.`STORERKEY` AS `STORERKEY`,
  `a_inbounddetail_dummy`.`STATUS` AS `STATUS`,
  `a_inbounddetail_dummy`.`datereceived` AS `datereceived`
FROM `cmlwms_archivedb`.`a_inbounddetail_dummy`
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
  ROUND(`ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Jumlah`, 0) AS `Jumlah`,
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Satuan` AS `Satuan`,
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`Pemilik` AS `Pemilik`,
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`STORERKEY` AS `STORERKEY`,
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`STATUS` AS `STATUS`,
  `ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`.`datereceived` AS `datereceived`
FROM `wms_cml`.`ZCBT01_A2002_PLBLTL_INVRPT_RECEIPT`;