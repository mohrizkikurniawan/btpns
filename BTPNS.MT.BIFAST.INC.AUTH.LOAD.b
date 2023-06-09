*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.INC.AUTH.LOAD
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20230215
* Description        : Routine to process autorize incoming bifast
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
	
	fnFundsTransfer				= "F.FUNDS.TRANSFER"
	fvFundsTransfer				= ""
	CALL OPF(fnFundsTransfer, fvFundsTransfer)

	fnFundsTransferNau			= "F.FUNDS.TRANSFER$NAU"
	fvFundsTransferNau			= ""
	CALL OPF(fnFundsTransferNau, fvFundsTransferNau)

	fnBtpnsThBifastIncoming		= "F.BTPNS.TH.BIFAST.INCOMING"
	fvBtpnsThBifastIncoming		= ""
	CALL OPF(fnBtpnsThBifastIncoming ,fvBtpnsThBifastIncoming)

    RETURN

END 