DELETE FROM BAS_SKU WHERE addWho='EDI' AND customerId='MAP' AND date(addTime)=date(NOW());

SELECT COUNT(*) FROM BAS_SKU WHERE addWho='EDI' AND customerId='MAP' AND date(addTime)=date(NOW())