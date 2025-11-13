SELECT * FROM asn_header WHERE customer_id='64'  and asn_no='0675235836' and interface_job_id=0;



SELECT interface_time,interface_job_id FROM asn_header WHERE customer_id='64'  and asn_no='0675235836' and interface_job_id=0;

SELECT interface_time,interface_job_id FROM order_header WHERE customer_id='64'  and order_no='0675235844' and interface_job_id=0;

SELECT * FROM asn_header WHERE customer_id='64' and interface_job_id=0 and asn_no='0675235846';

SELECT * FROM customer;


UPDATE asn_header
set interface_job_id= 0,interface_time=NULL
WHERE customer_id='64' and asn_no='0675235836';


UPDATE order_header
set interface_job_id= 0,interface_time=NULL
WHERE customer_id='64' and order_no='0675235844';

SELECT * from asn_tracking WHERE asn_header_id='22260';


SELECT * from asn_detail WHERE asn_header_id='22259'