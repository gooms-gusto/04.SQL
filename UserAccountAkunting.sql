SELECT bw.warehouseId AS WAREHOUSE_ID,bw.warehouseDescr AS WAREHOUSE_NAME,COUNT(buwas.userId) AS TOTAL_USER
  FROM wms_cml.BSM_USER buwas INNER JOIN  
      wms_cml.BSM_WAREHOUSE bw ON
   bw.organizationId = buwas.organizationId AND buwas.udf01 = bw.warehouseId
  WHERE bw.activeFlag='Y' AND buwas.udf01 <> '' AND buwas.udf01<> '1' AND buwas.udf01<> 'H'
  GROUP BY bw.warehouseId,bw.warehouseDescr;


SELECT * FROM wms_cml.BSM_USER_WAREHOUSE buw WHERE buw.warehouseId='TRKM5';

SELECT * FROM wms_cml.BSM_USER


SELECT bu.udf01 FROM wms_cml.BSM_USER bu WHERE bu.udf01 <> '' AND bu.udf01<> '1' AND bu.udf01<> 'H';
