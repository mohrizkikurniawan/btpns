SUBROUTINE BTPNS.DSF.STO.COMM.ACC(Y.DATA)
*-----------------------------------------------------------------------------
* Developer Name     : Ratih Purwaning Utami
* Development Date   : 20221208
* Description        : Routine to get pl or ia acct desc
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_F.CATEGORY
    $INSERT I_F.ACCOUNT

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

    FN.FT.COMMISSION.TYPE = "F.FT.COMMISSION.TYPE"
    F.FT.COMMISSION.TYPE = ""
    CALL OPF(FN.FT.COMMISSION.TYPE,F.FT.COMMISSION.TYPE)

    FN.CATEGORY = "F.CATEGORY"
    F.CATEGORY = ""
    CALL OPF(FN.CATEGORY,F.CATEGORY)

    FN.ACCOUNT = "F.ACCOUNT"
    F.ACCOUNT  = ""
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)

    Y.COMMISSION.TYPE = Y.DATA

    RETURN	

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    CALL F.READ(FN.FT.COMMISSION.TYPE,Y.COMMISSION.TYPE,R.FT.COMMISSION.TYPE,F.FT.COMMISSION.TYPE,FCT.ERR)

    Y.ACCOUNT = R.FT.COMMISSION.TYPE<FT4.CATEGORY.ACCOUNT>

    IF LEN(Y.ACCOUNT) EQ 5 THEN
        Y.CATEGORY = "PL" : Y.ACCOUNT
    END ELSE
        Y.CATEGORY = Y.ACCOUNT
        IF Y.CATEGORY[4] EQ '0000' THEN
            Y.CATEGORY = Y.CATEGORY[1,12]:ID.COMPANY[4]
        END
    END

    Y.DATA = Y.CATEGORY

    RETURN	

*-----------------------------------------------------------------------------
END


