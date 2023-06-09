    SUBROUTINE BTPNS.VIN.BIFAST.DB.CHRG
*-----------------------------------------------------------------------------
* Developer Name     : Ratih Purwaning Utami
* Development Date   : 20220622
* Description        : Routine to default charge.acct from db ac
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* 20220823        Ratih Purwaning Utami      Update mandatory condition for commission.type
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
    

    RETURN	

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    Y.ACCOUNT = R.NEW(FT.DEBIT.ACCT.NO)

    IF R.NEW(FT.COMMISSION.CODE) EQ "WAIVE" OR "" THEN
        R.NEW(FT.CHARGES.ACCT.NO) = ""
        R.NEW(FT.COMMISSION.TYPE) = ""
        R.NEW(FT.COMMISSION.AMT) = ""
    END ELSE
        R.NEW(FT.CHARGES.ACCT.NO) = Y.ACCOUNT
    END

*20220823

    IF R.NEW(FT.COMMISSION.CODE) NE "WAIVE" THEN
        N(FT.COMMISSION.TYPE) = "10.1"

        IF R.NEW(FT.COMMISSION.TYPE) EQ "" THEN
            ETEXT = "EB-INPUT.MISSING"
            AF = FT.COMMISSION.TYPE
            CALL STORE.END.ERROR
        END
    END
*\20220823


    RETURN	

*-----------------------------------------------------------------------------
END
