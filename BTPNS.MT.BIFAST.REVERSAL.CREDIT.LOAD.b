*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.REVERSAL.CREDIT.LOAD
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
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
	
	
	fnBtpnsTlSettlementDeclined = "F.BTPNS.TL.SETTLEMENT.DECLINED"
	fvBtpnsTlSettlementDeclined = ""
	CALL OPF(fnBtpnsTlSettlementDeclined, fvBtpnsTlSettlementDeclined)

	fnBtpnsTlBifastInterface	= "F.BTPNS.TL.BIFAST.INTERFACE"
	fvBtpnsTlBifastInterface	= ""
	CALL OPF(fnBtpnsTlBifastInterface, fvBtpnsTlBifastInterface)

	fnBtpnsThBifastIncoming		= "F.BTPNS.TH.BIFAST.INCOMING"
	fvBtpnsThBifastIncoming	    = ""
	CALL OPF(fnBtpnsThBifastIncoming, fvBtpnsThBifastIncoming)

	fnFundsTransfer				= "F.FUNDS.TRANSFER"
	fvFundsTransfer				= ""
	CALL OPF(fnFundsTransfer, fvFundsTransfer)

	fnOfsMessageQueue			= "F.OFS.MESSAGE.QUEUE"
	fvOfsMessageQueue			= ""
	CALL OPF(fnOfsMessageQueue, fvOfsMessageQueue)

	fnFundsTransferNau			= "F.FUNDS.TRANSFER$NAU"
	fvFundsTransferNau			= ""
	CALL OPF(fnFundsTransferNau, fvFundsTransferNau)

	fnBtpnsTlSettlementQueue   = "F.BTPNS.TL.SETTLEMENT.QUEUE"
	fvBtpnsTlSettlementQueue   = ""
	CALL OPF(fnBtpnsTlSettlementQueue, fvBtpnsTlSettlementQueue)

	fnBtpnsThBifastIncomingNau = "F.BTPNS.TH.BIFAST.INCOMING$NAU"
	fvBtpnsThBifastIncomingNau = ""
	CALL OPF(fnBtpnsThBifastIncomingNau, fvBtpnsThBifastIncomingNau)

	fnCustomer					= "F.CUSTOMER"
	fvCustomer					= ""
	CALL OPF(fnCustomer, fvCustomer)

	fnBtpnsTlBifastSettlement	= "F.BTPNS.TL.BIFAST.SETTLEMENT"
	fvBtpnsTlBifastSettlement   = ""
	CALL OPF(fnBtpnsTlBifastSettlement, fvBtpnsTlBifastSettlement)

	arrApp<1> 	= "FUNDS.TRANSFER"
	arrApp<2>	= "CUSTOMER"
	arrFld<1,1>	= "ATI.JNAME.2"
	arrFld<1,2> = "B.DBTR.NM"
	arrFld<1,3> = "B.CDTR.PRXYTYPE"
	arrFld<1,4> = "B.CDTR.TYPE"
	arrFld<1,5> = "B.DBTR.RESSTS"
	arrFld<1,6> = "B.CDTR.RESSTS"
	arrFld<1,7> = "B.DBTR.ID"
	arrFld<2,1> = "LEGAL.ID.NO"
	arrPos		= ""
	CALL MULTI.GET.LOC.REF(arrApp, arrFld, arrPos)
	atiJname2Pos	 	 = arrPos<1,1>
	bDbtrNmPos		 	 = arrPos<1,2>
	bCdtrPrxytypePos	 = arrPos<1,3>
	bCdtrTypePos 		 = arrPos<1,4>
	bDbtrResstsPos		 = arrPos<1,5>
	bCdtrResstsPos       = arrPos<1,6>
	bDbtrIdPos			 = arrPos<1,7>
	legalIdNo			 = arrPos<2,1>

    RETURN

END 