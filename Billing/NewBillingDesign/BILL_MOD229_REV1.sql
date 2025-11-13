DROP PROCEDURE IF EXISTS BILL_MOD229;
PROCEDURE BILL_MOD229_REV (IN IN_organizationId varchar(30),
IN IN_warehouseId varchar(30),
IN IN_USERID varchar(30),
IN IN_Language varchar(30),
IN IN_CustomerId varchar(30),
IN IN_asnNo varchar(30),
INOUT OUT_returnCode varchar(1000))
BEGIN

DECLARE R_CURRENTDATE timestamp;
  DECLARE R_OPDATE varchar(10);
  DECLARE R_FMDATE varchar(10);
  DECLARE R_TODATE varchar(10);
  DECLARE R_BILLINGDAY integer;
  DECLARE R_BILLINGDATE varchar(10);
  DECLARE R_TARGETDATE varchar(10);
  DECLARE R_DAYOFMONTH int;
  DECLARE R_ORGANIZATIONID varchar(30);
  DECLARE R_WAREHOUSEID varchar(30);
  DECLARE R_CUSTOMERID varchar(30);
  DECLARE R_STOCKDATE varchar(10);
  DECLARE R_TARIFFID varchar(10);
  DECLARE R_TARIFFMASTERID varchar(20);
  DECLARE R_TARIFFLINENO int(11);
  DECLARE R_TARIFFCLASSNO int(11);
  DECLARE R_CHARGECATEGORY varchar(20);
  DECLARE R_CHARGETYPE varchar(20);
  DECLARE R_descrC varchar(50);
  DECLARE R_ratebase varchar(20);
  DECLARE R_docType varchar(20);
  DECLARE R_rateperunit decimal(24, 8);
  DECLARE R_rate decimal(24, 8);
  DECLARE R_minQty varchar(500);
  DECLARE R_minAmount decimal(24, 8);
  DECLARE R_maxAmount decimal(24, 8);
  DECLARE R_billQty decimal(24, 8);
  DECLARE R_Cost decimal(24, 8);
  DECLARE R_materialNo varchar(500);
  DECLARE R_itemChargeCategory varchar(500);
  DECLARE R_billMode varchar(500);
  DECLARE R_UDF06 varchar(500);
  DECLARE R_FINALAMOUNT decimal(24, 8);
  DECLARE R_billsummaryId varchar(30) DEFAULT '';
  DECLARE R_billsummaryNo varchar(30) DEFAULT '';
  DECLARE R_LOCATIONCAT char(2);
  DECLARE R_LOCATIONGROUP varchar(500);
  DECLARE R_INCOMETAX decimal(24, 8);
  DECLARE R_CLASSFROM decimal(24, 8);
  DECLARE R_CLASSTO decimal(24, 8);
  DECLARE R_CONTRACTNO varchar(100);
  DECLARE R_BILLINGMONTH varchar(10);
  DECLARE R_BILLINGPARTY varchar(10);
  DECLARE R_BILLTO varchar(30);
  DECLARE R_NROW integer;
  DECLARE c_WAREHOUSEID varchar(30);
  DECLARE c_CUSTOMERID varchar(30);
  DECLARE c_chargecategory varchar(30);
  DECLARE c_charegetype varchar(30);
  DECLARE c_locationId varchar(60);
  DECLARE c_sku varchar(255);
  DECLARE c_qtyonHand int(11) DEFAULT NULL;
  DECLARE c_packkey varchar(255) binary DEFAULT NULL;
  DECLARE c_UOM varchar(255) binary DEFAULT NULL;
  DECLARE c_qtyallocated int(11) DEFAULT NULL;
  DECLARE c_qtyonHold int(11) DEFAULT NULL;
  DECLARE c_qtyavailable int(11) DEFAULT NULL;
  DECLARE c_qtyPicked int(11) DEFAULT NULL;
  DECLARE c_SKUDesc varchar(550) binary DEFAULT NULL;
  DECLARE c_stockDate date DEFAULT NULL;
  DECLARE c_Cub decimal(24, 8) DEFAULT NULL;
  DECLARE c_totalCub decimal(24, 8) DEFAULT NULL;
  DECLARE c_grossWeight decimal(18, 8) DEFAULT NULL;
  DECLARE c_netWeight decimal(18, 8) DEFAULT NULL;
  DECLARE c_freightClass varchar(255) binary DEFAULT NULL;
  DECLARE c_locationCategory varchar(10) DEFAULT '';
  DECLARE R_UDF08 varchar(500);
  DECLARE R_UDF07 varchar(500);
  DECLARE R_Days int(11) DEFAULT NULL;
  
  -- DECLARE VARIABLE LINE
  
    DECLARE ln_organizationId varchar(255);
	DECLARE ln_asnReference1 varchar(255);
	DECLARE ln_asnReference3 varchar(255);
	DECLARE ln_skuDescr1 varchar(255);
	DECLARE ln_warehouseId varchar(255);
	DECLARE ln_customerId varchar(255);
	DECLARE ln_asnNo varchar(255);
	DECLARE ln_asnLineNo varchar(255);
	DECLARE ln_sku varchar(255);
	DECLARE ln_qtyReceived varchar(255);
	DECLARE ln_uom varchar(255);
	DECLARE ln_qtyReceivedEach varchar(255);
	DECLARE ln_qtyCharge varchar(255);
	DECLARE ln_totalCube varchar(255);
	DECLARE ln_addTime varchar(255);
	DECLARE ln_editTime varchar(255);
	DECLARE ln_transactionTime varchar(255);
	DECLARE ln_lotNum varchar(255);
	DECLARE ln_traceId varchar(255);
	DECLARE ln_muid varchar(255);
	DECLARE ln_toLocation varchar(255);
	DECLARE ln_transactionId varchar(255);
	DECLARE ln_docType varchar(255);
	DECLARE ln_docTypeDescr varchar(255);
	DECLARE ln_packId varchar(255);
	DECLARE ln_QtyPerCases varchar(255);
	DECLARE ln_QtyPerPallet varchar(255);
	DECLARE ln_sku_group1 varchar(255);
	DECLARE ln_grossWeight varchar(255);
	DECLARE ln_cubeNya varchar(255);
	DECLARE ln_tariffMasterId varchar(255);
	DECLARE ln_zone varchar(255);
	DECLARE ln_batch varchar(255);
	DECLARE ln_lotAtt07 varchar(255);
	DECLARE ln_RecType varchar(21);



END