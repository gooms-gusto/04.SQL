--
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Create table `BAS_LOCATION`
--
CREATE TABLE BAS_LOCATION (
  organizationId varchar(20) binary NOT NULL,
  warehouseId varchar(20) binary NOT NULL,
  locationId varchar(60) binary NOT NULL DEFAULT '',
  putawayLogicalSequence varchar(20) binary NOT NULL,
  pickLogicalSequence varchar(20) binary NOT NULL,
  locationUsage varchar(2) binary NOT NULL,
  locationAttribute varchar(2) binary NOT NULL,
  locationCategory varchar(10) binary NOT NULL,
  locationHandling varchar(2) binary NOT NULL,
  environment varchar(20) binary DEFAULT NULL,
  demand varchar(2) binary NOT NULL,
  zoneGroup varchar(20) binary NOT NULL,
  validationCode varchar(20) binary DEFAULT NULL,
  locGroup1 varchar(10) binary DEFAULT NULL,
  locGroup2 varchar(10) binary DEFAULT NULL,
  workingArea varchar(20) binary DEFAULT NULL,
  aisleNo varchar(10) binary DEFAULT NULL,
  cubicCapacity decimal(18, 8) DEFAULT NULL,
  weightCapacity decimal(18, 8) DEFAULT NULL,
  csCount decimal(18, 8) DEFAULT NULL,
  eaCount int DEFAULT NULL,
  plCount int DEFAULT NULL,
  skuCount int DEFAULT NULL,
  length decimal(18, 8) DEFAULT NULL,
  width decimal(18, 8) DEFAULT NULL,
  height decimal(18, 8) DEFAULT NULL,
  xCoord int DEFAULT NULL,
  yCoord int DEFAULT NULL,
  zCoord int DEFAULT NULL,
  locLevel char(1) binary DEFAULT NULL,
  xDistance int DEFAULT NULL,
  yDistance int DEFAULT NULL,
  mix_flag char(1) binary NOT NULL DEFAULT 'N',
  mix_lotFlag char(1) binary NOT NULL DEFAULT 'N',
  loseId_flag char(1) binary NOT NULL DEFAULT 'N',
  noteText mediumtext binary DEFAULT NULL,
  udf01 varchar(500) binary DEFAULT NULL,
  udf02 varchar(500) binary DEFAULT NULL,
  udf03 varchar(500) binary DEFAULT NULL,
  udf04 varchar(500) binary DEFAULT NULL,
  udf05 varchar(500) binary DEFAULT NULL,
  currentVersion int NOT NULL DEFAULT 100,
  oprSeqFlag varchar(65) binary NOT NULL DEFAULT '2016',
  addWho varchar(40) binary DEFAULT NULL,
  addTime timestamp NULL DEFAULT NULL,
  editWho varchar(40) binary DEFAULT NULL,
  editTime timestamp NULL DEFAULT NULL,
  terminalNo1 varchar(50) binary DEFAULT NULL,
  terminalNo2 varchar(50) binary DEFAULT NULL,
  ROUND int DEFAULT NULL,
  usedTime timestamp NULL DEFAULT NULL,
  zoneId varchar(20) binary NOT NULL,
  locationRow int DEFAULT NULL,
  locationColumn int DEFAULT NULL,
  loseMuid_Flag char(1) binary NOT NULL DEFAULT 'N',
  PRIMARY KEY (organizationId, warehouseId, locationId)
)
ENGINE = INNODB,
AVG_ROW_LENGTH = 319,
CHARACTER SET utf8mb3,
COLLATE utf8mb3_bin,
ROW_FORMAT = DYNAMIC;

--
-- Create index `auto_shard_key_organizationId` on table `BAS_LOCATION`
--
ALTER TABLE BAS_LOCATION
ADD INDEX auto_shard_key_organizationId (organizationId);

--
-- Create index `BAS_LOCATION_locationId_IDX` on table `BAS_LOCATION`
--
ALTER TABLE BAS_LOCATION
ADD INDEX BAS_LOCATION_locationId_IDX (locationId, putawayLogicalSequence, organizationId, warehouseId, locationAttribute, zoneId);

--
-- Create index `I_BAS_LOCATION_L` on table `BAS_LOCATION`
--
ALTER TABLE BAS_LOCATION
ADD INDEX I_BAS_LOCATION_L (organizationId, warehouseId, locationUsage);

--
-- Create index `I_BAS_LOCATION_L1` on table `BAS_LOCATION`
--
ALTER TABLE BAS_LOCATION
ADD INDEX I_BAS_LOCATION_L1 (organizationId, warehouseId, locGroup1);

--
-- Create index `I_BAS_LOCATION_L2` on table `BAS_LOCATION`
--
ALTER TABLE BAS_LOCATION
ADD INDEX I_BAS_LOCATION_L2 (organizationId, warehouseId, locGroup2);

--
-- Create index `I_BAS_LOCATION_ZONE` on table `BAS_LOCATION`
--
ALTER TABLE BAS_LOCATION
ADD INDEX I_BAS_LOCATION_ZONE (organizationId, warehouseId, zoneId);

--
-- Create index `idx_bas_location_usg` on table `BAS_LOCATION`
--
ALTER TABLE BAS_LOCATION
ADD INDEX idx_bas_location_usg (locationUsage);

--
-- Create index `PK_BAS_LOCATION` on table `BAS_LOCATION`
--
ALTER TABLE BAS_LOCATION
ADD INDEX PK_BAS_LOCATION (locationId);

DELIMITER $$

--
-- Create trigger `TRG_GENERATE_VALIDATEION_CODE`
--
CREATE
DEFINER = 'root'@'%'
TRIGGER TRG_GENERATE_VALIDATEION_CODE
BEFORE INSERT
ON BAS_LOCATION
FOR EACH ROW
BEGIN
  DECLARE sValidationCode varchar(10);
  DECLARE nCount int;

  SET sValidationCode := '*';

  REPEAT
    SET sValidationCode := FLOOR(RAND() * (999999) + 1);
    SET nCount := 0;
    SELECT
      COUNT(validationCode)
    FROM BAS_LOCATION
    WHERE validationCode = sValidationCode
    LIMIT 1 INTO nCount;
    IF nCount > 0 THEN
      SET sValidationCode := '*';
    END IF;

  UNTIL sValidationCode <> '*'
  END REPEAT;

  SET new.validationCode = sValidationCode;
END
$$

DELIMITER ;