*-----------------------------------------------------------------------------
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.CONV.GET.DATE.BIFAST
*-----------------------------------------------------------------------------
* Developer Name     : Hamka Ardyansah
* Development Date   : 6 September 2022
* Description        : Routine to data from table proxy alias
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               :
* Modified by        :
* Description        :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.ACCOUNT
    $INSERT I_F.BTPNS.TH.BIFAST.PROXY.MGMT
*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

    FN.ACCOUNT = "F.ACCOUNT"
    F.ACCOUNT  = ""
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)
	
    FN.PROXY.MGMT = 'F.BTPNS.TH.BIFAST.PROXY.MGMT'
    F.PROXY.MGMT = ''
    CALL OPF(FN.PROXY.MGMT,F.PROXY.MGMT)

    Y.APP  = "ACCOUNT"
    Y.FLD.NAME  = "B.PROXY.TYPE" :VM: "B.PROXY.ID" :VM: "B.PROXY.STATUS" :VM: "B.PROXY.REG.ID"
    Y.POS       = ""
    CALL MULTI.GET.LOC.REF(Y.APP, Y.FLD.NAME, Y.POS)

    Y.PROXY.TYPE.POS    = Y.POS<1,1>
    Y.PROXY.ID.POS      = Y.POS<1,2>
    Y.PROXY.STATUS.POS  = Y.POS<1,3>
    Y.PROXY.REG.ID.POS  = Y.POS<1,4>
    
    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    
    Y.ACCOUNT.ID = O.DATA

    CALL F.READ(FN.ACCOUNT, Y.ACCOUNT.ID, R.ACCOUNT, F.ACCOUNT, ERR.ACCOUNT)
    Y.PROXY.TYPE   = R.ACCOUNT<AC.LOCAL.REF,Y.PROXY.TYPE.POS>
    Y.PROXY.ID     = R.ACCOUNT<AC.LOCAL.REF,Y.PROXY.ID.POS>
    Y.PROXY.STATUS = R.ACCOUNT<AC.LOCAL.REF,Y.PROXY.STATUS.POS>
    Y.PROXY.REG.ID = R.ACCOUNT<AC.LOCAL.REF,Y.PROXY.REG.ID.POS>

    SEL.CMD = "SELECT ":FN.PROXY.MGMT
    SEL.CRT.1 =" WITH PROXY.ID EQ ":Y.PROXY.ID
    SEL.CRT.2 =" AND PROXY.STATUS EQ ":Y.PROXY.STATUS
    SEL.CRT.3 =" AND REGISTER.ID EQ ":Y.PROXY.REG.ID
    SEL.CRT.4 =" AND ACCOUNT.NO EQ ":Y.ACCOUNT.ID
    SEL.CRT.5 =" SORT-BY @ID DSND SAMPLE 1"
    
    SEL.CMD.FNL =SEL.CMD:SEL.CRT.1:SEL.CRT.2:SEL.CRT.3:SEL.CRT.4:SEL.CRT.5
    CALL EB.READLIST(SEL.CMD.FNL,SEL.LIST,'',NO.OF.REC,ERR.REC)
    Y.ID.PROXY.MGMT = SEL.LIST
    
    CALL F.READ(FN.PROXY.MGMT,Y.ID.PROXY.MGMT,R.PROXY.MGMT,F.PROXY.MGMT,ERR.PROXY.MGMT)
    Y.INPUTTER   = FIELD(R.PROXY.MGMT<BF.PM.INPUTTER>,"_",2)
    Y.AUTHORISER = FIELD(R.PROXY.MGMT<BF.PM.AUTHORISER>,"_",2)
    Y.DATE.TIME  = R.PROXY.MGMT<BF.PM.DATE.TIME>
    
    
    Y.OUTPUT = Y.INPUTTER:"*":Y.AUTHORISER:"*":Y.DATE.TIME
    O.DATA = Y.OUTPUT

    RETURN
*-----------------------------------------------------------------------------
END









