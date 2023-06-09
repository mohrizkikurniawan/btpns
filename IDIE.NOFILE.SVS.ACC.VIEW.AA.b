 *-----------------------------------------------------------------------------
* <Rating>-50</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE IDIE.NOFILE.SVS.ACC.VIEW.AA(Y.OUTPUT)
*-----------------------------------------------------------------------------
* Developer Name     : Fatkhur Rohman
* Development Date   : 20150327
* Description        : Subroutine to build enquiry SVS Account
*                      Add condition for LSB (DAO begin with '12' and 6 digit) BTPNS
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               :1 November 2022
* Modified by        :Hamka Ardyansah
* Description        :duplicate from IDIE.NOFILE.SVS.ACC.VIEW add logic to handle selection AA ID
* No Log             :
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.USER
    $INSERT I_F.IM.DOCUMENT.IMAGE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.ALTERNATE.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    
*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
    FN.IM.DOC  = 'F.IM.DOCUMENT.IMAGE'
    F.IM.DOC   = ''
    CALL OPF(FN.IM.DOC, F.IM.DOC)

    FN.ACCT    = 'F.ACCOUNT'
    F.ACCT     = ''
    CALL OPF(FN.ACCT, F.ACCT)

    FN.ALT.ACT = 'F.ALTERNATE.ACCOUNT'
    F.ALT.ACT  = ''
    CALL OPF(FN.ALT.ACT, F.ALT.ACT)

    FN.USER    = 'F.USER'
    F.USER     = ''
    CALL OPF(FN.USER, F.USER)

    Y.USER.ID = OPERATOR
    
    FN.AA.ARRANGEMENT = "F.AA.ARRANGEMENT"
    F.AA.ARRANGEMENT  = ""
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    CALL F.READ(FN.USER, Y.USER.ID, R.USER, F.USER, USER.ERR)
    Y.USR.DEP.CD = R.USER<EB.USE.DEPARTMENT.CODE>

    Y.SEL.FLD = ENQ.SELECTION<2>

    FIND 'IMAGE.REFERENCE' IN Y.SEL.FLD SETTING POSF, POSV THEN
        Y.IMG.REF.OP     = ENQ.SELECTION<3, POSV>
        Y.IMG.REF.SEL    = ENQ.SELECTION<4, POSV>
        Y.IMG.REF.SEL.AA = ENQ.SELECTION<4, POSV>

    END

    IF Y.IMG.REF.SEL[1,2] EQ "AA" THEN
        CALL F.READ(FN.AA.ARRANGEMENT,Y.IMG.REF.SEL,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ERR.AA.ARRANGEMENT)
        Y.IMG.REF.SEL = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL.ID>
    END
    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    SEL.CMD  = 'SELECT ': FN.IM.DOC : ' AND WITH IMAGE.APPLICATION EQ ACCOUNT AA.ARRANGEMENT'
    SEL.CMD := ' AND WITH IMAGE.TYPE NE CU.CREDENTIAL'

    IF (Y.IMG.REF.SEL) THEN
        Y.ALT.ACT.ID = Y.IMG.REF.SEL
        CALL F.READ(FN.ALT.ACT, Y.ALT.ACT.ID, R.ALT.ACT, F.ALT.ACT, ALT.ACT.ERR)
        IF R.ALT.ACT THEN
            Y.IMG.REF.SEL = R.ALT.ACT<AAC.GLOBUS.ACCT.NUMBER>
        END

        SEL.CMD := ' AND WITH IMAGE.REFERENCE EQ ': Y.IMG.REF.SEL:" ":Y.IMG.REF.SEL.AA
    END

    SEL.CMD := ' BY DATE.TIME'

    CALL EB.READLIST(SEL.CMD, SEL.LIST, '', NO.REC, LIST.ERR)

    FOR A=1 TO NO.REC
        Y.IM.DOC.ID = SEL.LIST<A>
        CALL F.READ(FN.IM.DOC, Y.IM.DOC.ID, R.IM.DOC, F.IM.DOC, IM.DOC.ERR)

        Y.IMAGE.REFERENCE    = R.IM.DOC<IM.DOC.IMAGE.REFERENCE>
        Y.IMAGE.TYPE         = R.IM.DOC<IM.DOC.IMAGE.TYPE>
        Y.IMAGE              = R.IM.DOC<IM.DOC.IMAGE>

        Y.ACCT.ID = Y.IMAGE.REFERENCE
        CALL F.READ(FN.ACCT, Y.ACCT.ID, R.ACCT, F.ACCT, ACCT.ERR)
        IF (R.ACCT) THEN
            Y.ACCOUNT.OFFICER = R.ACCT<AC.ACCOUNT.OFFICER>
        END ELSE
            Y.ALT.ACT.ID = Y.IMAGE.REFERENCE
            CALL F.READ(FN.ALT.ACT, Y.ALT.ACT.ID, R.ALT.ACT, F.ALT.ACT, ALT.ACT.ERR)

            Y.ACCT.ID    = R.ALT.ACT<AAC.GLOBUS.ACCT.NUMBER>
            CALL F.READ(FN.ACCT, Y.ACCT.ID, R.ACCT, F.ACCT, ACCT.ERR)

            Y.ACCOUNT.OFFICER = R.ACCT<AC.ACCOUNT.OFFICER>
        END

        IF (LEN(Y.USR.DEP.CD) EQ 6) AND (Y.USR.DEP.CD[1,2] EQ '12') THEN
            IF (Y.ACCOUNT.OFFICER EQ Y.USR.DEP.CD) THEN
                GOSUB WRITE.OUTPUT
            END
        END ELSE
            GOSUB WRITE.OUTPUT
        END
    NEXT A

    RETURN
*-----------------------------------------------------------------------------
WRITE.OUTPUT:
*-----------------------------------------------------------------------------
    Y.OUT.TEMP  = Y.IM.DOC.ID ;*1
    Y.OUT.TEMP := "|" : Y.IMAGE.TYPE    ;*2
    Y.OUT.TEMP := "|" : Y.IMAGE         ;*3

    Y.OUTPUT<-1> = Y.OUT.TEMP

    RETURN
*-----------------------------------------------------------------------------
END






