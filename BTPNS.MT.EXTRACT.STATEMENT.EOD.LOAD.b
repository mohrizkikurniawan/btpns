*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.EXTRACT.STATEMENT.EOD.LOAD
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
*    $INSERT I_F.ACCT.ENT.LWORK.DAY
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

    fnAcctEntLworkDay   = "F.ACCT.ENT.LWORK.DAY"
    fvAcctEntLworkDay   = ""
    CALL OPF(fnAcctEntLworkDay, fvAcctEntLworkDay)

    fnAccount           = "F.ACCOUNT"
    fvAccount           = ""
    CALL OPF(fnAccount, fvAccount)

    fnStmtEntry         = "F.STMT.ENTRY"
    fvStmtEntry         = ""
    CALL OPF(fnStmtEntry, fvStmtEntry)

    fnFundsTransfer = "F.FUNDS.TRANSFER"
    fvFundsTransfer = ""
    CALL OPF(fnFundsTransfer, fvFundsTransfer)

    fnFundsTransferHis  = "F.FUNDS.TRANSFER$HIS"
    fvFundsTranferHis   = ""
    CALL OPF(fnFundsTransferHis, fvFundsTranferHis)

    fnBatch         = "F.BATCH"
    fvBatch         = ""
    CALL OPF(fnBatch, fvBatch)

    fnOutput    = "../UD/APPSHARED.BP/LOAN/STATEMENT/AUTO"
    fOutput     = ""

    OPEN fnOutput TO fOutput ELSE
        createFolder    = "CREATE.FILE ":fnOutput:" TYPE=UD"
        EXECUTE createFolder
        OPEN fnOutput TO fOutput ELSE
        END
    END

    dataExcelAll       = ''
    dataExcelAll       = "Tgl Transaksi,Tgl Efektif,No. Referensi,Keterangan,D/K,Debit,Kredit,Saldo,CIF T24,NTA/ No. Acc. Loan"

	RETURN
	
*-----------------------------------------------------------------------------
MainProcess:
*-----------------------------------------------------------------------------

    RETURN

END 
