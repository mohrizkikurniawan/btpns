*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.CHECK.STATUS.OUT(idQueue)
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Alamsyah Rizki Isroi
* Development Date   : 20220718
* Description        : Routine to process BIFAST Outgoing Check Status
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
    $INCLUDE I_F.BTPNS.TH.BIFAST.OUTGOING
    $INCLUDE I_F.BTPNS.TL.BFAST.INTERFACE.PARAM
    $INCLUDE I_F.IDCH.SKN.CLEARING.CODE
    $INCLUDE I_F.IDIH.WS.DATA.FT.MAP
    $INCLUDE I_F.OVERRIDE
    $INCLUDE I_F.TELLER
    $INCLUDE I_F.FUNDS.TRANSFER
    $INCLUDE I_F.FT.TXN.TYPE.CONDITION
*-----------------------------------------------------------------------------

	COMMON/BIFAST.CHECK.STATUS.OUT.COM/fnTableTmp,fvTableTmp,fnTableOutgoing,fvTableOutgoing,fnFundsTransfer,fvFundsTransfer,fnTableConcatLog,fvTableConcatLog,
	fnFundsTransferHis,fvFundsTransferHis,fInReversalIdPos,fnIdihWsDataFtMap,fvIdihWsDataFtMap,fFtChargesPos,fAtiFtWaivePos,fnBtnpsTlBfastInterfaceParam,fvBtnpsTlBfastInterfaceParam

*	SLEEP 45
	GOSUB Initialise
	GOSUB MainProcess
	
	RETURN
	
*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------
	
	idTableOutgoing = ""
	CALL F.READ(fnTableTmp, idQueue, rvTableTmp, fvTableTmp, "")
	idTableOutgoing = rvTableTmp<1>
	
	Y.DATE = OCONV(DATE(),'DYMD')
    Y.DATE = CHANGE(Y.DATE, ' ', '')
    Y.TIME = CHANGE(TIMEDATE(), ':', '')
    vDateTime = Y.DATE[3,6] : Y.TIME[1,4]
	
	flagRetry = 0
	RETURN
	
*-----------------------------------------------------------------------------
MainProcess:
*-----------------------------------------------------------------------------

	rvTableOutgoing = ""
	CALL F.READ(fnTableOutgoing, idTableOutgoing, rvTableOutgoing, fvTableOutgoing, "")
*enhance perubahan rrn
	vRrnValue = rvTableOutgoing<BtpnsThBifastOutgoing_RetrievalRefNo>
	CRT "vDateTime=":vDateTime
	CRT "itemDateTime=":rvTableOutgoing<BtpnsThBifastOutgoing_DateTime>

	checkRetryCounterFirst	= rvTableOutgoing<BtpnsThBifastOutgoing_RetryCounter>
	IF checkRetryCounterFirst EQ '' THEN
		SLEEP 45
	END

*	IF (vDateTime - rvTableOutgoing<BtpnsThBifastOutgoing_DateTime>) LE 2 THEN RETURN
*	SLEEP 10
	CALL F.READ(fnTableOutgoing, idTableOutgoing, rvTableOutgoing, fvTableOutgoing, "")

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
		GOSUB DeleteQueue
		RETURN
	CASE rvTableOutgoing<BtpnsThBifastOutgoing_SettlementStatus> EQ "DECLINED"
		IF rvFundsTransfer<FundsTransfer_RecordStatus> EQ "" THEN
			idFtReverse = idFt
			GOSUB ReverseFT
			IF rvIdihWsDataFtMap<IdihWsDataFtMap_LocalRef,fFtChargesPos> THEN
				idFtReverse = rvIdihWsDataFtMap<IdihWsDataFtMap_LocalRef,fFtChargesPos>
				GOSUB ReverseFT
			END
			IF rvIdihWsDataFtMap<IdihWsDataFtMap_LocalRef,fAtiFtWaivePos> THEN
				vListFtWaive = CHANGE(CHANGE(rvIdihWsDataFtMap<IdihWsDataFtMap_LocalRef,fAtiFtWaivePos>, @SM, @FM), @VM, @FM)
				FOR idx=1 TO DCOUNT(vListFtWaive, @FM)
					idFtReverse = vListFtWaive<idx>
					GOSUB ReverseFT
				NEXT idx
			END
		END
		GOSUB DeleteQueue
	CASE rvTableOutgoing<BtpnsThBifastOutgoing_SettlementStatus> EQ "PROCESSING"
*Check Retry Counter ----------
		checkRetryCounter	= rvTableOutgoing<BtpnsThBifastOutgoing_RetryCounter>
		IF checkRetryCounter EQ '' THEN
*			SLEEP 20
			checkRetryCounter = 0
		END ELSE
			SLEEP 5
		END

		CALL F.READ(fnTableOutgoing, idTableOutgoing, rvTableOutgoing, fvTableOutgoing, "")
		IF rvTableOutgoing<BtpnsThBifastOutgoing_SettlementStatus> EQ "PROCESSED" THEN
			GOSUB DeleteQueue
			RETURN		
		END
		
		CALL F.READ(fnBtnpsTlBfastInterfaceParam, "SYSTEM", rvBtnpsTlBfastInterfaceParam, fvBtnpsTlBfastInterfaceParam, "")
		maxRetry = rvBtnpsTlBfastInterfaceParam<BtpnsTlBfastInterfaceParam_MaxRetry>

		IF maxRetry EQ '' THEN
			CALL OCOMO("Set paramter max retry id SYSTEM on table ":fnBtnpsTlBfastInterfaceParam)
		END

		IF checkRetryCounter GE maxRetry THEN
			*GOSUB ReverseFT
			GOSUB DeleteQueue
			RETURN
		END ELSE
			GOSUB BuildJsonCheckStatus
			vJsonResponse = ""
			vError = ""
			CRT "vType=":vType
			CRT "vJsonRequest=":vJsonRequest

			CALL F.READ(fnTableOutgoing, idTableOutgoing, rvTableOutgoing, fvTableOutgoing, "")
			IF rvTableOutgoing<BtpnsThBifastOutgoing_SettlementStatus> EQ "PROCESSED" THEN
				RETURN
			END ELSE
				IF vJsonRequest THEN CALL BTPNSR.BIFAST.INTERFACE(vType,vJsonRequest,vJsonResponse,vError)
			END

			CRT "vJsonResponse=":vJsonResponse
			CRT "vError=":vError

			IF NOT(vError) THEN
				GOSUB ParseResponse
			END ELSE
				CRT "Error process interface! ":vError
				GOSUB WriteRetryCounter
				IF (checkRetryCounter+1) EQ maxRetry THEN
					*GOSUB ReverseFT
					GOSUB DeleteQueue
					flagRetry = 1
				END
			END

			IF flagRetry NE 1 THEN
				IF vJsonResponse EQ '' THEN
					GOSUB WriteRetryCounter
					IF (checkRetryCounter+1) EQ maxRetry THEN
						*GOSUB ReverseFT
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
		END ELSE
			vStatus = "DECLINED"
			idFtReverse = idFt
			GOSUB ReverseFT
			*IF rvIdihWsDataFtMap<IdihWsDataFtMap_LocalRef,fFtChargesPos> THEN
			*	idFtReverse = rvIdihWsDataFtMap<IdihWsDataFtMap_LocalRef,fFtChargesPos>
			*	GOSUB ReverseFT
			*END
			*IF rvIdihWsDataFtMap<IdihWsDataFtMap_LocalRef,fAtiFtWaivePos> THEN
			*	vListFtWaive = CHANGE(CHANGE(rvIdihWsDataFtMap<IdihWsDataFtMap_LocalRef,fAtiFtWaivePos>, @SM, @FM), @VM, @FM)
			*	FOR idx=1 TO DCOUNT(vListFtWaive, @FM)
			*		idFtReverse = vListFtWaive<idx>
			*		GOSUB ReverseFT
			*	NEXT idx
			*END
		END
		GOSUB UpdateTable
	END ELSE
		CRT "Unable to get responseCode ! ":vJsonResponse
	END
	
	RETURN
*-----------------------------------------------------------------------------
ReverseFT:
*-----------------------------------------------------------------------------
*	idFtReverse = idFt
	vOfsMessageRequest = "FUNDS.TRANSFER,BIFAST.OUTGOING.REVE/R/PROCESS//0,//":rvTableOutgoing<BtpnsThBifastOutgoing_CoCode>:",":idFtReverse
	
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
	
	CRT "Transaction ":idTableOutgoing:" update to ":vStatus
	
	IF vResponseCode THEN rvTableOutgoing<BtpnsThBifastOutgoing_ResponseCode> = vResponseCode
	rvTableOutgoing<BtpnsThBifastOutgoing_SettlementStatus> = vStatus
	
	CALL F.LIVE.WRITE(fnTableOutgoing, idTableOutgoing, rvTableOutgoing)
	
	GOSUB DeleteQueue
	
	RETURN
*-----------------------------------------------------------------------------
BuildJsonCheckStatus:
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
DeleteQueue:
*-----------------------------------------------------------------------------
	
	CALL F.DELETE(fnTableTmp, idQueue)
	CALL JOURNAL.UPDATE(fnTableTmp)

    RETURN
*-----------------------------------------------------------------------------
WriteRetryCounter:
*-----------------------------------------------------------------------------
	
	rvTableOutgoing = ""
*	CALL F.READ(fnTableOutgoing, idTableOutgoing, rvTableOutgoing, fvTableOutgoing, "")
	
*	rvTableOutgoing<BtpnsThBifastOutgoing_RetryCounter> = checkRetryCounter + 1

*	expirationDate	= rvTableIncoming<BtpnsThBifastIncoming_ExpirationDate>
*	rvTableIncoming<BtpnsThBifastIncoming_ExpirationDate> := "|" : Y.TIME

*	CALL F.LIVE.WRITE(fnTableOutgoing, idTableOutgoing, rvTableOutgoing)

    LOOP
        ITEMLOCKED = 0
        READU rvTableOutgoing FROM fvTableOutgoing, idTableOutgoing LOCKED
            ITEMLOCKED = 1
            MSLEEP 200
        END THEN
			rvTableOutgoing<BtpnsThBifastOutgoing_RetryCounter> = checkRetryCounter + 1
			WRITE rvTableOutgoing TO fvTableOutgoing, idTableOutgoing
		END ELSE
			RELEASE fvTableOutgoing, idTableOutgoing
		END
	WHILE ITEMLOCKED DO
    REPEAT

	CRT "Process Write Retry Counter with reference : ":idFt:" and retry counter ":(checkRetryCounter + 1)

    RETURN

END 