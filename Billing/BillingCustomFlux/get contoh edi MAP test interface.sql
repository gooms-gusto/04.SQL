SELECT doh.soReference1
FROM DOC_ORDER_HEADER doh
WHERE doh.organizationId='OJV_CML'
AND doh.warehouseId='CBT02'
AND doh.soStatus='99'
AND doh.customerId='MAP' AND doh.orderType='SO' AND doh.addWho='EDI'
ORDER BY doh.editTime DESC LIMIT 3;

0723364509,0723365559,0723364505


0723368447,0723368446,0723367977