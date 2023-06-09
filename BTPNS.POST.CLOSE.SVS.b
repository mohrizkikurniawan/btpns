*-----------------------------------------------------------------------------
* <Rating>51</Rating>
*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.POST.CLOSE.SVS
*-----------------------------------------------------------------------------
* Developer Name     : Hamka Ardyansah
* Development Date   : 2 November 2022
* Description        : ROutine to write AA ID to table queue fro closing svs when account or deposit is closed
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.ACCOUNT
    $INSERT I_F.USER
    $INSERT I_F.AA.ACTIVITY.HISTORY
    $INSERT I_F.EB.CONTRACT.BALANCES
    $INSERT I_F.BTPNS.TH.POOL.NISBAH.DEP
    $INSERT I_AA.APP.COMMON
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.ACTION.CONTEXT
    $INSERT I_GTS.COMMON
    $INSERT I_F.BTPNS.TH.QUEUE.CLOSE.SVS
    Y.ACTIVITY.STATUS = c_arrActivityStatus
    
    IF Y.ACTIVITY.STATUS EQ "AUTH" THEN
        GOSUB INIT
        GOSUB PROCESS
    END


    RETURN

*------------------------------------------------------------------------------
INIT:
*------------------------------------------------------------------------------
    
    FN.BTPNS.TH.QUEUE.CLOSE.SVS = "F.BTPNS.TH.QUEUE.CLOSE.SVS"
    F.BTPNS.TH.QUEUE.CLOSE.SVS  = ""
    CALL OPF(FN.BTPNS.TH.QUEUE.CLOSE.SVS,F.BTPNS.TH.QUEUE.CLOSE.SVS)
    
    FN.AA.ARRANGEMENT   = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT    = ''
    CALL OPF(FN.AA.ARRANGEMENT, F.AA.ARRANGEMENT)

    Y.AA.ID = AA$ARR.ID

    CALL F.READ(FN.AA.ARRANGEMENT,Y.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ERR.AA.ARRANGEMENT)
    Y.PRODUCT.LINE      = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.LINE>
    Y.LINKED.APPL.ID    = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL.ID>
    Y.CO.CODE           = R.AA.ARRANGEMENT<AA.ARR.CO.CODE>
    X = OCONV(DATE(),"D-")
    Y.TIME = OCONV(TIME(),"MTS")
    DT = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]:Y.TIME[7,2]
    Y.DATE.TIME = X[9,2]:X[1,2]:X[4,2]:Y.TIME[1,2]:Y.TIME[4,2]

    RETURN
*------------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------------
    CALL F.READ(FN.BTPNS.TH.QUEUE.CLOSE.SVS,Y.AA.ID,R.BTPNS.TH.QUEUE.CLOSE.SVS,F.BTPNS.TH.QUEUE.CLOSE.SVS,ERR.BTPNS.TH.QUEUE.CLOSE.SVS)
    R.BTPNS.TH.QUEUE.CLOSE.SVS<QUEUE.SVS.CO.CODE>   = Y.CO.CODE
    R.BTPNS.TH.QUEUE.CLOSE.SVS<QUEUE.SVS.DATE.TIME> = Y.DATE.TIME
    CALL F.WRITE(FN.BTPNS.TH.QUEUE.CLOSE.SVS,Y.AA.ID,R.BTPNS.TH.QUEUE.CLOSE.SVS)
    RETURN
*--------------------------------------------------------------------------------
END

