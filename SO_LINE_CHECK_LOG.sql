
    SELECT
              IFNULL(CAST(doh.organizationId AS char), '') AS organizationId,
              IFNULL(CAST(doh.orderNo AS char), '') AS orderNo,
              IFNULL(CAST(doh.soReference1 AS char(255)), '') AS soReference1,
              IFNULL(CAST(doh.soReference3 AS char(255)), '') AS soReference3,
              IFNULL(CAST(t1.codeType AS char(255)), '') AS docType,
              IFNULL(CAST(t1.codeDescr AS char(255)), '') AS docTypeDescr,
              IFNULL(CAST(doh.soStatus AS char(255)), '') AS soStatus,
              IFNULL(CAST(doh.warehouseId AS char(255)), '') AS warehouseId,
              IFNULL(CAST(aad.customerId AS char(255)), '') AS customerId,
              IFNULL(CAST(aad.orderLineNo AS char(255)), 0) AS orderLineNo,
              IFNULL(CAST(aad.SKU AS char(255)), '') AS SKU,
              CAST(DATE_FORMAT(aad.shipmentTime, '%Y-%m-%d') AS char(255)) AS ShipmentTime,
              IFNULL(CAST(aad.qty AS char(255)), 0) AS qty,
              IFNULL(CAST(aad.qty_each AS char(255)), 0) AS qty_each,
              IFNULL(CAST(aad.qtyShipped_each AS char(255)), 0) AS qtyShipped_each,
              IFNULL(CAST(aad.uom AS char(255)), '') AS uom,
              IFNULL(CAST((SUM(aad.qtyShipped_each * bs.cube)) AS char(255)), 0) AS qtyCharge,
              IFNULL(CAST((SUM(aad.qtyShipped_each * bs.cube)) AS char(255)), 0) AS totalCube,
              IFNULL(CAST(aad.editTime AS char(255)), '') AS editTime,
              IFNULL(CAST(aad.lotNum AS char(255)), '') AS lotNum,
              IFNULL(CAST(aad.traceId AS char(255)), '') AS traceId,
              IFNULL(CAST(aad.pickToTraceId AS char(255)), '') AS pickToTraceId,
              IFNULL(CAST(aad.dropId AS char(255)), '') AS dropId,
              IFNULL(CAST(aad.location AS char(255)), '') AS location,
              IFNULL(CAST(aad.pickToLocation AS char(255)), '') AS pickToLocation,
              IFNULL(CAST(aad.allocationDetailsId AS char(255)), '') AS allocationDetailsId,
              IFNULL(CAST(bs.skuDescr1 AS char(255)), '') AS skuDescr1,
              IFNULL(CAST(bs.grossWeight AS char(255)), 0) AS grossWeight,
              IFNULL(CAST(bs.cube AS char(255)), 0) AS cubeNya,
              IFNULL(CAST(bsm.tariffMasterId AS char(255)), '') AS tariffMasterId,
              IFNULL(CAST(bpd.qty AS char(255)), 0) AS QtyPerCases,
              IFNULL(CAST(bpd1.qty AS char(255)), 0) AS QtyPerPallet,
              IFNULL(CAST(bz.zoneDescr AS char(255)), '') AS zone,
              IFNULL(CAST(ila.lotAtt04 AS char(255)), '') AS batch,
              IFNULL(CAST(ila.lotAtt07 AS char(255)), '') AS lotAtt07,
              CASE ila.lotAtt07 WHEN 'O' THEN 'Owner Pallet' WHEN 'R' THEN 'Rental Pallet' WHEN 'PP' THEN 'Rental Plastic Pallet' WHEN 'WP' THEN 'Rental Wooden Pallet' END AS RecType

            FROM ACT_ALLOCATION_DETAILS aad

              LEFT OUTER JOIN DOC_ORDER_HEADER doh
                ON doh.organizationId = aad.organizationId
                AND doh.customerId = aad.customerId
                AND doh.orderNo = aad.orderNo
              LEFT OUTER JOIN BAS_SKU bs
                ON bs.organizationId = aad.organizationId
                AND bs.SKU = aad.SKU
                AND bs.customerId = aad.customerId
              LEFT OUTER JOIN BAS_SKU_MULTIWAREHOUSE bsm
                ON bsm.organizationId = bs.organizationId
                AND bsm.SKU = bs.SKU
                AND bsm.customerId = bs.customerId
                AND bsm.warehouseId = aad.warehouseId

              LEFT OUTER JOIN INV_LOT_ATT ila
                ON ila.organizationId = aad.organizationId
                AND ila.SKU = aad.SKU
                AND ila.lotnum = aad.lotnum
                AND ila.customerId = aad.customerId
              LEFT JOIN BAS_PACKAGE_DETAILS bpd
                ON bpd.organizationId = bs.organizationId
                AND bpd.packId = bs.packId
                AND bpd.customerId = bs.customerId
                AND bpd.packUom = 'CS'
              LEFT JOIN BAS_PACKAGE_DETAILS bpd1
                ON bpd1.organizationId = bs.organizationId
                AND bpd1.packId = bs.packId
                AND bpd1.customerId = bs.customerId
                AND bpd1.packUom = 'PL'
              LEFT JOIN BSM_CODE_ML t1
                ON t1.organizationId = aad.organizationId
                AND t1.codeType = 'SO_TYP'
                AND t1.codeId = doh.orderType
                AND t1.languageId = 'en'

              LEFT JOIN BAS_LOCATION bl
                ON bl.organizationId = aad.organizationId
                AND bl.warehouseId = aad.warehouseId
                AND bl.locationId = aad.location

              LEFT JOIN BAS_ZONE bz
                ON bz.organizationId = bl.organizationId
                AND bz.warehouseId = bl.warehouseId
                AND bz.zoneId = bl.zoneId
                AND bz.zoneGroup = bl.zoneGroup

            WHERE aad.customerId = 'MAP'
            AND aad.warehouseId = 'CBT01'
            AND aad.orderNo='MAP_ORDERNO000000106'
			
            AND bsm.tariffMasterId NOT LIKE '%PIECES'
           -- AND DATE_FORMAT(aad.shipmentTime, '%Y-%m-%d') >= '2023-09-10'
          --  AND DATE_FORMAT(aad.shipmentTime, '%Y-%m-%d') <= '2023-09-12'
            AND aad.Status IN ('99', '80')
            AND bs.skuDescr1 NOT LIKE '%PALLET%'
            AND doh.orderType NOT IN ('FREE', 'KT', 'OT')

            GROUP BY doh.organizationId,
                     doh.orderNo,
                     doh.soReference1,
                     doh.soReference3,
                     t1.codeid,
                     doh.soStatus,
                     doh.orderType,
                     doh.warehouseId,
                     aad.orderLineNo,
                     aad.traceId,
                     aad.pickToTraceId,
                     aad.dropId,
                     aad.customerId,
                     aad.location,
                     aad.pickToLocation,
                     aad.shipmentTime,
                     aad.allocationDetailsId,
                     aad.SKU,
                     aad.qty,
                     aad.qty_each,
                     aad.qtyShipped_each,
                     aad.uom,
                     aad.editTime,
                     aad.lotNum,
                     bsm.tariffMasterId,
                     bs.skuDescr1,
                     bs.grossWeight,
                     bs.cube,
                     bpd.qty,
                     bpd1.qty,
                     t1.codeDescr,
                     bz.zoneDescr,
                     ila.lotAtt04,
                     ila.lotAtt07;
  


-- SELECT * FROM WMS_FTEST.DOC_ORDER_HEADER doh WHERE doh.orderNo='MAP_ORDERNO000000106'