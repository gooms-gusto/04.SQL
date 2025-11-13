-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Create table `Z_InventoryBalance`
--
CREATE TABLE Z_InventoryBalance (
  id bigint(20) NOT NULL AUTO_INCREMENT,
  organizationId varchar(100) binary DEFAULT NULL,
  customerId varchar(100) binary DEFAULT NULL,
  warehouseId varchar(100) binary DEFAULT NULL,
  locationId varchar(60) binary DEFAULT NULL,
  traceId varchar(30) binary NOT NULL,
  muid varchar(30) binary NOT NULL DEFAULT '*',
  lotNum varchar(10) binary NOT NULL,
  sku varchar(255) binary NOT NULL DEFAULT '',
  qtyonHand int(11) DEFAULT NULL,
  packkey varchar(255) binary DEFAULT NULL,
  UOM varchar(255) binary DEFAULT NULL,
  qtyallocated int(11) DEFAULT NULL,
  qtyonHold int(11) DEFAULT NULL,
  qtyavailable int(11) DEFAULT NULL,
  qtyPicked int(11) DEFAULT NULL,
  SKUDesc varchar(550) binary DEFAULT NULL,
  StockDate date DEFAULT NULL,
  cube decimal(18, 8) DEFAULT NULL,
  totalCube decimal(24, 8) DEFAULT NULL,
  grossWeight decimal(18, 8) DEFAULT NULL,
  netWeight decimal(18, 8) DEFAULT NULL,
  freightClass varchar(255) binary DEFAULT NULL,
  locationCategory varchar(10) binary DEFAULT NULL,
  locGroup1 varchar(10) binary DEFAULT NULL,
  locGroup2 varchar(10) binary DEFAULT NULL,
  addWho varchar(255) binary NOT NULL DEFAULT '',
  addTime datetime DEFAULT NULL,
  editWho varchar(255) binary DEFAULT NULL,
  editTime datetime DEFAULT NULL,
  PRIMARY KEY (id)
)
ENGINE = INNODB,
AUTO_INCREMENT = 80897830,
AVG_ROW_LENGTH = 256,
CHARACTER SET utf8,
COLLATE utf8_bin;

--
-- Create index `I_Z_InventoryBalance_OWCTS` on table `Z_InventoryBalance`
--
ALTER TABLE Z_InventoryBalance
ADD INDEX I_Z_InventoryBalance_OWCTS (organizationId, warehouseId, customerId, traceId, StockDate);