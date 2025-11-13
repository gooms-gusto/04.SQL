USE WMS_FTEST;


SELECT * FROM DOC_ARRIVAL_HEADER WHERE arrivalNo='AN211104001';


SELECT * FROM DOC_ARRIVAL_HEADER   WHERE arrivalNo='AN211104001';

SELECT * FROM DOC_ARRIVAL_DETAILS  WHERE arrivalNo='AN211104001';



SELECT * FROM DOC_APPOINTMENT_HEADER  WHERE warehouseId='CBT01' AND appointmentNo='OUB211102001' ;


SELECT * FROM DOC_APPOINTMENT_DETAILS WHERE warehouseId='CBT01' AND  appointmentNo='OUB211102001';


SELECT * FROM DOC_LOADING_HEADER WHERE LDLNO='LDL2111020001';

SELECT * FROM DOC_LOADING_DETAILS  WHERE LDLNO='LDL2111020001';

SELECT * FROM DOC_ARRIVAL_HEADER  WHERE arrivalNo='AN211104001';
SELECT * FROM DOC_ARRIVAL_DETAILS WHERE arrivalNo='AN211104001';

  SELECT * FROM   DOC_LOADING_HEADER dlh  WHERE LDLNO='LDL2111020001';






  SELECT * FROM DOC_ORDER_HEADER WHERE waveNo='W211102001';


 
  SELECT dad.arrivalno,dad.appointmentno,doh.orderNo,doh.soStatus,dlh.ldlNo,dah.arrivalType
    FROM DOC_ARRIVAL_HEADER dah INNER JOIN
    DOC_ARRIVAL_DETAILS dad ON(dah.organizationId=dad.organizationId AND dah.warehouseId = dad.warehouseId AND dah.arrivalNo = dad.arrivalno) INNER JOIN DOC_APPOINTMENT_DETAILS dad1
    ON (dad.organizationId=dad1.organizationId AND dad.warehouseId = dad1.warehouseId AND dad.appointmentno = dad1.appointmentNo)
    INNER JOIN DOC_LOADING_HEADER dlh ON (dad1.organizationId = dlh.organizationId  AND
    dad1.warehouseId = dlh.warehouseId AND dad1.docNo=dlh.ldlNo ) INNER JOIN DOC_ORDER_HEADER doh ON (dlh.organizationId=doh.organizationId
    AND dlh.warehouseId=doh.warehouseId AND dlh.waveNo=doh.waveNo)
    WHERE dad.warehouseId='CBT01' AND dad1.docType='LOAD' AND dah.arrivalType='OUTBOUND' AND  dad.arrivalno='AN211102007';


   
  SELECT 1
    FROM DOC_ARRIVAL_HEADER dah INNER JOIN
    DOC_ARRIVAL_DETAILS dad ON(dah.organizationId=dad.organizationId AND dah.warehouseId = dad.warehouseId AND dah.arrivalNo = dad.arrivalno) INNER JOIN DOC_APPOINTMENT_DETAILS dad1
    ON (dad.organizationId=dad1.organizationId AND dad.warehouseId = dad1.warehouseId AND dad.appointmentno = dad1.appointmentNo)
    INNER JOIN DOC_LOADING_HEADER dlh ON (dad1.organizationId = dlh.organizationId  AND
    dad1.warehouseId = dlh.warehouseId AND dad1.docNo=dlh.ldlNo ) INNER JOIN DOC_ORDER_HEADER doh ON (dlh.organizationId=doh.organizationId
    AND dlh.warehouseId=doh.warehouseId AND dlh.waveNo=doh.waveNo)
    WHERE dad.warehouseId='CBT01' AND dad1.docType='LOAD' AND dah.arrivalType='OUTBOUND' AND doh.soStatus NOT IN ('99') AND  dad.arrivalno='AN211102007';

    