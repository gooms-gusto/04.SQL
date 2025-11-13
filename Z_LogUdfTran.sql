-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE WMS_FTEST;

--
-- Create table `Z_LogUdfTran`
--
CREATE TABLE Z_LogUdfTran (
  idLogTrx int(11) NOT NULL AUTO_INCREMENT,
  docType varchar(255) binary DEFAULT NULL,
  docNo varchar(255) binary DEFAULT NULL,
  userId varchar(255) binary DEFAULT NULL,
  lottable01 varchar(255) binary DEFAULT NULL,
  lottable02 varchar(255) binary DEFAULT NULL,
  lottable03 varchar(255) binary DEFAULT NULL,
  lottable04 varchar(255) binary DEFAULT NULL,
  addDate datetime DEFAULT NULL,
  addWho varchar(255) binary DEFAULT NULL,
  editDate datetime DEFAULT NULL,
  editWho varchar(255) binary DEFAULT NULL,
  PRIMARY KEY (idLogTrx)
)
ENGINE = INNODB,
AUTO_INCREMENT = 11,
AVG_ROW_LENGTH = 1820,
CHARACTER SET utf8,
COLLATE utf8_bin;