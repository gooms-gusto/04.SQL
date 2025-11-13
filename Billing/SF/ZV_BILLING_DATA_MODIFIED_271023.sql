USE reporting_wms_dev;

CREATE OR REPLACE
DEFINER = 'akbar'@'%'
VIEW ZV_BILLING_DATA
AS

/*

remarked 27.10.23, concern to billing amount / rate
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
  (CASE WHEN (LENGTH(`tariff`.`OpportunityID`) < 1) THEN NULL ELSE `tariff`.`OpportunityID` END) AS `opportunityid`,
  IFNULL(`transmit`.`status`, '00') AS `transmit_status`,
  `transmit`.`udf05` AS `transmit_date`,
  `bil`.`udf05` AS `udf05`,
  (CASE WHEN ((`bil`.`rateBase` = 'DO') AND
      (`bil`.`addWho` <> 'EDI')) THEN COUNT(`bil`.`docNo`) WHEN ((`bil`.`rateBase` = 'CTN') AND
      (`bil`.`addWho` <> 'EDI')) THEN SUM(CEILING((`bil`.`qty` / `pakCS`.`qty`))) WHEN ((`bil`.`rateBase` = 'CUBIC') AND
      (`bil`.`addWho` <> 'EDI')) THEN SUM(`bil`.`qty`) WHEN ((`bil`.`rateBase` = 'ORDERLINE') AND
      (`bil`.`addWho` <> 'EDI')) THEN COUNT(`bil`.`docLineNo`) WHEN ((`bil`.`rateBase` = 'ORDER NO') AND
      (`bil`.`addWho` <> 'EDI')) THEN COUNT(`bil`.`docNo`) WHEN ((`bil`.`rateBase` = 'WEIGHT') AND
      (`bil`.`addWho` <> 'EDI')) THEN SUM((`bil`.`weight` * `bil`.`qty`)) WHEN ((`bil`.`rateBase` = 'Pieces') AND
      (`bil`.`addWho` <> 'EDI')) THEN SUM(`bil`.`qty`) WHEN ((`bil`.`rateBase` = 'QUANTITY') AND
      (`bil`.`addWho` <> 'EDI')) THEN SUM(`bil`.`qty`) WHEN ((`bil`.`rateBase` = 'UOMCASE') AND
      (`bil`.`addWho` <> 'EDI')) THEN SUM(CEILING((`bil`.`qty` / `pakCS`.`qty`))) WHEN ((`bil`.`rateBase` = 'UOMPALLET') AND
      (`bil`.`addWho` <> 'EDI')) THEN SUM(CEILING((`bil`.`qty` / `pakPL`.`qty`))) WHEN ((`bil`.`rateBase` = 'UOMQUANTITY') AND
      (`bil`.`addWho` <> 'EDI')) THEN SUM(CEILING((`bil`.`qty` / `pakPL`.`qty`))) WHEN ((`bil`.`rateBase` = 'MONTH') AND
      (`bil`.`addWho` <> 'EDI') AND
      (`bil`.`chargeCategory` = 'FX')) THEN 1 ELSE SUM(CEILING((`bil`.`qty` / `bil`.`chargePerUnits`))) END) AS `qty`,
  `bil`.`uom` AS `uomdoc`,
  `bil`.`rateBase` AS `ratebase`,
  `bil`.`chargeRate` AS `chargerate`,
  SUM(`bil`.`billingAmount`) AS `billingAmount`,
  ((SUM(`bil`.`billingAmount`) / SUM((`bil`.`qty` / `bil`.`chargePerUnits`))) = `bil`.`chargeRate`) AS `directRate`,
  (`bil`.`qty` / `pakIP`.`qty`) AS `qtyIp`,
  (`bil`.`qty` / `pakCS`.`qty`) AS `qtyCs`,
  (`bil`.`qty` / `pakPL`.`qty`) AS `qtyPL`
FROM (((((((`BIL_SUMMARY` `bil`
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
    AND (`tariff`.`warehouseId` = `bil`.`warehouseId`)
    AND (`tariff`.`tariffId` = `bil`.`tariffId`))))
  LEFT JOIN `BIL_BILLING_HEADER` `transmit`
    ON (((`transmit`.`organizationId` = `bil`.`organizationId`)
    AND (`transmit`.`warehouseId` = `bil`.`warehouseId`)
    AND (`transmit`.`customerId` = `bil`.`customerId`)
    AND (`transmit`.`billingNo` = `bil`.`arNo`))))
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
         `bil`.`addWho`,
         `bil`.`qty`,
         `qtyIp`,
         `qtyCs`,
         `qtyPL`,
         `bil`.`sku`,
         `tariff`.`OpportunityID`,
         `transmit_status`,
         `transmit_date`;

*/
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
  (CASE WHEN (LENGTH(`tariff`.`OpportunityID`) < 1) THEN NULL ELSE `tariff`.`OpportunityID` END) AS `opportunityid`,
  IFNULL(`transmit`.`status`, '00') AS `transmit_status`,
  `transmit`.`udf05` AS `transmit_date`,
  `bil`.`udf05` AS `udf05`,
  (`bil`.`billingAmount` / `bil`.`chargeRate`) AS `qty`,
  `bil`.`uom` AS `uomdoc`,
  `bil`.`rateBase` AS `ratebase`,
  `bil`.`chargeRate` AS `chargerate`,
  `bil`.`billingAmount` AS `billingAmount`,
  1 AS `directRate`,
  (`bil`.`qty` / `pakIP`.`qty`) AS `qtyIp`,
  (`bil`.`qty` / `pakCS`.`qty`) AS `qtyCs`,
  (`bil`.`qty` / `pakPL`.`qty`) AS `qtyPL`
FROM (((((((`BIL_SUMMARY` `bil`
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
    AND (`tariff`.`warehouseId` = `bil`.`warehouseId`)
    AND (`tariff`.`tariffId` = `bil`.`tariffId`))))
  LEFT JOIN `BIL_BILLING_HEADER` `transmit`
    ON (((`transmit`.`organizationId` = `bil`.`organizationId`)
    AND (`transmit`.`warehouseId` = `bil`.`warehouseId`)
    AND (`transmit`.`customerId` = `bil`.`customerId`)
    AND (`transmit`.`billingNo` = `bil`.`arNo`))))
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
         `bil`.`qty`,
         `qtyIp`,
         `qtyCs`,
         `qtyPL`,
         `bil`.`sku`,
         `tariff`.`OpportunityID`,
         `transmit_status`,
         `transmit_date`;