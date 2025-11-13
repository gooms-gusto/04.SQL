-- 
-- Set character set the client will use to send SQL statements to the server
--
SET NAMES 'utf8';

--
-- Set default database
--
USE wms_cml;

--
-- Create view `ZCBT01_BCA_STREAM_SRNew`
--
CREATE
DEFINER = 'sa'@'localhost'
VIEW ZCBT01_BCA_STREAM_SRNew
AS
SELECT
  `a`.`organizationId` AS `organizationId`,
  'CBT01' AS `warehouseId`,
  `a`.`customerId` AS `customerId`,
  `a`.`sku` AS `sku`,
  (CASE WHEN ISNULL(`b`.`totalqty`) THEN 0 ELSE `b`.`totalqty` END) AS `totalqty`
FROM (`wms_cml`.`BAS_SKU` `a`
  LEFT JOIN (SELECT
      `a`.`organizationId` AS `organizationId`,
      `a`.`customerId` AS `customerId`,
      `a`.`warehouseId` AS `warehouseId`,
      `a`.`sku` AS `sku`,
      (CASE `b`.`lotId` WHEN 'SERIALNO' THEN (CASE WHEN (`c`.`qty` > 0) THEN (SUM((`a`.`qty` - `a`.`qtyAllocated`)) / `c`.`qty`) ELSE (SUM((`a`.`qty` - `a`.`qtyAllocated`)) / `d`.`qty`) END) ELSE SUM((`a`.`qty` - `a`.`qtyAllocated`)) END) AS `totalqty`
    FROM ((((((SELECT
          `wms_cml`.`INV_LOT_ATT`.`organizationId` AS `organizationId`,
          `wms_cml`.`INV_LOT_ATT`.`lotNum` AS `lotNum`,
          `wms_cml`.`INV_LOT_ATT`.`customerId` AS `customerId`,
          `wms_cml`.`INV_LOT_ATT`.`sku` AS `sku`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt01` AS `lotAtt01`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt02` AS `lotAtt02`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt03` AS `lotAtt03`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt04` AS `lotAtt04`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt05` AS `lotAtt05`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt06` AS `lotAtt06`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt07` AS `lotAtt07`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt08` AS `lotAtt08`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt09` AS `lotAtt09`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt10` AS `lotAtt10`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt11` AS `lotAtt11`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt12` AS `lotAtt12`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt13` AS `lotAtt13`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt14` AS `lotAtt14`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt15` AS `lotAtt15`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt16` AS `lotAtt16`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt17` AS `lotAtt17`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt18` AS `lotAtt18`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt19` AS `lotAtt19`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt20` AS `lotAtt20`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt21` AS `lotAtt21`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt22` AS `lotAtt22`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt23` AS `lotAtt23`,
          `wms_cml`.`INV_LOT_ATT`.`lotAtt24` AS `lotAtt24`,
          `wms_cml`.`INV_LOT_ATT`.`receivingTime` AS `receivingTime`,
          `wms_cml`.`INV_LOT_ATT`.`fileId` AS `fileId`,
          `wms_cml`.`INV_LOT_ATT`.`qcReportFileName` AS `qcReportFileName`,
          `wms_cml`.`INV_LOT_ATT`.`noteText` AS `noteText`,
          `wms_cml`.`INV_LOT_ATT`.`udf01` AS `udf01`,
          `wms_cml`.`INV_LOT_ATT`.`udf02` AS `udf02`,
          `wms_cml`.`INV_LOT_ATT`.`udf03` AS `udf03`,
          `wms_cml`.`INV_LOT_ATT`.`udf04` AS `udf04`,
          `wms_cml`.`INV_LOT_ATT`.`udf05` AS `udf05`,
          `wms_cml`.`INV_LOT_ATT`.`currentVersion` AS `currentVersion`,
          `wms_cml`.`INV_LOT_ATT`.`oprSeqFlag` AS `oprSeqFlag`,
          `wms_cml`.`INV_LOT_ATT`.`addWho` AS `addWho`,
          `wms_cml`.`INV_LOT_ATT`.`addTime` AS `addTime`,
          `wms_cml`.`INV_LOT_ATT`.`editWho` AS `editWho`,
          `wms_cml`.`INV_LOT_ATT`.`editTime` AS `editTime`
        FROM `wms_cml`.`INV_LOT_ATT`
        WHERE (`wms_cml`.`INV_LOT_ATT`.`lotAtt08` = 'N'))) `e`
      LEFT JOIN (SELECT
          `wms_cml`.`INV_LOT_LOC_ID`.`organizationId` AS `organizationId`,
          `wms_cml`.`INV_LOT_LOC_ID`.`warehouseId` AS `warehouseId`,
          `wms_cml`.`INV_LOT_LOC_ID`.`locationId` AS `locationId`,
          `wms_cml`.`INV_LOT_LOC_ID`.`lotNum` AS `lotNum`,
          `wms_cml`.`INV_LOT_LOC_ID`.`traceId` AS `traceId`,
          `wms_cml`.`INV_LOT_LOC_ID`.`customerId` AS `customerId`,
          `wms_cml`.`INV_LOT_LOC_ID`.`sku` AS `sku`,
          `wms_cml`.`INV_LOT_LOC_ID`.`qty` AS `qty`,
          `wms_cml`.`INV_LOT_LOC_ID`.`qtyAllocated` AS `qtyAllocated`,
          `wms_cml`.`INV_LOT_LOC_ID`.`qtyRpIn` AS `qtyRpIn`,
          `wms_cml`.`INV_LOT_LOC_ID`.`qtyRpOut` AS `qtyRpOut`,
          `wms_cml`.`INV_LOT_LOC_ID`.`qtyMvIn` AS `qtyMvIn`,
          `wms_cml`.`INV_LOT_LOC_ID`.`qtyMvOut` AS `qtyMvOut`,
          `wms_cml`.`INV_LOT_LOC_ID`.`qtyOnHold` AS `qtyOnHold`,
          `wms_cml`.`INV_LOT_LOC_ID`.`onHoldLocker` AS `onHoldLocker`,
          `wms_cml`.`INV_LOT_LOC_ID`.`grossWeight` AS `grossWeight`,
          `wms_cml`.`INV_LOT_LOC_ID`.`netWeight` AS `netWeight`,
          `wms_cml`.`INV_LOT_LOC_ID`.`cubic` AS `cubic`,
          `wms_cml`.`INV_LOT_LOC_ID`.`price` AS `price`,
          `wms_cml`.`INV_LOT_LOC_ID`.`lpn` AS `lpn`,
          `wms_cml`.`INV_LOT_LOC_ID`.`qtyPa` AS `qtyPa`,
          `wms_cml`.`INV_LOT_LOC_ID`.`qcStatus` AS `qcStatus`,
          `wms_cml`.`INV_LOT_LOC_ID`.`lastMaintenanceDate` AS `lastMaintenanceDate`,
          `wms_cml`.`INV_LOT_LOC_ID`.`noteText` AS `noteText`,
          `wms_cml`.`INV_LOT_LOC_ID`.`udf01` AS `udf01`,
          `wms_cml`.`INV_LOT_LOC_ID`.`udf02` AS `udf02`,
          `wms_cml`.`INV_LOT_LOC_ID`.`udf03` AS `udf03`,
          `wms_cml`.`INV_LOT_LOC_ID`.`udf04` AS `udf04`,
          `wms_cml`.`INV_LOT_LOC_ID`.`udf05` AS `udf05`,
          `wms_cml`.`INV_LOT_LOC_ID`.`currentVersion` AS `currentVersion`,
          `wms_cml`.`INV_LOT_LOC_ID`.`oprSeqFlag` AS `oprSeqFlag`,
          `wms_cml`.`INV_LOT_LOC_ID`.`addWho` AS `addWho`,
          `wms_cml`.`INV_LOT_LOC_ID`.`addTime` AS `addTime`,
          `wms_cml`.`INV_LOT_LOC_ID`.`editWho` AS `editWho`,
          `wms_cml`.`INV_LOT_LOC_ID`.`editTime` AS `editTime`,
          `wms_cml`.`INV_LOT_LOC_ID`.`inLocTime` AS `inLocTime`,
          `wms_cml`.`INV_LOT_LOC_ID`.`muid` AS `muid`
        FROM `wms_cml`.`INV_LOT_LOC_ID`
        WHERE (`wms_cml`.`INV_LOT_LOC_ID`.`qtyOnHold` = 0)) `a`
        ON (((`a`.`organizationId` = `e`.`organizationId`)
        AND (`a`.`lotNum` = `e`.`lotNum`)
        AND (`a`.`customerId` = `e`.`customerId`))))
      LEFT JOIN `wms_cml`.`BAS_SKU` `b`
        ON (((`a`.`organizationId` = `b`.`organizationId`)
        AND (`a`.`customerId` = `b`.`customerId`)
        AND (`a`.`sku` = `b`.`sku`))))
      LEFT JOIN (SELECT
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`organizationId` AS `organizationId`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`packId` AS `packId`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`packUom` AS `packUom`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`qty` AS `qty`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`uomDescr` AS `uomDescr`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`packMaterial` AS `packMaterial`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`cartonizeFlag` AS `cartonizeFlag`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`in_label` AS `in_label`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`out_label` AS `out_label`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`rpl_label` AS `rpl_label`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`serialNoCatch` AS `serialNoCatch`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`length` AS `length`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`width` AS `width`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`height` AS `height`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`cube` AS `cube`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`weight` AS `weight`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`noteText` AS `noteText`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`udf01` AS `udf01`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`udf02` AS `udf02`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`udf03` AS `udf03`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`udf04` AS `udf04`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`udf05` AS `udf05`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`currentVersion` AS `currentVersion`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`oprSeqFlag` AS `oprSeqFlag`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`addWho` AS `addWho`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`addTime` AS `addTime`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`editWho` AS `editWho`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`editTime` AS `editTime`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`showSequence` AS `showSequence`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`customerId` AS `customerId`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`cube1` AS `cube1`
        FROM `wms_cml`.`BAS_PACKAGE_DETAILS`
        WHERE (`wms_cml`.`BAS_PACKAGE_DETAILS`.`packUom` = 'IP')) `c`
        ON (((`a`.`organizationId` = `c`.`organizationId`)
        AND (`b`.`packId` = `c`.`packId`)
        AND (`a`.`customerId` = `c`.`customerId`))))
      LEFT JOIN (SELECT
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`organizationId` AS `organizationId`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`packId` AS `packId`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`packUom` AS `packUom`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`qty` AS `qty`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`uomDescr` AS `uomDescr`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`packMaterial` AS `packMaterial`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`cartonizeFlag` AS `cartonizeFlag`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`in_label` AS `in_label`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`out_label` AS `out_label`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`rpl_label` AS `rpl_label`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`serialNoCatch` AS `serialNoCatch`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`length` AS `length`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`width` AS `width`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`height` AS `height`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`cube` AS `cube`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`weight` AS `weight`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`noteText` AS `noteText`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`udf01` AS `udf01`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`udf02` AS `udf02`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`udf03` AS `udf03`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`udf04` AS `udf04`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`udf05` AS `udf05`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`currentVersion` AS `currentVersion`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`oprSeqFlag` AS `oprSeqFlag`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`addWho` AS `addWho`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`addTime` AS `addTime`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`editWho` AS `editWho`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`editTime` AS `editTime`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`showSequence` AS `showSequence`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`customerId` AS `customerId`,
          `wms_cml`.`BAS_PACKAGE_DETAILS`.`cube1` AS `cube1`
        FROM `wms_cml`.`BAS_PACKAGE_DETAILS`
        WHERE (`wms_cml`.`BAS_PACKAGE_DETAILS`.`packUom` = 'CS')) `d`
        ON (((`a`.`organizationId` = `d`.`organizationId`)
        AND (`b`.`packId` = `d`.`packId`)
        AND (`a`.`customerId` = `d`.`customerId`))))
    WHERE (`a`.`customerId` = 'BCA')
    GROUP BY `a`.`organizationId`,
             `a`.`customerId`,
             `a`.`warehouseId`,
             `a`.`sku`,
             `c`.`qty`,
             `d`.`qty`,
             `b`.`lotId`) `b`
    ON (((`a`.`organizationId` = `b`.`organizationId`)
    AND (`a`.`customerId` = `b`.`customerId`)
    AND (`a`.`sku` = `b`.`sku`))))
WHERE ((`a`.`customerId` = 'BCA')
AND (`a`.`udf05` = 'EBI'));