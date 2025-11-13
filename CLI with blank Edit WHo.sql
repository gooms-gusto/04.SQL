USE app;


SELECT  asnNo,lineStatus,asnLineNo,addTime,addWho from app.DOC_ASN_DETAILS  where editTime IS NULL ORDER BY ADDTIME DESC;

select COUNT(*) from app.DOC_ASN_DETAILS  where editTime IS NULL AND lineStatus='00';