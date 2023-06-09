*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.EXTRACT.STATEMENT.EOD.SELECT
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20221231
* Description        : Routine to extract statement when EOD
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
    $INSERT I_BATCH.FILES
    $INSERT I_F.BATCH
    $INSERT I_ENQUIRY.COMMON
*   $INSERT I_F.ACCT.ENT.LWORK.DAY
    $INSERT I_F.ACCOUNT
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.BATCH

*-----------------------------------------------------------------------------

	COMMON/EXTRACT.STATEMENT.COM/fnAcctEntLworkDay,fvAcctEntLworkDay,fnOutput,fOutput,dataExcelAll,fnAccount,fvAccount,fnStmtEntry,fvStmtEntry,fnFundsTransfer,fvFundsTransfer,fnFundsTransferHis,fvFundsTranferHis,fnBatch,fvBatch
    
	GOSUB Initialise
	GOSUB MainProcess
	
	RETURN
	
*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------

    selList    = ""

	RETURN
	
*-----------------------------------------------------------------------------
MainProcess:
*-----------------------------------------------------------------------------

    batchDetails 	= BATCH.DETAILS<3,1>

    vLockingDate    = batchDetails<1, 1, 1>
    vStartTime      = batchDetails<1, 1, 2>
    vEndTime        = batchDetails<1, 1, 3>

	IF CONTROL.LIST EQ "" THEN
		CONTROL.LIST	= "GET.DATA" :FM: "COMBINE.DATA"
	END
	
	Y.CONTROL			= CONTROL.LIST<1,1>


    vAccountCnt     = DCOUNT(batchDetails, @SM)

    FOR idx = 4 TO vAccountCnt
        vGl             = batchDetails<1, 1, idx>
        selList<-1>     = vLockingDate : "*" : vStartTime : "*" : vEndTime : "*" : vGl
    NEXT idx
	
	CALL BATCH.BUILD.LIST("", selList)

    RETURN

END 
