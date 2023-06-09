*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.STO.DEPO(idStmt)
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Alamsyah Rizki Isroi
* Development Date   : 20220809
* Description        : Routine to build BIFAST Deposito Standing Order
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* Date           	: -
* Modified by    	: -
* Description		: -
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
    $INCLUDE I_COMMON
    $INCLUDE I_EQUATE
    $INCLUDE I_GTS.COMMON
    $INCLUDE I_F.SPF
    $INCLUDE I_F.USER
    $INCLUDE I_F.STMT.ENTRY
    $INCLUDE I_F.CUSTOMER
    $INCLUDE I_F.AA.SETTLEMENT
    $INCLUDE I_F.AA.ARRANGEMENT
    $INCLUDE I_F.AA.ARRANGEMENT.ACTIVITY
    $INCLUDE I_F.BTPNS.TH.BIFAST.STO.DEPO
    $INCLUDE I_F.IDIH.PMS.CALC.PARAMETER
	$INCLUDE I_F.FT.COMMISSION.TYPE
	$INSERT I_F.BTPNS.TL.BFAST.INTERFACE.PARAM
	$INCLUDE I_F.AA.TERM.AMOUNT
	$INCLUDE I_F.ACCOUNT
	$INSERT I_Table
*-----------------------------------------------------------------------------
	
	COMMON/BIFAST.DEPO.STO.COM/fnTableParam,fvTableParam,fnAcctEntToday,fvAcctEntToday,fnStmtEntry,fvStmtEntry,
	fnTableTmp,fvTableTmp,fnAaArrangement,fvAaArrangement,fnAccount,fvAccount,fnEbLookup,fvEbLookup,fnFundsTransfer,fvFundsTransfer,
	fnFundsTransferHis,fvFundsTransferHis,fnAaArrSettlement,fvAaArrSettlement,fOthFlagPos,fOthTypePos,fDestAccPos,fDestNamePos,
	fProxyTypePos,fProxyIdPos,fDestBnkPos,fDestNameBIPos,fComCodePos,fComTypePos,idCategory,fnCustomer,fvCustomer,fCustTypePos,
	fLegalIDPos,fnTableInfo,fvTableInfo,fnAaArrangementActivity,fvAaArrangementActivity,fnRsdParameter,fvRsdParameter,fComAmtPos,fChargePenPos,
	fChargeBifastPos,fnFtCommissionType,fvftCommissionType,fComCodePos,FN.BTPNS.TL.BFAST.INTERFACE.PARAM,F.BTPNS.TL.BFAST.INTERFACE.PARAM,
	vPercenTax,vOfsSource,vNarrProfit,vNarrPrincipal,vVersion,fMatModePos,fnAaArrTermAmount,fvAaArrTermAmount,fJnamePos,fChargeAddPos,fChargeAddAmtPos,fnIdiuDepoRtgs,fvIdiuDepoRtgs,fnIdiuStodepoClearing,fvIdiuStodepoClearing,fSysTaxablePos

*	IF idStmt EQ '200807020931017.000001' THEN
*		DEBUG
*	END
	
	rvTableTmp = ""
	CALL F.READ(fnTableTmp, idStmt, rvTableTmp, fvTableTmp, "")
	IF rvTableTmp<2> EQ "PROCESSED" THEN RETURN

	CALL F.READ(fnIdiuDepoRtgs, idStmt, rvIdiuDepoRtgs, fvIdiuDepoRtgs, "")
	IF rvIdiuDepoRtgs NE "" THEN RETURN

	CALL F.READ(fnIdiuStodepoClearing, idStmt, rvIdiuStodepoClearing, fvIdiuStodepoClearing, "")
	IF rvIdiuStodepoClearing NE "" THEN RETURN

	GOSUB Initialise
	GOSUB MainProcess
	
	RETURN
	
*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------

	Y.DATE = OCONV(DATE(),'DYMD')
    Y.DATE = CHANGE(Y.DATE, ' ', '')
    Y.TIME = CHANGE(TIMEDATE(), ':', '')
    vDateTime = Y.DATE[3,6] : Y.TIME[1,4]
	
	RETURN
	
*-----------------------------------------------------------------------------
MainProcess:
*-----------------------------------------------------------------------------

	rvStmtEntry = ""
	CALL F.READ(fnStmtEntry, idStmt, rvStmtEntry, fvStmtEntry, "")
	IF NOT(rvStmtEntry) THEN RETURN
	
	IF rvStmtEntry<StmtEntry_AmountLcy> LT 0 THEN RETURN
	
	idAaDepo = FIELD(rvStmtEntry<StmtEntry_ChequeNumber>, "*", 1)
	idPma = FIELD(rvStmtEntry<StmtEntry_ChequeNumber>, "*", 2)
	vAmount = rvStmtEntry<StmtEntry_AmountLcy>

*	IF idStmt EQ '200741017900659.020001' OR idStmt EQ '200746556200603.000001' THEN
*		DEBUG
*	END ELSE
*		RETURN
*	END
	
	BEGIN CASE
	CASE idAaDepo[1,2] EQ "AA" AND idPma[1,3] EQ "PMA"
		GOSUB CheckCharges
		vAmountType = "PROFIT"
		IF vNarrProfit EQ '' THEN
			vNarrProfit = "BAGI HASIL DEPO "
		END
		Y.PAYDET	= 'PFT'
		vPaymentDetails = vNarrProfit
		vPaymentDetails := idAaDepo

		CALL F.READ(fnAaArrangement, idAaDepo, rvAaDepo, fvAaArrangement, "")
		linkedApplId	= rvAaDepo<AaArrangement_LinkedApplId,1>

		CALL F.READ(fnAccount, linkedApplId, rvAccount, fvAccount, '')
		taxFlag        = rvAccount<AC.LOCAL.REF, fSysTaxablePos>
		IF taxFlag EQ 'Y' THEN
			vAmount = DROUND((vAmount * ((100 - vPercenTax)/100)),0)
			vAmount = vAmount - ChargeBifastAmount
		END ELSE
			vAmount = vAmount - ChargeBifastAmount
		END

		GOSUB GetAaDetails
	CASE rvStmtEntry<StmtEntry_SystemId> EQ "AA" AND rvStmtEntry<StmtEntry_TransactionCode> EQ "890"
		idAaActivity = rvStmtEntry<StmtEntry_TransReference>
		CALL F.READ(fnAaArrangementActivity, idAaActivity, rvAaArrangementActivity, fvAaArrangementActivity, "")
		idAaDepo = rvAaArrangementActivity<AaArrangementActivity_Arrangement>
		GOSUB CheckCharges
		vAmountType = "PRINCIPAL"
		IF vNarrPrincipal EQ '' THEN
			vNarrPrincipal = "REDEEM DEPO "
		END
		Y.PAYDET	= 'RDM'
		vPaymentDetails = vNarrPrincipal
		vPaymentDetails := idAaDepo
		vAmount = vAmount - chargePenalty - ChargeBifastAmount
		GOSUB GetAaDetails
	CASE OTHERWISE
* exception case logic write here
	END CASE
	
	RETURN
	
*-----------------------------------------------------------------------------
GetAaDetails:
*-----------------------------------------------------------------------------
	
	rvAaDepo = ""
	CALL F.READ(fnAaArrangement, idAaDepo, rvAaDepo, fvAaArrangement, "")
	arrStatus	= rvAaDepo<AaArrangement_ArrStatus>
	IF rvAaDepo<AaArrangement_ProductLine> NE "DEPOSITS" THEN RETURN

	idProperty = 'COMMITMENT'
	idLinkRef = ""
	CALL AA.PROPERTY.REF(idAaDepo, idProperty, idLinkRef)
    CALL F.READ(fnAaArrTermAmount, idLinkRef, rvAaArrTermAmount, fvAaArrTermAmount,'')
	matMode	= rvAaArrTermAmount<AaSimTermAmount_LocalRef,fMatModePos>

	IF matMode EQ 'PRINCIPAL + PROFIT ROLLOVER' THEN
		descMatMode	= 'ARO2'
	END ELSE
		descMatMode = matMode
	END

	atTxnDesc	= descMatMode : "." : arrStatus
	
	idProperty = "SETTLEMENT"
	idLinkRef = ""
	CALL AA.PROPERTY.REF(idAaDepo, idProperty, idLinkRef)
	IF idLinkRef THEN CALL F.READ(fnAaArrSettlement, idLinkRef, rvAaArrSettlement, fvAaArrSettlement, "")
	IF rvAaArrSettlement<AaSimSettlement_LocalRef,fOthFlagPos> NE "Y" THEN RETURN
* process only for BIFAST
	IF rvAaArrSettlement<AaSimSettlement_LocalRef,fOthTypePos> NE "3" THEN RETURN
*	IF rvAaArrSettlement<AaSimSettlement_PayoutAccount>[4,5] NE idCategory THEN RETURN
	
	idCustomer = "" ; rvCustomer = ""
	LOCATE "OWNER" IN rvAaDepo<AaArrangement_CustomerRole,1> SETTING cPos THEN
		idCustomer = rvAaDepo<AaArrangement_Customer,cPos>
	END ELSE
		idCustomer = rvAaDepo<AaArrangement_Customer,1>
	END
	
	CALL F.READ(fnCustomer, idCustomer, rvCustomer, fvCustomer, "")
	
	BEGIN CASE
	CASE rvCustomer<Customer_LocalRef,fCustTypePos> EQ "R"
		vCustType = "1"
	CASE rvCustomer<Customer_LocalRef,fCustTypePos> EQ "C"
		vCustType = "2"
	CASE OTHERWISE
		vCustType = "0"
	END CASE
	
	vCommCode = "" ; vCommType = ""
	vChargeType = ""; vChargeAMt = ""
	vCommCode = rvAaArrSettlement<AaSimSettlement_LocalRef,fComCodePos>
	vCommType = rvAaArrSettlement<AaSimSettlement_LocalRef,fComTypePos>
	vCommAmt  = rvAaArrSettlement<AaSimSettlement_LocalRef,fComAmtPos>
	vChargeType = rvAaArrSettlement<AaSimSettlement_LocalRef,fChargeAddPos>
	vChargeAMt  = rvAaArrSettlement<AaSimSettlement_LocalRef, fChargeAddAmtPos>
	vCommType 	= CHANGE(CHANGE(vCommType, @SM, @FM), @VM, @FM)
	vCommAmt 	= CHANGE(CHANGE(vCommAmt, @SM, @FM), @VM, @FM)
	vChargeType = CHANGE(CHANGE(vChargeType, @SM, @FM), @VM, @FM)
	vChargeAMt	= CHANGE(CHANGE(vChargeAMt, @SM, @FM), @VM, @FM)

	IF LEN(vPaymentDetails) GT 35 THEN vPaymentDetails = FOLD(vPaymentDetails, 35)

*	Y.PAYMENT.DETAIL = Y.PAYDET : FIELD(idStmt, ".", 1)
	Y.PAYMENT.DETAIL = Y.PAYDET : "." : TODAY : "." : idAaDepo
	GOSUB OfsProcess
	
	RETURN
*-----------------------------------------------------------------------------
OfsProcess:
*-----------------------------------------------------------------------------
	
	CALL LOAD.COMPANY(rvAaDepo<AaArrangement_CoCode>)
	
	CALL IDC.AP.GET.NEXT.ID("FUNDS.TRANSFER",idFt)
	idSto = idAaDepo:".":rvStmtEntry<StmtEntry_BookingDate>:".":idFt
	
	vOfsRequest = vVersion:"/I/PROCESS/1/1,//":rvAaDepo<AaArrangement_CoCode>:",":idFt
	vOfsRequest := ",TRANSACTION.TYPE=AC35"
	vOfsRequest := ",DEBIT.CURRENCY=":LCCY
	vOfsRequest := ",CREDIT.CURRENCY=":LCCY
	vOfsRequest := ",ORDERING.BANK=":R.SPF.SYSTEM<Spf_SiteName>
	vOfsRequest := ",DEBIT.ACCT.NO=":rvStmtEntry<StmtEntry_AccountNumber>
	vOfsRequest := ",DEBIT.AMOUNT=":vAmount
	vOfsRequest := ",B.CDTR.AGTID=":rvAaArrSettlement<AaSimSettlement_LocalRef,fDestBnkPos>
	vOfsRequest := ",B.CDTR.ACCID=":rvAaArrSettlement<AaSimSettlement_LocalRef,fDestAccPos>
	vOfsRequest := ",B.CDTR.NM=":rvAaArrSettlement<AaSimSettlement_LocalRef,fDestNameBIPos>
	vOfsRequest := ",B.CDTR.ACCTYPE=10"
	vOfsRequest := ",B.CDTR.TYPE=":vCustType
*	vOfsRequest := ",PAYMENT.DETAIL=":rvAaDepo<AaArrangement_LinkedApplId,1>
	vOfsRequest := ",PAYMENT.DETAIL=":Y.PAYMENT.DETAIL
	vOfsRequest := ",B.CDTR.RESSTS=01"
	vOfsRequest := ",B.DBTR.NM=":rvCustomer<Customer_Name1>
	IF comCode EQ 'DEBIT PLUS CHARGES' THEN
		vOfsRequest := ",CHARGES.ACCT.NO=":rvStmtEntry<StmtEntry_AccountNumber>
	END
	vOfsRequest := ",AT.TXN.DESC=":atTxnDesc
	IF jName NE '' THEN
		vOfsRequest := ",ATI.JNAME.2=":jName
	END
	*CALL F.READ(FN.BTPNS.TL.BFAST.INTERFACE.PARAM,"SYSTEM",R.BIFAST.PARAM,F.BTPNS.TL.BFAST.INTERFACE.PARAM,READ.PAR.ERR)
	*vOfsRequest := ",CREDIT.ACCT.NO=":R.BIFAST.PARAM<BF.INT.PAR.BI.NOSTRO>

	FOR idx=1 TO DCOUNT(vPaymentDetails, @FM)
		vOfsRequest := ",PAYMENT.DETAILS:":idx:":1=":vPaymentDetails<idx>
	NEXT idx
	vOfsRequest := ",B.DBTR.TYPE=":vCustType
	vOfsRequest := ",B.DBTR.ACCTYPE=10"
	vOfsRequest := ",B.DBTR.RESSTS=01"
	IF NUM(rvCustomer<Customer_LocalRef,fLegalIDPos>) AND rvCustomer<Customer_LocalRef,fLegalIDPos> NE "" THEN vOfsRequest := ",B.DBTR.ID=":rvCustomer<Customer_LocalRef,fLegalIDPos>[1,16]
	vOfsRequest := ",COMMISSION.CODE=":vCommCode[1,1]
	IF vCommCode[1,1] NE "W" THEN
		FOR idx=1 TO DCOUNT(vCommType, @FM)
			vOfsRequest := ",COMMISSION.TYPE:":idx:":1=":vCommType<idx>
			IF vCommAmt<idx> THEN
				IF vCommAmt<idx>[1,3] NE LCCY THEN
					vOfsRequest := ",COMMISSION.AMT:":idx:":1=":LCCY:" ":vCommAmt<idx>
				END ELSE
					vOfsRequest := ",COMMISSION.AMT:":idx:":1=":vCommAmt<idx>
				END
			END
		NEXT idx
	END

	IF vChargeType NE '' THEN
		idFtCharges = ""
		vOfsRequest := ",B.CHARGE.TYPE=":vChargeType
		vChargeAMt	= "IDR":vChargeAMt
		vOfsRequest := ",B.CHARGE.AMT=":vChargeAMt
	END

*	IF vCommCode[1,1] NE "W" THEN
*		idxAddStart = DCOUNT(vCommType, @FM) + 1
*		idxAddEnd	= DCOUNT(vChargeType, @FM)
*		FOR idxAdd=1 TO idxAddEnd
*			vOfsRequest := ",COMMISSION.TYPE:":idxAddStart:":1=":vChargeType<idxAdd>
*			IF vChargeAMt<idxAdd> THEN
*				IF vChargeAMt<idxAdd>[1,3] NE LCCY THEN
*					vOfsRequest := ",COMMISSION.AMT:":idxAddStart:":1=":LCCY:" ":vChargeAMt<idxAdd>
*				END ELSE
*					vOfsRequest := ",COMMISSION.AMT:":idxAddStart:":1=":vChargeAMt<idxAdd>
*				END
*				idxAddStart = idxAddStart + 1
*			END
*		NEXT idxAdd
*	END
*	IF vChargeType EQ '' THEN
*			vOfsRequest := ",COMMISSION.TYPE:2:1=BYMATERAI"
*			vOfsRequest := ",COMMISSION.AMT:2:1=IDR 0"
*	END

	vOfsRequest := ",DEBIT.THEIR.REF=":idAaDepo
	IF idPma THEN vOfsRequest := ",CREDIT.THEIR.REF=":idPma
	IF idAaActivity AND vAmountType EQ "PRINCIPAL" THEN vOfsRequest := ",INC.TXN.REF=":idAaActivity
* AAACT222166ZQS1K82
* PMA2221300001
* AA20227Q18RV
	vOfsRequest := ",REMARKS=STO.DEPO"
	vOfsRequest := ",ATI.ORDER.NO=":idStmt
	vOfsRequest := ",RELATED.TRN=":vAmountType
	vOfsRequest := ",ORDER.CUST.ACC=":CHANGE(rvStmtEntry<StmtEntry_TransReference>, "/", "^")
	vOfsRequest := ",ATI.MIR=":idSto
	vOfsRequest := ",B.CDTR.PRXYTYPE:1:1=0"

*add field outgoing
	vOfsRequest := ",B.TXNTYPE:1:1=010"
	

	vOfsMessage = vOfsRequest
	vOfsResponse = ""
*	CALL OFS.GLOBUS.MANAGER(vOfsSource,vOfsMessage)
*	vOfsResponse = vOfsMessage
    vRequestCommitted = ''
    CALL OFS.CALL.BULK.MANAGER(vOfsSource,vOfsRequest,vOfsResponse,vRequestCommitted)
	vOfsResponse = CHANGE(vOfsResponse, "<requests>","")
	vOfsResponse = CHANGE(vOfsResponse, "<request>","")
	
	vErrMsg = ""
	IF FIELD(vOfsResponse, "/", 3)[1,1] NE "1" THEN
		CALL OCOMO("Error Posting OFS ":idAaDepo)
		CRT "OFS_REQUEST:":vOfsRequest
		CRT "OFS_RESPONSE:":vOfsResponse
		vErrMsg = FIELD(vOfsResponse, ",", 2,99)
		vErrMsg = FOLD(vErrMsg, 99)
	END ELSE
*		idFt = FIELD(vOfsResponse, "/", 1)
		CALL OCOMO("Success Posting OFS ":idAaDepo:"-":vAmountType:"-":idFt)
	END
	GOSUB WriteSto
	
	RETURN
*-----------------------------------------------------------------------------
WriteSto:
*-----------------------------------------------------------------------------
	
	rvRecord<BtpnsThBifastStoDepo_Arrangement> = idAaDepo
	rvRecord<BtpnsThBifastStoDepo_Date> = rvStmtEntry<StmtEntry_BookingDate>
	rvRecord<BtpnsThBifastStoDepo_DistEntry,1> = idStmt
	rvRecord<BtpnsThBifastStoDepo_DistReference,1> = rvStmtEntry<StmtEntry_TransReference>
	rvRecord<BtpnsThBifastStoDepo_DistPma,1> = idPma
	rvRecord<BtpnsThBifastStoDepo_DistAmount,1> = rvStmtEntry<StmtEntry_AmountLcy>
	rvRecord<BtpnsThBifastStoDepo_DistAccount,1> = rvStmtEntry<StmtEntry_AccountNumber>
	rvRecord<BtpnsThBifastStoDepo_AmountType,1> = vAmountType
	rvRecord<BtpnsThBifastStoDepo_FtReference> = idFt
	IF vErrMsg THEN
		rvRecord<BtpnsThBifastStoDepo_Status> = "ERROR"
		FOR idx=1 TO DCOUNT(vErrMsg, @FM)
			rvRecord<BtpnsThBifastStoDepo_ErrorMessage,idx> = vErrMsg<idx>
		NEXT idx
	END ELSE
		rvRecord<BtpnsThBifastStoDepo_Status> = "PROCESS"
	END
	rvRecord<BtpnsThBifastStoDepo_CurrNo> = "1"
	rvRecord<BtpnsThBifastStoDepo_Inputter> = TNO:"_":OPERATOR ;*FIELD(FIELD(vOfsResponse, "INPUTTER:1:1=", 2), ",", 1)
	rvRecord<BtpnsThBifastStoDepo_DateTime> = vDateTime ;*FIELD(FIELD(vOfsResponse, "DATE.TIME:1:1=", 2), ",", 1)
	rvRecord<BtpnsThBifastStoDepo_Authoriser> = TNO:"__":OPERATOR ;*FIELD(FIELD(vOfsResponse, "AUTHORISER:1:1=", 2), ",", 1)
	rvRecord<BtpnsThBifastStoDepo_CoCode> = rvAaDepo<AaArrangement_CoCode> ;*FIELD(FIELD(vOfsResponse, "CO.CODE:1:1=", 2), ",", 1)
	rvRecord<BtpnsThBifastStoDepo_DeptCode> = R.USER<EB.USE.DEPARTMENT.CODE> ;*FIELD(FIELD(vOfsResponse, "DEPT.CODE:1:1=", 2), ",", 1)

	rvRecord<BtpnsThBifastStoDepo_ComCode> 		= comCode
	rvRecord<BtpnsThBifastStoDepo_ChargesAmt>	= ChargeBifastAmount

	rvTableTmp<1> = idAaDepo
	rvTableTmp<2> = "PROCESSED"
	rvTableTmp<3> = idFt
	rvTableTmp<4> = vAmountType
	CALL F.WRITE(fnTableTmp, idStmt, rvTableTmp)
	
	CALL F.WRITE(fnTableInfo, idSto, rvRecord)
	CALL JOURNAL.UPDATE(fnTableInfo)

    RETURN
*-----------------------------------------------------------------------------
CheckCharges:
*-----------------------------------------------------------------------------
	
	idProperty = "SETTLEMENT"
	idLinkRef = ""
	CALL AA.PROPERTY.REF(idAaDepo, idProperty, idLinkRef)
	IF idLinkRef THEN CALL F.READ(fnAaArrSettlement, idLinkRef, rvAaArrSettlement, fvAaArrSettlement, "")
	chargePenalty	     = rvAaArrSettlement<AaSimSettlement_LocalRef,fChargePenPos>
	chargeBifastType	 = rvAaArrSettlement<AaSimSettlement_LocalRef,fChargeBifastPos>
	comCode				 = rvAaArrSettlement<AaSimSettlement_LocalRef, fComCodePos>
	jName				 = rvAaArrSettlement<AaSimSettlement_LocalRef, fJnamePos>
	additionalChargesType= rvAaArrSettlement<AaSimSettlement_LocalRef, fChargeAddPos>
	additionalChargesAmt = rvAaArrSettlement<AaSimSettlement_LocalRef, fChargeAddAmtPos>
	ChargeBifastAmount   = 0
	IF chargeBifastType EQ '' THEN
		ChargeBifastAmount	= 0
	END ELSE
		chargeBifastCount	= DCOUNT(chargeBifastType, @SM)
		FOR I = 1 TO chargeBifastCount
			yIdComType = chargeBifastType<1, 1, I>
			CALL F.READ(fnFtCommissionType, yIdComType, rvFtCommissionType, fvftCommissionType, "")
			rvRecord<BtpnsThBifastStoDepo_ChargesType, -1> = yIdComType
			chargeBifast = rvFtCommissionType<FtCommissionType_FlatAmt>
			ChargeBifastAmount = chargeBifast + ChargeBifastAmount
		NEXT I
	END

	IF additionalChargesType NE '' THEN
		addChargesCount = DCOUNT(additionalChargesType, @SM)
		FOR I = 1 TO addChargesCount
			rvRecord<BtpnsThBifastStoDepo_ChargesType, -1> = additionalChargesType<1, 1, I>
			addChargeValue = additionalChargesAmt<1, 1, I>
			ChargeBifastAmount = addChargeValue + ChargeBifastAmount
		NEXT I
	END

    RETURN

END 
