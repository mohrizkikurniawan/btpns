    SUBROUTINE BTPNS.MT.UPLOAD.BIFAST.DEL.FT(Y.REQ.FT)
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 08 Agustus 2022
* Description        : Routine to delete FT error Upload BIFAST 
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date            Modified by                Description
*-----------------------------------------------------------------------------
    $INCLUDE I_COMMON
    $INCLUDE I_EQUATE
    $INCLUDE I_GTS.COMMON
	$INSERT I_F.EB.FILE.UPLOAD
	$INSERT I_F.BTPNS.TL.BIFAST.UPLOAD.NAU
	$INSERT I_F.DM.MAPPING.DEFINITION
	
*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------

	COMMON/UPLOAD.BIFAST.DEL.FT.COM/FN.EB.FILE.UPLOAD,F.EB.FILE.UPLOAD,FN.BTPNS.TL.BIFAST.UPLOAD.NAU,F.BTPNS.TL.BIFAST.UPLOAD.NAU,FN.DM.MAPPING.DEFINITION,F.DM.MAPPING.DEFINITION,Y.UPLOAD.TYPE,Y.CO.CODE
	
    GOSUB INIT
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

	Y.FT	= FIELD(Y.REQ.FT, ".", 2)

	CALL F.READ(FN.DM.MAPPING.DEFINITION, Y.UPLOAD.TYPE, R.DMD, F.DM.MAPPING.DEFINITION, DM.MAPPING.DEFINITION.ERR)
	Y.APPLICATION.NAME		= R.DMD<DM.MD.APPLICATION.NAME>
	Y.OFS.ACTION			= R.DMD<DM.MD.OFS.ACTION>
	
	Y.OFS.SOURCE	= "BIFAST.MT"
    Y.APP.NAME		= Y.APPLICATION.NAME
    Y.OFS.FUNCT		= "D"
    Y.PROCESS		= Y.OFS.ACTION
    Y.OFS.VERSION	= Y.APP.NAME : ",DELETE.FT.BIFAST"
    Y.GTS.MODE		= ""
    Y.NO.OF.AUTH	= ""
    Y.TRANS.ID		= Y.FT
		
	Y.OFS.MESSAGE		= Y.OFS.VERSION : "/" : Y.OFS.FUNCT : "/" : Y.PROCESS : "/" : Y.GTS.MODE : "/" : Y.NO.OF.AUTH : "/,//" : Y.CO.CODE : "///////////////," : Y.TRANS.ID

    RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

	CALL OFS.CALL.BULK.MANAGER(Y.OFS.SOURCE, Y.OFS.MESSAGE, Y.OFS.RESPONSE, Y.RESULT)
	CHANGE '<requests>'           TO ''  IN Y.OFS.RESPONSE
    CHANGE '</request><request>'  TO @FM IN Y.OFS.RESPONSE
    CHANGE '<request>'            TO ''  IN Y.OFS.RESPONSE
    CHANGE '</request>'           TO ''  IN Y.OFS.RESPONSE
    CHANGE '</requests>'          TO ''  IN Y.OFS.RESPONSE
	
	Y.VALUE.RESPONSE 	= FIELD(Y.OFS.RESPONSE, "/", 3)[1,1] 
	IF Y.VALUE.RESPONSE EQ '1' THEN
		CALL F.DELETE(FN.BTPNS.TL.BIFAST.UPLOAD.NAU, Y.REQ.FT)
	END
	
    RETURN

*-----------------------------------------------------------------------------
END
