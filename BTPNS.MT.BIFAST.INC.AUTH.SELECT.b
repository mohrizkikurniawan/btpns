*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.INC.AUTH.SELECT
*------------------------------------------------------------------------------
*------------------------------------------------------------------------------
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
	
	selCmd = "SELECT " : fnBtpnsThBifastIncoming : " WITH @ID LIKE " : TODAY : "...."
	CALL EB.READLIST(selCmd, selList, '', noOfRec, errRec)
	
	CALL OCOMO("id ft incoming to process authorize : " : selList)
	CALL BATCH.BUILD.LIST("", selList)

    RETURN

END 