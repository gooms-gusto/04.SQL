        SELECT  btm.customerId,btd.* 
        FROM BIL_TARIFF_MASTER btm INNER JOIN
        BIL_TARIFF_HEADER bth ON btm.organizationId = bth.organizationId AND btm.tariffMasterId = bth.tariffMasterId
        LEFT JOIN BIL_TARIFF_DETAILS btd
            ON btd.organizationId = bth.organizationId
            AND btd.tariffId = bth.tariffId
        LEFT JOIN BIL_TARIFF_RATE btr
            ON btr.organizationId = btd.organizationId
            AND btr.tariffId = btd.tariffId
            AND btr.tariffLineNo = btd.tariffLineNo
  WHERE bth.organizationId = 'OJV_CML'
   AND btd.ratebase='LITER'
    AND bth.effectiveFrom <= DATE_FORMAT(CURDATE(), '%Y-%m-%d')
            AND bth.effectiveTo >= DATE_FORMAT(CURDATE(), '%Y-%m-%d')