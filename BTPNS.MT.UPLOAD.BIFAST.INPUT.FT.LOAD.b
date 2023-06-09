*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.UPLOAD.BIFAST.INPUT.FT.LOAD
*------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 08 Agustus 2022
* Description        : Routine to process FT $NAU Upload BIFAST 
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
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
	$INSERT I_F.EB.FILE.UPLOAD
	$INSERT I_F.EB.FILE.UPLOAD.TYPE
	$INSERT I_F.EB.FILE.UPLOAD.PARAM
	$INSERT I_F.FUNDS.TRANSFER
	$INSERT I_F.DM.MAPPING.DEFINITION
	$INSERT I_F.BTPNS.TL.BIFAST.UPLOAD.NAU
*-----------------------------------------------------------------------------

	COMMON/UPLOAD.BIFAST.INPUT.FT.COM/FN.BTPNS.TL.BIFAST.UPLOAD.TMP,F.BTPNS.TL.BIFAST.UPLOAD.TMP,FN.EB.FILE.UPLOAD.TYPE,F.EB.FILE.UPLOAD.TYPE,FN.EB.FILE.UPLOAD.PARAM,F.EB.FILE.UPLOAD.PARAM,FN.EB.FILE.UPLOAD,F.EB.FILE.UPLOAD,FN.FUNDS.TRANSFER,F.FUNDS.TRANSFER,FN.DM.MAPPING.DEFINITION,F.DM.MAPPING.DEFINITION,Y.UPLOAD.TYPE,FN.BTPNS.TL.BIFAST.UPLOAD.NAU,F.BTPNS.TL.BIFAST.UPLOAD.NAU,FN.FOLDER.LOG,F.FOLDER.LOG,FN.DIR.FILE,F.DIR.FILE
	
	FN.BTPNS.TL.BIFAST.UPLOAD.TMP	= "F.BTPNS.TL.BIFAST.UPLOAD.TMP"
	F.BTPNS.TL.BIFAST.UPLOAD.TMP	= ""
	CALL OPF(FN.BTPNS.TL.BIFAST.UPLOAD.TMP, F.BTPNS.TL.BIFAST.UPLOAD.TMP)
	
	FN.EB.FILE.UPLOAD	= "F.EB.FILE.UPLOAD"
	F.EB.FILE.UPLOAD	= ""
	CALL OPF(FN.EB.FILE.UPLOAD, F.EB.FILE.UPLOAD)
	
	FN.EB.FILE.UPLOAD.TYPE = 'F.EB.FILE.UPLOAD.TYPE'
	F.EB.FILE.UPLOAD.TYPE  = ''
	CALL OPF(FN.EB.FILE.UPLOAD.TYPE, F.EB.FILE.UPLOAD.TYPE)

	FN.EB.FILE.UPLOAD.PARAM = 'F.EB.FILE.UPLOAD.PARAM'
	F.EB.FILE.UPLOAD.PARAM  = ''
	CALL OPF(FN.EB.FILE.UPLOAD.PARAM, F.EB.FILE.UPLOAD.PARAM)
	
	FN.FUNDS.TRANSFER	= "F.FUNDS.TRANSFER"
	F.FUNDS.TRANSFER	= ""
	CALL OPF(FN.FUNDS.TRANSFER, F.FUNDS.TRANSFER)
	
	FN.BTPNS.TL.BIFAST.UPLOAD.NAU	= 'F.BTPNS.TL.BIFAST.UPLOAD.NAU'
	F.BTPNS.TL.BIFAST.UPLOAD.NAU	= ''
	CALL OPF(FN.BTPNS.TL.BIFAST.UPLOAD.NAU, F.BTPNS.TL.BIFAST.UPLOAD.NAU)
	
	FN.DM.MAPPING.DEFINITION	= 'F.DM.MAPPING.DEFINITION'
	F.DM.MAPPING.DEFINITION		= ''
	CALL OPF(FN.DM.MAPPING.DEFINITION, F.DM.MAPPING.DEFINITION)
	
	FN.FOLDER.LOG = "../UD/APPSHARED.BP/BIFAST.OUTGOING"
	OPEN FN.FOLDER.LOG TO F.FOLDER.LOG ELSE
        Y.ERROR.MESSAGE = "CANNOT OPEN TXT FILE FOLDER"
        RETURN
    END	

    RETURN

END 