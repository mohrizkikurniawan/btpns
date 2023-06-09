    SUBROUTINE BTPNS.VAT.DEF.PRINTED.ADD
*-----------------------------------------------------------------------------
* Developer Name     : Saidah Manshuroh
* Development Date   : 20221006
* Description        : Routine to set default value for address printed
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* Date           	: 
* Modified by    	: 
* Description		: 
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
	$INSERT I_F.AA.ACCOUNT

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
    GOSUB INIT
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

	Y.APP<1>			= "AA.ARR.ACCOUNT"
	Y.FLD<1,1>			= "ADD.PRINTED"
	Y.POS				= ""
	CALL MULTI.GET.LOC.REF(Y.APP, Y.FLD, Y.POS)
	Y.ADD.PRINTED.POS	= Y.POS<1,1>


    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

	Y.ADD.PRINTED	= R.NEW(AA.AC.LOCAL.REF)<1, Y.ADD.PRINTED.POS>
	IF Y.ADD.PRINTED EQ "" THEN
		R.NEW(AA.AC.LOCAL.REF)<1, Y.ADD.PRINTED.POS>	= "01 - Alamat Sesuai Identitas"
	END
		
    RETURN
*-----------------------------------------------------------------------------
END
