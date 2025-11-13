USE prod_apibilling;


SELECT
  *
FROM rate_detail_sf WHERE rate_header_sf_id=31;

SELECT * FROM bm_rate_header_cml WHERE idRateHeader=111

SELECT
  *
FROM rate_header_sf;

SELECT * FROM bm_rate_header_cml brhc WHERE brhc.customerId='BASF02'

INSERT INTO rate_detail_sf (rate_header_sf_id,product_code, product_descr, price, qty, uom, created_at, updated_at)
  VALUES (29, '1700000046', 'Handling Out', 55400, 1, 'Pieces', NOW(), NOW());


INSERT INTO rate_detail_sf (rate_header_sf_id,product_code, product_descr,price,qty, uom, created_at, updated_at)
  VALUES (29,'9999999999', 'Handling Out', 110800, 1, 'Pieces', NOW(), NOW());


INSERT INTO rate_header_sf ( opportunity_id, agreement_no, warehouse_code, customer_code, effective_from, effective_to, create_by, update_by, status, created_at, updated_at)
  VALUES ( '0060k00000G5fA0MAP', 'Contract-0000000012', 'CBT01', '3000007662' , '2023-01-01 00:00:00' , '2023-12-31 00:00:00', 'EDI' , 'EDI', ('0') , NOW() , NOW() );



INSERT INTO rate_header_sf( opportunity_id, agreement_no, warehouse_code, customer_code, effective_from, effective_to, create_by, update_by, status, created_at, updated_at)VALUES('0060k0000G5fA0BASF022','Contract-0000000014','BASF02','3000020580','2021-01-25','2024-01-31',' EDI ',' EDI','active', NOW() , NOW() );


INSERT INTO rate_detail_sf (rate_header_sf_id,product_code, product_descr, price, qty, uom, created_at, updated_at)VALUES('31','1700000045',' Handling In','44','1','QUANTITY', NOW(), NOW());

INSERT INTO rate_detail_sf (rate_header_sf_id,product_code, product_descr, price, qty, uom, created_at, updated_at)VALUES('31','1700000046',' Handling Out','44','1','QUANTITY', NOW(), NOW());
INSERT INTO rate_detail_sf (rate_header_sf_id,product_code, product_descr, price, qty, uom, created_at, updated_at)VALUES('31','1700000046',' Handling Out','550000','1','CTN', NOW(), NOW());
INSERT INTO rate_detail_sf (rate_header_sf_id,product_code, product_descr, price, qty, uom, created_at, updated_at)VALUES('31','1700000046',' Handling Out','800000','1','CTN', NOW(), NOW());
