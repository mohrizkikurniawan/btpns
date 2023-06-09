*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.CHECK.STATUS.SELECT
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
*-----------------------------------------------------------------------------
	
	COMMON/BIFAST.CHECK.STATUS.COM/fnTableInTmp,fvTableInTmp,fnTableIncoming,fvTableIncoming,fnFundsTransfer,fvFundsTransfer,
	fnFundsTransferHis,fvFundsTransferHis,fnBtnpsTlBfastInterfaceParam,fvBtnpsTlBfastInterfaceParam,fnTableOutgoing,fvTableOutgoing,
	fnTableOutTmp,fvTableOutTmp,fnIdihWsDataFtMap,fvIdihWsDataFtMap,fInReversalIdPos,fFtChargesPos,fAtiFtWaivePos,maxRetry
	
	vList = "" ; vParams = "" ; vSelectionFilter = ""

	CONTROL.LIST = "BIFAST.CHECK.STATUS"

	SLEEP 40

	CRT "Running on " FMT(TIME(), 'MTS')

	vType = "INCOMING"
	qryCmd = "SELECT ":fnTableInTmp
	GOSUB ProcessSelect

	vType = "OUTGOING"
	qryCmd = "SELECT ":fnTableOutTmp
	GOSUB ProcessSelect

*	vParams<1> = ""
*	vParams<2> = fnTableInTmp
*	vParams<3> = vSelectionFilter
*	vParams<6> = ""
*	vParams<7> = ""
	CALL BATCH.BUILD.LIST(vParams,vList)

    RETURN

ProcessSelect:

	qryList = ""
	CALL EB.READLIST(qryCmd, qryList, "", qryNo, "")
	IF qryList THEN
		FOR idx=1 TO qryNo
			vList<-1> = vType :"|":qryList<idx>
		NEXT idx
	END

	RETURN

END 