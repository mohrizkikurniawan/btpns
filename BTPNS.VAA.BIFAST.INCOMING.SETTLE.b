*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.VAA.BIFAST.INCOMING.SETTLE
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Alamsyah Rizki Isroi
* Development Date   : 20220704
* Description        : Routine to process BIFAST Incoming SETTLEMENT
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* Date           	: 20220924
* Modified by    	: Moh Rizki Kurniawan
* Description		: Add OFS Authorize FT
*-----------------------------------------------------------------------------
* Date           	: 20220924
* Modified by    	: Moh Rizki Kurniawan
* Description		: Add Flag to check settlement declined
*-----------------------------------------------------------------------------
    $INCLUDE I_COMMON
    $INCLUDE I_EQUATE
    $INCLUDE I_GTS.COMMON
    $INCLUDE I_F.BTPNS.TH.BIFAST.INCOMING
    $INCLUDE I_F.BTPNS.TH.BIFAST.OUTGOING
    $INCLUDE I_F.BTPNS.TL.BFAST.INTERFACE.PARAM
	$INCLUDE I_F.FUNDS.TRANSFER
	$INCLUDE I_F.ACCOUNT
	$INCLUDE I_F.AA.ACTIVITY.HISTORY
	$INSERT I_IO.EQUATE
*-----------------------------------------------------------------------------
	
	IF R.NEW(BtpnsThBifastIncoming_Rrn) EQ "" THEN
		E = "EB-BIFAST.INVALID.RRN"
	END ELSE
		GOSUB Initialise
		GOSUB MainProcess	
	END

	RETURN
	
*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------
	
	fnApplicationIN = "F.":APPLICATION
	fvApplicationIN = ""
	CALL OPF(fnApplicationIN, fvApplicationIN)

	fnTableTmpIN = "F.BTPNS.TL.BIFAST.INCOMING.TMP"
	fvTableTmpIN = ""
	CALL OPF(fnTableTmpIN, fvTableTmpIN)
	
	fnApplicationOUT = "F.BTPNS.TH.BIFAST.OUTGOING"
	fvApplicationOUT = ""
	CALL OPF(fnApplicationOUT, fvApplicationOUT)

	fnTableTmpOUT = "F.BTPNS.TL.BIFAST.OUTGOING.TMP"
	fvTableTmpOUT = ""
	CALL OPF(fnTableTmpOUT, fvTableTmpOUT)

	fnBtpnsTlSettlementDeclined = "F.BTPNS.TL.SETTLEMENT.DECLINED"
	fvBtpnsTlSettlementDeclined = ""
	CALL OPF(fnBtpnsTlSettlementDeclined, fvBtpnsTlSettlementDeclined)

	fnBtpnsTlSettlementQueue   = "F.BTPNS.TL.SETTLEMENT.QUEUE"
	fvBtpnsTlSettlementQueue   = ""
	CALL OPF(fnBtpnsTlSettlementQueue, fvBtpnsTlSettlementQueue)

	fnAccount				   = "F.ACCOUNT"
	fvAccount				   = ""
	CALL OPF(fnAccount, fvAccount)

	fnAaActivityHistory		   = "F.AA.ACTIVITY.HISTORY"
	fvAaActivityHistory		   = ""
	CALL OPF(fnAaActivityHistory, fvAaActivityHistory)

	fnBtpnsThBifastIncomingNau	= "F.BTPNS.TH.BIFAST.INCOMING$NAU"
	fvBtpnsThBifastIncomingNau	= ""
	CALL OPF(fnBtpnsThBifastIncomingNau, fvBtpnsThBifastIncomingNau)

	fnFundsTransferNau			= "F.FUNDS.TRANSFER$NAU"
	fvFundsTransferNau			= ""
	CALL OPF(fnFundsTransferNau, fvFundsTransferNau)

	fnBtpnsTlBifastSettlement   = "F.BTPNS.TL.BIFAST.SETTLEMENT"
	fvBtpnsTlBifastSettlement   = ""
	CALL OPF(fnBtpnsTlBifastSettlement, fvBtpnsTlBifastSettlement)

	RETURN
	
*-----------------------------------------------------------------------------
MainProcess:
*-----------------------------------------------------------------------------
	
	R.NEW(BtpnsThBifastIncoming_MsgType) = '0212'
	*SLEEP 15
	idTableTmp = TODAY:".":R.NEW(BtpnsThBifastIncoming_Rrn)
	rvTableTmp = ""
	CALL F.READ(fnTableTmpIN, idTableTmp, rvTableTmp, fvTableTmpIN, "")
	IF rvTableTmp THEN
		GOSUB ProcessIncoming
	END ELSE
		SLEEP 15
		CALL F.READ(fnTableTmpOUT, idTableTmp, rvTableTmp, fvTableTmpOUT, "")
		IF rvTableTmp THEN
			GOSUB ProcessOutgoing
		END ELSE
			CALL F.READ(fnBtpnsTlSettlementQueue, idTableTmp, rvBtpnsTlSettlementQueue, fvBtpnsTlSettlementQueue, "")
			IF rvBtpnsTlSettlementQueue EQ '' THEN
				R.NEW(BtpnsThBifastIncoming_ResponseCode)     = "12"
				R.NEW(BtpnsThBifastIncoming_ApiType)          = "B.STLM.TRF.RQ"
				R.NEW(BtpnsThBifastIncoming_SettlementStatus) = "DECLINED"
				R.NEW(BtpnsThBifastIncoming_ErrorMessage)	  = "table temporary belum terbentuk"
				selCmd = "SELECT " : fnBtpnsThBifastIncomingNau : " WITH RRN EQ " : R.NEW(BtpnsThBifastIncoming_Rrn)
				CALL EB.READLIST(selCmd, selList, "", selCnt, selErr)
				IF selList EQ '' THEN
					selCmd = "SELECT " : fnApplicationIN : " WITH RRN EQ " : R.NEW(BtpnsThBifastIncoming_Rrn)
					CALL EB.READLIST(selCmd, selList, "", selCnt, selErr)
				END
				rvTableTmp = selList
				CALL F.WRITE(fnBtpnsTlSettlementDeclined,idTableTmp, rvTableTmp)
			END ELSE
				GOSUB ProcessIncomingReversal
			END
		END
	END
	
	RETURN
	
*-----------------------------------------------------------------------------
ProcessIncoming:
*-----------------------------------------------------------------------------
	
	idApplication = rvTableTmp<1>
	rvApplication = ""
	CALL F.READ(fnApplicationIN, rvTableTmp<1>, rvApplication, fvApplicationIN, "")

*get Id Funds Transfer
	idFt	= rvApplication<BtpnsThBifastIncoming_FtSettlement>

	IF rvApplication EQ "" THEN
		E = "EB-BIFAST.INVALID.RRN"
		RETURN
	END
	
	BEGIN CASE
	*CASE rvApplication<BtpnsThBifastIncoming_SettlementStatus> EQ "PROCESSED"
	*	E = "EB-BIFAST.ALREADY.PROCESSED"
	*	CALL F.DELETE(fnTableTmpIN,idTableTmp)
	*	RETURN
	*CASE rvApplication<BtpnsThBifastIncoming_SettlementStatus> EQ "DECLINED"
	*	E = "EB-BIFAST.DECLINED"
	*	CALL F.DELETE(fnTableTmpIN,idTableTmp)
	*	RETURN
	CASE rvApplication<BtpnsThBifastIncoming_SettlementStatus> EQ "PROCESSING"
		rvApplication<BtpnsThBifastIncoming_SettlementStatus> = "PROCESSED"
	CASE rvApplication<BtpnsThBifastIncoming_SettlementStatus> EQ ""
		rvApplication<BtpnsThBifastIncoming_SettlementStatus> = "PROCESSED"
	END CASE

	CALL F.READ(fnFundsTransferNau, idFt, rvFundsTransferNau, fvFundsTransferNau, "")
	recordStatus	= rvFundsTransferNau<FundsTransfer_RecordStatus>

	BEGIN CASE
	CASE recordStatus EQ 'INAU'
		GOSUB AuthFt
		CALL F.WRITE(fnBtpnsTlSettlementDeclined,idTableTmp, rvTableTmp)
	CASE recordStatus EQ 'IHLD'
		CALL F.WRITE(fnBtpnsTlSettlementDeclined,idTableTmp, rvTableTmp)
	CASE recordStatus EQ ''
		CALL F.WRITE(fnBtpnsTlBifastSettlement,idTableTmp, rvTableTmp)
	END CASE
	
	R.NEW(BtpnsThBifastIncoming_ResponseCode) = "00"
	R.NEW(BtpnsThBifastIncoming_ApiType) = "B.STLM.TRF.RQ"
	CALL F.LIVE.WRITE(fnApplicationIN, idApplication, rvApplication)
	CALL F.DELETE(fnTableTmpIN,idTableTmp)

	
	RETURN	
*-----------------------------------------------------------------------------
ProcessOutgoing:
*-----------------------------------------------------------------------------
	
	idApplication = rvTableTmp<1>
	vLine := "idApplication : " : idApplication : CHARX(13) : CHARX(10)
	rvApplication = ""
	CALL F.READ(fnApplicationOUT, rvTableTmp<1>, rvApplication, fvApplicationOUT, "")
	vLine := "fnApplicationOUT : " : fnApplicationOUT :" fvApplicationOUT " :fvApplicationOUT: CHARX(13) : CHARX(10)
	IF rvApplication EQ "" THEN
		E = "EB-BIFAST.INVALID.RRN"
		RETURN
	END
	
	BEGIN CASE
	CASE rvApplication<BtpnsThBifastOutgoing_SettlementStatus> EQ "PROCESSED"
		E = "EB-BIFAST.ALREADY.PROCESSED"
		R.NEW(BtpnsThBifastIncoming_ResponseCode) = "94"
		CALL F.DELETE(fnTableTmpOUT,idTableTmp)
		RETURN
	CASE rvApplication<BtpnsThBifastOutgoing_SettlementStatus> EQ "DECLINED"
		E = "EB-BIFAST.DECLINED"
		R.NEW(BtpnsThBifastIncoming_ResponseCode) = "12"
		CALL F.DELETE(fnTableTmpOUT,idTableTmp)
		RETURN
	CASE rvApplication<BtpnsThBifastOutgoing_SettlementStatus> EQ "PROCESSING"
		rvApplication<BtpnsThBifastOutgoing_SettlementStatus> = "PROCESSED"
	CASE rvApplication<BtpnsThBifastOutgoing_SettlementStatus> EQ ""
		rvApplication<BtpnsThBifastOutgoing_SettlementStatus> = "PROCESSED"
		rvApplication<BtpnsThBifastOutgoing_ResponseCode> = "00"
	END CASE
	
	FOR idx=1 TO BtpnsThBifastIncoming_AuditDateTime
		IF R.NEW(idx) EQ "" THEN CONTINUE
		rvApplicationCopy<idx> = R.NEW(idx)
	NEXT idx

	R.NEW(BtpnsThBifastIncoming_ResponseCode) = "00"
	R.NEW(BtpnsThBifastIncoming_ApiType) = "B.STLM.TRF.RQ"
	rvApplicationCopy<BtpnsThBifastIncoming_ApiType> = "B.TRF.RQ"
	rvApplicationCopy<BtpnsThBifastIncoming_ResponseCode> = "00"
	rvApplicationCopy<BtpnsThBifastIncoming_SettlementStatus> = "PROCESSED"
	rvApplicationCopy<BtpnsThBifastIncoming_Reserved1> = "OUTGOING"
*	CALL F.LIVE.WRITE(fnApplicationIN, TODAY:".":CHANGE(TIMESTAMP(),".",""), rvApplicationCopy)
*	CALL F.LIVE.WRITE(fnApplicationIN, TODAY:".":idApplication, rvApplicationCopy)
	CALL F.WRITE(fnApplicationIN, TODAY:".":idApplication, rvApplicationCopy)
	CALL F.LIVE.WRITE(fnApplicationOUT, idApplication, rvApplication)
	CALL F.DELETE(fnTableTmpOUT,idTableTmp)

*    vLine := "fnApplicationIN : " : fnApplicationIN : " " : TODAY:".":idApplication:" rvApplicationCopy " : rvApplicationCopy: CHARX(13) : CHARX(10)
*    vLine := "fnApplicationOUT : " : fnApplicationOUT : " ":idApplication:" rvApplication " : rvApplication: CHARX(13) : CHARX(10)

*	WRITESEQ vLine APPEND TO fvFile ELSE
*        PRINT 'Process Write ERROR'
*    END
	
	RETURN	
*-----------------------------------------------------------------------------
AuthFt:
*-----------------------------------------------------------------------------

	OFS.MSG.ID    = ''
	OPTIONS       = OPERATOR
	Y.OFS.TEMP.MESSAGE = "FUNDS.TRANSFER,BTPNS.BIFAST.INCOMING/A/PROCESS//,//":ID.COMPANY:",":idFt
	Y.OFS.SOURCE	   = 'BIFAST'
	CALL OFS.POST.MESSAGE(Y.OFS.TEMP.MESSAGE, OFS.MSG.ID, Y.OFS.SOURCE, OPTIONS)
	
	RETURN
*-----------------------------------------------------------------------------
ProcessIncomingReversal:
*-----------------------------------------------------------------------------

	R.NEW(BtpnsThBifastIncoming_ResponseCode) = "00"
	R.NEW(BtpnsThBifastIncoming_ApiType) = "B.STLM.TRF.RQ"

	idApplication = rvBtpnsTlSettlementQueue<1>
	rvApplication = ""
	CALL F.READ(fnApplicationIN, rvBtpnsTlSettlementQueue<1>, rvApplication, fvApplicationIN, "")
	rvApplication<BtpnsThBifastIncoming_SettlementStatus> = "DECLINED"

	idFt	= rvApplication<BtpnsThBifastIncoming_FtSettlement>	

	idAccount	= rvApplication<BtpnsThBifastIncoming_ToAccount>
	CALL F.READ(fnAccount, idAccount, rvAccount, fvAccount, "")
	idArrangement  = rvAccount<Account_ArrangementId>
	companyAccount = rvAccount<Account_CoCode>

	CALL F.READ(fnAaActivityHistory, idArrangement, rvAaArrangmenetHistory, fvAaActivityHistory, "")
	contractId		= rvAaArrangmenetHistory<AA.AH.CONTRACT.ID>
	activityRef     = rvAaArrangmenetHistory<AA.AH.ACTIVITY.REF>

	FINDSTR idFt IN contractId SETTING YPOSF, YPOSV, YPOSS THEN
		activityId	= activityRef<YPOSF, YPOSV, YPOSS>
	END

*    Y.APP.NAME       = "AA.ARRANGEMENT.ACTIVITY"
*    Y.OFS.FUNCT      = "R"
*    Y.PROCESS        = "PROCESS"
*    Y.VERSION        = "AA.ARRANGEMENT.ACTIVITY,"
*    Y.GTS.MODE       = "1"
*    Y.NO.OF.AUTH     = 0
*    Y.TRANSACTION.ID = activityId
* 	R.ACL.OFS        = ""
* 	Y.OFS.SOURCE	= 'DS.PACKAGE'
*
*	CALL LOAD.COMPANY(companyAccount)
*    CALL OFS.BUILD.RECORD(Y.APP.NAME, Y.OFS.FUNCT, Y.PROCESS, Y.VERSION, Y.GTS.MODE, Y.NO.OF.AUTH, Y.TRANSACTION.ID, R.ACL.OFS, Y.OFS.MESSAGE)
*	Y.OFS.RESPONSE = ''
*	CALL OFS.CALL.BULK.MANAGER(Y.OFS.SOURCE, Y.OFS.MESSAGE, Y.OFS.RESPONSE, Y.TXN.RESULT)	

*	Y.OFS.TEMP.MESSAGE = "AA.ARRANGEMENT.ACTIVITY,/R/PROCESS//,//":companyAccount:",":activityId
*
*	OFS.SOURCE.ID = "BIFAST"
*	OFS.MESSAGE = Y.OFS.TEMP.MESSAGE
*	CALL OFS.GLOBUS.MANAGER(OFS.SOURCE.ID,OFS.MESSAGE)

*	OFS.MSG.ID    = ''
*	OPTIONS       = OPERATOR
*	Y.OFS.TEMP.MESSAGE = "AA.ARRANGEMENT.ACTIVITY,/R/PROCESS//,//":companyAccount:",":activityId
*	Y.OFS.SOURCE	   = 'BIFAST'
*	CALL OFS.POST.MESSAGE(Y.OFS.TEMP.MESSAGE, OFS.MSG.ID, Y.OFS.SOURCE, OPTIONS)

	Y.OFS.TEMP.MESSAGE = ''

	OFS.MSG.ID    = ''
	OPTIONS       = OPERATOR
	Y.OFS.TEMP.MESSAGE = "FUNDS.TRANSFER,BTPNS.BIFAST.INCOMING/D/PROCESS//,//":ID.COMPANY:",":idFt
	Y.OFS.SOURCE	   = 'BIFAST'
	CALL OFS.POST.MESSAGE(Y.OFS.TEMP.MESSAGE, OFS.MSG.ID, Y.OFS.SOURCE, OPTIONS)

*	Y.OFS.TEMP.MESSAGE = "FUNDS.TRANSFER,BTPNS.BIFAST.INCOMING/D/PROCESS//,//":ID.COMPANY:",":idFt
*
*	OFS.SOURCE.ID = "BIFAST"
*	OFS.MESSAGE = Y.OFS.TEMP.MESSAGE
*	CALL OFS.GLOBUS.MANAGER(OFS.SOURCE.ID,OFS.MESSAGE)

	CALL F.LIVE.WRITE(fnApplicationIN, idApplication, rvApplication)
	CALL F.DELETE(fnBtpnsTlSettlementQueue,idTableTmp)
	
	RETURN
	
END 