	SUBROUTINE BTPNS.VAA.BIFAST.DEL.FT.SUCCESS
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 18 Agt 2022
* Description        : Delete FT succes authorize in upload bifast
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               : 
* Modified by        : 
* Description        : 
*-----------------------------------------------------------------------------

	$INSERT I_COMMON
	$INSERT I_EQUATE
	$INSERT I_F.EB.FILE.UPLOAD
	$INSERT I_F.BTPNS.TL.BIFAST.UPLOAD.NAU

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	
	GOSUB INIT
	GOSUB PROCESS

	RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

	FN.BTPNS.TL.BIFAST.UPLOAD.NAU = 'F.BTPNS.TL.BIFAST.UPLOAD.NAU'
	F.BTPNS.TL.BIFAST.UPLOAD.NAU  = ''
	CALL OPF(FN.BTPNS.TL.BIFAST.UPLOAD.NAU, F.BTPNS.TL.BIFAST.UPLOAD.NAU)
	

	RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

	SEL.CMD := "SELECT " : FN.BTPNS.TL.BIFAST.UPLOAD.NAU : " WITH @ID LIKE ..." : ID.NEW : "..."
	CALL EB.READLIST(SEL.CMD, SEL.LIST, "", SEL.CNT, SEL.ERR)

	CALL F.DELETE(FN.BTPNS.TL.BIFAST.UPLOAD.NAU, SEL.LIST)
	
	RETURN
*-----------------------------------------------------------------------------
END




