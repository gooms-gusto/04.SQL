SELECT * FROM BSM_USER  WHERE userId not IN( 
SELECT DISTINCT userId FROM BSM_USER_LOGINOK WHERE loginTime BETWEEN '2025-01-01 00:00:00' AND '2026-12-29 00:00:00');

SELECT * FROM Z_LogUdfTran;



SELECT * FROM BIL_TARIFF_HEADER bth WHERE bth.tariffId='BIL00702';


SELECT * FROM BIL_CRM_HEADER bch WHERE bch.CustomerId='3000017758';


SELECT DISTINCT
        h1.CustomerId     AS CODEID  ,
        h2.customerId     AS CODETEXT,
        h2.customerDescr1 AS CODETEXT2
FROM
        BIL_CRM_HEADER h1
LEFT JOIN BAS_CUSTOMER h2
ON
        h1.organizationId   = h2.organizationId
        AND h1.customerid   = h2.udf02
        AND h2.customerType = 'OW'
WHERE
        h1.organizationId = 'OJV_CML'
        AND h2.udf02     IS NOT NULL
        AND h2.activeFlag = 'Y'
        AND H2.udf02='3000017758'
ORDER BY
        CODETEXT ;



SELECT * FROM BIL_CRM_HEADER bch WHERE bch.CustomerId='3000009257'   ;


SELECT * FROM BIL_CRM_DETAILS bcd WHERE bcd.OpportunityId IN('0062w00000PAkK2AAL','0062w00000PAkKRAA1')

