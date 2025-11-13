SELECT
               bc.customerId,DATE_FORMAT(bth.billingDate,"%Y-%m-%d") AS FIRSTBILLINGDATE,
               DATE_FORMAT(CONCAT(YEAR(NOW()),'-', MONTH(NOW()),'-',CASE WHEN DAY(bth.billingDate)=31 THEN 30 ELSE DAY(bth.billingDate) END ),"%Y-%m-%d")  AS CURRENT_FM_BILLINGDATE,
               DATE_ADD(DATE_ADD(DATE_FORMAT(CONCAT(YEAR(NOW()),'-', MONTH(NOW()),'-',CASE WHEN DAY(bth.billingDate)=31 THEN 30 ELSE DAY(bth.billingDate) END ),"%Y-%m-%d"), INTERVAL 1 MONTH),INTERVAL -1 DAY)  AS CURRENT_TO_BILLINGDATE,
                DATE_FORMAT(bth.effectiveFrom,"%Y-%m-%d") AS EFECTIVE_FMDATE,
                DATE_FORMAT(bth.effectiveTo,"%Y-%m-%d") AS EFECTIVE_TODATE
                FROM BIL_TARIFF_MASTER btm
               INNER JOIN BAS_CUSTOMER bc
                ON bc.customerId = btm.customerId
                AND bc.organizationId = btm.organizationId
                AND bc.CustomerType = 'OW'
              INNER JOIN BIL_TARIFF_HEADER bth
                ON bth.organizationId = btm.organizationId
                AND bth.tariffMasterId = btm.tariffMasterId
              INNER JOIN BIL_TARIFF_DETAILS btd
                ON btd.organizationId = bth.organizationId
                AND btd.tariffId = bth.tariffId
              INNER JOIN BIL_TARIFF_RATE btr
                ON btr.organizationId = btd.organizationId
                AND btr.tariffId = btd.tariffId
                AND btr.tariffLineNo = btd.tariffLineNo
              WHERE bc.organizationId = 'OJV_CML'
              AND bc.customerType = 'OW'
              AND bc.activeFlag='Y'
            --  AND bc.customerId IN ('ITOCHU')   -- SELECT bc.customerId FROM BAS_CUSTOMER bc WHERE bc.activeFlag='Y' AND bc.customerType='OW')
              AND DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 7 HOUR)- interval 1 DAY,"%Y-%m-%d") between DATE_FORMAT(DATE(bth.effectiveFrom),"%Y-%m-%d") and DATE_FORMAT(DATE(bth.effectiveTo),"%Y-%m-%d")
              AND btd.chargeCategory = 'IV'
              AND btd.chargeType='ST'
              AND btr.rate > 0
              GROUP BY 
                       bc.customerId,bth.billingDate,bth.effectiveFrom,bth.effectiveto
                      