*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.SETTLE.QUEUE.LOAD
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
*-----------------------------------------------------------------------------
	
	COMMON/BTPNS.MT.BIFAST.SETTLE.QUEUE.COM/fnBtpnsTlBifastSettlement,fvBtpnsTlBifastSettlement,fnFundsTransfer,fvFundsTransfer,fnFundsTransferNau,fvFundsTransferNau,fnBtpnsTlSettlementDeclined,fvBtpnsTlSettlementDeclined
	
	fnBtpnsTlBifastSettlement	= "F.BTPNS.TL.BIFAST.SETTLEMENT"
	fvBtpnsTlBifastSettlement	= ""
	CALL OPF(fnBtpnsTlBifastSettlement, fvBtpnsTlBifastSettlement)

	fnFundsTransfer				= "F.FUNDS.TRANSFER"
	fvFundsTransfer				= ""
	CALL OPF(fnFundsTransfer, fvFundsTransfer)

	fnFundsTransferNau			= "F.FUNDS.TRANSFER$NAU"
	fvFundsTransferNau			= ""
	CALL OPF(fnFundsTransferNau, fvFundsTransferNau)

	fnBtpnsTlSettlementDeclined = "F.BTPNS.TL.SETTLEMENT.DECLINED"
	fvBtpnsTlSettlementDeclined = ""
	CALL OPF(fnBtpnsTlSettlementDeclined, fvBtpnsTlSettlementDeclined)

    RETURN

END 