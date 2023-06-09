*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.INC.AUTH(idQueue)
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20220715
* Description        : Routine to process autorize FT settle queue
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
	$INCLUDE I_F.FUNDS.TRANSFER
	$INCLUDE I_F.BTPNS.TH.BIFAST.INCOMING

*-----------------------------------------------------------------------------

	COMMON/BTPNS.MT.BIFAST.INC.AUTH.COM/fnFundsTransfer,fvFundsTransfer,fnFundsTransferNau,fvFundsTransferNau,fnBtpnsThBifastIncoming,fvBtpnsThBifastIncoming
	
	GOSUB Initialise
	
	RETURN
	
*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------

	idFt	= FIELD(idQueue, ".", 2)

*	IF idFt EQ 'FT22094N0T5Y' OR idFt EQ 'FT22094XBSDQ' THEN
*		DEBUG
*	END

	CALL F.READ(fnBtpnsThBifastIncoming, idQueue, rvBtpnsThBifastIncoming, fvBtpnsThBifastIncoming, '')
	ftSettlement	= rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_FtSettlement>
	settlementStatus= rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_SettlementStatus>
	apiType			= rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_ApiType>
	reserved1		= rvBtpnsThBifastIncoming<BtpnsThBifastIncoming_Reserved1>

	IF settlementStatus NE 'PROCESSED' THEN RETURN
	IF apiType NE 'B.TRF.RQ' THEN RETURN
	IF reserved1 EQ 'OUTGOING' THEN RETURN

	CALL F.READ(fnFundsTransferNau, ftSettlement, rvFundsTransferNau, fvFundsTransferNau, '')
	recordStatus		= rvFundsTransferNau<FundsTransfer_RecordStatus>
	IF recordStatus EQ 'INAU' AND settlementStatus EQ 'PROCESSED' THEN
		GOSUB AuthFt
	END

	RETURN
	
*-----------------------------------------------------------------------------
AuthFt:
*-----------------------------------------------------------------------------

	OFS.MSG.ID    = ''
	OPTIONS       = OPERATOR
	Y.OFS.TEMP.MESSAGE = "FUNDS.TRANSFER,BTPNS.BIFAST.INCOMING/A/PROCESS//,//":ID.COMPANY:",":ftSettlement
	Y.OFS.SOURCE	   = 'BIFAST'
	CALL OFS.POST.MESSAGE(Y.OFS.TEMP.MESSAGE, OFS.MSG.ID, Y.OFS.SOURCE, OPTIONS)

	RETURN

END 