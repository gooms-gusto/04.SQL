  SELECT
        doh.organizationId,
        doh.warehouseId,
        aad.customerId,
        doh.orderNo,
        doh.soReference1,
        doh.soReference3,
        doh.orderType,
        t1.codeType AS docType,
        '' orderLineNo,
        '' SKU,
        DATE_FORMAT(doh.editTime, '%Y-%m-%d') AS ShipmentTime,
        SUM(aad.qty) AS qty,
        SUM(aad.qty_each) AS qty_each,
        SUM(aad.qtyShipped_each) AS qtyShipped_each,
        '' uom,
        0 qtyChargeCS,
        0 AS qtyChargeIP,
        0 qtyChargePL,
        0 qtyChargeCBM,
        0 qtyChargeTotDO,
        0 qtyChargeTotLine,
        0 totalCube,

        '' editTime,
        '' lotNum,
        '' traceId,
        '' pickToTraceId,
        '' dropId,
        '' location,
        '' pickToLocation,
        '' allocationDetailsId,
        '' skuDescr1,
        0 grossWeight,
        0 cubeNya,
        '' tariffMasterId,
        0 QtyPerCases,
        0 QtyPerPallet,
        '' zone,
        '' batch,
        '' lotAtt07,
        '' billtranctg,
        0 qtyChargeNettWeight,
        --             CASE 
        --                 WHEN bpdEA.uomDescr IN ('G', 'GRAM', 'Gram') 
        --                 THEN SUM(aad.qtyShipped_each / 1000) 
        --                 WHEN bpdEA.uomDescr IN ('MT', 'Metric Ton', 'METRIC TON') 
        --                 THEN SUM(aad.qtyShipped_each * 1000) 
        --                 ELSE SUM(aad.qtyShipped_each * bs.grossWeight) 
        --             END AS qtyChargeGrossWeight,

        -- Metric ton calculation
        --             CASE 
        --                 WHEN aad.customerId LIKE '%ABC%' 
        --                 THEN SUM((aad.qtyShipped_each * bpdCS.qty) / 1000) 
        --                 WHEN aad.customerId IN ('ADASBY', 'CAI_MDN', 'CAI_SBY') 
        --                 THEN IFNULL(CAST(SUM((aad.qtyShipped_each * bs.netweight) / 1000) AS CHAR(255)), 0) 
        --                 ELSE SUM(aad.qtyShipped_each / 1000) 
        --             END AS qtyChargeMetricTon,

        --  df.closeTime,

        -- Calculate billing quantity based on rate base
        --             CASE 
        --                 WHEN btd.ratebase = 'CUBIC' THEN SUM(aad.qtyShipped_each * bs.cube)
        --                 WHEN btd.ratebase = 'M2' THEN 
        --                     CASE 
        --                         WHEN aad.customerId = 'MAP' 
        --                             AND ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') 
        --                             AND bsm.tariffMasterId LIKE '%PIECE%' 
        --                         THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
        --                         ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
        --                     END
        --                 WHEN btd.ratebase = 'IP' THEN COALESCE(CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdIP.qty, 0))), 1)
        --                 WHEN btd.ratebase = 'KG' THEN 
        --                     CASE 
        --                         WHEN aad.customerId = 'MAP' 
        --                             AND ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') 
        --                             AND bsm.tariffMasterId LIKE '%PIECE%' 
        --                         THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
        --                         ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
        --                     END
        --                 WHEN btd.ratebase = 'LITER' THEN 
        --                     CASE 
        --                         WHEN aad.customerId = 'MAP' 
        --                             AND ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') 
        --                             AND bsm.tariffMasterId LIKE '%PIECE%' 
        --                         THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
        --                         ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
        --                     END
        --                 WHEN btd.ratebase = 'QUANTITY' THEN 
        --                     CASE 
        --                         WHEN aad.customerId = 'MAP' 
        --                             AND ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') 
        --                             AND bsm.tariffMasterId LIKE '%PIECE%' 
        --                         THEN SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
        --                         ELSE SUM(aad.qtyShipped_each / NULLIF(bpdEA.qty, 0)) 
        --                     END
        --                 WHEN btd.ratebase = 'DO' THEN COUNT(DISTINCT doh.orderNo)
        --                 WHEN btd.ratebase = 'PALLET' THEN CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdPL.qty, 0)))
        --                 WHEN btd.ratebase = 'CASE' THEN CEIL(SUM(aad.qtyShipped_each / NULLIF(bpdCS.qty, 0)))
        --                 WHEN btd.ratebase = 'NETWEIGHT' THEN SUM(aad.qtyShipped_each * bs.netWeight)
        --                 WHEN btd.ratebase = 'GW' THEN 
        --                     CASE 
        --                         WHEN bpdEA.uomDescr IN ('G', 'GRAM', 'Gram') 
        --                         THEN SUM(aad.qtyShipped_each / 1000) 
        --                         WHEN bpdEA.uomDescr IN ('MT', 'Metric Ton', 'METRIC TON') 
        --                         THEN SUM(aad.qtyShipped_each * 1000) 
        --                         ELSE SUM(aad.qtyShipped_each * bs.grossWeight) 
        --                     END
        --                 WHEN btd.ratebase = 'MT' THEN 
        --                     CASE 
        --                         WHEN aad.customerId LIKE '%ABC%' 
        --                         THEN SUM((aad.qtyShipped_each * bpdCS.qty) / 1000) 
        --                         WHEN aad.customerId IN ('ADASBY', 'CAI_MDN', 'CAI_SBY') 
        --                         THEN IFNULL(CAST(SUM((aad.qtyShipped_each * bs.netweight) / 1000) AS CHAR(255)), 0) 
        --                         ELSE SUM(aad.qtyShipped_each / 1000) 
        --                     END
        --                 ELSE 0 
        --             END
        CEIL(SUM(aad.qty_each) / 4) AS qtyChargeBilling,

        -- Tariff details
        btr.rate,
        btd.ratebase,
        btr.tariffId,
        btr.tariffLineNo,
        btr.tariffClassNo,
        btd.chargeCategory,
        btd.chargeType,
        btd.descrC,
        btr.ratePerUnit,
        btd.minAmount,
        btd.maxAmount,
        IF(btd.UDF03 = '', 0, btd.UDF03) AS minQty,
        btd.UDF01,
        btd.udf02,
        btd.udf04,
        btd.UDF05,
        btd.UDF06,
        btd.UDF07,
        btd.UDF08,
        IFNULL(btd.incomeTaxRate, 0) AS IncomeTaxRate,
        '' classFrom,
        '' classTo,
        '' contractNo,
        btr.cost,
        '' billingParty,
        '' locationCategory
      FROM ACT_ALLOCATION_DETAILS aad
        -- All the joins from original query
        INNER JOIN DOC_ORDER_HEADER doh
          ON doh.organizationId = aad.organizationId
          AND doh.customerId = aad.customerId
          AND doh.orderNo = aad.orderNo
          AND doh.orderType NOT IN ('FREE', 'KT', 'TROF', 'TTG')
        LEFT JOIN DOC_ORDER_HEADER_UDF df
          ON doh.organizationId = df.organizationId
          AND doh.warehouseId = df.warehouseId
          AND doh.orderNo = df.orderNo
        INNER JOIN BAS_SKU bs
          ON bs.organizationId = aad.organizationId
          AND bs.SKU = aad.SKU
          AND bs.customerId = aad.customerId
          AND bs.skuDescr1 NOT LIKE '%PALLET%'
        INNER JOIN BAS_SKU_MULTIWAREHOUSE bsm
          ON bsm.organizationId = bs.organizationId
          AND bsm.SKU = bs.SKU
          AND bsm.customerId = bs.customerId
          AND bsm.warehouseId = aad.warehouseId
        LEFT JOIN INV_LOT_ATT ila
          ON ila.organizationId = aad.organizationId
          AND ila.SKU = aad.SKU
          AND ila.lotnum = aad.lotnum
          AND ila.customerId = aad.customerId
          AND (ila.lotAtt04 IS NULL
          OR ila.lotAtt04 != 'SET')
        LEFT JOIN BAS_PACKAGE_DETAILS bpdEA
          ON bpdEA.organizationId = bs.organizationId
          AND bpdEA.packId = bs.packId
          AND bpdEA.customerId = bs.customerId
          AND bpdEA.packUom = 'EA'
        LEFT JOIN BAS_PACKAGE_DETAILS bpdIP
          ON bpdIP.organizationId = bs.organizationId
          AND bpdIP.packId = bs.packId
          AND bpdIP.customerId = bs.customerId
          AND bpdIP.packUom = 'IP'
        LEFT JOIN BAS_PACKAGE_DETAILS bpdCS
          ON bpdCS.organizationId = bs.organizationId
          AND bpdCS.packId = bs.packId
          AND bpdCS.customerId = bs.customerId
          AND bpdCS.packUom = 'CS'
        LEFT JOIN BAS_PACKAGE_DETAILS bpdPL
          ON bpdPL.organizationId = bs.organizationId
          AND bpdPL.packId = bs.packId
          AND bpdPL.customerId = bs.customerId
          AND bpdPL.packUom = 'PL'
        LEFT JOIN BSM_CODE_ML t1
          ON t1.organizationId = 'OJV_CML'
          AND t1.codeType = 'SO_TYP'
          AND t1.codeId = doh.orderType
          AND t1.languageId = 'en'
        LEFT JOIN BSM_CODE BT
          ON BT.organizationId = 'OJV_CML'
          AND BT.codeType = 'BILLING_TRANSACTION_CATEGORY'
          AND BT.outerCode = ila.lotAtt07
        LEFT JOIN BAS_LOCATION bl
          ON bl.organizationId = aad.organizationId
          AND bl.warehouseId = aad.warehouseId
          AND bl.locationId = aad.location
        LEFT JOIN BAS_ZONE bz
          ON bz.organizationId = bl.organizationId
          AND bz.warehouseId = bl.warehouseId
          AND bz.zoneId = bl.zoneId
          AND bz.zoneGroup = bl.zoneGroup
        LEFT JOIN BIL_TARIFF_HEADER bth
          ON bth.organizationId = bsm.organizationId
          AND bth.tariffMasterId = bsm.tariffMasterId
        LEFT JOIN BIL_TARIFF_DETAILS btd
          ON btd.organizationId = bth.organizationId
          AND btd.tariffId = bth.tariffId
          AND btd.docType = doh.orderType
        LEFT JOIN BIL_TARIFF_RATE btr
          ON btr.organizationId = btd.organizationId
          AND btr.tariffId = btd.tariffId
          AND btr.tariffLineNo = btd.tariffLineNo
      WHERE aad.organizationId = 'OJV_CML'
      AND aad.warehouseId = 'CBT02-B2C'
      AND aad.customerId = 'ECMAMAB2C'

      AND aad.orderNo = 'MMCSO2508261053'
      AND aad.Status IN ('99', '80')
      AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
      AND btd.chargeCategory = 'OB'
      AND (
      btd.billingTranCategory IS NULL
      OR btd.billingTranCategory = ''
      OR btd.billingTranCategory = BT.codeid
      )
      AND btr.rate > 0
      AND NOT EXISTS (SELECT
          1
        FROM Z_SKUNOTBILLING zsnb
        WHERE zsnb.organizationId = aad.organizationId
        AND zsnb.customerId = aad.customerId
        AND zsnb.sku = aad.sku)
      GROUP BY doh.organizationId,
               doh.orderNo,
               doh.soReference1,
               doh.soReference3,
               --            t1.codeid,
               --            doh.soStatus,
               doh.orderType,
               doh.warehouseId,
               --            aad.orderLineNo,
               --            aad.traceId,
               --            aad.pickToTraceId,
               --            aad.dropId,
               aad.customerId,
               --            aad.location,
               --            aad.pickToLocation,
               doh.editTime,
               --            aad.allocationDetailsId,
               --            aad.SKU,
               --            aad.qty,
               --            aad.qty_each,
               --            aad.qtyShipped_each,
               --            aad.uom,
               --            aad.editTime,
               --            aad.lotNum,
               bsm.tariffMasterId,
               --            bs.skuDescr1,
               --            bs.grossWeight,
               --            bs.cube,
               --            t1.codeDescr,
               --            bz.zoneDescr,
               --            ila.lotAtt04,
               --            ila.lotAtt07,
               --            BT.codeid,
               --            df.closeTime,
               --            bs.netWeight,
               --            bpdEA.qty,
               --            bpdEA.uomDescr,
               --            bpdCS.qty,
               --            bpdIP.qty,
               --            bpdPL.qty,
               btr.rate,
               btd.ratebase,
               btr.tariffId,
               btr.tariffLineNo,
               btr.tariffClassNo,
               btd.chargeCategory,
               btd.chargeType,
               btd.descrC,
               btr.ratePerUnit,
               btd.minAmount,
               btd.maxAmount,
               btd.UDF03,
               btd.UDF01,
               btd.udf02,
               btd.udf04,
               btd.UDF05,
               btd.UDF06,
               btd.UDF07,
               btd.UDF08,
               btd.incomeTaxRate,
               bth.contractNo,
               bth.tariffMasterId,
               btr.cost,
               bl.locationCategory;