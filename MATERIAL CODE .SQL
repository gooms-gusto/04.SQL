SELECT h1.productCode AS CODEID, h1.productDescr AS CODETEXT FROM BIL_CRM_DETAILS h1


SELECT h1.productCode AS CODEID, h1.productDescr AS CODETEXT FROM BIL_CRM_DETAILS h1
 WHERE h1.opportunityId =
                        (
                                
                                SELECT
                                        KA.opportunityId
                                FROM
                                        BIL_TARIFF_HEADER KA
                                WHERE
                                        KA.organizationId = '@{bizOrgId}'
                                        AND KA.tariffId   = '${tariffId}' LIMIT 1
                        )