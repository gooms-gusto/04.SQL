SELECT
        DOH.organizationId AS ORGANIZATIONID                   ,
        DOH.warehouseId AS  CUCUSTOMERID_WH                    ,
        DOH.customerId AS CUSTOMERID                    ,
        DOH.soReference1 AS SOREFERENCE1                     ,
        DOH.orderNo as ORDERNO                          ,
         AD.ORDERLINENO                      ,
         DOH.consigneeId AS  CONSIGNEECODE                    ,
         DOH.consigneeName CONSIGNEENAME                    ,
         DOH.consigneeAddress1 AS CONSIGNEEADDRESS                 ,
         DOH.consigneeCity  CONSIGNEE_CITY                   ,
         DOH.consigneeZip  CONSIGNEE_ZIP                    ,
         AD.CONSIGNEE_STATE                  ,
         AD.CONSIGNEE_CONT                   ,
         AD.STATUS_KOTA                      ,
         DED.SKU                              ,
         AD.SKUDESCR                         ,
         AD.PICKQTYEA    ,
        -- add akbar Konversi UOM Order 26.01.23 03.54am
         CASE WHEN DED.packUom='EA' THEN AD.PICKQTYEA
        ELSE AD.PICKQTYEA / PACKOD.qty END AS  QTYPICKUOMORDER,
         DED.QTYORDERED AS QTYORDERED,
         PACKOD.UOMDESCR AS UOMORDER,
         DED.udf03 AS BARCODEORDER                          ,
         AD.NOTETEXT                         ,
         AD.PACKID                           ,
         AD.BILADDR1                         ,
        DOH.ORDERTIME                      ,
         AD.SJPRINT_FLAG,
  STS.STATUSPRINT
FROM DOC_ORDER_DETAILS DED INNER JOIN   DOC_ORDER_HEADER DOH ON 
  (DED.organizationId = DOH.organizationId AND
  DED.warehouseId = DOH.warehouseId AND
  DED.customerId = DOH.customerId AND 
  DED.orderNo = DOH.orderNo ) 
  INNER JOIN   
        (
                
              SELECT
                        h2.organizationId                                                 AS ORGANIZATIONID,
                        h2.warehouseId                                                    AS CUSTOMERID_WH ,
                        h2.customerId                                                     AS CUSTOMERID_OW ,
                        h2.orderNo           AS ORDERNO         ,
                        h2.orderLineNo       AS ORDERLINENO     ,
                        h3.consigneeId       AS CONSIGNEECODE   ,
                        h3.consigneeName     AS CONSIGNEENAME   ,
                        h3.consigneeAddress1 AS CONSIGNEEADDRESS,
                        co.city              AS CONSIGNEE_CITY  ,
                        co.zipCode           AS CONSIGNEE_ZIP   ,
                        co.province          AS CONSIGNEE_STATE ,
                        co.contact1          AS CONSIGNEE_CONT  ,
                        CASE WHEN co.udf01 = 'DK' THEN 'Dalam Kota' WHEN co.udf01 = 'LK' THEN
                                        'Luar Kota' END AS STATUS_KOTA,
                        h2.sku                          AS SKU        ,
                        sku.skuDescr1                   AS SKUDESCR   ,
                        SUM(h2.qtyPicked_each)                AS PICKQTYEA  ,
                        ROUND(SUM(h2.qty * sku.cube), 6)                                    AS CUBIC_TOTAL ,
                        h3.noteText                                                         AS NOTETEXT    ,
                        sku.packId                                                          AS PACKID      ,
                        h3.billingAddress1                                                  AS BILADDR1    ,
                      --  h3.ORDERTIME                                                        AS ORDERTIME   ,
                        CASE WHEN h3.deliveryNoteprintFlag = 'N' THEN '' ELSE 'Reprint' END AS
                        SJPRINT_FLAG
                FROM
                        ACT_ALLOCATION_DETAILS h2
                LEFT  JOIN DOC_ORDER_HEADER h3
                ON
                        h2.organizationId  = h3.organizationId
                        AND h2.warehouseId = h3.warehouseId
                        AND h2.orderNo     = h3.orderNo
                         AND h2.qtyPicked_each > 0

                LEFT  JOIN BAS_SKU sku
                ON
                        sku.organizationId = h2.organizationId
                        AND sku.sku        = h2.sku
                        AND sku.customerId = h2.customerId
                
                LEFT  JOIN INV_LOT_ATT la
                ON
                        h2.organizationId = la.organizationId
                        AND h2.lotNum     = la.lotNum
                        AND h2.customerId = la.customerId
                        AND la.sku        = h2.sku
                LEFT  JOIN BAS_CUSTOMER co
                ON
                        (co.customerId = h3.consigneeId AND co.customerType = 'CO' )
                WHERE    h2.warehouseId='PAPAYA'  AND h2.customerId='PAPAYA' AND h2.orderNo ='PSO202301260073'
                GROUP BY
                        h2.organizationId   ,
                        h2.warehouseId      ,
                        h2.customerId       ,
                        h3.soReference1     ,
                        h2.orderNo          ,
                        h2.orderLineNo      ,
                        h3.consigneeId      ,
                        co.customerDescr1   ,
                        co.address1         ,
                        co.city             ,
                        co.zipCode          ,
                        co.province         ,
                        co.contact1         ,
                        co.udf01            ,
                        h2.sku              ,
                        sku.skuDescr1       ,    
                        h3.noteText         ,
                        sku.packId          ,
                        h3.consigneeName    ,
                        h3.consigneeAddress1,
                        billingAddress1,
                         h3.deliveryNoteprintFlag
                ORDER BY
                        h2.orderNo    ,
                        h2.orderLineNo 
        )
        AD ON  (
    DED.organizationId  = AD.ORGANIZATIONID
                        AND DED.warehouseId = AD.CUSTOMERID_WH
                        AND DED.sku         = AD.SKU
                        AND DED.orderNo     = AD.ORDERNO
                        AND DED.orderLineNo = AD.ORDERLINENO
                        AND DED.customerid  = AD.CUSTOMERID_OW)
      LEFT  JOIN BAS_PACKAGE_DETAILS PACKOD   ON (DED.organizationId = PACKOD.organizationId
                    AND DED.customerId = PACKOD.customerId
                    AND DED.packId = PACKOD.packId
                    AND DED.packUom =PACKOD.packUom) INNER JOIN (SELECT CASE WHEN COUNT(1) > 0 THEN 'MASIH ADA QTY ALLOCATE' ELSE '' END AS STATUSPRINT,aad.orderNo FROM ACT_ALLOCATION_DETAILS aad
                      WHERE aad.warehouseId='PAPAYA' AND aad.customerId='PAPAYA' AND  aad.orderNo='PSO202301260073' AND aad.qtyPicked_each=0) STS
  ON (AD.ORDERNO=STS.orderNo)
    WHERE DED.warehouseId='PAPAYA' AND DED.customerId='PAPAYA' AND  DOH.orderNo='PSO202301260073' 
GROUP BY
         DOH.organizationId  ,
          DOH.warehouseId   ,
         DED.customerId   ,
         DOH.soReference1,
         DOH.orderNo         ,
         AD.ORDERLINENO     ,
         AD.CONSIGNEECODE   ,
         AD.CONSIGNEENAME   ,
         AD.CONSIGNEEADDRESS,
         AD.CONSIGNEE_CITY  ,
         AD.CONSIGNEE_ZIP   ,
         AD.CONSIGNEE_STATE ,
         AD.CONSIGNEE_CONT  ,
         AD.STATUS_KOTA     ,
         DED.SKU            ,
         AD.SKUDESCR        ,
   AD.PICKQTYEA ,
   CASE WHEN DED.packUom='EA' THEN AD.PICKQTYEA
        ELSE AD.PICKQTYEA / PACKOD.qty END,
  DED.QTYORDERED,
   PACKOD.UOMDESCR,
         AD.NOTETEXT        ,
         AD.PACKID          ,
         AD.BILADDR1        ,
   AD.SJPRINT_FLAG,
  DOH.ORDERTIME                ,
   DED.udf03      
ORDER BY
        DOH.orderNo,
  AD.ORDERLINENO,
        DED.SKU ASC;


  -- SELECT * FROM DOC_ORDER_DETAILS dod WHERE dod.orderNo='SO202301180040';

   -- SELECT * FROM wms_cml.ACT_ALLOCATION_DETAILS aad WHERE aad.warehouseId='PAPAYA' AND aad.customerId='PAPAYA'
   --   AND aad.orderNo='PSO202301260073'

