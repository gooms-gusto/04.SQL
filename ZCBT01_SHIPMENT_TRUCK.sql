USE wms_cml;

DROP VIEW ZCBT01_SHIPMENT_TRUCK CASCADE;

CREATE
DEFINER = 'sa'@'localhost'
VIEW ZCBT01_SHIPMENT_TRUCK
AS
SELECT
  `a`.`organizationId` AS `organizationId`,
  `a`.`warehouseId` AS `warehouseId`,
  `g`.`customerId` AS `customerid`,
  `a`.`arrivalno` AS `arrivalNo`,
  `a`.`appointmentno` AS `appointmentno`,
  `c`.`docNo` AS `docNo`,
  `e`.`orderNo` AS `orderNo`,
  `b`.`vehicleNo` AS `vehicleNo`,
  `b`.`driver` AS `driver`,
  `b`.`driverTel` AS `driverTel`,
  `b`.`vehicleType` AS `VehicleType`,
  `b`.`entranceTime` AS `appointmentStartTime`,
  `b`.`leaveTime` AS `appointmentEndTime`,
  `b`.`startTime` AS `startTime`,
  `b`.`endTime` AS `endTime`,
  `b`.`carrierId` AS `carrierId`,
  `f`.`customerDescr1` AS `carrierName`
FROM ((((((((SELECT
      `wms_cml`.`DOC_ARRIVAL_DETAILS`.`organizationId` AS `organizationId`,
      `wms_cml`.`DOC_ARRIVAL_DETAILS`.`warehouseId` AS `warehouseId`,
      `wms_cml`.`DOC_ARRIVAL_DETAILS`.`arrivalno` AS `arrivalno`,
      `wms_cml`.`DOC_ARRIVAL_DETAILS`.`appointmentno` AS `appointmentno`,
      `wms_cml`.`DOC_ARRIVAL_DETAILS`.`noteText` AS `noteText`,
      `wms_cml`.`DOC_ARRIVAL_DETAILS`.`udf01` AS `udf01`,
      `wms_cml`.`DOC_ARRIVAL_DETAILS`.`udf02` AS `udf02`,
      `wms_cml`.`DOC_ARRIVAL_DETAILS`.`udf03` AS `udf03`,
      `wms_cml`.`DOC_ARRIVAL_DETAILS`.`udf04` AS `udf04`,
      `wms_cml`.`DOC_ARRIVAL_DETAILS`.`udf05` AS `udf05`,
      `wms_cml`.`DOC_ARRIVAL_DETAILS`.`currentVersion` AS `currentVersion`,
      `wms_cml`.`DOC_ARRIVAL_DETAILS`.`oprSeqFlag` AS `oprSeqFlag`,
      `wms_cml`.`DOC_ARRIVAL_DETAILS`.`addWho` AS `addWho`,
      `wms_cml`.`DOC_ARRIVAL_DETAILS`.`addTime` AS `addTime`,
      `wms_cml`.`DOC_ARRIVAL_DETAILS`.`editWho` AS `editWho`,
      `wms_cml`.`DOC_ARRIVAL_DETAILS`.`editTime` AS `editTime`
    FROM `wms_cml`.`DOC_ARRIVAL_DETAILS`
    WHERE (`wms_cml`.`DOC_ARRIVAL_DETAILS`.`appointmentno` LIKE 'OUB%'))) `a`
  LEFT JOIN `wms_cml`.`DOC_ARRIVAL_HEADER` `b`
    ON (((`a`.`arrivalno` = `b`.`arrivalNo`)
    AND (`a`.`organizationId` = `b`.`organizationId`)
    AND (`a`.`warehouseId` = `b`.`warehouseId`))))
  LEFT JOIN `wms_cml`.`DOC_APPOINTMENT_DETAILS` `c`
    ON (((`a`.`appointmentno` = `c`.`appointmentNo`)
    AND (`a`.`organizationId` = `c`.`organizationId`)
    AND (`a`.`warehouseId` = `c`.`warehouseId`))))
  LEFT JOIN `wms_cml`.`DOC_LOADING_HEADER` `d`
    ON (((`c`.`docNo` = `d`.`ldlNo`)
    AND (`c`.`organizationId` = `d`.`organizationId`)
    AND (`c`.`warehouseId` = `d`.`warehouseId`))))
  LEFT JOIN `wms_cml`.`DOC_WAVE_DETAILS` `e`
    ON (((`d`.`waveNo` = `e`.`waveNo`)
    AND (`d`.`organizationId` = `e`.`organizationId`)
    AND (`d`.`warehouseId` = `e`.`warehouseId`))))
  LEFT JOIN (SELECT
      `wms_cml`.`BAS_CUSTOMER`.`organizationId` AS `organizationId`,
      `wms_cml`.`BAS_CUSTOMER`.`customerId` AS `customerId`,
      `wms_cml`.`BAS_CUSTOMER`.`customerType` AS `customerType`,
      `wms_cml`.`BAS_CUSTOMER`.`customerDescr1` AS `customerDescr1`,
      `wms_cml`.`BAS_CUSTOMER`.`customerDescr2` AS `customerDescr2`,
      `wms_cml`.`BAS_CUSTOMER`.`activeFlag` AS `activeFlag`,
      `wms_cml`.`BAS_CUSTOMER`.`refOwner` AS `refOwner`,
      `wms_cml`.`BAS_CUSTOMER`.`easyCode` AS `easyCode`,
      `wms_cml`.`BAS_CUSTOMER`.`address1` AS `address1`,
      `wms_cml`.`BAS_CUSTOMER`.`address2` AS `address2`,
      `wms_cml`.`BAS_CUSTOMER`.`address3` AS `address3`,
      `wms_cml`.`BAS_CUSTOMER`.`address4` AS `address4`,
      `wms_cml`.`BAS_CUSTOMER`.`country` AS `country`,
      `wms_cml`.`BAS_CUSTOMER`.`province` AS `province`,
      `wms_cml`.`BAS_CUSTOMER`.`city` AS `city`,
      `wms_cml`.`BAS_CUSTOMER`.`district` AS `district`,
      `wms_cml`.`BAS_CUSTOMER`.`street` AS `street`,
      `wms_cml`.`BAS_CUSTOMER`.`zipCode` AS `zipCode`,
      `wms_cml`.`BAS_CUSTOMER`.`contact1` AS `contact1`,
      `wms_cml`.`BAS_CUSTOMER`.`contact1_tel1` AS `contact1_tel1`,
      `wms_cml`.`BAS_CUSTOMER`.`contact1_tel2` AS `contact1_tel2`,
      `wms_cml`.`BAS_CUSTOMER`.`contact1_fax` AS `contact1_fax`,
      `wms_cml`.`BAS_CUSTOMER`.`contact1_email` AS `contact1_email`,
      `wms_cml`.`BAS_CUSTOMER`.`contact1_title` AS `contact1_title`,
      `wms_cml`.`BAS_CUSTOMER`.`contact2` AS `contact2`,
      `wms_cml`.`BAS_CUSTOMER`.`contact2_tel1` AS `contact2_tel1`,
      `wms_cml`.`BAS_CUSTOMER`.`contact2_tel2` AS `contact2_tel2`,
      `wms_cml`.`BAS_CUSTOMER`.`contact2_fax` AS `contact2_fax`,
      `wms_cml`.`BAS_CUSTOMER`.`contact2_email` AS `contact2_email`,
      `wms_cml`.`BAS_CUSTOMER`.`contact2_title` AS `contact2_title`,
      `wms_cml`.`BAS_CUSTOMER`.`contact3` AS `contact3`,
      `wms_cml`.`BAS_CUSTOMER`.`contact3_tel1` AS `contact3_tel1`,
      `wms_cml`.`BAS_CUSTOMER`.`contact3_tel2` AS `contact3_tel2`,
      `wms_cml`.`BAS_CUSTOMER`.`contact3_fax` AS `contact3_fax`,
      `wms_cml`.`BAS_CUSTOMER`.`contact3_email` AS `contact3_email`,
      `wms_cml`.`BAS_CUSTOMER`.`contact3_title` AS `contact3_title`,
      `wms_cml`.`BAS_CUSTOMER`.`currency` AS `currency`,
      `wms_cml`.`BAS_CUSTOMER`.`billTo` AS `billTo`,
      `wms_cml`.`BAS_CUSTOMER`.`carrier` AS `carrier`,
      `wms_cml`.`BAS_CUSTOMER`.`cartonGroup` AS `cartonGroup`,
      `wms_cml`.`BAS_CUSTOMER`.`docPrefix` AS `docPrefix`,
      `wms_cml`.`BAS_CUSTOMER`.`edi_code` AS `edi_code`,
      `wms_cml`.`BAS_CUSTOMER`.`followUp` AS `followUp`,
      `wms_cml`.`BAS_CUSTOMER`.`defaultPutawayRule` AS `defaultPutawayRule`,
      `wms_cml`.`BAS_CUSTOMER`.`reserveCode` AS `reserveCode`,
      `wms_cml`.`BAS_CUSTOMER`.`calculateCode` AS `calculateCode`,
      `wms_cml`.`BAS_CUSTOMER`.`rotationId` AS `rotationId`,
      `wms_cml`.`BAS_CUSTOMER`.`defaultSoftAllocationRule` AS `defaultSoftAllocationRule`,
      `wms_cml`.`BAS_CUSTOMER`.`defaultAllocationRule` AS `defaultAllocationRule`,
      `wms_cml`.`BAS_CUSTOMER`.`defaultSkuLotId` AS `defaultSkuLotId`,
      `wms_cml`.`BAS_CUSTOMER`.`tariffId` AS `tariffId`,
      `wms_cml`.`BAS_CUSTOMER`.`defaultPackId` AS `defaultPackId`,
      `wms_cml`.`BAS_CUSTOMER`.`defaultReceivingUom` AS `defaultReceivingUom`,
      `wms_cml`.`BAS_CUSTOMER`.`defaultShipmentUom` AS `defaultShipmentUom`,
      `wms_cml`.`BAS_CUSTOMER`.`defaultReportUom` AS `defaultReportUom`,
      `wms_cml`.`BAS_CUSTOMER`.`defaultReplenishRule` AS `defaultReplenishRule`,
      `wms_cml`.`BAS_CUSTOMER`.`orderBySql` AS `orderBySql`,
      `wms_cml`.`BAS_CUSTOMER`.`qcRule` AS `qcRule`,
      `wms_cml`.`BAS_CUSTOMER`.`asnRef1ToLot4` AS `asnRef1ToLot4`,
      `wms_cml`.`BAS_CUSTOMER`.`asnRef2ToLot5` AS `asnRef2ToLot5`,
      `wms_cml`.`BAS_CUSTOMER`.`asnRef3ToLot6` AS `asnRef3ToLot6`,
      `wms_cml`.`BAS_CUSTOMER`.`asnRef4ToLot7` AS `asnRef4ToLot7`,
      `wms_cml`.`BAS_CUSTOMER`.`asnRef5ToLot8` AS `asnRef5ToLot8`,
      `wms_cml`.`BAS_CUSTOMER`.`soRef1ToLot4` AS `soRef1ToLot4`,
      `wms_cml`.`BAS_CUSTOMER`.`soRef2ToLot5` AS `soRef2ToLot5`,
      `wms_cml`.`BAS_CUSTOMER`.`soRef3ToLot6` AS `soRef3ToLot6`,
      `wms_cml`.`BAS_CUSTOMER`.`soRef4ToLot7` AS `soRef4ToLot7`,
      `wms_cml`.`BAS_CUSTOMER`.`soRef5ToLot8` AS `soRef5ToLot8`,
      `wms_cml`.`BAS_CUSTOMER`.`copyPriceToLotAtt09` AS `copyPriceToLotAtt09`,
      `wms_cml`.`BAS_CUSTOMER`.`overReceiving` AS `overReceiving`,
      `wms_cml`.`BAS_CUSTOMER`.`overRcvPercentage` AS `overRcvPercentage`,
      `wms_cml`.`BAS_CUSTOMER`.`vat` AS `vat`,
      `wms_cml`.`BAS_CUSTOMER`.`bankAccount` AS `bankAccount`,
      `wms_cml`.`BAS_CUSTOMER`.`billingDate` AS `billingDate`,
      `wms_cml`.`BAS_CUSTOMER`.`allInFlag` AS `allInFlag`,
      `wms_cml`.`BAS_CUSTOMER`.`allInRate` AS `allInRate`,
      `wms_cml`.`BAS_CUSTOMER`.`allInArea` AS `allInArea`,
      `wms_cml`.`BAS_CUSTOMER`.`allInRateType` AS `allInRateType`,
      `wms_cml`.`BAS_CUSTOMER`.`billClass` AS `billClass`,
      `wms_cml`.`BAS_CUSTOMER`.`cubicUom` AS `cubicUom`,
      `wms_cml`.`BAS_CUSTOMER`.`weightUom` AS `weightUom`,
      `wms_cml`.`BAS_CUSTOMER`.`billClassInv` AS `billClassInv`,
      `wms_cml`.`BAS_CUSTOMER`.`invChgWithShipment` AS `invChgWithShipment`,
      `wms_cml`.`BAS_CUSTOMER`.`billWithAsnType` AS `billWithAsnType`,
      `wms_cml`.`BAS_CUSTOMER`.`billWithSoType` AS `billWithSoType`,
      `wms_cml`.`BAS_CUSTOMER`.`bil_obd_stk` AS `bil_obd_stk`,
      `wms_cml`.`BAS_CUSTOMER`.`sn_asn_cls` AS `sn_asn_cls`,
      `wms_cml`.`BAS_CUSTOMER`.`sn_so_cls` AS `sn_so_cls`,
      `wms_cml`.`BAS_CUSTOMER`.`sn_asn_so` AS `sn_asn_so`,
      `wms_cml`.`BAS_CUSTOMER`.`inboundSerialNoQtyControl` AS `inboundSerialNoQtyControl`,
      `wms_cml`.`BAS_CUSTOMER`.`outboundSerialNoQtyControl` AS `outboundSerialNoQtyControl`,
      `wms_cml`.`BAS_CUSTOMER`.`asn_snd_eml` AS `asn_snd_eml`,
      `wms_cml`.`BAS_CUSTOMER`.`so_snd_eml` AS `so_snd_eml`,
      `wms_cml`.`BAS_CUSTOMER`.`idx_load_sku` AS `idx_load_sku`,
      `wms_cml`.`BAS_CUSTOMER`.`idx_load_supplier` AS `idx_load_supplier`,
      `wms_cml`.`BAS_CUSTOMER`.`idx_load_consignee` AS `idx_load_consignee`,
      `wms_cml`.`BAS_CUSTOMER`.`printMedicineQcReport` AS `printMedicineQcReport`,
      `wms_cml`.`BAS_CUSTOMER`.`emedicineQcReport` AS `emedicineQcReport`,
      `wms_cml`.`BAS_CUSTOMER`.`asn_lnk_po` AS `asn_lnk_po`,
      `wms_cml`.`BAS_CUSTOMER`.`orderLotControl` AS `orderLotControl`,
      `wms_cml`.`BAS_CUSTOMER`.`fullCaseLotControl` AS `fullCaseLotControl`,
      `wms_cml`.`BAS_CUSTOMER`.`pieceLotControl` AS `pieceLotControl`,
      `wms_cml`.`BAS_CUSTOMER`.`asnNoByCustomer` AS `asnNoByCustomer`,
      `wms_cml`.`BAS_CUSTOMER`.`orderNoByCustomer` AS `orderNoByCustomer`,
      `wms_cml`.`BAS_CUSTOMER`.`routeCode` AS `routeCode`,
      `wms_cml`.`BAS_CUSTOMER`.`system_type` AS `system_type`,
      `wms_cml`.`BAS_CUSTOMER`.`validDateFrom` AS `validDateFrom`,
      `wms_cml`.`BAS_CUSTOMER`.`validDateTo` AS `validDateTo`,
      `wms_cml`.`BAS_CUSTOMER`.`skuAnalysisFields` AS `skuAnalysisFields`,
      `wms_cml`.`BAS_CUSTOMER`.`noteText` AS `noteText`,
      `wms_cml`.`BAS_CUSTOMER`.`udf01` AS `udf01`,
      `wms_cml`.`BAS_CUSTOMER`.`udf02` AS `udf02`,
      `wms_cml`.`BAS_CUSTOMER`.`udf03` AS `udf03`,
      `wms_cml`.`BAS_CUSTOMER`.`udf04` AS `udf04`,
      `wms_cml`.`BAS_CUSTOMER`.`udf05` AS `udf05`,
      `wms_cml`.`BAS_CUSTOMER`.`currentVersion` AS `currentVersion`,
      `wms_cml`.`BAS_CUSTOMER`.`oprSeqFlag` AS `oprSeqFlag`,
      `wms_cml`.`BAS_CUSTOMER`.`addWho` AS `addWho`,
      `wms_cml`.`BAS_CUSTOMER`.`addTime` AS `addTime`,
      `wms_cml`.`BAS_CUSTOMER`.`editWho` AS `editWho`,
      `wms_cml`.`BAS_CUSTOMER`.`editTime` AS `editTime`,
      `wms_cml`.`BAS_CUSTOMER`.`refWarehouseId` AS `refWarehouseId`,
      `wms_cml`.`BAS_CUSTOMER`.`stopStation` AS `stopStation`,
      `wms_cml`.`BAS_CUSTOMER`.`alternativeId` AS `alternativeId`,
      `wms_cml`.`BAS_CUSTOMER`.`discountRate` AS `discountRate`,
      `wms_cml`.`BAS_CUSTOMER`.`discountStart` AS `discountStart`,
      `wms_cml`.`BAS_CUSTOMER`.`autoShipRule` AS `autoShipRule`,
      `wms_cml`.`BAS_CUSTOMER`.`originalCode` AS `originalCode`,
      `wms_cml`.`BAS_CUSTOMER`.`internalCode` AS `internalCode`,
      `wms_cml`.`BAS_CUSTOMER`.`asnCloseUpdatePo` AS `asnCloseUpdatePo`,
      `wms_cml`.`BAS_CUSTOMER`.`customerclass` AS `customerclass`
    FROM `wms_cml`.`BAS_CUSTOMER`
    WHERE (`wms_cml`.`BAS_CUSTOMER`.`customerType` = 'CA')) `f`
    ON (((`b`.`carrierId` = `f`.`customerId`)
    AND (`b`.`organizationId` = `f`.`organizationId`))))
  LEFT JOIN `wms_cml`.`DOC_ORDER_HEADER` `g`
    ON (((`e`.`orderNo` = `g`.`orderNo`)
    AND (`e`.`organizationId` = `g`.`organizationId`)
    AND (`e`.`warehouseId` = `g`.`warehouseId`))))
WHERE ((`b`.`arrivalType` = 'OUTBOUND')
AND (`b`.`arrivalStatus` = '99')
AND (`b`.`leaveTime` IS NOT NULL)
AND (`d`.`vehicalNo` IS NOT NULL));