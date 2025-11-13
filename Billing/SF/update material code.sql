SELECT h1.productCode AS CODEID,bcm.codeDescr AS CODETEXT FROM BIL_CRM_DETAILS h1 INNER JOIN BSM_CODE_ML bcm ON h1.organizationId = bcm.organizationId AND bcm.codeType='MAT_COD' AND bcm.codeid=h1.ProductCode AND bcm.languageId='en'
 WHERE h1.opportunityId =
                        (
                                
                                SELECT
                                        KA.opportunityId
                                FROM
                                        BIL_TARIFF_HEADER KA
                                WHERE
                                        KA.organizationId = 'OJV_CML'
                                        AND KA.tariffId   = 'BIL00486' LIMIT 1
                        )


SELECT * FROM BIL_CRM_DETAILS WHERE OpportunityId='0062w00000NguxKAAR';

UPDATE BIL_CRM_DETAILS bc INNER JOIN BSM_CODE_ML bcm ON bc.organizationId = bcm.organizationId AND bcm.codeType='MAT_COD' AND bcm.languageId='en'AND bcm.codeid=bc.ProductCode
SET bc.ProductDescr=bcm.codeDescr
WHERE bc.OpportunityId='0062w00000NguxLAAR'