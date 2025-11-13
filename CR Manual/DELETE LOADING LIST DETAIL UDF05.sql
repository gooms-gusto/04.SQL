
CREATE TRIGGER TRG_DETAIL_LOADINGLIST_DEL
BEFORE DELETE ON DOC_LOADING_DETAILS
FOR EACH ROW
BEGIN

     UPDATE ACT_ALLOCATION_DETAILS
    SET udf05 = NULL,
        editTime = NOW()
    WHERE organizationId = OLD.organizationId
    AND warehouseId = OLD.warehouseId
    AND OLD.allocationDetailsId=OLD.allocationDetailsId AND orderNo=OLD.orderNo
    AND pickToTraceId=OLD.traceId;
 
    
END

