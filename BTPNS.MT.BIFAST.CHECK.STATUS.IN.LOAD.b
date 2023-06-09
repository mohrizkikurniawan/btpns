*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.BIFAST.CHECK.STATUS.IN.LOAD
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
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

    RETURN

END 