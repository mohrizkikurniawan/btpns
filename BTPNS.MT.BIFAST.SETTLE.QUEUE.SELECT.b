*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.SETTLE.QUEUE.SELECT
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
*-----------------------------------------------------------------------------
	
	COMMON/BTPNS.MT.BIFAST.SETTLE.QUEUE.COM/fnBtpnsTlBifastSettlement,fvBtpnsTlBifastSettlement,fnFundsTransfer,fvFundsTransfer,fnFundsTransferNau,fvFundsTransferNau,fnBtpnsTlSettlementDeclined,fvBtpnsTlSettlementDeclined
	
	*vList = "" ; vParams = "" ; vSelectionFilter = ""
	*vParams<1> = ""
	*vParams<2> = fnBtpnsTlBifastSettlement
	*vParams<3> = vSelectionFilter
	*vParams<6> = ""
	*vParams<7> = ""
	*CALL BATCH.BUILD.LIST(vParams,vList)
	
	SEL.CMD = "SELECT " : fnBtpnsTlBifastSettlement
	CALL EB.READLIST(SEL.CMD, SEL.LIST, '', NO.OF.REC, ERR.REC)
	
	CALL BATCH.BUILD.LIST("", SEL.LIST)

    RETURN

END 
