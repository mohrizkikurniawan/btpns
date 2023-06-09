*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.REVERSAL.CREDIT.SELECT
*------------------------------------------------------------------------------
*------------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20221009
* Description        : Routine to process reverse credit transfer
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
	
	COMMON/BTPNS.MT.BIFAST.REVERSAL.CREDIT.COM/fnBtpnsTlSettlementDeclined,fvBtpnsTlSettlementDeclined,fnBtpnsTlBifastInterface,
	fvBtpnsTlBifastInterface,fnBtpnsThBifastIncoming,fvBtpnsThBifastIncoming,fnFundsTransfer,fvFundsTransfer,fnOfsMessageQueue,
	fvOfsMessageQueue,fnFundsTransferNau,fvFundsTransferNau,atiJname2Pos,bDbtrNmPos,bCdtrPrxytypePos,bCdtrTypePos,bDbtrResstsPos,
	bCdtrResstsPos,bDbtrIdPos,fnBtpnsTlSettlementQueue,fvBtpnsTlSettlementQueue,fnBtpnsThBifastIncomingNau,fvBtpnsThBifastIncomingNau,fnCustomer,fvCustomer,legalIdNo,fnBtpnsTlBifastSettlement,fvBtpnsTlBifastSettlement
	
	*vList = "" ; vParams = "" ; vSelectionFilter = ""
	*vParams<1> = ""
	*vParams<2> = fnBtpnsTlSettlementDeclined
	*vParams<3> = vSelectionFilter
	*vParams<6> = ""
	*vParams<7> = ""
	*CALL BATCH.BUILD.LIST(vParams,vList)

	SEL.CMD = "SELECT " : fnBtpnsTlSettlementDeclined
	CALL EB.READLIST(SEL.CMD, SEL.LIST, '', NO.OF.REC, ERR.REC)
	
	CALL BATCH.BUILD.LIST("", SEL.LIST)

    RETURN

END 