*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.CHECK.STATUS(idQueue)
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Alamsyah Rizki Isroi
* Development Date   : 20220715
* Description        : Routine to process BIFAST Check Status
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
    $INCLUDE I_F.BTPNS.TL.BFAST.INTERFACE.PARAM
    $INCLUDE I_F.IDCH.SKN.CLEARING.CODE
    $INCLUDE I_F.IDIH.WS.DATA.FT.MAP
    $INCLUDE I_F.FUNDS.TRANSFER
    $INCLUDE I_F.FT.TXN.TYPE.CONDITION
    $INCLUDE I_F.BTPNS.TH.BIFAST.OUTGOING
*-----------------------------------------------------------------------------

	COMMON/BIFAST.CHECK.STATUS.COM/fnTableInTmp,fvTableInTmp,fnTableIncoming,fvTableIncoming,fnFundsTransfer,fvFundsTransfer,
	fnFundsTransferHis,fvFundsTransferHis,fnBtnpsTlBfastInterfaceParam,fvBtnpsTlBfastInterfaceParam,fnTableOutgoing,fvTableOutgoing,
	fnTableOutTmp,fvTableOutTmp,fnIdihWsDataFtMap,fvIdihWsDataFtMap,fInReversalIdPos,fFtChargesPos,fAtiFtWaivePos,maxRetry

	vTypeTrx = FIELD(idQueue, "|", 1)
	idQueue = FIELD(idQueue, "|", 2)

	flagRetry = 0

*	SLEEP 45

	BEGIN CASE
	CASE vTypeTrx EQ "INCOMING"
		GOSUB ProcessIncoming
	CASE vTypeTrx EQ "OUTGOING"
		GOSUB ProcessOutgoing
	CASE OTHERWISE
		RETURN
	END CASE
	
*-----------------------------------------------------------------------------
ProcessOutgoing:
*-----------------------------------------------------------------------------

	idTableOutgoing = ""
	CALL F.READ(fnTableOutTmp, idQueue, rvTableTmp, fvTableOutTmp, "")
	idTableOutgoing = rvTableTmp<1>

	rvTableOutgoing = ""
	CALL F.READ(fnTableOutgoing, idTableOutgoing, rvTableOutgoing, fvTableOutgoing, "")
*enhance perubahan rrn
	vRrnValue = rvTableOutgoing<BtpnsThBifastOutgoing_RetrievalRefNo>

	CRT "itemDateTime=":rvTableOutgoing<BtpnsThBifastOutgoing_DateTime>
	
	idFt = idTableOutgoing
	idFtReverse	= idFt
	rvFundsTransfer = ""
	CALL F.READ(fnFundsTransfer, idFt, rvFundsTransfer, fvFundsTransfer, "")
	IF NOT(rvFundsTransfer) THEN CALL EB.READ.HISTORY.REC(fvFundsTransferHis, idFt, rvFundsTransfer, "")
	IF COUNT(idFt, ";") THEN idFt = FIELD(idFt, ";", 1)
	
	IF NOT(rvFundsTransfer) THEN RETURN
	
	idReversal = rvFundsTransfer<FundsTransfer_LocalRef,fInReversalIdPos>
	CALL F.READ(fnIdihWsDataFtMap, idReversal, rvIdihWsDataFtMap, fvIdihWsDataFtMap, "")
	
	BEGIN CASE
	CASE rvTableOutgoing EQ "" OR rvTableOutgoing<BtpnsThBifastOutgoing_SettlementStatus> EQ "PROCESSED"
		GOSUB DeleteQueueOutgoing
		RETURN
	CASE rvTableOutgoing<BtpnsThBifastOutgoing_SettlementStatus> EQ "DECLINED"
		IF rvFundsTransfer<FundsTransfer_RecordStatus> EQ "" THEN
			idFtReverse = idFt
			GOSUB ReverseFTOutgoing
			IF rvIdihWsDataFtMap<IdihWsDataFtMap_LocalRef,fFtChargesPos> THEN
				idFtReverse = rvIdihWsDataFtMap<IdihWsDataFtMap_LocalRef,fFtChargesPos>
				GOSUB ReverseFTOutgoing
			END
			IF rvIdihWsDataFtMap<IdihWsDataFtMap_LocalRef,fAtiFtWaivePos> THEN
				vListFtWaive = CHANGE(CHANGE(rvIdihWsDataFtMap<IdihWsDataFtMap_LocalRef,fAtiFtWaivePos>, @SM, @FM), @VM, @FM)
				FOR idx=1 TO DCOUNT(vListFtWaive, @FM)
					idFtReverse = vListFtWaive<idx>
					GOSUB ReverseFTOutgoing
				NEXT idx
			END
		END
		GOSUB DeleteQueueOutgoing
	CASE rvTableOutgoing<BtpnsThBifastOutgoing_SettlementStatus> EQ "PROCESSING"
*Check Retry Counter ----------
		checkRetryCounter	= rvTableOutgoing<BtpnsThBifastOutgoing_RetryCounter>
		IF checkRetryCounter EQ '' THEN
			checkRetryCounter = 0
		END
	
		IF maxRetry EQ '' THEN
			CALL OCOMO("Set paramter max retry id SYSTEM on table ":fnBtnpsTlBfastInterfaceParam)
		END

		IF checkRetryCounter GE maxRetry THEN
			GOSUB ReverseFTOutgoing
			GOSUB DeleteQueueOutgoing
			RETURN
		END ELSE
			GOSUB BuildJsonCheckStatusOutgoing
			vJsonResponse = ""
			vError = ""
			CRT "vType=":vType
			CRT "vJsonRequest=":vJsonRequest
			IF vJsonRequest THEN CALL BTPNSR.BIFAST.INTERFACE(vType,vJsonRequest,vJsonResponse,vError)
			CRT "vJsonResponse=":vJsonResponse
			CRT "vError=":vError

*testing
			vError = "ERROR"
			IF NOT(vError) THEN
				GOSUB ParseResponseOutgoing
			END ELSE
				CRT "Error process interface! ":vError
				GOSUB WriteRetryCounterOutgoing
				IF (checkRetryCounter+1) EQ maxRetry THEN
					GOSUB ReverseFTOutgoing
					GOSUB DeleteQueueOutgoing
					flagRetry = 1
				END
			END

			IF flagRetry NE 1 THEN
				IF vJsonResponse EQ '' THEN
					GOSUB WriteRetryCounterOutgoing
					IF (checkRetryCounter+1) EQ maxRetry THEN
						GOSUB ReverseFTOutgoing
						GOSUB DeleteQueueOutgoing
					END
				END
			END
		END
	CASE OTHERWISE
		GOSUB DeleteQueueOutgoing
	END CASE
	
	RETURN

*-----------------------------------------------------------------------------
ProcessIncoming:
*-----------------------------------------------------------------------------

	idTableIncoming = ""
	CALL F.READ(fnTableInTmp, idQueue, rvTableTmp, fvTableInTmp, "")
	idTableIncoming = rvTableTmp<1>

	rvTableIncoming = ""
	CALL F.READ(fnTableIncoming, idTableIncoming, rvTableIncoming, fvTableIncoming, "")
	
	BEGIN CASE
	CASE rvTableIncoming EQ "" OR rvTableIncoming<BtpnsThBifastIncoming_SettlementStatus> EQ "PROCESSED"
		GOSUB DeleteQueue
		RETURN
	CASE rvTableIncoming<BtpnsThBifastIncoming_SettlementStatus> EQ "DECLINED"
		idFt = rvTableIncoming<BtpnsThBifastIncoming_FtSettlement>
		rvFundsTransfer = ""
		CALL F.READ(fnFundsTransfer, idFt, rvFundsTransfer, fvFundsTransfer, "")
		IF NOT(rvFundsTransfer) THEN CALL EB.READ.HISTORY.REC(fvFundsTransferHis, idFt, rvFundsTransfer, "")
		IF rvFundsTransfer<FundsTransfer_RecordStatus> EQ "" THEN GOSUB ReverseFT
		GOSUB DeleteQueue
		RETURN
	CASE rvTableIncoming<BtpnsThBifastIncoming_SettlementStatus> EQ "PROCESSING"

*Check Retry Counter ----------
		checkRetryCounter	= rvTableIncoming<BtpnsThBifastIncoming_RetryCounter>
		IF checkRetryCounter EQ '' THEN checkRetryCounter = 0		

		IF maxRetry EQ '' THEN CALL OCOMO("Set paramter max retry id SYSTEM on table ":fnBtnpsTlBfastInterfaceParam)

		IF checkRetryCounter GE maxRetry THEN
*			GOSUB ReverseFT
			GOSUB DeleteQueue
			RETURN
		END ELSE
			GOSUB BuildJsonCheckStatus
			vJsonResponse = ""
			vError = ""
			CRT "vType=":vType
			CRT "vJsonRequest=":vJsonRequest

			CALL BTPNSR.BIFAST.INTERFACE(vType,vJsonRequest,vJsonResponse,vError)
			CRT "vJsonResponse=":vJsonResponse
			CRT "vError=":vError

*testing
			vError = "ERROR"

			IF NOT(vError) THEN
				GOSUB ParseResponse
			END ELSE
				CRT "Error process interface! ":vError
				GOSUB WriteRetryCounter
				IF (checkRetryCounter+1) EQ maxRetry THEN
					GOSUB DeleteQueue
					flagRetry = 1
				END
			END

			IF flagRetry NE 1 THEN
				IF vJsonResponse EQ '' THEN
					GOSUB WriteRetryCounter
					IF (checkRetryCounter+1) EQ maxRetry THEN
						GOSUB DeleteQueue
					END
				END
			END
			
		END
	CASE OTHERWISE
		GOSUB DeleteQueue
	END CASE
	
	RETURN
	
*-----------------------------------------------------------------------------
ParseResponse:
*-----------------------------------------------------------------------------
	
*{"BInqTrfRS":{"toAccount":"","msgType":"0210","fromAccount":"1010000226","retrievalReferenceNumber":"345076084205","transactionIndicator":"2","responseCode":"00","transmissionDateTime":"0718084340","trxCode":"391010","additionalDataPrivate":"ALDI SAPUTRA                  345076084205    ANDRIANSYAH                   ","merchantNameLocation":"KC BANDUNG                              ","msgSTAN":"345076","merchantType":"6847","trxDate":"0718","beneficiaryID":"91014","trxAmount":"700000.00","posConditionMode":"55","settlementDate":"0718","terminalID":"00006010","trxCurrencyCode":"360","issuerID":"92547","trxPAN":"3609254710100002260","forwardingID":"360000","merchantID":"ID0010014      ","additionalDataNational":"TM101011      TC0400  PI05B0510DI163270778680612111CI16      RN12345076084205","trxTime":"084340","posEntryMode":"011","acquirerID":"92547"}}
	
	IF COUNT(vJsonResponse, "responseCode") THEN
		vJsonParsed = CHANGE(CHANGE(vJsonResponse, '":"', '|'), '","', '|')
		vResponseCode = FIELD(FIELD(vJsonParsed, "responseCode", 2), "|", 2)
		IF vResponseCode EQ "00" THEN
			vStatus = "PROCESSED"
			GOSUB AuthFt
		END ELSE
			vStatus = "DECLINED"
			GOSUB ReverseFT
		END
		GOSUB UpdateTable
	END ELSE
		CRT "Unable to get responseCode ! ":vJsonResponse
	END
	
	RETURN
*-----------------------------------------------------------------------------
ReverseFT:
*-----------------------------------------------------------------------------
	
	vOfsMessageRequest = "FUNDS.TRANSFER,BTPNS.BIFAST.INCOMING/D/PROCESS//0,//":rvTableIncoming<BtpnsThBifastIncoming_CoCode>:",":rvTableIncoming<BtpnsThBifastIncoming_FtSettlement>
	
	OFS.SOURCE.ID = "BIFAST"
	OFS.MESSAGE = vOfsMessageRequest
	CALL OFS.GLOBUS.MANAGER(OFS.SOURCE.ID,OFS.MESSAGE)
    
	CHANGE '<requests>'           TO ''  IN OFS.MESSAGE
    CHANGE '</request><request>'  TO @FM IN OFS.MESSAGE
    CHANGE '<request>'            TO ''  IN OFS.MESSAGE
    CHANGE '</request>'           TO ''  IN OFS.MESSAGE
    CHANGE '</requests>'          TO ''  IN OFS.MESSAGE

	IF FIELD(OFS.MESSAGE, "/", 3)[1,1] EQ "1" THEN CRT "Reversed Transaction ":FIELD(OFS.MESSAGE, "/", 1)
	
	RETURN
*-----------------------------------------------------------------------------
UpdateTable:
*-----------------------------------------------------------------------------
	
	CRT "Transaction ":idTableIncoming:" update to ":vStatus
	
	rvTableIncoming<BtpnsThBifastIncoming_SettlementStatus> = vStatus
	
	CALL F.LIVE.WRITE(fnTableIncoming, idTableIncoming, rvTableIncoming)
	
	GOSUB DeleteQueue
	
	RETURN
*-----------------------------------------------------------------------------
BuildJsonCheckStatus:
*-----------------------------------------------------------------------------

	vAddDataPrivate = FMT(rvTableIncoming<BtpnsThBifastIncoming_CusCrName>, "L#30")
	vAddDataPrivate := FMT(rvTableIncoming<BtpnsThBifastIncoming_CusReference>, "L#16")
	vAddDataPrivate := FMT(rvTableIncoming<BtpnsThBifastIncoming_CusDbName>, "L#30")
	
	vAddDataNational = FMT(rvTableIncoming<BtpnsThBifastIncoming_TagTm>, "L#":(rvTableIncoming<BtpnsThBifastIncoming_TagTm>[3,2]+4))
	vAddDataNational := FMT(rvTableIncoming<BtpnsThBifastIncoming_TagTc>, "L#":(rvTableIncoming<BtpnsThBifastIncoming_TagTc>[3,2]+4))
	vAddDataNational := FMT(rvTableIncoming<BtpnsThBifastIncoming_TagPi>, "L#":(rvTableIncoming<BtpnsThBifastIncoming_TagPi>[3,2]+4))
	vAddDataNational := FMT(rvTableIncoming<BtpnsThBifastIncoming_TagDi>, "L#":(rvTableIncoming<BtpnsThBifastIncoming_TagDi>[3,2]+4))
	vAddDataNational := FMT(rvTableIncoming<BtpnsThBifastIncoming_TagCi>, "L#":(rvTableIncoming<BtpnsThBifastIncoming_TagCi>[3,2]+4))
	vAddDataNational := FMT(rvTableIncoming<BtpnsThBifastIncoming_TagRn>, "L#":(rvTableIncoming<BtpnsThBifastIncoming_TagRn>[3,2]+4))
	vAddDataNational := FMT(rvTableIncoming<BtpnsThBifastIncoming_TagIf>, "L#":(rvTableIncoming<BtpnsThBifastIncoming_TagIf>[3,2]+4))
	
	
	vType = "BCheckStatusRQ"
	vJsonRequest = "{"
	vJsonRequest := DQUOTE("msgType"):":":DQUOTE("0200"):","
	vJsonRequest := DQUOTE("trxPAN"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_TrxPan>):","
	vJsonRequest := DQUOTE("trxCode"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_TrxCode>):","
	vJsonRequest := DQUOTE("trxAmount"):":":DQUOTE(FMT(rvTableIncoming<BtpnsThBifastIncoming_TrxAmount>, "R2%")):","
	vJsonRequest := DQUOTE("transmissionDateTime"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_TransDateTime>):","
	vJsonRequest := DQUOTE("msgSTAN"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_MsgStan>):","
	vJsonRequest := DQUOTE("trxTime"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_TrxTime>):","
	vJsonRequest := DQUOTE("trxDate"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_TrxDate>):","
	vJsonRequest := DQUOTE("settlementDate"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_SettlementDate>):","
	vJsonRequest := DQUOTE("merchantType"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_MerchantType>):","
	vJsonRequest := DQUOTE("posEntryMode"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_PosEntryMode>):","
	vJsonRequest := DQUOTE("posConditionMode"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_PosConditionMode>):","
	vJsonRequest := DQUOTE("acquirerID"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_AcquirerId>):","
	vJsonRequest := DQUOTE("forwardingID"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_ForwardingId>):","
	vJsonRequest := DQUOTE("retrievalReferenceNumber"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_Rrn>):","
	vJsonRequest := DQUOTE("terminalID"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_TerminalId>):","
	vJsonRequest := DQUOTE("merchantID"):":":DQUOTE(FMT(rvTableIncoming<BtpnsThBifastIncoming_MerchantId>,"L#15")):","
	IF rvTableIncoming<BtpnsThBifastIncoming_MerchantNameLoc> THEN
		vJsonRequest := DQUOTE("merchantNameLocation"):":":DQUOTE(FMT(rvTableIncoming<BtpnsThBifastIncoming_MerchantNameLoc>,"L#40")):","
	END ELSE
		vJsonRequest := DQUOTE("merchantNameLocation"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_MerchantNameLoc>):","
	END
	vJsonRequest := DQUOTE("additionalDataPrivate"):":":DQUOTE(vAddDataPrivate):","
	vJsonRequest := DQUOTE("trxCurrencyCode"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_TrxCurrencyCode>):","
	vJsonRequest := DQUOTE("encryptedData"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_EncryptedData>):","
	vJsonRequest := DQUOTE("additionalDataNational"):":":DQUOTE(vAddDataNational):","
	vJsonRequest := DQUOTE("issuerID"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_IssuerId>):","
	vJsonRequest := DQUOTE("fromAccount"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_FromAccount>):","
	vJsonRequest := DQUOTE("toAccount"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_ToAccount>):","
	vJsonRequest := DQUOTE("transactionIndicator"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_TrxIndicator>):","
	vJsonRequest := DQUOTE("beneficiaryID"):":":DQUOTE(rvTableIncoming<BtpnsThBifastIncoming_BeneficiaryId>)
	vJsonRequest := "}"

    RETURN

*-----------------------------------------------------------------------------
DeleteQueue:
*-----------------------------------------------------------------------------
	
	CALL F.DELETE(fnTableInTmp, idQueue)
	CALL JOURNAL.UPDATE(fnTableInTmp)

    RETURN
*-----------------------------------------------------------------------------
WriteRetryCounter:
*-----------------------------------------------------------------------------
	
	rvTableIncoming = ""

    LOOP
        ITEMLOCKED = 0
        READU rvTableIncoming FROM fvTableIncoming, idTableIncoming LOCKED
            ITEMLOCKED = 1
            MSLEEP 200
        END THEN
			rvTableIncoming<BtpnsThBifastIncoming_RetryCounter> = checkRetryCounter + 1
*			WRITE rvTableIncoming TO fvTableIncoming, idTableIncoming
			CALL F.LIVE.WRITE(fnTableIncoming, idTableIncoming, rvTableIncoming)
		END ELSE
			RELEASE fvTableIncoming, idTableIncoming
		END
	WHILE ITEMLOCKED DO
    REPEAT

	CRT "Process Write Retry Counter with reference : ":rvTableIncoming<BtpnsThBifastIncoming_FtSettlement>:" and retry counter ":(checkRetryCounter + 1)

    RETURN
*-----------------------------------------------------------------------------
AuthFt:
*-----------------------------------------------------------------------------
	
	vOfsMessageRequest = ''
	vOfsMessageRequest = "FUNDS.TRANSFER,BTPNS.BIFAST.INCOMING/A/PROCESS//0,//":rvTableIncoming<BtpnsThBifastIncoming_CoCode>:",":rvTableIncoming<BtpnsThBifastIncoming_FtSettlement>
	
	OFS.SOURCE.ID = ''
	OFS.SOURCE.ID = "BIFAST"

	OFS.MESSAGE = ''
	OFS.MESSAGE = vOfsMessageRequest
	CALL OFS.GLOBUS.MANAGER(OFS.SOURCE.ID,OFS.MESSAGE)
    
	CHANGE '<requests>'           TO ''  IN OFS.MESSAGE
    CHANGE '</request><request>'  TO @FM IN OFS.MESSAGE
    CHANGE '<request>'            TO ''  IN OFS.MESSAGE
    CHANGE '</request>'           TO ''  IN OFS.MESSAGE
    CHANGE '</requests>'          TO ''  IN OFS.MESSAGE

	IF FIELD(OFS.MESSAGE, "/", 3)[1,1] EQ "1" THEN CRT "Reversed Transaction ":FIELD(OFS.MESSAGE, "/", 1)
	
	RETURN

*-----------------------------------------------------------------------------
ParseResponseOutgoing:
*-----------------------------------------------------------------------------
	
*{"BInqTrfRS":{"toAccount":"","msgType":"0210","fromAccount":"1010000226","retrievalReferenceNumber":"345076084205","transactionIndicator":"2","responseCode":"00","transmissionDateTime":"0718084340","trxCode":"391010","additionalDataPrivate":"ALDI SAPUTRA                  345076084205    ANDRIANSYAH                   ","merchantNameLocation":"KC BANDUNG                              ","msgSTAN":"345076","merchantType":"6847","trxDate":"0718","beneficiaryID":"91014","trxAmount":"700000.00","posConditionMode":"55","settlementDate":"0718","terminalID":"00006010","trxCurrencyCode":"360","issuerID":"92547","trxPAN":"3609254710100002260","forwardingID":"360000","merchantID":"ID0010014      ","additionalDataNational":"TM101011      TC0400  PI05B0510DI163270778680612111CI16      RN12345076084205","trxTime":"084340","posEntryMode":"011","acquirerID":"92547"}}
	
	IF COUNT(vJsonResponse, "responseCode") THEN
		vJsonParsed = CHANGE(CHANGE(vJsonResponse, '":"', '|'), '","', '|')
		vResponseCode = FIELD(FIELD(vJsonParsed, "responseCode", 2), "|", 2)

		IF vResponseCode EQ "00" THEN
			vStatus = "PROCESSED"
		END ELSE
			vStatus = "DECLINED"
			idFtReverse = idFt
			GOSUB ReverseFTOutgoing
			IF rvIdihWsDataFtMap<IdihWsDataFtMap_LocalRef,fFtChargesPos> THEN
				idFtReverse = rvIdihWsDataFtMap<IdihWsDataFtMap_LocalRef,fFtChargesPos>
				GOSUB ReverseFTOutgoing
			END
			IF rvIdihWsDataFtMap<IdihWsDataFtMap_LocalRef,fAtiFtWaivePos> THEN
				vListFtWaive = CHANGE(CHANGE(rvIdihWsDataFtMap<IdihWsDataFtMap_LocalRef,fAtiFtWaivePos>, @SM, @FM), @VM, @FM)
				FOR idx=1 TO DCOUNT(vListFtWaive, @FM)
					idFtReverse = vListFtWaive<idx>
					GOSUB ReverseFTOutgoing
				NEXT idx
			END
		END
		GOSUB UpdateTableOutgoing
	END ELSE
		CRT "Unable to get responseCode ! ":vJsonResponse
	END
	
	RETURN
*-----------------------------------------------------------------------------
ReverseFTOutgoing:
*-----------------------------------------------------------------------------
*	idFtReverse = idFt
	vOfsMessageRequest = "FUNDS.TRANSFER,DMI/R/PROCESS//0,//":rvTableOutgoing<BtpnsThBifastOutgoing_CoCode>:",":idFtReverse
	
	OFS.SOURCE.ID = "BIFAST"
	OFS.MESSAGE = vOfsMessageRequest
	CALL OFS.GLOBUS.MANAGER(OFS.SOURCE.ID,OFS.MESSAGE)
    
	CHANGE '<requests>'           TO ''  IN OFS.MESSAGE
    CHANGE '</request><request>'  TO @FM IN OFS.MESSAGE
    CHANGE '<request>'            TO ''  IN OFS.MESSAGE
    CHANGE '</request>'           TO ''  IN OFS.MESSAGE
    CHANGE '</requests>'          TO ''  IN OFS.MESSAGE

	IF FIELD(OFS.MESSAGE, "/", 3)[1,1] EQ "1" THEN CRT "Reversed Transaction ":FIELD(OFS.MESSAGE, "/", 1)
	
	RETURN
*-----------------------------------------------------------------------------
UpdateTableOutgoing:
*-----------------------------------------------------------------------------
	
	CRT "Transaction ":idTableOutgoing:" update to ":vStatus
	
	IF vResponseCode THEN rvTableOutgoing<BtpnsThBifastOutgoing_ResponseCode> = vResponseCode
	rvTableOutgoing<BtpnsThBifastOutgoing_SettlementStatus> = vStatus
	
	CALL F.LIVE.WRITE(fnTableOutgoing, idTableOutgoing, rvTableOutgoing)
	
	GOSUB DeleteQueueOutgoing
	
	RETURN
*-----------------------------------------------------------------------------
BuildJsonCheckStatusOutgoing:
*-----------------------------------------------------------------------------

	vJsonRequest = ""
*	vRrnValue = RIGHT(rvFundsTransfer<FundsTransfer_LocalRef,fInReversalIdPos>,12)

	idTableConcatLog = TODAY:".BTrfRQ.":vRrnValue
	rvTableConcatLog = ""
	CALL F.READ(fnTableConcatLog, idTableConcatLog, rvTableConcatLog, fvTableConcatLog, "")
	IF NOT(rvTableConcatLog) THEN
		CALL OCOMO("Unable to get original JSON message of ":idFt:" on table ":fnTableConcatLog)
	END ELSE
		vType = "BCheckStatusRQ"
		vJsonRequest = rvTableConcatLog<1>
	END

    RETURN

*-----------------------------------------------------------------------------
DeleteQueueOutgoing:
*-----------------------------------------------------------------------------
	
	CALL F.DELETE(fnTableOutTmp, idQueue)
	CALL JOURNAL.UPDATE(fnTableOutTmp)

    RETURN
*-----------------------------------------------------------------------------
WriteRetryCounterOutgoing:
*-----------------------------------------------------------------------------
	
	rvTableOutgoing = ""
    LOOP
        ITEMLOCKED = 0
        READU rvTableOutgoing FROM fvTableOutgoing, idTableOutgoing LOCKED
            ITEMLOCKED = 1
            MSLEEP 200
        END THEN
			rvTableOutgoing<BtpnsThBifastOutgoing_RetryCounter> = checkRetryCounter + 1
*			WRITE rvTableOutgoing TO fvTableOutgoing, idTableOutgoing
			CALL F.LIVE.WRITE(fnTableOutgoing, idTableOutgoing, rvTableOutgoing)
		END ELSE
			RELEASE fvTableOutgoing, idTableOutgoing
		END
	WHILE ITEMLOCKED DO
    REPEAT

	CRT "Process Write Retry Counter with reference : ":idFt:" and retry counter ":(checkRetryCounter + 1)

    RETURN

END 