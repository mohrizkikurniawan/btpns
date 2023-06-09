*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.UPLOAD.BIFAST.DEL.FT.SELECT
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
	$INSERT I_F.EB.FILE.UPLOAD
	$INSERT I_F.BTPNS.TL.BIFAST.UPLOAD.NAU
	

*-----------------------------------------------------------------------------
	COMMON/UPLOAD.BIFAST.DEL.FT.COM/FN.EB.FILE.UPLOAD,F.EB.FILE.UPLOAD,FN.BTPNS.TL.BIFAST.UPLOAD.NAU,F.BTPNS.TL.BIFAST.UPLOAD.NAU,FN.DM.MAPPING.DEFINITION,F.DM.MAPPING.DEFINITION,Y.UPLOAD.TYPE,Y.CO.CODE
	
	
	Y.DATA.ERROR	=	""
	SEL.CMD := "SELECT " : FN.EB.FILE.UPLOAD : " WITH UPLOAD.TYPE EQ 'BIFAST.OUTGOING' AND B.ERROR.MSG NE ''"
    CALL EB.READLIST(SEL.CMD, SEL.LIST, "", SEL.CNT, SEL.ERR)
	
	CALL F.READ(FN.EB.FILE.UPLOAD, SEL.LIST<1>, R.EB.FILE.UPLOAD, F.EB.FILE.UPLOAD, EB.FILE.UPLOAD.ERR)
	Y.UPLOAD.TYPE		= R.EB.FILE.UPLOAD<EbFileUpload_UploadType>
	Y.CO.CODE			= R.EB.FILE.UPLOAD<EbFileUpload_TargetCompany>
	
	IF Y.CO.CODE EQ '' THEN
		Y.CO.CODE		= R.EB.FILE.UPLOAD<EbFileUpload_CoCode>
	END
	
	FOR Y.I = 1 TO SEL.CNT
		Y.ID.UPLOAD	= SEL.LIST<Y.I>
		SEL.CMD.NAU := "SELECT " : FN.BTPNS.TL.BIFAST.UPLOAD.NAU : " WITH @ID LIKE ..." : Y.ID.UPLOAD : "..."
	    CALL EB.READLIST(SEL.CMD.NAU, SEL.LIST.NAU, "", SEL.CNT.NAU, SEL.NAU.ERR)
		FOR Y.J = 1 TO SEL.CNT.NAU
			Y.DATA.ERROR<-1>	= SEL.LIST.NAU<Y.J>
		NEXT Y.J
		SEL.CMD.NAU		= ''
	NEXT Y.I

    CALL BATCH.BUILD.LIST("", Y.DATA.ERROR)

    RETURN

END 