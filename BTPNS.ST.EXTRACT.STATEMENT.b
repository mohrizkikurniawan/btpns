*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.ST.EXTRACT.STATEMENT
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20221231
* Description        : Routine to extract statement for IDR1523300019002
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
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.ACCOUNT

*-----------------------------------------------------------------------------
    
	GOSUB Initialise
	GOSUB MainProcess
	
	RETURN
	
*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------

    fnStmtEntry     = "F.STMT.ENTRY"
    fvStmtEntry     = ""
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

    fnAccount       = "F.ACCOUNT"
    fvAccount       = ""
    CALL OPF(fnAccount, fvAccount)

    fnOutput    = "../UD/APPSHARED.BP/LOAN/STATEMENT/MANUAL"
    fOutput     = ""

    OPEN fnOutput TO fOutput ELSE
        createFolder    = "CREATE.FILE ":fnOutput:" TYPE=UD"
        EXECUTE createFolder
        OPEN fnOutput TO fOutput ELSE
        END
    END

    dataExcelAll       = ''
    dataExcelAll<-1>       = "Tgl Transaksi,Tgl Efektif,No. Referensi,Keterangan,D/K,Debit,Kredit,Saldo,CIF T24,NTA/ No. Acc. Loan,Nomor IA,Nomor AA"

	RETURN
	
*-----------------------------------------------------------------------------
MainProcess:
*-----------------------------------------------------------------------------

    batchDetails 	= BATCH.DETAILS<3,1>
	fromDate		= batchDetails<1, 1, 1>
	endDate			= batchDetails<1, 1, 1>

    

    nameText        = fromDate:"_DETAIL":batchDetails<1, 1, 2>:".csv"

    vAccountCnt     = DCOUNT(batchDetails, @SM)
    FOR idx = 2 TO vAccountCnt
        vGl             = batchDetails<1, 1, idx>
        IF vGl NE '' THEN GOSUB GetData
    NEXT idx

    WRITE dataExcelAll ON fOutput, nameText
	CALL JOURNAL.UPDATE("")
    
    GOSUB UpdateBatch

    RETURN
*-----------------------------------------------------------------------------
UpdateBatch:
*-----------------------------------------------------------------------------
    
    idBatch = "BNK/BTPNS.EXTRACT.STATEMENT"
    CALL F.READ(fnBatch, idBatch, rvbatch, fvBatch, '')

    rvbatch<Batch_Data> = ""

	CALL F.WRITE(fnBatch, idBatch, rvbatch)
	CALL JOURNAL.UPDATE(fnBatch)

    RETURN
*-----------------------------------------------------------------------------
GetData:
*-----------------------------------------------------------------------------

    
	CALL EB.ACCT.ENTRY.LIST(vGl, fromDate, endDate, stmtEntryList, openBal, vErr)
    saldo     = openBal

    cntIdEntry  = DCOUNT(stmtEntryList, @FM)

    FOR idxEntry = 1 TO cntIdEntry
        idStmtEntry     = stmtEntryList<idxEntry>
        CALL F.READ(fnStmtEntry, idStmtEntry, rvStmtEntry, fvStmtEntry, '')
        bookingDate     = rvStmtEntry<StmtEntry_BookingDate>
        valueDate       = rvStmtEntry<StmtEntry_ValueDate>
*       transReference  = rvStmtEntry<StmtEntry_TransReference>
        transReference  = rvStmtEntry<StmtEntry_OurReference>
        transactionCode = rvStmtEntry<StmtEntry_TransactionCode>

        saveData        = O.DATA
        O.DATA          = transReference:"*":transactionCode:"*":idStmtEntry
        CALL ATI.CONV.AC.STMT.NARRATIVE
        vKeterangan     = O.DATA
        O.DATA          = saveData

        CALL F.READ(fnFundsTransfer, transReference, rvFundsTransfer, fvFundsTransfer, '')
        IF rvFundsTransfer EQ '' THEN
            CALL F.READ.HISTORY(fnFundsTransferHis, transReference, rvFundsTransferHis, fvFundsTranferHis, '')
            creditAcctNo    = rvFundsTransferHis<FundsTransfer_CreditAcctNo>
            debitAcctNo     = rvFundsTransferHis<FundsTransfer_DebitAcctNo>
            creditCustomer  = rvFundsTransferHis<FundsTransfer_CreditCustomer>
            debitCustomer   = rvFundsTransferHis<FundsTransfer_DebitCustomer>
            transReference  = FIELD(transReference, ';', 1)
        END ELSE
            creditAcctNo    = rvFundsTransfer<FundsTransfer_CreditAcctNo>
            debitAcctNo     = rvFundsTransfer<FundsTransfer_DebitAcctNo>
            creditCustomer  = rvFundsTransfer<FundsTransfer_CreditCustomer>
            debitCustomer   = rvFundsTransfer<FundsTransfer_DebitCustomer>
        END

        amountLcy       = rvStmtEntry<StmtEntry_AmountLcy>
        IF amountLcy LT 0 THEN
            vDK         = "D"
        END ELSE
            vDK         = "K"
        END

        IF vDK EQ 'D' THEN
            vKredit     = ''
            vDebit      = amountLcy*(-1)
            vCif        = creditCustomer
            noAccLoan   = creditAcctNo

        END ELSE
            vKredit     = amountLcy
            vDebit      = ''
            vCif        = debitCustomer
            noAccLoan   = debitAcctNo
        END

        saldo           = saldo + amountLcy

        CALL F.READ(fnAccount, noAccLoan, rAccount, fvAccount, '')
        vArrangementId  = rAccount<Account_ArrangementId>

        *dataExcel  = ''
        *dataExcel := bookingDate:",":valueDate:",":transReference:",":vKeterangan:",":vDK:",":vDebit:",":vKredit:",":saldo:","
        dataExcelAll<-1>    = bookingDate:",":valueDate:",":transReference:",":vKeterangan:",":vDK:",":vDebit:",":vKredit:",":saldo:",":vCif:",":noAccLoan:",":vGl:",":vArrangementId
    NEXT idxEntry

    RETURN

END 
