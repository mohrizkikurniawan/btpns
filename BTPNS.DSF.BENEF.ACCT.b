    SUBROUTINE BTPNS.DSF.BENEF.ACCT(Y.DATA)
*-----------------------------------------------------------------------------
* Developer Name     : Saidah Manshuroh
* Development Date   : 20221222
* Description        : Routine to show beneficiary information
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date			Modified by					Description
*-----------------------------------------------------------------------------
* Date           	: 
* Modified by    	: 
* Description		: 
*-----------------------------------------------------------------------------
*
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
	
	FN.FUNDS.TRANSFER		= "F.FUNDS.TRANSFER"
	F.FUNDS.TRANSFER		= ""
	CALL OPF(FN.FUNDS.TRANSFER, F.FUNDS.TRANSFER)
	
	Y.APP<1>				= "FUNDS.TRANSFER"
	Y.FLD<1,1>				= "B.CDTR.PRXYTYPE"
	Y.FLD<1,2>				= "B.CDTR.PRXYID"
	Y.FLD<1,3>				= "B.CDTR.ACCID"
	CALL MULTI.GET.LOC.REF(Y.APP, Y.FLD, Y.POS)
	Y.B.CDTR.PRXYTYPE.POS	= Y.POS<1,1>
	Y.B.CDTR.PRXYID.POS		= Y.POS<1,2>
	Y.B.CDTR.ACCID.POS		= Y.POS<1,3>

    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

	Y.ID.FT				= Y.DATA
	CALL F.READ(FN.FUNDS.TRANSFER, Y.ID.FT, R.FUNDS.TRANSFER, F.FUNDS.TRANSFER, Y.ERR.FUNDS.TRANSFER)
	Y.B.CDTR.PRXYTYPE	= R.FUNDS.TRANSFER<FT.LOCAL.REF, Y.B.CDTR.PRXYTYPE.POS>
	Y.B.CDTR.PRXYID		= R.FUNDS.TRANSFER<FT.LOCAL.REF, Y.B.CDTR.PRXYID.POS>
	Y.B.CDTR.ACCID		= R.FUNDS.TRANSFER<FT.LOCAL.REF, Y.B.CDTR.ACCID.POS>
	
	BEGIN CASE
	CASE Y.B.CDTR.PRXYTYPE EQ "1"
		Y.DATA = Y.B.CDTR.PRXYID
		
	CASE Y.B.CDTR.PRXYTYPE EQ "2"
		Y.DATA = Y.B.CDTR.PRXYID
		
	CASE 1
		Y.DATA = Y.B.CDTR.ACCID
	END CASE
		
    RETURN
*-----------------------------------------------------------------------------
END
