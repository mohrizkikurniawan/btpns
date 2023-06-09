*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.UPLOAD.BIFAST.DEL.FT.LOAD
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 08 Agustus 2022
* Description        : Routine to delete FT error Upload BIFAST 
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
* Date           	: -
* Modified by    	: -
* Description		: -
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
    $INCLUDE I_COMMON
    $INCLUDE I_EQUATE
    $INCLUDE I_GTS.COMMON
*-----------------------------------------------------------------------------
	
	COMMON/UPLOAD.BIFAST.DEL.FT.COM/FN.EB.FILE.UPLOAD,F.EB.FILE.UPLOAD,FN.BTPNS.TL.BIFAST.UPLOAD.NAU,F.BTPNS.TL.BIFAST.UPLOAD.NAU,FN.DM.MAPPING.DEFINITION,F.DM.MAPPING.DEFINITION,Y.UPLOAD.TYPE,Y.CO.CODE
	
	FN.EB.FILE.UPLOAD	= "F.EB.FILE.UPLOAD"
	F.EB.FILE.UPLOAD	= ""
	CALL OPF(FN.EB.FILE.UPLOAD, F.EB.FILE.UPLOAD)
	
	FN.BTPNS.TL.BIFAST.UPLOAD.NAU	= 'F.BTPNS.TL.BIFAST.UPLOAD.NAU'
	F.BTPNS.TL.BIFAST.UPLOAD.NAU	= ''
	CALL OPF(FN.BTPNS.TL.BIFAST.UPLOAD.NAU, F.BTPNS.TL.BIFAST.UPLOAD.NAU)
	
	FN.DM.MAPPING.DEFINITION		= 'F.DM.MAPPING.DEFINITION'
	F.DM.MAPPING.DEFINITION			= ''
	CALL OPF(FN.DM.MAPPING.DEFINITION, F.DM.MAPPING.DEFINITION)

    RETURN

END 