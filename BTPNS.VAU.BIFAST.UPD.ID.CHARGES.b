    SUBROUTINE BTPNS.VAU.BIFAST.UPD.ID.CHARGES
*-----------------------------------------------------------------------------
* Developer Name     : Ratih Purwaning Utami
* Development Date   : 20220727
* Description        : Auth Routine to update FT charges in IDIH.WS.DATA.FT.MAP
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
	$INSERT I_F.IDIH.WS.DATA.FT.MAP

    GOSUB INIT
	GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	
	FN.IDIH.WS.DATA.FT.MAP = "F.IDIH.WS.DATA.FT.MAP"
	F.IDIH.WS.DATA.FT.MAP  = ""
	CALL OPF(FN.IDIH.WS.DATA.FT.MAP,F.IDIH.WS.DATA.FT.MAP)

	CALL GET.LOC.REF("IDIH.WS.DATA.FT.MAP","FT.CHARGES",Y.FT.CHARGES.POS)
	CALL GET.LOC.REF("FUNDS.TRANSFER","REL.REF",Y.REL.REF.POS)

    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	Y.ID = R.NEW(FT.LOCAL.REF)<1,Y.REL.REF.POS>
	CALL F.READ(FN.IDIH.WS.DATA.FT.MAP,Y.ID,R.IDIH.WS.DATA.FT.MAP,F.IDIH.WS.DATA.FT.MAP,READ.ERR3)
    R.IDIH.WS.DATA.FT.MAP<WS.DATA.FT.ERROR.DESC> = ID.NEW
    CALL F.WRITE(FN.IDIH.WS.DATA.FT.MAP,Y.IN.REVERSAL.ID,R.IDIH.WS.DATA.FT.MAP)

*	WRITE R.IDIH.WS.DATA.FT.MAP TO F.IDIH.WS.DATA.FT.MAP, Y.IN.REVERSAL.ID
    
	RETURN
*-----------------------------------------------------------------------------
END

