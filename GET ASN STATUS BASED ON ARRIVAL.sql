SELECT 	a.organizationId, a.warehouseId, a.customerId,  a.asnNo, a.asnReference1, dad.appointmentno, dah.arrivalNo, a.asnType, c2.asnTypeName, a.asnStatus, c1.asnStatusName,
		a.supplierId, a.supplierName, dah.vehicleType, dah.driver, dah.vehicleNo, dah.dockNo AS dockNo, 
		DATE_FORMAT(a.asnCreationTime, '%Y-%m-%d %T') AS asnCreationTime, 
		DATE_FORMAT(a.expectedArriveTime1, '%Y-%m-%d %T') AS expectedArriveTime1, 
		DATE_FORMAT(dah.appointmentStartTime, '%Y-%m-%d %T') AS appointmentStartTime, 
		DATE_FORMAT(dah.appointmentEndTime, '%Y-%m-%d %T') AS appointmentEndTime, 
		DATE_FORMAT(dah.arriveTime, '%Y-%m-%d %T') AS arriveTime, 
		DATE_FORMAT(dah.entranceTime, '%Y-%m-%d %T') AS entranceTime,
		DATE_FORMAT(dah.startTime, '%Y-%m-%d %T') AS startUnloadTime, 
		DATE_FORMAT(dah.endTime, '%Y-%m-%d %T') AS endUnloadTime,
		DATE_FORMAT(dah.leaveTime, '%Y-%m-%d %T') AS leaveTime	
FROM 	DOC_ASN_HEADER a
LEFT JOIN DOC_APPOINTMENT_DETAILS ad ON a.organizationId = ad.organizationId AND a.warehouseId = ad.warehouseId AND a.asnNo=ad.poNo AND docType IN ('ASN','PO')
LEFT JOIN DOC_APPOINTMENT_HEADER ah ON a.organizationId = ah.organizationId AND a.warehouseId = ah.warehouseId AND ad.appointmentNo = ah.appointmentNo
LEFT JOIN DOC_ARRIVAL_DETAILS dad ON a.organizationId = dad.organizationId AND a.warehouseId = dad.warehouseId AND dad.appointmentNo = ah.appointmentNo AND LEFT(dad.appointmentno,3) ='INB'
LEFT JOIN DOC_ARRIVAL_HEADER dah ON a.organizationId = dah.organizationId AND a.warehouseId = dah.warehouseId AND dah.arrivalno = dad.arrivalno AND appointmentType='PO'
INNER JOIN
(
	SELECT codeId, codeDescr as asnStatusName from BSM_CODE_ML 
	WHERE codeType='ASN_STS' AND languageId='en'
)
c1 on c1.codeId = a.asnStatus
INNER JOIN
(
	SELECT codeId, codeDescr as asnTypeName from BSM_CODE_ML 
	WHERE codeType='ASN_TYP' AND languageId='en'
)
c2 on c2.codeId = a.asnType
WHERE 1=1 AND a.organizationId='OJV_CML' AND a.asnNo IN ('BAJ00000000004')
ORDER BY a.customerId, a.asnCreationTime


  SELECT * FROM DOC_APPOINTMENT_DETAILS WHERE poNo='BAJ00000000004'


  SELECT A.ASNSTATUS
    FROM DOC_ASN_HEADER A INNER JOIN DOC_APPOINTMENT_DETAILS B ON (A.ASNNO=B.PONO) 
    INNER JOIN DOC_ARRIVAL_DETAILS C ON (B.APPOINTMENTNO=C.APPOINTMENTNO)
    WHERE C.ARRIVALNO='AN210816001'


    SELECT * FROM DOC_ARRIVAL_HEADER WHERE arrivalno='AN210816001'



DROP TRIGGER IF EXISTS BEFORE_UPDATE_ARRIVAL_CLOSE

CREATE TRIGGER BEFORE_UPDATE_ARRIVAL_CLOSE
BEFORE UPDATE
ON DOC_ARRIVAL_HEADER FOR EACH ROW
BEGIN
    DECLARE errorMessage VARCHAR(255);
    DECLARE status_asn varchar(2);
    SET errorMessage = CONCAT('Cannot change arrival status to Leave, ASN still not close!');
                        


    IF new.arrivalstatus = '99' THEN

    SELECT  A.ASNSTATUS INTO status_asn
    FROM DOC_ASN_HEADER A INNER JOIN DOC_APPOINTMENT_DETAILS B ON (A.ASNNO=B.PONO) 
    INNER JOIN DOC_ARRIVAL_DETAILS C ON (B.APPOINTMENTNO=C.APPOINTMENTNO)
    WHERE C.ARRIVALNO=old.ARRIVALNO;

        IF  status_asn <> '99' THEN
            SIGNAL SQLSTATE '45000' 
                SET MESSAGE_TEXT = errorMessage;
        END IF;
    END IF;
END 

SELECT * FROM DOC_ASN_HEADER dah WHERE dah.asnNo='BAJ00000000003'



  
  SELECT * FROM DOC_ARRIVAL_HEADER WHERE arrivalno='AN210907002'