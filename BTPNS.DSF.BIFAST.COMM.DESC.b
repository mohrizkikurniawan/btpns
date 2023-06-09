SUBROUTINE BTPNS.DSF.BIFAST.COMM.DESC(Y.DATA)
*-----------------------------------------------------------------------------
* Developer Name     : Ratih Purwaning Utami
* Development Date   : 20221010
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
        Y.CATEGORY = Y.ACCOUNT
    END ELSE
        CALL F.READ(FN.ACCOUNT,Y.ACCOUNT,R.AC, F.ACCOUNT,READ.AC.ERR)
        Y.CATEGORY = R.AC<AC.CATEGORY>
    END

    CALL F.READ(FN.CATEGORY,Y.CATEGORY,R.CATEGORY,F.CATEGORY,CATEGORY.ERR)

    Y.DESCRIPTION = R.CATEGORY<EB.CAT.DESCRIPTION>

    Y.DATA = Y.DESCRIPTION

    RETURN	

*-----------------------------------------------------------------------------
END


