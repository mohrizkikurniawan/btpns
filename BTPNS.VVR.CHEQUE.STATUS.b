*-----------------------------------------------------------------------------
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.VVR.CHEQUE.STATUS
*-----------------------------------------------------------------------------
* Developer Name     : Ratih Purwaning Utami
* Development Date   : 20220622
* Description        : Input routine for checking valid cheque number/BG
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               :
* Modified by        :
* Description        :
* No Log             :
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CHEQUE.REGISTER
    $INSERT I_F.CHEQUES.STOPPED
    $INSERT I_F.CHEQUES.PRESENTED
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.TELLER
    $INSERT I_F.CHEQUE.REGISTER.SUPPLEMENT
    $INSERT I_F.ACCOUNT

    GOSUB INIT
    GOSUB GET.DATA
    GOSUB PROCESS
 
    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
    FN.CHQ.RGTS = "F.CHEQUE.REGISTER"
    F.CHQ.RGTS  = ""
    CALL OPF(FN.CHQ.RGTS,F.CHQ.RGTS)

    FN.ACCOUNT = "F.ACCOUNT"
    F.ACCOUNT  = ""
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.CHQ.STOP = "F.CHEQUES.STOPPED"
    F.CHQ.STOP  = ""
    CALL OPF(FN.CHQ.STOP,F.CHQ.STOP)

    FN.CHQ.PRESENTED = "F.CHEQUES.PRESENTED"
    F.CHQ.PRESENTED  = ""
    CALL OPF(FN.CHQ.PRESENTED,F.CHQ.PRESENTED)

    FN.CHQ.REG.SUP = "F.CHEQUE.REGISTER.SUPPLEMENT"
    F.CHQ.REG.SUP  = ""
    CALL OPF(FN.CHQ.REG.SUP,F.CHQ.REG.SUP)

    CHEQUE = COMI
    Y.STATUS = '' ; STOP.ERR = ''
    CMD.LIST = '' ; ERR1 = ''

    RETURN

*-----------------------------------------------------------------------------
GET.DATA:
    BEGIN CASE
    CASE APPLICATION EQ "FUNDS.TRANSFER"
        ACCT.NO = R.NEW(FT.DEBIT.ACCT.NO)
        CHEQ.TYPE = R.NEW(FT.CHEQ.TYPE)
        AF = FT.CHEQUE.NUMBER
    CASE APPLICATION EQ "TELLER"
        IF R.NEW(TT.TE.DR.CR.MARKER) EQ "CREDIT" THEN
            ACCT.NO = R.NEW(TT.TE.ACCOUNT.2)
        END ELSE
            ACCT.NO = R.NEW(TT.TE.ACCOUNT.1)
        END
        CHEQ.TYPE = R.NEW(TT.TE.CHEQ.TYPE)
        AF = TT.TE.CHEQUE.NUMBER
    END CASE

    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	
	CALL F.READ(FN.ACCOUNT, ACCT.NO, R.ACCOUNT, F.ACCOUNT, ERR.ACCOUNT)
    Y.CATEGORY = R.ACCOUNT<AC.CATEGORY>
	
*	IF Y.CATEGORY GE 1000 AND Y.CATEGORY LT 2999 ELSE
*		RETURN
*	END

    IF NOT(CHEQUE) THEN
        RETURN
    END
		
    CMD = "SELECT " : FN.CHQ.RGTS
    CMD := " WITH @ID LIKE ..." : ACCT.NO
    CALL EB.READLIST(CMD, CMD.LIST, "", "", "")
    IF CMD.LIST EQ "" THEN
        ETEXT = "ST-CHQ.AC.MISS"
        CALL STORE.END.ERROR
    END ELSE
        GOSUB CHQ.REGISTER
        GOSUB CHQ.STOPPED
    END

    RETURN

*-----------------------------------------------------------------------------
CHQ.REGISTER:
*-----------------------------------------------------------------------------
    LOOP
        REMOVE CHQ.RGTS.ID FROM CMD.LIST SETTING POS
    WHILE CHQ.RGTS.ID:POS
        R.CHQ.RGTS = ""
        Y.RGTS.CHQ.TYPE = FIELDS(CHQ.RGTS.ID,'.',1)
        IF Y.RGTS.CHQ.TYPE EQ CHEQ.TYPE THEN
            CALL F.READ(FN.CHQ.RGTS,CHQ.RGTS.ID,R.CHQ.RGTS,F.CHQ.RGTS,ERR1)
            ER1 = ""
            NO.OF.ISS = DCOUNT(R.CHQ.RGTS<CHEQUE.REG.CHEQUE.NOS>,@VM)
            FOR ISS.NO = 1 TO NO.OF.ISS
                START.NO = FIELD(R.CHQ.RGTS<CHEQUE.REG.CHEQUE.NOS,ISS.NO>,"-",1)
                END.NO = FIELD(R.CHQ.RGTS<CHEQUE.REG.CHEQUE.NOS,ISS.NO>,"-",2)
                IF END.NO = '' THEN
                    END.NO = START.NO
                END

                IF (CHEQUE GE START.NO) AND (CHEQUE LE END.NO) THEN
                    Y.STATUS = 'SUCESS'
                    CHQ.TYPE = FIELD(CHQ.RGTS.ID,".",1)
                    EXIT
                END
            NEXT ISS.NO
            IF Y.STATUS EQ 'SUCESS' THEN
                EXIT
            END
        END
    REPEAT

    RETURN

*-----------------------------------------------------------------------------
CHQ.STOPPED:
*-----------------------------------------------------------------------------
    IF Y.STATUS EQ '' THEN
        ETEXT = "ST-CHQ.AC.MISS"
        CALL STORE.END.ERROR
        RETURN
    END

    Y.CHQ.REG.SUP = CHQ.TYPE:".":ACCT.NO:".":TRIM(CHEQUE,"0","L")
    CALL F.READ(FN.CHQ.REG.SUP,Y.CHQ.REG.SUP,R.CHQ.REG.SUP,F.CHQ.REG.SUP,Y.CHQ.REG.SUP.ERR)
    IF R.CHQ.REG.SUP THEN
        Y.REG.SUP.STATUS = R.CHQ.REG.SUP<CC.CRS.STATUS>
        BEGIN CASE
        CASE Y.REG.SUP.STATUS EQ "CLEARED"
            ETEXT = "ST-CHQ.ALRDY.PRESENTED"
            CALL STORE.END.ERROR
        CASE Y.REG.SUP.STATUS EQ "STOPPED"
            ETEXT = "ST-CHQ.ALRDY.STOPPED"
            CALL STORE.END.ERROR
        CASE 1
            GOSUB CHQ.RETURNED
        END CASE
    END

    RETURN

*-----------------------------------------------------------------------------
CHQ.RETURNED:
*-----------------------------------------------------------------------------
    SEL.CMD = "SELECT ":FN.CHQ.RGTS
    SEL.CMD := " WITH @ID LIKE ...":ACCT.NO
    CALL EB.READLIST(SEL.CMD,SEL.LIST,"",SEL.CNT,SEL.ERR)

    IF SEL.LIST THEN
        LOOP
            REMOVE Y.ID.CHQ FROM SEL.LIST SETTING POS
        WHILE Y.ID.CHQ:POS
            Y.RGTS.CHQ.TYPE = FIELDS(Y.ID.CHQ,'.',1)

            CALL F.READ(FN.CHQ.RGTS,Y.ID.CHQ,R.CHQ,F.CHQ.RGTS,CHQ.ERR)
            Y.CHQ.RETURNED = R.CHQ<CHEQUE.REG.RETURNED.CHQS>

            IF Y.RGTS.CHQ.TYPE EQ CHEQ.TYPE AND Y.CHQ.RETURNED NE '' THEN
                LOCATE CHEQUE IN Y.CHQ.RETURNED<1,1> SETTING POS1 THEN
                    ETEXT = "EB-CHEQUE.RETURNED"
                    CALL STORE.END.ERROR
                END
            END
        REPEAT
    END

    RETURN
*-----------------------------------------------------------------------------
END
