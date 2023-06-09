    SUBROUTINE BTPNS.VIN.BIFAST.COM.TYPE
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20221201
* Description        : Routine to default charge.acct from db ac
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* 
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	DEBUG
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
	
    vCommissionCode = R.NEW(FT.COMMISSION.CODE)
	vCommissionType	= R.NEW(FT.COMMISSION.TYPE)

    IF vCommissionCode NE "WAIVE" THEN
        N(FT.COMMISSION.TYPE) = "10.1"

        IF vCommissionType EQ "" THEN
            ETEXT = "EB-INPUT.MISSING"
            AF = FT.COMMISSION.TYPE
            CALL STORE.END.ERROR
        END
    END
*\20220823


    RETURN	

*-----------------------------------------------------------------------------
END
