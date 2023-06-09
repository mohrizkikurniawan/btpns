*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.CHECK.STATUS.IN.SELECT
*------------------------------------------------------------------------------
*------------------------------------------------------------------------------
* Developer Name     : Alamsyah Rizki Isroi
* Development Date   : 20220715
* Description        : Routine to process BIFAST Incoming Check Status
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
	
	COMMON/BIFAST.CHECK.STATUS.IN.COM/fnTableTmp,fvTableTmp,fnTableIncoming,fvTableIncoming,fnFundsTransfer,fvFundsTransfer,
	fnFundsTransferHis,fvFundsTransferHis,fnBtnpsTlBfastInterfaceParam,fvBtnpsTlBfastInterfaceParam
	
	vList = "" ; vParams = "" ; vSelectionFilter = ""
	vParams<1> = ""
	vParams<2> = fnTableTmp
	vParams<3> = vSelectionFilter
	vParams<6> = ""
	vParams<7> = ""
	CALL BATCH.BUILD.LIST(vParams,vList)

    RETURN

END 