*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.REVERSAL.CREDIT(idQueue)
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Alamsyah Rizki Isroi
* Development Date   : 20220715
* Description        : Routine to process BIFAST Incoming Check Status
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
	$INCLUDE I_F.BTPNS.TH.BIFAST.INCOMING
	$INCLUDE I_F.FUNDS.TRANSFER
	$INCLUDE I_F.CUSTOMER

*-----------------------------------------------------------------------------

	COMMON/BTPNS.MT.BIFAST.REVERSAL.CREDIT.COM/fnBtpnsTlSettlementDeclined,fvBtpnsTlSettlementDeclined,fnBtpnsTlBifastInterface,
	fvBtpnsTlBifastInterface,fnBtpnsThBifastIncoming,fvBtpnsThBifastIncoming,fnFundsTransfer,fvFundsTransfer,fnOfsMessageQueue,
	fvOfsMessageQueue,fnFundsTransferNau,fvFundsTransferNau,atiJname2Pos,bDbtrNmPos,bCdtrPrxytypePos,bCdtrTypePos,bDbtrResstsPos,
	bCdtrResstsPos,bDbtrIdPos,fnBtpnsTlSettlementQueue,fvBtpnsTlSettlementQueue,fnBtpnsThBifastIncomingNau,fvBtpnsThBifastIncomingNau,fnCustomer,fvCustomer,legalIdNo,fnBtpnsTlBifastSettlement,fvBtpnsTlBifastSettlement
	
	GOSUB Initialise
	
	RETURN
	
*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------
	
	CALL F.READ(fnBtpnsTlSettlementDeclined, idQueue, rvBtpnsTlSettlementDeclined, fvBtpnsTlSettlementDeclined, "")
	idIncoming = rvBtpnsTlSettlementDeclined<1>
	idFt	   = FIELDS(idIncoming, ".", 2)
	flagBtpnsThIncoming = ""

	*selList 	= ""
	*recordFt    = 1
	*allRecordQueue = ""
	*LOOP
	*MSLEEP 200
	*WHILE recordFt DO
    *	selCmd		= "SELECT " : fnOfsMessageQueue : " WITH @ID LIKE ...BIFAST..."
    *	CALL EB.READLIST(selCmd, selList, "", selCnt, selErr)
	*	FOR yLoop = 1 TO selCnt
	*		idOfsQueue = selList<yLoop>
	*		CALL F.READ(fnOfsMessageQueue, idOfsQueue, rvOfsMessageQueue, fvOfsMessageQueue, "")
	*		allRecordQueue := rvOfsMessageQueue
	*	NEXT yLoop
	*	allRecordQueue := "BIFAST"
	*	recordFt = DCOUNT(allRecordQueue, idFt)
	*	recordFt = recordFt - 1
	*	allRecordQueue = ""
	*REPEAT

	CALL F.READ(fnBtpnsTlBifastSettlement, idQueue, rvBtpnsTlBifastSettlement, fvBtpnsTlBifastSettlement, "")
	IF rvBtpnsTlBifastSettlement THEN RETURN

	CALL F.READ(fnFundsTransferNau, idFt, rvFundsTransferNau, fvFundsTransferNau, "")
	recordStatus = rvFundsTransferNau<FundsTransfer_RecordStatus>

	CALL F.READ(fnFundsTransfer, idFt, rvFundsTransfer, fvFundsTransfer, "")
	IF rvFundsTransfer NE '' OR recordStatus EQ 'INAU' THEN
		CALL F.DELETE(fnBtpnsTlSettlementDeclined,idQueue)
		RETURN
	END ELSE
		CALL F.READ(fnBtpnsThBifastIncoming, idIncoming, rvBtpnsThBifastIncoming, fvBtpnsThBifastIncoming, "")
		IF rvBtpnsThBifastIncoming EQ '' THEN
			CALL F.READ(fnBtpnsThBifastIncomingNau, idIncoming, rvBtpnsThBifastIncomingNau, fvBtpnsThBifastIncomingNau, "")
			GOSUB MainProcessNau
		END ELSE
			flagBtpnsThIncoming = rvBtpnsThBifastIncoming
			GOSUB MainProcess
		END	
	END
	
	RETURN
	
*-----------------------------------------------------------------------------
MainProcess:
*-----------------------------------------------------------------------------

	Y.MSG.TYPE     = '0200'
	Y.TRX.PAN      = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TrxPan>[1,8] : rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_ToAccount>
	Y.TRX.CODE	   = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TrxCode>[1,2] : rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TrxCode>[5,2] : rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TrxCode>[3,2]
	Y.AMOUNT	   = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TrxAmount>
	Y.TRANSMIT.DT  = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TransDateTime>
	Y.IN.STAN	   = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_MsgStan>
	Y.TRX.TIME	   = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TrxTime>
	Y.TRX.DATE     = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TrxDate>
	Y.SETTLE.DATE  = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_SettlementDate>
	Y.MERCHANT.TYPE= rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_MerchantType>
	Y.POS.ENTRY	   = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_PosEntryMode>

	Y.POS.COND	   = '53'
*	Y.POS.COND	   = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_PosConditionMode>
	Y.ACQUIRER.ID  = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_BeneficiaryId>
	Y.FORWARD.ID   = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_ForwardingId>
	Y.RETRIEVE.REF = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_Rrn>
	Y.TERMINAL.ID  = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TerminalId>
	Y.MERCHANT.ID  = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_MerchantId>
	Y.MERCHANT.ID  = FMT(Y.MERCHANT.ID,"L#15")

	cityCountryCode = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_MerchantNameLoc>[7]
	terminalId		= FIELDS(rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_MerchantNameLoc>, cityCountryCode, 1)
	blankSpace 		= ""
	Y.MERCHANT.LOC = FMT(terminalId,"L#32") : FMT(blankSpace,"L#1")  : FMT(cityCountryCode,"L#8")

*	Y.ADD.DATA.PRIVATE = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_AddDataPrivate>
*	Y.ADD.DATA.PRIVATE = FMT(Y.ADD.DATA.PRIVATE,"L#76")

	Y.ATI.JNAME.2	   = rvFundsTransferNau<FundsTransfer_LocalRef, atiJname2Pos>
	Y.DBTR.NM		   = rvFundsTransferNau<FundsTransfer_LocalRef, bDbtrNmPos>
*	Y.ADD.DATA.PRIVATE = FMT(Y.ATI.JNAME.2,"L#30"):FMT(Y.RETRIEVE.REF,"L#16"):FMT(Y.DBTR.NM,"L#30")
	Y.ADD.DATA.PRIVATE = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_AddDataPrivate>
	FINDSTR Y.RETRIEVE.REF IN Y.ADD.DATA.PRIVATE SETTING Y.POSS THEN
		Y.ADD.DATA.PRIVATE = FMT(rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_CusDbName>, "L#30") : FMT(Y.RETRIEVE.REF,"L#16") : FMT(rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_CusCrName>, "L#30")
	END ELSE
		blankSpace = ""
		Y.ADD.DATA.PRIVATE = FMT(rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_CusDbName>, "L#30") : FMT(blankSpace,"L#16") : FMT(rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_CusCrName>, "L#30")
	END

	Y.CCY.ID	   = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TrxCurrencyCode>

	Y.CDTR.PRXY.TYPE = rvFundsTransferNau<FundsTransfer_LocalRef, bCdtrPrxytypePos>
	Y.CDTR.TYPE		 = rvFundsTransferNau<FundsTransfer_LocalRef, bCdtrTypePos>
	Y.DBTR.RESSTS    = rvFundsTransferNau<FundsTransfer_LocalRef, bDbtrResstsPos>
	Y.CDTR.RESSTS	 = rvFundsTransferNau<FundsTransfer_LocalRef, bCdtrResstsPos>
*	Y.DBTR.RESSTS    = NUM(Y.DBTR.RESSTS)
*	Y.CDTR.RESSTS    = NUM(Y.CDTR.RESSTS)
*	Y.TM		   = 'TM10':Y.CDTR.PRXY.TYPE:Y.CDTR.TYPE:'0':Y.DBTR.RESSTS:Y.CDTR.RESSTS
	Y.TM			 = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TagTm>
	Y.TM             = FMT(Y.TM,"L#14")
	Y.TC			 = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TagTc>
	Y.TC             = FMT(Y.TC,"L#8")
	Y.PI             = 'PI05B0011'
	Y.DBTR.ID		 = rvFundsTransferNau<FundsTransfer_LocalRef, bDbtrIdPos>
*	Y.DI             = "DI16":FMT(Y.DBTR.ID,"L#16")
*	Y.CI             = FMT("CI16","L#20")
	IF FIELDS(rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TagCi>, "CI", 2) EQ '00' THEN
		creditCustomer	 = rvFundsTransferNau<FundsTransfer_CreditCustomer>
		CALL F.READ(fnCustomer, creditCustomer, rvCustomer, fvCustomer, "")
		nikNumber		 = rvCustomer<Customer_LocalRef, legalIdNo>
*		Y.DI 			 = "DI" : nikNumber
		IF nikNumber EQ '' THEN nikNumber = "12345678"
		Y.DI 			 = "DI":FMT(LEN(nikNumber), 'R%2') : nikNumber
	END ELSE
		Y.DI			 = "DI" : FIELDS(rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TagCi>, "CI", 2)
	END

*	Y.DI			 = FMT(Y.DI,"L#16")
	Y.CI			 = "CI" : FIELDS(rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TagDi>, "DI", 2)
*	Y.CI			 = FMT(Y.CI,"L#20")
	Y.IN.REVERSAL.ID = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_Rrn>
	Y.RN             = 'RN12':FMT(Y.IN.REVERSAL.ID[12],"L#12")
	Y.IF			 = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TagIf>
	Y.ADD.DATA.NAS = Y.TM:Y.TC:Y.PI:Y.DI:Y.CI:Y.RN:Y.IF
*	Y.ADD.DATA.NAS = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_AddDataNational>
*	Y.ADD.DATA.NAS = FMT(Y.ADD.DATA.PRIVATE,"L#70")

	Y.ISSUER.ID    = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_BeneficiaryId>
	Y.FROM.ACC	   = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_ToAccount>
	Y.TO.ACC	   = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_FromAccount>
	Y.TXN.INDICATOR= rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TrxIndicator>
	Y.BENEF.ID	   = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_IssuerId>

	GOSUB BuildJson

	RETURN
	
*-----------------------------------------------------------------------------
BuildJson:
*-----------------------------------------------------------------------------
	
	XX = ':'
    Y.TYPE = 'BTrfRQ'
	Y.OPEN   = '{'
    Y.CLOSE = '}'
	Y.PARAM = Y.OPEN
	Y.PARAM :='"msgType"':XX:DQUOTE(Y.MSG.TYPE)
    Y.PARAM :=',"trxPAN"':XX:DQUOTE(Y.TRX.PAN)
    Y.PARAM :=',"trxCode"':XX:DQUOTE(Y.TRX.CODE)         
    Y.PARAM :=',"trxAmount"':XX:DQUOTE(Y.AMOUNT)
    Y.PARAM :=',"transmissionDateTime"':XX:DQUOTE(Y.TRANSMIT.DT)
    Y.PARAM :=',"msgSTAN"':XX:DQUOTE(Y.IN.STAN)
	Y.PARAM :=',"trxTime"':XX:DQUOTE(Y.TRX.TIME)
	Y.PARAM :=',"trxDate"':XX:DQUOTE(Y.TRX.DATE)
	Y.PARAM :=',"settlementDate"':XX:DQUOTE(Y.SETTLE.DATE)
	Y.PARAM :=',"merchantType"':XX:DQUOTE(Y.MERCHANT.TYPE)
	Y.PARAM :=',"posEntryMode"':XX:DQUOTE(Y.POS.ENTRY)
	Y.PARAM :=',"posConditionMode"':XX:DQUOTE(Y.POS.COND)
	Y.PARAM :=',"acquirerID"':XX:DQUOTE(Y.ACQUIRER.ID)
	Y.PARAM :=',"forwardingID"':XX:DQUOTE(Y.FORWARD.ID)
	Y.PARAM :=',"retrievalReferenceNumber"':XX:DQUOTE(Y.RETRIEVE.REF)
	Y.PARAM :=',"terminalID"':XX:DQUOTE(Y.TERMINAL.ID)
	Y.PARAM :=',"merchantID"':XX:DQUOTE(Y.MERCHANT.ID)
	Y.PARAM :=',"merchantNameLocation"':XX:DQUOTE(Y.MERCHANT.LOC)
	Y.PARAM :=',"additionalDataPrivate"':XX:DQUOTE(Y.ADD.DATA.PRIVATE)
	Y.PARAM :=',"trxCurrencyCode"':XX:DQUOTE(Y.CCY.ID)
	Y.PARAM :=',"encryptedData"':XX:DQUOTE("")
	Y.PARAM :=',"additionalDataNational"':XX:DQUOTE(Y.ADD.DATA.NAS)
	Y.PARAM :=',"issuerID"':XX:DQUOTE(Y.ISSUER.ID)
	Y.PARAM :=',"fromAccount"':XX:DQUOTE(Y.FROM.ACC)
	Y.PARAM :=',"toAccount"':XX:DQUOTE(Y.TO.ACC)
	Y.PARAM :=',"transactionIndicator"':XX:DQUOTE(Y.TXN.INDICATOR)
	Y.PARAM :=',"beneficiaryID"':XX:DQUOTE(Y.BENEF.ID)
	Y.PARAM := Y.CLOSE

	CALL BTPNSR.BIFAST.INTERFACE(Y.TYPE,Y.PARAM,RESP.POS,RESP.ERR)
	GOSUB CheckResponse

	RETURN
*-----------------------------------------------------------------------------
CheckResponse:
*-----------------------------------------------------------------------------

    FINDSTR '"responseCode"' IN RESP.POS SETTING POS THEN
		Y.RESPONSE.TEMP = EREPLACE(EREPLACE(RESP.POS,'":"','|'),'","','|')
		Y.RESPONSE = CHANGE(CHANGE(Y.RESPONSE.TEMP,'"',''),'}','')
   	END
   	Y.RESPONSE.CODE.RES    = FIELDS(FIELDS(Y.RESPONSE,'responseCode',2),'|',2)
   
   	IF Y.RESPONSE.CODE.RES EQ '00' THEN
		rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_SettlementStatus> = "DECLINING"
		rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_ResponseCode>		= Y.RESPONSE.CODE.RES

		rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_SettlementStatus> = "DECLINING"
		rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_ResponseCode>		= Y.RESPONSE.CODE.RES

		CALL F.DELETE(fnBtpnsTlSettlementDeclined,idQueue)
		CALL F.WRITE(fnBtpnsTlSettlementQueue, idQueue, rvBtpnsTlSettlementDeclined)
		

		OFS.MSG.ID    = ''
		OPTIONS       = OPERATOR
		Y.OFS.TEMP.MESSAGE = "FUNDS.TRANSFER,BTPNS.BIFAST.INCOMING/D/PROCESS//,//":ID.COMPANY:",":idFt
		Y.OFS.SOURCE	   = 'BIFAST'
		CALL OFS.POST.MESSAGE(Y.OFS.TEMP.MESSAGE, OFS.MSG.ID, Y.OFS.SOURCE, OPTIONS)
   	END ELSE
		rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_SettlementStatus> = "DECLINING"
		rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_ResponseCode>		= Y.RESPONSE.CODE.RES
		rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_ErrorMessage>		= "error Reversal Credit Transfer"	

		rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_SettlementStatus> = "DECLINING"
		rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_ResponseCode>		= Y.RESPONSE.CODE.RES
		rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_ErrorMessage>		= "error Reversal Credit Transfer"	

*for running one time
		CALL F.DELETE(fnBtpnsTlSettlementDeclined,idQueue)
   	END

	IF flagBtpnsThIncoming EQ '' THEN
		CALL F.WRITE(fnBtpnsThBifastIncomingNau, idIncoming, rvBtpnsThBifastIncomingNau)
	END ELSE
		CALL F.LIVE.WRITE(fnBtpnsThBifastIncoming, idIncoming, rvBtpnsThBifastIncoming)
	END
	

	RETURN
*-----------------------------------------------------------------------------
MainProcessNau:
*-----------------------------------------------------------------------------

	Y.MSG.TYPE     = '0200'
	Y.TRX.PAN      = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_TrxPan>[1,8] : rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_ToAccount>
	Y.TRX.CODE	   = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_TrxCode>[1,2] : rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_TrxCode>[5,2] : rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_TrxCode>[3,2]
	Y.AMOUNT	   = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_TrxAmount>
	Y.TRANSMIT.DT  = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_TransDateTime>
	Y.IN.STAN	   = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_MsgStan>
	Y.TRX.TIME	   = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_TrxTime>
	Y.TRX.DATE     = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_TrxDate>
	Y.SETTLE.DATE  = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_SettlementDate>
	Y.MERCHANT.TYPE= rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_MerchantType>
	Y.POS.ENTRY	   = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_PosEntryMode>

	Y.POS.COND	   = '53'
*	Y.POS.COND	   = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_PosConditionMode>
	Y.ACQUIRER.ID  = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_BeneficiaryId>
	Y.FORWARD.ID   = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_ForwardingId>
	Y.RETRIEVE.REF = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_Rrn>
	Y.TERMINAL.ID  = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_TerminalId>
	Y.MERCHANT.ID  = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_MerchantId>
	Y.MERCHANT.ID  = FMT(Y.MERCHANT.ID,"L#15")

	cityCountryCode = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_MerchantNameLoc>[7]
	terminalId		= FIELDS(rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_MerchantNameLoc>, cityCountryCode, 1)
	blankSpace 		= ""
	Y.MERCHANT.LOC = FMT(terminalId,"L#32") : FMT(blankSpace,"L#1")  : FMT(cityCountryCode,"L#8")

*	Y.ADD.DATA.PRIVATE = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_AddDataPrivate>
*	Y.ADD.DATA.PRIVATE = FMT(Y.ADD.DATA.PRIVATE,"L#76")

	Y.ATI.JNAME.2	   = rvFundsTransferNau<FundsTransfer_LocalRef, atiJname2Pos>
	Y.DBTR.NM		   = rvFundsTransferNau<FundsTransfer_LocalRef, bDbtrNmPos>
*	Y.ADD.DATA.PRIVATE = FMT(Y.ATI.JNAME.2,"L#30"):FMT(Y.RETRIEVE.REF,"L#16"):FMT(Y.DBTR.NM,"L#30")
	Y.ADD.DATA.PRIVATE = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_AddDataPrivate>
	FINDSTR Y.RETRIEVE.REF IN Y.ADD.DATA.PRIVATE SETTING Y.POSS THEN
		Y.ADD.DATA.PRIVATE = FMT(rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_CusDbName>, "L#30") : FMT(Y.RETRIEVE.REF,"L#16") : FMT(rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_CusCrName>, "L#30")
	END ELSE
		blankSpace = ""
		Y.ADD.DATA.PRIVATE = FMT(rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_CusDbName>, "L#30") : FMT(blankSpace,"L#16") : FMT(rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_CusCrName>, "L#30")
	END

	Y.CCY.ID	   = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_TrxCurrencyCode>

	Y.CDTR.PRXY.TYPE = rvFundsTransferNau<FundsTransfer_LocalRef, bCdtrPrxytypePos>
	Y.CDTR.TYPE		 = rvFundsTransferNau<FundsTransfer_LocalRef, bCdtrTypePos>
	Y.DBTR.RESSTS    = rvFundsTransferNau<FundsTransfer_LocalRef, bDbtrResstsPos>
	Y.CDTR.RESSTS	 = rvFundsTransferNau<FundsTransfer_LocalRef, bCdtrResstsPos>
*	Y.DBTR.RESSTS    = NUM(Y.DBTR.RESSTS)
*	Y.CDTR.RESSTS    = NUM(Y.CDTR.RESSTS)
	Y.TM			 = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TagTm>
	Y.TM             = FMT(Y.TM,"L#14")
	Y.TC			 = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TagTc>
	Y.TC             = FMT(Y.TC,"L#8")
	Y.PI             = 'PI05B0011'
	Y.DBTR.ID		 = rvFundsTransferNau<FundsTransfer_LocalRef, bDbtrIdPos>
*	Y.DI             = "DI16":FMT(Y.DBTR.ID,"L#16")
*	Y.CI             = FMT("CI16","L#20")
	IF FIELDS(rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TagCi>, "CI", 2) EQ '00' THEN
		creditCustomer	 = rvFundsTransferNau<FundsTransfer_CreditCustomer>
		CALL F.READ(fnCustomer, creditCustomer, rvCustomer, fvCustomer, "")
		nikNumber		 = rvCustomer<Customer_LocalRef, legalIdNo>
		IF nikNumber EQ '' THEN nikNumber = "12345678"
		Y.DI 			 = "DI":FMT(LEN(nikNumber), 'R%2') : nikNumber
	END ELSE
		Y.DI			 = "DI" : FIELDS(rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TagCi>, "CI", 2)
	END

*	Y.DI			 = FMT(Y.DI,"L#16")
	Y.CI			 = "CI" : FIELDS(rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TagDi>, "DI", 2)
*	Y.CI			 = FMT(Y.CI,"L#20")
	Y.IN.REVERSAL.ID = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_Rrn>
	Y.RN             = 'RN12':FMT(Y.IN.REVERSAL.ID[12],"L#12")
	Y.IF			 = rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_TagIf>
	Y.ADD.DATA.NAS = Y.TM:Y.TC:Y.PI:Y.DI:Y.CI:Y.RN:Y.IF
*	Y.ADD.DATA.NAS = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_AddDataNational>
*	Y.ADD.DATA.NAS = FMT(Y.ADD.DATA.PRIVATE,"L#70")

	Y.ISSUER.ID    = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_BeneficiaryId>
	Y.FROM.ACC	   = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_ToAccount>
	Y.TO.ACC	   = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_FromAccount>
	Y.TXN.INDICATOR= rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_TrxIndicator>
	Y.BENEF.ID	   = rvBtpnsThBifastIncomingNau<BtpnsThBifastIncoming_IssuerId>

	GOSUB BuildJson

	RETURN

END 