SELECT * from order_header where customer_id=64 and order_no='0675235891'

UPDATE order_header
set interface_job_id=0, interface_time=NULL
where customer_id=64 and order_no='0675235891'