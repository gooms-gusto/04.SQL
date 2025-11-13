SELECT SUM(TOT.TotalCharge)

  FROM (


SELECT
        aad.organizationId        ,
        aad.warehouseId           ,
        aad.customerId            ,
        aad.orderNo               ,
        aad.allocationDetailsId   ,
aad.lotNum,
        aad.tariffMasterId        ,
        aad.tariffId              ,
        aad.codeDescr                                                                    AS OrderType,
        CASE aad.lotAtt07 WHEN 'O' THEN 'Owner Pallet' WHEN 'R' THEN 'Rental Pallet' when 'PP' then 'Rental Plastic Pallet' when 'WP' then 'Rental Wooden Pallet' END AS RecType
        ,
        DATE_FORMAT(aad.lastshipmentTime, '%Y-%m-%d %T')   AS Shipdate                  ,
        DATE_FORMAT(h.appointmentStartTime, '%Y-%m-%d %T') AS TimeIn                    ,
        h.vehicleNo                                                                     ,
        aad.soReference1                                                                ,
        aad.sku                                                                         ,
        aad.skuDescr1                                                                   ,
        CASE aad.customerId          WHEN 'LTL'         THEN aad.ProfitCntr ELSE aad.sku_group1 END AS MU,
        CASE aad.customerId          WHEN 'ZAP'         THEN(
                                CASE WHEN aad.qtycs > 0 THEN aad.qty_each / aad.qtycs ELSE
                                                aad.qty_each END)                     ELSE
                        aad.qty_each                         END AS qtyshipped_EA,
        CASE aad.customerId          WHEN 'ZAP'         THEN(
                                CASE WHEN aad.qtycs > 0 THEN aad.uomdescrcs ELSE aad.uomdescrea END
                        )                                                   ELSE aad.uomdescrea END
                                 AS UOM_EA       ,
        case when aad.customerid in ('API','ADS') THEN (CASE WHEN aad.uomea='KG' THEN aad.qty_each WHEN aad.uomea='LT' THEN aad.qty_each ELSE (aad.qty_each*aad.sku_group6) END) ELSE (aad.qty_each / aad.qtycs) END AS qtyshipped_CS,
        case when aad.customerid in ('API','ADS') THEN 'LT' ELSE aad.uomdescrcs END          AS UOM_CS       ,
        CASE aad.customerId          WHEN 'ZAP'         THEN(
                                CASE WHEN aad.qtycs > 0 THEN aad.qtypl / aad.qtycs ELSE aad.qtypl
                                END)                                               ELSE aad.qtypl
                                END AS QtyPerpallet                             ,
        aad.traceId                                                             ,
        aad.pickToTraceId                                                       ,
        MID(aad.location, 1, 1) AS Area                                         ,
        aad.putawayDescr                                                        ,
        aad.location AS Location                                                ,
        aad.lotAtt04                                                            ,
        case when aad.customerid='MAP' then aad.cubesku else (CASE aad.cubeea WHEN 0 THEN aad.cubecs ELSE aad.cubeea END) end AS CBMSKU    ,
        CEIL(aad.qty_each / aad.qtypl)                             AS PalletUsed,
        case when aad.customerid='MAP' then (case when aad.lotAtt04='SET' then 0 else (aad.cubesku*aad.qty_each) end) else (
                CASE aad.customerId                                       WHEN 'ZAP'         THEN(
                                        CASE                              WHEN aad.qtycs > 0 THEN aad.qty_each / aad.qtycs ELSE
                                                        aad.qty_each END) WHEN 'YFI'         THEN
                                aad.qty_each / aad.qtycs                  WHEN 'UEI'         THEN
                                aad.qty_each / aad.qtycs ELSE aad.qty_each END) *(
                CASE aad.cubeea WHEN 0 THEN aad.cubecs   ELSE aad.cubeea   END)  end  AS QtyCBM         ,
        aad.rate                                                                        AS CHARGE_VALUE   ,
				case when aad.tariffMasterId='BIL00062' THEN (case when aad.lotAtt04='SET' then 0 else (aad.cubesku*aad.qty_each *  aad.rate ) end) 
				when aad.tariffMasterId='BIL00062PIECES' THEN (case when aad.lotAtt04='SET' then 0 else (aad.qty_each *  aad.rate ) end) ELSE 0 END as TotalCharge,
        ' '                                                                        AS OVERTIME_CHARGE,
        ' '                                                                        AS STANDYBY_FEE   ,
        CASE aad.customerId WHEN 'PLB-LTL' THEN aad.lotAtt10 ELSE aad.lotAtt09 END AS EXTPO          ,
        aad.consigneeId                                                                              ,
        aad.consigneeName                                                                            ,
        h.carrierName                                                                                ,
        aad.udf02 AS MatdocSAP,aad.sku_group3 as SKU_GROUP3
FROM
        (
                
                SELECT
                        aad.organizationId       ,
                        aad.warehouseId          ,
                        aad.customerId           ,
                        aad.orderNo              ,
                  aad.lotNum,
                        aad.allocationDetailsId  ,
											  E.rate,
                        C.tariffMasterId     ,
                        C.tariffId           ,
                        case when aad.customerid='MAP' and bcm.codeDescr='Inter-warehouse transfer' then   'Shipment Order' else bcm.codeDescr end as    codeDescr       ,
                        ila.lotAtt07             ,
                        ila.lotAtt04             ,
                        ila.lotAtt09             ,
                        ila.lotAtt10             ,
                        doh.lastshipmentTime     ,
                        doh.soReference1         ,
                        aad.sku                  ,
                        bs.skuDescr1             ,
bs.sku_group3,
                        l.ProfitCntr             ,
                        bs.sku_group1            ,
                        case when cs.qty=0 then 1 else cs.qty end AS qtycs          ,
                        ea.qty AS qtyea          ,
                        pl.qty AS qtypl          ,
                        aad.qty_each             ,
                        cs.uomdescr AS uomdescrcs,
                        ea.uomdescr AS uomdescrea,
                        pl.uomdescr AS uomdescrpl,
                        aad.traceId              ,
                        aad.pickToTraceId        ,
                        aad.location             ,
                        rph.putawayDescr         ,
                        ea.cube AS cubeea        ,
                        cs.cube AS cubecs        ,
bs.cube AS cubesku        ,
                        doh.consigneeId          ,
                        doh.consigneeName        ,
                        doh.udf02,
ea.uomdescr as uomea,
bs.sku_group6 as sku_group6
                FROM
                        ACT_ALLOCATION_DETAILS aad
                LEFT OUTER JOIN INV_LOT_ATT ila
                ON
                        aad.organizationId = ila.organizationId
                        AND aad.lotNum     = ila.lotNum
                LEFT JOIN DOC_ORDER_HEADER doh
                ON
                        aad.organizationId  = doh.organizationId
                        AND aad.warehouseId = doh.warehouseId
                        AND aad.orderNo     = doh.orderNo
                LEFT JOIN BAS_SKU bs
                ON
                        aad.organizationId = bs.organizationId
                        AND aad.customerId = bs.customerId
                        AND aad.sku        = bs.sku
                LEFT OUTER JOIN
                        (
                                
                                SELECT * FROM BSM_CODE_ML WHERE codeType = 'SO_TYP' AND languageId
                                        = 'en'
                        )
                        bcm
                ON
                        doh.organizationId = bcm.organizationId
                        AND doh.orderType  = bcm.codeid
                LEFT OUTER JOIN
                        (
                                
                                SELECT * FROM BAS_PACKAGE_DETAILS WHERE packUom = 'EA'
                        )
                        ea
                ON
                        aad.organizationId = ea.organizationId
                        AND aad.packId     = ea.packId
                        AND aad.customerId = ea.customerId
                LEFT OUTER JOIN
                        (
                                
                                SELECT * FROM BAS_PACKAGE_DETAILS WHERE packUom = 'PL'
                        )
                        pl
                ON
                        aad.organizationId = pl.organizationId
                        AND aad.packId     = pl.packId
                        AND aad.customerId = pl.customerId
                LEFT OUTER JOIN
                        (
                                
                                SELECT * FROM BAS_PACKAGE_DETAILS WHERE packUom = 'CS'
                        )
                        cs
                ON
                        aad.organizationId = cs.organizationId
                        AND aad.packId     = cs.packId
                        AND aad.customerId = cs.customerId
                LEFT JOIN BAS_SKU_MULTIWAREHOUSE skumw
                ON
                        aad.organizationId  = skumw.organizationId
                        AND aad.warehouseId = skumw.warehouseId
                        AND aad.sku         = skumw.sku
                        AND aad.customerId  = skumw.customerId
                LEFT JOIN RUL_PUTAWAY_HEADER rph
                ON
                        rph.organizationId  = skumw.organizationId
                        AND rph.warehouseId = skumw.warehouseId
                        AND rph.putawayId   = skumw.putawayRule
												LEFT JOIN BIL_TARIFF_HEADER C
												 ON C.ORGANIZATIONID = skumw.ORGANIZATIONID 
												 AND C.tariffMasterId=skumw.tariffMasterId
												 LEFT JOIN BIL_TARIFF_DETAILS D 
      ON D.ORGANIZATIONID = C.ORGANIZATIONID 
      AND D.tariffId =C.tariffId
     AND D.CHARGECATEGORY = 'OB' 
     AND D.docType=doh.orderType
   --  AND D.RATEBASE = 'CUBIC' 
    LEFT JOIN BIL_TARIFF_RATE E 
      ON E.ORGANIZATIONID = D.ORGANIZATIONID 
      AND E.TARIFFID = D.TARIFFID 
      AND E.TARIFFLINENO = D.TARIFFLINENO
                LEFT OUTER JOIN cmlwms_archivedb.MUIDMAPPING l
                ON
                        aad.organizationId  = l.organizationId
                        AND aad.warehouseId = l.warehouseId
                        AND CONCAT(
                                CASE WHEN doh.Udf06  IS NULL THEN '' ELSE doh.Udf06  END,
                                CASE WHEN doh.HEDI08 IS NULL THEN '' ELSE doh.HEDI08 END) = l.B00
                WHERE
                        1                      = 1
                        AND aad.organizationId = 'OJV_CML'
                        AND aad.warehouseId    = 'CBT01'
                        AND doh.soStatus       in ( '99','80')
												AND doh.orderNo in ('MAPSO000000696')
                        AND doh.orderType NOT IN('FREE', 'KT')
                        AND aad.SKU NOT       IN('YFI001')
                        AND bs.skuDescr1 NOT LIKE '%PALLET%'
                    --    AND skumw.tariffMasterId                 = '${tariffMasterId}'
                        AND aad.customerId                       = 'MAP'
                     --   AND CONVERT(doh.lastshipmentTime, DATE) >= '${ShipdateFM}'
                     --   AND CONVERT(doh.lastshipmentTime, DATE) <= '${ShipdateTO}'
        )
        aad
LEFT JOIN ZCBT01_SHIPMENT_TRUCK_NEW4 h
ON
        aad.organizationId  = h.organizationId
        AND aad.warehouseId = h.warehouseId
        AND aad.orderNo     = h.orderNo
LEFT JOIN DOC_LOADING_DETAILS dld
ON
        dld.organizationId          = aad.organizationId
        AND dld.warehouseId         = aad.warehouseId
        AND dld.orderNo             = aad.orderNo
        AND dld.allocationDetailsId = aad.allocationDetailsId
        AND dld.ldlNo               = h.ldlNo
GROUP BY
        aad.organizationId     ,
        aad.warehouseId        ,
        aad.customerId         ,
        aad.orderNo            ,
  aad.lotNum,
        aad.allocationDetailsId,
				aad.tariffId              ,
        aad.tariffMasterId     ,
				aad.rate,
        aad.codeDescr          ,
        h.appointmentStartTime ,
        h.vehicleNo            ,
        aad.ProfitCntr         ,
        h.carrierName
ORDER BY
        aad.orderNo ASC           ,
        h.appointmentStartTime ASC,
        aad.lastshipmentTime ASC  ,
        h.vehicleNo ASC ) TOT