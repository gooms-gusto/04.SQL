-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Create view `ZCBT01_RECEIPT_TRUCK2`
--
CREATE
DEFINER = 'sa'@'localhost'
VIEW ZCBT01_RECEIPT_TRUCK2
AS
SELECT
  `ZCBT01_RECEIPT_TRUCK`.`organizationId` AS `organizationId`,
  `ZCBT01_RECEIPT_TRUCK`.`warehouseId` AS `warehouseId`,
  `ZCBT01_RECEIPT_TRUCK`.`customerid` AS `customerid`,
  MIN(`ZCBT01_RECEIPT_TRUCK`.`arrivalNo`) AS `arrivalNo`,
  `ZCBT01_RECEIPT_TRUCK`.`appointmentno` AS `appointmentno`,
  `ZCBT01_RECEIPT_TRUCK`.`docNo` AS `docNo`,
  `ZCBT01_RECEIPT_TRUCK`.`orderNo` AS `orderNo`,
  MIN(`ZCBT01_RECEIPT_TRUCK`.`vehicleNo`) AS `vehicleNo`,
  MIN(`ZCBT01_RECEIPT_TRUCK`.`driver`) AS `driver`,
  MIN(`ZCBT01_RECEIPT_TRUCK`.`driverTel`) AS `driverTel`,
  MIN(`ZCBT01_RECEIPT_TRUCK`.`VehicleType`) AS `VehicleType`,
  MAX(`ZCBT01_RECEIPT_TRUCK`.`appointmentStartTime`) AS `appointmentStartTime`,
  MAX(`ZCBT01_RECEIPT_TRUCK`.`appointmentEndTime`) AS `appointmentEndTime`,
  MAX(`ZCBT01_RECEIPT_TRUCK`.`startTime`) AS `startTime`,
  MAX(`ZCBT01_RECEIPT_TRUCK`.`endTime`) AS `endTime`,
  MAX(`ZCBT01_RECEIPT_TRUCK`.`carrierId`) AS `carrierId`,
  MAX(`ZCBT01_RECEIPT_TRUCK`.`carrierName`) AS `carrierName`,
  `ZCBT01_RECEIPT_TRUCK`.`udf05` AS `udf05`
FROM `wms_cml`.`ZCBT01_RECEIPT_TRUCK`
GROUP BY `ZCBT01_RECEIPT_TRUCK`.`organizationId`,
         `ZCBT01_RECEIPT_TRUCK`.`warehouseId`,
         `ZCBT01_RECEIPT_TRUCK`.`customerid`,
         `ZCBT01_RECEIPT_TRUCK`.`appointmentno`,
         `ZCBT01_RECEIPT_TRUCK`.`docNo`,
         `ZCBT01_RECEIPT_TRUCK`.`orderNo`,
         `ZCBT01_RECEIPT_TRUCK`.`udf05`;