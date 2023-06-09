*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.SETTLE.QUEUE(idQueue)
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
	$INCLUDE I_F.BTPNS.TH.BIFAST.INCOMING
	$INCLUDE I_F.FUNDS.TRANSFER

*-----------------------------------------------------------------------------

	COMMON/BTPNS.MT.BIFAST.SETTLE.QUEUE.COM/fnBtpnsTlBifastSettlement,fvBtpnsTlBifastSettlement,fnFundsTransfer,fvFundsTransfer,fnFundsTransferNau,fvFundsTransferNau,fnBtpnsTlSettlementDeclined,fvBtpnsTlSettlementDeclined
	
	GOSUB Initialise
	
	RETURN
	
*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------

	CALL F.READ(fnBtpnsTlBifastSettlement, idQueue, rvBtpnsTlBifastSettlement, fvBtpnsTlBifastSettlement, "")
	idIncoming = rvBtpnsTlBifastSettlement<1>
	idFt	   = FIELDS(idIncoming, ".", 2)	

	CALL F.READ(fnFundsTransferNau, idFt, rvFundsTransferNau, fvFundsTransferNau, "")
	recordStatus = rvFundsTransferNau<FundsTransfer_RecordStatus>

	BEGIN CASE
	CASE recordStatus EQ 'INAU'
		GOSUB AuthFt
		CALL F.DELETE(fnBtpnsTlBifastSettlement,idQueue)
		CALL F.WRITE(fnBtpnsTlSettlementDeclined, idQueue, rvBtpnsTlBifastSettlement)
	CASE recordStatus EQ 'IHLD'
		CALL F.DELETE(fnBtpnsTlBifastSettlement,idQueue)
		CALL F.WRITE(fnBtpnsTlSettlementDeclined, idQueue, rvBtpnsTlBifastSettlement)
	CASE recordStatus EQ ''
		RETURN
	END CASE
	
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

END 
