USE reporting_wms;

CREATE OR REPLACE
VIEW ZV_BILLING_DATA
AS
SELECT
  `bil`.`billingFromDate` AS `billingfromdate`,
  (CASE WHEN (LENGTH(TRIM(`bil`.`arNo`)) < 1) THEN NULL ELSE `bil`.`arNo` END) AS `arNo`,
  `bil`.`tariffId` AS `tariffId`,
  `cus`.`udf02` AS `sapcustomerid`,
  `bil`.`customerId` AS `customerid`,
  `bil`.`warehouseId` AS `warehouseid`,
  `bil`.`chargeCategory` AS `chargecategory`,
  `bil`.`chargeType` AS `chargetype`,
  `bil`.`descr` AS `descr`,
  `bil`.`sku` AS `sku`,
  `bil`.`docNo` AS `docno`,
  (CASE WHEN ((`bil`.`udf01` = '1700000045') AND
      (`bil`.`docType` = 'OV')) THEN '8888888888' WHEN ((`bil`.`udf01` = '1700000046') AND
      (`bil`.`docType` = 'OT')) THEN '9999999999' ELSE `bil`.`udf01` END) AS `sapmaterialid`,
  (CASE WHEN (LENGTH(`tariff`.`OpportunityID`) < 1) THEN NULL ELSE `tariff`.`OpportunityID` END) AS `opportunityid`,
  IFNULL(`transmit`.`status`, '00') AS `transmit_status`,
  `transmit`.`udf05` AS `transmit_date`,
  `bil`.`udf05` AS `udf05`,
  (SUM(`bil`.`billingAmount`) / `bil`.`chargeRate`) AS `qty`,
  `bil`.`uom` AS `uomdoc`,
  `sf`.`uom` AS `ratebase`,
  `bil`.`chargeRate` AS `chargerate`,
  SUM(`bil`.`billingAmount`) AS `billingAmount`,
  1 AS `directRate`,
  (CASE WHEN (`bil`.`udf01` NOT IN ('8888888888', '9999999999', '1700000045', '1700000046')) THEN (SUM(`bil`.`billingAmount`) / `bil`.`chargeRate`) ELSE (SUM(`bil`.`qty`) / MAX(`pakIP`.`qty`)) END) AS `qtyIp`,
  (CASE WHEN (`bil`.`udf01` NOT IN ('8888888888', '9999999999', '1700000045', '1700000046')) THEN (SUM(`bil`.`billingAmount`) / `bil`.`chargeRate`) ELSE (SUM(`bil`.`qty`) / MAX(`pakCS`.`qty`)) END) AS `qtyCs`,
  (CASE WHEN (`bil`.`udf01` NOT IN ('8888888888', '9999999999', '1700000045', '1700000046')) THEN (SUM(`bil`.`billingAmount`) / `bil`.`chargeRate`) ELSE (SUM(`bil`.`qty`) / MAX(`pakPL`.`qty`)) END) AS `qtyPL`
FROM ((((((((`BIL_SUMMARY` `bil`
  JOIN `BAS_CUSTOMER` `cus`
    ON (((`cus`.`customerId` = `bil`.`customerId`)
    AND (`cus`.`organizationId` = `bil`.`organizationId`)
    AND (`cus`.`customerType` = 'OW'))))
  LEFT JOIN `BAS_SKU` `sku`
    ON (((`sku`.`organizationId` = `bil`.`organizationId`)
    AND (`sku`.`customerId` = `bil`.`customerId`)
    AND (`sku`.`sku` = `bil`.`sku`))))
  LEFT JOIN `BAS_PACKAGE_DETAILS` `pakIP`
    ON (((`pakIP`.`organizationId` = `sku`.`organizationId`)
    AND (`pakIP`.`packId` = `sku`.`packId`)
    AND (`pakIP`.`packUom` = 'IP')
    AND (`pakIP`.`customerId` = `bil`.`customerId`))))
  LEFT JOIN `BAS_PACKAGE_DETAILS` `pakCS`
    ON (((`pakCS`.`organizationId` = `sku`.`organizationId`)
    AND (`pakCS`.`packId` = `sku`.`packId`)
    AND (`pakCS`.`packUom` = 'CS')
    AND (`pakCS`.`customerId` = `bil`.`customerId`))))
  LEFT JOIN `BAS_PACKAGE_DETAILS` `pakPL`
    ON (((`pakPL`.`organizationId` = `sku`.`organizationId`)
    AND (`pakPL`.`packId` = `sku`.`packId`)
    AND (`pakPL`.`packUom` = 'PL')
    AND (`pakPL`.`customerId` = `bil`.`customerId`))))
  LEFT JOIN `BIL_TARIFF_HEADER` `tariff`
    ON (((`tariff`.`organizationId` = `bil`.`organizationId`)
    AND (`tariff`.`tariffId` = `bil`.`tariffId`))))
  LEFT JOIN `BIL_CRM_DETAILS` `sf`
    ON (((`tariff`.`OpportunityID` = `sf`.`OpportunityId`)
    AND (`bil`.`udf01` = `sf`.`ProductCode`)
    AND (`bil`.`chargeRate` = `sf`.`rate`))))
  LEFT JOIN `BIL_BILLING_HEADER` `transmit`
    ON (((`transmit`.`organizationId` = `bil`.`organizationId`)
    AND (`transmit`.`warehouseId` = `bil`.`warehouseId`)
    AND (`transmit`.`customerId` = `bil`.`customerId`)
    AND (`transmit`.`billingNo` = `bil`.`arNo`))))
    WHERE (CAST(`bil`.`billingFromDate` AS date) > (NOW() + INTERVAL -(3) MONTH))
GROUP BY `bil`.`billingFromDate`,
         `bil`.`tariffId`,
         `bil`.`arNo`,
         `sapcustomerid`,
         `bil`.`customerId`,
         `bil`.`warehouseId`,
         `bil`.`chargeCategory`,
         `bil`.`chargeType`,
         `bil`.`descr`,
         `bil`.`docNo`,
         `bil`.`rateBase`,
         `bil`.`chargeRate`,
         `bil`.`billingAmount`,
         `bil`.`udf01`,
         `bil`.`udf05`,
         `bil`.`uom`,
         `bil`.`addWho`,
         `bil`.`sku`,
         `tariff`.`OpportunityID`,
         `transmit_status`,
         `bil`.`docType`,
         `sf`.`uom`,
         `bil`.`traceId`,
         `transmit_date`;