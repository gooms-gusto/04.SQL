USE wms_cml;

SELECT * FROM BIL_TARIFF_MASTER btm WHERE 

SELECT DISTINCT(bth.tariffId) FROM BIL_TARIFF_DETAILS  bth WHERE bth.chargeCategory='FX' AND btm.tariffMasterId IN (SELECT btm.tariffMasterId FROM BIL_TARIFF_MASTER btm );



SELECT  BTD.tariffId AS TarifID, BTH.tariffMasterId AS TarifMaster,BTM.customerId, BTD.descrC AS ChargeType
FROM BIL_TARIFF_DETAILS BTD INNER JOIN BIL_TARIFF_HEADER BTH ON BTD.organizationId = BTH.organizationId AND BTD.warehouseId = BTH.warehouseId AND BTD.tariffId = BTH.tariffId
INNER JOIN
BIL_TARIFF_MASTER BTM
ON  BTD.organizationId = BTM.organizationId AND BTH.tariffMasterId = BTM.tariffMasterId 
INNER JOIN BAS_CUSTOMER BC ON BTM.customerId = BC.customerId
WHERE BTD.chargeCategory='FX' AND
DATE_FORMAT(BTH.effectiveFrom,'%Y-%m-%d') < DATE_FORMAT(NOW(),'%Y-%m-%d') AND
DATE_FORMAT(BTH.effectiveTo,'%Y-%m-%d') > DATE_FORMAT(NOW(),'%Y-%m-%d')
AND BC.customerType='OW' AND BC.activeFlag='Y'

