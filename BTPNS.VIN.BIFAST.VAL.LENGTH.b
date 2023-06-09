    SUBROUTINE BTPNS.VIN.BIFAST.VAL.LENGTH
*-----------------------------------------------------------------------------
* Developer Name     : Ratih Purwaning Utami
* Development Date   : 20220610
* Description        : Input routine for remarks validation BIFAST Outgoing Credit
*                      Modification from IDCV.IN.FT.VAL.RMK
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
    $INSERT I_F.FUNDS.TRANSFER


*-------------------------------------------------------------------------------
INITIALISE:
*-------------------------------------------------------------------------------
    Y.POS    = ""
    Y.APPS   = "FUNDS.TRANSFER"
    Y.FIELDS = "B.DBTR.NM" : VM : "B.CDTR.NM"
    CALL MULTI.GET.LOC.REF(Y.APPS, Y.FIELDS, Y.POS)

    Y.DEBITOR.NAME.POS  = Y.POS<1,1>
    Y.CREDITOR.NAME.POS = Y.POS<1,2>

*-------------------------------------------------------------------------------
PROCESS:
*-------------------------------------------------------------------------------

*    Y.REMARK = R.NEW(FT.PAYMENT.DETAILS)
*	Y.CNT = DCOUNT(Y.REMARK,@VM)
*	CONVERT VM TO "" IN Y.REMARK
*	
*    IF LEN(Y.REMARK) GT 140 THEN
*        AF = FT.PAYMENT.DETAILS
*        ETEXT<1> = "FT-BIFAST.TOO.MANY.CHAR"
*        ETEXT<2> = "140"
*        CALL STORE.END.ERROR
*    END

    Y.DEBITOR.NAME = R.NEW(FT.LOCAL.REF)<1,Y.DEBITOR.NAME.POS>
	Y.CNT2 = DCOUNT(Y.DEBITOR.NAME,@SM)
	CONVERT SM TO "" IN Y.DEBITOR.NAME
	
    IF LEN(Y.DEBITOR.NAME) GT 140 THEN
        AF = FT.LOCAL.REF
        AV = Y.DEBITOR.NAME.POS
        ETEXT<1> = "FT-BIFAST.TOO.MANY.CHAR"
        ETEXT<2> = "140"
        CALL STORE.END.ERROR
		RETURN
    END

    Y.CREDITOR.NAME = R.NEW(FT.LOCAL.REF)<1,Y.CREDITOR.NAME.POS>
	Y.CNT3 = DCOUNT(Y.CREDITOR.NAME,@SM)
	CONVERT SM TO "" IN Y.CREDITOR.NAME
	
    IF LEN(Y.CREDITOR.NAME) GT 140 THEN
        AF = FT.LOCAL.REF
        AV = Y.CREDITOR.NAME.POS
        ETEXT = "FT-BIFAST.TOO.MANY.CHAR"
*        ETEXT<2> = "140"
*        CALL STORE.END.ERROR
		RETURN
    END

    RETURN
*-----------------------------------------------------------------------------------------
END
