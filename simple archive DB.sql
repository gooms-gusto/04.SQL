USE wms_cml;

INSERT INTO wms_cml_arv2022.ACT_TRANSACTION_LOG
SELECT * FROM wms_cml.ACT_TRANSACTION_LOG atl WHERE year(atl.addTime)=2022 AND atl.organizationId='OJV_CML';

SELECT COUNT(1) FROM wms_cml.ACT_TRANSACTION_LOG  das WHERE  year(das.addTime)=2022 AND das.organizationId='OJV_CML';

SELECT COUNT(1) FROM wms_cml_arv2022.ACT_TRANSACTION_LOG das WHERE  year(das.addTime)=2022 AND das.organizationId='OJV_CML';

DELETE FROM  wms_cml.ACT_TRANSACTION_LOG WHERE  year(addTime)=2022 AND organizationId='OJV_CML';
