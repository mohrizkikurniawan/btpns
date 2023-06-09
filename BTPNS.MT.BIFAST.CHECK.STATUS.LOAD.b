*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.CHECK.STATUS.LOAD
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Alamsyah Rizki Isroi
* Development Date   : 20220715
* Description        : Routine to process BIFAST Check Status
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
	$INCLUDE I_F.BTPNS.TL.BFAST.INTERFACE.PARAM
*-----------------------------------------------------------------------------
	
	COMMON/BIFAST.CHECK.STATUS.COM/fnTableInTmp,fvTableInTmp,fnTableIncoming,fvTableIncoming,fnFundsTransfer,fvFundsTransfer,
	fnFundsTransferHis,fvFundsTransferHis,fnBtnpsTlBfastInterfaceParam,fvBtnpsTlBfastInterfaceParam,fnTableOutgoing,fvTableOutgoing,
	fnTableOutTmp,fvTableOutTmp,fnIdihWsDataFtMap,fvIdihWsDataFtMap,fInReversalIdPos,fFtChargesPos,fAtiFtWaivePos,maxRetry
	
	fnTableIncoming = "F.BTPNS.TH.BIFAST.INCOMING"
	fvTableIncoming = ""
	CALL OPF(fnTableIncoming, fvTableIncoming)
	
	fnTableTmp = "F.BTPNS.TL.BIFAST.INCOMING.TMP"
	fvTableTmp = ""
	CALL OPF(fnTableTmp, fvTableTmp)
	
	fnFundsTransfer = "F.FUNDS.TRANSFER"
	fvFundsTransfer = ""
	CALL OPF(fnFundsTransfer, fvFundsTransfer)

	fnFundsTransferHis = "F.FUNDS.TRANSFER$HIS"
	fvFundsTransferHis = ""
	CALL OPF(fnFundsTransferHis, fvFundsTransferHis)

	fnBtnpsTlBfastInterfaceParam = "F.BTPNS.TL.BFAST.INTERFACE.PARAM"
	fvBtnpsTlBfastInterfaceParam = ""
	CALL OPF(fnBtnpsTlBfastInterfaceParam, fvBtnpsTlBfastInterfaceParam)

	fnTableOutgoing = "F.BTPNS.TH.BIFAST.OUTGOING"
	fvTableOutgoing = ""
	CALL OPF(fnTableOutgoing, fvTableOutgoing)
	
	fnTableOutTmp = "F.BTPNS.TL.BIFAST.OUTGOING.TMP"
	fvTableOutTmp = ""
	CALL OPF(fnTableOutTmp, fvTableOutTmp)

	fnIdihWsDataFtMap = "F.IDIH.WS.DATA.FT.MAP"
	fvIdihWsDataFtMap = ""
	CALL OPF(fnIdihWsDataFtMap,fvIdihWsDataFtMap)
	
	arrApp<1> 	= "FUNDS.TRANSFER"
	arrApp<2> 	= "IDIH.WS.DATA.FT.MAP"
	arrFld<1,1>	= "IN.REVERSAL.ID"
	arrFld<2,1>	= "FT.CHARGES"
	arrFld<2,2>	= "ATI.FT.WAIVE"
	arrPos		= ""
	CALL MULTI.GET.LOC.REF(arrApp, arrFld, arrPos)
	fInReversalIdPos = arrPos<1,1>
	fFtChargesPos	 = arrPos<2,1>
	fAtiFtWaivePos	 = arrPos<2,2>

	CALL F.READ(fnBtnpsTlBfastInterfaceParam, "SYSTEM", rvBtnpsTlBfastInterfaceParam, fvBtnpsTlBfastInterfaceParam, "")
	maxRetry = rvBtnpsTlBfastInterfaceParam<BtpnsTlBfastInterfaceParam_MaxRetry>

    RETURN

END 