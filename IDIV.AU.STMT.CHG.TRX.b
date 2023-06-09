    SUBROUTINE IDIV.AU.STMT.CHG.TRX
*------------------------------------------------------------------------
** MODIFIED BY : Hamka Ardyansah
** DATE        : 7 januari 2020
** ACTIVITY    : Change logic to r19 btpns upgrade
*-------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.IDIH.IN.FT.JOURNAL.PAR
    $INSERT I_IDIV.IN.GET.PARAM.JOURNAL.COMMON
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.IDIH.IN.CONDITION.CHG
    $INSERT I_F.ACCOUNT
    $INSERT I_F.FT.TXN.TYPE.CONDITION
    $INSERT I_F.IDIH.QUEUE.CHARGES

*--------------------------------------------------

    Y.FT.DB.ACCT    = ''
    Y.FT.CR.ACCT    = ''
    Y.CHG.DB.CONS   = ''
    Y.CHG.CR.CONS   = ''
    Y.CHG.TYPE              = ''
    Y.CHG.DB                = ''
    Y.CHG.CR                = ''
    Y.ACCT.DB               = ''
    Y.ACCT.CR               = ''
    Y.CURR.DB               = ''
    Y.CURR.CR               = ''
    JML.ACCT.CR = ''
    JML.CHG = ''
    Y.CNT.CHG = ''
    Y.CNT.CR.ACCT = ''
    Y.CHG.CR = ''
    Y.JML.CND.CHG = ''
    Y.ORI.JML.DB = ''

*------------------------------------------------

    GOSUB INIT
    GOSUB PROCESS

    RETURN

*---------------------------------------------------------------
INIT:

    FN.IDIH.IN.FT.JOURNAL.PAR  = 'F.IDIH.IN.FT.JOURNAL.PAR'
    F.IDIH.IN.FT.JOURNAL.PAR   = ''
    CALL OPF(FN.IDIH.IN.FT.JOURNAL.PAR,F.IDIH.IN.FT.JOURNAL.PAR)

    FN.COMM.TYPE    = 'F.FT.COMMISSION.TYPE'
    F.COMM.TYPE             = ''
    CALL OPF(FN.COMM.TYPE,F.COMM.TYPE)

    FN.STMT.ENTRY = 'F.STMT.ENTRY'
    F.STMT.ENTRY = ''
    CALL OPF(FN.STMT.ENTRY, F.STMT.ENTRY)

    FN.CHG.CON = 'F.IDIH.IN.CONDITION.CHG'
    F.CHG.CON = ''
    CALL OPF(FN.CHG.CON, F.CHG.CON)

    FN.ACCT = 'F.ACCOUNT'
    F.ACCT = ''
    CALL OPF(FN.ACCT,F.ACCT)

    FN.TXN.TYPE = 'F.FT.TXN.TYPE.CONDITION'
    F.TXN.TYPE = ''
    CALL OPF(FN.TXN.TYPE,F.TXN.TYPE)

    FN.IDIH.QUEUE.CHARGES = "F.IDIH.QUEUE.CHARGES"
    F.IDIH.QUEUE.CHARGES  =""
    CALL OPF(FN.IDIH.QUEUE.CHARGES,F.IDIH.QUEUE.CHARGES)

    Y.APP = "FUNDS.TRANSFER"
    Y.FIELDS = "IN.UNIQUE.ID":VM:"IN.REVERSAL.ID"
    CALL MULTI.GET.LOC.REF(Y.APP,Y.FIELDS,Y.POS)
    Y.IN.UNIQUE.ID.POS   = Y.POS<1,1>
    Y.IN.REVERSAL.ID.POS = Y.POS<1,2>

    CALL GET.LOC.REF('IDIH.IN.FT.JOURNAL.PAR','ACC.CR.SPLIT',Y.ACC.CR.SPLIT.POS)
    CALL GET.LOC.REF('IDIH.IN.FT.JOURNAL.PAR','ACC.DB.SPLIT',Y.ACC.DB.SPLIT.POS)

    Y.IN.UNIQUE.ID    = R.NEW(FT.LOCAL.REF)<1,Y.IN.UNIQUE.ID.POS>
    Y.IN.REVERSAL.ID  = R.NEW(FT.LOCAL.REF)<1,Y.IN.REVERSAL.ID.POS>

    CALL F.READ(FN.IDIH.IN.FT.JOURNAL.PAR,Y.IN.UNIQUE.ID,R.IDIH.IN.FT.JOURNAL.PAR,F.IDIH.IN.FT.JOURNAL.PAR,ERR.PAR)
    Y.ACC.DB.SPLIT = R.IDIH.IN.FT.JOURNAL.PAR<JOURNAL.PAR.LOCAL.REF,Y.ACC.DB.SPLIT.POS>
    Y.ACC.CR.SPLIT = R.IDIH.IN.FT.JOURNAL.PAR<JOURNAL.PAR.LOCAL.REF,Y.ACC.CR.SPLIT.POS>
    
    RETURN
*---------------------------------------------------------------

PROCESS:
    TIME.STAMP = TIMEDATE()
    X = OCONV(DATE(),"D-")
    DT = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]:TIME.STAMP[7,2]
    Y.DT = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]

    IF Y.ACC.CR.SPLIT NE ''  THEN
        Y.ID.REQ = Y.IN.REVERSAL.ID:"01"
        CALL F.READ(F.IDIH.QUEUE.CHARGES,Y.ID.REQ,R.IDIH.QUEUE.CHARGES,F.IDIH.QUEUE.CHARGES,ERR.QUEUE)
       
        R.IDIH.QUEUE.CHARGES<QUEUE.CHG1.AT.CHG.CODE> = Y.IN.UNIQUE.ID
        R.IDIH.QUEUE.CHARGES<QUEUE.CHG1.VALUE.DATE>  = TODAY
        R.IDIH.QUEUE.CHARGES<QUEUE.CHG1.DATE.TIME>   = Y.DT
        R.IDIH.QUEUE.CHARGES<QUEUE.CHG1.CO.CODE>   = R.NEW(FT.CO.CODE)
        
        CALL F.WRITE(FN.IDIH.QUEUE.CHARGES,Y.ID.REQ,R.IDIH.QUEUE.CHARGES)    
    END

RETURN
*---------------------------------------------------------------

END
