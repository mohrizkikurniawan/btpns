*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.CHECK.STATUS.OUT.LOAD
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Alamsyah Rizki Isroi
* Development Date   : 20220718
* Description        : Routine to process BIFAST Outgoing Check Status
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
	
	COMMON/BIFAST.CHECK.STATUS.OUT.COM/fnTableTmp,fvTableTmp,fnTableOutgoing,fvTableOutgoing,fnFundsTransfer,fvFundsTransfer,fnTableConcatLog,fvTableConcatLog,
	fnFundsTransferHis,fvFundsTransferHis,fInReversalIdPos,fnIdihWsDataFtMap,fvIdihWsDataFtMap,fFtChargesPos,fAtiFtWaivePos,fnBtnpsTlBfastInterfaceParam,fvBtnpsTlBfastInterfaceParam
	
	fnTableOutgoing = "F.BTPNS.TH.BIFAST.OUTGOING"
	fvTableOutgoing = ""
	CALL OPF(fnTableOutgoing, fvTableOutgoing)
	
	fnTableTmp = "F.BTPNS.TL.BIFAST.OUTGOING.TMP"
	fvTableTmp = ""
	CALL OPF(fnTableTmp, fvTableTmp)
	
	fnFundsTransfer = "F.FUNDS.TRANSFER"
	fvFundsTransfer = ""
	CALL OPF(fnFundsTransfer, fvFundsTransfer)
	
	fnFundsTransferHis = "F.FUNDS.TRANSFER$HIS"
	fvFundsTransferHis = ""
	CALL OPF(fnFundsTransferHis, fvFundsTransferHis)
	
	fnTableConcatLog = "F.BTPNS.TL.BIFAST.INTERFACE"
	fvTableConcatLog = ""
	CALL OPF(fnTableConcatLog, fvTableConcatLog)

	fnBtnpsTlBfastInterfaceParam = "F.BTPNS.TL.BFAST.INTERFACE.PARAM"
	fvBtnpsTlBfastInterfaceParam = ""
	CALL OPF(fnBtnpsTlBfastInterfaceParam, fvBtnpsTlBfastInterfaceParam)
	
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

    RETURN

END 