/*
  @ BASF Get Cengkareng Outbound V1
  @ Based on SCRIPT OUTBOUND BASF Revisi 20211229
  @ Author : Ahmad Sudjana
  @ Created At : 2021-12-29
  @ Edited At : 2023-03-07
*/
SELECT * FROM (
SELECT
  IFNULL(CAST(dah.soReference1 as char (255)),'') AS soReference1, 
  IFNULL(CAST(dah.soReference2 as char (255)),'') AS soReference2, 
  IFNULL(CAST(dah.soReference3 as char (255)),'') AS soReference3, 
  IFNULL(CAST(dah.soReference4 as char (255)),'') AS soReference4, 
  IFNULL(CAST(dah.soReference5 as char (255)),'') AS soReference5,
  IFNULL(CAST(ila.lotAtt10 as char (255)),'') AS plant, /*BASF Cengkareng Plant ID*/
  IFNULL(CAST(ila.lotAtt11 as char (255)),'') AS sloc, /*BASF Cengkareng SLOC*/
  IFNULL(CAST(dah.orderType as char (255)),'') AS orderType, 
  IFNULL(CAST(atl.docNo as char (255)),'') AS orderNo, 
  IFNULL(CAST(dah.noteText as char (255)),'') AS noteText,  
  IFNULL(CAST(atl.fmSku as char (255)),'') AS SKU,
  IFNULL(CAST(bs.skuDescr1 as char (255)),'') AS skuDescr1,
  IFNULL(CAST(bs.packId as char (255)),'') AS packId, 
  IFNULL(CAST(bpd.qty as char (255)),'') AS QtyPerPallet, 
  IFNULL(CAST(bpd1.qty as char (255)),'') AS QtyPerCases, 
  IFNULL(CAST(atl.status as char (255)),'') AS soStatus,
  IFNULL(CAST(DATE_FORMAT(atl.addTime, '%Y-%m-%d' ) as char (255)),'') AS ShipmentTime,
  IFNULL(CAST(atl.fmLotNum as char (255)),'') AS lotNum , 
  IFNULL(CAST(ila.lotAtt05 as char (255)),'') AS typeSku, 
  IFNULL(CAST(ila.lotAtt04 as char (255)),'') AS batch,
  IFNULL(CAST(atl.fmQty_Each as char (255)),'') AS qtyShipped_each, 
  IFNULL(CAST('KG' as char (255)),'') AS uom, 
  IFNULL(CAST(bs.sku_group2 as char (255)),'') AS skuGroup, 
  IFNULL(CAST(bs.sku_group3 as char (255)),'') AS sku_group3,
  IFNULL(CAST(dah.udf01 as char (255)),'') AS containerNo,
  IFNULL(CAST(dah3.vehicleNo as char (255)),'') AS vehicleNo,
  IFNULL(CAST(dah3.vehicleType as char (255)),'') AS vehicleType,
  IFNULL(CAST(dah3.carrierId as char (255)),'') AS carrierId,
  IFNULL(CAST(bc.customerdescr1 as char (255)),'') AS carrierName,
  IFNULL(CAST(dah.consigneeId as char (255)),'') AS consigneeId,
  IFNULL(CAST(bc1.customerDescr1 as char (255)),'') AS CompanyName,
  IFNULL(CAST(bc1.address3 as char (255)),'') AS ConsigneeCategory,
  IFNULL(CAST(dah.consigneeName as char (255)),'') AS consigneedName,
  IFNULL(CAST(bc1.address4 as char (255)),'') AS Destinatiomn,
  IFNULL(CAST(atl.toId as char (255)),'') AS traceId,
  IFNULL(CAST(atl.toMuid as char (255)),'') AS dropId
FROM
 ACT_TRANSACTION_LOG atl 
LEFT OUTER JOIN INV_LOT_ATT ila 
on 
 atl.organizationId=ila.organizationId 
 and atl.tolotnum=ila.lotnum 
 and atl.tocustomerid=ila.customerid
LEFT OUTER JOIN DOC_ORDER_HEADER dah 
on 
 atl.organizationId=dah.organizationId 
 and atl.warehouseid=dah.warehouseid 
 and atl.docno=dah.orderno 
 and atl.tocustomerid=dah.customerid
LEFT OUTER JOIN BAS_SKU bs 
on 
 atl.organizationId=bs.organizationId 
 and atl.tosku=bs.sku 
 and atl.tocustomerid=bs.customerid
LEFT OUTER JOIN (
  select * from BAS_PACKAGE_DETAILS where packUom = 'PL') bpd 
on
 bs.organizationId=bpd.organizationId 
 and bs.packid=bpd.packid 
 and bs.customerid=bpd.customerid
LEFT OUTER JOIN (
  select * from BAS_PACKAGE_DETAILS where packUom = 'CS') bpd1 
on
 bs.organizationId=bpd1.organizationId 
 and bs.packid=bpd1.packid 
 and bs.customerid=bpd1.customerid

LEFT OUTER JOIN DOC_LOADING_HEADER dlh 
on
 dah.organizationId=dlh.organizationId 
 and dah.warehouseId=dlh.warehouseId 
 and dah.waveNo=dlh.waveNo
 and dlh.warehouseId = '$warehouseId'
LEFT OUTER JOIN DOC_APPOINTMENT_DETAILS dad 
on
 dlh.organizationId=dad.organizationId 
 and dlh.warehouseId=dad.warehouseId 
 and dlh.ldlNo=dad.docNo
 and dad.warehouseId = '$warehouseId'
LEFT OUTER JOIN DOC_APPOINTMENT_HEADER dah2 
on
 dad.organizationId=dah2.organizationId
 and dad.warehouseId=dah2.warehouseId 
 and dad.appointmentNo=dah2.appointmentNo and
 dah.warehouseId = '$warehouseId'
LEFT OUTER JOIN (
  select
   * 
  from
   DOC_ARRIVAL_DETAILS 
  where
   arrivalno not in (
     select
      arrivalno 
     from
      DOC_ARRIVAL_HEADER 
     where
      arrivalStatus<>'90')) dad2 
on
 dah2.organizationId=dad2.organizationId 
 and dah2.warehouseId=dad2.warehouseId 
 and dah2.appointmentNo=dad2.appointmentno
LEFT OUTER JOIN (
  select * from DOC_ARRIVAL_HEADER where arrivalStatus<>'90') dah3 
on
 dad2.organizationId=dah3.organizationId 
 and dad2.warehouseId=dah3.warehouseId 
 and dad2.arrivalno=dah3.arrivalNo
LEFT OUTER JOIN (
  select * from BAS_CUSTOMER where customertype='CA') bc 
on
 dah3.organizationId=bc.organizationId 
 and dah3.carrierId=bc.customerId
LEFT OUTER JOIN (select * from BAS_CUSTOMER where customertype='CO') bc1 
on
 dah.organizationId=bc1.organizationId 
 and dah.consigneeId=bc1.customerId
where
  atl.warehouseId = '$warehouseId' and atl.fmCustomerId = '$company_id' 
  and atl.transactionType = 'SO' and atl.status <> '90' and dah.orderType <> 'IU'
  and DATE_FORMAT(atl.addTime, '%Y-%m-%d' ) >= '$startDate'
	and DATE_FORMAT(atl.addTime, '%Y-%m-%d' ) <= '2023-06-30'
group by
 dah.soReference1, 
 dah.soReference2 , 
 dah.soReference3, 
 dah.soReference4 , 
 dah.soReference5 , 
 dah.orderType , 
 atl.docNo ,
 atl.docLineNo , 
 atl.addTime, 
 dah.noteText ,
 atl.fmSku,
 atl.fmLotNum,
 atl.fmQty_Each, 
 bs.skuDescr1 , 
 bs.packId , 
 bpd.qty, 
 bpd1.qty, 
 atl.status, 
 ila.lotAtt05 , 
 ila.lotAtt04, 
 bs.sku_group2, 
 bs.sku_group3,
 dah.udf01,
 dah3.vehicleNo,
 dah3.vehicleType,
 dah3.carrierId,
 bc.customerdescr1,
 dah.consigneeId,
 bc1.customerDescr1,
 ila.lotAtt10,
 ila.lotAtt11,
 bc1.address3,
 dah.consigneeId,
 dah.consigneeName,
 bc1.address4,
 dlh.reference1,
 atl.toId, 
 atl.toMuid ) atl
 WHERE atl.typeSku = 'FG' AND  orderType NOT IN ('FREE') and ConsigneeCategory = 'TO PROD'
AND SKU NOT LIKE 'PALLET%' AND SKU NOT LIKE 'PLYWOOD%' AND SKU NOT LIKE 'BLOCKING_BOARD%'

