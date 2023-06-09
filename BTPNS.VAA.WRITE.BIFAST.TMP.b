	SUBROUTINE BTPNS.VAA.WRITE.BIFAST.TMP
*-----------------------------------------------------------------------------
* Developer Name     : Khoirul Rokhim
* Development Date   : 04 Agt 2022
* Description        : Check Maximal Row Upload BIFAST Outgoing
*-----------------------------------------------------------------------------
* Modification History:-
*-----------------------------------------------------------------------------
* Date               : Moh Rizki Kurniawan
* Modified by        : 18 Agustus 2022
* Description        : write processing to bifast status
*-----------------------------------------------------------------------------

	$INSERT I_COMMON
	$INSERT I_EQUATE
	$INSERT I_BATCH.FILES
	$INSERT I_TSA.COMMON
	$INSERT I_F.EB.FILE.UPLOAD
*	$INSERT I_F.BTPNS.TL.BIFAST.UPLOAD.TMP

*-----------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------
	GOSUB INIT
	GOSUB PROCESS

	RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------

	FN.EB.FILE.UPLOAD = 'F.EB.FILE.UPLOAD'
	F.EB.FILE.UPLOAD  = ''
	CALL OPF(FN.EB.FILE.UPLOAD, F.EB.FILE.UPLOAD)

	FN.BTPNS.TL.BIFAST.UPLOAD.TMP = 'F.BTPNS.TL.BIFAST.UPLOAD.TMP'
	F.BTPNS.TL.BIFAST.UPLOAD.TMP  = ''
	CALL OPF(FN.BTPNS.TL.BIFAST.UPLOAD.TMP, F.BTPNS.TL.BIFAST.UPLOAD.TMP)
	
    Y.APP 		= "EB.FILE.UPLOAD"
    Y.FIELDS  	= "B.BIFAST.STATUS"
    CALL MULTI.GET.LOC.REF(Y.APP,Y.FIELDS,Y.POS)

	Y.B.BIFAST.STATUS.POS		= Y.POS<1,1>

	RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
	Y.BIFAST.UPLOAD.TMP.ID				= ID.NEW
	R.BTPNS.TL.BIFAST.UPLOAD.TMP		= ""
	WRITE R.BTPNS.TL.BIFAST.UPLOAD.TMP TO F.BTPNS.TL.BIFAST.UPLOAD.TMP, Y.BIFAST.UPLOAD.TMP.ID
	
	R.NEW(EB.UF.LOCAL.REF)<1, Y.B.BIFAST.STATUS.POS>	= "PROCESSING"
	
	RETURN
*-----------------------------------------------------------------------------
END




