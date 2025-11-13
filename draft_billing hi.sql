 SELECT
   dah.organizationId,
    dah.asnReference1 ,
    dah.asnReference3,
    dad.skuDescr,
    atl.warehouseId,
    atl.tocustomerId,
    atl.docNo,
    atl.docLineNo,
    atl.toSku,
    atl.toQty,
    atl.toUom,
    atl.toQty_Each,
        -- Gross weight calculation
            CASE 
                WHEN bpdEA.uomDescr IN ('G', 'GRAM', 'Gram') 
                THEN SUM(atl.toQty_Each / 1000) 
                WHEN bpdEA.uomDescr IN ('MT', 'Metric Ton', 'METRIC TON') 
                THEN SUM(atl.toQty_Each * 1000) 
                ELSE SUM(atl.toQty_Each * bs.grossWeight) 
            END AS qtyChargeGrossWeight,
            
            -- Metric ton calculation
            CASE 
                WHEN atl.toCustomerId LIKE '%ABC%' 
                THEN SUM((atl.toQty_Each * bpdCS.qty) / 1000) 
                WHEN atl.toCustomerId IN ('ADASBY', 'CAI_MDN', 'CAI_SBY') 
                THEN IFNULL(CAST(SUM((atl.toQty_Each * bs.netweight) / 1000) AS CHAR(255)), 0) 
                ELSE SUM(atl.toQty_Each / 1000) 
            END AS qtyChargeMetricTon,
            
            
            -- Calculate billing quantity based on rate base
            CASE 
                WHEN btd.ratebase = 'CUBIC' THEN SUM(atl.toQty_Each * bs.cube)
                WHEN btd.ratebase = 'M2' THEN 
                    CASE 
                        WHEN atl.tocustomerId = 'MAP' 
                            AND ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') 
                            AND bsm.tariffMasterId LIKE '%PIECE%' 
                        THEN SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0)) 
                        ELSE SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0)) 
                    END
                WHEN btd.ratebase = 'IP' THEN COALESCE(CEIL(SUM(atl.toQty_Each / NULLIF(bpdIP.qty, 0))), 1)
                WHEN btd.ratebase = 'KG' THEN 
                    CASE 
                        WHEN atl.tocustomerId = 'MAP' 
                            AND ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') 
                            AND bsm.tariffMasterId LIKE '%PIECE%' 
                        THEN SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0)) 
                        ELSE SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0)) 
                    END
                WHEN btd.ratebase = 'LITER' THEN 
                    CASE 
                        WHEN atl.tocustomerId = 'MAP' 
                            AND ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') 
                            AND bsm.tariffMasterId LIKE '%PIECE%' 
                        THEN SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0)) 
                        ELSE SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0)) 
                    END
                WHEN btd.ratebase = 'QUANTITY' THEN 
                    CASE 
                        WHEN atl.tocustomerId = 'MAP' 
                            AND ila.lotAtt04 IN ('SETA', 'SET A', 'SET_A', 'SET-A', 'NONSET', 'NON SET', 'NON_SET', 'NON-SET') 
                            AND bsm.tariffMasterId LIKE '%PIECE%' 
                        THEN SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0)) 
                        ELSE SUM(atl.toQty_Each / NULLIF(bpdEA.qty, 0)) 
                    END
                WHEN btd.ratebase = 'DO' THEN COUNT(DISTINCT dah.asnNo)
                WHEN btd.ratebase = 'PALLET' THEN CEIL(SUM(atl.toQty_Each / NULLIF(bpdPL.qty, 0)))
                WHEN btd.ratebase = 'CASE' THEN CEIL(SUM(atl.toQty_Each / NULLIF(bpdCS.qty, 0)))
                WHEN btd.ratebase = 'NETWEIGHT' THEN SUM(atl.toQty_Each * bs.netWeight)
                WHEN btd.ratebase = 'GW' THEN 
                    CASE 
                        WHEN bpdEA.uomDescr IN ('G', 'GRAM', 'Gram') 
                        THEN SUM(atl.toQty_Each / 1000) 
                        WHEN bpdEA.uomDescr IN ('MT', 'Metric Ton', 'METRIC TON') 
                        THEN SUM(atl.toQty_Each * 1000) 
                        ELSE SUM(atl.toQty_Each * bs.grossWeight) 
                    END
                WHEN btd.ratebase = 'MT' THEN 
                    CASE 
                        WHEN atl.tocustomerId LIKE '%ABC%' 
                        THEN SUM((atl.toQty_Each * bpdCS.qty) / 1000) 
                        WHEN atl.tocustomerId IN ('ADASBY', 'CAI_MDN', 'CAI_SBY') 
                        THEN IFNULL(CAST(SUM((atl.toQty_Each * bs.netweight) / 1000) AS CHAR(255)), 0) 
                        ELSE SUM(atl.toQty_Each / 1000) 
                    END
                ELSE 0 
            END AS qtyChargeBilling,
    atl.docNo AS qtyChargeTotDO,
    COUNT(atl.docLineNo) AS qtyChargeTotLine,
    SUM(bs.cube) AS totalCube,
    DATE_FORMAT(atl.addTime, '%Y-%m-%d') AS addTime,
    DATE_FORMAT(atl.editTime, '%Y-%m-%d') AS editTime,
    DATE_FORMAT(atl.transactionTime, '%Y-%m-%d') AS transactionTime,
    atl.tolotNum AS lotNum,
    atl.toId AS traceId,
    atl.tomuid AS muid,
    atl.toLocation AS toLocation,
    t1.codeid AS docType,
    t1.codeDescr AS docTypeDescr,
    bpdCS.packId AS packId,
    bpdCS.qty AS  QtyPerCases,
    bpdPL.qty AS  QtyPerPallet,
    bs.sku_group1 AS sku_group1,
    bs.grossWeight AS grossWeight,
    bs.cube,
    bsm.tariffMasterId  AS tariffMasterId,
    bz.zoneDescr AS zone,
    ila.lotAtt04 AS batch,
    ila.lotAtt07 AS lotAtt07,
    BT.codeid billtranctg,
    IFNULL(CAST(SUM(atl.toQty_Each * bs.netWeight) AS char(255)), 0) AS qtyChargeNettWeight,/*additional nettweight grossweight*/
    CASE WHEN bpdEA.uomDescr IN ('G', 'GRAM', 'Gram') THEN IFNULL(CAST(SUM(atl.toQty_Each / 1000) AS char(255)), 0) 
    WHEN bpdEA.uomDescr IN ('MT', 'Metric Ton', 'METRIC TON') THEN IFNULL(CAST(SUM(atl.toQty_Each * 1000) AS char(255)), 0) 
    ELSE IFNULL(CAST(SUM(atl.toQty_Each * bs.grossWeight) AS char(255)), 0) END AS qtyChargeGrossWeight,
    CASE WHEN atl.tocustomerId LIKE '%ABC%' THEN IFNULL(CAST(SUM((atl.toQty_Each * bpdCS.qty) / 1000) AS char(255)), 0) 
    when atl.tocustomerId in ('ADASBY','CAI_MDN','CAI_SBY') THEN IFNULL(CAST(SUM((atl.toQty_Each * bs.netweight) / 1000) AS char(255)), 0)
    ELSE IFNULL(CAST(SUM(atl.toQty_Each / 1000) AS char(255)), 0) END AS qtyChargeMetricTon,
    daf.closeTime,
    atl.transactionId, -- add transaction line
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
            CASE WHEN chargeType = 'ES' THEN IFNULL(btr.classfrom, 0) - 1 ELSE IFNULL(btr.classfrom, 0) END AS classFrom,
            IFNULL(classTo, 0) AS classTo,
            bth.contractNo,
            btr.cost,
            btd.billingParty,
            bl.locationCategory
  FROM ACT_TRANSACTION_LOG atl
    LEFT OUTER JOIN BAS_SKU bs
      ON bs.organizationId = atl.organizationId
      AND bs.customerId = atl.toCustomerId
      AND bs.SKU = atl.toSku
    LEFT OUTER JOIN BAS_SKU_MULTIWAREHOUSE bsm
      ON bsm.organizationId = atl.organizationId
      AND bsm.warehouseId = atl.warehouseId
      AND bsm.customerId = atl.tocustomerId
      AND bsm.SKU = atl.toSku
    LEFT OUTER JOIN DOC_ASN_HEADER dah
      ON dah.organizationId = atl.organizationId
      AND dah.warehouseId = atl.warehouseId
      AND dah.asnNo = atl.docNo
      AND dah.customerId = atl.fmCustomerId
    LEFT JOIN DOC_ASN_HEADER_UDF daf
      ON dah.organizationId = daf.organizationId
      AND dah.warehouseId = daf.warehouseId
      AND dah.asnNo = daf.asnNo
    LEFT OUTER JOIN DOC_ASN_DETAILS dad
      ON dad.organizationId = atl.organizationId
      AND dad.warehouseId = atl.warehouseId
      AND dad.asnNo = atl.docNo
      AND dad.asnLineNo = atl.docLineNo
      AND dad.sku = atl.toSku
    LEFT OUTER JOIN INV_LOT_ATT ila
      ON ila.organizationId = atl.organizationId
      AND ila.customerId = atl.toCustomerId
      AND ila.SKU = atl.toSku
      AND ila.lotNum = atl.toLotNum
    LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdEA
      ON bpdEA.organizationId = bs.organizationId
      AND bpdEA.packId = bs.packId
      AND bpdEA.customerId = bs.customerId
      AND bpdEA.packUom = 'EA'
    LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdIP
      ON bpdIP.organizationId = bs.organizationId
      AND bpdIP.packId = bs.packId
      AND bpdIP.customerId = bs.customerId
      AND bpdIP.packUom = 'IP'
    LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdCS
      ON bpdCS.organizationId = bs.organizationId
      AND bpdCS.packId = bs.packId
      AND bpdCS.customerId = bs.customerId
      AND bpdCS.packUom = 'CS'
    LEFT OUTER JOIN BAS_PACKAGE_DETAILS bpdPL
      ON bpdPL.organizationId = bs.organizationId
      AND bpdPL.packId = bs.packId
      AND bpdPL.customerId = bs.customerId
      AND bpdPL.packUom = 'PL'
    LEFT JOIN BSM_CODE_ML t1
      ON t1.organizationId = atl.organizationId
      AND t1.codeType = 'ASN_TYP'
      AND dah.asnType = t1.codeId
      AND t1.languageId = 'en'
    LEFT JOIN BSM_CODE BT
      ON BT.organizationId = atl.organizationId
      AND BT.codeType = 'BILLING_TRANSACTION_CATEGORY'
      AND BT.outerCode = ila.lotAtt07
    LEFT JOIN BAS_LOCATION bl
      ON bl.organizationId = atl.organizationId
      AND bl.warehouseId = atl.warehouseId
      AND bl.locationId = atl.toLocation
    LEFT JOIN BAS_ZONE bz
      ON bz.organizationId = bl.organizationId
      AND bz.organizationId = bl.organizationId
      AND bz.warehouseId = bl.warehouseId
      AND bz.zoneId = bl.zoneId
      AND bz.zoneGroup = bl.zoneGroup
    LEFT JOIN BIL_TARIFF_HEADER bth
            ON bth.organizationId = bsm.organizationId
            AND bth.tariffMasterId = bsm.tariffMasterId
        LEFT JOIN BIL_TARIFF_DETAILS btd
            ON btd.organizationId = bth.organizationId
            AND btd.tariffId = bth.tariffId
            AND btd.docType =dah.asnType
        LEFT JOIN BIL_TARIFF_RATE btr
            ON btr.organizationId = btd.organizationId
            AND btr.tariffId = btd.tariffId
            AND btr.tariffLineNo = btd.tariffLineNo
  WHERE atl.organizationId = 'OJV_CML'
  AND atl.warehouseId = 'CBT01'
  AND dah.customerId = 'LTL'
  AND dah.asnNo='P000018311'
  AND COALESCE(ila.lotAtt04, '') NOT IN ('SET') /*AL validate batch*/
  AND atl.transactionType = 'IN'
  AND dah.asnType NOT IN ('FREE', 'IU', 'TTG')
  AND dad.skuDescr NOT LIKE '%PALLET%'
    AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
            AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
            AND btd.chargeCategory = 'IB'
            AND (
                    btd.billingTranCategory IS NULL 
                    OR btd.billingTranCategory = '' 
                    OR btd.billingTranCategory = BT.codeid
                )
            AND btr.rate > 0
            AND NOT EXISTS (
                SELECT 1
                FROM Z_SKUNOTBILLING zsnb
                WHERE zsnb.organizationId = 'OJV_CML'
                    AND zsnb.customerId = dah.customerId
                    AND zsnb.sku = atl.toSku
            )
  AND atl.toSku NOT IN (SELECT
      sku
    FROM Z_SKUNOTBILLING zsnb
    WHERE organizationId = atl.organizationId
    AND customerId = atl.toCustomerId)
  AND atl.STATUS IN ('80', '99')
  AND dah.asnStatus IN ('99')
  GROUP BY atl.docNo,
           atl.docLineNo,
           atl.toCustomerId,
           atl.toSku,
           atl.toQty,
           atl.toQty_Each,
           atl.toUom,
           atl.addTime,
           atl.transactionTime,
           atl.toLotNum,
           atl.toId,
           atl.tomuid,
           atl.toLocation,
           atl.warehouseId,
           atl.tocustomerId,
           atl.transactionId,
           atl.editTime,
           dah.organizationId,
           dah.asnNo,
           dah.asnType,
           dah.asnReference1,
           dah.asnReference3,
           dah.asnReference1,
           dad.SkuDescr,
           bsm.tariffMasterId,
           bs.grossWeight,
           bs.cube,
           bs.sku_group1,
           bz.zoneDescr,
           bpdCS.packId,
           bpdPL.packId,
           bpdCS.qty,
           bpdPL.qty,
           ila.lotAtt04,
           ila.lotAtt07,
           t1.codeid,
           BT.codeid, btr.rate, btd.ratebase, btr.tariffId, btr.tariffLineNo,
            btr.tariffClassNo, btd.chargeCategory, btd.chargeType,
            btd.descrC, btr.ratePerUnit, btd.minAmount, btd.maxAmount,
            btd.UDF03, btd.UDF01, btd.udf02, btd.udf04, btd.UDF05,
            btd.UDF06, btd.UDF07, btd.UDF08, btd.incomeTaxRate,
            bth.contractNo, bth.tariffMasterId, btr.cost, bl.locationCategory;