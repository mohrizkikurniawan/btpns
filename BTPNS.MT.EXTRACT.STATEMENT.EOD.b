*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.EXTRACT.STATEMENT.EOD(dataSelect)
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

    vLockingDate    = FIELD(dataSelect, "*", 1)
    vStartTime      = FIELD(dataSelect, "*", 2)
    vEndTime        = FIELD(dataSelect, "*", 3)
    accountNo       = FIELD(dataSelect, "*", 4)

    GOSUB Initialise
	GOSUB MainProcess
	
	RETURN
	
*-----------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------

    CALL F.READ(fnAccount, accountNo, rvAccount, fvAccount, '')
    IF rvAccount EQ '' THEN RETURN

    TotAmtBal   = 0
    fromDate    = TODAY
    CALL CDT("", fromDate, "-1W")

    endDate    = TODAY
    CALL CDT("", endDate, "-1W")

	CALL EB.ACCT.ENTRY.LIST(accountNo, fromDate, endDate, stmtEntryList, openBal, vErr)
    saldoToday    = openBal

    nameText        = fromDate:"_DETAIL":accountNo:".csv"
	RETURN
	
*-----------------------------------------------------------------------------
MainProcess:
*-----------------------------------------------------------------------------

    cntIdEntry  = DCOUNT(stmtEntryList, @FM)

    FOR idx = 1 TO cntIdEntry
        idStmtEntry     = stmtEntryList<idx>
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

        *dataExcel  = ''
        *dataExcel := bookingDate:",":valueDate:",":transReference:",":vKeterangan:",":vDK:",":vDebit:",":vKredit:",":saldo:","
        dataExcelAll<-1>    = bookingDate:",":valueDate:",":transReference:",":vKeterangan:",":vDK:",":vDebit:",":vKredit:",":saldo:",":vCif:",":noAccLoan
    NEXT idx

	WRITE dataExcelAll ON fOutput, nameText
	CALL JOURNAL.UPDATE("")

    GOSUB UpdateBatch

    RETURN
*-----------------------------------------------------------------------------
UpdateBatch:
*-----------------------------------------------------------------------------
    
    idBatch = "BNK/BTPNS.EXTRACT.STATEMENT.EOD"
    CALL F.READ(fnBatch, idBatch, rvbatch, fvBatch, '')
    rvbatch<Batch_Data, 1, 1>    = TODAY

*    vData   = rvbatch<Batch_Data>
*    vDataCnt    = DCOUNT(vData, @SM)
*
*    FOR idx = 1 TO vDataCnt
*        vDataIdx    = vData<1, idx>
*        IF idx EQ 1 THEN
*            rvbatch<Batch_Data, 1, idx> = TODAY
*        END ELSE
*            rvbatch<Batch_Data, 1, idx> = vDataIdx
*        END
*    NEXT idx

	CALL F.WRITE(fnBatch, idBatch, rvbatch)
	CALL JOURNAL.UPDATE(fnBatch)

    RETURN

END 