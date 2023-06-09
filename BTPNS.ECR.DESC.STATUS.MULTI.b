*-----------------------------------------------------------------------------
    SUBROUTINE BTPNS.ECR.DESC.STATUS.MULTI
*-----------------------------------------------------------------------------
* Developer Name     : Moh Rizki Kurniawan
* Development Date   : 20220808
* Description        : Conversion routine for change status for mutli data error
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               :
* Modified by        :
* Description        :
*-----------------------------------------------------------------------------
	$INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
	$INSERT I_F.BTPNS.TL.BIFAST.UPLOAD.NAU
	$INSERT I_F.EB.FILE.UPLOAD

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------

	GOSUB INIT
	GOSUB PROCESS
	
    RETURN

*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
	
	FN.BTPNS.TL.BIFAST.UPLOAD.NAU	= 'F.BTPNS.TL.BIFAST.UPLOAD.NAU'
	F.BTPNS.TL.BIFAST.UPLOAD.NAU	= ''
	CALL OPF(FN.BTPNS.TL.BIFAST.UPLOAD.NAU, F.BTPNS.TL.BIFAST.UPLOAD.NAU)
	
	FN.EB.FILE.UPLOAD	= "F.EB.FILE.UPLOAD"
	F.EB.FILE.UPLOAD	= ""
	CALL OPF(FN.EB.FILE.UPLOAD, F.EB.FILE.UPLOAD)

    Y.APP 		= "EB.FILE.UPLOAD"
    Y.FIELDS  	= "B.BIFAST.STATUS":@VM:"B.ERROR.MSG"
    CALL MULTI.GET.LOC.REF(Y.APP,Y.FIELDS,Y.POS)

	Y.B.BIFAST.STATUS.POS		= Y.POS<1,1>
	Y.B.ERROR.MSG.POS			= Y.POS<1,2>
	

	
	RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	
	CALL F.READ(FN.EB.FILE.UPLOAD, O.DATA, R.EB.FILE.UPLOAD, F.EB.FILE.UPLOAD, EB.FILE.UPLOAD.ERR)
	Y.BIFAST.STATUS	= R.EB.FILE.UPLOAD<EbFileUpload_LocalRef, Y.B.BIFAST.STATUS.POS>
	Y.ERROR.MSG		= R.EB.FILE.UPLOAD<EbFileUpload_LocalRef, Y.B.ERROR.MSG.POS>

	IF Y.BIFAST.STATUS EQ 'UPLOADED' AND Y.ERROR.MSG NE '' THEN
		O.DATA	= 'ERROR'
	END ELSE
		O.DATA	= Y.BIFAST.STATUS
	END
	
	RETURN
*-----------------------------------------------------------------------------
END
