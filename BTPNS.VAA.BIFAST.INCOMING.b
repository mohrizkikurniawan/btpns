*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.VAA.BIFAST.INCOMING
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Alamsyah Rizki Isroi
* Development Date   : 20220628
* Description        : Routine to process BIFAST Incoming Transaction to FT
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* Date           	: 20220924
* Modified by    	: Moh Rizki Kurniawan
* Description		: Update GTS.CONTROL to 1 in OFS FT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
    $INCLUDE I_COMMON
    $INCLUDE I_EQUATE
    $INCLUDE I_GTS.COMMON
    $INCLUDE I_F.BTPNS.TH.BIFAST.INCOMING
    $INCLUDE I_F.BTPNS.TH.SKN.BIC
    $INCLUDE I_F.BTPNS.TL.BFAST.INTERFACE.PARAM
    $INCLUDE I_F.IDCH.SKN.CLEARING.CODE
    $INCLUDE I_F.IDIH.WS.DATA.FT.MAP
    $INCLUDE I_F.OVERRIDE
    $INCLUDE I_F.TELLER
    $INCLUDE I_F.FUNDS.TRANSFER
    $INCLUDE I_F.FT.TXN.TYPE.CONDITION
	$INCLUDE I_F.ACCOUNT
*-----------------------------------------------------------------------------
	
	GOSUB Initialise
	
	RETURN
	
*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------

	fnSknBic = "F.BTPNS.TH.SKN.BIC"
	fvSknBic = ""
	CALL OPF(fnSknBic, fvSknBic)

	fnFttc = "F.FT.TXN.TYPE.CONDITION"
	fvFttc = ""
	CALL OPF(fnFttc, fvFttc)
	
	fnApplication = "F.":APPLICATION
	fvApplication = ""
	CALL OPF(fnApplication, fvApplication)

	fnTableTmp = "F.BTPNS.TL.BIFAST.INCOMING.TMP"
	fvTableTmp = ""
	CALL OPF(fnTableTmp, fvTableTmp)
	
	fnSknClearingCode = "F.IDCH.SKN.CLEARING.CODE"
	fvSknClearingCode = ""
	CALL OPF(fnSknClearingCode, fvSknClearingCode)

	fnParam = "F.BTPNS.TL.BFAST.INTERFACE.PARAM"
	fvParam = ""
	CALL OPF(fnParam, fvParam)
	
	CALL F.READ(fnParam, "SYSTEM", rvParam, fvParam, "")
	
	fnTableReversalMap = "F.IDIH.WS.DATA.FT.MAP"
	fvTableReversalMap = ""
	CALL OPF(fnTableReversalMap, fvTableReversalMap)

	fnFundsTransfer = "F.FUNDS.TRANSFER"
	fvFundsTransfer = ""
	CALL OPF(fnFundsTransfer, fvFundsTransfer)

	fnFundsTransferNau = "F.FUNDS.TRANSFER$NAU"
	fvFundsTransferNau = ""
	CALL OPF(fnFundsTransferNau, fvFundsTransferNau)

	fnAccount	= "F.ACCOUNT"
	fvAccount	= ""
	CALL OPF(fnAccount, fvAccount)
	
	idFt = FIELD(ID.NEW, ".", 2)

	arrApp<1> = "IDCH.SKN.CLEARING.CODE"
	arrApp<2> = "COMPANY"
	arrApp<3> = "BTPNS.TH.BIFAST.INCOMING"
	arrFld<1,1> = "BIC.INT"
	arrFld<2,1> = "RTGS.CODE"
	arrFld<3,1> = "B.TIME.CODE"
	arrFld<3,2> = "B.SYSTEM.DATE"
	arrPos 		= ""
	CALL MULTI.GET.LOC.REF(arrApp, arrFld, arrPos)
	fBicPos		= arrPos<1,1>
	fRtgsPos	= arrPos<2,1>
	fTimeCode   = arrPos<3,1>
	fSystemDate = arrPos<3,2>
	
*validation checking tag

	IF R.NEW(BtpnsThBifastIncoming_BeneficiaryId)[3,3] NE '547' THEN
		R.NEW(BtpnsThBifastIncoming_SettlementStatus) = "DECLINED"
		R.NEW(BtpnsThBifastIncoming_ResponseCode) = "12"
		R.NEW(BtpnsThBifastIncoming_ErrorMessage) = "Beneficiary Id Not 547"
		R.NEW(BtpnsThBifastIncoming_FtSettlement) = idFt
		CALL F.WRITE(fnTableTmp, TODAY:".":R.NEW(BtpnsThBifastIncoming_Rrn), ID.NEW)
		GOSUB ParseDataNational
		GOSUB BuildOfsMessage
		vOfsMessageRequest := ",CREDIT.AMOUNT=BIFAST999.999"
		OFS.MSG.ID    = ''
		OPTIONS       = OPERATOR
		Y.OFS.TEMP.MESSAGE = vOfsMessageRequest
		Y.OFS.SOURCE	   = 'BIFAST'
		CALL OFS.POST.MESSAGE(Y.OFS.TEMP.MESSAGE, OFS.MSG.ID, Y.OFS.SOURCE, OPTIONS)

		Y.CUT.TIME = '1400'
		HHMM   = TIMEDATE()
    	HHMM   = HHMM[1,2]:HHMM[4,2]
    	IF HHMM GT Y.CUT.TIME THEN
    	    R.NEW(BtpnsThBifastIncoming_LocalRef)<1, fTimeCode> = "AFTERNOON"
    	END ELSE
    	    R.NEW(BtpnsThBifastIncoming_LocalRef)<1, fTimeCode> = "MORNING"
    	END
		R.NEW(BtpnsThBifastIncoming_LocalRef)<1, fSystemDate> = TODAY
		RETURN
	END

	amtIncoming = R.NEW(BtpnsThBifastIncoming_TrxAmount)
	IF LEN(FIELD(amtIncoming, ".", 2)) GE 3 THEN
		R.NEW(BtpnsThBifastIncoming_SettlementStatus) = "DECLINED"
		R.NEW(BtpnsThBifastIncoming_ResponseCode) = "12"
		R.NEW(BtpnsThBifastIncoming_ErrorMessage) = "Format Amount Not Support"
		R.NEW(BtpnsThBifastIncoming_FtSettlement) = idFt
		CALL F.WRITE(fnTableTmp, TODAY:".":R.NEW(BtpnsThBifastIncoming_Rrn), ID.NEW)
		GOSUB ParseDataNational
		GOSUB BuildOfsMessage	

		OFS.MSG.ID    = ''
		OPTIONS       = OPERATOR
		Y.OFS.TEMP.MESSAGE = vOfsMessageRequest
		Y.OFS.SOURCE	   = 'BIFAST'
		CALL OFS.POST.MESSAGE(Y.OFS.TEMP.MESSAGE, OFS.MSG.ID, Y.OFS.SOURCE, OPTIONS)
		Y.CUT.TIME = '1400'
		HHMM   = TIMEDATE()
    	HHMM   = HHMM[1,2]:HHMM[4,2]
    	IF HHMM GT Y.CUT.TIME THEN
    	    R.NEW(BtpnsThBifastIncoming_LocalRef)<1, fTimeCode> = "AFTERNOON"
    	END ELSE
    	    R.NEW(BtpnsThBifastIncoming_LocalRef)<1, fTimeCode> = "MORNING"
    	END
		R.NEW(BtpnsThBifastIncoming_LocalRef)<1, fSystemDate> = TODAY
		RETURN
	END

	toAccount = R.NEW(BtpnsThBifastIncoming_ToAccount)
	CALL F.READ(fnAccount, toAccount, rvAccount, fvAccount, "")

	IF rvAccount EQ '' THEN
		toAccount = "IDR" : toAccount
		CALL F.READ(fnAccount, toAccount, rvAccount, fvAccount, "")
	END

	IF rvAccount EQ '' THEN
		R.NEW(BtpnsThBifastIncoming_SettlementStatus) = "DECLINED"
		R.NEW(BtpnsThBifastIncoming_ResponseCode) = "12"
		R.NEW(BtpnsThBifastIncoming_ErrorMessage) = "Account not registered"
		R.NEW(BtpnsThBifastIncoming_FtSettlement) = idFt
		CALL F.WRITE(fnTableTmp, TODAY:".":R.NEW(BtpnsThBifastIncoming_Rrn), ID.NEW)
		GOSUB ParseDataNational
		GOSUB BuildOfsMessage	

		OFS.MSG.ID    = ''
		OPTIONS       = OPERATOR
		Y.OFS.TEMP.MESSAGE = vOfsMessageRequest
		Y.OFS.SOURCE	   = 'BIFAST'
		CALL OFS.POST.MESSAGE(Y.OFS.TEMP.MESSAGE, OFS.MSG.ID, Y.OFS.SOURCE, OPTIONS)
		Y.CUT.TIME = '1400'
		HHMM   = TIMEDATE()
    	HHMM   = HHMM[1,2]:HHMM[4,2]
    	IF HHMM GT Y.CUT.TIME THEN
    	    R.NEW(BtpnsThBifastIncoming_LocalRef)<1, fTimeCode> = "AFTERNOON"
    	END ELSE
    	    R.NEW(BtpnsThBifastIncoming_LocalRef)<1, fTimeCode> = "MORNING"
    	END
		R.NEW(BtpnsThBifastIncoming_LocalRef)<1, fSystemDate> = TODAY	
		RETURN	
	END

*rounding amount with case sen
	IF COUNT(amtIncoming, ".") AND FIELD(amtIncoming, ".", 2) NE "00" THEN
		IF FIELD(amtIncoming, ".", 2) GE 50 THEN
			amtIncRound	= FIELD(amtIncoming, ".", 1) + 1
			*amtIncRound = amtIncRound : ".00"
			amtIncRound = amtIncRound
		END ELSE
			*amtIncRound = FIELD(amtIncoming, ".", 1) : ".00"
			amtIncRound = FIELD(amtIncoming, ".", 1)
		END
	END
*	IF COUNT(amtIncoming, ".") AND FIELD(amtIncoming, ".", 2) NE "00" THEN
*		R.NEW(BtpnsThBifastIncoming_SettlementStatus) = "DECLINED"
*		R.NEW(BtpnsThBifastIncoming_ResponseCode) = "12"
*		R.NEW(BtpnsThBifastIncoming_ErrorMessage) = "Format Amount Not Support"
*		R.NEW(BtpnsThBifastIncoming_FtSettlement) = idFt
*		CALL F.WRITE(fnTableTmp, TODAY:".":R.NEW(BtpnsThBifastIncoming_Rrn), ID.NEW)
*		GOSUB ParseDataNational
*		GOSUB BuildOfsMessage	
*
*		OFS.MSG.ID    = ''
*		OPTIONS       = OPERATOR
*		Y.OFS.TEMP.MESSAGE = vOfsMessageRequest
*		Y.OFS.SOURCE	   = 'BIFAST'
*		CALL OFS.POST.MESSAGE(Y.OFS.TEMP.MESSAGE, OFS.MSG.ID, Y.OFS.SOURCE, OPTIONS)
*		RETURN
*	END
	
	
	vBicCodeIssuer = ""
	
	CALL F.READ(fnSknBic, R.NEW(BtpnsThBifastIncoming_IssuerId)[3,3], rvSknBic, fvSknBic, "")
	vBicCodeIssuer = rvSknBic<BtpnsThSknBic_BicCode>

	
	IF NOT(vBicCodeIssuer) THEN
		qryCmd = "SELECT ":fnSknClearingCode:" WITH @ID LIKE '":R.NEW(BtpnsThBifastIncoming_IssuerId)[3,3]:"...' AND L.HO.FLAG EQ 'Y'"
		qryList = "" ; qryNo = ""
		CALL EB.READLIST(qryCmd, qryList, "", qryNo, "")
		vBicCodeIssuer = qryList<1>
		CALL F.READ(fnSknClearingCode, vBicCodeIssuer, rvSknClearingCode, fvSknClearingCode, "")
		vBicCodeIssuer = rvSknClearingCode<IdchSknClearingCode_LocalRef,fBicPos>
	END

	IF vBicCodeIssuer EQ '' THEN
		vBicCodeIssuer = 'BANKNOTREGISTER'
	END
	
	rvFttc = ""
	CALL F.READ(fnFttc, rvParam<BtpnsTlBfastInterfaceParam_FttcIncoming>, rvFttc, fvFttc, "")
	vDefaultNarrative = rvFttc<FtTxnTypeCondition_Description>

	GOSUB MainProcess
	
	RETURN
	
*-----------------------------------------------------------------------------
MainProcess:
*-----------------------------------------------------------------------------
	flagRepeat = 0
	GOSUB ParseDataNational

	IF R.NEW(BtpnsThBifastIncoming_MsgType) EQ '0201' AND R.NEW(BtpnsThBifastIncoming_ApiType) EQ 'B.TRF.RQ' THEN GOSUB CheckRepeat
	IF flagRepeat EQ 1 THEN RETURN
	GOSUB BuildOfsMessage
	
*command for faster time to hit bifat=st
*	OFS.SOURCE.ID = "BIFAST"
*	OFS.MESSAGE = vOfsMessageRequest
*	CALL OFS.GLOBUS.MANAGER(OFS.SOURCE.ID,OFS.MESSAGE)

	OFS.MSG.ID    = ''
	OPTIONS       = OPERATOR
	Y.OFS.TEMP.MESSAGE = vOfsMessageRequest
	Y.OFS.SOURCE	   = 'BIFAST'
	CALL OFS.POST.MESSAGE(Y.OFS.TEMP.MESSAGE, OFS.MSG.ID, Y.OFS.SOURCE, OPTIONS)

*	Y.OFS.SOURCE  = "BIFAST"
*	Y.OFS.MESSAGE = vOfsMessageRequest
*	CALL OFS.INITIALISE.SOURCE(Y.OFS.SOURCE, "", "LOG.ERROR.BIFAST")
*   CALL OFS.BUILD.RECORD(Y.APP.NAME, Y.OFS.FUNCT, Y.PROCESS, Y.OFS.VERSION, Y.GTS.MODE, Y.NO.OF.AUTH, Y.TRANSACTION.ID, R.FUNDS.TRANSFER, Y.OFS.MESSAGE)	
*   CALL OFS.BULK.MANAGER(Y.OFS.MESSAGE, Y.OFS.RESPONSE, "")

	flagOfs = 1

*	IF FIELD(OFS.MESSAGE, "/", 3)[1,1] NE "1" THEN
	IF flagOfs NE "1" THEN
**		E = FIELD(OFS.MESSAGE, ",", 2,99)
		R.NEW(BtpnsThBifastIncoming_SettlementStatus) = "DECLINED"
		R.NEW(BtpnsThBifastIncoming_ResponseCode) = "12"
		R.NEW(BtpnsThBifastIncoming_ErrorMessage) = FIELD(OFS.MESSAGE, ",", 2,99)
*		FOR idx=1 TO BtpnsThBifastIncoming_AuditDateTime
		FOR idx=1 TO 53
			rvArray<idx> = R.NEW(idx)
		NEXT idx

		APPL.NAME = APPLICATION
		VERSION.NAME = APPLICATION:",RAD"
		OFS.RECORD = '' ; GTSMODE = "" ; NO.OF.AUTH = '0'
		CALL OFS.BUILD.RECORD(APPL.NAME, 'I', 'PROCESS', VERSION.NAME, GTSMODE, NO.OF.AUTH, ID.NEW, rvArray, OFS.RECORD)	;*getting OFS MESSAGE format
		OFS.RECORD = CHANGE(OFS.RECORD,'ID0010001',ID.COMPANY)
		MSG.ID = '' ; OPTION = ''
		CALL OFS.POST.MESSAGE(OFS.RECORD, MSG.ID, OFS.SOURCE.ID, OPTION)	;*Posting OFS MESSAGE

	END ELSE
		R.NEW(BtpnsThBifastIncoming_FtSettlement) = idFt
		R.NEW(BtpnsThBifastIncoming_ResponseCode) = "00"
		CALL F.WRITE(fnTableTmp, TODAY:".":R.NEW(BtpnsThBifastIncoming_Rrn), ID.NEW)		

		GOSUB WriteTableReversalMap
	END
	
	Y.CUT.TIME = '1400'
	HHMM   = TIMEDATE()
    HHMM   = HHMM[1,2]:HHMM[4,2]
    IF HHMM GT Y.CUT.TIME THEN
        R.NEW(BtpnsThBifastIncoming_LocalRef)<1, fTimeCode> = "AFTERNOON"
    END ELSE
        R.NEW(BtpnsThBifastIncoming_LocalRef)<1, fTimeCode> = "MORNING"
    END
	R.NEW(BtpnsThBifastIncoming_LocalRef)<1, fSystemDate> = TODAY

	
	RETURN
	
*-----------------------------------------------------------------------------
ParseDataNational:
*-----------------------------------------------------------------------------

	
	vValueTM 	= R.NEW(BtpnsThBifastIncoming_TagTm)[5,(R.NEW(BtpnsThBifastIncoming_TagTm)[3,2]*1)]
	vValuePI 	= R.NEW(BtpnsThBifastIncoming_TagPi)[5,(R.NEW(BtpnsThBifastIncoming_TagPi)[3,2]*1)]
	vValueIFori = R.NEW(BtpnsThBifastIncoming_TagIf)[5,(R.NEW(BtpnsThBifastIncoming_TagIf)[3,2]*1)]
	vValueDI 	= R.NEW(BtpnsThBifastIncoming_TagDi)[5,(R.NEW(BtpnsThBifastIncoming_TagDi)[3,2]*1)]
	vValueCI 	= R.NEW(BtpnsThBifastIncoming_TagCi)[5,(R.NEW(BtpnsThBifastIncoming_TagCi)[3,2]*1)]

	IF vValueTM EQ '-' THEN vValueTM = ''
	IF vValuePI EQ '-' THEN vValuePI = ''
	IF vValueIFori EQ '-' THEN vValueIFori = ''
	IF vValueDI EQ '-' THEN vValueDI = ''
	IF vValueCI EQ '-' THEN vValueCI = ''
	
*	vCusReference = R.NEW(BtpnsThBifastIncoming_CusReference)
*	IF vCusReference EQ '-' THEN vCusReference = ''

	vValueIFfold = FOLD(vValueIFori, 35)

	
	RETURN
*-----------------------------------------------------------------------------
BuildOfsMessage:
*-----------------------------------------------------------------------------
	
	vOfsMessageRequest = "FUNDS.TRANSFER,BTPNS.BIFAST.INCOMING/I/PROCESS//,//":ID.COMPANY:",":idFt
	vOfsMessageRequest := ",TRANSACTION.TYPE=":rvParam<BtpnsTlBfastInterfaceParam_FttcIncoming>
	vOfsMessageRequest := ",DEBIT.CURRENCY=IDR"
	vOfsMessageRequest := ",DEBIT.ACCT.NO=":rvParam<BtpnsTlBfastInterfaceParam_BiNostro>	;*will be parameterized
	vOfsMessageRequest := ",DEBIT.THEIR.REF=":R.NEW(BtpnsThBifastIncoming_MsgStan)
*	vOfsMessageRequest := ",CREDIT.ACCT.NO=":R.NEW(BtpnsThBifastIncoming_ToAccount)
vOfsMessageRequest := ",CREDIT.ACCT.NO=":toAccount
	vOfsMessageRequest := ",CREDIT.CURRENCY=IDR"
	IF amtIncRound EQ '' THEN
		vOfsMessageRequest := ",CREDIT.AMOUNT=":R.NEW(BtpnsThBifastIncoming_TrxAmount)*1
	END ELSE
		vOfsMessageRequest := ",CREDIT.AMOUNT=":amtIncRound
	END
	
	vOfsMessageRequest := ",CREDIT.THEIR.REF=":TRIM(R.NEW(BtpnsThBifastIncoming_CusReference), ' ','B')
	vOfsMessageRequest := ",ORDERING.BANK=BTPNS"
	BEGIN CASE
	CASE vValueIFori NE ""
		FOR idx=1 TO DCOUNT(vValueIFfold, @FM)
			vOfsMessageRequest := ",PAYMENT.DETAILS:":idx:":1=":vValueIFfold<idx>
		NEXT idx
	CASE R.NEW(BtpnsThBifastIncoming_CusReference) NE ""
		vOfsMessageRequest := ",PAYMENT.DETAILS=":TRIM(R.NEW(BtpnsThBifastIncoming_CusReference), ' ','B')
	CASE OTHERWISE
		vOfsMessageRequest := ",PAYMENT.DETAILS=":TRIM(vDefaultNarrative, ' ','B')
	END CASE
	vOfsMessageRequest := ",PROFIT.CENTRE.DEPT=1"
	vOfsMessageRequest := ",B.DBTR.ACCTYPE=":R.NEW(BtpnsThBifastIncoming_TrxCode)[3,2]
	vOfsMessageRequest := ",B.CDTR.ACCTYPE=":R.NEW(BtpnsThBifastIncoming_TrxCode)[5,2]
	vOfsMessageRequest := ",B.CREDTTM=":R.NEW(BtpnsThBifastIncoming_TransDateTime)
	vOfsMessageRequest := ",B.CHNTYPE=":R.NEW(BtpnsThBifastIncoming_MerchantType)
	vOfsMessageRequest := ",IN.STAN=":R.NEW(BtpnsThBifastIncoming_MsgStan)
	vOfsMessageRequest := ",IN.TRNS.DT.TM=":R.NEW(BtpnsThBifastIncoming_TransDateTime)
	vOfsMessageRequest := ",IN.TERMINAL.ID=":R.NEW(BtpnsThBifastIncoming_TerminalId)
	vOfsMessageRequest := ",IN.REVERSAL.ID=":ID.NEW
	vOfsMessageRequest := ",B.CDTR.NM=":TRIM(R.NEW(BtpnsThBifastIncoming_CusCrName), ' ','B')
	vOfsMessageRequest := ",B.MSGID=":R.NEW(BtpnsThBifastIncoming_Rrn)
	vOfsMessageRequest := ",B.DBTR.NM=":TRIM(R.NEW(BtpnsThBifastIncoming_CusDbName), ' ','B')
	vOfsMessageRequest := ",B.DBTR.AGTID=":vBicCodeIssuer
	vOfsMessageRequest := ",B.DBTR.ACCID=":R.NEW(BtpnsThBifastIncoming_FromAccount)
*	vOfsMessageRequest := ",B.CDTR.ACCID=":R.NEW(BtpnsThBifastIncoming_ToAccount)
	vOfsMessageRequest := ",B.CDTR.ACCID=":toAccount
	IF R.COMPANY(Company_LocalRef)<1,fRtgsPos> THEN
		vOfsMessageRequest := ",B.CDTR.AGTID=":R.COMPANY(Company_LocalRef)<1,fRtgsPos>
	END ELSE
		vOfsMessageRequest := ",B.CDTR.AGTID=PUBAIDJ1"
	END
	vOfsMessageRequest := ",B.DBTR.RESSTS=0":vValueTM[4,1]
	vOfsMessageRequest := ",B.CDTR.RESSTS=0":vValueTM[5,1]
	vOfsMessageRequest := ",B.DBTR.TYPE=":vValueTM[2,1]
	vOfsMessageRequest := ",B.TXNTYPE=":RIGHT(vValuePI[1,5],3)
	vOfsMessageRequest := ",B.PRTRY=":vValueTM[3,1]
	vOfsMessageRequest := ",B.DBTR.ID=":vValueDI
	vOfsMessageRequest := ",B.CDTR.ID=":vValueCI
	vOfsMessageRequest := ",REMARKS=":R.NEW(BtpnsThBifastIncoming_Rrn)
	
	RETURN
	
*-----------------------------------------------------------------------------
WriteTableReversalMap:
*-----------------------------------------------------------------------------
	
	rvTableReversalMap = ""
	rvTableReversalMap<IdihWsDataFtMap_NoFt> = idFt
	rvTableReversalMap<IdihWsDataFtMap_TransactionType> = FIELD(FIELD(vOfsMessageRequest, ",TRANSACTION.TYPE=", 2), ",", 1)
	rvTableReversalMap<IdihWsDataFtMap_DebitAcctNo> = FIELD(FIELD(vOfsMessageRequest, ",DEBIT.ACCT.NO=", 2), ",", 1)
	rvTableReversalMap<IdihWsDataFtMap_DebitCurrency> = FIELD(FIELD(vOfsMessageRequest, ",DEBIT.CURRENCY=", 2), ",", 1)
	rvTableReversalMap<IdihWsDataFtMap_CreditCurrency> = FIELD(FIELD(vOfsMessageRequest, ",CREDIT.CURRENCY=", 2), ",", 1)
	rvTableReversalMap<IdihWsDataFtMap_CreditAcctNo> = FIELD(FIELD(vOfsMessageRequest, ",CREDIT.ACCT.NO=", 2), ",", 1)
	rvTableReversalMap<IdihWsDataFtMap_CreditAmount> = FIELD(FIELD(vOfsMessageRequest, ",CREDIT.AMOUNT=", 2), ",", 1)
	IF COUNT(vOfsMessageRequest, ",PAYMENT.DETAILS=") THEN
		rvTableReversalMap<IdihWsDataFtMap_PaymentDetails> = FIELD(FIELD(vOfsMessageRequest, ",PAYMENT.DETAILS=", 2), ",", 1)
	END ELSE
		rvTableReversalMap<IdihWsDataFtMap_PaymentDetails> = CHANGE(vValueIFfold, @FM, " ")[1,99]
	END
	rvTableReversalMap<IdihWsDataFtMap_ProccessingDate> = TODAY
	rvTableReversalMap<IdihWsDataFtMap_InProcDate> = TODAY
	rvTableReversalMap<IdihWsDataFtMap_InStan> = FIELD(FIELD(vOfsMessageRequest, ",IN.STAN=", 2), ",", 1)
	rvTableReversalMap<IdihWsDataFtMap_InTrnsDtTm> = FIELD(FIELD(vOfsMessageRequest, ",IN.TRNS.DT.TM=", 2), ",", 1)
	rvTableReversalMap<IdihWsDataFtMap_InTerminalId> = FIELD(FIELD(vOfsMessageRequest, ",IN.TERMINAL.ID=", 2), ",", 1)
	rvTableReversalMap<IdihWsDataFtMap_InReversalId> = FIELD(FIELD(vOfsMessageRequest, ",IN.REVERSAL.ID=", 2), ",", 1)
	rvTableReversalMap<IdihWsDataFtMap_InStatusRec> = "SUCCESS"
	rvTableReversalMap<IdihWsDataFtMap_CurrNo> = R.NEW(BtpnsThBifastIncoming_CurrNo)
	rvTableReversalMap<IdihWsDataFtMap_Inputter> = R.NEW(BtpnsThBifastIncoming_Inputter)
	rvTableReversalMap<IdihWsDataFtMap_DateTime> = R.NEW(BtpnsThBifastIncoming_DateTime)
	rvTableReversalMap<IdihWsDataFtMap_Authoriser> = R.NEW(BtpnsThBifastIncoming_Authoriser)
	rvTableReversalMap<IdihWsDataFtMap_CoCode> = R.NEW(BtpnsThBifastIncoming_CoCode)
	rvTableReversalMap<IdihWsDataFtMap_DeptCode> = R.NEW(BtpnsThBifastIncoming_DeptCode)

	CALL F.WRITE(fnTableReversalMap, "BIFAST.IN.":ID.NEW, rvTableReversalMap)
	
	RETURN
*-----------------------------------------------------------------------------
CheckRepeat:
*-----------------------------------------------------------------------------
	
	CALL F.READ(fnTableTmp, TODAY:".":R.NEW(BtpnsThBifastIncoming_Rrn), rTableTmp, fvTableTmp, '')
	idFtTmp = FIELD(rTableTmp<1>, ".", 2)

	CALL F.READ(fnFundsTransfer, idFtTmp, rFundsTransfer, fvFundsTransfer, '')
	IF rFundsTransfer NE '' THEN
		R.NEW(BtpnsThBifastIncoming_ResponseCode) = "00"
		flagRepeat	= 1
	END

	CALL F.READ(fnFundsTransferNau, idFtTmp, rFundsTransferNau, fvFundsTransferNau, '')
	IF rFundsTransferNau NE '' THEN
		R.NEW(BtpnsThBifastIncoming_ResponseCode) = "00"
		flagRepeat = 1
	END

	IF flagRepeat NE 1 THEN 
		R.NEW(BtpnsThBifastIncoming_SettlementStatus) = "DECLINED"
		R.NEW(BtpnsThBifastIncoming_ResponseCode) = "12"
	END
	
	RETURN

END 
