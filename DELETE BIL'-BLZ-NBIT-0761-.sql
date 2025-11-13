


SELECT * FROM Z_BAS_CUSTOMER_CUSTBILLING zbcc;
SELECT * FROM Z_BAS_CUSTOMER_CUSTBILLING_DETAILS zbccd;


-- SELECT COUNT(*) FROM BIL_SUMMARY bs     
-- where organizationId='OJV_CML'  AND bs.customerId='YFI' AND bs.warehouseId='CBT01'
--  AND bs.addWho='CUSTOMBILL'   AND bs.arNo='*'  AND bs.chargeCategory='OB' AND DATE(bs.addTime) > getBillFMDate(25);
-- 
-- 
-- SELECT COUNT(*) FROM BIL_SUMMARY bs     
-- where organizationId='OJV_CML'  AND bs.customerId='YFI' AND bs.warehouseId='JBK01'
--  AND bs.addWho='CUSTOMBILL'   AND bs.arNo='*'  AND bs.chargeCategory='OB' AND DATE(bs.addTime) > getBillFMDate(25);




DELETE FROM BIL_SUMMARY bs     
where organizationId='OJV_CML'  AND bs.customerId='MAP' AND bs.warehouseId='CBT02' AND bs.docNo IN ('KEDASN250908020',
'KEDASN250908021',
'KEDASN250908022',
'KEDASN250908023',
'KEDASN250908024',
'KEDASN250908025',
'KEDASN250908026')
 AND bs.addWho='CUSTOMBILL'   AND bs.arNo='*'  AND bs.chargeCategory='IB' AND DATE(bs.addTime) > getBillFMDate(25);
-- 
-- 
-- DELETE FROM BIL_SUMMARY bs     
-- where organizationId='OJV_CML'
-- AND warehouseId='CBT01' and customerId='PPG' AND
--  DATE(addTime) > getBillFMDate(25)  and arNo = '*'  
--  AND chargeCategory IN ('IB','OB')
-- AND addWho='CUSTOMBILL' AND billingSummaryId LIKE 'INVC250915000000017292*%';



-- 
-- SELECT arNo,docNo FROM BIL_SUMMARY 
-- where organizationId='OJV_CML'
-- AND warehouseId='CBT01' and customerId='PPG' AND
--  DATE(addTime) > getBillFMDate(25)  and arNo = '*'  
--  AND chargeCategory IN ('IB','OB')
-- AND addWho='CUSTOMBILL' AND billingSummaryId LIKE 'INVC250915000000017292*%';







-- delete vas SO
--          SELECT dov.vasType,dod.orderNo 
--                    FROM DOC_ORDER_VAS dov INNER JOIN
--                    DOC_ORDER_DETAILS dod ON dov.organizationId = dod.organizationId
--                    AND dov.warehouseId = dod.warehouseId 
--                    AND dov.orderNo = dod.orderNo 
--                    AND dov.orderLineNo = dod.orderLineNo 
--                    INNER JOIN DOC_ORDER_HEADER_UDF dohu ON dov.organizationId = dohu.organizationId
--                    AND dod.warehouseId = dohu.warehouseId AND dov.orderNo = dohu.orderNo
--                    WHERE dov.organizationId='OJV_CML' AND dov.warehouseId='CBT01' AND dod.customerId='PPG'
--                    AND DATE(dohu.closeTime) > getBillFMDate(25);


--  DELETE FROM BIL_SUMMARY bs WHERE organizationId='OJV_CML' AND warehouseId='CBT01' AND customerId='PPG' 
--  AND chargeCategory='VA' AND docType='SO' AND DATE(addTime)> getBillFMDate(25) AND arNo = '*';