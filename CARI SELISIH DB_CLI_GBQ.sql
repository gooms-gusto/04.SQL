select count(asnNo) from linc-sci.app.DOC_ASN_HEADER 
WHERE warehouseId='WHPGD01' 
and DATE(TIMESTAMP(addtime),"Asia/Jakarta") < DATE_SUB(CURRENT_DATE(), INTERVAL 0 DAY)
order by asnNo DESC