*------------------------------------------------------------------------------
    SUBROUTINE BTPNS.MT.UPLOAD.BIFAST.INPUT.FT.SELECT
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

	SEL.LIST 	= ""
    SEL.CMD 	= "SELECT " : FN.BTPNS.TL.BIFAST.UPLOAD.TMP
    CALL EB.READLIST(SEL.CMD, SEL.LIST, "", SEL.CNT, SEL.ERR)
	SEL.LIST	= SEL.LIST<1>
	
	CALL F.READ(FN.EB.FILE.UPLOAD, SEL.LIST, R.EB.FILE.UPLOAD, F.EB.FILE.UPLOAD, EB.FILE.UPLOAD.ERR)
	
	Y.UPLOAD.TYPE		= R.EB.FILE.UPLOAD<EbFileUpload_UploadType>
	Y.SYSTEM.FILE.NAME	= R.EB.FILE.UPLOAD<EbFileUpload_SystemFileName>
	Y.CO.CODE			= R.EB.FILE.UPLOAD<EbFileUpload_TargetCompany>
	
	IF Y.CO.CODE EQ '' THEN
		Y.CO.CODE		= R.EB.FILE.UPLOAD<EbFileUpload_CoCode>
	END
	
	CALL F.READ(FN.EB.FILE.UPLOAD.TYPE, Y.UPLOAD.TYPE, R.EB.FILE.UPLOAD.TYPE, F.EB.FILE.UPLOAD.TYPE, EB.FILE.UPLOAD.TYPE.ERR)
	Y.UPLOAD.DIR		= R.EB.FILE.UPLOAD.TYPE<EbFileUploadType_UploadDir>

    CALL F.READ(FN.EB.FILE.UPLOAD.PARAM, "SYSTEM", R.EB.FILE.UPLOAD.PARAM, F.EB.FILE.UPLOAD.PARAM, EB.FILE.UPLOAD.PARAM.ERR)
	Y.TC.UPLOAD.PATH	= R.EB.FILE.UPLOAD.PARAM<EbFileUploadParam_TcUploadPath>
	FN.DIR.FILE			= Y.TC.UPLOAD.PATH : "\" : Y.UPLOAD.DIR
	
	OPEN FN.DIR.FILE TO F.DIR.FILE ELSE
        Y.ERROR.MESSAGE = "CANNOT OPEN TXT FILE FOLDER"
        RETURN
    END		

	CALL F.READ(FN.DIR.FILE, Y.SYSTEM.FILE.NAME, R.DIR.FILE, F.DIR.FILE, DIR.FILE.ERR)
	
	Y.DIR.FILE.CNT = DCOUNT(R.DIR.FILE, @FM)
	Y.DIR.FILE	= ""
	FOR Y.I = 1 TO Y.DIR.FILE.CNT
		Y.DIR.FILE<-1>  = R.DIR.FILE<Y.I> : "|" : Y.I : "*" : SEL.LIST : "|" : Y.UPLOAD.TYPE : "|" : Y.CO.CODE
	NEXT Y.I
	
	CALL OCOMO("Data to process : " : Y.DIR.FILE.CNT)
	CALL OCOMO("Records to process: " : Y.DIR.FILE)
	
    CALL BATCH.BUILD.LIST("", Y.DIR.FILE)
	
    RETURN

END 