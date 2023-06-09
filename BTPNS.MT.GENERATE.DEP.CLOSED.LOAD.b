    SUBROUTINE BTPNS.MT.GENERATE.DEP.CLOSED.LOAD
*-----------------------------------------------------------------------------
* Developer Name     : Hamka Ardyansah
* Development Date   : 13 September 2022
* Description        : Routine multithread for generate report deposito dengan status tutup
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               : 
* Modified by        : 
* Description        : 
*-----------------------------------------------------------------------------
    
    $INSERT I_GTS.COMMON
    $INSERT I_TSA.COMMON
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.CHANGE.PRODUCT
    $INSERT I_F.USER
    $INSERT I_BTPNS.MT.GENERATE.DEP.CLOSED.COMMON
    
    FN.AA.ARRANGEMENT    = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT    = ''
    CALL OPF(FN.AA.ARRANGEMENT, F.AA.ARRANGEMENT)    
    
    FN.AA.ACCOUNT.DETAILS    = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS    = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS, F.AA.ACCOUNT.DETAILS)
    
    FN.AA.ARR.ACCOUNT ="F.AA.ARR.ACCOUNT"
    F.AA.ARR.ACCOUNT  = ""
    CALL OPF(FN.AA.ARR.ACCOUNT,F.AA.ARR.ACCOUNT)
    
    FN.AA.ARR.TERM.AMOUNT = "F.AA.ARR.TERM.AMOUNT"
    F.AA.ARR.TERM.AMOUNT  = ""
    CALL OPF(FN.AA.ARR.TERM.AMOUNT,F.AA.ARR.TERM.AMOUNT)
    
    FN.AA.ARR.CHANGE.PRODUCT = "F.AA.ARR.CHANGE.PRODUCT"
    F.AA.ARR.CHANGE.PRODUCT  = ""
    CALL OPF(FN.AA.ARR.CHANGE.PRODUCT,F.AA.ARR.CHANGE.PRODUCT)
        
    FN.ACCOUNT    = 'F.ACCOUNT'
    F.ACCOUNT    = ''
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)
    
    FN.ACCOUNT.HIS    = 'F.ACCOUNT$HIS'
    F.ACCOUNT.HIS    = ''
    CALL OPF(FN.ACCOUNT.HIS, F.ACCOUNT.HIS)
    
    FN.FC = "F.FILE.CONTROL"
    F.FC = ""
    CALL OPF(FN.FC,F.FC)
    
    FN.BTPNS.TH.POOL.DEP.CLOSE = "F.BTPNS.TH.POOL.DEP.CLOSE"
    F.BTPNS.TH.POOL.DEP.CLOSE  = ""
    CALL OPF(FN.BTPNS.TH.POOL.DEP.CLOSE,F.BTPNS.TH.POOL.DEP.CLOSE)
    
    Y.APP<1>        = 'AA.ARR.ACCOUNT'
    Y.APP<2>        = 'AA.ARR.TERM.AMOUNT'
    Y.FLD.NAME<1>     = 'ATI.JOINT.NAME' :VM: 'L.COUNTER.NISBA' :VM: 'L.FINAL.NISBA' :VM: 'L.BILYET.NUM' :VM: 'L.MIG.PRD'
    Y.FLD.NAME<2>     = 'L.ORG.MAT.DATE' :VM: 'L.MAT.MODE' :VM: "L.TENOR"
    Y.POS             = ''
    
    CALL MULTI.GET.LOC.REF(Y.APP, Y.FLD.NAME, Y.POS)

    Y.ATI.JOINT.NAME.POS    = Y.POS<1,1>
    Y.L.COUNTER.NISBA.POS   = Y.POS<1,2>
    Y.L.FINAL.NISBA.POS     = Y.POS<1,3>
    Y.L.BILYET.NUM.POS      = Y.POS<1,4>
    Y.L.MIG.PRD.POS         = Y.POS<1,5>
    Y.L.ORG.MAT.DATE.POS    = Y.POS<2,1>
    Y.L.MAT.MODE.POS        = Y.POS<2,2>
    Y.TERM.POS              = Y.POS<2,3>

    RETURN
END