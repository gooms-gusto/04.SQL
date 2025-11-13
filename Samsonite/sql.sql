USE LincDataProd;



select * from LincDataProd.wh5.sku where storerkey='MAP' AND SKU IN ('ZZZPLSSPL')
SELECT * FROM LincDataProd.WH5.ALTSKU WHERE STORERKEY='MAP' AND SKU IN ('ZZZPLSSPL');

SELECT * FROM LincDataProd.WH5.RECEIPT WHERE WAREHOUSEREFERENCE='4501719917'
SELECT * FROM LincDataProd.WH5.RECEIPTDETAIL WHERE RECEIPTKEY='0000015439'


SELECT * FROM LincDataProd.WH5.STORER WHERE STORERKEY='0000314467'


select * from LincDataProd.wh5.PO WHERE POKEY='0000017660';
select * from LincDataProd.wh5.PODETAIL WHERE POKEY='0000017660';

select * from LincDataProd.wh5.receipt where warehousereference='0082678660'
select * from LincDataProd.wh5.receiptdetail where receiptkey='0000015413'


-- order RS (return order)

select * from LincDataProd.wh5.PO WHERE POKEY='0000017634';
select * from LincDataProd.wh5.PODETAIL WHERE POKEY='0000017634';

select * from LincDataProd.wh5.receipt where pokey='0000017634'
select * from LincDataProd.wh5.receiptdetail where receiptkey='0000015413'

select * from LincDataProd.wh5.ORDERS where externorderkey='0950406736'

select * from LincDataProd.wh5.ORDERS where externorderkey='0082674108'

select * from LincDataProd.wh5.ORDERDETAIL WHERE ORDERKEY IN (
    select ORDERKEY from LincDataProd.wh5.ORDERS (NOLOCK) where externorderkey='0082674108'
    )



select * from LincDataProd.wh5.