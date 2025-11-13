USE reporting_wms;

CREATE OR REPLACE
DEFINER = 'akbar'@'%'
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
  `bil`.`udf01` AS `sapmaterialid`,
  `bil`.`udf05` AS `udf05`,
  SUM((`bil`.`qty` / `bil`.`chargePerUnits`)) AS `qty`,
  `bil`.`uom` AS `uomdoc`,
  `bil`.`rateBase` AS `ratebase`,
  `bil`.`chargeRate` AS `chargerate`,
  SUM(`bil`.`billingAmount`) AS `billingAmount`,
  ((SUM(`bil`.`billingAmount`) / SUM((`bil`.`qty` / `bil`.`chargePerUnits`))) = `bil`.`chargeRate`) AS `directRate`,
  (`bil`.`qty` / `pakIP`.`qty`) AS `qtyIp`,
  (`bil`.`qty` / `pakCS`.`qty`) AS `qtyCs`,
  (`bil`.`qty` / `pakPL`.`qty`) AS `qtyPL`
FROM (((((`BIL_SUMMARY` `bil`
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
         `bil`.`udf01`,
         `bil`.`udf05`,
         `bil`.`uom`,
         `qtyIp`,
         `qtyCs`,
         `qtyPL`,
         `bil`.`sku`;